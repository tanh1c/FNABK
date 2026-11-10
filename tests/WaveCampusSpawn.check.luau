-- Run in a fresh solo Studio Play server (SURV-02, CR-017).
local map, round = workspace.FNABKGraybox, game.ReplicatedStorage.FNABKRoundState
local player = game.Players:GetPlayers()[1]
local root = player.Character:WaitForChild("HumanoidRootPart")
local oldPivot, anchored, oldBase = player.Character:GetPivot(), root.Anchored, round.ActiveBase.Value
player.Character:PivotTo(CFrame.new(map.PlayerSpawn.Position + Vector3.new(0, 30, 0))); root.Anchored = true
round.ActiveBase.Value = ""
local enemies, seen, bad = map.WaveAttackers, 0, 0
local ignored = { enemies, player.Character }
local ray = RaycastParams.new(); ray.FilterType, ray.FilterDescendantsInstances, ray.RespectCanCollide = Enum.RaycastFilterType.Exclude, ignored, true
local overlap = OverlapParams.new(); overlap.FilterType, overlap.FilterDescendantsInstances, overlap.RespectCanCollide = Enum.RaycastFilterType.Exclude, ignored, true
local connection = enemies.ChildAdded:Connect(function(enemy)
	local part = enemy.PrimaryPart
	if not part then bad += 1; return end
	local floor = workspace:Raycast(part.Position, Vector3.new(0, -10, 0), ray)
	if not floor or floor.Distance > 2.2 or math.abs(floor.Position.Y - map.PlayerSpawn.Position.Y) > 3
		or #workspace:GetPartBoundsInBox(part.CFrame, Vector3.new(1.8, 3.8, 1.8), overlap) > 0 then bad += 1 end
	seen += 1
end)
game.ServerScriptService.FNABKServer.Bootstrap.SurvivalEvents:Fire("NightWave:2:1")
task.wait(3.5)
connection:Disconnect()
assert(seen == 10 and bad == 0, string.format("spawned=%d invalid=%d", seen, bad))
game.ServerScriptService.FNABKServer.Bootstrap.SurvivalEvents:Fire("Retreat:1")
round.ActiveBase.Value = oldBase
player.Character:PivotTo(oldPivot); root.Anchored = anchored
return "Campus wave spawn checks passed"
