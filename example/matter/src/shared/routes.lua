local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

type ComponentInstance<T> = T & { patch: (self: T, data: { any: any }) -> ComponentInstance<T> }

local Net = require(Packages.Net)
type Net<U...> = Net.Net<U...>

local defaultConfiguration = {
	Channel = "Unreliable",
	Event = "default",
}

-- Replicate Matter Components
local MatterReplication: Net<{ ComponentInstance<any> }> = Net.new(defaultConfiguration)

return {
	MatterReplication = MatterReplication,
}
