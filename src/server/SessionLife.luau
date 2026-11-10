--!strict
-- SURV-10: living/eliminated state retained only while this server is alive.
local Life = {}
export type State = { respawns: number, health: number, eliminated: boolean }
local function valid(id: any, respawns: any, health: any, eliminated: any): boolean
	return type(id) == "number" and id ~= 0 and id % 1 == 0 and math.abs(id) < math.huge
		and type(respawns) == "number" and respawns % 1 == 0 and respawns >= 0 and respawns <= 3
		and type(health) == "number" and health == health and health >= 0 and health <= 100
		and type(eliminated) == "boolean"
end
local function create(states: { [number]: State })
	return {
		save = function(id: number, respawns: number, health: number, eliminated: boolean)
			assert(valid(id, respawns, health, eliminated), "invalid life state")
			states[id] = { respawns = respawns, health = health, eliminated = eliminated }
		end,
		get = function(id: number): State? return if states[id] then table.clone(states[id]) else nil end,
		snapshot = function()
			local result = {}
			for id, state in pairs(states) do
				table.insert(result, { userId = id, respawns = state.respawns, health = state.health, eliminated = state.eliminated })
			end
			table.sort(result, function(a, b) return a.userId < b.userId end)
			return { version = 1, players = result }
		end,
	}
end
function Life.new() return create({}) end

function Life.restore(data: any)
	if type(data) ~= "table" or data.version ~= 1 or type(data.players) ~= "table" then return nil end
	local states, count = {}, 0
	for k in pairs(data.players) do
		if type(k) ~= "number" or k % 1 ~= 0 or k < 1 or k > 256 then return nil end
		count += 1
	end
	for i = 1, count do
		local entry = data.players[i]
		if type(entry) ~= "table" or not valid(entry.userId, entry.respawns, entry.health, entry.eliminated)
			or (not entry.eliminated and entry.health == 0) or states[entry.userId] then return nil end
		states[entry.userId] = { respawns = entry.respawns, health = entry.health, eliminated = entry.eliminated }
	end
	return create(states)
end
return table.freeze(Life)
