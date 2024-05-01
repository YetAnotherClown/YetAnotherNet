--!native

local BUFFER_SIZE = 4

local function serialize(number: number): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writef32(_buffer, 0, number)
	return _buffer
end

local function deserialize(_buffer: buffer): number
	return buffer.readf32(_buffer, 0)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 4,
}
