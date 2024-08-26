local JestGlobals = require("@dev-packages/JestGlobals")
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test
local it = JestGlobals.it

local Identifier = require("@yetanothernet/Identifier")
local QueryResult = require("@yetanothernet/QueryResult")

local mockPlayers = require("@yetanothernet/__utils__/mockPlayers")

local identifier = Identifier.new()

describe("QueryResult", function()
	test("When iterating, should return all expected values", function()
		local snapshot = {
			{
				data = { 1, 2, 3 },
				identifier = identifier,
				sender = "NET_SERVER" :: "NET_SERVER",
			},
		}

		local result = QueryResult.new(snapshot, identifier)
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
				identifier = identifier,
				sender = "NET_SERVER" :: "NET_SERVER",
			},
			{
				data = { "a", "b", "c" },
				identifier = identifier,
				sender = mockPlayers.createPlayer(),
			},
		} :: { any }

		local result = QueryResult.new(snapshot, identifier)

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
		local identifier1 = Identifier.new()
		local identifier2 = Identifier.new()

		local snapshot = {
			{
				data = { 1, 2, 3 },
				identifier = identifier1,
				sender = "NET_SERVER" :: "NET_SERVER",
			},
			{
				data = { "a", "b", "c" },
				identifier = identifier2,
				sender = "NET_SERVER" :: "NET_SERVER",
			},
		} :: { any }

		local result = QueryResult.new(snapshot, identifier1)

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

	it("Should not terminate iteration unexpectedly", function()
		local snapshot = {
			{
				data = { 1, 2, 3 },
				identifier = identifier,
				sender = "NET_SERVER" :: "NET_SERVER",
			},
			{
				data = { "a", "b", "c" },
				identifier = Identifier.new(),
				sender = "NET_SERVER" :: "NET_SERVER",
			},
			{
				data = { 4, 6, 7 },
				identifier = identifier,
				sender = "NET_SERVER" :: "NET_SERVER",
			},
		} :: { { data: { any }, identifier: buffer, sender: any } }

		local result = QueryResult.new(snapshot, identifier)

		local n = 0
		for i, sender, num1, num2, num3 in result do
			expect(i).toEqual(expect.any("number"))
			expect(sender).toEqual("NET_SERVER")
			expect(num1).toEqual(expect.any("number"))
			expect(num2).toEqual(expect.any("number"))
			expect(num3).toEqual(expect.any("number"))

			n += 1
		end

		expect(n).toEqual(2)
	end)
end)
