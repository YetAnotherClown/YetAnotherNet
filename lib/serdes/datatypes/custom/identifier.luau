--!native

local BUFFER_SIZE = 2

local nextIdentifier = 1

local function serialize(position: number?): buffer
	if not position then
		position = nextIdentifier
		nextIdentifier += 1
	end

	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writeu16(_buffer, 0, position :: number)

	return _buffer
end

local function deserialize(_buffer: buffer): number
	local position = buffer.readu16(_buffer, 0)
	return position
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 50,
}
