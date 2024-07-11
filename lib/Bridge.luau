--!native
local RunService = game:GetService("RunService")

local serdes = require("@serdes")
local instance = serdes.Instance
local dictionary = serdes.dictionary

local Identifier = require("@yetanothernet/Identifier")
export type Identifier = Identifier.Identifier

export type Channel = "Reliable" | "Unreliable"
export type NetServer = "NET_SERVER"

export type IncomingPacket = {
	identifier: Identifier,
	sender: Player | NetServer,
	data: { any },
}

export type IncomingQueue = {
	Reliable: { IncomingPacket },
	Unreliable: { IncomingPacket },
}

export type Recipient = { Player } | Player | NetServer

export type OutgoingPacket = {
	channel: Channel,
	identifier: Identifier,
	recipient: Recipient,
	data: { any },
}

export type OutgoingQueue = {
	Reliable: { OutgoingPacket },
	Unreliable: { OutgoingPacket },
}

type Payload = {
	[Identifier]: { { any } },
}

type ServerPayload = {
	Reliable: Payload,
	Unreliable: Payload,
}

type ClientPayloads = {
	[Player]: {
		Reliable: Payload,
		Unreliable: Payload,
	},
}

export type BridgeImpl = {
	__index: BridgeImpl,

	server: NetServer,
	reliableChannel: RemoteEvent,
	unreliableChannel: UnreliableRemoteEvent,

	_incomingQueue: IncomingQueue,
	_instanceMap: { [number]: Instance },
	_outgoingQueue: OutgoingQueue,
	_snapshot: IncomingQueue,

	step: (self: Bridge) -> (),
	snapshot: (self: Bridge) -> IncomingQueue,

	_getInstanceMapChanges: (self: Bridge) -> { [number]: Instance }?,
	_processIncoming: (
		self: Bridge,
		channel: Channel,
		sender: Player | NetServer,
		package: Payload | buffer,
		instanceMapChanges: {
			[number]: Instance,
		}?
	) -> (),
	_processOutgoingQueue: (self: Bridge) -> (ClientPayloads, ServerPayload),
	_sendPayloads: (
		self: Bridge,
		clientPayloads: ClientPayloads,
		serverPayloads: ServerPayload
	) -> (),

	_initialize: (self: Bridge) -> (),

	_getContext: (self: Bridge) -> "client" | "server",
	_getRemotes: (self: Bridge) -> (RemoteEvent, UnreliableRemoteEvent),
	_isPlayer: (self: Bridge, player: any) -> boolean,

	new: () -> Bridge,
}

export type Bridge = typeof(setmetatable({}, {} :: BridgeImpl))

--[=[
	@class Bridge

	Bridges are the Transport and SerDes Layer of YetAnotherNet, responsible for
	serializing and deserializing data as well as sending it over the network.

	The Bridge class should only be used internally within the Library, when
	creating behavior identical to hooks, or when performing Unit/Integration Tests.

	The Bridge is structured in a way to enable simple mocking using Jest-Lua.
]=]
local Bridge: BridgeImpl = {} :: BridgeImpl
Bridge.__index = Bridge
Bridge.server = "NET_SERVER"

function Bridge:_getInstanceMapChanges()
	local changes = {}
	local currentMap = instance.getInstanceMap()

	for identifier, _instance in currentMap do
		if self._instanceMap[identifier] ~= _instance then
			changes[identifier] = _instance
			continue
		end
	end

	self._instanceMap = currentMap

	return next(changes) ~= nil and changes or nil
end

