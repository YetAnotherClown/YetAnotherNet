local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Bridge = require("@yetanothernet/Bridge")
type Bridge = Bridge.Bridge

type Recipient = Bridge.Recipient
type IncomingPacket = Bridge.IncomingPacket
type OutgoingPacket = Bridge.OutgoingPacket

type IncomingQueue = Bridge.IncomingQueue
type OutgoingQueue = Bridge.OutgoingQueue

type NetServer = Bridge.NetServer

local Identifier = require("@yetanothernet/Identifier")
export type Identifier = Identifier.Identifier

local read = Identifier.read

local QueryResult = require("@yetanothernet/QueryResult")
export type QueryResult<U...> = QueryResult.QueryResult<U...>

local SendRequest = require("@yetanothernet/SendRequest")
export type SendRequest = SendRequest.SendRequest

local isClient = RunService:IsClient()

--[=[
	@interface Configuration
	@within Route
	@field Channel ("Reliable" | "Unreliable")? -- Default: Reliable
	@field Event string? -- The event to schedule the Route on in your Matter Loop -- Default: "default"
	@field Ratelimit number? -- Amount of allowed invocations a frame

	:::note
	Ratelimiting is not implemented yet. This feature will come in future versions.
	:::

	### Channel

	**Reliable**: All packets will be sent and received per frame in order.
	**Unreliable**: Packets may be dropped but will be received in order.
]=]
export type Configuration = {
	Channel: ("Reliable" | "Unreliable")?,
	Event: string?,
	Ratelimit: number?,
}

--[=[
	@class Route

	A Networking Library, inspired by BridgeNet2 & Bevy_Renet, made for ECS.

	See the [Intro](/docs/intro) to get started.
]=]
type RouteImpl<U...> = {
	server: NetServer,
	_identifier: Identifier,
	_configuration: Configuration,
	_outgoingQueue: { OutgoingPacket },
	_currentPlayers: { Player },
	_snapshot: IncomingQueue,
	_middleware: {
		Incoming: ((...any) -> ...any)?,
		Outgoing: ((...any) -> ...any)?,
	},

	__index: RouteImpl<U...>,
	__iter: (self: Route<U...>) -> QueryResult<U...>,

	_queuePackets: (Route<U...>, Bridge) -> (),
	_updateSnapshot: (Route<U...>, Bridge) -> (),
	addIncomingMiddleware: (self: Route<U...>, middleware: (...any) -> ...any) -> (),
	addOutgoingMiddleware: (self: Route<U...>, middleware: (...any) -> ...any) -> (),
	send: (self: Route<U...>, U...) -> SendRequest,
	query: (self: Route<U...>) -> QueryResult<U...>,

	start: (loop: any, { Route<U...> }) -> (),
	createHook: ({ Route<U...> }) -> () -> (),

	new: (Configuration) -> Route<U...>,
}

export type Route<U...> = typeof(setmetatable(
	{} :: {
		_configuration: Configuration,
		_outgoingQueue: { OutgoingPacket },
		_snapshot: IncomingQueue,
		_currentPlayers: { Player },
	},
	{} :: RouteImpl<U...>
))

local Route: RouteImpl<...any> = {} :: RouteImpl<...any>
Route.__index = Route

Route.server = Bridge.server

--[=[
	@method __iter
	@within Route
	@private
	
	Creates a QueryResult that returns all Packets in the current frame's snapshot
	from the Route's identifier.
	
	See [Route:query] to filter by Senders.

	@return QueryResult
]=]
function Route:__iter()
	return QueryResult.new(self._snapshot, self._identifier)
end

