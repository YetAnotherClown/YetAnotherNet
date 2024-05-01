--!native

local BUFFER_SIZE = 8

local function serialize(udim: UDim): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writef32(_buffer, 0, udim.Scale)
	buffer.writeu32(_buffer, 4, udim.Offset)

	return _buffer
end

local function deserialize(_buffer: buffer): UDim
	local scale = buffer.readf32(_buffer, 0)
	local offset = buffer.readu32(_buffer, 4)

	return UDim.new(scale, offset)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 43,
}
