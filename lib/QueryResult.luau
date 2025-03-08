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

type ClientQueryResult<U...> = {
	__index: ClientQueryResult<U...>,
	__iter: (self: ClientQueryResult<U...>) -> () -> (number, U...),

	_snapshot: { IncomingPacket },
	_identifier: Identifier,
	_senders: { NetServer },

	iter: (self: ClientQueryResult<U...>) -> () -> (number, U...),
}

type ServerQueryResult<U...> = {
	__index: ServerQueryResult<U...>,
	__iter: (self: ServerQueryResult<U...>) -> () -> (number, Player, U...),

	_snapshot: { IncomingPacket },
	_identifier: Identifier,
	_senders: { Player },
	_view: "server",

	iter: (self: ServerQueryResult<U...>) -> () -> (number, Player, U...),
	from: (self: QueryResult<U...>, ...Player) -> QueryResult<U...>,
}

--[=[
	@class QueryResult
	@since v0.4.0

	An iterable object returned as the result of [Route:query] that can filter snapshots
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

	See [Querying Data](/docs/getting-started/routes#querying) for more information.
]=]
type QueryResultImpl<U...> = {
	__index: QueryResultImpl<U...>,
	__iter: (self: QueryResult<U...>) -> () -> (number, Player | NetServer, U...),

	_snapshot: { IncomingPacket },
	_identifier: Identifier,
	_senders: { Player | NetServer },
	_view: "client"?,

	iter: (self: QueryResult<U...>) -> () -> (number, Player | NetServer, U...),
	from: (self: QueryResult<U...>, ...(Player | NetServer)) -> QueryResult<U...>,

	client: (self: QueryResult<U...>) -> ClientQueryResult<U...>,
	server: (self: QueryResult<U...>) -> ServerQueryResult<U...>,

	new: (
		snapshot: { IncomingPacket },
		identifier: Identifier,
		senders: { Recipient }?
	) -> QueryResult<U...>,
}

export type QueryResult<U...> = typeof(setmetatable(
	{} :: QueryResultImpl<U...>,
	{} :: QueryResultImpl<U...>
))

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

	local filteredSnapshot = {}

	local view = self._view

	for i = 1, #self._snapshot do
		local packet = self._snapshot[i]
		if not packet then
			continue
		end

		local filterSenders = #senders > 0
		local isSenderAllowed = if filterSenders then table.find(senders, packet.sender) else true

		if read(packet.identifier) ~= read(identifier) or not isSenderAllowed then
			continue
		end

		table.insert(filteredSnapshot, packet)
	end

	local i = 0

	return function(): ...any
		i += 1

		local packet = filteredSnapshot[i]
		if not packet then
			return
		end

		if view == "client" then
			return i, unpack(packet.data)
		end

		return i, packet.sender, unpack(packet.data)
	end
end

--[=[
	@method iter
	@within QueryResult
	
	An iterator method for typechecking.

	```lua
	for i, sender, ... in route:query():iter() do
		-- ...
	end
	```
]=]
function QueryResult:iter()
	return self:__iter()
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
		if typeof(param) == "table" and param.__type ~= "Player" then
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
	@method client
	@within QueryResult
	
	Switches the query to a client view, for typechecking.
	The client view will not return a `sender` when iterating.

	```lua
	for i, ... in route:query():client():iter() do
		-- ...
	end
	```
]=]
function QueryResult:client()
	self._view = "client"
	return self :: any
end

--[=[
	@method server
	@within QueryResult
	
	Switches the query to a server view, for typechecking.

	```lua
	for i, player, ... in route:query():server():iter() do
		-- ...
	end
	```
]=]
function QueryResult:server()
	return self :: any
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
	}, QueryResult) :: any
end

return QueryResult
