--!native

local BUFFER_SIZE = 2

local brickColorCache = {}

local function serialize(color: BrickColor): buffer
	if brickColorCache[color.Number] then
		return brickColorCache[color.Number]
	end

	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writeu16(_buffer, 0, color.Number)

	brickColorCache[color.Number] = _buffer

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
