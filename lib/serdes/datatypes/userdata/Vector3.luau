--!native

local BUFFER_SIZE = 12

local function serialize(vector: Vector3): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writef32(_buffer, 0, vector.X)
	buffer.writef32(_buffer, 4, vector.Y)
	buffer.writef32(_buffer, 8, vector.Z)

	return _buffer
end

local function deserialize(_buffer: buffer): Vector3
	local x = buffer.readf32(_buffer, 0)
	local y = buffer.readf32(_buffer, 4)
	local z = buffer.readf32(_buffer, 8)

	return Vector3.new(x, y, z)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 47,
}
