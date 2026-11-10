-- Studio Play server: measure one attacker's unobstructed movement on a temporary floor.
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local character = player.Character
local root = character:WaitForChild("HumanoidRootPart")
local previous, anchored = character:GetPivot(), root.Anchored
local state = game.ReplicatedStorage.FNABKRoundState
local oldBase = state.ActiveBase.Value
local floor = Instance.new("Part")
floor.Size, floor.CFrame, floor.Anchored, floor.Parent = Vector3.new(100, 1, 100), CFrame.new(0, 999.5, 0), true, workspace
character:PivotTo(CFrame.new(0, 1003, 0)); root.Anchored = true
local map, events, shots = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent, state.ActiveBase.Value = workspace, "A1"
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, shots)
events:Fire("NightWave:2:1")
task.wait(.5)
local enemy = map.WaveAttackers:GetChildren()[1]
assert(enemy and enemy:IsA("Model") and enemy.PrimaryPart)
enemy:PivotTo(CFrame.new(25, 1003, 0))
task.wait(.3)
local before, started = enemy.PrimaryPart.Position, os.clock()
task.wait(.6)
local elapsed = os.clock() - started
local distance = (enemy.PrimaryPart.Position - before).Magnitude
assert(distance / elapsed > 5 and distance / elapsed < 20, "unreasonable unobstructed movement")
state.ActiveBase.Value = oldBase
character:PivotTo(previous); root.Anchored = anchored
map:Destroy(); events:Destroy(); shots:Destroy(); floor:Destroy()
return string.format("Wave movement: %.1f studs/s", distance / elapsed)
