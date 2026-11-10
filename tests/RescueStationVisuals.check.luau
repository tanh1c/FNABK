-- Run in a fresh Studio Play server (SURV-01/11).
local stations = workspace:WaitForChild("FNABKRescueStations")
local names = { Power = "Switch", Frequency = "FrequencyRecord", Transmitter = "Antenna" }
for kind, detailName in pairs(names) do
	local station = stations:WaitForChild(kind)
	local detail = station:FindFirstChild(detailName)
	assert(detail and detail:IsA("BasePart") and not detail.CanCollide and not detail.CanTouch and not detail.CanQuery)
	local weld = detail:FindFirstChildOfClass("WeldConstraint")
	assert(weld and weld.Part0 == station and weld.Part1 == detail, "detail not attached")
	assert(station:FindFirstChildOfClass("ProximityPrompt"), "missing interaction")
end
return "Rescue station visual checks passed"
