--!native

local cframe = require("@serdes/datatypes/userdata/CFrame")
local vector3 = require("@serdes/datatypes/userdata/Vector3")

local BUFFER_SIZE = cframe.size + vector3.size

local function serialize(region: Region3): buffer
	local _cframe = cframe.serialize(region.CFrame)
	local size = vector3.serialize(region.Size)

	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.copy(_buffer, 0, _cframe, 0, cframe.size)
	buffer.copy(_buffer, cframe.size, size, 0, vector3.size)

	return _buffer
end

local function deserialize(_buffer: buffer): Region3
	local cframeBuffer = buffer.create(cframe.size)
	local sizeBuffer = buffer.create(vector3.size)

	buffer.copy(cframeBuffer, 0, _buffer, 0, cframe.size)
	buffer.copy(sizeBuffer, 0, _buffer, cframe.size, vector3.size)

	local _cframe = cframe.deserialize(cframeBuffer)
	local size = vector3.deserialize(sizeBuffer)

	local min = _cframe.Position - (size / 2)
	local max = _cframe.Position + (size / 2)

	return Region3.new(min, max)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 37,
}
