-- Sample a character-sized volume through the 20 workshop bay/shutter openings.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local count=0
for _,id in ipairs({"C1","C2","C3"}) do
 local b=bs[id]
 local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={b}
 for _,d in ipairs(b:GetDescendants()) do
  if d:IsA("BasePart") and d:GetAttribute("CampusDoor") and (d.Name:match("^OpenBayShadow") or d.Name=="MainWorkshopShutter") then
   local cf=d:GetAttribute("DoorClosed");local size=d:GetAttribute("DoorClosedSize_v1") or d.Size
   local thinX=size.X<size.Z
   local box=thinX and Vector3.new(3,4.5,2.5) or Vector3.new(2.5,4.5,3)
   local center=cf*CFrame.new(0,-size.Y/2+2.35,0)
   for _,v in ipairs(workspace:GetPartBoundsInBox(center,box,p)) do
    assert(v==d or not v.CanCollide or v:GetAttribute("CampusDoor") or v.Name:find("Floor",1,true) or v.Name:match("^WorkshopSlab"),d:GetFullName().." blocked by "..v:GetFullName())
   end
   count+=1
  end
 end
end
assert(count==20)
return "20 workshop bay openings have sampled character-sized clearance"
