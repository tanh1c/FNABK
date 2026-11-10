-- Add a central-side C6 entrance and retain the earlier entrance as a secondary door.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local b=root.Buildings.C6
local old=assert(b:FindFirstChild("CenterFacingEntrance_v1"))
assert(not b:FindFirstChild("SecondaryEntrance_v1") and not b:FindFirstChild("C6CentralRaisedID_v1"))
local storage=game:GetService("ServerStorage")
assert(not storage:FindFirstChild("C6CentralEntranceOriginal_v1"))
local wall=b.C6.WalkableStructure.OuterWall_Floor_01_North
local hall=b.C6.WalkableStructure.HallRunner_Floor_01
assert(#wall:GetChildren()==0 and wall.Size.X>8 and wall.Size.Z<4)
local outward=wall.CFrame.LookVector
if outward:Dot(wall.Position-hall.Position)<0 then outward=-outward end
assert(outward.X>.99,"C6 central side changed")
local frame=CFrame.fromMatrix(Vector3.new(wall.Position.X,0,wall.Position.Z),Vector3.yAxis:Cross(outward),Vector3.yAxis,outward)
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={wall};ray.RespectCanCollide=true
for _,x in ipairs({-1,0,1}) do for _,y in ipairs({2.5,4.5,6.5}) do
 assert(not workspace:Raycast(frame:PointToWorldSpace(Vector3.new(x,y,8)),-outward*16,ray),"C6 approach obstructed")
end end
for _,z in ipairs({-6,-3,3,6,10,15}) do
 local hit=workspace:Raycast(frame:PointToWorldSpace(Vector3.new(0,4,z)),Vector3.new(0,-7,0),ray)
 assert(hit,"C6 approach lacks floor")
end
local entry=Instance.new("Model");entry.Name="CenterFacingEntrance_v1";entry:SetAttribute("EntranceDirection","toward_central_road")
local function wallSection(x0,x1,y0,y1)
 local part=wall:Clone();part.Name="C6CentralWallTrim"
 part.Size=Vector3.new(x1-x0,y1-y0,wall.Size.Z)
 part.CFrame=wall.CFrame*CFrame.new((x0+x1)/2,(y0+y1)/2,0)
 part.Parent=entry
end
local lo,hi=-wall.Size.Y/2,wall.Size.Y/2
wallSection(-wall.Size.X/2,-1.8,lo,hi)
wallSection(1.8,wall.Size.X/2,lo,hi)
wallSection(-1.8,1.8,8.8-wall.Position.Y,hi)
local function part(name,size,cf,color,material,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material
 p.Anchored=true;p.CanCollide=collide;p.CanTouch=false;p.Parent=entry;return p
end
part("EntryCanopy",Vector3.new(7,.55,4.5),frame*CFrame.new(0,10.2,2.5),Color3.fromRGB(42,79,100),Enum.Material.Concrete,true)
for _,x in ipairs({-3,3}) do part("EntryColumn",Vector3.new(.6,10,.6),frame*CFrame.new(x,5,4.2),Color3.fromRGB(221,220,207),Enum.Material.Concrete,true) end
local closed=frame*CFrame.new(0,4.8,0)
local offset=Vector3.new(-1.6,0,0)
local angle=-math.pi/2
local opened=closed*CFrame.new(offset)*CFrame.Angles(0,angle,0)*CFrame.new(-offset)
local door=part("MainEntryDoor",Vector3.new(3.2,8,.2),opened,Color3.fromRGB(120,86,59),Enum.Material.WoodPlanks,false)
door:SetAttribute("CampusDoor",true);door:SetAttribute("DoorClosed",closed);door:SetAttribute("DoorOpen",opened);door:SetAttribute("StartsOpen",true)
door:SetAttribute("SwingHingeOffset_v1",offset);door:SetAttribute("SwingAngle_v1",angle)
local sign=b.RaisedBuildingID_v1:Clone();sign.Name="C6CentralRaisedID_v1";sign:PivotTo(frame*CFrame.new(0,18,4.5))
local backup=Instance.new("Folder");backup.Name="C6CentralEntranceOriginal_v1";backup.Parent=storage
wall:SetAttribute("OriginalParentPath",wall.Parent:GetFullName());wall.Parent=backup
old.Name="SecondaryEntrance_v1";old:SetAttribute("EntranceDirection","secondary")
old.MainEntryDoor.Name="SecondaryEntryDoor"
entry.Parent=b;sign.Parent=b
return "Added C6 central-side main entrance; prior entry retained as secondary"
