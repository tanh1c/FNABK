-- Run on the Studio server; SURV-01/10/11.
local Clock = require(game.ServerScriptService.FNABKServer.SurvivalClock)
local Snapshot = require(game.ServerScriptService.FNABKServer.ClockSnapshot)
local http = game:GetService("HttpService")
local function roundtrip(state)
	return Snapshot.restore(http:JSONDecode(http:JSONEncode(Snapshot.capture(state))))
end
local day = Clock.new()
Clock.advance(day, 800)
local quietNight = assert(roundtrip(day))
assert(quietNight.phase == "Night" and quietNight.remaining == 220)
assert(table.concat(Clock.advance(quietNight, 220), ",") == "Day:2")
Clock.advance(day, 220 + 15)
assert(day.phase == "Day" and day.day == 2)
local restored = assert(roundtrip(day))
assert(restored.remaining == day.remaining and restored.day == 2)
assert(table.concat(Clock.advance(restored, 705), ",") == "Night:2")
local boarding = Clock.new()
assert(Clock.signal(boarding))
Clock.advance(boarding, 5340 + 40)
local waiting = assert(roundtrip(boarding))
assert(waiting.phase == "RescueWait" and waiting.remaining == 200)
assert(table.concat(Clock.advance(waiting, 200), ",") == "HelicopterArrived")
Clock.advance(boarding, 200 + 42)
restored = assert(roundtrip(boarding))
assert(restored.phase == "Boarding" and restored.remaining == 138)
assert(table.concat(Clock.advance(restored, 138), ",") == "HelicopterDeparted")
local active = Clock.new()
Clock.advance(active, 5340 + 65)
assert(Snapshot.capture(active) == nil)
assert(Clock.signal(active) and Snapshot.capture(active) == nil) -- active grace wave remains pending
local laterNight = Clock.new()
Clock.advance(laterNight, 720 + 300 + 720)
assert(Snapshot.capture(laterNight) == nil)
for _, data in ipairs({
	{ version = 1, phase = "Day", day = 1, remaining = 0, signaled = false },
	{ version = 1, phase = "Day", day = 1, remaining = 0/0, signaled = false },
	{ version = 1, phase = "Day", day = 1, remaining = math.huge, signaled = false },
	{ version = 1, phase = "Boarding", day = 4, remaining = 10, signaled = true },
	{ version = 1, phase = "Boarding", day = 5, remaining = 10, signaled = false },
	{ version = 1, phase = "RescueWait", day = 5, remaining = 241, signaled = true },
	{ version = 1, phase = "Night", day = 2, remaining = 200, signaled = false },
	{ version = 2, phase = "Day", day = 1, remaining = 10, signaled = false },
}) do assert(Snapshot.restore(data) == nil) end
print("Clock snapshot checks passed")
