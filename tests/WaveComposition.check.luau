-- Studio server: selected grace wave totals for each party size.
local composition = require(game.ServerScriptService.FNABKServer.WaveComposition)
for players, expected in ipairs({ {20,3,1}, {30,5,1}, {40,6,2}, {50,8,2} }) do
	local wave = composition.make(expected[1] + expected[2] + expected[3], players, true)
	local counts = { Creature = 0, Machine = 0, Mimic = 0 }
	for _, kind in ipairs(wave) do counts[kind] += 1 end
	assert(counts.Creature == expected[1] and counts.Machine == expected[2] and counts.Mimic == expected[3])
end
print("Wave composition checks passed")
