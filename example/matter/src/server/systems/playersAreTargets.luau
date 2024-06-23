local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)
local components = require(ReplicatedStorage.Shared.components)

local function playersAreTargets(world)
	for _, player in ipairs(Players:GetPlayers()) do
		for _, character in Matter.useEvent(player, "CharacterAdded") do
			world:spawn(
				components.Target(),
				components.Model({
					model = character,
				})
			)
		end
	end

	-- players can die
	for id in world:query(components.Target):without(components.Model) do
		world:despawn(id)
	end
end

return playersAreTargets
