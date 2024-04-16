--!native

local root = script.Parent.Parent.Parent

local utilities = require(root.utilities)
local deserializeBuffer = utilities.deserializeBuffer
local getSerDes = utilities.getSerDes
local isArray = utilities.isArray

--[[
	Structure of Dictionary Buffers:

	Buffer {
		type: u8, -- Type of the Buffer (Dictionary)
		size: u32, -- Size of the Dictionary Buffer

		-- Then the sub-buffers
		...

		-- Key
		type: u8,
		size: u32?,
		buffer,

		-- Index
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

local function serialize(dictionary: { [any]: any }): buffer?
	local buffers = {}

	local sum = 0

	-- Serialize each value in array
	for key, value in dictionary do
		local _type = typeof(value)
		if _type == "table" then
			_type = isArray(value) and "array" or "dictionary"
		end

		local valueSerdes = getSerDes(_type)
		if not valueSerdes then
			warn(`Cannot serialize type {_type} when serializing Dictionary Value`)
			return
		end

		local valueBuffer = valueSerdes.serialize(value)
		if not valueBuffer then
			return
		end

		local length = buffer.len(valueBuffer)
		sum += length

		local idBuffer = buffer.create(1)
		buffer.writeu8(idBuffer, 0, valueSerdes.id)
		sum += buffer.len(idBuffer)

		local sizeBuffer
		if valueSerdes.size ~= length then
			sizeBuffer = buffer.create(4)
			buffer.writeu32(sizeBuffer, 0, length)
			sum += buffer.len(sizeBuffer)
		end

		local keyType = typeof(key)
		if keyType == "table" then
			keyType = isArray(key) and "array" or "dictionary"
		end

		local keySerdes = getSerDes(keyType)
		if not keySerdes then
			warn(`Cannot serialize type {_type} when serializing Dictionary Key`)
			return
		end

		local keyBuffer = keySerdes.serialize(key)
		if not keyBuffer then
			return
		end

		local keyLength = buffer.len(keyBuffer)
		sum += keyLength

		local keyTypeBuffer = buffer.create(1)
		buffer.writeu8(keyTypeBuffer, 0, keySerdes.id)
		sum += buffer.len(keyTypeBuffer)

		local keySizeBuffer
		if keySerdes.size ~= keyLength then
			keySizeBuffer = buffer.create(4)
			buffer.writeu32(keySizeBuffer, 0, keyLength)
			sum += buffer.len(keySizeBuffer)
		end

		buffers[key] = {
			key = {
				type = keyTypeBuffer,
				size = keySizeBuffer,
				buffer = keyBuffer,
			},
			value = {
				type = idBuffer,
				size = sizeBuffer,
				buffer = valueBuffer,
			},
		}
	end

	local _buffer = buffer.create(sum)
	local cursor = 0

	for _, _buffers in buffers do
		local key = _buffers.key
		buffer.copy(_buffer, cursor, key.type)
		cursor += buffer.len(key.type)

		if key.size then
			buffer.copy(_buffer, cursor, key.size)
			cursor += buffer.len(key.size)
		end

		buffer.copy(_buffer, cursor, key.buffer)
		cursor += buffer.len(key.buffer)

		local value = _buffers.value
		buffer.copy(_buffer, cursor, value.type)
		cursor += buffer.len(value.type)

		if value.size then
			buffer.copy(_buffer, cursor, value.size)
			cursor += buffer.len(value.size)
		end

		buffer.copy(_buffer, cursor, _buffers.value.buffer)
		cursor += buffer.len(_buffers.value.buffer)
	end

	return _buffer
end

local function deserialize(_buffer: buffer): { [any]: any }
	local dictionary = {}

	local cursor = 0
	local i = 0

	repeat
		i += 1

		local key, cursorPosition = deserializeBuffer(_buffer, cursor)
		cursor = cursorPosition

		local value, _cursorPosition = deserializeBuffer(_buffer, cursor)
		cursor = _cursorPosition

		dictionary[key] = value
	until cursor == buffer.len(_buffer)

	return dictionary
end

return {
	serialize = serialize,
	deserialize = deserialize,

	id = 2,
}
