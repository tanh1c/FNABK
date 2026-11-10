-- Studio Play server: isolated sight test for a single wave attacker.
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local character = player.Character
local root = character:WaitForChild("HumanoidRootPart")
local oldCFrame, oldAnchored = character:GetPivot(), root.Anchored
local state = game.ReplicatedStorage.FNABKRoundState
local oldBase = state.ActiveBase.Value
local map, events, shot = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent = workspace
state.ActiveBase.Value = "A1"
local floor = Instance.new("Part")
floor.Anchored, floor.Size, floor.CFrame, floor.Parent = true, Vector3.new(100, 1, 100), CFrame.new(0, 999.5, 0), workspace
character:PivotTo(CFrame.new(10, 1003, 0))
root.Anchored = true
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, shot)
task.wait(.2)
events:Fire("NightWave:2:1")
task.wait(.4)
local enemy
for _, candidate in ipairs(map.WaveAttackers:GetChildren()) do if candidate:GetAttribute("NPCType") == "Creature" then enemy = candidate; break end end
assert(enemy and enemy.PrimaryPart)
enemy:PivotTo(CFrame.new(-10, 1003, 0))
local wall = Instance.new("Part")
wall.Anchored, wall.Size, wall.CFrame, wall.Parent = true, Vector3.new(1, 20, 80), CFrame.new(0, 1003, 0), workspace
task.wait(.5)
assert(enemy:GetAttribute("WaveTargetUserId") == 0, "acquired unseen player through wall")
wall.CanCollide, wall.CanQuery = false, false
task.wait(.5)
assert(enemy:GetAttribute("WaveTargetUserId") == player.UserId, "did not acquire visible player")
wall.CanQuery, wall.CanCollide = true, true
enemy:PivotTo(CFrame.new(-10, 1003, 0))
task.wait(.5)
assert(enemy:GetAttribute("WaveTargetUserId") == 0, "retained visible target through wall")
shot:Fire(Vector3.new(10, 1003, 0), 60)
task.wait()
assert(enemy:GetAttribute("HeardPosition") == Vector3.new(10, 1003, 0), "wall blocked gunshot hearing")
state.ActiveBase.Value = oldBase
character:PivotTo(oldCFrame)
root.Anchored = oldAnchored
map:Destroy(); events:Destroy(); shot:Destroy(); wall:Destroy(); floor:Destroy()
return "Wave sight checks passed"
