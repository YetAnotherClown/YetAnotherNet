local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test
local it = JestGlobals.it

local root = script.Parent.Parent
local QueryResult = require(root.QueryResult)

local utils = root.__utils__
local mockPlayers = require(utils.mockPlayers)

describe("QueryResult", function()
	test("When iterating, should return all expected values", function()
		local snapshot = {
			{
				data = { 1, 2, 3 },
				identifier = "Jest",
				sender = "NET_SERVER" :: "NET_SERVER",
			},
		}

		local result = QueryResult.new(snapshot, "Jest")
		for i, sender, num1, num2, num3 in result do
			expect(i).toEqual(1)
			expect(sender).toEqual("NET_SERVER")
			expect(num1).toEqual(1)
			expect(num2).toEqual(2)
			expect(num3).toEqual(3)
		end
	end)

	test("When calling `from()`, should query for the sender", function()
		local snapshot = {
			{
				data = { 1, 2, 3 },
				identifier = "Jest",
				sender = "NET_SERVER" :: "NET_SERVER",
			},
			{
				data = { "a", "b", "c" },
				identifier = "Jest",
				sender = mockPlayers.createPlayer(),
			},
		} :: { any }

		local result = QueryResult.new(snapshot, "Jest")

		local n = 0
		for i, sender, num1, num2, num3 in result:from("NET_SERVER") do
			n += 1

			expect(i).toEqual(n)
			expect(sender).toEqual("NET_SERVER")
			expect(num1).toEqual(1)
			expect(num2).toEqual(2)
			expect(num3).toEqual(3)
		end
	end)

	it("Should respect it's identifier", function()
		local snapshot = {
			{
				data = { 1, 2, 3 },
				identifier = "Jest",
				sender = "NET_SERVER" :: "NET_SERVER",
			},
			{
				data = { "a", "b", "c" },
				identifier = "Wrong",
				sender = "NET_SERVER" :: "NET_SERVER",
			},
		} :: { any }

		local result = QueryResult.new(snapshot, "Jest")

		local n = 0
		for i, sender, num1, num2, num3 in result:from("NET_SERVER") do
			n += 1

			expect(i).toEqual(n)
			expect(sender).toEqual("NET_SERVER")
			expect(num1).toEqual(1)
			expect(num2).toEqual(2)
			expect(num3).toEqual(3)
		end
	end)
end)
