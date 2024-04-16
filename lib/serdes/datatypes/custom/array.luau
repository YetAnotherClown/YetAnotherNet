--!native

local root = script.Parent.Parent.Parent

local utilities = require(root.utilities)
local deserializeBuffer = utilities.deserializeBuffer
local getSerDes = utilities.getSerDes
local isArray = utilities.isArray

--[[
	Structure of Array Buffers:

	Buffer {
		type: u8, -- Type of the Buffer (Array)
		size: u32, -- Size of the Array Buffer

		-- Then the sub-buffers
		...

		type: u8,
		size: u32?,
		buffer,
	}

	type: u8
	The type slice of the Buffer is a u8 that acts as an identifier
	for each Datatype. These will be hardcoded into the library in
	each Datatype's respective module.

	size: u32?
	This is a slice that will only be written to the Buffer if the
	type is Dynamic as we cannot hardcode the size in the library.
	This allows us to know where the buffer is when packed into
	a parent buffer.

	buffer
	This is the sub-buffer for the given Datatype that contains
	our data. The type and size slices will be used to deserialize
	this buffer to extract the data at runtime.
]]

local function serialize(array: { any }): buffer?
	local buffers = {}

	local sum = 0

	-- Serialize each value in array
	for i, value in array do
		-- Get the type, accounting for array and dictionary types (and other custom types)
		local _type = typeof(value)
		if _type == "table" then
			_type = isArray(value) and "array" or "dictionary"
		end

		local serdes = getSerDes(_type)
		if not serdes then
			warn(`Cannot serialize type {_type} when serializing Array value`)
			return
		end

		local _buffer = serdes.serialize(value)
		if not _buffer then
			return
		end

		local length = buffer.len(_buffer)
		sum += length

		local idBuffer = buffer.create(1)
		buffer.writeu8(idBuffer, 0, serdes.id)
		sum += buffer.len(idBuffer)

		local sizeBuffer
		if serdes.size ~= length then
			sizeBuffer = buffer.create(4)
			buffer.writeu32(sizeBuffer, 0, length)
			sum += buffer.len(sizeBuffer)
		end

		buffers[i] = {
			type = idBuffer,
			size = sizeBuffer,
			buffer = _buffer,
		}
	end

	local _buffer = buffer.create(sum)
	local cursor = 0

	for _, _buffers in buffers do
		buffer.copy(_buffer, cursor, _buffers.type)
		cursor += buffer.len(_buffers.type)

		if _buffers.size then
			buffer.copy(_buffer, cursor, _buffers.size)
			cursor += buffer.len(_buffers.size)
		end

		buffer.copy(_buffer, cursor, _buffers.buffer)
		cursor += buffer.len(_buffers.buffer)
	end

	return _buffer
end

local function deserialize(_buffer: buffer): { any }
	local array = {}

	local cursor = 0
	local i = 0

	repeat
		i += 1

		local value, cursorPosition = deserializeBuffer(_buffer, cursor)
		cursor = cursorPosition
		array[i] = value
	until cursor == buffer.len(_buffer)

	return array
end

return {
	serialize = serialize,
	deserialize = deserialize,

	id = 1,
}
