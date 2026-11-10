-- Studio Play server; isolated station state only, not a complete saved run. SURV-01/10/11.
local service = require(game.ServerScriptService.FNABKServer.RescueObjectives)
local round = game.ReplicatedStorage.FNABKRoundState
local campus = Instance.new("Model")
local buildings = Instance.new("Folder")
buildings.Name, buildings.Parent = "Buildings", campus
for i, name in ipairs({ "B3", "A1", "C1" }) do
	local building = Instance.new("Model")
	building.Name, building.Parent = name, buildings
	local floor = Instance.new("Part")
	floor.Name, floor.Size, floor.Position, floor.Parent = "WalkableFloor", Vector3.new(30, 1, 30), Vector3.new(i * 100, 2000, 0), building
end
local function start(saved)
	local before = {}
	for _, obj in ipairs(round:GetChildren()) do before[obj] = true end
	for _, obj in ipairs(workspace:GetChildren()) do before[obj] = true end
	local signaled = 0
	service.Start(campus, function() signaled += 1; return true end, saved)
	local folder, points
	for _, obj in ipairs(round:GetChildren()) do if obj.Name == "RescueObjectives" and not before[obj] then folder = obj end end
	for _, obj in ipairs(workspace:GetChildren()) do if obj.Name == "FNABKRescueStations" and not before[obj] then points = obj end end
	assert(folder and points)
	return folder, points, function() return signaled end
end
local original, originalPoints = start()
original.Power.Value, original.Frequency.Value = true, true
local json = game:GetService("HttpService")
local snapshot = json:JSONDecode(json:JSONEncode(assert(service.snapshot(original))))
original:Destroy(); originalPoints:Destroy()
local restored, points, calls = start(snapshot)
assert(restored.Power.Value and restored.Frequency.Value and not restored.Transmitter.Value and not restored.SignalSent.Value)
assert(restored.Power:GetAttribute("Building") == snapshot.stations.Power.building)
assert((restored.Power:GetAttribute("Position") - Vector3.new(snapshot.stations.Power.x, snapshot.stations.Power.y, snapshot.stations.Power.z)).Magnitude < .01)
assert(not points.Power:FindFirstChildWhichIsA("ProximityPrompt").Enabled)
assert(calls() == 0)
restored:Destroy(); points:Destroy()
snapshot.stations.Transmitter.complete = true
restored, points, calls = start(snapshot)
local signalPrompt
for _, prompt in ipairs(points.Transmitter:GetChildren()) do
	if prompt:IsA("ProximityPrompt") and prompt.ActionText == "Send signal" then signalPrompt = prompt end
end
assert(signalPrompt and signalPrompt.Enabled and calls() == 0)
restored:Destroy(); points:Destroy()
snapshot.sent = true
restored, points, calls = start(snapshot)
assert(restored.SignalSent.Value and calls() == 0)
for _, prompt in ipairs(points.Transmitter:GetChildren()) do
	if prompt:IsA("ProximityPrompt") then assert(not prompt.Enabled) end
end
restored:Destroy(); points:Destroy()
snapshot.stations.Transmitter.complete = false
snapshot.sent = true
assert(not pcall(function() start(snapshot) end)) -- cannot restore a signal before all objectives
snapshot.sent = false
snapshot.stations.Power.x += 1
assert(not pcall(function() start(snapshot) end)) -- map layout changed
campus:Destroy()
return "Rescue snapshot checks passed"
