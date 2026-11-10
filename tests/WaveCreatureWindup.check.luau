-- Run on a fresh Studio Play server (SURV-07).
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local state = game.ReplicatedStorage.FNABKRoundState
local base = workspace.FNABKBaseClaimPoints.A1
local previous, anchored, oldBase, oldPoint = character:GetPivot(), root.Anchored, state.ActiveBase.Value, base.CFrame
local floor = Instance.new("Part")
floor.Size, floor.CFrame, floor.Anchored, floor.Parent = Vector3.new(100, 1, 100), CFrame.new(0, 999.5, 0), true, workspace
base.CFrame = CFrame.new(0, 1001, 0)
character:PivotTo(CFrame.new(0, 1003, 0)); root.Anchored = true
local map, events, shots = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent, state.ActiveBase.Value = workspace, "A1"
local hits = {}
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function(_, amount) table.insert(hits, {time = os.clock(), amount = amount}); return nil end, shots)
events:Fire("Wave:1")
task.wait(1.3)
local creature
for _, enemy in ipairs(map.WaveAttackers:GetChildren()) do
	if enemy:GetAttribute("NPCType") == "Creature" and enemy:GetAttribute("EnemyState") == "Chase" then creature = enemy; break end
end
assert(creature, "missing creature")
for _, enemy in ipairs(map.WaveAttackers:GetChildren()) do if enemy ~= creature then enemy:Destroy() end end
map.WaveAttackers.ChildAdded:Connect(function(enemy) if enemy ~= creature then enemy:Destroy() end end)
local start = os.clock()
creature:PivotTo(CFrame.new(3, 1003, 0))
task.wait(.6)
assert(#hits == 0, "creature struck before wind-up")
character:PivotTo(CFrame.new(0, 1003, 15))
task.wait(.3)
assert(#hits == 0, "interrupted wind-up struck")
character:PivotTo(CFrame.new(0, 1003, 0))
creature:PivotTo(CFrame.new(3, 1003, 0))
start = os.clock()
while #hits == 0 and os.clock() - start < 3 do task.wait(.05) end
assert(hits[1] and hits[1].amount == 15 and hits[1].time - start >= .95, "missing delayed strike")
state.ActiveBase.Value, base.CFrame = oldBase, oldPoint
character:PivotTo(previous); root.Anchored = anchored
map:Destroy(); events:Destroy(); shots:Destroy(); floor:Destroy()
return "Creature wind-up checks passed"
