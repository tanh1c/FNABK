--!strict
-- SURV-01/02/11: deterministic schedule only; world events are handled separately.
local Clock = {}
local nights = { 300, 300, 300, 360, 480 }
local nightCounts = { 0, 2, 2, 3, 4 }
local soloTotals = { 0, 10, 14, 18, 24 }
local graceEvents = {
	{ 30, "WaveWarning:1" }, { 60, "Wave:1" }, { 210, "Retreat:1" },
	{ 210, "WaveWarning:2" }, { 240, "Wave:2" }, { 390, "Retreat:2" },
	{ 390, "WaveWarning:3" }, { 420, "Wave:3" }, { 570, "Retreat:3" },
}

export type State = {
	phase: string, day: number, remaining: number, signaled: boolean,
	graceElapsed: number, eventIndex: number, activeWave: number?, warnedWave: number?,
	pendingRetreat: number?, canceledWave: number?,
	nightEventIndex: number,
}

function Clock.new(): State
	return { phase = "Day", day = 1, remaining = 720, signaled = false,
		graceElapsed = 0, eventIndex = 1, activeWave = nil, warnedWave = nil,
		pendingRetreat = nil, canceledWave = nil, nightEventIndex = 1 }
end

function Clock.waveSize(night: number, players: number): (number?, number?)
	if type(night) ~= "number" or night % 1 ~= 0 or night < 2 or night > 5
		or type(players) ~= "number" or players % 1 ~= 0 or players < 1 or players > 4 then return nil, nil end
	local total = math.ceil(soloTotals[night] * (1 + 0.5 * (players - 1)))
	return total, math.min(total, 20 + 10 * (players - 1))
end

function Clock.lightingTime(state: State): number
	if state.phase == "Day" then
		return 6 + 12 * (1 - math.clamp(state.remaining / 720, 0, 1))
	elseif state.phase == "Night" then
		return (18 + 12 * (1 - math.clamp(state.remaining / nights[state.day], 0, 1))) % 24
	end
	return 6
end

local function nightEvent(state: State): (number?, string?)
	local count = nightCounts[state.day]
	if state.nightEventIndex > count * 2 then return nil, nil end
	local wave = math.ceil(state.nightEventIndex / 2)
	-- ponytail: evenly spaced attacks; tune their timings once spawning and retreat are playtested.
	local start = nights[state.day] * wave / (count + 1)
	local warning = state.nightEventIndex % 2 == 1
	return if warning then start - 30 else start, (if warning then "NightWaveWarning:" else "NightWave:") .. state.day .. ":" .. wave
end

function Clock.signal(state: State): boolean
	if state.signaled or (state.phase ~= "Day" and state.phase ~= "Night" and state.phase ~= "SignalGrace") then return false end
	state.signaled = true
	if state.phase == "SignalGrace" then
		state.pendingRetreat = if state.activeWave then state.activeWave * 180 + 30 - state.graceElapsed else nil
		state.canceledWave = state.warnedWave
		state.phase, state.remaining = "RescueWait", 240
	end
	return true
end

function Clock.advance(state: State, seconds: number): { string }
	assert(type(seconds) == "number" and seconds >= 0 and seconds < math.huge, "invalid elapsed time")
	local events: { string } = {}
	if state.canceledWave then
		table.insert(events, "WaveCanceled:" .. state.canceledWave)
		state.canceledWave = nil
	end
	while seconds > 0 and state.phase ~= "Lost" and state.phase ~= "Departed" do
		local step = math.min(seconds, state.remaining)
		local boundary: string? = nil
		if state.phase == "Night" then
			local at = nightEvent(state)
			if at then
				local distance = math.max(0, at - (nights[state.day] - state.remaining))
				if distance <= step then step, boundary = distance, "Night" end
			end
		elseif state.phase == "SignalGrace" then
			local nextEvent = graceEvents[state.eventIndex]
			if nextEvent then
				local distance = math.max(0, (nextEvent[1] :: number) - state.graceElapsed)
				if distance <= step then step, boundary = distance, "Grace" end
			end
		elseif state.phase == "RescueWait" and state.pendingRetreat then
			step = math.min(step, state.pendingRetreat)
		end
		seconds -= step
		state.remaining -= step
		if state.phase == "Night" then
			local at, event = nightEvent(state)
			if at and boundary == "Night" then
				table.insert(events, event :: string)
				state.nightEventIndex += 1
			end
		elseif state.phase == "SignalGrace" then
			state.graceElapsed += step
			if boundary == "Grace" and graceEvents[state.eventIndex] then
				state.graceElapsed = graceEvents[state.eventIndex][1] :: number
			end
			while graceEvents[state.eventIndex] and (graceEvents[state.eventIndex][1] :: number) <= state.graceElapsed do
				local event = graceEvents[state.eventIndex][2] :: string
				table.insert(events, event)
				local kind, number = string.match(event, "^(%a+):(%d+)$")
				if kind == "WaveWarning" then state.warnedWave = tonumber(number)
				elseif kind == "Wave" then state.activeWave, state.warnedWave = tonumber(number), nil
				elseif kind == "Retreat" then state.activeWave = nil end
				state.eventIndex += 1
			end
		elseif state.phase == "RescueWait" and state.pendingRetreat then
			state.pendingRetreat -= step
			if state.pendingRetreat <= 0 then
				table.insert(events, "Retreat:" .. (state.activeWave :: number))
				state.pendingRetreat, state.activeWave = nil, nil
			end
		end
		if state.remaining <= 0 then
			if state.phase == "Day" then
				state.phase, state.remaining = "Night", nights[state.day]
				state.nightEventIndex = 1
				table.insert(events, "Night:" .. state.day)
			elseif state.phase == "Night" and state.day < 5 then
				state.day += 1
				state.phase, state.remaining = "Day", 720
				table.insert(events, "Day:" .. state.day)
			elseif state.phase == "Night" then
				state.phase = if state.signaled then "RescueWait" else "SignalGrace"
				state.remaining = if state.signaled then 240 else 600
				table.insert(events, state.phase)
			elseif state.phase == "SignalGrace" then
				state.phase = "Lost"
				table.insert(events, "SignalDeadlineExpired")
			elseif state.phase == "RescueWait" then
				state.phase, state.remaining = "Boarding", 180
				table.insert(events, "HelicopterArrived")
			elseif state.phase == "Boarding" then
				state.phase = "Departed"
				table.insert(events, "HelicopterDeparted")
			end
		end
	end
	return events
end

return table.freeze(Clock)
