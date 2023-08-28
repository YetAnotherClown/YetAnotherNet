local RunService = game:GetService("RunService")

local Bridge = require(script.Bridge)
export type Bridge = Bridge.Bridge

local Identifier = require(script.Identifier)
export type Identifier = Identifier.Identifier

--[=[
	@interface Configuration
	@within Net
	@field Channel "ReliableOrdered" | "ReliableUnordered" | "Unreliable" -- Default: ReliableUnordered
	@field DebugMode boolean -- Enable Debug Features?
	@field DebugKey KeyCode -- The key to open the Debug Panel
	@field Event string -- The event to schedule Net on in your Matter Loop -- Default: "default"
	@field Middleware (sender, identifier, ...) -> any -- Ran before a packet is queried
	@field Ratelimit number -- Amount of allowed invocations a frame

	@tag Future Feature

	As of v0.2.0, the only two configuration parameters that are implemented are Event and Priority.
	All other parameters will be implemented at a later date. With the exception of Middleware & Ratelimiting,
	most of these parameters should not change and remain stable API.

	### Channel

	**ReliableOrdered**: Ensures the order in which Packets were sent at the cost of a few bytes. It is not recommended
	that this is used. In most cases, ``ReliableUnordered`` should work.

	**ReliableUnordered**: Does not ensure the order in which Packets are sent. However, Packets will be ordered properly
	per Identifier only. This should work in most cases and does not have any overhead.

	**Unreliable**: Anticipated feature that Roblox may add, this is here for planning and is not yet available.
]=]
type Configuration = {
	Channel: ("ReliableOrdered" | "ReliableUnordered" | "Unreliable")?,
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

	-- Filters take in a key-value pair, the filter can remove this pair by not adding it to the filtered_snapshot array.
	if filter then
		local filteredSnapshot = {}
		for k, v in snapshot do
			local filtered = filter(v)
			if filtered then
				table.insert(filteredSnapshot, v)
			end
		end
		snapshot = filteredSnapshot
	end

	return function()
		i += 1

		local packet = snapshot[i]
		if packet then
			if returnFilter then
				return returnFilter(i, packet.sender, packet.identifier, packet.data)
			else
				return i,
					packet.sender,
					packet.identifier,
					unpack(packet.data)
			end
		end

		return
	end
end

-- The varying Parameter Types used for queries
type QueryParams = {
	multipleSenders: boolean,
	senders: { "NET_SERVER" | Player },
	identifiers: { Identifier },
}

-- Query different Parameter Types
local parseQueryParams = {
	Player = function(queryParams: QueryParams, player: Player)
		table.insert(queryParams.senders, player)
	end,

	table = function(queryParams: QueryParams, players: { Player })
		queryParams.multipleSenders = true

		for _, player in players do
			table.insert(queryParams.senders, player)
		end
	end,

	string = function(queryParams: QueryParams, identifier: string)
		if identifier == "NET_SERVER" then
			return
		end

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
		multipleSenders = false,
		senders = {},
		identifiers = {},
	} :: QueryParams

	-- Parse each appropriate Parameter Type
	for _, param in { ... } do
		local parser = parseQueryParams[typeof(param)]
		parser(queryParams, param)
	end

	-- Build the iterator function with Filters
	local iter = self:__iter(function(v)
		-- Filter Sender
		if
			not RunService:IsClient()
			and not queryParams.multipleSenders
			and v.sender
			and not table.find(queryParams.senders, v.sender)
		then
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
		if queryParams.multipleSenders or #queryParams.senders ~= 1 and not (RunService:IsClient() and #queryParams.senders == 0) then
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
