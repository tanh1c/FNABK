-- Run in a fresh solo Studio Play server (SURV-02).
local player = game.Players:GetPlayers()[1]
local root = player.Character:WaitForChild("HumanoidRootPart")
local oldPivot, anchored = player.Character:GetPivot(), root.Anchored
player.Character:PivotTo(CFrame.new(0, 1020, 0)); root.Anchored = true
local state = game.ReplicatedStorage.FNABKRoundState
local base, oldBase = workspace.FNABKBaseClaimPoints.A1, state.ActiveBase.Value
local oldPoint = base.CFrame
base.CFrame, state.ActiveBase.Value = CFrame.new(0, 1001, 0), "A1"
local map, events, shots = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent = workspace
local floor = Instance.new("Part")
floor.Size, floor.Position, floor.Anchored, floor.Parent = Vector3.new(160, 1, 160), Vector3.new(0, 999.5, 0), true, workspace
local blockers = Instance.new("Model"); blockers.Parent = workspace
for i = 0, 11 do
	local a = 2.4 + i * math.pi / 6
	local wall = Instance.new("Part")
	wall.Anchored, wall.Size = true, Vector3.new(7, 10, 7)
	wall.Position, wall.Parent = base.Position + Vector3.new(math.cos(a) * 35, 2, math.sin(a) * 35), blockers
end
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, shots)
events:Fire("NightWave:2:1")
task.wait(.15)
local enemy = assert(map.WaveAttackers:FindFirstChildWhichIsA("Model"))
local pos = assert(enemy.PrimaryPart).Position
local radius = Vector3.new(pos.X - base.Position.X, 0, pos.Z - base.Position.Z).Magnitude
assert(radius > 40 and radius < 46, "did not use the clear outer ring")
state.ActiveBase.Value, base.CFrame = oldBase, oldPoint
player.Character:PivotTo(oldPivot); root.Anchored = anchored
map:Destroy(); events:Destroy(); shots:Destroy(); floor:Destroy(); blockers:Destroy()
return "Wave outer spawn check passed"
