-- Native, bounded landscape details; paths and the existing flat ground remain intact.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusNaturalLandscape_v1"))
local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld")
local occupied,entries={},{}
for _,folder in ipairs({root.CampusGrass_v1,root.CampusParkDetails_v1,root.CampusNarrowPlanting_v1,root.CampusPerimeterPlanting_v1}) do
 for _,p in ipairs(folder:GetDescendants()) do
  if p:IsA("Seat") or (p:IsA("BasePart") and p.Name=="Trunk") then table.insert(occupied,p.Position) end
 end
end
for _,p in ipairs(root.Buildings:GetDescendants()) do
 if p:IsA("BasePart") and p:GetAttribute("CampusDoor") and (p.Name:find("Main") or p.Name:find("Entry")) then
  local closed=p:GetAttribute("DoorClosed");if closed then table.insert(entries,closed.Position) end
 end
end
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1}
local function far(pos,list,distance)
 for _,q in ipairs(list) do if Vector3.new(pos.X-q.X,0,pos.Z-q.Z).Magnitude<distance then return false end end
 return true
end
local function clear(pos,size)
 for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos),size,overlap)) do if p.CanCollide then return false end end
 return true
end
local function shuffle(t,random) for i=#t,2,-1 do local j=random:NextInteger(1,i);t[i],t[j]=t[j],t[i] end end
local largeTargets={grass16=6,grass17=2,grass1=1,grass4=1,grass10=1,grass11=1,grass22=1}
local plans={};local largeCount,moundCount,tuftCount=0,0,0
for _,feature in ipairs(manifest.features) do
 if feature.category=="area" and feature.id:match("^grass%d*$") then
  local poly=feature.polygonStuds
  local x0,x1,z0,z1,sum=math.huge,-math.huge,math.huge,-math.huge,0
  for i,v in ipairs(poly) do local n=poly[i%#poly+1];x0=math.min(x0,v[1]);x1=math.max(x1,v[1]);z0=math.min(z0,v[2]);z1=math.max(z1,v[2]);sum+=v[1]*n[2]-n[1]*v[2] end
  local function inside(x,z)
   local hit=false;local a=poly[#poly]
   for _,b in ipairs(poly) do if (a[2]>z)~=(b[2]>z) and x<(a[1]-b[1])*(z-b[2])/(a[2]-b[2])+b[1] then hit=not hit end;a=b end
   return hit
  end
  local function footprint(x,z,rx,rz)
   for _,dx in ipairs({-rx,0,rx}) do for _,dz in ipairs({-rz,0,rz}) do if not inside(x+dx,z+dz) then return false end end end
   return true
  end
  local floor=RaycastParams.new();floor.FilterType=Enum.RaycastFilterType.Include;floor.FilterDescendantsInstances={root.CampusExactGrass_v1[feature.id]};floor.RespectCanCollide=true
  local random=Random.new(7319+math.floor(x0*13+z0*3))
  local plan={id=feature.id,trees={},mounds={},tufts={}}
  if largeTargets[feature.id] then
   local options={}
   for z=z0+7,z1-7,14 do for x=x0+7,x1-7,14 do if footprint(x,z,6.5,6.5) then table.insert(options,Vector3.new(origin.X+x,0,origin.Z+z)) end end end
   shuffle(options,random)
   for _,pos in ipairs(options) do
    if #plan.trees>=largeTargets[feature.id] then break end
    if far(pos,occupied,18) and far(pos,entries,25) and clear(pos+Vector3.new(0,7.5,0),Vector3.new(13,15,13)) then
     local hit=workspace:Raycast(pos+Vector3.new(0,4,0),Vector3.new(0,-8,0),floor)
     if hit then table.insert(plan.trees,hit.Position);table.insert(occupied,pos);largeCount+=1 end
    end
   end
  end
  local options={}
  for z=z0+7,z1-7,12 do for x=x0+8,x1-8,12 do if footprint(x,z,7,6) then table.insert(options,Vector3.new(origin.X+x,0,origin.Z+z)) end end end
  shuffle(options,random)
  for _,pos in ipairs(options) do
   if #plan.mounds >= (feature.id=="grass16" and 3 or 1) then break end
   if far(pos,occupied,14) and far(pos,entries,18) and clear(pos+Vector3.new(0,1,0),Vector3.new(14,2,12)) then
    local hit=workspace:Raycast(pos+Vector3.new(0,4,0),Vector3.new(0,-8,0),floor)
    if hit then
     local mound={center=hit.Position,size=Vector3.new(14,.55+(moundCount%3)*.1,12)}
     table.insert(plan.mounds,mound);table.insert(occupied,pos);moundCount+=1
    end
   end
  end
  options={}
  for z=z0+1,z1-1,5 do for x=x0+1,x1-1,5 do if footprint(x,z,.8,.8) then table.insert(options,Vector3.new(origin.X+x,0,origin.Z+z)) end end end
  shuffle(options,random)
  local target=math.clamp(math.floor(math.abs(sum)/2/300),12,80)
  for _,pos in ipairs(options) do
   if #plan.tufts>=target then break end
   if far(pos,occupied,3) and far(pos,entries,8) and far(pos,plan.tufts,4) and clear(pos+Vector3.new(0,1,0),Vector3.new(1.6,2,1.6)) then
    local hit=workspace:Raycast(pos+Vector3.new(0,4,0),Vector3.new(0,-8,0),floor)
    if hit then
     local y=hit.Position.Y
     for _,mound in ipairs(plan.mounds) do
      local dx=math.abs(pos.X-mound.center.X);local dz=math.abs(pos.Z-mound.center.Z)
      if dx<mound.size.X/2 and dz<mound.size.Z/2 then y=math.max(y,mound.center.Y+mound.size.Y*(1-dz/(mound.size.Z/2))) end
     end
     table.insert(plan.tufts,Vector3.new(pos.X,y,pos.Z));tuftCount+=1
    end
   end
  end
  table.insert(plans,plan);task.wait()
 end
end
assert(#plans==24 and largeCount>=8 and moundCount>=8 and tuftCount>=100,"Insufficient safe landscape placements")
local output=Instance.new("Folder");output.Name="CampusNaturalLandscape_v1";output.Parent=root
local greens={Color3.fromRGB(55,103,62),Color3.fromRGB(69,116,72),Color3.fromRGB(91,128,68),Color3.fromRGB(49,96,77)}
local function part(parent,name,size,cf,color,material,collide,ball)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material;p.Anchored=true
 p.CanCollide=collide;p.CanTouch=false;p.CanQuery=collide;p.CastShadow=collide;if ball then p.Shape=Enum.PartType.Ball end;p.Parent=parent;return p
end
for _,plan in ipairs(plans) do
 local area=Instance.new("Folder");area.Name=plan.id
 for i,pos in ipairs(plan.trees) do
  local tree=Instance.new("Model");tree.Name="LargeParkTree";local h=6.6+(i%3)*.45;local color=greens[(i-1)%#greens+1]
  part(tree,"Trunk",Vector3.new(1.25,h,1.25),CFrame.new(pos+Vector3.new(0,h/2,0)),Color3.fromRGB(101,70,46),Enum.Material.Wood,true)
  if i%3==0 then
   part(tree,"Crown",Vector3.new(10,4.8,9),CFrame.new(pos+Vector3.new(0,h+2.2,0)),color,Enum.Material.Grass,false,true)
   part(tree,"Crown",Vector3.new(7,4,7),CFrame.new(pos+Vector3.new(0,h+4.3,0)),color,Enum.Material.Grass,false,true)
  elseif i%3==1 then
   for _,x in ipairs({-2,2}) do part(tree,"Crown",Vector3.new(7,6,7),CFrame.new(pos+Vector3.new(x,h+2.8,0)),color,Enum.Material.Grass,false,true) end
   part(tree,"Crown",Vector3.new(6,5,6),CFrame.new(pos+Vector3.new(0,h+5,0)),greens[2],Enum.Material.Grass,false,true)
  else
   part(tree,"Crown",Vector3.new(8,8,8),CFrame.new(pos+Vector3.new(0,h+3.1,0)),color,Enum.Material.Grass,false,true)
  end
  tree.Parent=area
 end
 for _,mound in ipairs(plan.mounds) do
  local shape=Instance.new("Model");shape.Name="GrassMound"
  for _,side in ipairs({-1,1}) do
   local slope=Instance.new("WedgePart");slope.Name="GrassMoundSlope";slope.Size=Vector3.new(mound.size.X,mound.size.Y,mound.size.Z/2)
   slope.CFrame=CFrame.new(mound.center+Vector3.new(0,mound.size.Y/2,side*mound.size.Z/4))*CFrame.Angles(0,if side==1 then math.pi else 0,0)
   slope.Color=Color3.fromRGB(82,125,75);slope.Material=Enum.Material.Grass;slope.Anchored=true;slope.CanCollide=true;slope.CanTouch=false;slope.CanQuery=true;slope.CastShadow=false;slope.Parent=shape
  end
  part(shape,"GrassMoundCrest",Vector3.new(mound.size.X,.08,.16),CFrame.new(mound.center+Vector3.new(0,mound.size.Y-.04,0)),Color3.fromRGB(82,125,75),Enum.Material.Grass,true)
  shape.Parent=area
 end
 for i,pos in ipairs(plan.tufts) do
  local tuft=Instance.new("Model");tuft.Name="GrassTuft"
  local color=greens[(i-1)%#greens+1]
  for _,angle in ipairs({-.35,.35}) do
   part(tuft,"Blade",Vector3.new(.24,1.05,.75),CFrame.new(pos+Vector3.new(0,.46,0))*CFrame.Angles(0,angle*2,angle*.35),color,Enum.Material.Grass,false)
  end
  tuft.Parent=area
 end
 area.Parent=output;task.wait()
end
output:SetAttribute("LargeTreeCount",largeCount);output:SetAttribute("MoundCount",moundCount);output:SetAttribute("TuftCount",tuftCount)
return string.format("Added %d larger trees, %d low grass mounds and %d grass tufts across 24 areas",largeCount,moundCount,tuftCount)
