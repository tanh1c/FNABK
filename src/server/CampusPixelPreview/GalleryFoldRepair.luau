-- Compress remaining obstructed gallery leaves inside their existing opening.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local changes={}
for _,id in ipairs({"B12","C6","KioskOISP"}) do
 local b=bs[id];local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={b}
 local function clear(d,pose,size)
  size=Vector3.new(math.max(.01,size.X-.12),math.max(.01,size.Y-.35),math.max(.01,size.Z-.12))
  for _,v in ipairs(workspace:GetPartBoundsInBox(pose,size,p)) do
   if v~=d and v.CanCollide and not v:GetAttribute("CampusDoor") and not v.Name:match("^WalkableFloor") and not v.Name:match("^HallRunner") then return false end
  end
  return true
 end
 for _,d in ipairs(b:GetDescendants()) do
  if d:IsA("BasePart") and d.Name:match("^GalleryClassroomDoor") and d:GetAttribute("CampusDoor") and not d:GetAttribute("OriginalDoorOpen_v1") and not clear(d,d:GetAttribute("DoorOpen"),d.Size) then
   local c,s=d:GetAttribute("DoorClosed"),d.Size
   assert(s.Z>s.X and not d:GetAttribute("StartsOpen"))
   for i=1,6 do
    local width=s.Z+(.2-s.Z)*i/6
    assert(clear(d,c*CFrame.new(0,0,(s.Z-width)/2),Vector3.new(s.X,s.Y,width)),d:GetFullName().." fold obstructed")
   end
   table.insert(changes,d)
  end
 end
 task.wait()
end
assert(#changes==15,"Unexpected fold candidate count; no changes: "..#changes)
for _,d in ipairs(changes) do
 local s,c=d.Size,d:GetAttribute("DoorClosed")
 d:SetAttribute("OriginalDoorOpen_v1",d:GetAttribute("DoorOpen"))
 d:SetAttribute("DoorClosedSize_v1",s)
 d:SetAttribute("DoorFold_v1",true)
 d:SetAttribute("DoorOpen",c*CFrame.new(0,0,(s.Z-.2)/2))
end
return "Configured 15 gallery leaves to fold within their openings"
