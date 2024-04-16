--!native

local BUFFER_SIZE = 6

local function serialize(vector: Vector3int16): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writei16(_buffer, 0, vector.X)
	buffer.writei16(_buffer, 2, vector.Y)
	buffer.writei16(_buffer, 4, vector.Z)

	return _buffer
end

local function deserialize(_buffer: buffer): Vector3int16
	local x = buffer.readi16(_buffer, 0)
	local y = buffer.readi16(_buffer, 2)
	local z = buffer.readi16(_buffer, 4)

	return Vector3int16.new(x, y, z)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 48,
}
