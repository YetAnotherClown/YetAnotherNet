--!native

local BUFFER_SIZE = 12

local function serialize(color: Color3): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writef32(_buffer, 0, color.R)
	buffer.writef32(_buffer, 4, color.G)
	buffer.writef32(_buffer, 8, color.B)

	return _buffer
end

local function deserialize(_buffer: buffer): Color3
	local r = buffer.readf32(_buffer, 0)
	local g = buffer.readf32(_buffer, 4)
	local b = buffer.readf32(_buffer, 8)

	return Color3.new(r, g, b)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 10,
}
