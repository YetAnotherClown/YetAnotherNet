--!native

local enumItem = require("@serdes/datatypes/userdata/EnumItem")
local number = require("@serdes/datatypes/primitive/number")
local boolean = require("@serdes/datatypes/primitive/boolean")
local _string = require("@serdes/datatypes/primitive/string")

local PARTIAL_BUFFER_SIZE = (number.size * 3) + boolean.size

local function serialize(tweenInfo: TweenInfo): buffer
	local time = number.serialize(tweenInfo.Time)
	local delayTime = number.serialize(tweenInfo.DelayTime)
	local repeatCount = number.serialize(tweenInfo.RepeatCount)
	local reverses = boolean.serialize(tweenInfo.Reverses)
	local easingDirection = enumItem.serialize(tweenInfo.EasingDirection)
	local easingStyle = enumItem.serialize(tweenInfo.EasingStyle)

	local _buffer = buffer.create(
		PARTIAL_BUFFER_SIZE + 8 + buffer.len(easingDirection) + buffer.len(easingStyle)
	)

	buffer.copy(_buffer, 0, time, 0, number.size)
	buffer.copy(_buffer, number.size, delayTime, 0, number.size)
	buffer.copy(_buffer, number.size * 2, repeatCount, 0, number.size)
	buffer.copy(_buffer, number.size * 3, reverses, 0, boolean.size)

	local cursor = PARTIAL_BUFFER_SIZE

	local easingDirectionSizeBuffer = buffer.create(4)
	buffer.writeu32(easingDirectionSizeBuffer, 0, buffer.len(easingDirection))

	buffer.copy(_buffer, cursor, easingDirectionSizeBuffer)
	cursor += buffer.len(easingDirectionSizeBuffer)

	buffer.copy(_buffer, cursor, easingDirection)
	cursor += buffer.len(easingDirection)

	local easingStyleSizeBuffer = buffer.create(4)
	buffer.writeu32(easingStyleSizeBuffer, 0, buffer.len(easingStyle))

	buffer.copy(_buffer, cursor, easingStyleSizeBuffer)
	cursor += buffer.len(easingStyleSizeBuffer)

	buffer.copy(_buffer, cursor, easingStyle)
	cursor += buffer.len(easingStyle)

	return _buffer
end

local function deserialize(_buffer: buffer): TweenInfo
	local timeBuffer = buffer.create(number.size)
	local delayTimeBuffer = buffer.create(number.size)
	local repeatCountBuffer = buffer.create(number.size)
	local reversesBuffer = buffer.create(boolean.size)

	buffer.copy(timeBuffer, 0, _buffer, 0, number.size)
	buffer.copy(delayTimeBuffer, 0, _buffer, number.size, number.size)
	buffer.copy(repeatCountBuffer, 0, _buffer, number.size * 2, number.size)
	buffer.copy(reversesBuffer, 0, _buffer, number.size * 3, boolean.size)

	local cursor = PARTIAL_BUFFER_SIZE

	local easingDirectionSizeBuffer = buffer.create(4)
	buffer.copy(easingDirectionSizeBuffer, 0, _buffer, cursor, 4)
	cursor += 4

	local easingDirectionSize = buffer.readu32(easingDirectionSizeBuffer, 0)

	local easingDirectionBuffer = buffer.create(easingDirectionSize)
	buffer.copy(easingDirectionBuffer, 0, _buffer, cursor, easingDirectionSize)
	cursor += buffer.len(easingDirectionBuffer)

	local easingStyleSizeBuffer = buffer.create(4)
	buffer.copy(easingStyleSizeBuffer, 0, _buffer, cursor, 4)
	cursor += 4

	local easingStyleSize = buffer.readu32(easingStyleSizeBuffer, 0)

	local easingStyleBuffer = buffer.create(easingStyleSize)
	buffer.copy(easingStyleBuffer, 0, _buffer, cursor, easingStyleSize)
	cursor += buffer.len(easingStyleBuffer)

	local time = number.deserialize(timeBuffer)
	local delayTime = number.deserialize(delayTimeBuffer)
	local repeatCount = number.deserialize(repeatCountBuffer)
	local reverses = boolean.deserialize(reversesBuffer)
	local easingDirection = enumItem.deserialize(easingDirectionBuffer) :: Enum.EasingDirection
	local easingStyle = enumItem.deserialize(easingStyleBuffer) :: Enum.EasingStyle

	return TweenInfo.new(time, easingStyle, easingDirection, repeatCount, reverses, delayTime)
end

return {
	serialize = serialize,
	deserialize = deserialize,

	id = 42,
}
