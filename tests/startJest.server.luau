local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Jest = require("@dev-packages/Jest")

Jest.runCLI(
	script,
	{
		testPathPattern = { "\\.test$" },
		testPathIgnorePatterns = { "DevPackages" },
		verbose = true,
	} :: any,
	{
		ReplicatedStorage,
	}
):await()
