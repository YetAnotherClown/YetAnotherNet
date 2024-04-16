--!native

local BUFFER_SIZE = 4

local nextIdentifer = 1
local instanceMap = {}

local function setIdentifier(identifier: number, instance: Instance)
	instanceMap[identifier] = instance
	nextIdentifer += 1
end

local function getInstanceMap()
	return table.freeze(table.clone(instanceMap))
end

local function serialize(instance: Instance): (buffer, number)
	local identifier = nextIdentifer
	setIdentifier(identifier, instance)

	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writeu32(_buffer, 0, identifier)

	return _buffer, identifier
end

local function deserialize(_buffer: buffer): Instance
	local identifier = buffer.readu32(_buffer, 0)
	return instanceMap[identifier]
end

return {
	serialize = serialize,
	deserialize = deserialize,
	setIdentifier = setIdentifier,
	getInstanceMap = getInstanceMap,

	size = BUFFER_SIZE,
	id = 22,
}
