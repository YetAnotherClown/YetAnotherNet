local Net = require("@yetanothernet")
local JestGlobals = require("@dev-packages/JestGlobals")
local beforeAll = JestGlobals.beforeAll
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test
local jest = JestGlobals.jest

local root = script.Parent.Parent
local BridgeModule = root.Bridge

local mockPlayers = require("@yetanothernet/__utils__/mockPlayers")
local mockBridge = require("@yetanothernet/__mocks__/mockBridge")

local MockedBridge

local serverRoute
local serverBeginFrame
local serverEndFrame

local clientRoute
local clientBeginFrame
local clientEndFrame
local mockPlayer

local beginFrame
local endFrame

describe("Route", function()
	beforeAll(function()
		jest.mock(BridgeModule, mockBridge)

		MockedBridge = require(BridgeModule) :: mockBridge.MockedBridge

		local function createHook(
			routes: { Net.Route<...any> },
			context: "server" | "client",
			player: any?
		)
			local bridge = MockedBridge.new(context, player)

			local function beginFrameFn()
				bridge:beginFrame()

				for _, route in routes do
					route:_updateSnapshot(bridge)
				end
			end

			local function endFrameFn()
				for _, route in routes do
					route:_queuePackets(bridge)
				end

				bridge:endFrame()
			end

			return beginFrameFn, endFrameFn
		end

		-- Setup server

		serverRoute = Net.Route.new({
			Channel = "Reliable",
		}) :: Net.Route<number, boolean, string>

		serverBeginFrame, serverEndFrame = createHook({ serverRoute }, "server")

		-- Setup client

		mockPlayer = mockPlayers.createPlayer()

		clientRoute = Net.Route.new({
			Channel = "Reliable",
		}) :: Net.Route<number, boolean, string>
		clientRoute["_identifier"] = serverRoute["_identifier"]

		clientBeginFrame, clientEndFrame = createHook({ clientRoute }, "client", mockPlayer)

		beginFrame = function()
			serverBeginFrame()
			clientBeginFrame()
		end

		endFrame = function()
			serverEndFrame()
			clientEndFrame()
		end
	end)

	-- Schedule cleanup
	beforeEach(function()
		beginFrame()
	end)

	-- Schedule cleanup
	afterEach(function()
		endFrame()
	end)

	test("When calling `:send()`, it should properly queue the packets to it's bridge", function()
		local sendRequest = serverRoute:send(1, true, "Hello, world")
		sendRequest:to(mockPlayer)

		expect(sendRequest._outgoingQueue).toEqual(serverRoute._outgoingQueue)
		expect(sendRequest._outgoingQueue[sendRequest._position]).toEqual({
			recipient = mockPlayer,
			data = { 1, true, "Hello, world" } :: { any },
		})
	end)

	test("When calling `:query()`, it should return a valid QueryResult", function()
		local sendRequest = serverRoute:send(1, true, "Hello, world")
		sendRequest:to(mockPlayer)

		endFrame()
		beginFrame()

		local queryResult = clientRoute:query()

		expect(queryResult._identifier).toEqual(serverRoute._identifier)
		expect(queryResult._snapshot).toContainEqual({
			identifier = serverRoute._identifier,
			sender = Net.server,
			data = { 1, true, "Hello, world" } :: { any },
		})
	end)

	test("Incoming Middleware should overwrite each packet's data", function()
		clientRoute:addIncomingMiddleware(function(num, bool, str)
			local returnValues = {} :: { any }

			table.insert(returnValues, if typeof(num) ~= "number" then 1 else num)
			table.insert(returnValues, if typeof(bool) ~= "boolean" then true else bool)
			table.insert(returnValues, if typeof(str) ~= "string" then "Hello, world" else str)

			return table.unpack(returnValues)
		end)

		-- Send incorrect values
		local sendRequest = serverRoute:send(false :: any, "Oops" :: any, 1 :: any)
		sendRequest:to(mockPlayer)

		endFrame()
		beginFrame()

		local queryResult = clientRoute:query()

		expect(queryResult._identifier).toEqual(serverRoute._identifier)
		expect(queryResult._snapshot).toContainEqual({
			identifier = serverRoute._identifier,
			sender = Net.server,
			data = { 1, true, "Hello, world" } :: { any },
		})
	end)

	test("Outgoing Middleware should overwrite each packet's data", function()
		serverRoute:addOutgoingMiddleware(function(num, bool, str)
			local returnValues = {} :: { any }

			table.insert(returnValues, if typeof(num) ~= "number" then 1 else num)
			table.insert(returnValues, if typeof(bool) ~= "boolean" then true else bool)
			table.insert(returnValues, if typeof(str) ~= "string" then "Hello, world" else str)

			return table.unpack(returnValues)
		end)

		-- Send incorrect values
		local sendRequest = serverRoute:send(false :: any, "Oops" :: any, 1 :: any)
		sendRequest:to(mockPlayer)

		endFrame()
		beginFrame()

		local queryResult = clientRoute:query()

		expect(queryResult._identifier).toEqual(serverRoute._identifier)
		expect(queryResult._snapshot).toContainEqual({
			identifier = serverRoute._identifier,
			sender = Net.server,
			data = { 1, true, "Hello, world" } :: { any },
		})
	end)

	test("Should process connections", function()
		local seenConnection = false

		Net.createConnection(clientRoute, function(i, sender, num, bool, str)
			expect(i).toEqual(1)
			expect(sender).toEqual("NET_SERVER")
			expect(num).toEqual(1)
			expect(bool).toEqual(true)
			expect(str).toEqual("Hello, world")

			seenConnection = true
		end)

		local sendRequest = serverRoute:send(1, true, "Hello, world")
		sendRequest:to(mockPlayer)

		endFrame()
		beginFrame()

		clientRoute:_processConnections()
		expect(seenConnection).toEqual(true)
	end)
end)
