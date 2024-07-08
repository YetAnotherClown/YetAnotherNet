local array = require("@serdes/datatypes/custom/array")
local dictionary = require("@serdes/datatypes/custom/dictionary")

local boolean = require("@serdes/datatypes/primitive/boolean")
local number = require("@serdes/datatypes/primitive/number")
local _string = require("@serdes/datatypes/primitive/string")

local BrickColor = require("@serdes/datatypes/userdata/BrickColor")
local CFrame = require("@serdes/datatypes/userdata/CFrame")
local Color3 = require("@serdes/datatypes/userdata/Color3")
local DateTime = require("@serdes/datatypes/userdata/DateTime")
local EnumItem = require("@serdes/datatypes/userdata/EnumItem")
local Instance = require("@serdes/datatypes/userdata/Instance")
local Rect = require("@serdes/datatypes/userdata/Rect")
local Region3 = require("@serdes/datatypes/userdata/Region3")
local Region3int16 = require("@serdes/datatypes/userdata/Region3int16")
local TweenInfo = require("@serdes/datatypes/userdata/TweenInfo")
local UDim = require("@serdes/datatypes/userdata/UDim")
local UDim2 = require("@serdes/datatypes/userdata/UDim2")
local Vector2 = require("@serdes/datatypes/userdata/Vector2")
local Vector2int16 = require("@serdes/datatypes/userdata/Vector2int16")
local Vector3 = require("@serdes/datatypes/userdata/Vector3")
local Vector3int16 = require("@serdes/datatypes/userdata/Vector3int16")

return {
	array = array,
	dictionary = dictionary,

	boolean = boolean,
	number = number,
	string = _string,

	BrickColor = BrickColor,
	CFrame = CFrame,
	Color3 = Color3,
	DateTime = DateTime,
	EnumItem = EnumItem,
	Instance = Instance,
	Rect = Rect,
	Region3 = Region3,
	Region3int16 = Region3int16,
	TweenInfo = TweenInfo,
	UDim = UDim,
	UDim2 = UDim2,
	Vector2 = Vector2,
	Vector2int16 = Vector2int16,
	Vector3 = Vector3,
	Vector3int16 = Vector3int16,
}
