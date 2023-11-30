local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)
local components = require(ReplicatedStorage.Shared.components)

local function mothershipsSpawnRoombas(world)
	for id, model, lasering, transform in
		world:query(components.Model, components.Lasering, components.Transform, components.Mothership)
	do
		model.model.Beam.Transparency = 1 - lasering.remainingTime

		lasering = lasering:patch({
			remainingTime = lasering.remainingTime - Matter.useDeltaTime(),
		})

		if not lasering.spawned then
			local spawnPosition = Vector3.new(transform.cframe.p.X, 11, transform.cframe.p.Z)

			world:spawn(
				components.Roomba(),
				components.Charge({
					charge = 100,
				}),
				components.Transform({
					cframe = CFrame.new(spawnPosition),
				})
			)

			lasering = lasering:patch({ spawned = true })
		end

		if lasering.remainingTime <= 0 then
			world:remove(id, components.Lasering)
		else
			world:insert(id, lasering)
		end
	end
end

return mothershipsSpawnRoombas
