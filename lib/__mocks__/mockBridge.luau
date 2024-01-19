--!nonstrict
local root = script.Parent.Parent
local Bridge = require(root.Bridge)

local utils = root.__utils__
local mockRemoteEvents = require(utils.mockRemoteEvents)
local mockPlayers = require(utils.mockPlayers)

export type MockedBridge = Bridge.Bridge & MockedBridgeImpl & {
	_owner: any,
	context: "server" | "client",
}

export type MockedBridgeImpl = Bridge.BridgeImpl & {
	context: "server" | "client",
	_initializeRemotes: (self: MockedBridge) -> (),
	new: (context: "server" | "client", owner: any) -> MockedBridge,
}

local n = 0

local mockedModule = table.clone(Bridge) :: MockedBridgeImpl
mockedModule.__index = mockedModule

function mockedModule:getContext()
	return self.context
end

function mockedModule:isPlayer(player)
	if table.find(mockPlayers.getAllPlayers(), player) then
		return true
	end

	return false
end

function mockedModule:_initializeRemotes()
	local identifier = tostring(n)

	if self:getContext() == "server" then
		self.reliableRemote = mockRemoteEvents.ServerRemoteEvent.new(tostring(identifier), "Reliable")
		self.unreliableRemote = mockRemoteEvents.ServerRemoteEvent.new(tostring(identifier), "Unreliable")

		self.reliableRemote.OnServerEvent:Connect(function(player, package)
			self:_processIncoming("Reliable", player, package)
		end)
		self.unreliableRemote.OnServerEvent:Connect(function(player, package)
			self:_processIncoming("Unreliable", player, package)
		end)
	elseif self:getContext() == "client" then
		self.reliableRemote = mockRemoteEvents.ClientRemoteEvent.new(self._owner, tostring(identifier), "Reliable")
		self.unreliableRemote = mockRemoteEvents.ClientRemoteEvent.new(self._owner, tostring(identifier), "Unreliable")

		self.reliableRemote.OnClientEvent:Connect(function(package)
			self:_processIncoming("Reliable", "NET_SERVER", package)
		end)
		self.unreliableRemote.OnClientEvent:Connect(function(package)
			self:_processIncoming("Unreliable", "NET_SERVER", package)
		end)
	end
end

function mockedModule.new(context: "client" | "server", owner: any)
	local self = {}
	setmetatable(self, mockedModule)

	self.context = context
	self._owner = owner

	self._incomingQueue = { Reliable = {}, Unreliable = {} } :: Bridge.IncomingQueue
	self._snapshot = { Reliable = {}, Unreliable = {} } :: Bridge.IncomingQueue

	self._outgoingQueue = { Reliable = {}, Unreliable = {} } :: Bridge.OutgoingQueue

	self:_initializeRemotes()

	return self
end

return function()
	n += 1
	return mockedModule
end
