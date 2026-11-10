-- Studio Play server: inspect fresh-run assignments without changing progress.
local folder = game.ReplicatedStorage.FNABKRoundState:WaitForChild("RescueObjectives")
local stations = workspace:WaitForChild("FNABKRescueStations")
for _, name in ipairs({ "Power", "Frequency", "Transmitter" }) do
	local flag = folder:WaitForChild(name)
	local station = stations:WaitForChild(name)
	assert(flag:IsA("BoolValue") and not flag.Value)
	assert(typeof(flag:GetAttribute("Position")) == "Vector3")
	assert((flag:GetAttribute("Position") - station.Position).Magnitude < 0.01)
	assert(type(flag:GetAttribute("Building")) == "string")
end
assert(not folder.SignalSent.Value)
local send = stations.Transmitter:FindFirstChild("ProximityPrompt", true)
local found = false
for _, p in ipairs(stations.Transmitter:GetChildren()) do
	if p:IsA("ProximityPrompt") and p.ActionText == "Send signal" then found = true; assert(not p.Enabled) end
end
assert(found)
print("Rescue assignment checks passed")
