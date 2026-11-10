-- ponytail: primitive foliage keeps the preview asset-free; replace with reviewed low-poly models when available.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusParkEcosystem_v1"))
local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld")
local trunks,seats,entries={},{},{}
for _,v in ipairs(root:GetDescendants()) do
 if v:IsA("BasePart") and v.Name=="Trunk" then table.insert(trunks,v.Position)
 elseif v:IsA("Seat") then table.insert(seats,v.Position) end
 if v:IsA("BasePart") and v:GetAttribute("CampusDoor") and (v.Name:find("Main") or v.Name:find("Entry")) then
  local c=v:GetAttribute("DoorClosed");if c then table.insert(entries,c.Position) end
 end
end
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1,root.CampusRemainingAreas_v1}
local function far(pos,items,distance)
 for _,p in ipairs(items) do if Vector3.new(pos.X-p.X,0,pos.Z-p.Z).Magnitude<distance then return false end end
 return true
end
local function clear(pos,size)
 for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos),size,overlap)) do if p.CanCollide then return false end end
 return true
end
local plans={}
local treeCount,shrubCount,flowerCount=0,0,0
for _,f in ipairs(manifest.features) do if f.category=="area" and f.id:match("^grass%d*$") then
 local poly=f.polygonStuds
 local x0,x1,z0,z1=math.huge,-math.huge,math.huge,-math.huge
 for _,v in ipairs(poly) do x0=math.min(x0,v[1]);x1=math.max(x1,v[1]);z0=math.min(z0,v[2]);z1=math.max(z1,v[2]) end
 local function inside(x,z)
  local yes=false;local a=poly[#poly]
  for _,b in ipairs(poly) do if (a[2]>z)~=(b[2]>z) and x<(a[1]-b[1])*(z-b[2])/(a[2]-b[2])+b[1] then yes=not yes end;a=b end
  return yes
 end
 local function footprint(x,z,r)
  for _,dx in ipairs({-r,0,r}) do for _,dz in ipairs({-r,0,r}) do if not inside(x+dx,z+dz) then return false end end end
  return true
 end
 local floor=RaycastParams.new();floor.FilterType=Enum.RaycastFilterType.Include;floor.RespectCanCollide=true
 floor.FilterDescendantsInstances={root.CampusExactGrass_v1[f.id],root.CampusNaturalLandscape_v1[f.id]}
 local random=Random.new(13681+math.floor(x0*13+z0*19))
 local candidates={}
 for z=z0+4,z1-4,8 do for x=x0+4,x1-4,8 do
  local px,pz=x+random:NextNumber(-1.5,1.5),z+random:NextNumber(-1.5,1.5)
  if footprint(px,pz,4) then table.insert(candidates,{px,pz}) end
 end end
 for i=#candidates,2,-1 do local j=random:NextInteger(1,i);candidates[i],candidates[j]=candidates[j],candidates[i] end
 local plan={id=f.id,trees={},shrubs={},flowers={}}
 local maxTrees=if f.id=="grass16" then 16 else 3
 for _,p in ipairs(candidates) do
  if #plan.trees>=maxTrees or treeCount>=80 then break end
  local pos=Vector3.new(origin.X+p[1],0,origin.Z+p[2])
  if far(pos,trunks,11) and far(pos,seats,8) and far(pos,entries,23) and clear(pos+Vector3.new(0,12,0),Vector3.new(9,24,9)) then
   local hit=workspace:Raycast(pos+Vector3.new(0,5,0),Vector3.new(0,-10,0),floor)
   if hit then table.insert(plan.trees,hit.Position);table.insert(trunks,pos);treeCount+=1 end
  end
 end
 local greenery={}
 for z=z0+2,z1-2,6 do for x=x0+2,x1-2,6 do
  local px,pz=x+random:NextNumber(-1,1),z+random:NextNumber(-1,1)
  if footprint(px,pz,1.7) then table.insert(greenery,{px,pz}) end
 end end
 for i=#greenery,2,-1 do local j=random:NextInteger(1,i);greenery[i],greenery[j]=greenery[j],greenery[i] end
 local maxShrubs=if f.id=="grass16" then 45 else 14
 for _,p in ipairs(greenery) do
  if #plan.shrubs>=maxShrubs or shrubCount>=350 then break end
  local pos=Vector3.new(origin.X+p[1],0,origin.Z+p[2])
  if far(pos,trunks,3.5) and far(pos,seats,5) and far(pos,entries,12) and clear(pos+Vector3.new(0,1,0),Vector3.new(3.4,2,3.4)) then
   local hit=workspace:Raycast(pos+Vector3.new(0,5,0),Vector3.new(0,-10,0),floor)
   if hit then table.insert(plan.shrubs,hit.Position);shrubCount+=1 end
  end
 end
 for _,p in ipairs(greenery) do
  if #plan.flowers>=7 or flowerCount>=140 then break end
  local pos=Vector3.new(origin.X+p[1]+1.3,0,origin.Z+p[2])
  if footprint(pos.X-origin.X,pos.Z-origin.Z,1) and far(pos,trunks,3) and far(pos,seats,5) and far(pos,entries,12) and clear(pos+Vector3.new(0,1,0),Vector3.new(2,2,2)) then
   local hit=workspace:Raycast(pos+Vector3.new(0,5,0),Vector3.new(0,-10,0),floor)
   if hit then table.insert(plan.flowers,hit.Position);flowerCount+=1 end
  end
 end
 table.insert(plans,plan);task.wait()
end end
assert(#plans==24 and treeCount>=20 and shrubCount>=100 and flowerCount>=50,"Not enough safe planting positions")
local colors={Color3.fromRGB(50,99,66),Color3.fromRGB(71,119,69),Color3.fromRGB(88,128,71),Color3.fromRGB(47,101,81)}
local function part(parent,name,size,cf,color,material,collide,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material;p.Anchored=true
 p.CanCollide=collide;p.CanTouch=false;p.CanQuery=collide;p.CastShadow=collide;if shape then p.Shape=shape end;p.Parent=parent
 return p
end
local output=Instance.new("Folder");output.Name="CampusParkEcosystem_v1"
for _,plan in ipairs(plans) do
 local area=Instance.new("Folder");area.Name=plan.id
 for i,pos in ipairs(plan.trees) do
  local seed=math.abs(math.floor(pos.X*17+pos.Z*23));local rand=Random.new(seed);local style=seed%4
  local height=rand:NextNumber(10,17);local tree=Instance.new("Model");tree.Name="ParkCanopyTree";tree:SetAttribute("TreeStyle",style)
  part(tree,"Trunk",Vector3.new(1,height,1),CFrame.new(pos+Vector3.new(0,height/2,0)),Color3.fromRGB(100,73,52),Enum.Material.Wood,true)
  local color=colors[style+1]
  if style==0 then
   for n=1,6 do
    local a=n*math.pi/3;local from=pos+Vector3.new(0,height,0);local target=from+Vector3.new(math.cos(a)*3.5,-1.2,math.sin(a)*3.5)
    local frond=Instance.new("WedgePart");frond.Name="PalmFrond";frond.Size=Vector3.new(1.2,.2,(target-from).Magnitude)
    frond.CFrame=CFrame.lookAt((from+target)/2,target);frond.Color=color;frond.Material=Enum.Material.LeafyGrass
    frond.Anchored=true;frond.CanCollide=false;frond.CanTouch=false;frond.CanQuery=false;frond.CastShadow=false;frond.Parent=tree
   end
  else
   local yScale=if style==1 then 1.25 elseif style==2 then .75 else 1
   for n=1,4 do
    local a=n*math.pi/2+style*.3
    local center=pos+Vector3.new(math.cos(a)*1.6,height+.7+(n%2)*.8,math.sin(a)*1.6)
    part(tree,"Crown",Vector3.new(4.8,4.5*yScale,4.8),CFrame.new(center),colors[(style+n)%#colors+1],Enum.Material.LeafyGrass,false,Enum.PartType.Ball)
   end
   part(tree,"Crown",Vector3.new(4.4,4.8*yScale,4.4),CFrame.new(pos+Vector3.new(0,height+2.4,0)),color,Enum.Material.LeafyGrass,false,Enum.PartType.Ball)
  end
  tree.Parent=area
 end
 for i,pos in ipairs(plan.shrubs) do
  local shrub=Instance.new("Model");shrub.Name="ParkShrub"
  local color=colors[(i%#colors)+1]
  for _,dx in ipairs({-.7,.7}) do
   part(shrub,"Leaves",Vector3.new(2.1,1.5+(i%3)*.3,2.1),CFrame.new(pos+Vector3.new(dx,.7,0)),color,Enum.Material.LeafyGrass,false,Enum.PartType.Ball)
  end
  shrub.Parent=area
 end
 for i,pos in ipairs(plan.flowers) do
  local color=if i%3==0 then Color3.fromRGB(227,180,76) elseif i%3==1 then Color3.fromRGB(215,151,168) else Color3.fromRGB(230,221,190)
  part(area,"FlowerCluster",Vector3.new(1.4,.3,1.4),CFrame.new(pos+Vector3.new(0,.18,0)),color,Enum.Material.Grass,false,Enum.PartType.Ball)
 end
 area.Parent=output;task.wait()
end
output:SetAttribute("TreeCount",treeCount);output:SetAttribute("ShrubCount",shrubCount);output:SetAttribute("FlowerCount",flowerCount)
output.Parent=root
return string.format("Added %d trees, %d shrubs and %d flower clusters",treeCount,shrubCount,flowerCount)