--[=[
	@method query
	@within Route
	
	Allows for iteration of all packets of the previous frame.
	You can filter by Senders by chaining the ``QueryResult:from()`` method onto the query method.

	:::note
	Due to certain limitations with the Luau Type System, iterating over the QueryResult Object
	will not return typed values. In order to fix this, call ``:__iter()`` on the QueryResult Object.

	For example:
	```lua
	for i, sender, ... in route:query():__iter() do
		-- Do something
	end
	```
	:::

	See [Querying Data](/docs/getting-started/routes#querying) for more information.

	@return QueryResult
]=]
function Route:query()
	return self:__iter()
end

--[=[
	@method send
	@within Route
	
	Sends data to all clients or to specific recipients from the Route's identifier.

	By default, [Route:send] will send the data to all Clients. You can specify which
	Clients to receive the data by chaining [SendRequest:to] and passing
	``{ Player }``, ``Player``, or ``Route.Server``.

	See [Sending Data](/docs/getting-started/routes#sending) for more information.

	@param ... U...
	@return SendRequest
]=]
function Route:send(...)
	local packet = {} :: OutgoingPacket
	packet.data = { ... }
	packet.recipient = isClient and Bridge.server or self._currentPlayers
	-- Identifier and Channel are assigned when queuing to the Bridge

	table.insert(self._outgoingQueue, packet)

	local sendRequest = {}
	SendRequest._outgoingQueue = self._outgoingQueue
	SendRequest._position = #self._outgoingQueue
	setmetatable(sendRequest, SendRequest)

	return sendRequest
end

--[=[
	@method _queuePackets
	@within Route
	@private
	
	Processes the Route's internal queue and sends it to the supplied Bridge.
	Doing this will reset the internal queue.
]=]
function Route:_queuePackets(bridge: Bridge)
	local channel = self._configuration.Channel or "Reliable"

	local queue = self._outgoingQueue :: { OutgoingPacket }
	self._outgoingQueue = {}

	for _, packet in queue do
		-- Implement middleware
		if self._middleware.Outgoing then
			local newData = { self._middleware.Outgoing(table.unpack(packet.data)) }
			if #newData > 0 then
				packet.data = newData
			else
				continue
			end
		end

		packet.identifier = self._identifier
		packet.channel = channel :: "Reliable" | "Unreliable"

		-- Typecheck recipients
		if bridge:_getContext() == "client" then
			if packet.recipient ~= Bridge.server then
				warn("Clients can only send to YetAnotherNet.Server")
				continue
			end
		elseif bridge:_getContext() == "server" then
			if not bridge:_isPlayer(packet.recipient) then
				if typeof(packet.recipient) == "table" then
					for _, player in packet.recipient do
						if not bridge:_isPlayer(player) then
							warn(
								"Attempt to send a table with a non-player instance as a recipient"
							)
							continue
						end
					end
				else
					warn("Attempt to send a non-player instance as a recipient")
					continue
				end
			end
		end

		-- Typecheck identifier
		if typeof(packet.identifier) ~= "buffer" then
			warn("Invalid Identifier")

			continue
		end

		if typeof(packet.recipient) == "string" and packet.recipient ~= Bridge.server then
			warn("Invalid Recipient: must be a player instance or Route.server")
			continue
		end

		table.insert(bridge._outgoingQueue[channel], packet)
	end
end

function Route:_updateSnapshot(bridge)
	local snapshot = bridge:snapshot()[self._configuration.Channel]

	for _, packet in snapshot :: { IncomingPacket } do
		if not self._middleware.Incoming or read(packet.identifier) ~= read(self._identifier) then
			continue
		end

		-- Implement middleware
		local middleware = self._middleware.Incoming :: (...any?) -> ...any
		local newData = { middleware(table.unpack(packet.data)) }
		if #newData > 0 then
			packet.data = newData
		end
	end

	self._snapshot = snapshot
	self._currentPlayers = Players:GetPlayers()
end

--[=[
	@method addIncomingMiddleware
	@within Route
	
	Sets a function to be ran on Incoming packets before they are processed.
	For example, this would run after the Client receives a Packet from the Server over the network:
	after calling ``Route:send()`` on the Server and before calling ``Route:query()`` on the Client.

	See [Middleware](/docs/getting-started/middleware) for more information.

	@param (...any) -> (...any?)
	@return ()
]=]
function Route:addIncomingMiddleware(middleware)
	if not middleware or typeof(middleware) ~= "function" then
		error("Middleware should be a function.", 2)
	end

	self._middleware.Incoming = middleware
end

--[=[
	@method addOutgoingMiddleware
	@within Route
	
	Sets a function to be ran on Outgoing packets before they are sent over the network.
	For example, this would run before the Server sends a Packet to the Client over the network:
	after calling ``Route:send()`` on the Server and before the Client ever receives the Packet.

	See [Middleware](/docs/getting-started/middleware) for more information.

	@param (...any) -> (...any?)
	@return ()
]=]
function Route:addOutgoingMiddleware(middleware)
	if not middleware or typeof(middleware) ~= "function" then
		error("Middleware should be a function.", 2)
	end

	self._middleware.Outgoing = middleware
end

--[=[
	@function new
	@within Route
	
	Creates a new Route with a unique identifier, channel, and event.

	:::note
	All Routes with the same Channel will share a single Remote. It's recommended that you run all your
	Net scheduling code on a single event.
	:::

	@param configuration Configuration?
]=]
function Route.new(configuration: Configuration?)
	local self = {}
	setmetatable(self, Route)

	self._configuration = configuration or {} :: Configuration

	-- Validate Channel
	if
		self._configuration.Channel
		and not table.find({ "Reliable", "Unreliable" }, self._configuration.Channel)
	then
		error("Channel should be Reliable or Unreliable.", 2)
	end

	-- Implement default channel
	if not self._configuration.Channel then
		self._configuration.Channel = "Reliable"
	end

	-- Validate Event
	if self._configuration.Event and typeof(self._configuration.Event) ~= "string" then
		error("Event should be a string.", 2)
	end

	self._middleware = {
		Incoming = nil,
		Outgoing = nil,
	}
	self._identifier = Identifier.new()
	self._outgoingQueue = {}
	self._currentPlayers = Players:GetPlayers()
	self._snapshot = {
		Reliable = {},
		Unreliable = {},
	}

	return self
end

--[=[
	@class Loop

	A [Matter Loop](https://matter-ecs.github.io/matter/api/Loop).

	For technical details, if you were to use a custom Loop object or try to integrate this Net Library in a ECS other than Matter,
	the ``YetAnotherNet.start(loop, { Route })`` function uses a similar implementation to ``YetAnotherNet.createHook({ Route })`` internally.

	For more information on this, see [Net.createHook].
]=]

--[=[
	@within YetAnotherNet

	Initializes your Routes by adding middleware to your Matter Loop.
	This ensures that your Routes run between each frame.

	:::note
	Please make sure that the event you set in the Configuration, or the default, is the same index you used for your
	``RunService.Heartbeat`` event in your ``Loop:begin()`` method.

	Your Routes are meant to run on the heartbeat, like most systems. In some cases you may want to run your Routes on different events,
	in this case it is acceptable to change it to a different event.
	:::

	@param loop Loop -- A Matter Loop
	@param routes { Route } -- A table of your Routes
]=]
function start(loop, routes)
	local events = {}
	for _, route in routes do
		local event = route._configuration.Event or "default"

		local exists = events[event]
		if not exists then
			events[event] = {}
		end

		table.insert(events[event], route)
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

			for _, route in events[eventName] do
				route:_updateSnapshot(bridge)
				route:_queuePackets(bridge)
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
	@within YetAnotherNet

	This function allows you to run the scheduling code on your own events.

	Because scheduling should be ran at the beginning and end of each frame,
	this will return two functions which you can use to call the scheduling
	code for the beginning and end of a frame. 

	For example, to run scheduling on the Heartbeat:
	```lua
	local beginFrame, endFrame = YetAnotherNet.createHook({ Route })
	RunService.Heartbeat:Connect(function()
		beginFrame()

		Route:send(...)
		for i, player, data in Route:query() do
			-- Do something
		end

		endFrame()
	end)
	```

	@param routes { Route } -- A table of Routes to run with these hooks
	@return () -> () -- Begin frame hook
	@return () -> () -- End frame hook
]=]
function createHook(routes)
	local bridge = Bridge.new()

	local function beginFrame()
		bridge:beginFrame()

		for _, route in routes do
			route:_updateSnapshot(bridge)
		end
	end

	local function endFrame()
		for _, route in routes do
			route:_queuePackets(bridge)
		end

		bridge:endFrame()
	end

	return beginFrame, endFrame
end

--- @prop server "Net_Server"
--- @within YetAnotherNet
--- A unique identifier used for to identify the Server when sending/querying.

--- @prop Route Route
--- @within YetAnotherNet
--- A uniquely identified Object responsible for handling queries and send requests.

--[=[
	@class YetAnotherNet

	YetAnotherNet is a networking library for Roblox, or rather its a library that wraps around Roblox's RemoteEvents to solve certain issues and provide new API for networking on Roblox.

	Some of the issues this library solves are:
	- Overhead from RemoteEvents
	- Ordering of Networking Events
	- Lack of Type-Checking and Intellisense for working with RemoteEvents

	YetAnotherNet also provides several utilities:
	- Middleware
	- Strict Type-Checking & Auto-completion
	- Simple integration with Hooks
	- Data-driven Design

	You can learn more about how YetAnotherNet works and how to use it by visiting [Getting Started with Routes](/docs/getting-started/routes).
	Or, you can keep reading to learn more about the technical details and design choices that went into creating YetAnotherNet in the [Introduction](/docs/intro).
]=]
return table.freeze({
	server = Bridge.server :: NetServer,
	Route = Route,

	createHook = createHook,
	start = start,
})
