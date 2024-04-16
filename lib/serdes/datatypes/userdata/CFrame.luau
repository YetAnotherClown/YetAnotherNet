--!native

local BUFFER_SIZE = 48

local function serialize(cframe: CFrame): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:GetComponents()
	buffer.writef32(_buffer, 0, x)
	buffer.writef32(_buffer, 4, y)
	buffer.writef32(_buffer, 8, z)
	buffer.writef32(_buffer, 12, R00)
	buffer.writef32(_buffer, 16, R01)
	buffer.writef32(_buffer, 20, R02)
	buffer.writef32(_buffer, 24, R10)
	buffer.writef32(_buffer, 28, R11)
	buffer.writef32(_buffer, 32, R12)
	buffer.writef32(_buffer, 36, R20)
	buffer.writef32(_buffer, 40, R21)
	buffer.writef32(_buffer, 44, R22)

	return _buffer
end

local function deserialize(_buffer: buffer): CFrame
	local x = buffer.readf32(_buffer, 0)
	local y = buffer.readf32(_buffer, 4)
	local z = buffer.readf32(_buffer, 8)
	local R00 = buffer.readf32(_buffer, 12)
	local R01 = buffer.readf32(_buffer, 16)
	local R02 = buffer.readf32(_buffer, 20)
	local R10 = buffer.readf32(_buffer, 24)
	local R11 = buffer.readf32(_buffer, 28)
	local R12 = buffer.readf32(_buffer, 32)
	local R20 = buffer.readf32(_buffer, 36)
	local R21 = buffer.readf32(_buffer, 40)
	local R22 = buffer.readf32(_buffer, 44)

	return CFrame.new(x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 9,
}
