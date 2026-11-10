-- Studio Play server: forces a terminal result in a disposable test session.
local state = game.ReplicatedStorage:WaitForChild("FNABKRoundState")
assert(state:WaitForChild("RoundStatus", 20), "round did not initialize")
assert(state:WaitForChild("ActiveBase", 20), "base did not initialize")
assert(state.RoundStatus.Value == "Running")
local map = Instance.new("Folder")
map.Name, map.Parent = "WaveRoundEndTest", workspace
local events, gunshot = Instance.new("BindableEvent"), Instance.new("BindableEvent")
state.ActiveBase.Value = "A1"
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, gunshot)
events:Fire("NightWave:2:1")
task.wait(1)
local initial = map.WaveAttackers:GetChildren()
assert(#initial > 0)
state.RoundStatus.Value = "Lost"
task.wait(.2)
for _, enemy in ipairs(initial) do
	local key = if enemy:GetAttribute("NPCType") == "Mimic" then "MimicState" else "EnemyState"
	assert(enemy:GetAttribute(key) == "Retreat" or enemy:GetAttribute(key) == "Defeated")
end
events:Fire("NightWave:2:2")
task.wait(.5)
assert(#map.WaveAttackers:GetChildren() <= #initial, "wave spawned after round ended")
events:Destroy()
gunshot:Destroy()
map:Destroy()
return "Wave round-end check passed"
