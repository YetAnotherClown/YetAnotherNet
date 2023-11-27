local RunService = game:GetService("RunService")

local Bridge = require(script.Bridge)
export type Bridge = Bridge.Bridge

local Identifier = require(script.Identifier)
export type Identifier = Identifier.Identifier

--[=[
	@interface Configuration
	@within Net
	@field Channel "Reliable" | "Unreliable" -- Default: Reliable
	@field DebugMode boolean -- Enable Debug Features?
	@field DebugKey KeyCode -- The key to open the Debug Panel
	@field Event string -- The event to schedule Net on in your Matter Loop -- Default: "default"
	@field Middleware (sender, identifier, ...) -> any -- Ran before a packet is queried
	@field Ratelimit number -- Amount of allowed invocations a frame

	@tag Future Feature

	As of v0.2.0, the only configuration parameter that is implemented is Event.
	All other parameters will be implemented at a later date. With the exception of Middleware & Ratelimiting,
	most of these parameters should not change and remain stable API.

	### Channel

	**Reliable**: All packets will be sent and received per frame in order.

	**Unreliable**: Anticipated feature that Roblox may add, this is here for planning and is not yet available.
]=]
type Configuration = {
	Channel: ("Reliable" | "Unreliable")?,
	DebugMode: boolean?,
	DebugKey: Enum.KeyCode?,
	Event: string?,
	Middleware: ((any) -> any)?,
	Ratelimit: number?,
}

