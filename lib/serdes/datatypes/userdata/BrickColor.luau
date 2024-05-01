--!native

local BUFFER_SIZE = 2

local function serialize(color: BrickColor): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writeu16(_buffer, 0, color.Number)

	return _buffer
end

local function deserialize(_buffer: buffer): BrickColor
	local colorNumber = buffer.readu16(_buffer, 0)
	return BrickColor.new(colorNumber)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 7,
}
