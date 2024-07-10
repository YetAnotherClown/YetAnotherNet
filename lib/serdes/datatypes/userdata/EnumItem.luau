--!native

local enumMap = {}
for _, enum in Enum:GetEnums() do
	enumMap[tostring(enum)] = {}

	for _, enumItem in enum:GetEnumItems() do
		enumMap[tostring(enum)][enumItem.Value] = enumItem
	end
end

local enumItemCache = {}

local function serialize(enumItem: EnumItem): buffer
	if enumItemCache[enumItem] then
		return enumItemCache[enumItem]
	end

	local typeBuffer = buffer.fromstring(tostring(enumItem.EnumType))

	local _buffer = buffer.create(1 + buffer.len(typeBuffer))
	buffer.writei8(_buffer, 0, enumItem.Value)
	buffer.copy(_buffer, 1, typeBuffer)

	enumItemCache[enumItem] = _buffer

	return _buffer
end

local function deserialize(_buffer: buffer): EnumItem
	local typeBuffer = buffer.create(buffer.len(_buffer) - 1)
	buffer.copy(typeBuffer, 0, _buffer, 1)

	local _type = buffer.tostring(typeBuffer)
	local value = buffer.readi8(_buffer, 0)

	return enumMap[_type][value]
end

return {
	serialize = serialize,
	deserialize = deserialize,

	id = 17,
}