--[=[
	@class Net

	A Networking Library, inspired by BridgeNet2 & Bevy_Renet, made for ECS.

	See the [Intro](https://yetanotherclown.github.io/Net/docs/intro) to get started.
]=]
local Net = {}
Net.__index = Net

Net._bridge = {} :: Bridge
Net.Server = "NET_SERVER"

--[=[
	@class QueryResult
	@since v0.4.0

	An iterable object returned as the result of [Net:query] that can filter snapshots
	by Identifiers and Senders.

	See [Querying Data](https://yetanotherclown.github.io/Net/docs/querying-data) for more information.
]=]
local QueryResult: QueryResultImpl = {} :: QueryResultImpl
QueryResult.__index = QueryResult

--[=[
	@method __iter
	@within QueryResult
	
	Iterating over a QueryResult will return the Packets in it's Snapshot that
	match the supplied Identifiers from [Net:query] and the supplied Senders
	from [QueryResult:from].

	Usage:
	```lua
	for pos, sender, identifier, ... in net:query(...identifiers):from(...senders) do
		-- Do something
	end
	```

	@return number
	@return Player | string
	@return string
	@return ...any
]=]
function QueryResult:__iter()
	local senders = self._senders
	local identifiers = self._identifiers

	local snapshot = self._snapshot
	local i = 1

	local function iterator(): (number?, (Player | string)?, string?, ...any)
		local packet = snapshot[i]
		if not packet then
			return
		end

		-- Return all packets if no Identifiers are supplied, or filter by Identifiers
		local filterIdentifiers = #identifiers > 0
		local isIdentifierAllowed = filterIdentifiers and table.find(identifiers, packet.identifier) or true

		-- Return all packets if no Senders are supplied, or filter by Senders
		local filterSenders = #senders > 0
		local isSenderAllowed = not filterSenders and table.find(senders, packet.sender) or true

		-- Don't return packet if filtered
		if not isIdentifierAllowed or not isSenderAllowed then
			return
		end

		-- Tick for next packet
		i += 1

		return i, packet.sender, packet.identifier, unpack(packet.data)
	end

	return iterator
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
	return self.new(self._snapshot, self._identifiers, senders)
end

--[=[
	@method of
	@within QueryResult
	@private

	:::caution
		This method may change in later versions, it is advised you only supply Identifiers
		by using [Net:query] and avoid using this method.
	:::
	
	Filters Packets from the QueryResult's Snapshot based on the provided Identifiers.

	@param identifiers ...identifier -- The Identifiers to filter
	@return QueryResult
]=]
function QueryResult:of(...: string)
	return self.new(self._snapshot, { ... }, self._senders)
end

--[=[
	@function new
	@within QueryResult
	@private

	Creates a new QueryResult with the supplied Snapshot.

	@param snapshot { identifier: string, sender: Player | "NET_SERVER", data: { any } } -- The Identifiers to filter
	@return QueryResult
]=]
function QueryResult.new(snapshot, identifiers, senders): QueryResult
	return setmetatable({
		_snapshot = snapshot,
		_identifiers = identifiers or {},
		_senders = senders or {},
	}, QueryResult)
end

export type QueryResultImpl = {
	_snapshot: {
		{
			identifier: string,
			sender: Player | "NET_SERVER",
			data: { any },
		}
	},
	_identifiers: { string },
	_senders: { Player | "NET_SERVER" },

	__index: QueryResultImpl,
	__iter: (self: QueryResult) -> () -> (number?, Player? | string?, string?, ...any),
	from: (self: QueryResult, ...(Player | "NET_SERVER")) -> QueryResult,
	of: (self: QueryResult, ...string) -> QueryResult,

	new: (
		snapshot: {
			{
		identifier: string,
		sender: Player | "NET_SERVER",
		data: { any },
			}
		},
		identifiers: { string? }?,
		senders: { { Player } | Player | "NET_SERVER" }?
	) -> QueryResult,
}

export type QueryResult = typeof(setmetatable({}, QueryResult))

--[=[
	@method __iter
	@within Net
	@private
	
	Creates a QueryResult that returns all Packets in the current frame's snapshot.
	See [Net:query] to filter Identifiers and Senders.

	@return QueryResult
]=]
function Net:__iter(): QueryResult
	local snapshot = self._bridge:snapshot()
	return QueryResult.new(snapshot)
end

--[=[
	@method query
	@within Net
	
	Allows for iteration of all packets of the previous frame.

	You can filter by Identifiers by adding them as function parameters. You can also filter by Senders
	by chaining the ``QueryResult:from()`` method onto the query method.

	See [Querying Data](https://yetanotherclown.github.io/Net/docs/querying-data) for more information.

	@return QueryResult
]=]
function Net:query(...: Identifier): QueryResult
	local snapshot = self._bridge:snapshot()
	return QueryResult.new(snapshot, { ... })
end

-- The varying Parameter Types used for sending data
type SendParams = {
	recipient: "NET_SERVER" | { Player } | Player,
	identifier: Identifier,
	data: { any },
}

-- Send different Parameter Types
local parseSendParams = {
	Instance = function(sendParams: SendParams, player: Player)
		-- Player should be a Player
		if typeof(player) ~= "Instance" then
			return
		elseif not player:IsA("Player") then
			return
		end

		if typeof(sendParams.recipient) == "Instance" then
			-- Combine both Players into a table
			sendParams.recipient = { sendParams.recipient, player }
		elseif typeof(sendParams.recipient) == "table" then
			-- Add the Player to the preexisting table
			table.insert(sendParams.recipient, player)
		else
			-- Set the recipient as the player
			sendParams.recipient = player
		end
	end,

	table = function(sendParams: SendParams, players: { Player })
		-- Each Player should be a Player
		for _, player in players do
			if typeof(player) ~= "Instance" then
				return
			elseif not player:IsA("Player") then
				return
			end
		end

		if typeof(sendParams.recipient) == "Instance" then
			-- Add the player to the new table, then set that table as the recipient
			table.insert(players, sendParams.recipient)
			sendParams.recipient = players
		elseif typeof(sendParams.recipient) == "table" then
			-- Combine both tables of Players
			for _, player in players do
				table.insert(sendParams.recipient, player)
			end
		else
			-- Set the Players as the recipient
			sendParams.recipient = players
		end
	end,

	string = function(sendParams: SendParams, identifierOrNetServer: string)
		if identifierOrNetServer == "NET_SERVER" then
			-- Net.Server is a recipient
			sendParams.recipient = identifierOrNetServer
		else
			-- Only one Identifier can be used when sending data
			sendParams.identifier = identifierOrNetServer
		end
	end,
}

--[=[
	@method send
	@within Net
	
	Sends data to a recipient or the server if not specified under a unique identifier.

	See [Sending Data](https://yetanotherclown.github.io/Net/docs/sending-data) for more information.
]=]
function Net:send(...)
	local sendParams = {
		identifier = nil,
		recipient = nil,
		data = {},
	} :: SendParams

	-- Parse each appropriate Parameter Type
	for _, param in { ... } do
		-- SendParams end after the Identifier is given
		if sendParams.identifier then
			table.insert(sendParams.data, param)

			continue
		end

		-- Parse the SendParams
		local parser = parseSendParams[typeof(param)]
		parser(sendParams, param)
	end

	-- Fill in recipient for the Client
	if RunService:IsClient() then
		sendParams.recipient = "NET_SERVER"
	end

	-- Queue the data on the Bridge
	self._bridge:send(sendParams.recipient, sendParams.identifier, sendParams.data)
end

-- Identifiers are globally unique
function Net.identifier(index)
	return Identifier(index)
end

--[=[
	@class Loop

	A [Matter Loop](https://eryn.io/matter/api/Loop).

	For technical details, if you were to use a custom Loop object or try to integrate this Net Library in a ECS other than Matter,
	the ``Net:start()`` method is the equivalent of scheduling the ``Bridge:step()`` function to run first on the ``RunService.Heartbeat``
	event.

	For more information on this, see the [Bridge API](https://yetanotherclown.github.io/Net/api/Bridge)
]=]

--[=[
	@method start
	@within Net
	
	Initializes your Net Server by adding middleware to your Matter Loop.
	This ensures that your netcode runs last every frame.

	:::note
	Please make sure that the event you set in the Configuration, or the default, is the same index you used for your ``RunService.Heartbeat`` event in your ``Loop:begin()`` method.

	Your netcode is meant to run on the heartbeat, like most systems. In some cases you may want to run your netcode on different events, in this case
	it is acceptable to change it to a different event.
	You should have different Net objects for each event in this case.
	:::

	@param loop Loop -- A Matter Loop
]=]
function Net:start(loop: any)
	-- Performs queue tasks after each frame finishes
	loop:addMiddleware(function(nextFn, eventName)
		local function networkingMiddleware()
			-- Each Net object should run on one event
			-- Otherwise it may cause undesired behavior
			if eventName ~= self._configuration.Event then
				nextFn()
				return
			end

			-- Middleware runs before/after each frame,
			self._bridge:step()

			nextFn()
		end

		return networkingMiddleware
	end)

	return
end

--[=[
	@function new
	@within Net
	
	Creates a new Net object with unique configuration.

	:::warning
	You should limit the amount of Net objects you create, each object runs on a separate RemoteEvent based on it's
	Channel and Event. Net Objects with the same Channel and Event will run on the same RemoteEvent.
	Net achieves it's performance gains by primarily reducing the overhead of RemoteEvent calls.
	:::

	@param configuration Configuration?
]=]
function Net.new(configuration: Configuration?)
	local self = {}
	setmetatable(self, Net)

	self._bridge = Bridge.new(configuration) :: Bridge
	self._configuration = configuration or {}

	return self
end

export type Net = typeof(Net.new())

return Net
