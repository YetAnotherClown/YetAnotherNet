local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

type ComponentInstance<T> = T & { patch: (self: T, data: { any: any }) -> ComponentInstance<T> }

local Net = require(Packages.Net)

local Route = Net.Route
type Route<U...> = Net.Route<U...>

local defaultConfiguration: Net.Configuration = {
	Channel = "Reliable",
	Event = "default",
}

-- Replicate Matter Components
local MatterReplication: Route<{ ComponentInstance<any> }> = Route.new(defaultConfiguration)

return {
	MatterReplication = MatterReplication,
}
