--!native

local BUFFER_SIZE = 4

local function serialize(vector: Vector2): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writei16(_buffer, 0, vector.X)
	buffer.writei16(_buffer, 2, vector.Y)

	return _buffer
end

local function deserialize(_buffer: buffer): Vector2
	local x = buffer.readi16(_buffer, 0)
	local y = buffer.readi16(_buffer, 2)

	return Vector2.new(x, y)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 46,
}
