local datatypes = script.Parent.datatypes

local primitives = datatypes.primitive
local userdata = datatypes.userdata
local custom = datatypes.custom

local idsToTypeMap

local function getSerDesById(id: number)
	if not idsToTypeMap then
		idsToTypeMap = {}

		for _, module in datatypes:GetDescendants() do
			if not module:IsA("ModuleScript") then
				continue
			end

			local serdes = require(module) :: any
			idsToTypeMap[serdes.id] = serdes
		end
	end

	return idsToTypeMap[id]
end

local function getSerDes(_type: string)
	-- Nil is grouped with the Boolean primitive
	if _type == "nil" then
		_type = "boolean"
	end

	local module = primitives:FindFirstChild(_type)
		or userdata:FindFirstChild(_type)
		or custom:FindFirstChild(_type)
	if module then
		return require(module) :: any
	end

	warn(`Unexpected type {_type} passed`)
	return
end

local function deserializeBuffer(_buffer: buffer, cursor: number): (any, number)
	local idBuffer = buffer.create(1)
	buffer.copy(idBuffer, 0, _buffer, cursor, 1)
	cursor += 1

	local id = buffer.readu8(idBuffer, 0)

	local serdes = getSerDesById(id)
	local size = serdes.size

	if not size then
		local sizeBuffer = buffer.create(4)

		buffer.copy(sizeBuffer, 0, _buffer, cursor, 4)
		cursor += 4

		size = buffer.readu32(sizeBuffer, 0)
	end

	local subBuffer = buffer.create(size)
	buffer.copy(subBuffer, 0, _buffer, cursor, size)
	cursor += size

	return serdes.deserialize(subBuffer), cursor
end

-- Source: https://github.com/jsdotlua/luau-polyfill/blob/main/modules/collections/src/Array/isArray.lua
local function isArray(value)
	if next(value) == nil then
		return true
	end

	local length = #value
	if length == 0 then
		return false
	end

	local count = 0
	local sum = 0
	for key in pairs(value) do
		if typeof(key) ~= "number" then
			return false
		end

		if key % 1 ~= 0 or key < 1 then
			return false
		end

		count += 1
		sum += key
	end

	return sum == (count * (count + 1) / 2)
end

return {
	deserializeBuffer = deserializeBuffer,
	getSerDesById = getSerDesById,
	getSerDes = getSerDes,
	isArray = isArray,
}
