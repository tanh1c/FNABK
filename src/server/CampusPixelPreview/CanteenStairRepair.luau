-- Replace the compressed canteen stair with a wider, walkable flight.
-- The former steps and floor slabs are preserved; the new opening is cut from native Parts.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
local source=b.Canteen
local stairs=source.StairsAndLandings
local structure=source.WalkableStructure
local storage=game:GetService("ServerStorage")
assert(not b:FindFirstChild("CanteenAccessibleStair_v1") and not storage:FindFirstChild("CanteenStairBefore_v1"))
local a=assert(stairs:FindFirstChild("B10_Stair_Floor_01_Step_01"))
local z=assert(stairs:FindFirstChild("B10_Stair_Floor_01_Step_16"))
local dir=z.Position-a.Position;dir=Vector3.new(dir.X,0,dir.Z).Unit
local start=z.Position-dir*22.5;local finish=z.Position
local center=(start+finish)/2
local savedFloor,savedStairs={},{}
for _,v in ipairs(structure:GetChildren()) do if v:IsA("BasePart") and v.Name:match("^WalkableFloor_02_") then
 assert(v.Anchored and #v:GetChildren()==0 and v.CFrame.UpVector.Y>.999)
 table.insert(savedFloor,v)
end end
for _,v in ipairs(stairs:GetChildren()) do if v:IsA("BasePart") and v.Name:match("^B10_Stair_Floor_0[12]_") then
 assert(v.Anchored and #v:GetChildren()==0);table.insert(savedStairs,v)
end end
assert(#savedFloor==4 and #savedStairs==44)
local priorStringers={}
local stringers=b:FindFirstChild("StairStringers_v1")
if stringers then for _,v in ipairs(stringers:GetChildren()) do if v.Name:match("^Flight_02_Stringer_") then table.insert(priorStringers,v) end end end
assert(#priorStringers==2)
local furniture=source.Furnishings.F01_Classroom_12
local moved={}
for _,v in ipairs(furniture:GetDescendants()) do if v:IsA("BasePart") and (v.Position-a.Position):Dot(dir)>-15.5 then
 assert(v.Anchored and not v:GetAttribute("BeforeCanteenStairCFrame_v1"));table.insert(moved,v)
end end
assert(#moved==8,"Unexpected nearby furniture count: "..#moved)
local output=Instance.new("Folder");output.Name="CanteenAccessibleStair_v1"
local slabs=Instance.new("Folder");slabs.Name="UpperFloor";slabs.Parent=output
local function addSlab(original,x0,x1,z0,z1)
 if x1-x0<.05 or z1-z0<.05 then return end
 local p=original:Clone();p.Name=original.Name.."_StairTrim"
 p.Size=Vector3.new(x1-x0,original.Size.Y,z1-z0)
 p.CFrame=original.CFrame*CFrame.new((x0+x1)/2,0,(z0+z1)/2);p.Parent=slabs
end
for _,floor in ipairs(savedFloor) do
 assert(math.abs(floor.CFrame.RightVector:Dot(a.CFrame.RightVector))>.999)
 local q=floor.CFrame:PointToObjectSpace(Vector3.new(center.X,floor.Position.Y,center.Z))
 local x0,x1=-floor.Size.X/2,floor.Size.X/2
 local z0,z1=-floor.Size.Z/2,floor.Size.Z/2
 local l,r=math.max(x0,q.X-2.35),math.min(x1,q.X+2.35)
 local u,v=math.max(z0,q.Z-13),math.min(z1,q.Z+13)
 if l>=r or u>=v then addSlab(floor,x0,x1,z0,z1) else
  addSlab(floor,x0,l,z0,z1);addSlab(floor,r,x1,z0,z1)
  addSlab(floor,l,r,z0,u);addSlab(floor,l,r,v,z1)
 end
end
local treadFolder=Instance.new("Folder");treadFolder.Name="Treads";treadFolder.Parent=output
local rise=12.85714/16
for i=1,16 do
 local t=(i-1)/15;local position=start:Lerp(finish,t);local height=rise*i
 local part=Instance.new("Part");part.Name=string.format("CanteenStair_%02d",i)
 part.Size=Vector3.new(3.5,height,1.6)
 part.CFrame=CFrame.new(position.X,.8+height/2,position.Z)*a.CFrame.Rotation
 part.Color=a.Color;part.Material=a.Material;part.Anchored=true;part.CanCollide=true;part.Parent=treadFolder
end
local rails=Instance.new("Folder");rails.Name="Handrails";rails.Parent=output
for _,side in ipairs({-1,1}) do
 local offset=a.CFrame.RightVector*(side*1.95)
 local low=Vector3.new(start.X,.8+rise+2.7,start.Z)+offset
 local high=Vector3.new(finish.X,.8+12.85714+2.7,finish.Z)+offset
 local beam=Instance.new("Part");beam.Name="Handrail";beam.Size=Vector3.new(.16,.16,(high-low).Magnitude)
 beam.CFrame=CFrame.lookAt((low+high)/2,high);beam.Color=Color3.fromRGB(75,87,88);beam.Material=Enum.Material.Metal
 beam.Anchored=true;beam.CanCollide=false;beam.CanTouch=false;beam.CanQuery=false;beam.Parent=rails
 for _,t in ipairs({0,.33,.66,1}) do
  local top=low:Lerp(high,t);local post=Instance.new("Part");post.Name="Post"
  post.Size=Vector3.new(.16,2.7,.16);post.CFrame=CFrame.new(top-Vector3.new(0,1.35,0))
  post.Color=beam.Color;post.Material=beam.Material;post.Anchored=true;post.CanCollide=false;post.CanTouch=false;post.CanQuery=false;post.Parent=rails
 end
end
local backup=Instance.new("Folder");backup.Name="CanteenStairBefore_v1";backup.Parent=storage
for _,v in ipairs(savedFloor) do v:SetAttribute("OriginalParentPath",v.Parent:GetFullName());v.Parent=backup end
for _,v in ipairs(savedStairs) do v:SetAttribute("OriginalParentPath",v.Parent:GetFullName());v.Parent=backup end
for _,v in ipairs(priorStringers) do v:SetAttribute("OriginalParentPath",v.Parent:GetFullName());v.Parent=backup end
for _,v in ipairs(moved) do v:SetAttribute("BeforeCanteenStairCFrame_v1",v.CFrame);v.CFrame=v.CFrame+Vector3.new(0,0,-4) end
output.Parent=b
return "Built a wider 16-step Canteen stair and preserved old slabs and stair"
