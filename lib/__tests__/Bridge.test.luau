local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Bridge = require(ReplicatedStorage.Packages.Net.Bridge)
local beforeAll = JestGlobals.beforeAll
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test
local jest = JestGlobals.jest

local root = script.Parent.Parent
local BridgeModule = root.Bridge

local utils = root.__utils__
local mockPlayers = require(utils.mockPlayers)

local mocks = script.Parent.Parent.__mocks__
local mockBridge = require(mocks.mockBridge)

local MockedBridge

local serverBridge
local clientBridge
local player

function queueFakePackets(bridge: any, mockPlayer: any, ...)
	local channel = "Reliable"

	local queue = {
		{
			channel = "Reliable",
			identifier = "Jest",
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
			identifier = "Jest",
			sender = "NET_SERVER",
		})
	end)

	test("When called, `_processOutgoingQueue` should properly package Client/Server payloads", function()
		MockedBridge = require(BridgeModule) :: mockBridge.MockedBridge

		local fakeClientPacket = {
			channel = "Reliable",
			identifier = "PayloadTest",
			recipient = serverBridge.server,
			data = { "a", "b", "c" },
		}

		-- Fill the outgoingQueue with fake packets
		queueFakePackets(serverBridge, player, fakeClientPacket)

		local clientPayloads: { [any]: any }, serverPayloads = serverBridge:_processOutgoingQueue()

		-- Check client payloads
		expect(clientPayloads[player].Reliable).toEqual(expect.objectContaining({
			Jest = {
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
			local packet = {
				channel = "Reliable",
				identifier = "OutgoingQueueTest",
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
			local packet = {
				channel = "Reliable",
				identifier = "OutgoingQueueTest",
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
end)
