-- Controlled Studio Play server check, SURV-05/10; uses separate temporary services.
local Service = require(game.ServerScriptService.FNABKServer.MedkitService)
local config = require(game.ReplicatedStorage.FNABKShared.GameConfig)
local function start(name)
	local map = Instance.new("Folder")
	map.Name, map.Parent = name, workspace
	local events = Instance.new("BindableEvent")
	events.Parent = map
	local _, capture, restore = Service.Start(map, config, function() return 100 end, events, events)
	return map, events, capture, restore
end
local map1, event1, capture1 = start("DailyRestoreSource")
event1:Fire("Day:2")
task.wait(.1)
local original = capture1()
assert(original.processedDay == 2)
local expected = {}
for _, item in ipairs(original.supplies) do if item.point then expected[item.item.id] = item end end
assert(next(expected), "no daily supplies")
local map2, event2, capture2, restore = start("DailyRestoreTarget")
local invalid = table.clone(original)
invalid.processedDay = 6
assert(not restore(invalid) and capture2().processedDay == 1)
assert(restore(original))
local restored = capture2()
local count = 0
for _, item in ipairs(restored.supplies) do
	if item.point then
		local prior = assert(expected[item.item.id])
		assert(item.point == prior.point and item.slot == prior.slot and item.item.rounds == prior.item.rounds)
		count += 1
	end
end
local total = 0
for _ in pairs(expected) do total += 1 end
assert(count == total and restored.processedDay == 2)
assert(not restore(original), "second restore accepted")
event2:Fire("Day:2")
task.wait(.1)
assert(capture2().processedDay == 2)
local again = capture2()
local after = 0
for _, item in ipairs(again.supplies) do if item.point then after += 1 end end
assert(after == total, "same day replenished twice")
event2:Fire("Day:3")
task.wait(.1)
assert(capture2().processedDay == 3)
local map3, _, capture3, restore3 = start("DailyRestoreEmpty")
local empty = capture3()
assert(restore3(empty) and not restore3(empty), "empty day restored twice")
map3:Destroy()
map1:Destroy(); map2:Destroy()
return "Daily supply restore checks passed"
