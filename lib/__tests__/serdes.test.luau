local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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
	identifier = 1,
	boolean = true,
	number = 22,
	string = "Hello, world!",
	BrickColor = BrickColor.Yellow(),
	CFrame = CFrame.new(Vector3.new(20, 40, 60)) * CFrame.fromEulerAnglesXYZ(math.rad(45), math.rad(90), math.rad(180)),
	Color3 = Color3.fromHex("54bbff"),
	DateTime = DateTime.fromUnixTimestampMillis(1686894720000),
	EnumItem = Enum.Genre.Scary,
	Instance = Instance.new("Part"),
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

local customTests = {
	"buffer",
}

describe("Ser/Des", function()
	describe("Serialization and Deserialization should return exact value", function()
		for _, module in root.serdes.datatypes:GetDescendants() do
			if not module:IsA("ModuleScript") then
				continue
			end

			if not typeToValue[module.Name] then
				if table.find(customTests, module.Name) then
					continue
				end

				test.todo(module.Name)
				continue
			end

			test(module.Name, function()
				local serdes = require(module) :: any

				local _buffer = serdes.serialize(typeToValue[module.Name])
				local value = serdes.deserialize(_buffer)

				expect(value).toEqual(typeToValue[module.Name])
			end)
		end
	end)

	test("Array should return nil when failing serialization", function()
		local part = Instance.new("Part")
		part.Anchored = true
		part.Position = Vector3.new(0, 3, 0)
		part.Parent = Workspace

		-- RaycastResults have no constructor, meaning we can't deserialize it
		local raycastResult = Workspace:Raycast(Vector3.zero, Vector3.new(0, 5, 0))

		local serdes = require(root.serdes.datatypes.custom.array)
		local array: { any } = {
			1,
			true,
			raycastResult,
		}

		part:Destroy()

		local _buffer = serdes.serialize(array)
		expect(_buffer).toBeNil()
	end)

	test("Array should be able to serialize/deserialize empty arrays", function()
		local serdes = require(root.serdes.datatypes.custom.array)
		local array = {}

		local _buffer = serdes.serialize(array)
		expect(_buffer).toEqual(expect.any("buffer"))

		local value = serdes.deserialize(_buffer)
		expect(value).toEqual(array)
	end)

	test("Dictionary should return nil when failing serialization", function()
		local part = Instance.new("Part")
		part.Anchored = true
		part.Position = Vector3.new(0, 3, 0)
		part.Parent = Workspace

		-- RaycastResults have no constructor, meaning we can't deserialize it
		local raycastResult = Workspace:Raycast(Vector3.zero, Vector3.new(0, 5, 0))

		local serdes = require(root.serdes.datatypes.custom.dictionary)
		local dictionary = {
			a = 1,
			b = true,
			c = raycastResult,
		}

		part:Destroy()

		local _buffer = serdes.serialize(dictionary)
		expect(_buffer).toBeNil()
	end)
end)
