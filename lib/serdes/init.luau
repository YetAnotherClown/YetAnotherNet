local array = require(script.datatypes.custom.array)
local dictionary = require(script.datatypes.custom.dictionary)

local boolean = require(script.datatypes.primitive.boolean)
local number = require(script.datatypes.primitive.number)
local _string = require(script.datatypes.primitive.string)

local BrickColor = require(script.datatypes.userdata.BrickColor)
local CFrame = require(script.datatypes.userdata.CFrame)
local Color3 = require(script.datatypes.userdata.Color3)
local DateTime = require(script.datatypes.userdata.DateTime)
local EnumItem = require(script.datatypes.userdata.EnumItem)
local Instance = require(script.datatypes.userdata.Instance)
local Rect = require(script.datatypes.userdata.Rect)
local Region3 = require(script.datatypes.userdata.Region3)
local Region3int16 = require(script.datatypes.userdata.Region3int16)
local TweenInfo = require(script.datatypes.userdata.TweenInfo)
local UDim = require(script.datatypes.userdata.UDim)
local UDim2 = require(script.datatypes.userdata.UDim2)
local Vector2 = require(script.datatypes.userdata.Vector2)
local Vector2int16 = require(script.datatypes.userdata.Vector2int16)
local Vector3 = require(script.datatypes.userdata.Vector3)
local Vector3int16 = require(script.datatypes.userdata.Vector3int16)

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
