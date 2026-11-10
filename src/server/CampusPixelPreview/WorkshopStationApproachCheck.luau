-- Sample a character-sized standing area on the control side of each workshop station.
local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local expected = {C1=7, C2=6, C3=6}
for name, count in pairs(expected) do
 local building = buildings[name]
 local workshop = building.WorkshopArchitecture
 local floor = workshop.WorkshopWalkableFloor
 local ray = RaycastParams.new(); ray.FilterType = Enum.RaycastFilterType.Include; ray.FilterDescendantsInstances = {floor}
 local overlap = OverlapParams.new(); overlap.FilterType = Enum.RaycastFilterType.Include; overlap.FilterDescendantsInstances = {building}
 local found = 0
 for _, station in ipairs(workshop:GetChildren()) do
  if station:IsA("BasePart") and (station.Name:match("MechanicalLathe_%d+Base") or station.Name:match("MechatronicsTestCell_%d+Base") or station.Name:match("MechanicalWorkbench_%d+Base")) then
   local point = station.CFrame:PointToWorldSpace(Vector3.new(0,0,station.Size.Z/2+2))
   local center = Vector3.new(point.X,3.2,point.Z)
   assert(workspace:Raycast(center,Vector3.new(0,-5,0),ray), "No floor at " .. station:GetFullName())
   for _, other in ipairs(workspace:GetPartBoundsInBox(CFrame.new(center),Vector3.new(1.8,4.4,1.8),overlap)) do
    assert(not other.CanCollide or other == floor, "Station approach blocked: " .. station:GetFullName() .. " by " .. other:GetFullName())
   end
   found += 1
  end
 end
 assert(found == count, "Unexpected workstation count in " .. name)
end
return "19 workshop station standing areas have sampled floor and clearance"
