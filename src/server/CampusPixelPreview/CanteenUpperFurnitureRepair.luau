-- Move two dining sets clear of the Canteen stair opening and adjacent seats.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
assert(not b:FindFirstChild("CanteenStairFurnitureRelocation_v1"))
local floorParts={}
for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floorParts,v) end end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=floorParts;ray.RespectCanCollide=true
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
local plans,moving={},{}
for _,spec in ipairs({
 {room=b.Canteen.Furnishings.F01_Classroom_12,delta=Vector3.new(6,0,0),ground=true},
 {room=b.Canteen.Furnishings.F02_Classroom_25,delta=Vector3.new(6,0,-4),ground=false},
}) do
 local count=0
 for _,v in ipairs(spec.room:GetDescendants()) do
  if v:IsA("BasePart") and ((spec.ground and v:GetAttribute("BeforeCanteenStairCFrame_v1")) or (not spec.ground and v.Position.X>5355.5)) then
   assert(v.Anchored and not v:GetAttribute("BeforeCanteenStairRelocation_v1"))
   table.insert(plans,{part=v,delta=spec.delta});moving[v]=true;count+=1
  end
 end
 assert(count==8,"Unexpected dining set: "..spec.room.Name.." "..count)
end
for _,plan in ipairs(plans) do
 local v=plan.part
 if v.CanCollide and v.Transparency<.9 then
  local target=v.CFrame+plan.delta
  for _,x in ipairs({-.4,.4}) do for _,z in ipairs({-.4,.4}) do
   local point=target:PointToWorldSpace(Vector3.new(v.Size.X*x,2,v.Size.Z*z))
   local floor=workspace:Raycast(point,Vector3.new(0,-5,0),ray)
   assert(floor and math.abs(floor.Position.Y-(target.Position.Y-v.Size.Y/2))<.5,"Dining furniture has no floor")
  end end
  for _,q in ipairs(workspace:GetPartBoundsInBox(target,v.Size*.95,overlap)) do
   assert(moving[q] or not q.CanCollide or q:GetAttribute("CampusDoor") or q.Name:match("^WalkableFloor") or q.Name:match("^HallRunner"),"Dining move overlaps "..q:GetFullName())
  end
 end
end
for _,plan in ipairs(plans) do
 local v=plan.part;v:SetAttribute("BeforeCanteenStairRelocation_v1",v.CFrame);v.CFrame=v.CFrame+plan.delta
end
local marker=Instance.new("Folder");marker.Name="CanteenStairFurnitureRelocation_v1";marker:SetAttribute("MovedParts",#plans);marker.Parent=b
return "Moved two dining sets clear of the Canteen stair opening"
