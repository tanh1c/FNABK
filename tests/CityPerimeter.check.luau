-- Run in Studio's command bar with the edited campus v6 in Workspace.
local campus = assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local city = assert(campus:FindFirstChild("CityPerimeter_20261104"))
local counts = {}
for _, item in ipairs(city:GetChildren()) do
	assert(item:IsA("BasePart") and item.Anchored, "City elements must be anchored parts")
	counts[item.Name] = (counts[item.Name] or 0) + 1
end
assert((counts.House or 0) >= 40 and (counts.Sidewalk or 0) >= 8, "Perimeter buildings or sidewalks are missing")
assert(counts.Gate1Approach == 1 and counts.NorthGateApproach == 2, "Gate approaches are missing")
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = {city}
params.RespectCanCollide = true
local function paved(point: Vector3)
	local hit = workspace:Raycast(point + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), params)
	assert(hit and (hit.Instance.Name:find("Road") or hit.Instance.Name:find("Approach")), "Road sample is not paved")
end
for _, name in ipairs({"WestRoad", "EastRoad", "NorthRoad", "SouthRoad", "Gate1Approach"}) do
	local road = assert(city:FindFirstChild(name))
	paved(road.Position)
end
for _, road in ipairs(city:GetChildren()) do
	if road.Name == "NorthGateApproach" then paved(road.Position) end
end
local west, east = city.WestRoad.Position.X, city.EastRoad.Position.X
local north, south = city.NorthRoad.Position.Z, city.SouthRoad.Position.Z
for _, x in ipairs({west, east}) do for _, z in ipairs({north, south}) do paved(Vector3.new(x, 0, z)) end end
print("City perimeter roads, corners and gate approaches passed")
