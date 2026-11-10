-- Run on a fresh solo Studio Play server (SURV-02).
local state = game.ReplicatedStorage.FNABKRoundState
local oldBase = state.ActiveBase.Value
state.ActiveBase.Value = ""
local map, events, shots = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent = workspace
local spawn = Instance.new("Part")
spawn.Name, spawn.Anchored, spawn.Position, spawn.Parent = "PlayerSpawn", true, Vector3.new(0, 1000, 0), map
local floor = Instance.new("Part")
floor.Size, floor.Position, floor.Anchored, floor.Parent = Vector3.new(160, 1, 160), Vector3.new(0, 999.5, 0), true, workspace
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, shots)
events:Fire("NightWave:2:1")
task.wait(.7)
local enemies = map.WaveAttackers:GetChildren()
assert(#enemies > 0, "wave was skipped without a base")
local root = assert(enemies[1].PrimaryPart)
assert((root.Position - spawn.Position).Magnitude < 40, "wave did not use fallback spawn")
assert(state.ActiveBase.Value == "", "fallback claimed a base")
state.ActiveBase.Value = oldBase
map:Destroy(); events:Destroy(); shots:Destroy(); floor:Destroy()
return "Wave no-base fallback check passed"
