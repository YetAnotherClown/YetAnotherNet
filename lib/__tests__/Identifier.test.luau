local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local newIdentifier = require(script.Parent.Parent.Identifier)

describe("Identifier", function()
	it("Should return unique strings", function()
		local identifierOne = newIdentifier("identifierOne")
		local identifierTwo = newIdentifier("identifierTwo")

		expect(identifierOne ~= identifierTwo).toEqual(true)
	end)

	it("Should have the correct position when a position is given", function()
		local identifierThree = newIdentifier("identifierThree", 1)
		local _identifierFour = newIdentifier("identifierFour", 2)
		local identifierFive = newIdentifier("identifierFive", 1)

		expect(identifierThree == identifierFive).toEqual(true)
	end)

	it("Should return existing identifiers", function()
		local identifierSix = newIdentifier("identifierSix")
		local identifierSeven = newIdentifier("identifierSix")

		expect(identifierSix == identifierSeven).toEqual(true)
	end)
end)
