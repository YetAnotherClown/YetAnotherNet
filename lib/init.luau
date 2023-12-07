local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Bridge = require(script.Bridge)
type Bridge = Bridge.Bridge

type Recipient = Bridge.Recipient
type IncomingPacket = Bridge.IncomingPacket
type OutgoingPacket = Bridge.OutgoingPacket

type IncomingQueue = Bridge.IncomingQueue
type OutgoingQueue = Bridge.OutgoingQueue

type NetServer = Bridge.NetServer

local Identifier = require(script.Identifier)
export type Identifier = Identifier.Identifier

--[=[
	@interface Configuration
	@within Net
	@field Channel "Reliable" | "Unreliable" -- Default: Reliable
	@field Event string -- The event to schedule the Route on in your Matter Loop -- Default: "default"
	@field Ratelimit number -- Amount of allowed invocations a frame
	@field Middleware (event: "send" | "receive", ...any?) -> ...any? -- Runs before your packets are sent or received

	:::note
	As of v0.5.0, Ratelimiting is not implemented. This feature will come in future versions.
	:::

	### Channel

	**Reliable**: All packets will be sent and received per frame in order.
	**Unreliable**: Packets may be dropped but will be received in order.
]=]
export type Configuration = {
	Channel: ("Reliable" | "Unreliable")?,
	Event: string?,
	Ratelimit: number?,
	Middleware: ((event: "send" | "receive", ...any?) -> ...any?)?,
}

--[=[
	@class SendRequest
	@since v0.4.0

	Allows for modification of queued packets before they're sent.
]=]
type SendRequestImpl = {
	_outgoingQueue: { OutgoingPacket },
	_position: number,

	__index: SendRequestImpl,

	to: (self: SendRequest, recipient: Recipient) -> (),
}

export type SendRequest = typeof(setmetatable({}, {} :: SendRequestImpl))

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

	local packet = self._outgoingQueue[position]
	local newPacket = {
		channel = packet.channel,
		identifier = packet.identifier,
		recipient = recipient,
		data = packet.data,
	}

	self._outgoingQueue[position] = newPacket

	return
end

