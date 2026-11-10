-- Expose B1 plates on both wall faces and lower C1 labels below the roof curb.
local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local b=buildings.B1
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={b};ray.RespectCanCollide=true
local plans={}
for _,plate in ipairs(b:GetDescendants()) do
 if plate:IsA("BasePart") and (plate.Name=="ClassNumber" or plate.Name=="RoomSign") then
  assert(not plate.CanCollide and not plate.CanQuery and not plate:GetAttribute("BeforeWallClearanceSize_v1"))
  local half=plate.Size.Z/2;local walls=0
  for _,wall in ipairs(workspace:GetPartBoundsInBox(plate.CFrame,plate.Size,overlap)) do
   if wall~=plate and wall.CanCollide and not wall:GetAttribute("CampusDoor") then
    walls+=1
    for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
     local corner=wall.CFrame:PointToWorldSpace(Vector3.new(x*wall.Size.X/2,y*wall.Size.Y/2,z*wall.Size.Z/2))
     half=math.max(half,math.abs(plate.CFrame:PointToObjectSpace(corner).Z))
    end end end
   end
  end
  assert(walls>0);half+=.1;assert(half<1)
  for _,gui in ipairs(plate:GetChildren()) do if gui:IsA("SurfaceGui") and gui.Enabled then
   local direction=if gui.Face==Enum.NormalId.Front then plate.CFrame.LookVector else -plate.CFrame.LookVector
   assert(not workspace:Raycast(plate.Position+direction*(half+1),-direction*.98,ray),"B1 sign face blocked")
  end end
  table.insert(plans,{part=plate,depth=half*2})
 end
end
assert(#plans==112,"Unexpected B1 plate count")
local c1=buildings.C1
local c1ray=RaycastParams.new();c1ray.FilterType=Enum.RaycastFilterType.Include;c1ray.FilterDescendantsInstances={c1};c1ray.RespectCanCollide=true
local lowered={}
for _,plate in ipairs(c1.C1UpperAccess_v1:GetDescendants()) do
 if plate:IsA("BasePart") and plate.Name=="C1UpperRoomNumber" then
  assert(not plate:GetAttribute("BeforeWallClearanceFrame_v1"))
  local nextFrame=plate.CFrame+Vector3.new(0,-1.2,0)
  for _,z in ipairs({-1.3,0,1.3}) do for _,side in ipairs({-1,1}) do
   local direction=plate.CFrame.RightVector*side
   local pos=nextFrame:PointToWorldSpace(Vector3.new(0,0,z))
   assert(not workspace:Raycast(pos+direction*(plate.Size.X/2+1),-direction*.98,c1ray),"C1 sign face blocked")
  end end
  table.insert(lowered,{part=plate,frame=nextFrame})
 end
end
assert(#lowered==4,"Unexpected C1 plate count")
for _,plan in ipairs(plans) do
 plan.part:SetAttribute("BeforeWallClearanceSize_v1",plan.part.Size)
 plan.part.Size=Vector3.new(plan.part.Size.X,plan.part.Size.Y,plan.depth)
end
for _,plan in ipairs(lowered) do
 plan.part:SetAttribute("BeforeWallClearanceFrame_v1",plan.part.CFrame)
 plan.part.CFrame=plan.frame
end
return "Exposed 112 B1 plates and lowered four C1 signs below the roof curb"
