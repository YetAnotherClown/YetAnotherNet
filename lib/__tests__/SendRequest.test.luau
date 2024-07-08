local JestGlobals = require("@dev-packages/JestGlobals")
local describe = JestGlobals.describe
local test = JestGlobals.test

local Identifier = require("@yetanothernet/Identifier")
local SendRequest = require("@yetanothernet/SendRequest")

describe("SendRequest", function()
	test("When calling `to()`, should modify the recipient", function()
		local outgoingQueue = {}

		local identifier = Identifier.new()

		local packet = {
			channel = "Reliable",
			data = { 1, 2, 3 },
			identifier = identifier,
			recipient = nil,
		}
		table.insert(outgoingQueue, packet)

		local sendRequest = {
			_outgoingQueue = outgoingQueue,
			_position = #outgoingQueue,
		}
		setmetatable(sendRequest, SendRequest)
	end)
end)
