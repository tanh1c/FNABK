-- Native tree renewal: retain the old models and leaf parts for reversible review.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusTreePolish_v1"))
local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld")
local features={}
for _,f in ipairs(manifest.features) do if f.category=="area" and f.id:match("^grass%d*$") then features[f.id]=f end end
local folders={root.CampusGrass_v1,root.CampusParkDetails_v1,root.CampusNarrowPlanting_v1,root.CampusPerimeterPlanting_v1,root.CampusNaturalLandscape_v1}
local trees,seats,occupied,entries={},{},{},{}
for _,folder in ipairs(folders) do
 for _,area in ipairs(folder:GetChildren()) do if features[area.Name] then
  for _,v in ipairs(area:GetDescendants()) do
   if v:IsA("Model") and v:FindFirstChild("Trunk") then table.insert(trees,{model=v,area=area.Name});table.insert(occupied,v.Trunk.Position)
   elseif v:IsA("Seat") then table.insert(seats,v.Position);table.insert(occupied,v.Position)
   elseif v:IsA("Model") and v.Name=="GrassMound" then table.insert(occupied,v:GetPivot().Position) end
  end
 end end
end
for _,p in ipairs(root.Buildings:GetDescendants()) do
 if p:IsA("BasePart") and p:GetAttribute("CampusDoor") and (p.Name:find("Main") or p.Name:find("Entry")) then
  local closed=p:GetAttribute("DoorClosed");if closed then table.insert(entries,closed.Position) end
 end
end
assert(#trees==167,"Unexpected existing tree count")
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1}
local function inside(poly,x,z)
 local yes=false;local a=poly[#poly]
 for _,b in ipairs(poly) do if (a[2]>z)~=(b[2]>z) and x<(a[1]-b[1])*(z-b[2])/(a[2]-b[2])+b[1] then yes=not yes end;a=b end
 return yes
end
local function footprint(poly,pos,r)
 local x,z=pos.X-origin.X,pos.Z-origin.Z
 for _,dx in ipairs({-r,0,r}) do for _,dz in ipairs({-r,0,r}) do if not inside(poly,x+dx,z+dz) then return false end end end
 return true
end
local function far(pos,list,distance)
 for _,q in ipairs(list) do if Vector3.new(pos.X-q.X,0,pos.Z-q.Z).Magnitude<distance then return false end end
 return true
end
local function clear(pos,width)
 for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos.X,12,pos.Z),Vector3.new(width,24,width),overlap)) do if p.CanCollide then return false end end
 return true
