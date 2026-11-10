-- Extend existing double-sided classroom plates just beyond their enclosing headers.
local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local plans={}
for _,building in ipairs(buildings:GetChildren()) do
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={building}
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={building};ray.RespectCanCollide=true
 for _,plate in ipairs(building:GetDescendants()) do
  if plate:IsA("BasePart") and (plate.Name=="ClassroomNumber" or plate.Name=="InteriorClassroomNumber") then
   assert(not plate.CanCollide and not plate.CanQuery and not plate:GetAttribute("BeforeWallClearanceSize_v1"))
   local half=plate.Size.Z/2;local headers=0
   for _,wall in ipairs(workspace:GetPartBoundsInBox(plate.CFrame,plate.Size,overlap)) do
    if wall~=plate and wall.CanCollide and wall.Name:find("Header") then
     headers+=1
     for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
      local corner=wall.CFrame:PointToWorldSpace(Vector3.new(x*wall.Size.X/2,y*wall.Size.Y/2,z*wall.Size.Z/2))
      half=math.max(half,math.abs(plate.CFrame:PointToObjectSpace(corner).Z))
     end end end
    end
   end
   assert(headers>0,"Missing enclosing header: "..plate:GetFullName())
   half+=.1
   assert(half<1,"Unexpected plate depth: "..plate:GetFullName())
   for _,side in ipairs({-1,1}) do
    local direction=plate.CFrame.LookVector*side
    assert(not workspace:Raycast(plate.Position+direction*(half+1),-direction*.98,ray),"Plate surface obstructed: "..plate:GetFullName())
   end
   table.insert(plans,{plate=plate,depth=half*2})
  end
 end
 task.wait()
end
assert(#plans==782,"Unexpected plate count; nothing changed: "..#plans)
for _,plan in ipairs(plans) do
 plan.plate:SetAttribute("BeforeWallClearanceSize_v1",plan.plate.Size)
 plan.plate.Size=Vector3.new(plan.plate.Size.X,plan.plate.Size.Y,plan.depth)
end
return "Exposed both faces of 782 room and access plates beyond their headers"