--[=[
	@class QueryResult
	@since v0.4.0

	An iterable object returned as the result of [Net:query] that can filter snapshots
	by Identifier and Senders.

	:::note
	Due to certain limitations with the Luau Type System, iterating over the QueryResult Object
	will not return typed values. In order to fix this, call ``:__iter()`` on the QueryResult Object.

	For example:
	```lua
	for i, sender, ... in net:query():__iter() do
		-- Do something
	end
	```
	:::

	See [Querying Data](https://yetanotherclown.github.io/Net/docs/intro#querying-data) for more information.
]=]
type QueryResultImpl<U...> = {
	_snapshot: { IncomingPacket },
	_identifier: Identifier,
	_senders: { Player | NetServer },

	__index: QueryResultImpl<U...>,
	__iter: (self: QueryResult<U...>) -> () -> (number?, (Player | NetServer)?, U...),

	from: (self: QueryResult<U...>, ...(Player | NetServer)) -> QueryResult<U...>,

	new: (snapshot: { IncomingPacket }, identifier: Identifier, senders: { Recipient }?) -> QueryResult<U...>,
}

export type QueryResult<U...> = typeof(setmetatable({}, {} :: QueryResultImpl<U...>))

local QueryResult: QueryResultImpl<...any> = {} :: QueryResultImpl<...any>
QueryResult.__index = QueryResult

--[=[
	@method __iter
	@within QueryResult
	
	Iterating over a QueryResult will return the Packets in the QueryResult's Snapshot that
	match the supplied Senders from [QueryResult:from].

	Usage:
	```lua
	for pos, sender, ... in net:query():from(...senders) do
		-- Do something
	end
	```

	@return number
	@return Player | string
	@return ...any
]=]
function QueryResult:__iter()
	local senders = self._senders
	local identifier = self._identifier

	local snapshot = self._snapshot
	local i = 1

	return function()
		local packet = snapshot[i]
		if not packet then
			return
		end

		-- Return all packets if no Senders are supplied, or filter by Senders
		local filterSenders = #senders > 0
		local isSenderAllowed = not filterSenders and table.find(senders, packet.sender) or true

		-- Don't return packet if filtered
		if packet.identifier ~= identifier or not isSenderAllowed then
			return
		end

		-- Tick for next packet
		i += 1

		return i, packet.sender, unpack(packet.data)
	end
end

--[=[
	@method from
	@within QueryResult
	
	Filters Packets from the QueryResult's Snapshot based on the provided Senders.

	@param senders ...sender -- The Senders to filter
	@return QueryResult
]=]
function QueryResult:from(...)
	local senders = {} :: { { Player } | Player | "NET_SERVER" }

	local params = { ... }
	for _, param in params do
		if typeof(param) == "table" then
			for _, player in param do
				table.insert(senders, player)
			end

			continue
		end

		table.insert(senders, param)
	end
	return self.new(self._snapshot, self._identifier, senders)
end

--[=[
	@function new
	@within QueryResult
	@private

	Creates a new QueryResult with the supplied Snapshot.

	@return QueryResult
]=]
function QueryResult.new(snapshot, identifier, senders)
	return setmetatable({
		_snapshot = snapshot,
		_identifier = identifier,
		_senders = senders or {},
	}, QueryResult)
end

--[=[
	@class Net

	A Networking Library, inspired by BridgeNet2 & Bevy_Renet, made for ECS.

	See the [Intro](https://yetanotherclown.github.io/Net/docs/intro) to get started.
]=]
type NetImpl<U...> = {
	Server: NetServer,
	_identifier: Identifier,
	_configuration: Configuration,
	_outgoingQueue: { OutgoingPacket },
	_snapshot: IncomingQueue,
	_middleware: ((event: "send" | "receive", U...) -> ...any?)?,

	__index: NetImpl<U...>,
	__iter: (self: Net<U...>) -> QueryResult<U...>,

	_queuePackets: (Net<U...>, Bridge) -> (),
	_updateSnapshot: (Net<U...>, Bridge) -> (),
	addMiddleware: (self: Net<U...>, middleware: (event: "send" | "receive", ...any?) -> ...any?) -> (),
	send: (self: Net<U...>, U...) -> SendRequest,
	query: (self: Net<U...>) -> QueryResult<U...>,

	start: (loop: any, { Net<U...> }) -> (),
	createHook: ({ Net<U...> }) -> () -> (),

	new: (Configuration) -> Net<U...>,
}

export type Net<U...> = typeof(setmetatable(
	{} :: {
		_middleware: ((event: "send" | "receive", U...) -> ...any?)?,
		_configuration: Configuration,
		_outgoingQueue: { OutgoingPacket },
		_snapshot: IncomingQueue,
	},
	{} :: NetImpl<U...>
))

local Net: NetImpl<...any> = {} :: NetImpl<...any>
Net.__index = Net

Net.Server = "NET_SERVER"

--[=[
	@method __iter
	@within Net
	@private
	
	Creates a QueryResult that returns all Packets in the current frame's snapshot
	from the Route's identifier.
	
	See [Net:query] to filter by Senders.

	@return QueryResult
]=]
function Net:__iter()
	return QueryResult.new(self._snapshot, self._identifier)
end

--[=[
	@method query
	@within Net
	
	Allows for iteration of all packets of the previous frame.
	You can filter by Senders by chaining the ``QueryResult:from()`` method onto the query method.

	:::note
	Due to certain limitations with the Luau Type System, iterating over the QueryResult Object
	will not return typed values. In order to fix this, call ``:__iter()`` on the QueryResult Object.

	For example:
	```lua
	for i, sender, ... in net:query():__iter() do
		-- Do something
	end
	```
	:::

	See [Querying Data](https://yetanotherclown.github.io/Net/docs/intro#querying-data) for more information.

	@return QueryResult
]=]
function Net:query()
	return self:__iter()
end

--[=[
	@method send
	@within Net
	
	Sends data to all clients or to specific recipients from the Route's identifier.

	By default, [Net:send] will send the data to all Clients. You can specify which
	Clients to receive the data by chaining [SendRequest:to] and passing
	``{ Player }``, ``Player``, or ``Net.Server``.

	See [Sending Data](https://yetanotherclown.github.io/Net/docs/intro#sending-data) for more information.
]=]
function Net:send(...)
	local packet = {
		channel = self._configuration.Channel,
		data = { ... },
		identifier = self._identifier,
		recipient = RunService:IsClient() and Net.Server or Players:GetPlayers(),
	} :: OutgoingPacket
	table.insert(self._outgoingQueue, packet)

	local sendRequest = {
		_outgoingQueue = self._outgoingQueue,
		_position = #self._outgoingQueue,
	}
	setmetatable(sendRequest, SendRequest)

	return sendRequest
end

--[=[
	@method _queuePackets
	@within Net
	@private
	
	Processes the Route's internal queue and sends it to the supplied Bridge.
	Doing this will reset the internal queue.
]=]
function Net:_queuePackets(bridge: Bridge)
	local channel = self._configuration.Channel or "Reliable"

	local queue = self._outgoingQueue :: { OutgoingPacket }
	self._outgoingQueue = {}

	for _, packet in queue do
		-- Implement middleware
		if self._middleware and packet.identifier == self._identifier then
			local newData = { self._middleware("send", table.unpack(packet.data)) }
			if #newData > 0 then
				packet.data = newData
			else
				continue
			end
		end

		-- Typecheck recipients
		if RunService:IsClient() then
			if packet.recipient ~= "NET_SERVER" then
				warn("Clients can only send to Net.Server")
				continue
			end
		elseif RunService:IsServer() then
			if typeof(packet.recipient) == "table" then
				for _, player in packet.recipient do
					if typeof(player) ~= "Instance" or (typeof(player) == "Instance" and not player:IsA("Player")) then
						warn("Attempt to send a table with a non-player instance as a recipient")
						continue
					end
				end
			elseif
				typeof(packet.recipient) ~= "Instance"
				or (typeof(packet.recipient) == "Instance" and not packet.recipient:IsA("Player"))
			then
				warn("Attempt to send a non-player instance as a recipient")
				continue
			end
		end

		-- Typecheck identifier
		if typeof(packet.identifier) ~= "string" then
			warn("Invalid Identifier")

			continue
		end

		if typeof(packet.recipient) == "string" and packet.recipient ~= "NET_SERVER" then
			continue
		end

		table.insert(bridge._outgoingQueue[channel], packet)
	end
end

function Net:_updateSnapshot(bridge)
	local snapshot = bridge:snapshot()[self._configuration.Channel or "Reliable"]
	for _, packet in snapshot :: { IncomingPacket } do
		if not self._middleware or packet.identifier ~= self._identifier then
			continue
		end

		-- Implement middleware
		local newData = { self._middleware("receive", table.unpack(packet.data)) }
		if #newData > 0 then
			packet.data = newData
		end
	end

	self._snapshot = snapshot
end

--[=[
	@class Loop

	A [Matter Loop](https://eryn.io/matter/api/Loop).

	For technical details, if you were to use a custom Loop object or try to integrate this Net Library in a ECS other than Matter,
	the ``Net.start(loop, { Net })`` function uses a similar implementation to ``Net.createHook({ Net })`` internally.

	For more information on this, see [Net.createHook].
]=]

--[=[
	@function start
	@within Net
	
	Initializes your Routes by adding middleware to your Matter Loop.
	This ensures that your Routes run between each frame.

	:::note
	Please make sure that the event you set in the Configuration, or the default, is the same index you used for your
	``RunService.Heartbeat`` event in your ``Loop:begin()`` method.

	Your Routes are meant to run on the heartbeat, like most systems. In some cases you may want to run your Routes on different events,
	in this case it is acceptable to change it to a different event.
	:::

	@param loop Loop -- A Matter Loop
	@param routes { Net } -- A table of your Routes
]=]
function Net.start(loop, netObjects)
	local events = {}
	for _, netObject in netObjects do
		local event = netObject._configuration.Event or "default"

		local exists = events[event]
		if not exists then
			events[event] = {}
		end

		table.insert(events[event], netObject)
	end

	local bridges = {}
	for event, _ in events do
		bridges[event] = Bridge.new()
	end

	-- Performs queue tasks after each frame finishes
	loop:addMiddleware(function(nextFn, eventName)
		local function networkingMiddleware()
			local bridge = bridges[eventName]
			if not bridge then
				nextFn()
				return
			end

			for _, netObject in events[eventName] do
				netObject:_updateSnapshot(bridge)
				netObject:_queuePackets(bridge)
			end

			-- Middleware runs before/after each frame,
			bridge:step()

			nextFn()
		end

		return networkingMiddleware
	end)

	return
end

--[=[
	@function createHook
	@within Net
	
	This function allows you to run Net scheduling code on your own events.

	When you provide a table of Routes, this function will return another function
	you can call which will step each Route and process it's Packet Queue.

	For example, to run scheduling on the Heartbeat:
	```lua
	local hook = Net.createHook({ Net })
	RunService.Heartbeat:Connect(hook)
	```

	@param routes { Net } -- A table of your Routes
	@return () -> ()
]=]
function Net.createHook(netObjects)
	local bridge = Bridge.new()

	return function()
		for _, netObject in netObjects do
			netObject:_updateSnapshot(bridge)
			netObject:_queuePackets(bridge)
		end

		bridge:step()
	end
end

--[=[
	@function new
	@within Net
	
	Creates a new Route with a unique identifier, channel, and event.

	:::note
	All Routes with the same Channel will share a single Remote. It's recommended that you run all your
	Net scheduling code on a single event.
	:::

	@param configuration Configuration?
]=]
function Net.new(configuration: Configuration)
	local self = {}
	setmetatable(self, Net)

	self._configuration = configuration or { Channel = "Reliable" } :: Configuration
	self._identifier = Identifier(tostring(self))
	self._middleware = configuration.Middleware
	self._outgoingQueue = {}
	self._snapshot = {
		Reliable = {},
		Unreliable = {},
	}

	return self
end

return Net
