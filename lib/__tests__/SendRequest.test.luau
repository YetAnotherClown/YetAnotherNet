local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Identifier = require(ReplicatedStorage.Packages.Net.Identifier)
local describe = JestGlobals.describe
local test = JestGlobals.test

local root = script.Parent.Parent
local SendRequest = require(root.SendRequest)

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
