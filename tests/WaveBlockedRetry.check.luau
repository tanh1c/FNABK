-- Run in a fresh solo Studio Play server (SURV-02).
local player = game.Players:GetPlayers()[1]
local root = player.Character:WaitForChild("HumanoidRootPart")
local oldPivot, anchored = player.Character:GetPivot(), root.Anchored
player.Character:PivotTo(CFrame.new(0, 1040, 0)); root.Anchored = true
local state = game.ReplicatedStorage.FNABKRoundState
local base, oldBase = workspace.FNABKBaseClaimPoints.A1, state.ActiveBase.Value
local oldPoint = base.CFrame
base.CFrame, state.ActiveBase.Value = CFrame.new(0, 1001, 0), "A1"
local map, events, shots = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent = workspace
local floor = Instance.new("Part")
floor.Size, floor.Position, floor.Anchored, floor.Parent = Vector3.new(160, 1, 160), Vector3.new(0, 999.5, 0), true, workspace
local ceiling = Instance.new("Part")
ceiling.Size, ceiling.Position, ceiling.Anchored, ceiling.Parent = Vector3.new(140, 1, 140), Vector3.new(0, 1005, 0), true, workspace
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, shots)
events:Fire("NightWave:2:1")
task.wait(1.3)
assert(#map.WaveAttackers:GetChildren() == 0, "spawned in blocked geometry")
ceiling:Destroy()
task.wait(1.5)
assert(#map.WaveAttackers:GetChildren() > 0, "did not retry when clear")
events:Fire("Retreat:1")
state.ActiveBase.Value, base.CFrame = oldBase, oldPoint
player.Character:PivotTo(oldPivot); root.Anchored = anchored
map:Destroy(); events:Destroy(); shots:Destroy(); floor:Destroy()
return "Blocked wave retry check passed"
