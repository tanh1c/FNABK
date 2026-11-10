-- Restore usable depth to the canteen seats compressed by the building port.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
assert(not b:FindFirstChild("CanteenSeatScale_v1"))
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
local floorParts={}
for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floorParts,v) end end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=floorParts;ray.RespectCanCollide=true
local plans={}
for _,room in ipairs(b:GetDescendants()) do
 if room:IsA("Model") and room:GetAttribute("CampusAreaType")=="DiningFurnitureGroup" then
  local seats,desks={},{}
  for _,v in ipairs(room:GetDescendants()) do
   if v:IsA("Seat") and v.Name=="DiningSeat" then table.insert(seats,v)
   elseif v:IsA("BasePart") and v.Name:match("^StudentDesk_%d") then table.insert(desks,v) end
  end
  assert(#seats==2 and #desks==2)
  for _,seat in ipairs(seats) do
   local nearest,distance=nil,math.huge
   for _,desk in ipairs(desks) do local n=(desk.Position-seat.Position).Magnitude;if n<distance then nearest,distance=desk,n end end
   assert(nearest and seat.Size.X<.5 and not seat:GetAttribute("BeforeCanteenSeatSize_v1"))
   local delta=seat.Position-nearest.Position;delta=Vector3.new(delta.X,0,delta.Z)
   assert(delta.Magnitude>.2);delta=delta.Unit*.7
   local newSize=Vector3.new(1.2,seat.Size.Y,seat.Size.Z);local newFrame=seat.CFrame+delta
   for _,v in ipairs(workspace:GetPartBoundsInBox(newFrame,newSize*.96,overlap)) do
    assert(v==seat or not v.CanCollide or v:GetAttribute("CampusDoor") or v.Name:match("^WalkableFloor") or v.Name:match("^HallRunner"),"Canteen seat overlaps "..v:GetFullName())
   end
   local hit=workspace:Raycast(newFrame.Position+Vector3.new(0,2,0),Vector3.new(0,-5,0),ray)
   assert(hit and math.abs(hit.Position.Y-(newFrame.Position.Y-newSize.Y/2))<.5,"Canteen seat unsupported")
   table.insert(plans,{seat,newSize,newFrame})
  end
 end
end
assert(#plans==50)
for i=1,#plans do for j=i+1,#plans do
 local a,sa,fa=table.unpack(plans[i]);local b,sb,fb=table.unpack(plans[j])
 if math.abs(fa.Position.Y-fb.Position.Y)<3 then
  local delta=fa.Position-fb.Position
  local radius=(math.sqrt(sa.X^2+sa.Z^2)+math.sqrt(sb.X^2+sb.Z^2))/2+.1
  assert(Vector3.new(delta.X,0,delta.Z).Magnitude>=radius,"Resized canteen seats overlap")
 end
end end
for _,v in ipairs(plans) do
 local seat,size,frame=table.unpack(v)
 seat:SetAttribute("BeforeCanteenSeatSize_v1",seat.Size);seat:SetAttribute("BeforeCanteenSeatCFrame_v1",seat.CFrame)
 seat.Size=size;seat.CFrame=frame
end
local marker=Instance.new("Folder");marker.Name="CanteenSeatScale_v1";marker:SetAttribute("SeatCount",#plans);marker.Parent=b
return "Resized 50 canteen seats with their original transforms retained"
