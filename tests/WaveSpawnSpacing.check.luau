-- Run in a fresh solo Studio Play server (SURV-02).
local map, round = workspace.FNABKGraybox, game.ReplicatedStorage.FNABKRoundState
local player = game.Players:GetPlayers()[1]
local root = player.Character:WaitForChild("HumanoidRootPart")
local oldPivot, anchored, oldBase = player.Character:GetPivot(), root.Anchored, round.ActiveBase.Value
local base = workspace.FNABKBaseClaimPoints.B9
local candidate = base.Position + Vector3.new(math.cos(2.4) * 35, 2, math.sin(2.4) * 35)
player.Character:PivotTo(CFrame.new(candidate)); root.Anchored = true
round.ActiveBase.Value = "B9"
local seen, bad = 0, 0
local folder = map.WaveAttackers
local connection = folder.ChildAdded:Connect(function(enemy)
	local part = enemy.PrimaryPart
	if not part then bad += 1; return end
	if (root.Position - part.Position).Magnitude < 5 then bad += 1 end
	for _, other in ipairs(folder:GetChildren()) do
		if other ~= enemy and other:IsA("Model") and other.PrimaryPart and (other.PrimaryPart.Position - part.Position).Magnitude < 3 then bad += 1; break end
	end
	seen += 1
end)
game.ServerScriptService.FNABKServer.Bootstrap.SurvivalEvents:Fire("NightWave:2:1")
task.wait(3.5)
connection:Disconnect()
assert(seen == 10 and bad == 0, string.format("spawned=%d crowded=%d", seen, bad))
game.ServerScriptService.FNABKServer.Bootstrap.SurvivalEvents:Fire("Retreat:1")
round.ActiveBase.Value = oldBase
player.Character:PivotTo(oldPivot); root.Anchored = anchored
return "Wave spawn spacing checks passed"
