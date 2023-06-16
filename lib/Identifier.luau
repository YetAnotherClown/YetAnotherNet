export type Identifier = string

-- Map our indices to our compressed identifiers
local identifiers = {}

-- Create or Retrieve a Identifier represented as "binary"
return function(index: string, pos: number?): Identifier
    -- Return existing Identifiers
    if identifiers[index] then
        return identifiers[index]
    end

    -- Create a new Identifier
    local identifier = string.pack("B", pos or #identifiers)
	identifiers[index] = identifier

    return identifiers[index]
end