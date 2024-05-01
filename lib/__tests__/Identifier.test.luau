local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local Identifier = require(script.Parent.Parent.Identifier)

describe("Identifier", function()
	it("Should return unique strings", function()
		local identifierOne = Identifier.new()
		local identifierTwo = Identifier.new()

		expect(identifierOne).never.toEqual(identifierTwo)
	end)

	it("Should have the correct position when a position is given", function()
		local identifierThree = Identifier.new(1)
		local _identifierFour = Identifier.new(2)
		local identifierFive = Identifier.new(1)

		expect(identifierThree).toEqual(identifierFive)
	end)
end)
