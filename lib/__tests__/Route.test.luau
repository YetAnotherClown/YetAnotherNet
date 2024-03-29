local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(script.Parent.Parent)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local beforeAll = JestGlobals.beforeAll
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
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

local serverRoute
local serverHook

local clientRoute
local clientHook
local mockPlayer

local processHooks

describe("Route", function()
	beforeAll(function()
		jest.mock(BridgeModule, mockBridge)

		MockedBridge = require(BridgeModule) :: mockBridge.MockedBridge

		local function createHook(routes: { Net.Route<...any> }, context: "server" | "client", player: any?)
			local bridge = MockedBridge.new(context, player)

			return function()
				for _, route in routes do
					route:_updateSnapshot(bridge)
					route:_queuePackets(bridge)
				end

				bridge:step()
			end
		end

		-- Setup server

		serverRoute = Net.Route.new({
			Channel = "Reliable",
		}) :: Net.Route<number, boolean, string>

		serverHook = createHook({ serverRoute }, "server")

		-- Setup client

		mockPlayer = mockPlayers.createPlayer()

		clientRoute = Net.Route.new({
			Channel = "Reliable",
		}) :: Net.Route<number, boolean, string>
		clientRoute["_identifier"] = serverRoute["_identifier"]

		clientHook = createHook({ clientRoute }, "client", mockPlayer)

		processHooks = function()
			serverHook()
			clientHook()

			-- To account for data being deferred by one frame
			serverHook()
			clientHook()
		end
	end)

	-- Schedule cleanup
	beforeEach(function()
		processHooks()
	end)

	-- Schedule cleanup
	afterEach(function()
		processHooks()
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
		processHooks()

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

		processHooks()

		local queryResult = clientRoute:query()

		expect(queryResult._identifier).toEqual(serverRoute._identifier)
		expect(queryResult._snapshot).toContainEqual({
			identifier = serverRoute._identifier,
			sender = Net.server,
			data = { 1, true, "Hello, world" } :: { any },
		})
	end)

	test("Outgoing Middleware should overwrite each packet's data", function()
		clientRoute:addOutgoingMiddleware(function(num, bool, str)
			local returnValues = {} :: { any }

			table.insert(returnValues, if typeof(num) ~= "number" then 1 else num)
			table.insert(returnValues, if typeof(bool) ~= "boolean" then true else bool)
			table.insert(returnValues, if typeof(str) ~= "string" then "Hello, world" else str)

			return table.unpack(returnValues)
		end)

		-- Send incorrect values
		local sendRequest = serverRoute:send(false :: any, "Oops" :: any, 1 :: any)
		sendRequest:to(mockPlayer)

		processHooks()

		local queryResult = clientRoute:query()

		expect(queryResult._identifier).toEqual(serverRoute._identifier)
		expect(queryResult._snapshot).toContainEqual({
			identifier = serverRoute._identifier,
			sender = Net.server,
			data = { 1, true, "Hello, world" } :: { any },
		})
	end)
end)
