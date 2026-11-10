-- Run in a fresh solo Studio Play server (SURV-07/08).
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local state, base = game.ReplicatedStorage.FNABKRoundState, workspace.FNABKBaseClaimPoints.A1
local oldPivot, oldAnchored, oldBase, oldPoint = character:GetPivot(), root.Anchored, state.ActiveBase.Value, base.CFrame
local floor = Instance.new("Part")
floor.Size, floor.CFrame, floor.Anchored, floor.Parent = Vector3.new(100, 1, 100), CFrame.new(0, 999.5, 0), true, workspace
base.CFrame, state.ActiveBase.Value = CFrame.new(0, 1001, 0), "A1"
character:PivotTo(CFrame.new(0, 1003, 0)); root.Anchored = true
local map, events, shots = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent = workspace
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, shots)
events:Fire("Wave:1")
task.wait(.4)
local mimic = assert(map.WaveAttackers:FindFirstChild("WaveMimic"))
for _, enemy in ipairs(map.WaveAttackers:GetChildren()) do if enemy ~= mimic then enemy:Destroy() end end
map.WaveAttackers.ChildAdded:Connect(function(enemy) if enemy ~= mimic then enemy:Destroy() end end)
mimic:PivotTo(CFrame.new(0, 1003, -8))
task.wait(.4)
assert(mimic:GetAttribute("WaveTargetUserId") == player.UserId, "living player not targeted")
character:SetAttribute("FNABKDowned", true)
task.wait(.4)
assert(mimic:GetAttribute("WaveTargetUserId") == 0, "downed character still targeted")
character:SetAttribute("FNABKDowned", false)
task.wait(.4)
assert(mimic:GetAttribute("WaveTargetUserId") == player.UserId, "recovered player not targeted")
state.ActiveBase.Value, base.CFrame = oldBase, oldPoint
character:PivotTo(oldPivot); root.Anchored = oldAnchored
map:Destroy(); events:Destroy(); shots:Destroy(); floor:Destroy()
return "Wave incapacitated target checks passed"
