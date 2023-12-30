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

local QueryResult = require(script.QueryResult)
export type QueryResult<U...> = QueryResult.QueryResult<U...>

local SendRequest = require(script.SendRequest)
export type SendRequest = SendRequest.SendRequest

--[=[
	@interface Configuration
	@within Route
	@field Channel "Reliable" | "Unreliable" -- Default: Reliable
	@field Event string -- The event to schedule the Route on in your Matter Loop -- Default: "default"
	@field Ratelimit number -- Amount of allowed invocations a frame

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
	_snapshot: IncomingQueue,
	_middleware: {
		Incoming: ((...any?) -> U...)?,
		Outgoing: ((U...) -> ...any?)?,
	},

	__index: RouteImpl<U...>,
	__iter: (self: Route<U...>) -> QueryResult<U...>,

	_queuePackets: (Route<U...>, Bridge) -> (),
	_updateSnapshot: (Route<U...>, Bridge) -> (),
	addIncomingMiddleware: (self: Route<U...>, middleware: (...any?) -> U...?) -> (),
	addOutgoingMiddleware: (self: Route<U...>, middleware: (U...) -> ...any?) -> (),
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
]=]
function Route:send(...)
	local packet = {
		channel = self._configuration.Channel,
		data = { ... },
		identifier = self._identifier,
		recipient = RunService:IsClient() and Bridge.server or Players:GetPlayers(),
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
		if self._middleware.Outgoing and packet.identifier == self._identifier then
			local newData = { self._middleware.Outgoing(table.unpack(packet.data)) }
			if #newData > 0 then
				packet.data = newData
			else
				continue
			end
		end

		-- Typecheck recipients
		if RunService:IsClient() then
			if packet.recipient ~= Bridge.server then
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

		if typeof(packet.recipient) == "string" and packet.recipient ~= Bridge.server then
			continue
		end

		table.insert(bridge._outgoingQueue[channel], packet)
	end
end

function Route:_updateSnapshot(bridge)
	local snapshot = bridge:snapshot()[self._configuration.Channel]
	for _, packet in snapshot :: { IncomingPacket } do
		if not self._middleware.Incoming or packet.identifier ~= self._identifier then
			continue
		end

		-- Implement middleware
		local newData = { self._middleware.Incoming(table.unpack(packet.data)) }
		if #newData > 0 then
			packet.data = newData
		end
	end

	self._snapshot = snapshot
end

--[=[
	@method addIncomingMiddleware
	@within Route
	
	Sets a function to be ran on Incoming packets before they are processed.
	For example, this would run after the Client receives a Packet from the Server over the network:
	after calling ``Route:send()`` on the Server and before calling ``Route:query()`` on the Client.

	See [Middleware](/docs/getting-started/middleware) for more information.
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
	if configuration then
		-- Validate Channel
		if configuration.Channel and configuration.Channel ~= ("Reliable" or "Unreliable") then
			error("Channel should be Reliable or Unreliable.", 2)
		end

		-- Implement default channel
		if not configuration.Channel then
			configuration.Channel = "Reliable"
		end

		-- Validate Event
		if configuration.Event and typeof(configuration.Event) ~= "string" then
			error("Event should be a string.", 2)
		end
	end

	self._middleware = {
		Incoming = nil,
		Outgoing = nil,
	}
	self._identifier = Identifier(tostring(self))
	self._outgoingQueue = {}
	self._snapshot = {
		Reliable = {},
		Unreliable = {},
	}

	return self
end

--[=[
	@class Loop

	A [Matter Loop](https://eryn.io/matter/api/Loop).

	For technical details, if you were to use a custom Loop object or try to integrate this Net Library in a ECS other than Matter,
	the ``Net.start(loop, { Route })`` function uses a similar implementation to ``Net.createHook({ Net })`` internally.

	For more information on this, see [Net.createHook].
]=]

--[=[
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
	@within Net

	This function allows you to run Net scheduling code on your own events.

	When you provide a table of Routes, this function will return another function
	you can call which will step each Route and process it's Packet Queue.

	For example, to run scheduling on the Heartbeat:
	```lua
	local hook = Net.createHook({ Route })
	RunService.Heartbeat:Connect(hook)
	```

	@param routes { Net } -- A table of your Routes
	@return () -> ()
]=]
function createHook(routes)
	local bridge = Bridge.new()

	return function()
		for _, route in routes do
			route:_updateSnapshot(bridge)
			route:_queuePackets(bridge)
		end

		bridge:step()
	end
end

--- @prop server "Net_Server"
--- @within Net
--- A unique identifier used for to identify the Server when sending/querying.

--- @prop Route Route
--- @within Net
--- A uniquely identified Object responsible for handling queries and send requests.

--[=[
	@class Net

	Net is a networking library for Roblox, or rather its a library that wraps around Roblox's RemoteEvents to solve certain issues and provide new API for networking on Roblox.

	Some of the issues this library solves are:
	- Overhead from RemoteEvents
	- Ordering of Networking Events
	- Lack of Type-Checking and Intellisense for working with RemoteEvents

	Net also provides several utilities:
	- Middleware
	- Strict Type-Checking & Auto-completion
	- Simple integration with Hooks
	- Data-driven Design

	You can learn more about how Net works and how to use it by visiting [Getting Started with Routes](/docs/getting-started/routes).
	Or, you can keep reading to learn more about the technical details and design choices that went into creating Net in the [Introduction](/docs/intro).
]=]
return table.freeze({
	server = Bridge.server :: NetServer,
	Route = Route,

	createHook = createHook,
	start = start,
})
