local RunService = game:GetService("RunService")

export type BridgeImpl = {
	remote: RemoteEvent,

	_configuration: { [string]: any },
	_outgoingQueue: OutgoingQueue,
	_incomingQueue: IncomingQueue,
	_snapshot: IncomingQueue,

	__index: BridgeImpl,

	_addPacketToPayload: (self: Bridge, { [string]: any }, Packet) -> (),
	_updateClientPayload: (
		self: Bridge,
		clientPackages: { [Player]: { [string]: any } },
		player: Player,
		packet: Packet
	) -> (),
	_processOutgoingQueue: (self: Bridge) -> (),
	_processIncoming: (self: Bridge, sender: Player | "NET_SERVER", payload: Payload) -> (),

	step: (self: Bridge) -> (),
	snapshot: (self: Bridge) -> IncomingQueue,
	send: (self: Bridge, recipient: Recipient, identifier: string, ...any) -> SendRequest?,

	new: ({ [string]: any }?) -> Bridge,
}

export type Bridge = typeof(setmetatable({}, {} :: BridgeImpl))

--[=[
	@class Bridge
	@private

	Handles all incoming and outgoing packets from a RemoteEvent.

	The following API can be used by Advanced Users if they wish to not use the ``Net:start()`` method
	or to bypass the ``Bridge:step()`` method in favor of custom behavior.
]=]
local Bridge: BridgeImpl = {} :: BridgeImpl
Bridge.__index = Bridge

type Recipient = { Player } | Player | "NET_SERVER"

type Packet = {
	identifier: string,
	recipient: Recipient,
	data: { any },
}

-- A queue of Packets to send next frame
type OutgoingQueue = { Packet }

-- A queue of Packets received on the current frame
type IncomingQueue = {
	{
		identifier: string,
		sender: Player | "NET_SERVER",
		data: { any },
	}
}

--[=[
	@interface orderedPayload
	@within Bridge
	@field [Identifier] { { QueuePosition, any... } }

	A Payload represents a singular table that will be sent over the RemoteEvent.
	It is structured in a way to minimize overhead when calling RemoteEvents.

	In order to guarantee the order of the queue, an additional value is packed
	into the packet data. In order to minimize overhead, the value is represented
	in a similar way as Identifiers.
]=]

--[=[
	@interface unorderedPayload
	@within Bridge
	@field [Identifier] { { any... } }

	@tag Future Feature

	A Payload represents a singular table that will be sent over the RemoteEvent.
	It is structured in a way to minimize overhead when calling RemoteEvents.

	By default, each queue will be ordered. This is a design choice in order to promote
	predictable and data-driven networking.
]=]

-- Packages a Packet to go into a Server Payload
function Bridge:_addPacketToPayload(payload: { [string]: any }, packet: Packet)
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
function Bridge:_updateClientPayload(clientPackages: { [Player]: { [string]: any } }, player: Player, packet: Packet)
	if not clientPackages[player] then
		clientPackages[player] = {}
	end

	self:_addPacketToPayload(clientPackages[player], packet)

	return
end

type Payload = {
	[string]: { { any } },
}

--[=[
	@method _processOutgoingQueue
	@within Bridge

	Sends all queued outgoing packets over the Remote.
]=]
function Bridge:_processOutgoingQueue()
	local serverPayload = {} :: Payload
	local clientPayloads = {} :: {
		[Player]: Payload,
	}
	local snapshot = self._outgoingQueue
	self._outgoingQueue = {}

	-- Add each packet to it's respective payload
	for _, packet in
		snapshot :: {
			{
				identifier: string,
				recipient: Recipient,
				data: { any },
			}
		}
	do
		if typeof(packet.recipient) == "table" then
			for _, player in packet.recipient do
				self:_updateClientPayload(clientPayloads, player, packet)
			end
		elseif typeof(packet.recipient) == "Instance" and packet.recipient:IsA("Player") then
			self:_updateClientPayload(clientPayloads, packet.recipient, packet)
		else
			self:_addPacketToPayload(serverPayload, packet)
		end
	end

	-- Send the Payload over the RemoteEvent
	if RunService:IsClient() then
		self.remote:FireServer(serverPayload)
	elseif RunService:IsServer() then
		for player, payload in clientPayloads do
			self.remote:FireClient(player, payload)
		end
	end
end

