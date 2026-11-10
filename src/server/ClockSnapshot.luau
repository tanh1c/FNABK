--!strict
-- SURV-01/10/11: limited clock serialization; not a complete run save.
local Clock = require(script.Parent.SurvivalClock)
local Snapshot = {}

-- ponytail: reject active waves; add full warning and wave restoration when ownership is saved.
function Snapshot.capture(state: Clock.State): { [string]: any }?
	if state.activeWave or state.warnedWave or state.pendingRetreat or state.canceledWave then return nil end
	local data = { version = 1, phase = state.phase, day = state.day, remaining = state.remaining, signaled = state.signaled }
	return if Snapshot.restore(data) then data else nil
end

function Snapshot.restore(data: any): Clock.State?
	if type(data) ~= "table" or data.version ~= 1 or type(data.day) ~= "number"
		or data.day % 1 ~= 0 or data.day < 1 or data.day > 5
		or type(data.remaining) ~= "number" or data.remaining ~= data.remaining or data.remaining <= 0 or data.remaining >= math.huge
		or type(data.signaled) ~= "boolean" then return nil end
	if data.phase == "Day" then
		if data.remaining > 720 then return nil end
	elseif data.phase == "Night" then
		if data.day ~= 1 or data.remaining > 300 then return nil end
	elseif data.phase == "RescueWait" then
		if data.day ~= 5 or not data.signaled or data.remaining > 240 then return nil end
	elseif data.phase == "Boarding" then
		if data.day ~= 5 or not data.signaled or data.remaining > 180 then return nil end
	else
		return nil
	end
	local state = Clock.new()
	state.phase, state.day, state.remaining, state.signaled = data.phase, data.day, data.remaining, data.signaled
	return state
end

return table.freeze(Snapshot)
