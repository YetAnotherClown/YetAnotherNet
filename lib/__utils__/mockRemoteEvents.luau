--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevPackages = ReplicatedStorage.DevPackages

local Signal = require(DevPackages.Signal)

local clientRemotes = {}
local serverRemotes = {}

local ClientRemoteEvent = {}
ClientRemoteEvent.__index = ClientRemoteEvent

local utils = script.Parent
local mockPlayers = require(utils.mockPlayers)

function ClientRemoteEvent:FireServer(...: any)
	local container = serverRemotes[self._identifier]
	if not container then
		return
	end

	for _, remote in container do
		remote.OnServerEvent:Fire(self._owner, ...)
	end
end

function ClientRemoteEvent.new(player, identifier: string, channel: "Reliable" | "Unreliable")
	local remote = {}
	setmetatable(remote, ClientRemoteEvent)

	remote._owner = player
	remote._channel = channel
	remote._identifier = identifier
	remote.OnClientEvent = Signal.new()

	local container = clientRemotes[remote._identifier]
	if not container then
		container = {}
		clientRemotes[remote._identifier] = container
	end

	table.insert(container, remote)

	return remote
end

local ServerRemoteEvent = {}
ServerRemoteEvent.__index = ServerRemoteEvent

function ServerRemoteEvent:FireAllClient(...: any)
	for _, player in mockPlayers.getAllPlayers() do
		self:FireClient(player, ...)
	end
end

function ServerRemoteEvent:FireClient(player, ...: any)
	local container = clientRemotes[self._identifier]
	if not container then
		return
	end

	for _, remote in container do
		if remote._owner ~= player then
			continue
		end

		remote.OnClientEvent:Fire(...)
	end
end

function ServerRemoteEvent.new(identifier: string, channel: "Reliable" | "Unreliable")
	local remote = {}
	setmetatable(remote, ServerRemoteEvent)

	remote._channel = channel
	remote._identifier = identifier
	remote.OnServerEvent = Signal.new()

	local container = serverRemotes[remote._identifier]
	if not container then
		container = {}
		serverRemotes[remote._identifier] = container
	end

	table.insert(container, remote)

	return remote
end

function getAllPlayersRemotes(identifier: string)
	for _, player in mockPlayers.getAllPlayers() do
		getPlayerRemotes(player, identifier)
	end
end

function getPlayerRemotes(player, identifier: string)
	local container = clientRemotes[identifier]
	if not container then
		return {}
	end

	local remotes = {}

	for _, remote in container do
		if remote._owner ~= player then
			continue
		end

		table.insert(remotes, player)
	end

	return remotes
end

function getServerRemotes(identifier: string)
	local container = serverRemotes[identifier]
	if not container then
		return {}
	end

	return container
end

return {
	ClientRemoteEvent = ClientRemoteEvent,
	ServerRemoteEvent = ServerRemoteEvent,

	getPlayerRemotes = getPlayerRemotes,
	getAllPlayersRemotes = getAllPlayersRemotes,
	getServerRemotes = getServerRemotes,
}
