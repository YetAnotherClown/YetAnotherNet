local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local test = JestGlobals.test

local root = script.Parent.Parent

local typeToValue = {
	array = { 1, 2, 3 },
	dictionary = {
		a = 1,
		b = 2,
		c = 3,
	},
	boolean = true,
	number = 22,
	string = "Hello, world!",
	BrickColor = BrickColor.Yellow(),
	CFrame = CFrame.new(Vector3.new(20, 40, 60)) * CFrame.fromEulerAnglesXYZ(math.rad(45), math.rad(90), math.rad(180)),
	Color3 = Color3.fromHex("54bbff"),
	DateTime = DateTime.fromUnixTimestampMillis(1686894720000),
	EnumItem = Enum.Genre.Scary,
	Rect = Rect.new(Vector2.new(10, 20), Vector2.new(40, 80)),
	Region3 = Region3.new(Vector3.zero, Vector3.new(30, 30, 30)),
	Region3int16 = Region3int16.new(Vector3int16.new(0, 0, 0), Vector3int16.new(30, 30, 30)),
	TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true, 5),
	UDim = UDim.new(0.5, 10),
	UDim2 = UDim2.new(UDim.new(0.1, 10), UDim.new(0.7, 30)),
	Vector2 = Vector2.new(10, 20),
	Vector2int16 = Vector2int16.new(30, 60),
	Vector3 = Vector3.new(20, 40, 60),
	Vector3int16 = Vector3int16.new(40, 80, 120),
}

describe.only("Ser/Des", function()
	for _, module in root.serdes.datatypes:GetDescendants() do
		if not module:IsA("ModuleScript") then
			continue
		end

		if not typeToValue[module.Name] then
			test.todo(module.Name)
		end

		test(module.Name, function()
			local serdes = require(module) :: any

			local _buffer = serdes.serialize(typeToValue[module.Name])
			local value = serdes.deserialize(_buffer)

			expect(value).toEqual(typeToValue[module.Name])
		end)
	end
end)
