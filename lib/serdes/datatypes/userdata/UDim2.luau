--!native

local udim = require(script.Parent.UDim)

local BUFFER_SIZE = udim.size * 2

local function serialize(_udim: UDim2): buffer
	local x = udim.serialize(_udim.X)
	local y = udim.serialize(_udim.Y)

	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.copy(_buffer, 0, x)
	buffer.copy(_buffer, udim.size, y)

	return _buffer
end

local function deserialize(_buffer: buffer): UDim2
	local xBuffer = buffer.create(udim.size)
	local yBuffer = buffer.create(udim.size)
	buffer.copy(xBuffer, 0, _buffer, 0, udim.size)
	buffer.copy(yBuffer, 0, _buffer, udim.size, udim.size)

	local x = udim.deserialize(xBuffer)
	local y = udim.deserialize(yBuffer)

	return UDim2.new(x, y)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	id = 44,
}
