local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local count=0
for _,b in ipairs(bs:GetChildren()) do
 local floors={}
 for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floors,v) end end
 local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances=floors;p.RespectCanCollide=true
 for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") and v:GetAttribute("BeforeFloorAlignment_v1") then
  local hit=workspace:Raycast(v.Position+Vector3.new(0,2,0),Vector3.new(0,-4,0),p)
  assert(hit and math.abs((v.Position.Y-.025)-hit.Position.Y)<.1,v:GetFullName())
  count+=1
 end end
 task.wait()
end
assert(count==43)
return "43 corrected hall runners align with sampled floor height"
