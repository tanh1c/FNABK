--!strict
-- SURV-08: server-owned ammunition and timing. Ownership and hit validation belong to the caller.
local Firearm = {}
local definitions = {
	Pistol = { capacity = 12, ammo = "PistolAmmo", box = 20, interval = 0.4, reload = 2 },
	Shotgun = { capacity = 6, ammo = "ShotgunAmmo", box = 10, interval = 1.2, reload = 0.7 },
	Rifle = { capacity = 30, ammo = "RifleAmmo", box = 30, interval = 0.15, reload = 2.8 },
}
export type State = { kind: string, loaded: number, nextFire: number, reloadAt: number?, reloadBox: string? }
export type Box = { id: string, kind: string, rounds: number }
local function validTime(now: number): boolean
	return type(now) == "number" and now == now and math.abs(now) < math.huge
end

function Firearm.new(kind: string): State
	assert(definitions[kind], "unknown firearm")
	return { kind = kind, loaded = 0, nextFire = 0, reloadAt = nil, reloadBox = nil }
end

function Firearm.snapshot(state: State, now: number): { [string]: any }?
	local d = definitions[state.kind]
	if not d or not validTime(now) or not validTime(state.nextFire) or type(state.loaded) ~= "number"
		or state.loaded % 1 ~= 0 or state.loaded < 0 or state.loaded > d.capacity then return nil end
	local cooldown = math.max(0, state.nextFire - now)
	if cooldown > d.interval + 0.001 then return nil end
	return { kind = state.kind, loaded = state.loaded, cooldown = cooldown }
end

function Firearm.restore(data: any, now: number): State?
	if type(data) ~= "table" or type(data.kind) ~= "string" or not definitions[data.kind] or not validTime(now)
		or type(data.loaded) ~= "number" or data.loaded % 1 ~= 0 or data.loaded < 0 or data.loaded > definitions[data.kind].capacity
		or not validTime(data.cooldown) or data.cooldown < 0 or data.cooldown > definitions[data.kind].interval + 0.001 then return nil end
	local state = Firearm.new(data.kind)
	state.loaded, state.nextFire = data.loaded, now + data.cooldown
	return state
end

function Firearm.startReload(state: State, box: Box, now: number): boolean
	local d = definitions[state.kind]
	if not d or not validTime(now) or state.reloadAt or type(box) ~= "table" or type(box.id) ~= "string" or box.id == ""
		or box.kind ~= d.ammo or type(box.rounds) ~= "number" or box.rounds % 1 ~= 0 or box.rounds <= 0 or box.rounds > d.box
		or state.loaded >= d.capacity then return false end
	state.reloadAt, state.reloadBox = now + d.reload, box.id
	return true
end

function Firearm.finishReload(state: State, box: Box, now: number): boolean
	local d = definitions[state.kind]
	if not d or not validTime(now) or not state.reloadAt or now < state.reloadAt or type(box) ~= "table"
		or box.id ~= state.reloadBox or box.kind ~= d.ammo or type(box.rounds) ~= "number"
		or box.rounds % 1 ~= 0 or box.rounds <= 0 or box.rounds > d.box then return false end
	-- Process shells already completed when the server resumes after a delayed frame.
	local completed = if state.kind == "Shotgun" then 1 + math.floor((now - state.reloadAt) / d.reload + 1e-9) else d.capacity
	local moved = math.min(box.rounds, d.capacity - state.loaded, completed)
	if moved <= 0 then state.reloadAt, state.reloadBox = nil, nil; return false end
	state.loaded += moved
	box.rounds -= moved
	if state.kind == "Shotgun" and state.loaded < d.capacity and box.rounds > 0 then
		state.reloadAt += moved * d.reload
	else state.reloadAt, state.reloadBox = nil, nil end
	return true
end

function Firearm.cancelReload(state: State)
	state.reloadAt, state.reloadBox = nil, nil
end

function Firearm.fire(state: State, now: number): boolean
	local d = definitions[state.kind]
	if not d or not validTime(now) or now < state.nextFire or state.loaded < 1 then return false end
	if state.reloadAt and state.kind ~= "Shotgun" then return false end
	state.reloadAt, state.reloadBox = nil, nil
	state.loaded -= 1
	state.nextFire = now + d.interval
	return true
end

function Firearm.shotgunPelletDamage(distance: number): number
	assert(validTime(distance) and distance >= 0, "invalid distance")
	return if distance <= 15 then 10 elseif distance >= 65 then 0 else 10 * (1 - (distance - 15) / 50)
end

return table.freeze(Firearm)
