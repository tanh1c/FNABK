-- Studio Play server; triggers a temporary day-2 replenishment in this test run.
local events = game.ServerScriptService.FNABKServer.Bootstrap:WaitForChild("SurvivalEvents")
local folder = workspace.FNABKGraybox:WaitForChild("DailySupplies")
assert(#game.Players:GetPlayers() == 1 and not folder:GetAttribute("ProcessedDay"))
events:Fire("Day:2")
task.wait(.3)
local counts = {}
for _, point in ipairs(folder:GetChildren()) do
	assert(#point:GetChildren() <= 10)
	for _, item in ipairs(point:GetChildren()) do counts[item.Name] = (counts[item.Name] or 0) + 1 end
end
assert(counts.Water == 4 and counts.Food == 3 and counts.PistolAmmo == 2 and counts.ShotgunAmmo == 1 and counts.RifleAmmo == 1)
events:Fire("Day:2")
task.wait(.2)
local total = 0
for _, point in ipairs(folder:GetChildren()) do total += #point:GetChildren() end
assert(total == 11)
print("Daily supply live check passed")
