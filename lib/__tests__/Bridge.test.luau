local JestGlobals = require("@dev-packages/JestGlobals")
local Bridge = require("@yetanothernet/Bridge")
local beforeAll = JestGlobals.beforeAll
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test
local jest = JestGlobals.jest

local root = script.Parent.Parent
local BridgeModule = root.Bridge

local mockPlayers = require("@yetanothernet/__utils__/mockPlayers")
local mockBridge = require("@yetanothernet/__mocks__/mockBridge")

local Identifier = require("@yetanothernet/Identifier")

local MockedBridge

local serverBridge
local clientBridge
local player

local globalIdentifier = Identifier.new()

function queueFakePackets(bridge: any, mockPlayer: any, ...)
	local channel = "Reliable"

	local queue = {
		{
			channel = "Reliable",
			identifier = globalIdentifier,
			recipient = mockPlayer,
			data = { 1, 2, 3 },
		},
		...,
	}

	for _, packet in queue do
		table.insert(bridge._outgoingQueue[channel], packet)
	end
end

describe("Bridge", function()
	beforeAll(function()
		jest.mock(BridgeModule, mockBridge)
		MockedBridge = require(BridgeModule) :: mockBridge.MockedBridge

		player = mockPlayers.createPlayer()
		clientBridge = MockedBridge.new("client", player)

		serverBridge = MockedBridge.new("server")
	end)

	test("Should work across the Client-Server Boundary", function()
		MockedBridge = require(BridgeModule) :: mockBridge.MockedBridge

		queueFakePackets(serverBridge, player)

		serverBridge:step()
		clientBridge:step()

		local snapshot = clientBridge:snapshot()

		expect(snapshot["Reliable"][1]).toEqual({
			data = { 1, 2, 3 },
			identifier = globalIdentifier,
			sender = "NET_SERVER",
		})
	end)

	test("When called, `_processOutgoingQueue` should properly package Client/Server payloads", function()
		MockedBridge = require(BridgeModule) :: mockBridge.MockedBridge

		local identifier = Identifier.new()

		local fakeClientPacket = {
			channel = "Reliable",
			identifier = identifier,
			recipient = serverBridge.server,
			data = { "a", "b", "c" },
		}

		-- Fill the outgoingQueue with fake packets
		queueFakePackets(serverBridge, player, fakeClientPacket)

		local clientPayloads: { [any]: any }, serverPayloads = serverBridge:_processOutgoingQueue()

		-- Check client payloads
		expect(clientPayloads[player].Reliable).toEqual(expect.objectContaining({
			[globalIdentifier] = {
				{ 1, 2, 3 },
			},
		}))

		-- Check server payloads
		expect(serverPayloads.Reliable).toEqual(expect.objectContaining({
			[fakeClientPacket.identifier] = { fakeClientPacket.data },
		}))
	end)

	describe("Should send payloads to their appropriate Channel and Recipient on the Client", function()
		test("Client -> Server", function()
			local identifier = Identifier.new()

			local packet = {
				channel = "Reliable",
				identifier = identifier,
				recipient = Bridge.server,
				data = { "a", "b", "c" },
			} :: Bridge.OutgoingPacket

			-- Add to the queue
			table.insert(clientBridge._outgoingQueue.Reliable, packet)

			-- Process and send payloads
			local clientPayloads, serverPayloads = clientBridge:_processOutgoingQueue()
			clientBridge:_sendPayloads(clientPayloads, serverPayloads)

			-- Find the packet in the queue
			expect(serverBridge._incomingQueue.Reliable).toEqual(expect.arrayContaining({
				{
					identifier = packet.identifier,
					sender = player,
					data = packet.data,
				},
			}))
		end)

		test("Server -> Client", function()
			local identifier = Identifier.new()

			local packet = {
				channel = "Reliable",
				identifier = identifier,
				recipient = player,
				data = { "a", "b", "c" },
			} :: Bridge.OutgoingPacket

			-- Add to the queue
			table.insert(serverBridge._outgoingQueue.Reliable, packet)

			-- Process and send payloads
			local clientPayloads, serverPayloads = serverBridge:_processOutgoingQueue()
			serverBridge:_sendPayloads(clientPayloads, serverPayloads)

			-- Find the packet in the queue
			expect(clientBridge._incomingQueue.Reliable).toEqual(expect.arrayContaining({
				{
					identifier = packet.identifier,
					sender = serverBridge.server,
					data = packet.data,
				},
			}))
		end)
	end)

	test("Should not send empty payloads", function()
		-- Clear queue
		clientBridge:step()

		-- Track whether or not the RemoteEvent was fired
		local wasFired = false
		clientBridge.reliableChannel.OnClientEvent:Connect(function()
			wasFired = true
		end)

		-- Send empty payload
		local clientPayloads, serverPayloads = serverBridge:_processOutgoingQueue()
		serverBridge:_sendPayloads(clientPayloads, serverPayloads)

		expect(clientBridge._incomingQueue.Reliable).toEqual({})
		expect(wasFired).toBe(false)
	end)

	describe("Ser/Des Integration", function()
		test("Should provide an Instance map when serializing Instances", function()
			MockedBridge = require(BridgeModule) :: mockBridge.MockedBridge

			local identifier = Identifier.new()

			local instance = Instance.new("Part")

			table.insert(serverBridge._outgoingQueue["Reliable"], {
				channel = "Reliable",
				identifier = identifier,
				recipient = player,
				data = { instance },
			})

			serverBridge:step()
			clientBridge:step()

			expect(clientBridge._instanceMap).toContain(instance)

			local snapshot = clientBridge:snapshot()

			expect(snapshot["Reliable"][1]).toEqual({
				identifier = identifier,
				sender = "NET_SERVER",
				data = { instance },
			})
		end)
	end)
end)
