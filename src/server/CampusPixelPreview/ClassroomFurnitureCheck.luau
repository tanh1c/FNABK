-- Verify added desks and benches are floor-supported and do not overlap other collidable parts.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local marker=assert(root:FindFirstChild("CampusClassroomFurniture_v1"))
local count=0
for _,b in ipairs(root.Buildings:GetChildren()) do
 local floors={}
 for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floors,v) end end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=floors;ray.RespectCanCollide=true
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
 for _,room in ipairs(b:GetDescendants()) do
  if room:IsA("Model") and room:FindFirstChild("ExtraStudentFurniture_v1") then
   local folder=room.ExtraStudentFurniture_v1
   assert(room:GetAttribute("CampusRoomId") and folder:FindFirstChild("StudentDesk_Extra") and folder:FindFirstChild("StudentBench_Extra"))
   for _,item in ipairs(folder:GetChildren()) do
    assert(item:IsA("BasePart") and item.Anchored and item.CanCollide)
    local hit=workspace:Raycast(item.Position+Vector3.new(0,2,0),Vector3.new(0,-6,0),ray)
    assert(hit and math.abs(hit.Position.Y-(item.Position.Y-item.Size.Y/2))<2,"Unsupported furniture: "..room:GetFullName())
    for _,v in ipairs(workspace:GetPartBoundsInBox(item.CFrame,item.Size*.95,overlap)) do
     assert(v:IsDescendantOf(folder) or not v.CanCollide or v:GetAttribute("CampusDoor") or v.Name:match("^WalkableFloor") or v.Name:match("^HallRunner"),"Furniture overlaps "..v:GetFullName())
    end
   end
   count+=1
  end
 end
 task.wait()
end
assert(count==348 and marker:GetAttribute("ClassroomCount")==count)
return "348 classrooms have added floor-supported desk and bench pairs"
