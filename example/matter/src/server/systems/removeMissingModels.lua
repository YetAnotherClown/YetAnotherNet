local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)
local components = require(ReplicatedStorage.Shared.components)

local function removeMissingModels(world)
	for id, model in world:query(components.Model) do
		for _ in Matter.useEvent(model.model, "AncestryChanged") do
			if model.model:IsDescendantOf(game) == false then
				world:remove(id, components.Model)
				break
			end
		end
		if not model.model.PrimaryPart then
			world:remove(id, components.Model)
		end
	end

	for _id, modelRecord in world:queryChanged(components.Model) do
		if modelRecord.new == nil then
			if modelRecord.old and modelRecord.old.model then
				modelRecord.old.model:Destroy()
			end
		end
	end
end

return removeMissingModels
