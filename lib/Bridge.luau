local RunService = game:GetService("RunService")

export type NetServer = "NET_SERVER"

export type Identifier = string

export type IncomingPacket = {
	identifier: Identifier,
	sender: Player | NetServer,
	data: { any },
}

export type IncomingQueue = {
	Reliable: { IncomingPacket },
	Unreliable: { IncomingPacket },
}

export type Recipient = { Player } | Player | "NET_SERVER"

export type OutgoingPacket = {
	channel: "Reliable" | "Unreliable",
	identifier: Identifier,
	recipient: Recipient,
	data: { any },
}

export type OutgoingQueue = {
	Reliable: { OutgoingPacket },
	Unreliable: { OutgoingPacket },
}

type Payload = {
	[string]: { { any } },
}

export type BridgeImpl = {
	server: NetServer,
	reliableRemote: RemoteEvent,
	unreliableRemote: UnreliableRemoteEvent,

	_incomingQueue: IncomingQueue,
	_outgoingQueue: OutgoingQueue,
	_snapshot: IncomingQueue,

	__index: BridgeImpl,

	_addPacketToPayload: (self: Bridge, {
		Reliable: Payload,
		Unreliable: Payload,
	}, OutgoingPacket) -> (),
	_updateClientPayload: (
		self: Bridge,
		clientPackages: {
			[Player]: {
				Reliable: Payload,
				Unreliable: Payload,
			},
		},
		player: Player,
		packet: OutgoingPacket
	) -> (),
	_sendPayloads: (self: Bridge, clientPayloads: ClientPayloads, clientPayloads: ServerPayloads) -> (),
	_processOutgoingQueue: (self: Bridge) -> (ClientPayloads, ServerPayloads),
	_processIncoming: (
		self: Bridge,
		channel: "Reliable" | "Unreliable",
		sender: Player | NetServer,
		payload: Payload
	) -> (),

	step: (self: Bridge) -> (),
	snapshot: (self: Bridge) -> IncomingQueue,
	getContext: (self: Bridge) -> "server" | "client",
	isPlayer: (self: Bridge, player: any) -> boolean,

	_initializeRemotes: (self: Bridge) -> (),

	new: () -> Bridge,
}

export type Bridge = typeof(setmetatable({}, {} :: BridgeImpl))

-- Handles packaging and unpacking Packets to send and receive over Remotes
local Bridge: BridgeImpl = {} :: BridgeImpl
Bridge.__index = Bridge

Bridge.server = "NET_SERVER" :: NetServer

-- Packages a Packet to go into a Server Payload
function Bridge:_addPacketToPayload(
	payload: {
		Reliable: Payload,
		Unreliable: Payload,
	},
	packet: OutgoingPacket
)
	if not payload[packet.identifier] then
		payload[packet.identifier] = {}
	end

	local data = {}

	for _, value in packet.data do
		table.insert(data, value)
	end

	table.insert(payload[packet.identifier], data)

	return
end

-- Packages a Packet to go into a Client Payload
function Bridge:_updateClientPayload(
	clientPackages: {
		[Player]: {
			Reliable: Payload,
			Unreliable: Payload,
		},
	},
	player: Player,
	packet: OutgoingPacket
)
	if not clientPackages[player] then
		clientPackages[player] = {
			Reliable = {},
			Unreliable = {},
		}
	end

	self:_addPacketToPayload(clientPackages[player][packet.channel], packet)

	return
end

type ServerPayloads = {
	Reliable: Payload,
	Unreliable: Payload,
}

type ClientPayloads = {
	[Player]: {
		Reliable: Payload,
		Unreliable: Payload,
	},
}

-- Package all packets into payloads to be sent over the network
function Bridge:_processOutgoingQueue()
	local serverPayloads = {
		Reliable = {},
		Unreliable = {},
	} :: {
		Reliable: Payload,
		Unreliable: Payload,
	}
	local clientPayloads = {} :: {
		[Player]: {
			Reliable: Payload,
			Unreliable: Payload,
		},
	}
	local snapshot = self._outgoingQueue
	self._outgoingQueue = { Reliable = {}, Unreliable = {} }

	-- Add each packet to it's respective payload
	for channel, package in pairs(snapshot) do
		for _, packet in package do
			if self:isPlayer(packet.recipient) then
				self:_updateClientPayload(clientPayloads, packet.recipient, packet)
			elseif typeof(packet.recipient) == "table" then
				for _, player in packet.recipient do
					if not self:isPlayer(player) then
						continue
					end

					self:_updateClientPayload(clientPayloads, player, packet)
				end
			else
				self:_addPacketToPayload(serverPayloads[channel], packet)
			end
		end
	end

	return clientPayloads, serverPayloads
