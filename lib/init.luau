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
	@field Middleware (sender, identifier, ...) -> any -- Ran before a packet is queried
	@field Ratelimit number -- Amount of allowed invocations a frame

	@tag Future Feature

	As of v0.1.0, none of these are implemented. All are planned and will be implemented in later versions.
]=]
type Configuration = {
	Channel: ("ReliableOrdered" | "ReliableUnordered" | "Unreliable")?,
	DebugMode: boolean?,
	DebugKey: Enum.KeyCode?,
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
	@method __iter
	@within Net
	@private
	@tag Internal Use Only
	
	Creates an iterator function that creates a snapshot and iterates over it; 
	filtering out key-value pairs of the snapshot when a filter is provided, and filtering out 
	the return results of the iterator function when a returnFilter is provided.

	```lua
	type FilteredResults = (
		pos: number?,
		sender: (Player | string)?,
		identifier: Identifier?,
		packetData: any?...
	)

	Net:__iter(
		filter: (
			k: number,
			v: any
		) -> (
			number?,
			any?
		)?,
		returnFilter: (
			pos: number,
			sender: (Player | string),
			identifier: string,
			packetData: {any}
		) -> FilteredResults
	) -> () -> FilteredResults

	@return (pos: number?, sender: (Player | string)?, identifier: string?, packetData: any?...)
]=]
function Net:__iter(filter: (k: number, v: any) -> (number?, any?)?, returnFilter)
	local snapshot = self._bridge:snapshot()
	local i = 0

	-- Filters take in a key-value pair, the filter can remove this pair by returning ``k, nil``.
	if filter then
		for k, v in snapshot do
			v = filter(v)

			if v then
				snapshot[k] = v
			else
				table.remove(snapshot, k)
			end
		end
	end

	return function()
		i += 1

		local packet = snapshot[i]
		if packet then
			return if returnFilter then returnFilter(i, packet.sender, packet.identifier, packet.data) else i,
				packet.sender,
				packet.identifier,
				unpack(packet.data)
		end

		return
	end
end

-- The varying Parameter Types used for queries
type queryParams = {
	senders: { "NET_SERVER" | Player },
	identifiers: { Identifier },
}

-- Query different Parameter Types
local parseQueryParams = {
	Player = function(queryParams: queryParams, player: Player)
		table.insert(queryParams.senders, player)
	end,

	table = function(queryParams: queryParams, players: { Player })
		for _, player in players do
			table.insert(queryParams.senders, player)
		end
	end,

	string = function(queryParams: queryParams, identifier: string)
		table.insert(queryParams.identifiers, identifier)
	end,
}

--[=[
	@method query
	@within Net
	
	Allows for iteration of all packets of the previous frame with support for QueryParameters.
	QueryParameters can be ``Player``, ``{Players}``, or ``Identifier``.
	When provided, related return values will not be returned.

	See [Querying Data](https://yetanotherclown.github.io/Net/docs/querying-data) for more information.

	@return () -> (pos: number, sender: (Player | string)?, identifier: (string)?, packetData: any...)
]=]
function Net:query(...: { Players } | Player | Identifier | any)
	local queryParams = {
		senders = {},
		identifiers = {},
	} :: queryParams

	-- Parse each appropriate Parameter Type
	for _, param in { ... } do
		local parser = parseQueryParams[typeof(param)]
		parser(queryParams, param)
	end

	-- Build the iterator function with Filters
	local iter = self:__iter(function(v)
		-- Filter Sender
		if not table.find(queryParams.senders, v.sender) then
			return
		end

		-- Filter Identifier
		if not table.find(queryParams.identifiers, v.identifier) then
			return
		end

		return v
	end, function(i, sender, identifier, data)
		local package = { i }

		--[[
            With how the query method works, the Sender and Identifier
            may already be known to the caller. That is if they have
            provided them within the Query Parameters.

            It becomes obvious who the sender is or what identifier they
            are listening to if they have only provide one of either.
            If they have provided multiple, we return who the sender or
            what the identifier is.

            { Players }, Identifier -> Position, Player, Data
            Player, Identifier, Identifier -> Position, Identifier, Data
            _ -> Position, Sender, Identifier, Data
        ]]

		-- If not already known, return the sender
		if #queryParams.senders ~= 1 then
			table.insert(package, sender)
		end

		-- If not already known, return the identifier
		if #queryParams.identifiers ~= 1 then
			table.insert(package, identifier)
		end

		-- Return all data
		for _, v in data do
			table.insert(package, v)
		end

		return table.unpack(package)
	end)

	return iter
end

--[=[
	@method send
	@within Net
	
	Sends data to a recipient or the server if not specified under a unique identifier.

	See [Sending Data](https://yetanotherclown.github.io/Net/docs/sending-data) for more information.

	@param param1 PacketRecipient | PacketIdentifier -- An optional First Parameter that specifies a recipient of Player, { Player }, or ``Net.Server``. If not specified, the packet will be sent to the server.
	@param param2 PacketIdentifier | ...any -- A secondary parameter representing a unique Identifier of ``string``.
	@param data ...any -- A tuple representing the data you want to send.
]=]
function Net:send(recipient: { Player } | Player | "NET_SERVER", identifier: Identifier, ...: any)
	self._bridge:send(recipient, identifier, { ... })
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

	To use it outside of any ECS, you could use the following code:
	```lua
	RunService.Heartbeat:Connect(function()
		Net._bridge:step()
	end)
	```

	Otherwise, you can use the ``Bridge:step()`` method to integrate it into other ECS libraries.
]=]

--[=[
	@method start
	@within Net
	
	Initializes your Net Server by scheduling it on your Matter Loop.
	This ensures that your netcode runs first every frame.

	:::note
	Please make sure that the event you provided is the same index you used for your ``RunService.Heartbeat`` event in your ``Loop:begin()`` method.

	Your netcode is meant to run on the heartbeat, like most systems. In some cases you may want to run your netcode on different events, in this case
	it is acceptable to change it to a different event.
	You should have different netcodes for each event in this case.
	:::

	:::warning
	The ``start`` method assumes your systems are ordered from ``0`` to ``inf``.
	If you have any systems that run on a priority below zero, you should either change your system's priority or manually set the priority in the ``start`` method.

	If your netcode runs after any system, it may cause undesired behavior.
	:::

	@param loop Loop -- An optional First Parameter that specifies a recipient of Player, { Player }, or ``Net.Server``. If not specified, the packet will be sent to the server.
	@param event string -- The Index of the Event you want Net to use in your ``Loop:begin()`` method.
	@param priorityOverride number -- A optional override for the priority of the Net System/
]=]
function Net:start(loop: any, event: string, priorityOverride: number?)
	local function handleNetworking()
		self._bridge:step()
	end

	loop:scheduleSystem({
		system = handleNetworking,
		event = event,
		priority = priorityOverride or -1,
	})

	return nil
end

--[=[
	@function new
	@within Net
	
	Creates a new Net object with unique configuration.

	:::warning
	You should limit the amount of Net objects you create, each object runs on a separate RemoteEvent.
	Net achieves it's performance gains by primarily reducing the overhead of RemoteEvent calls.
	:::

	@param configuration Configuration?
]=]
function Net.new()
	local self = {}
	setmetatable(self, Net)

	self._bridge = Bridge.new() :: Bridge

	return self
end

export type Net = typeof(Net.new())

return Net
