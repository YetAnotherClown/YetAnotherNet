local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Net = require(Packages.Net)

local IDENTIFIERS = {
	"Replication",
}

local identifiers = {}

for _, name in ipairs(IDENTIFIERS) do
	identifiers[name] = Net.identifier(name)
end

return identifiers