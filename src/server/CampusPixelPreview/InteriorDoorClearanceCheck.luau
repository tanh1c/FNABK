-- Check a character-sized volume at each interior doorway with door leaves open.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local count=0
for _,b in ipairs(bs:GetChildren()) do
 local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={b}
 for _,d in ipairs(b:GetDescendants()) do
  if d:IsA("BasePart") and d.Name=="InteriorClassDoor" then
   local cf=d:GetAttribute("DoorClosed");local thinX=d.Size.X<d.Size.Z
   local width=math.min(2,(thinX and d.Size.Z or d.Size.X)-.2)
   assert(width>1.5,"Door too narrow: "..d:GetFullName())
   local size=thinX and Vector3.new(2.5,4.5,width) or Vector3.new(width,4.5,2.5)
   local center=cf*CFrame.new(0,-d.Size.Y/2+2.35,0)
   for _,v in ipairs(workspace:GetPartBoundsInBox(center,size,params)) do
    assert(v==d or not v.CanCollide or v:GetAttribute("CampusDoor") or v.Name:match("^WalkableFloor") or v.Name:match("^HallRunner"),d:GetFullName().." blocked by "..v:GetFullName())
   end
   count+=1
  end
 end
 task.wait()
end
assert(count==446)
return "446 interior doorways have sampled character-sized clearance"
