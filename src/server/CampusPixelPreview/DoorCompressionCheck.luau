-- Sample the compressed doors inside their original closed footprints.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local count=0
for _,b in ipairs(bs:GetChildren()) do
 local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={b}
 for _,d in ipairs(b:GetDescendants()) do
  local size=d:IsA("BasePart") and d:GetAttribute("DoorClosedSize_v1")
  if typeof(size)=="Vector3" then
   local closed=d:GetAttribute("DoorClosed");local fold=d:GetAttribute("DoorFold_v1")==true
   for i=1,6 do
    local t=i/6;local extent=(fold and size.Z or size.Y)*(1-t)+.2*t
    local shape=fold and Vector3.new(size.X,size.Y,extent) or Vector3.new(size.X,extent,size.Z)
    local pose=closed*CFrame.new(0,fold and 0 or (size.Y-extent)/2,fold and (size.Z-extent)/2 or 0)
    if i==6 then assert((pose.Position-d:GetAttribute("DoorOpen").Position).Magnitude<.1) end
    shape=Vector3.new(math.max(.01,shape.X-.12),math.max(.01,shape.Y-.35),math.max(.01,shape.Z-.12))
    for _,v in ipairs(workspace:GetPartBoundsInBox(pose,shape,p)) do
     assert(v==d or not v.CanCollide or v:GetAttribute("CampusDoor") or v.Name:match("^WalkableFloor") or v.Name:match("^HallRunner"),d:GetFullName().." intersects "..v:GetFullName())
    end
   end
   count+=1
  end
 end
 task.wait()
end
assert(count==35)
return "35 compressed doors: six sampled positions checked"