--[=[
	@method _processIncoming
	@within Bridge

	Processes an incoming packet, adding it to the incoming queue.

	@param sender Player | "NET_SERVER"
	@param payload Payload
]=]
function Bridge:_processIncoming(sender: Player | "NET_SERVER", payload: Payload)
	-- Unpack each packet and add it to the queue
	for identifier, packets in payload do
		for _, data in packets do
			local pos = #self._incomingQueue + 1

			local packet = {
				identifier = identifier,
				sender = sender,
				data = data,
			}

			table.insert(self._incomingQueue, pos, packet)
		end
	end
end

--[=[
	@method step
	@within Bridge

	Updates the incoming queue and snapshot and calls ``Bridge:_processOutgoingQueue()``.
]=]
function Bridge:step()
	-- Update queue & Snapshot
	self._snapshot = self._incomingQueue
	self._incomingQueue = {}

	-- Send outgoing
	self:_processOutgoingQueue()
end

--[=[
	@method snapshot
	@within Bridge

	Returns a snapshot of the incoming queue.
]=]
function Bridge:snapshot()
	return table.clone(self._snapshot)
end

export type SendRequestImpl = {
	_outgoingQueue: OutgoingQueue,
	_bridge: Bridge,
	_position: number,

	__index: SendRequestImpl,

	to: (self: SendRequest, recipient: Recipient) -> (),
}

export type SendRequest = typeof(setmetatable({}, {} :: SendRequestImpl))

--[=[
	@class SendRequest
	@since v0.4.0

	Allows for modification of queued packets before they're sent.
]=]
local SendRequest: SendRequestImpl = {} :: SendRequestImpl
SendRequest.__index = SendRequest

--[=[
	@method to
	@within SendRequest

	Modifies the recipients of the packet to the one(s) provided in the parameter.

	@param recipient { Player } | Player | "NET_SERVER"
]=]
function SendRequest:to(recipient: Recipient)
	if RunService:IsClient() then
		warn("You should not use the SendRequest:to() method on the Client")
		return
	end

	local position = self._position
	local bridge = self._bridge

	local packet = bridge._outgoingQueue[position]
	local newPacket = {
		identifier = packet.identifier,
		recipient = recipient,
		data = packet.data,
	}

	table.remove(bridge._outgoingQueue, position)
	table.insert(bridge._outgoingQueue, newPacket)

	return
end

function Bridge:send(recipient, identifier, data): SendRequest?
	-- Typecheck recipients
	if RunService:IsClient() then
		if recipient ~= "NET_SERVER" then
			warn("Clients can only send to Net.Server")

			return
		end
	elseif RunService:IsServer() then
		if typeof(recipient) == "table" then
			for _, player in recipient do
				if typeof(player) ~= "Instance" or (typeof(player) == "Instance" and not player:IsA("Player")) then
					warn("Attempt to send a table with a non-player instance as a recipient")

					return
				end
			end
		elseif typeof(recipient) ~= "Instance" or (typeof(recipient) == "Instance" and not recipient:IsA("Player")) then
			warn("Attempt to send a non-player instance as a recipient")

			return
		end
	end

	-- Typecheck identifier
	if typeof(identifier) ~= "string" then
		warn("Identifier must be a string")

		return
	end

	if typeof(recipient) == "string" and recipient ~= "NET_SERVER" then
		return
	end

	table.insert(self._outgoingQueue, {
		identifier = identifier,
		recipient = recipient,
		data = data,
	})

	local sendRequest = {
		_position = #self._outgoingQueue,
		_bridge = self,
	}
	setmetatable(sendRequest, SendRequest)

	return sendRequest :: SendRequest
end

function Bridge.new(configuration: any?)
	local self = {}
	setmetatable(self, Bridge)

	self._incomingQueue = {} :: IncomingQueue
	self._snapshot = {} :: IncomingQueue

	self._outgoingQueue = {} :: OutgoingQueue

	self._configuration = configuration or {
		Channel = "Reliable",
		Event = "default",
	}

	local channel = self._configuration.Channel
	local event = self._configuration.Event

	local remoteKey = channel .. "@" .. event

	if RunService:IsServer() then
		self.remote = script.Parent.Remotes:FindFirstChild(remoteKey) or Instance.new("RemoteEvent")
		self.remote.Name = remoteKey
		self.remote.Parent = script.Parent.Remotes

		local function processIncoming(player, package)
			self:_processIncoming(player, package)
		end

		self.remote.OnServerEvent:Connect(processIncoming)
	elseif RunService:IsClient() then
		self.remote = script.Parent.Remotes:WaitForChild(remoteKey)

		local function processIncoming(package)
			self:_processIncoming("NET_SERVER", package)
		end

		self.remote.OnClientEvent:Connect(processIncoming)
	end

	return self
end

return Bridge
