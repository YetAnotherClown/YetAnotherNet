--!native

local BUFFER_SIZE = 8

local function serialize(dateTime: DateTime): buffer
	local _buffer = buffer.create(BUFFER_SIZE)
	buffer.writef64(_buffer, 0, dateTime.UnixTimestampMillis)
	return _buffer
end

local function deserialize(_buffer: buffer): DateTime
	return DateTime.fromUnixTimestampMillis(buffer.readf64(_buffer, 0))
end

return {
	serialize = serialize,
	deserialize = deserialize,

	size = BUFFER_SIZE,
	id = 14,
}
