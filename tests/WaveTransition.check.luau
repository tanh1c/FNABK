-- Studio Play server: force a grace-wave transition with an unfinished retreat.
local map = Instance.new("Folder")
map.Name, map.Parent = "WaveTransitionTest", workspace
local events, gunshot = Instance.new("BindableEvent"), Instance.new("BindableEvent")
local state = game.ReplicatedStorage.FNABKRoundState
local oldBase = state.ActiveBase.Value
state.ActiveBase.Value = "A1"
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, gunshot)
events:Fire("Wave:1")
task.wait(1)
local old = map.WaveAttackers:GetChildren()
assert(#old > 0)
events:Fire("Wave:2")
task.wait(0.2)
for _, enemy in ipairs(old) do assert(enemy.Parent == nil, "old wave overlaps grace wave") end
assert(#map.WaveAttackers:GetChildren() > 0, "next wave did not start")
assert(map:FindFirstChild("RetreatEffect"), "missing straggler effect")
state.ActiveBase.Value = oldBase
events:Destroy()
gunshot:Destroy()
map:Destroy()
print("Grace wave transition check passed")
