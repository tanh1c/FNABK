-- Run in Studio's command bar with the edited campus v6 in Workspace.
local campus = assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local gate = assert(campus.CampusBoundaryAndGates_v1.BoundaryEdge_1:FindFirstChild("CampusGate_1"))
local header = assert(gate:FindFirstChild("GateHeader"))
local monument = assert(campus:FindFirstChild("Gate1Monument_20261104"))
local tower = assert(monument:FindFirstChild("BlueTower"))
assert(tower:IsA("BasePart") and tower.Size.Y >= 40, "Gate 1 tower is missing")
assert(monument:FindFirstChild("BKMonogram") and monument:FindFirstChild("UniversityNamePlaque"), "Gate lettering is missing")
local flags = 0
for _, item in ipairs(monument:GetChildren()) do
	if item.Name == "RedFlag" then flags += 1 end
	assert(item:IsA("BasePart") and item.Anchored, "Monument elements must be anchored parts")
end
assert(flags == 4, "Flag details are missing")
local frame = CFrame.new(header.Position.X,0,header.Position.Z) * header.CFrame.Rotation
local params = OverlapParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = {monument}
params.RespectCanCollide = true
assert(#workspace:GetPartBoundsInBox(frame*CFrame.new(0,4,0),Vector3.new(24,8,6),params) == 0, "Monument blocks the entrance")
print("Gate 1 monument and entrance clearance checks passed")