end
local upgrades={}
for _,candidate in ipairs(trees) do
 local tree,trunk=candidate.model,candidate.model.Trunk
 assert(not tree:GetAttribute("PolishedTree_v1") and trunk.CFrame.UpVector.Y>.99)
 local pos=trunk.Position
 if footprint(features[candidate.area].polygonStuds,pos,6) and far(pos,entries,25) and far(pos,seats,8) and clear(pos,12) then
  local leaves={}
  for _,p in ipairs(tree:GetChildren()) do if p:IsA("BasePart") and (p.Name=="Crown" or p.Name=="Canopy" or p.Name=="UpperCanopy") then
   assert(not p.CanCollide and p:GetAttribute("BeforeTreePolishTransparency_v1")==nil);table.insert(leaves,p)
  end end
  assert(#leaves>0 and not tree:FindFirstChild("DetailedCanopy_v1"))
  table.insert(upgrades,{tree=tree,trunk=trunk,leaves=leaves})
 end
end
assert(#upgrades>=80,"Too few suitable trees; nothing changed")
local additions={}
for _,feature in ipairs(manifest.features) do if features[feature.id] then
 local poly=feature.polygonStuds;local x0,x1,z0,z1=math.huge,-math.huge,math.huge,-math.huge
 for _,v in ipairs(poly) do x0=math.min(x0,v[1]);x1=math.max(x1,v[1]);z0=math.min(z0,v[2]);z1=math.max(z1,v[2]) end
 local options={}
 for z=z0+6,z1-6,10 do for x=x0+6,x1-6,10 do
  local p=Vector3.new(origin.X+x,0,origin.Z+z);if footprint(poly,p,6) then table.insert(options,p) end
 end end
 local random=Random.new(32871+math.floor(x0*7+z0*13))
 for i=#options,2,-1 do local j=random:NextInteger(1,i);options[i],options[j]=options[j],options[i] end
 local floor=RaycastParams.new();floor.FilterType=Enum.RaycastFilterType.Include;floor.FilterDescendantsInstances={root.CampusExactGrass_v1[feature.id]};floor.RespectCanCollide=true
 local target=if feature.id=="grass16" then 12 else 2
 local made=0
 for _,pos in ipairs(options) do
  if made>=target then break end
  if far(pos,occupied,12) and far(pos,entries,25) and clear(pos,12) then
   local hit=workspace:Raycast(pos+Vector3.new(0,4,0),Vector3.new(0,-8,0),floor)
   if hit then table.insert(additions,{area=feature.id,pos=hit.Position});table.insert(occupied,pos);made+=1 end
  end
 end
 task.wait()
end end
assert(#additions>=20,"Too few safe new trees; nothing changed")
local output=Instance.new("Folder");output.Name="CampusTreePolish_v1";output.Parent=root
local greens={Color3.fromRGB(45,92,55),Color3.fromRGB(61,111,65),Color3.fromRGB(77,125,71),Color3.fromRGB(51,103,78),Color3.fromRGB(97,127,69)}
local function create(parent,class,name,size,frame,color,material,collide,shape)
 local p=Instance.new(class);p.Name=name;p.Size=size;p.CFrame=frame;p.Color=color;p.Material=material;p.Anchored=true
 p.CanCollide=collide;p.CanTouch=false;p.CanQuery=collide;p.CastShadow=collide;if shape then p.Shape=shape end;p.Parent=parent;return p
end
local function decorate(tree,trunk,leaves)
 local base=trunk.Position-Vector3.new(0,trunk.Size.Y/2,0)
 local seed=math.abs(math.floor(base.X*17+base.Z*31));local random=Random.new(seed)
 local style=seed%5;local height=if style==0 then 17+random:NextNumber(0,3) else 12.5+random:NextNumber(0,3.4)
 trunk:SetAttribute("BeforeTreePolishSize_v1",trunk.Size);trunk:SetAttribute("BeforeTreePolishFrame_v1",trunk.CFrame)
 local rotation=trunk.CFrame.Rotation;trunk.Size=Vector3.new(math.max(1.1,trunk.Size.X),height,math.max(1.1,trunk.Size.Z));trunk.CFrame=CFrame.new(base+Vector3.new(0,height/2,0))*rotation
 for _,leaf in ipairs(leaves) do leaf:SetAttribute("BeforeTreePolishTransparency_v1",leaf.Transparency);leaf.Transparency=1 end
 local detail=Instance.new("Folder");detail.Name="DetailedCanopy_v1"
 local color=greens[seed%#greens+1];local phase=random:NextNumber(0,math.pi*2)
 if style==0 then
  -- Palm-like crown with drooping native wedge fronds.
  for i=1,7 do
   local angle=phase+(i-1)*math.pi*2/7;local from=base+Vector3.new(0,height-.1,0);local dest=base+Vector3.new(math.cos(angle)*5,height-1.7,math.sin(angle)*5)
   local mid=(from+dest)/2;local length=(dest-from).Magnitude
   create(detail,"WedgePart","Frond",Vector3.new(1.25,.3,length),CFrame.lookAt(mid,dest),greens[(seed+i)%#greens+1],Enum.Material.LeafyGrass,false)
  end
 else
  local spread=if style==1 then 2.4 elseif style==2 then 2.9 else 3.1
  for i=1,4 do
   local angle=phase+(i-1)*math.pi/2;local from=base+Vector3.new(0,height*.68+(i%2)*.45,0)
   local dest=base+Vector3.new(math.cos(angle)*spread,height+1.1+(i%2)*.7,math.sin(angle)*spread)
   local mid=(from+dest)/2;local length=(dest-from).Magnitude
   create(detail,"Part","Branch",Vector3.new(length,.48,.48),CFrame.lookAt(mid,dest)*CFrame.Angles(0,math.pi/2,0),Color3.fromRGB(101,72,48),Enum.Material.Wood,false,Enum.PartType.Cylinder)
   local leafSize=if style==1 then Vector3.new(4.5,5.2,4.5) elseif style==2 then Vector3.new(5.4,3.5,5) else Vector3.new(5.1,4.2,4.8)
   create(detail,"Part","Foliage",leafSize,CFrame.new(dest+Vector3.new(0,.7,0))*CFrame.Angles(0,angle,.12*(i%2)),greens[(seed+i)%#greens+1],Enum.Material.LeafyGrass,false,Enum.PartType.Ball)
  end
  create(detail,"Part","Foliage",Vector3.new(5.2,4.5,5.2),CFrame.new(base+Vector3.new(0,height+3.2,0)),color,Enum.Material.LeafyGrass,false,Enum.PartType.Ball)
 end
 detail.Parent=tree;tree:SetAttribute("PolishedTree_v1",true);tree:SetAttribute("TreeStyle_v1",style)
end
for i,plan in ipairs(upgrades) do decorate(plan.tree,plan.trunk,plan.leaves);if i%20==0 then task.wait() end end
for i,plan in ipairs(additions) do
 local area=output:FindFirstChild(plan.area);if not area then area=Instance.new("Folder");area.Name=plan.area;area.Parent=output end
 local tree=Instance.new("Model");tree.Name="CampusTreeLarge"
 local trunk=create(tree,"Part","Trunk",Vector3.new(1.1,4,1.1),CFrame.new(plan.pos+Vector3.new(0,2,0)),Color3.fromRGB(101,72,48),Enum.Material.Wood,true)
 decorate(tree,trunk,{})
 tree.Parent=area;if i%20==0 then task.wait() end
end
output:SetAttribute("UpgradedTreeCount",#upgrades);output:SetAttribute("NewTreeCount",#additions)
return string.format("Renewed %d trees and added %d taller native trees",#upgrades,#additions)
