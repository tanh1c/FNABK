-- ponytail: enrich the largest perimeter lawn; other lawns retain their current planting pending visual review.
local root = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusPerimeterPlanting_v1"))
local manifest = require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin = root:GetAttribute("PreviewOriginWorld")
local feature
for _, item in ipairs(manifest.features) do if item.id == "grass16" then feature = item end end
assert(feature and feature.polygonStuds)
local poly = feature.polygonStuds
local x0, x1, z0, z1 = math.huge, -math.huge, math.huge, -math.huge
for _, v in ipairs(poly) do x0=math.min(x0,v[1]); x1=math.max(x1,v[1]); z0=math.min(z0,v[2]); z1=math.max(z1,v[2]) end
local function inside(x,z)
 local yes=false; local a=poly[#poly]
 for _, b in ipairs(poly) do
  if (a[2]>z) ~= (b[2]>z) and x < (a[1]-b[1])*(z-b[2])/(a[2]-b[2])+b[1] then yes=not yes end
  a=b
 end
 return yes
end
local occupied, entries = {}, {}
for _, folder in ipairs({root.CampusGrass_v1, root.CampusParkDetails_v1, root.CampusNarrowPlanting_v1}) do
 for _, part in ipairs(folder:GetDescendants()) do
  if part:IsA("Seat") or (part:IsA("BasePart") and part.Name == "Trunk") then table.insert(occupied,part.Position) end
 end
end
for _, part in ipairs(root.Buildings:GetDescendants()) do
 if part:IsA("BasePart") and part:GetAttribute("CampusDoor") and (part.Name:find("Main") or part.Name:find("Entry")) then table.insert(entries,part:GetAttribute("DoorClosed").Position) end
end
local overlap=OverlapParams.new(); overlap.FilterType=Enum.RaycastFilterType.Include; overlap.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1}
local floorRay=RaycastParams.new(); floorRay.FilterType=Enum.RaycastFilterType.Include; floorRay.FilterDescendantsInstances={root.CampusExactGrass_v1.grass16}; floorRay.RespectCanCollide=true
local candidates={}
for z=z0+5,z1-5,14 do for x=x0+5,x1-5,14 do
 local good=true
 for _,dx in ipairs({-4.5,4.5}) do for _,dz in ipairs({-4.5,4.5}) do if not inside(x+dx,z+dz) then good=false end end end
 local pos=Vector3.new(origin.X+x,0,origin.Z+z)
 if good then for _,q in ipairs(occupied) do if (Vector3.new(pos.X-q.X,0,pos.Z-q.Z)).Magnitude<15 then good=false;break end end end
 if good then for _,q in ipairs(entries) do if (Vector3.new(pos.X-q.X,0,pos.Z-q.Z)).Magnitude<20 then good=false;break end end end
 if good then for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos+Vector3.new(0,5,0)),Vector3.new(9,10,9),overlap)) do if part.CanCollide then good=false;break end end end
 local ground = good and workspace:Raycast(pos+Vector3.new(0,4,0),Vector3.new(0,-8,0),floorRay)
 if ground then table.insert(candidates,ground.Position);table.insert(occupied,pos) end
end end
assert(#candidates>=16,"Insufficient safe perimeter planting positions")
local output=Instance.new("Folder");output.Name="CampusPerimeterPlanting_v1"
local area=Instance.new("Folder");area.Name="grass16";area.Parent=output
local colors={Color3.fromRGB(55,105,66),Color3.fromRGB(77,123,70),Color3.fromRGB(52,98,82),Color3.fromRGB(107,131,68)}
local function part(parent,name,size,position,color,material,collide,ball)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position;p.Color=color;p.Material=material;p.Anchored=true
 p.CanCollide=collide;p.CanTouch=false;p.CanQuery=collide;p.CastShadow=collide;if ball then p.Shape=Enum.PartType.Ball end;p.Parent=parent
end
for i=1,16 do
 local pos=candidates[math.floor((i-.5)*#candidates/16)+1]
 local tree=Instance.new("Model");tree.Name="PerimeterTree_"..i
 local h=4.1+(i%3)*.45
 part(tree,"Trunk",Vector3.new(.9,h,.9),pos+Vector3.new(0,h/2,0),Color3.fromRGB(101,72,50),Enum.Material.Wood,true)
 local color=colors[(i-1)%#colors+1]
 if i%4==0 then
  part(tree,"Crown",Vector3.new(7,3.4,6),pos+Vector3.new(0,h+1.3,0),color,Enum.Material.Grass,false,true)
  part(tree,"Crown",Vector3.new(4,3,4),pos+Vector3.new(0,h+3,0),color,Enum.Material.Grass,false,true)
 elseif i%4==1 then
  for _,dx in ipairs({-1.5,1.5}) do part(tree,"Crown",Vector3.new(4.6,4,4.6),pos+Vector3.new(dx,h+1.7,0),color,Enum.Material.Grass,false,true) end
 elseif i%4==2 then
  part(tree,"Crown",Vector3.new(4.4,6,4.4),pos+Vector3.new(0,h+2,0),color,Enum.Material.Grass,false,true)
 else
  part(tree,"Crown",Vector3.new(6.5,4.5,6.5),pos+Vector3.new(0,h+1.7,0),color,Enum.Material.Grass,false,true)
 end
 for _,dx in ipairs({-.8,.8}) do
  part(tree,"Flower",Vector3.new(.4,.4,.4),pos+Vector3.new(dx,.25,1.4),if i%2==0 then Color3.fromRGB(221,176,81) else Color3.fromRGB(196,135,165),Enum.Material.SmoothPlastic,false,true)
 end
 tree.Parent=area
end
output.Parent=root
return "Added 16 varied modest trees to the perimeter lawn"
