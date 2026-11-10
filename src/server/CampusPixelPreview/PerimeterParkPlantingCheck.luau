local root = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local folder = root.CampusPerimeterPlanting_v1.grass16
local floor = RaycastParams.new(); floor.FilterType = Enum.RaycastFilterType.Include; floor.FilterDescendantsInstances = {root.CampusExactGrass_v1.grass16}; floor.RespectCanCollide = true
local overlap = OverlapParams.new(); overlap.FilterType = Enum.RaycastFilterType.Include; overlap.FilterDescendantsInstances = {root.Buildings, root.CampusBoundaryAndGates_v1}
local count = 0
for _, tree in ipairs(folder:GetChildren()) do
 local trunk = assert(tree:FindFirstChild("Trunk"))
 local base = trunk.Position - Vector3.new(0,trunk.Size.Y/2,0)
 for _, x in ipairs({-4,4}) do for _, z in ipairs({-4,4}) do
  assert(workspace:Raycast(base+Vector3.new(x,5,z),Vector3.new(0,-10,0),floor), "Canopy extends beyond grass: " .. tree.Name)
 end end
 for _, other in ipairs(workspace:GetPartBoundsInBox(CFrame.new(base+Vector3.new(0,5,0)),Vector3.new(9,10,9),overlap)) do
  assert(not other.CanCollide, "Plant overlaps building or boundary: " .. tree.Name)
 end
 for _, plantFolder in ipairs({root.CampusGrass_v1,root.CampusParkDetails_v1,root.CampusNarrowPlanting_v1,root.CampusPerimeterPlanting_v1}) do
  for _, part in ipairs(plantFolder:GetDescendants()) do
   if part:IsA("Seat") or (part:IsA("BasePart") and part.Name=="Trunk" and part~=trunk) then
    assert((Vector3.new(part.Position.X-base.X,0,part.Position.Z-base.Z)).Magnitude >= 14.9, "Plant too close to seat or tree: " .. tree.Name)
   end
  end
 end
 count += 1
end
assert(count == 16)
return "16 perimeter trees sampled inside grass and clear of buildings, seats and other trees"
