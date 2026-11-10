-- Check eight unnumbered ground-floor access doors lead to supported open space.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local count=0
for _,b in ipairs(bs:GetChildren()) do
 local hall
 for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") and v.Name=="HallRunner_Floor_01" then hall=v;break end end
 for _,plate in ipairs(b:GetDescendants()) do
  if plate:IsA("BasePart") and plate.Name=="ClassroomNumber" and plate:GetAttribute("RoomLabel")=="LỐI ĐI" then
   local door
   for _,v in ipairs(plate.Parent:GetChildren()) do
    if v:IsA("BasePart") and v:GetAttribute("CampusDoor") and v.Name:match("_F01_") and (Vector3.new(v.Position.X,0,v.Position.Z)-Vector3.new(plate.Position.X,0,plate.Position.Z)).Magnitude<.2 then assert(not door);door=v end
   end
   assert(door,"Missing access door: "..b.Name)
   local cf=door:GetAttribute("DoorClosed");local n=door.Size.X<door.Size.Z and cf.RightVector or cf.LookVector
   if hall and (hall.Position-cf.Position):Dot(n)<0 then n=-n end
   local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={b};p.RespectCanCollide=true
   for _,distance in ipairs({2,5,10,15,20}) do
    local point=cf.Position+n*distance;point=Vector3.new(point.X,3.5,point.Z)
    local hit=workspace:Raycast(point,Vector3.new(0,-5,0),p)
    assert(hit and hit.Instance.Name=="WalkableFloor_01","Access has no floor: "..b.Name)
   end
   local origin=Vector3.new(cf.X,3,cf.Z)+n
   assert(not workspace:Raycast(origin,n*19,p),"Access blocked: "..b.Name)
   count+=1
  end
 end
 task.wait()
end
assert(count==8)
return "Eight access doors lead toward sampled supported open space"
