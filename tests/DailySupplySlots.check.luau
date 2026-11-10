-- Studio Play server: run in a fresh session; day events and pickups are temporary.
local events = game.ServerScriptService:FindFirstChild("SurvivalEvents", true)
assert(events and events:IsA("BindableEvent"))
local folder = workspace.FNABKGraybox.DailySupplies
events:Fire("Day:2")
task.wait(.5)
local point
for _, stock in ipairs(folder:GetChildren()) do if #stock:GetChildren() >= 2 then point = stock; break end end
assert(point, "no populated supply point")
local first = point:GetChildren()[1]
first:Destroy()
events:Fire("Day:25") -- 23 anchors: same point rotation as day 2.
task.wait(.5)
local seen = {}
for _, box in ipairs(point:GetChildren()) do
	local slot = box:GetAttribute("SupplySlot")
	assert(type(slot) == "number" and not seen[slot], "duplicate placement slot")
	seen[slot] = true
end
assert(seen[0], "vacated placement slot was not reused")
print("Daily supply placement check passed")
