local mockedPlayers = {}

function createPlayer()
	local n = #mockedPlayers + 1
	table.insert(mockedPlayers, {
		__type = "Player",
		Name = `MockPlayer{n}`,
		UserId = -n,
	})

	return mockedPlayers[n]
end

function getAllPlayers()
	return mockedPlayers
end

return {
	createPlayer = createPlayer,
	getAllPlayers = getAllPlayers,
}
