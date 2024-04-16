--!native

local BUFFER_SIZE = 1

local map = {
	[true] = 1,
	[false] = 0,
}

local function serialize(bool: boolean?): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writei8(_buffer, 0, bool and map[bool] or -1)

	return _buffer
end

local function deserialize(_buffer: buffer): boolean?
	local number = buffer.readi8(_buffer, 0)
	return if number == 1 then true elseif number == 0 then false else nil
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,

	id = 3,
}
