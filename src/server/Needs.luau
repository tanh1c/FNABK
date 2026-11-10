--!strict
-- SURV-05: deterministic need decay; caller supplies eligible elapsed seconds.
local Needs = {}
export type State = { food: number, water: number, deprived: number }

function Needs.new(): State
	return { food = 100, water = 100, deprived = 0 }
end

function Needs.advance(state: State, seconds: number): number
	assert(seconds >= 0 and seconds < math.huge, "invalid elapsed time")
	local onset = math.min(state.food * 60, state.water * 40)
	state.food = math.max(0, state.food - seconds / 60)
	state.water = math.max(0, state.water - seconds / 40)
	local emptySeconds = math.max(0, seconds - onset)
	if state.food > 0 and state.water > 0 then state.deprived = 0; return 0 end
	state.deprived += emptySeconds
	local damage = math.floor(state.deprived / 5)
	state.deprived -= damage * 5
	return damage
end

function Needs.consume(state: State, kind: string): boolean
	if kind == "Food" and state.food < 100 then state.food = math.min(100, state.food + 35)
	elseif kind == "Water" and state.water < 100 then state.water = math.min(100, state.water + 40)
	else return false end
	if state.food > 0 and state.water > 0 then state.deprived = 0 end
	return true
end

return table.freeze(Needs)
