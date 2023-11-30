export type Identifier = string

-- Map our indices to our compressed identifiers
local identifiers = {}
local uniquePositions = 0

-- Create or Retrieve a Identifier represented as "binary"
return function(index: string, pos: number?): Identifier
	-- Return existing Identifiers
	if identifiers[index] then
		return identifiers[index]
	end

	if not pos then
		uniquePositions += 1
		pos = uniquePositions
	end

	-- Create a new Identifier
	local identifier = string.pack("B", pos)
	identifiers[index] = identifier

	return identifiers[index]
end
