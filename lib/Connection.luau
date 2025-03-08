type ConnectionImpl = {
	__index: ConnectionImpl,
	_callback: <U...>(U...) -> (),

	connected: boolean,

	disconnect: (Connection) -> (),
	reconnect: (Connection) -> (),

	new: <U...>(callback: (U...) -> ()) -> Connection,
}

export type Connection = typeof(setmetatable({} :: ConnectionImpl, {} :: ConnectionImpl))

--[=[
    @class Connection

    Stores a callback that will be called by YetAnotherNet at the end of a frame
    if [Connection.connected] is true.

    You can disconnect the connection by using [Connection:disconnect] and
    reconnect by using [Connection:reconnect].

    For more information, see [YetAnotherNet.createConnection].
]=]
local Connection: ConnectionImpl = {} :: ConnectionImpl
Connection.__index = Connection

--- @prop connected boolean
--- @within Connection

--- @within Connection
function Connection:disconnect()
	self.connected = false

	return
end

--- @within Connection
function Connection:reconnect()
	self.connected = true

	return
end

--- @within Connection
function Connection.new<U...>(callback: (U...) -> ())
	local self = {}
	setmetatable(self, Connection)

	self.connected = true
	self._callback = function(...: U...)
		if not self.connected then
			return
		end

		task.spawn(callback, ...)
	end

	return self :: any
end

return Connection
