-- Fill two narrow grass polygons missed by the earlier park pass.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusNarrowPlanting_v1"))
local m=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld")
local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include
params.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1,root.CampusGrass_v1,root.CampusParkDetails_v1}
local function inside(poly,x,z)
 local yes=false;local a=poly[#poly]
 for _,v in ipairs(poly) do
  if (v[2]>z)~=(a[2]>z) and x<(a[1]-v[1])*(z-v[2])/(a[2]-v[2])+v[1] then yes=not yes end
  a=v
 end
 return yes
end
local choices={grass20={1,4,7,9,12,15,19,23},grass23={1,3,4}}
local plans={}
for _,feature in ipairs(m.features) do
 local selection=choices[feature.id]
 if selection then
  local x0,x1,z0,z1=math.huge,-math.huge,math.huge,-math.huge
  for _,v in ipairs(feature.polygonStuds) do x0=math.min(x0,v[1]);x1=math.max(x1,v[1]);z0=math.min(z0,v[2]);z1=math.max(z1,v[2]) end
  local found={}
  for z=z0+3,z1-3,4 do for x=x0+3,x1-3,4 do
   local poly=feature.polygonStuds
   if inside(poly,x-3,z-3) and inside(poly,x+3,z-3) and inside(poly,x-3,z+3) and inside(poly,x+3,z+3) then
    local pos=Vector3.new(origin.X+x,4.5,origin.Z+z);local clear=true
    for _,v in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos),Vector3.new(6,9,6),params)) do if v.CanCollide then clear=false;break end end
    if clear then
     for _,other in ipairs(found) do if (pos-other).Magnitude<12 then clear=false;break end end
     if clear then table.insert(found,pos) end
    end
   end
  end end
  for _,i in ipairs(selection) do assert(found[i],"Planting candidates changed: "..feature.id);table.insert(plans,{feature.id,found[i]}) end
 end
end
assert(#plans==11)
local output=Instance.new("Folder");output.Name="CampusNarrowPlanting_v1"
local colors={Color3.fromRGB(61,112,70),Color3.fromRGB(88,130,67),Color3.fromRGB(53,99,78)}
for i,entry in ipairs(plans) do
 local area=output:FindFirstChild(entry[1])
 if not area then area=Instance.new("Folder");area.Name=entry[1];area.Parent=output end
 local pos=entry[2]-Vector3.new(0,4.5,0)
 local model=Instance.new("Model");model.Name="NarrowParkTree_"..i
 local trunk=Instance.new("Part");trunk.Name="Trunk";trunk.Size=Vector3.new(.8,4.4,.8);trunk.Position=pos+Vector3.new(0,2.35,0)
 trunk.Color=Color3.fromRGB(96,69,47);trunk.Material=Enum.Material.Wood;trunk.Anchored=true;trunk.CanCollide=true;trunk.Parent=model
 local crown=Instance.new("Part");crown.Name="Crown";crown.Shape=Enum.PartType.Ball
 crown.Size=if i%3==0 then Vector3.new(4.2,5.2,4.2) elseif i%3==1 then Vector3.new(5,4,5) else Vector3.new(4.4,4.8,4.4)
 crown.Position=pos+Vector3.new(0,6.2,0);crown.Color=colors[(i-1)%3+1];crown.Material=Enum.Material.Grass
 crown.Anchored=true;crown.CanCollide=false;crown.CanTouch=false;crown.CanQuery=false;crown.CastShadow=false;crown.Parent=model
 for _,dx in ipairs({-1.1,0,1.1}) do
  local flower=Instance.new("Part");flower.Name="Flower";flower.Shape=Enum.PartType.Ball;flower.Size=Vector3.new(.38,.38,.38)
  flower.Position=pos+Vector3.new(dx,.38,1.5);flower.Color=if i%2==0 then Color3.fromRGB(220,175,78) else Color3.fromRGB(192,130,163)
  flower.Material=Enum.Material.SmoothPlastic;flower.Anchored=true;flower.CanCollide=false;flower.CanTouch=false;flower.CanQuery=false;flower.CastShadow=false;flower.Parent=model
 end
 model.Parent=area
end
output.Parent=root
return "Added 11 modest trees with flowers to the two narrow grass areas"
