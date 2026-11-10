-- Sample C1's bridge, four room doors, sweep clearance and workshop furniture.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.C1
local group=assert(b:FindFirstChild("C1UpperAccess_v1"))
assert(game.ServerStorage:FindFirstChild("C1UpperPartitionsBefore_v1"))
local floor=b.WorkshopArchitecture.UpperWalkableServiceFloor
local bridge=group.ServiceBridge
assert(bridge.CanCollide and bridge.Size.X>120 and bridge.Size.Z>=5)
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances={bridge,floor};ray.RespectCanCollide=true
local stair=b.WorkshopArchitecture.UpperFloorStair_16
local from=floor.CFrame:PointToObjectSpace(stair.Position).X
for i=1,20 do
 local x=from+(-floor.Size.X/2-from)*i/20
 local pt=floor.CFrame:PointToWorldSpace(Vector3.new(x,5,4.5))
 assert(workspace:Raycast(pt,Vector3.new(0,-7,0),ray),"C1 bridge floor gap")
end
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
local doors,labels,rooms,seats=0,0,0,0
for _,v in ipairs(group:GetDescendants()) do
 if v:IsA("BasePart") and v:GetAttribute("CampusDoor") then
  local closed=v:GetAttribute("DoorClosed");local offset=v:GetAttribute("SwingHingeOffset_v1");local angle=v:GetAttribute("SwingAngle_v1")
  assert(typeof(closed)=="CFrame" and typeof(offset)=="Vector3" and typeof(angle)=="number")
  for i=0,6 do
   local cf=closed*CFrame.new(offset)*CFrame.Angles(0,angle*i/6,0)*CFrame.new(-offset)
   for _,hit in ipairs(workspace:GetPartBoundsInBox(cf,Vector3.new(.04,v.Size.Y-.3,v.Size.Z-.12),overlap)) do
    assert(hit==v or not hit.CanCollide or hit:GetAttribute("CampusDoor") or hit==floor,v.Name.." intersects "..hit:GetFullName())
   end
  end
  doors+=1
 elseif v:IsA("BasePart") and v.Name=="C1UpperRoomNumber" then labels+=1
 elseif v:IsA("Model") and v.Parent==group.UpperWorkshopFurniture then rooms+=1
 elseif v:IsA("Seat") then seats+=1 end
end
assert(doors==4 and labels==4 and rooms==4 and seats==8)
return "C1 bridge samples, four door sweeps, four numbered rooms and eight seats checked"
