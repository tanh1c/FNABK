-- Connect C1's upper service floor and give its four workshop rooms usable entrances.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.C1
local arch=b.WorkshopArchitecture
local storage=game:GetService("ServerStorage")
assert(not b:FindFirstChild("C1UpperAccess_v1") and not storage:FindFirstChild("C1UpperPartitionsBefore_v1"))
local floor=assert(arch.UpperWalkableServiceFloor)
local stair=assert(arch.UpperFloorStair_16)
local partitions={}
for i=1,4 do
 local p=assert(arch:FindFirstChild(string.format("UpperRoomPartition_%02d",i)))
 assert(p:IsA("BasePart") and p.CanCollide and p.Anchored and #p:GetChildren()==0 and p.CFrame.UpVector.Y>.999)
 assert(math.abs(p.Size.Y-8.8)<.05 and p.Size.Z>10)
 table.insert(partitions,p)
end
local endLocal=floor.CFrame:PointToObjectSpace(stair.Position)
local edge=-floor.Size.X/2
local gap=edge-endLocal.X
assert(gap>120 and gap<140)
local group=Instance.new("Folder");group.Name="C1UpperAccess_v1"
local function part(parent,name,size,cf,color,material,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material
 p.Anchored=true;p.CanCollide=collide;p.CanTouch=false;p.Parent=parent;return p
end
local concrete=Color3.fromRGB(186,188,178);local metal=Color3.fromRGB(75,87,90);local wood=Color3.fromRGB(135,104,73)
local bridge=part(group,"ServiceBridge",Vector3.new(gap+2.4,.5,5.8),floor.CFrame*CFrame.new((endLocal.X+edge)/2,.15,4.5),concrete,Enum.Material.Concrete,true)
-- Guard both edges, stopping at the deck entrance.
for _,outsideZ in ipairs({1.5,7.5}) do
 part(group,"BridgeGuard",Vector3.new(gap+.7,.22,.22),floor.CFrame*CFrame.new((endLocal.X+edge)/2-.85,3.1,outsideZ),metal,Enum.Material.Metal,true)
 for i=0,8 do
  local x=endLocal.X+((gap-.6)*i/8)
  part(group,"BridgePost",Vector3.new(.22,3,.22),floor.CFrame*CFrame.new(x,1.75,outsideZ),metal,Enum.Material.Metal,true)
 end
end
local trim=Instance.new("Folder");trim.Name="PartitionsAndDoors";trim.Parent=group
for i,wall in ipairs(partitions) do
 local min,max=-wall.Size.Z/2,wall.Size.Z/2;local cut0,cut1=1.4,4.6
 local function piece(z0,z1,y,sy,name)
  if z1-z0<.05 then return end
  local q=wall:Clone();q.Name=name;q.Size=Vector3.new(wall.Size.X,sy,z1-z0)
  q.CFrame=wall.CFrame*CFrame.new(0,y,(z0+z1)/2);q.Parent=trim
 end
 piece(min,cut0,0,wall.Size.Y,"RoomPartitionLeft")
 piece(cut1,max,0,wall.Size.Y,"RoomPartitionRight")
 local opening=7.6;local header=wall.Size.Y-opening
 piece(cut0,cut1,wall.Size.Y/2-header/2,header,"RoomDoorHeader")
 local closed=wall.CFrame*CFrame.new(0,-.6,3);local offset=Vector3.new(0,0,1.5);local angle=math.pi/2
 local open=closed*CFrame.new(offset)*CFrame.Angles(0,angle,0)*CFrame.new(-offset)
 local door=part(trim,string.format("C1UpperDoor_%02d",i),Vector3.new(.16,opening,3),open,wood,Enum.Material.WoodPlanks,false)
 door:SetAttribute("CampusDoor",true);door:SetAttribute("DoorClosed",closed);door:SetAttribute("DoorOpen",open);door:SetAttribute("StartsOpen",true)
 door:SetAttribute("SwingHingeOffset_v1",offset);door:SetAttribute("SwingAngle_v1",angle);door:SetAttribute("ClassroomID",string.format("C1-2%02d",i))
 local label=part(trim,"C1UpperRoomNumber",Vector3.new(.12,.8,3.2),wall.CFrame*CFrame.new(-.28,3.65,3),Color3.fromRGB(37,78,98),Enum.Material.SmoothPlastic,false)
 for _,face in ipairs({Enum.NormalId.Left,Enum.NormalId.Right}) do
  local gui=Instance.new("SurfaceGui");gui.Face=face;gui.LightInfluence=0;gui.Parent=label
  local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text=string.format("C1-2%02d",i)
  text.TextScaled=true;text.Font=Enum.Font.GothamBold;text.TextColor3=Color3.fromRGB(245,245,235);text.Parent=gui
 end
end
local rooms=Instance.new("Folder");rooms.Name="UpperWorkshopFurniture";rooms.Parent=group
for i=1,4 do
 local cell=Instance.new("Model");cell.Name=string.format("C1-2%02d",i);cell.Parent=rooms
 local x=-floor.Size.X/2+(i-.5)*(floor.Size.X/4)
 local function at(xoffset,y,z) return floor.CFrame*CFrame.new(x+xoffset,y,z) end
 local desktop=part(cell,"WorkshopBenchTop",Vector3.new(7,.35,2.8),at(0,2,-2.8),wood,Enum.Material.WoodPlanks,true)
 for _,dx in ipairs({-2.8,2.8}) do for _,dz in ipairs({-3.75,-1.85}) do
  part(cell,"BenchLeg",Vector3.new(.28,1.65,.28),at(dx,1.0,dz),metal,Enum.Material.Metal,true)
 end end
 part(cell,"ToolCabinet",Vector3.new(3,3.4,1.2),at(10,2.1,-5.4),metal,Enum.Material.Metal,true)
 local board=part(cell,"ToolBoard",Vector3.new(4,2.4,.12),at(-8,4.4,-5.7),Color3.fromRGB(50,79,80),Enum.Material.SmoothPlastic,false)
 for _,dx in ipairs({-1.8,1.8}) do
  local s=Instance.new("Seat");s.Name="WorkshopSeat";s.Size=Vector3.new(1.2,.35,1.2);s.CFrame=at(dx,1.45,-.6)
  s.Color=metal;s.Material=Enum.Material.Metal;s.Anchored=true;s.Parent=cell
 end
end
local backup=Instance.new("Folder");backup.Name="C1UpperPartitionsBefore_v1";backup.Parent=storage
for _,p in ipairs(partitions) do p:SetAttribute("OriginalParentPath",p.Parent:GetFullName());p.Parent=backup end
group.Parent=b
return "Connected C1 upper floor and added four numbered workshop rooms"
