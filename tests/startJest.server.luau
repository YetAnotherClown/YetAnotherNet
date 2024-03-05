local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Jest = require(ReplicatedStorage.DevPackages.Jest)

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