end

-- Send payloads over the network to their respective channel
function Bridge:_sendPayloads(clientPayloads: ClientPayloads, serverPayloads: ServerPayloads)
	if self:getContext() == "client" then
		for channel, remote in pairs({ Reliable = self.reliableRemote, Unreliable = self.unreliableRemote }) do
			local n = 0
			for _ in serverPayloads[channel] do
				n += 1
			end

			-- Do not send empty payloads
			if n == 0 then
				continue
			end

			remote:FireServer(serverPayloads[channel])
		end
	elseif self:getContext() == "server" then
		for player, payload in clientPayloads do
			for channel, remote in pairs({ Reliable = self.reliableRemote, Unreliable = self.unreliableRemote }) do
				local n = 0
				for _ in payload[channel] do
					n += 1
				end

				-- Do not send empty payloads
				if n == 0 then
					continue
				end

				remote:FireClient(player, payload[channel])
			end
		end
	end
end

-- Processes an incoming packet, adding it to the incoming queue.
function Bridge:_processIncoming(channel: "Reliable" | "Unreliable", sender: Player | "NET_SERVER", payload: Payload)
	-- Unpack each packet and add it to the queue
	for identifier, packets in payload do
		for _, data in packets do
			local pos = #self._incomingQueue[channel] + 1

			local packet = {
				identifier = identifier,
				sender = sender,
				data = data,
			}

			table.insert(self._incomingQueue[channel], pos, packet)
		end
	end
end

-- Updates the incoming queue and snapshot and calls ``Bridge:_processOutgoingQueue()``.
function Bridge:step()
	-- Update queue & Snapshot
	self._snapshot = self._incomingQueue
	self._incomingQueue = {
		Reliable = {},
		Unreliable = {},
	}

	-- Send outgoing
	local clientPayloads, serverPayloads = self:_processOutgoingQueue()
	self:_sendPayloads(clientPayloads, serverPayloads)
end

-- Returns a snapshot of the incoming queue.
function Bridge:snapshot()
	return table.clone(self._snapshot)
end

function Bridge:isPlayer(player: any)
	return typeof(player) == "Instance" and player:IsA("Player") or false
end

function Bridge:getContext()
	return RunService:IsServer() and "server" or RunService:IsClient() and "client"
end

function Bridge:_initializeRemotes()
	-- Fix for typescript
	if not script.Parent:FindFirstChild("Remotes") then
		local folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = script.Parent
	end

	if RunService:IsServer() then
		self.reliableRemote = script.Parent.Remotes:FindFirstChild("Reliable") or Instance.new("RemoteEvent")
		self.reliableRemote.Name = "Reliable"
		self.reliableRemote.Parent = script.Parent.Remotes

		self.unreliableRemote = script.Parent.Remotes:FindFirstChild("Unreliable")
			or Instance.new("UnreliableRemoteEvent")
		self.unreliableRemote.Name = "Unreliable"
		self.unreliableRemote.Parent = script.Parent.Remotes

		self.reliableRemote.OnServerEvent:Connect(function(player, package)
			self:_processIncoming("Reliable", player, package)
		end)
		self.unreliableRemote.OnServerEvent:Connect(function(player, package)
			self:_processIncoming("Unreliable", player, package)
		end)
	elseif RunService:IsClient() then
		self.reliableRemote = script.Parent.Remotes:WaitForChild("Reliable")
		self.unreliableRemote = script.Parent.Remotes:WaitForChild("Unreliable")

		self.reliableRemote.OnClientEvent:Connect(function(package)
			self:_processIncoming("Reliable", "NET_SERVER", package)
		end)
		self.unreliableRemote.OnClientEvent:Connect(function(package)
			self:_processIncoming("Unreliable", "NET_SERVER", package)
		end)
	end
end

-- Creates a new Bridge
function Bridge.new()
	local self = {}
	setmetatable(self, Bridge)

	self._incomingQueue = { Reliable = {}, Unreliable = {} } :: IncomingQueue
	self._snapshot = { Reliable = {}, Unreliable = {} } :: IncomingQueue

	self._outgoingQueue = { Reliable = {}, Unreliable = {} } :: OutgoingQueue

	self:_initializeRemotes()

	return self
end

return Bridge
