-- Run in a fresh solo Studio Play server (SURV-05).
local state = game.ReplicatedStorage.FNABKRoundState
local anchors = workspace.FNABKBaseClaimPoints:GetChildren()
table.sort(anchors, function(a, b) return a.Name < b.Name end)
assert(#game.Players:GetPlayers() == 1 and #anchors >= 5)
local folder = workspace.FNABKGraybox.DailySupplies
local active = state.ActiveBase
local oldBase = active.Value
local chosen = {}
for offset = 0, 4 do
	local anchor = anchors[(2 * 5 + offset - 1) % #anchors + 1]
	assert(anchor:IsA("BasePart"))
	local stock = Instance.new("Folder")
	stock.Name, stock.Parent = anchor.Name, folder
	for i = 1, 9 do local item = Instance.new("Part"); item.Name, item.Parent = "Existing", stock end
	chosen[anchor.Name] = stock
end
local baseName = anchors[(2 * 5 - 1) % #anchors + 1].Name
active.Value = baseName
game.ServerScriptService.FNABKServer.Bootstrap.SurvivalEvents:Fire("Day:2")
task.wait(.4)
local counts, total, inBase = {}, 0, 0
for name, stock in pairs(chosen) do
	assert(#stock:GetChildren() <= 10, "point capacity exceeded")
	for _, item in ipairs(stock:GetChildren()) do
		if item.Name ~= "Existing" then
			counts[item.Name] = (counts[item.Name] or 0) + 1
			total += 1
			if name == baseName then inBase += 1 end
		end
	end
end
assert(total == 5 and counts.Water == 4 and counts.Food == 1, "priority or total incorrect")
assert(inBase <= math.floor(total / 4), "base share exceeded")
game.ServerScriptService.FNABKServer.Bootstrap.SurvivalEvents:Fire("Day:2")
task.wait(.2)
for _, stock in pairs(chosen) do assert(#stock:GetChildren() == 10, "repeat changed stock") end
active.Value = oldBase
for _, stock in pairs(chosen) do stock:Destroy() end
return "Constrained daily supply live check passed"
