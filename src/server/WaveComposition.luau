--!strict
-- SURV-11 selected grace compositions; regular waves use a proportional prototype.
local Composition = {}
local grace = { { 20, 3, 1 }, { 30, 5, 1 }, { 40, 6, 2 }, { 50, 8, 2 } }
function Composition.make(total: number, players: number, isGrace: boolean): { string }
	assert(players >= 1 and players <= 4 and players % 1 == 0 and total > 0 and total % 1 == 0)
	local machine, mimic
	if isGrace then
		assert(total == grace[players][1] + grace[players][2] + grace[players][3])
		machine, mimic = grace[players][2], grace[players][3]
	else
		machine, mimic = math.floor(total / 8), math.floor(total / 24)
	end
	local result = {}
	for index = 1, total do
		local kind = if index <= mimic then "Mimic" elseif index <= mimic + machine then "Machine" else "Creature"
		table.insert(result, kind)
	end
	return result
end
return table.freeze(Composition)
