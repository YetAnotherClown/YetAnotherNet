local RunService = game:GetService("RunService")

--[=[
    @class Bridge
    @private

    Handles all incoming and outgoing packets from a RemoteEvent.

    The following API can be used by Advanced Users if they wish to not use the ``Net:start()`` method
    or to bypass the ``Bridge:step()`` method in favor of custom behavior.
]=]
local Bridge = {}
Bridge.__index = Bridge

-- A queue of Packets to send next frame
type OutgoingQueue = {
	{
		identifier: string,
		recipient: Player | "NET_SERVER",
		data: { any },
	}
}

-- A queue of Packets received on the current frame
type IncomingQueue = {
	{
		identifier: string,
		sender: Player | "NET_SERVER",
		data: { any },
	}
}

Bridge._incomingQueue = {} :: IncomingQueue
Bridge._snapshot = {} :: IncomingQueue

Bridge._outgoingQueue = {} :: OutgoingQueue

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
    predictable and data-driven networking. To make the queue unordered, set the ``Channel``
    to ``ReliableUnordered`` in the Configuration.

    As of v0.1.0, the ``ReliableUnordered`` Channel is not implemented.
]=]

-- Packages a Packet to go into a Server Payload
function Bridge:_addPacketToPayload(
	payload: {
		[string]: { { any } },
	},
	packet: {
		identifier: string,
		recipient: { Player } | Player | "NET_SERVER",
		data: { any },
	},
	pos
)
	if not payload[packet.identifier] then
		payload[packet.identifier] = {}
	end

	local data = {}

	-- Implement ReliableOrdered Channel for precise ordering
	if self._configuration and self._configuration.Channel == "ReliableOrdered" then
		-- Prevent unsigned overflow
		if pos < 0 or pos > 65535 then
			pos = 0
		end

		-- Store the queue position
		table.insert(data, string.pack("H", pos)) -- Limit: 65535
	end

	for _, value in packet.data do
		table.insert(data, value)
	end

	table.insert(payload[packet.identifier], data)
end

-- Packages a Packet to go into a Client Payload
function Bridge:_updateClientPayload(clientPackages, player, packet, pos)
	if not clientPackages[player] then
		clientPackages[player] = {}
	end

	self:_addPacketToPayload(clientPackages[player], packet, pos)
end

--[=[
    @method _processOutgoingQueue
    @within Bridge

    Sends all queued outgoing packets over the Remote.
]=]
function Bridge:_processOutgoingQueue()
	local serverPayload = {} :: {
		[string]: { { any } },
	}
	local clientPayloads = {} :: {
		[Player]: {
			[string]: { { any } },
		},
	}
	local snapshot = self._outgoingQueue
	self._outgoingQueue = {}

	-- Add each packet to it's respective payload
	for pos, packet in
		snapshot :: {
			{
				identifier: string,
				recipient: { Player } | Player | "NET_SERVER",
				data: { any },
			}
		}
	do
		if typeof(packet.recipient) == "table" then
			for _, player in packet.recipient do
				self:_updateClientPayload(clientPayloads, player, packet, pos)
			end
		elseif typeof(packet.recipient) == "Player" then
			self:_updateClientPayload(clientPayloads, packet.recipient, packet, pos)
		else
			self:_addPacketToPayload(serverPayload, packet, pos)
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
function Bridge:_processIncoming(
	sender,
	payload: {
		[string]: { { any } },
	}
)
	-- Unpack each packet and add it to the queue
	for identifier, packets in payload do
		for _, rawData in packets do
			local pos = #self._incomingQueue + 1
			local data = {}

			-- Implement ReliableOrdered Channel
			if self._configuration and self._configuration.Channel == "ReliableOrdered" then
				pos = string.unpack("H", rawData[1]) -- Limit: 65535

				for i = 2, #rawData do
					table.insert(data, rawData[i])
				end
			else
				data = rawData -- No extra arguments stored
			end

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

--[=[
    @method send
    @within Bridge

    Queue a packet to be sent in the outgoing queue
]=]
function Bridge:send(recipient, identifier, data)
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

	table.insert(self._outgoingQueue, {
		identifier = identifier,
		recipient = recipient,
		data = data,
	})
end

function Bridge.new(configuration: { any }?)
	local self = {}
	setmetatable(self, Bridge)

	self._configuration = configuration or {}

	local channel = self._configuration.Channel or "ReliableUnordered"
	local event = self._configuration.Event or "default"

	local remoteKey = channel .. "@" .. event

	if RunService:IsServer() then
		self.remote = script:FindFirstChild(remoteKey) or Instance.new("RemoteEvent")
		self.remote.Name = remoteKey
		self.remote.Parent = script

		self.remote.OnServerEvent:Connect(function(player, package)
			self:_processIncoming(player, package)
		end)
	elseif RunService:IsClient() then
		self.remote = script:WaitForChild(remoteKey)

		self.remote.OnClientEvent:Connect(function(package)
			self:_processIncoming("NET_SERVER", package)
		end)
	end

	return self
end

export type Bridge = typeof(Bridge.new())

return Bridge
