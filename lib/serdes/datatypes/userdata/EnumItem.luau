--!native

local function serialize(enumItem: EnumItem): buffer
	local typeBuffer = buffer.fromstring(tostring(enumItem.EnumType))

	local _buffer = buffer.create(1 + buffer.len(typeBuffer))
	buffer.writei8(_buffer, 0, enumItem.Value)
	buffer.copy(_buffer, 1, typeBuffer)

	return _buffer
end

local function deserialize(_buffer: buffer): EnumItem
	local typeBuffer = buffer.create(buffer.len(_buffer) - 1)
	buffer.copy(typeBuffer, 0, _buffer, 1)

	local _type = buffer.tostring(typeBuffer)
	local value = buffer.readi8(_buffer, 0)
	local enumItem

	for _, enum in Enum:GetEnums() do
		for _, _enumItem in enum:GetEnumItems() do
			if tostring(_enumItem.EnumType) == _type and _enumItem.Value == value then
				enumItem = _enumItem
			end
		end
	end

	return enumItem
end

return {
	serialize = serialize,
	deserialize = deserialize,

	id = 17,
}
