-- Samples support beneath B1 furniture and the three workshop machine bases.
local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local b1 = buildings.B1
local floors = {}
for _, part in ipairs(b1:GetChildren()) do
 if part:IsA("BasePart") and part.CanCollide and part.Name:find("Floor") then table.insert(floors, part) end
end
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = floors
local count = 0
for _, part in ipairs(b1.B1_OpenGalleryAndClassrooms_v1:GetDescendants()) do
 if part:IsA("BasePart") and (part.Name == "DeskTop" or part.Name == "ChairSeat") then
  for _, x in ipairs({-.4, .4}) do for _, z in ipairs({-.4, .4}) do
   local origin = part.CFrame:PointToWorldSpace(Vector3.new(x * part.Size.X, 0, z * part.Size.Z))
   assert(workspace:Raycast(origin, Vector3.new(0, -5, 0), ray), "Unsupported B1 furniture: " .. part:GetFullName())
   count += 1
  end end
 end
end
assert(count == 1344)
local machines = 0
for _, name in ipairs({"C1", "C2", "C3"}) do
 local building = buildings[name]
 local workshopFloors = {}
 for _, part in ipairs(building:GetDescendants()) do
  if part:IsA("BasePart") and part.CanCollide and part.Name == "WorkshopWalkableFloor" then table.insert(workshopFloors, part) end
 end
 ray.FilterDescendantsInstances = workshopFloors
 for _, part in ipairs(building:GetDescendants()) do
  if part:IsA("BasePart") and (part.Name:match("MechanicalLathe_%d+Base") or part.Name:match("MechatronicsTestCell_%d+Base") or part.Name:match("MechanicalWorkbench_%d+Base")) then
   assert(workspace:Raycast(part.Position, Vector3.new(0, -6, 0), ray), "Unsupported machine: " .. part:GetFullName())
   machines += 1
  end
 end
end
assert(machines == 19)
return "B1 furniture support sampled at 1,344 points; 19 workshop machine bases supported"
