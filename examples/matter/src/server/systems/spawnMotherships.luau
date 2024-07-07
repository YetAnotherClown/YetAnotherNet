local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)
local components = require(ReplicatedStorage.Shared.components)

local function spawnMotherships(world)
	if Matter.useThrottle(10) then
		local spawnPosition = Vector3.new(500, 500, 500)
			* Vector3.new(math.random(1, 2) == 1 and 1 or -1, 1, math.random(1, 2) == 1 and 1 or -1)

		local despawnPosition = Vector3.new(500, 500, 500)
			* Vector3.new(math.random(1, 2) == 1 and 1 or -1, 1, math.random(1, 2) == 1 and 1 or -1)

		local goalPosition = Vector3.new(math.random(-100, 100), 100, math.random(-100, 100))

		world:spawn(
			components.Mothership({
				goal = goalPosition,
				nextGoal = despawnPosition,
			}),
			components.Transform({
				cframe = CFrame.new(spawnPosition),
			})
		)
	end

	for id, _ in world:query(components.Transform, components.Mothership):without(components.Model) do
		local model = ReplicatedStorage.Assets.Mothership:Clone()
		model.Parent = workspace
		model.PrimaryPart:SetNetworkOwner(nil)

		world:insert(
			id,
			components.Model({
				model = model,
			})
		)
	end

	for id, mothership, transform in
		world:query(components.Mothership, components.Transform):without(components.Lasering)
	do
		if (transform.cframe.p - mothership.goal).magnitude < 10 then
			if mothership.lasered then
				world:despawn(id)
			else
				world:insert(
					id,
					mothership:patch({
						goal = mothership.nextGoal,
						lasered = true,
					}),
					components.Lasering({
						remainingTime = 1,
					})
				)
			end
		end
	end

	for _, mothership, model in world:query(components.Mothership, components.Model):without(components.Lasering) do
		model.model.Roomba.AlignPosition.Position = mothership.goal
	end
end

return spawnMotherships
