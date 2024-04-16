--!native

local vector2 = require(script.Parent.Vector2)

local BUFFER_SIZE = vector2.size * 2

local function serialize(rect: Rect): buffer
	local min = vector2.serialize(rect.Min)
	local max = vector2.serialize(rect.Max)

	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.copy(_buffer, 0, min, 0, vector2.size)
	buffer.copy(_buffer, vector2.size, max, 0, vector2.size)

	return _buffer
end

local function deserialize(_buffer: buffer): Rect
	local minBuffer = buffer.create(vector2.size)
	local maxBuffer = buffer.create(vector2.size)

	buffer.copy(minBuffer, 0, _buffer, 0, vector2.size)
	buffer.copy(maxBuffer, 0, _buffer, vector2.size, vector2.size)

	local min = vector2.deserialize(minBuffer)
	local max = vector2.deserialize(maxBuffer)

	return Rect.new(min, max)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 36,
}
