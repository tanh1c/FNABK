-- Extend three B12 upper classroom doors down to their actual, shorter-storey floor.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B12
local floor=b.B12.WalkableStructure.WalkableFloor_02_East
local top=floor.Position.Y+floor.Size.Y/2
local plans={}
local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={b}
for _,d in ipairs(b:GetDescendants()) do
 if d:IsA("BasePart") and d.Name=="InteriorClassDoor" and (d:GetAttribute("ClassroomID") or ""):match("^B12%-2") then
  local closed,open=d:GetAttribute("DoorClosed"),d:GetAttribute("DoorOpen")
  local extend=closed.Position.Y-d.Size.Y/2-top-.03
  assert(extend>1.3 and extend<1.5 and not d:GetAttribute("BeforeB12Height_v1"))
  local size=d.Size+Vector3.new(0,extend,0);local shift=Vector3.new(0,-extend/2,0)
  for _,pose in ipairs({closed+shift,open+shift}) do
   local testSize=Vector3.new(math.max(.01,size.X-.12),size.Y-.2,math.max(.01,size.Z-.12))
   for _,v in ipairs(workspace:GetPartBoundsInBox(pose,testSize,p)) do
    assert(v==d or not v.CanCollide or v:GetAttribute("CampusDoor") or v.Name:match("^WalkableFloor") or v.Name:match("^HallRunner"),d:GetFullName().." intersects "..v:GetFullName())
   end
  end
  table.insert(plans,{d,size,closed+shift,open+shift})
 end
end
assert(#plans==3)
for _,v in ipairs(plans) do
 local d,size,closed,open=table.unpack(v)
 d:SetAttribute("BeforeB12Height_v1",d.Size)
 d:SetAttribute("BeforeB12Closed_v1",d:GetAttribute("DoorClosed"))
 d:SetAttribute("BeforeB12Open_v1",d:GetAttribute("DoorOpen"))
 d.Size=size;d:SetAttribute("DoorClosed",closed);d:SetAttribute("DoorOpen",open)
 d.CFrame=if d:GetAttribute("StartsOpen") then open else closed
end
return "Aligned three B12 upper classroom doors to their floor"
