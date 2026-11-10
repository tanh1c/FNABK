-- Replace compressed A2 reading-chair blocks with usable seats and retain the originals.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.A2
local storage=game:GetService("ServerStorage")
assert(not b:FindFirstChild("A2ReadingSeats_v1") and not storage:FindFirstChild("A2ReadingChairsBefore_v1"))
local floors={}
for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floors,v) end end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=floors;ray.RespectCanCollide=true
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
local plans={}
for _,room in ipairs(b:GetDescendants()) do
 if room:IsA("Model") and room:GetAttribute("CampusRoomId") then
  local t=room:FindFirstChild("ReadingTable")
  if t then
   for _,chair in ipairs(room:GetChildren()) do
    if chair:IsA("BasePart") and chair.Name:match("^ReadingChair") then
     assert(chair.Anchored and chair.CanCollide and #chair:GetChildren()==0)
     local dir=chair.Position-t.Position;dir=Vector3.new(dir.X,0,dir.Z)
     assert(dir.Magnitude>.1);dir=dir.Unit
     local radius=math.abs(dir:Dot(t.CFrame.RightVector))*t.Size.X/2+math.abs(dir:Dot(t.CFrame.LookVector))*t.Size.Z/2
     local pos=t.Position+dir*(radius+1.1)
     local hit=workspace:Raycast(Vector3.new(pos.X,t.Position.Y+2,pos.Z),Vector3.new(0,-6,0),ray)
     assert(hit,"Reading seat has no floor: "..room:GetAttribute("CampusRoomId"))
     local y=hit.Position.Y
     local frame=CFrame.lookAt(Vector3.new(pos.X,y+1.05,pos.Z),Vector3.new(t.Position.X,y+1.05,t.Position.Z))
     for _,x in ipairs({-.45,.45}) do for _,z in ipairs({-.45,.45}) do
      local pt=frame:PointToWorldSpace(Vector3.new(x,2,z))
      local support=workspace:Raycast(pt,Vector3.new(0,-5,0),ray)
      assert(support and math.abs(support.Position.Y-y)<.1,"Reading seat lacks floor support")
     end end
     local volume=CFrame.new(pos.X,y+2.5,pos.Z)
     for _,v in ipairs(workspace:GetPartBoundsInBox(volume,Vector3.new(1.5,3.3,1.5),overlap)) do
      assert(v==chair or not v.CanCollide or v:GetAttribute("CampusDoor") or v.Name:match("^WalkableFloor") or v.Name:match("^HallRunner"),"Reading seat overlaps "..v:GetFullName())
     end
     table.insert(plans,{old=chair,room=room,frame=frame,floorY=y})
    end
   end
  end
 end
end
assert(#plans==54,"Unexpected reading-chair count: "..#plans)
local output=Instance.new("Folder");output.Name="A2ReadingSeats_v1"
local backup=Instance.new("Folder");backup.Name="A2ReadingChairsBefore_v1";backup.Parent=storage
for _,plan in ipairs(plans) do
 local chair=Instance.new("Model");chair.Name=plan.room:GetAttribute("CampusRoomId").."_"..plan.old.Name
 local seat=Instance.new("Seat");seat.Name="ReadingSeat";seat.Size=Vector3.new(1.1,.3,1.1);seat.CFrame=plan.frame
 seat.Color=Color3.fromRGB(135,104,73);seat.Material=Enum.Material.WoodPlanks;seat.Anchored=true;seat.Parent=chair
 for _,x in ipairs({-.4,.4}) do for _,z in ipairs({-.4,.4}) do
  local leg=Instance.new("Part");leg.Name="ChairLeg";leg.Size=Vector3.new(.14,.9,.14)
  leg.CFrame=plan.frame*CFrame.new(x,-.6,z);leg.Color=seat.Color;leg.Material=seat.Material
  leg.Anchored=true;leg.CanCollide=false;leg.CanTouch=false;leg.CanQuery=false;leg.CastShadow=false;leg.Parent=chair
 end end
 local back=Instance.new("Part");back.Name="ChairBack";back.Size=Vector3.new(1.1,1,.14);back.CFrame=plan.frame*CFrame.new(0,.55,.48)
 back.Color=seat.Color;back.Material=seat.Material;back.Anchored=true;back.CanCollide=false;back.CanTouch=false;back.CanQuery=false;back.CastShadow=false;back.Parent=chair
 chair.Parent=output
 plan.old:SetAttribute("OriginalParentPath",plan.old.Parent:GetFullName());plan.old.Parent=backup
end
output.Parent=b
return "Added 54 usable reading seats; original chair blocks retained"
