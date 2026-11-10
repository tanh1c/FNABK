-- Studio Play server: first install the B1 barricade, then run this controlled check. SURV-03/04.
local round = game.ReplicatedStorage.FNABKRoundState
local map = workspace.FNABKGraybox
local barrier = map.B1Barricade
assert(round.ActiveBase.Value == "B1" and barrier:GetAttribute("Health") == 100)
local enemy, root = Instance.new("Model"), Instance.new("Part")
root.Anchored, root.CanCollide, root.Position, root.Parent = true, false, barrier.Position + Vector3.new(0, 0, 3), enemy
enemy.PrimaryPart, enemy.Parent = root, map.WaveAttackers
enemy:SetAttribute("NPCType", "Creature")
enemy:SetAttribute("EnemyState", "Chase")
round.SurvivalPhase.Value = "Night"
barrier.WaveStrike:Fire(enemy)
task.wait(.1)
assert(barrier:GetAttribute("Health") == 80, "first valid strike failed")
round.SurvivalPhase.Value = "Night"
barrier.WaveStrike:Fire(enemy)
task.wait(.1)
assert(barrier:GetAttribute("Health") == 80, "cooldown allowed a second hit")
round.SurvivalPhase.Value = "Day"
task.wait(2.1)
barrier.WaveStrike:Fire(enemy)
task.wait(.1)
assert(barrier:GetAttribute("Health") == 80, "daytime strike was accepted")
enemy:Destroy()
return "Barricade wave strike checks passed"
