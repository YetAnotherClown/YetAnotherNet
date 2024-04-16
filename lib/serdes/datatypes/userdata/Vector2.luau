--!native

local BUFFER_SIZE = 8

local function serialize(vector: Vector2): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writef32(_buffer, 0, vector.X)
	buffer.writef32(_buffer, 4, vector.Y)

	return _buffer
end

local function deserialize(_buffer: buffer): Vector2
	local x = buffer.readf32(_buffer, 0)
	local y = buffer.readf32(_buffer, 4)

	return Vector2.new(x, y)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = 8,
	id = 45,
}
