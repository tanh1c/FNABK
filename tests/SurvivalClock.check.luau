-- Studio server command bar after Rojo sync. SURV-01/02/11.
local Clock = require(game.ServerScriptService.FNABKServer.SurvivalClock)
local c = Clock.new()
assert(c.phase == "Day" and c.day == 1 and c.remaining == 720)
assert(Clock.lightingTime(c) == 6)
Clock.advance(c, 360)
assert(Clock.lightingTime(c) == 12)
Clock.advance(c, 360)
assert(Clock.lightingTime(c) == 18)
assert(c.phase == "Night" and c.day == 1 and c.remaining == 300)
Clock.advance(c, 150)
assert(Clock.lightingTime(c) == 0)
Clock.advance(c, 150)
assert(Clock.lightingTime(c) == 6)
assert(c.phase == "Day" and c.day == 2 and c.remaining == 720)
Clock.advance(c, 720 + 300 + 720 + 300 + 720 + 360 + 720 + 480)
assert(c.phase == "SignalGrace" and c.remaining == 600)
local events = Clock.advance(c, 270)
assert(table.concat(events, ",") == "WaveWarning:1,Wave:1,Retreat:1,WaveWarning:2,Wave:2")
assert(Clock.signal(c))
assert(c.phase == "RescueWait" and c.remaining == 240)
assert(not Clock.signal(c))
events = Clock.advance(c, 240)
assert(table.concat(events, ",") == "Retreat:2,HelicopterArrived")
assert(c.phase == "Boarding" and c.remaining == 180)
Clock.advance(c, 180)
assert(c.phase == "Departed")
local early = Clock.new()
assert(Clock.signal(early))
Clock.advance(early, 5340)
assert(early.phase == "RescueWait" and early.remaining == 240)
local expired = Clock.new()
Clock.advance(expired, 5940)
assert(expired.phase == "Lost" and not Clock.signal(expired))
assert(not pcall(function() Clock.advance(expired, -1) end))
local cancel = Clock.new()
Clock.advance(cancel, 5340 + 35)
assert(Clock.signal(cancel))
assert(table.concat(Clock.advance(cancel, 1), ",") == "WaveCanceled:1")
local last = Clock.new()
Clock.advance(last, 5340 + 425)
assert(Clock.signal(last))
assert(table.concat(Clock.advance(last, 145), ",") == "Retreat:3")
local waiting = Clock.new()
Clock.advance(waiting, 0)
assert(waiting.phase == "Day" and waiting.remaining == 720)
Clock.advance(waiting, 720)
assert(#Clock.advance(waiting, 300) == 1) -- quiet first night, then Day 2
Clock.advance(waiting, 720)
assert(table.concat(Clock.advance(waiting, 300), ",") == "NightWaveWarning:2:1,NightWave:2:1,NightWaveWarning:2:2,NightWave:2:2,Day:3")
assert(Clock.waveSize(2, 1) == 10 and Clock.waveSize(2, 4) == 25)
assert(Clock.waveSize(4, 3) == 36 and Clock.waveSize(5, 4) == 60)
assert(Clock.waveSize(1, 1) == nil and Clock.waveSize(2, 0) == nil)
for night, expected in ipairs({ 0, 2, 2, 3, 4 }) do
	local state = Clock.new()
	for _ = 1, night - 1 do Clock.advance(state, 720 + ({300,300,300,360,480})[state.day]) end
	Clock.advance(state, 720)
	local waveEvents = Clock.advance(state, ({300,300,300,360,480})[night])
	local starts, warnings = 0, 0
	for _, event in ipairs(waveEvents) do
		if event:match("^NightWave:") then starts += 1 end
		if event:match("^NightWaveWarning:") then warnings += 1 end
	end
	assert(starts == expected and warnings == expected)
end
local total, cap = Clock.waveSize(5, 4)
assert(total == 60 and cap == 50)
local stepped = Clock.new()
local observed = {}
for _ = 1, 60000 do
	for _, event in ipairs(Clock.advance(stepped, 0.1013)) do table.insert(observed, event) end
end
assert(stepped.phase == "Lost")
local warnings, starts = 0, 0
for _, event in ipairs(observed) do
	if event:match("^NightWaveWarning:") then warnings += 1 end
	if event:match("^NightWave:") then starts += 1 end
end
assert(warnings == 11 and starts == 11)
assert(table.find(observed, "SignalDeadlineExpired"))
print("Survival clock checks passed")
