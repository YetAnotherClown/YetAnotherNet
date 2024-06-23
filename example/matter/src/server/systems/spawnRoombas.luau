local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)

local function spawnRoombas(world)
	for id, _ in world:query(components.Transform, components.Roomba):without(components.Model) do
		local model = ReplicatedStorage.Assets.KillerRoomba:Clone()
		model.Parent = workspace
		model.PrimaryPart:SetNetworkOwner(nil)

		world:insert(
			id,
			components.Model({
				model = model,
			})
		)
	end
end

return spawnRoombas
