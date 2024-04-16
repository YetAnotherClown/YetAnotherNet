--!nonstrict
local root = script.Parent.Parent
local Bridge = require(root.Bridge)

local utils = root.__utils__
local mockRemoteEvents = require(utils.mockRemoteEvents)
local mockPlayers = require(utils.mockPlayers)

local ServerRemoteEvent = mockRemoteEvents.ServerRemoteEvent
local ClientRemoteEvent = mockRemoteEvents.ClientRemoteEvent

local n = 0

local mockedModule = table.clone(Bridge)
mockedModule.__index = mockedModule

function mockedModule:_getContext()
	return self.context
end

function mockedModule:_isPlayer(player)
	if table.find(mockPlayers.getAllPlayers(), player) then
		return true
	end

	return false
end

function mockedModule:_getRemotes()
	local identifier = tostring(n)

	if self:_getContext() == "server" then
		local reliable = ServerRemoteEvent.new(identifier, "Reliable")
		local unreliable = ServerRemoteEvent.new(identifier, "Unreliable")
		return reliable, unreliable
	elseif self:_getContext() == "client" then
		local reliable = ClientRemoteEvent.new(self._owner, identifier, "Reliable")
		local unreliable = ClientRemoteEvent.new(self._owner, identifier, "Unreliable")
		return reliable, unreliable
	end

	return
end

function mockedModule.new(context: "client" | "server", owner: any)
	local self = {}
	setmetatable(self, mockedModule)

	self.context = context
	self._owner = owner

	self:_initialize()

	return self
end

export type MockedBridge = typeof(mockedModule)

return function()
	n += 1
	return mockedModule
end
