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
	_snapshot: { IncomingPacket },
	_identifier: Identifier,
	_senders: { Player | NetServer },

	__index: QueryResultImpl<U...>,
	__iter: (self: QueryResult<U...>) -> () -> (number?, (Player | NetServer)?, U...),

	from: (self: QueryResult<U...>, ...(Player | NetServer)) -> QueryResult<U...>,

	new: (
		snapshot: { IncomingPacket },
		identifier: Identifier,
		senders: { Recipient }?
	) -> QueryResult<U...>,
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

	local filteredSnapshot = {}

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

	return function()
		i += 1

		local packet = filteredSnapshot[i]
		if not packet then
			return
		end

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

return QueryResult