--[=[
	@method _sendPayloads
	@within Bridge
	
	Before sending the Payloads over the network, this method will
	attempt to serialize the Payloads into buffers. If the payload
	fails to serialize, it will send the unserialized payload
	instead.
]=]
function Bridge:_sendPayloads(clientPayloads, serverPayload)
	if self:_getContext() == "client" then
		for channel, remote in pairs({
			Reliable = self.reliableChannel,
			Unreliable = self.unreliableChannel,
		}) do
			local n = 0
			for _ in serverPayload[channel] do
				n += 1
			end

			-- Do not send empty payloads
			if n == 0 then
				continue
			end

			local _buffer = dictionary.serialize(serverPayload[channel])
			local instanceMapChanges = self:_getInstanceMapChanges()

			local package: buffer? | { [number]: any } = _buffer
			if not package then
				local newPackage = {}

				-- Buffers as indices get converted to strings
				for identifier, packets in serverPayload[channel] do
					newPackage[Identifier.read(identifier)] = packets
				end

				package = newPackage
			end

			remote:FireServer(_buffer or serverPayload[channel], instanceMapChanges)
		end
	elseif self:_getContext() == "server" then
		for player, payload in clientPayloads do
			for channel, remote in pairs({
				Reliable = self.reliableChannel,
				Unreliable = self.unreliableChannel,
			}) do
				local n = 0
				for _ in payload[channel] do
					n += 1
				end

				-- Do not send empty payloads
				if n == 0 then
					continue
				end

				local _buffer = dictionary.serialize(payload[channel])
				local instanceMapChanges = self:_getInstanceMapChanges()

				local package: buffer? | { [number]: any } = _buffer
				if not package then
					local newPackage = {}

					-- Buffers as indices get converted to strings
					for identifier, packets in payload[channel] do
						newPackage[Identifier.read(identifier)] = packets
					end

					package = newPackage
				end

				remote:FireClient(player, _buffer or payload[channel], instanceMapChanges)
			end
		end
	end
end

local function addPacketToPayload(payload: ServerPayload, packet: OutgoingPacket)
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

local function updateClientPayload(
	clientPayloads: ClientPayloads,
	player: Player,
	packet: OutgoingPacket
)
	if not clientPayloads[player] then
		clientPayloads[player] = {
			Reliable = {},
			Unreliable = {},
		}
	end

	addPacketToPayload(clientPayloads[player][packet.channel], packet)

	return
end

--[=[
	@method _processOutgoingQueue
	@within Bridge
	
	This method will process the OutgoingQueue and pack it into Payloads for
	use in Bride:_sendPayloads()

	@return ClientPayloads, ServerPayload
]=]
function Bridge:_processOutgoingQueue()
	local serverPayload = {
		Reliable = {},
		Unreliable = {},
	} :: ServerPayload
	local clientPayloads = {} :: ClientPayloads

	local snapshot = self._outgoingQueue
	self._outgoingQueue = { Reliable = {}, Unreliable = {} }

	-- Add each packet to it's respective payload
	for channel, package in pairs(snapshot) do
		for _, packet in package do
			if self:_isPlayer(packet.recipient) then
				updateClientPayload(clientPayloads, packet.recipient, packet)
			elseif typeof(packet.recipient) == "table" then
				for _, player in packet.recipient do
					if not self:_isPlayer(player) then
						continue
					end

					updateClientPayload(clientPayloads, player, packet)
				end
			else
				addPacketToPayload(serverPayload[channel], packet)
			end
		end
	end

	return clientPayloads, serverPayload
end

--[=[
	@method snapshot
	@within Bridge
	
	Returns a copy of the snapshot.
	The snapshot is a snapshot of the last frame's IncomingQueue.
]=]
function Bridge:snapshot()
	return self._snapshot
end

--[=[
	@method step
	@within Bridge
	
	This will empty the IncomingQueue and produce a new Snapshot of it, then
	it will process the OutgoingQueue and send the payloads over the network.

	You should only use this function if creating custom scheduling behavior
	similar to the Hooks API, which you should use instead of trying to achieve
	this behavior using the Bridge itself.
]=]
function Bridge:step()
	self._snapshot = table.freeze(self._incomingQueue)
	self._incomingQueue = {
		Reliable = {},
		Unreliable = {},
	}

	local clientPayloads, serverPayloads = self:_processOutgoingQueue()
	self:_sendPayloads(clientPayloads, serverPayloads)
end

--[=[
	@method _processIncoming
	@within Bridge
	@private
	
	This method will process any packages sent over either channel of the Bridge.
	It will attempt to deserialize the package and add it to our IncomingQueue.
]=]
function Bridge:_processIncoming(channel, sender, package, instanceMapChanges)
	if instanceMapChanges then
		for identifier, _instance in instanceMapChanges do
			instance.setIdentifier(identifier, _instance)
			self._instanceMap = instance.getInstanceMap()
		end
	end

	-- Todo: Stricter typechecking for Payload
	local payload: Payload? = typeof(package) == "table" and package or nil
	if not payload and typeof(package) == "buffer" then
		payload = dictionary.deserialize(package)
		if not payload then
			warn("Error when attempting to deserialize package")
			return
		end
	elseif not payload then
		warn("Invalid package sent over network.")
		return
	end

	-- Unpack each packet and add it to the queue
	for identifier, packets in payload :: { [any]: any } do
		if type(identifier) == "string" then
			identifier = Identifier.new(tonumber(identifier))
		end

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

