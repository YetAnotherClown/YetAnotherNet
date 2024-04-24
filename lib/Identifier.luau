local identifier = require(script.Parent.serdes.datatypes.custom.identifier)
export type Identifier = buffer

local function new(uniquePosition: number?): buffer
	return identifier.serialize(uniquePosition)
end

local function read(_buffer: buffer): number
	return identifier.deserialize(_buffer)
end

return {
	new = new,
	read = read,
}
