--!native

local BUFFER_SIZE = 1

local _true = buffer.create(BUFFER_SIZE)
buffer.writei8(_true, 0, 1)

local _false = buffer.create(BUFFER_SIZE)
buffer.writei8(_false, 0, 0)

local _nil = buffer.create(BUFFER_SIZE)
buffer.writei8(_nil, 0, -1)

local function serialize(bool: boolean?): buffer
	if bool == true then
		return _true
	elseif bool == false then
		return _false
	else
		return _nil
	end
end

local function deserialize(_buffer: buffer): boolean?
	local number = buffer.readi8(_buffer, 0)
	return if number == 1 then true elseif number == 0 then false else nil
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,

	id = 3,
}
