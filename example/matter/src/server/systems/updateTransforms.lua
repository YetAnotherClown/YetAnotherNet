local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local removeMissingModels = require(script.Parent.removeMissingModels)

local function updateTransforms(world)
	-- Handle Transform added/changed to existing entity with Model
	for id, transformRecord in world:queryChanged(components.Transform) do
		if not world:contains(id) then
			continue
		end

		local model = world:get(id, components.Model)

		if not model then
			continue
		end

		if transformRecord.new and not transformRecord.new.doNotReconcile then
			model.model:SetPrimaryPartCFrame(transformRecord.new.cframe)
		end
	end

	-- Handle Model added/changed on existing entity with Transform
	for id, modelRecord in world:queryChanged(components.Model) do
		if not world:contains(id) then
			continue
		end

		local transform = world:get(id, components.Transform)

		if not transform then
			continue
		end

		if modelRecord.new then
			modelRecord.new.model:SetPrimaryPartCFrame(transform.cframe)
		end
	end

	-- Update Transform on unanchored Models
	for id, model, transform in world:query(components.Model, components.Transform) do
		if model.model.PrimaryPart.Anchored then
			continue
		end

		local existingCFrame = transform.cframe
		local currentCFrame = model.model.PrimaryPart.CFrame

		-- Despawn models that fall into the void
		if currentCFrame.Y < -400 then
			world:despawn(id)
			continue
		end

		if currentCFrame ~= existingCFrame then
			world:insert(
				id,
				components.Transform({
					cframe = currentCFrame,
					doNotReconcile = true,
				})
			)
		end
	end
end

return {
	system = updateTransforms,
	after = { removeMissingModels },
}
