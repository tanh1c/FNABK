-- Run in Studio's command bar with the campus v6 in Workspace.
local campus = assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local city = assert(campus:FindFirstChild("CityOutsideGate1_20261104"))
local counts = {}
for _, item in ipairs(city:GetChildren()) do
	assert(item:IsA("BasePart") and item.Anchored, "City geometry must be anchored parts")
	counts[item.Name] = (counts[item.Name] or 0) + 1
end
assert(counts.House == 12 and counts.Sidewalk == 2 and counts.CenterDash == 12, "City layout is incomplete")
assert(counts.Asphalt == 1 and counts.CityGround == 1, "City ground or road is missing")
local road = assert(city:FindFirstChild("Asphalt"))
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = {city}
params.RespectCanCollide = true
for _, x in ipairs({-140, 0, 140}) do
	local point = road.CFrame:PointToWorldSpace(Vector3.new(x, 10, 5))
	local hit = workspace:Raycast(point, Vector3.new(0, -20, 0), params)
	assert(hit and hit.Instance == road, "Road is not continuous")
end
print("City geometry and road checks passed")
