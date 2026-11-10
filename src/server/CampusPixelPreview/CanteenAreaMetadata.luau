-- The open canteen has dining furniture groups, not 25 enclosed classrooms.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
assert(b:FindFirstChild("CanteenOpenHall_v1"))
local groups={}
for _,v in ipairs(b:GetDescendants()) do
 if v:IsA("Model") and v:GetAttribute("CampusRoomId") then
  assert(v:FindFirstChild("DiningDetails_v1") and not v:GetAttribute("FormerClassroomId_v1"))
  table.insert(groups,v)
 end
end
assert(#groups==25)
for _,v in ipairs(groups) do
 v:SetAttribute("FormerClassroomId_v1",v:GetAttribute("CampusRoomId"))
 v:SetAttribute("CampusRoomId",nil)
 v:SetAttribute("CampusAreaType","DiningFurnitureGroup")
end
return "Reclassified 25 open-hall furniture groups; old room IDs retained"
