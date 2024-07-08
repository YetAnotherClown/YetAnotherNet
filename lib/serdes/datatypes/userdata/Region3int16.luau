--!native

local vector3int16 = require("@serdes/datatypes/userdata/Vector3int16")

local BUFFER_SIZE = vector3int16.size * 2

local function serialize(region: Region3int16): buffer
	local min = vector3int16.serialize(region.Min)
	local max = vector3int16.serialize(region.Max)

	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.copy(_buffer, 0, min, 0, vector3int16.size)
	buffer.copy(_buffer, 6, max, 0, vector3int16.size)

	return _buffer
end

local function deserialize(_buffer: buffer): Region3int16
	local minBuffer = buffer.create(vector3int16.size)
	local maxBuffer = buffer.create(vector3int16.size)

	buffer.copy(minBuffer, 0, _buffer, 0, vector3int16.size)
	buffer.copy(maxBuffer, 0, _buffer, vector3int16.size, vector3int16.size)

	local min = vector3int16.deserialize(minBuffer)
	local max = vector3int16.deserialize(maxBuffer)

	return Region3int16.new(min, max)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 38,
}
