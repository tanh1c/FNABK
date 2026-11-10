-- Verify both canteen floors support all dining furniture and resized seats do not overlap.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
local floors={}
for _,v in ipairs(b:GetDescendants()) do
 if v:IsA("BasePart") and v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floors,v) end
end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=floors;ray.RespectCanCollide=true
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
local parts,seats=0,0
for _,room in ipairs(b:GetDescendants()) do
 if room:IsA("Model") and room:GetAttribute("CampusAreaType")=="DiningFurnitureGroup" then
  for _,v in ipairs(room:GetDescendants()) do
   if v:IsA("BasePart") and v.CanCollide and v.Transparency<.9 then
    local bottom=v.Position.Y-v.Size.Y/2
    for _,x in ipairs({-.4,.4}) do for _,z in ipairs({-.4,.4}) do
     local point=v.CFrame:PointToWorldSpace(Vector3.new(v.Size.X*x,2,v.Size.Z*z))
     local hit=workspace:Raycast(point,Vector3.new(0,-5,0),ray)
     assert(hit and math.abs(hit.Position.Y-bottom)<.5,"Unsupported dining furniture: "..v:GetFullName())
    end end
    if v:IsA("Seat") then
     assert(v:GetAttribute("BeforeCanteenSeatSize_v1") and math.abs(v.Size.X-1.2)<.01)
     for _,q in ipairs(workspace:GetPartBoundsInBox(v.CFrame,v.Size*.95,overlap)) do
      assert(q==v or not q.CanCollide or q:GetAttribute("CampusDoor") or q.Name:match("^WalkableFloor") or q.Name:match("^HallRunner"),"Dining seat overlaps "..q:GetFullName())
     end
     seats+=1
    end
    parts+=1
   end
  end
 end
end
assert(parts==125 and seats==50)
assert(b.CanteenStairFurnitureRelocation_v1:GetAttribute("MovedParts")==16)
return "125 dining furniture parts are supported; 50 resized seats have no sampled overlaps"