--[=[
	@method _initialize
	@within Bridge
	@private
	
	Assigns starting values, creates connections for channels, and other initialization work.

	This is intentionally abstracted out of Bridge.new() so we can overwrite Bridge.new()
	during mocking without having to rewrite the contents of this function.
]=]
function Bridge:_initialize()
	self._incomingQueue = { Reliable = {}, Unreliable = {} } :: IncomingQueue
	self._outgoingQueue = { Reliable = {}, Unreliable = {} } :: OutgoingQueue
	self._snapshot = table.freeze({ Reliable = {}, Unreliable = {} }) :: IncomingQueue
	self._instanceMap = instance.getInstanceMap()

	local reliable, unreliable = self:_getRemotes()
	self.reliableChannel = reliable
	self.unreliableChannel = unreliable

	if self:_getContext() == "server" then
		reliable.OnServerEvent:Connect(function(player, package, instanceMapChanges)
			self:_processIncoming("Reliable", player, package, instanceMapChanges)
		end)

		unreliable.OnServerEvent:Connect(function(player, package, instanceMapChanges)
			self:_processIncoming("Unreliable", player, package, instanceMapChanges)
		end)
	elseif self:_getContext() == "client" then
		reliable.OnClientEvent:Connect(function(package, instanceMapChanges)
			self:_processIncoming("Reliable", "NET_SERVER", package, instanceMapChanges)
		end)

		unreliable.OnClientEvent:Connect(function(package, instanceMapChanges)
			self:_processIncoming("Unreliable", "NET_SERVER", package, instanceMapChanges)
		end)
	end
end

--[=[
	@method _getContext
	@within Bridge
	@private
	
	This is a wrapper around RunService:IsServer() and RunService:IsClient()
	to enable us to mock the Click/Server Boundary during Unit Testing.

	@return "client" | "server"
]=]
function Bridge:_getContext()
	return RunService:IsServer() and "server" or RunService:IsClient() and "client"
end

--[=[
	@method _getRemotes
	@within Bridge
	@private
	
	When mocking, we use Mock RemoteEvents instead of actual RemoteEvents,
	this function allows us to replace the Remotes with these Mock RemoteEvents
	without having to rewrite any functionality of the library during mocking.

	@return RemoteEvent, UnreliableRemoveEvent
]=]
function Bridge:_getRemotes()
	-- Fix for typescript
	if not script.Parent:FindFirstChild("Remotes") then
		local folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = script.Parent
	end

	local remotes = script.Parent.Remotes

	local reliableRemote, unreliableRemote =
		remotes:FindFirstChild("Reliable"), remotes:FindFirstChild("Unreliable")
	if reliableRemote and unreliableRemote then
		return reliableRemote, unreliableRemote
	end

	if self:_getContext() == "server" then
		reliableRemote = Instance.new("RemoteEvent")
		reliableRemote.Name = "Reliable"
		reliableRemote.Parent = remotes

		unreliableRemote = Instance.new("RemoteEvent")
		unreliableRemote.Name = "Unreliable"
		unreliableRemote.Parent = remotes

		return reliableRemote, unreliableRemote
	else
		return remotes:WaitForChild("Reliable"), remotes:WaitForChild("Unreliable")
	end
end

--[=[
	@method _isPlayer
	@within Bridge
	@private
	
	Since we mock the Client/Server Boundary in Unit Tests, we also fake the
	Players in our games with Mock Players. This function allows us to
	switch out the typechecking for Players with typechecking for Mock Players.

	@return boolean
]=]
function Bridge:_isPlayer(player: any)
	return typeof(player) == "Instance" and player:IsA("Player") or false
end

--[=[
	@function new
	@within Bridge
	
	This creates a new Bridge and performs initialization work.

	You should not create or use Bridges in your code unless creating
	custom scheduling behavior similar to hooks. If you can use the
	native Hooks API, it is recommended you do instead of using the Bridge
	directly.

	Creating a new Bridge does not create new Remotes, all Remotes are shared
	by all Bridges. During Mocking, we can change this behavior by overwriting
	the Bridge:_getRemotes() method.

	@return boolean
]=]
function Bridge.new()
	local self = setmetatable({}, Bridge) :: Bridge
	self:_initialize()

	return self
end

return Bridge
