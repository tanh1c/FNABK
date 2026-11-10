local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local output=root.CampusParkEcosystem_v1
local seats,entries,trunks={},{},{}
for _,v in ipairs(root:GetDescendants()) do
 if v:IsA("Seat") then table.insert(seats,v.Position)
 elseif v:IsA("BasePart") and v.Name=="Trunk" then table.insert(trunks,v.Position) end
 if v:IsA("BasePart") and v:GetAttribute("CampusDoor") and (v.Name:find("Main") or v.Name:find("Entry")) then
  local c=v:GetAttribute("DoorClosed");if c then table.insert(entries,c.Position) end
 end
end
local function far(pos,list,distance,except)
 for _,p in ipairs(list) do
  local d=Vector3.new(pos.X-p.X,0,pos.Z-p.Z).Magnitude
  assert(d>=distance or (except and d<.01),"Plant too close to an obstacle")
 end
end
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1,root.CampusRemainingAreas_v1}
local counts={trees=0,shrubs=0,flowers=0,areas=0};local styles={}
for _,area in ipairs(output:GetChildren()) do
 local grass=root.CampusExactGrass_v1[area.Name]
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.RespectCanCollide=true
 ray.FilterDescendantsInstances={grass,root.CampusNaturalLandscape_v1[area.Name]}
 local grassRay=RaycastParams.new();grassRay.FilterType=Enum.RaycastFilterType.Include;grassRay.RespectCanCollide=true;grassRay.FilterDescendantsInstances={grass}
 for _,plant in ipairs(area:GetChildren()) do
  if plant.Name=="ParkCanopyTree" then
   local trunk=plant.Trunk;local base=trunk.Position-Vector3.new(0,trunk.Size.Y/2,0)
   assert(trunk.CanCollide and trunk.Size.Y>=10 and trunk.Size.Y<=17)
   for _,x in ipairs({-4,0,4}) do for _,z in ipairs({-4,0,4}) do
    assert(workspace:Raycast(base+Vector3.new(x,5,z),Vector3.new(0,-10,0),grassRay),"Tree outside grass")
   end end
   assert(workspace:Raycast(base+Vector3.new(0,4,0),Vector3.new(0,-8,0),ray),"Tree lacks ground")
   far(base,trunks,10.99,true);far(base,seats,8);far(base,entries,23)
   for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(base+Vector3.new(0,12,0)),Vector3.new(9,24,9),overlap)) do assert(not p.CanCollide) end
   for _,p in ipairs(plant:GetChildren()) do if p~=trunk then assert(not p.CanCollide and not p.CanQuery) end end
   styles[plant:GetAttribute("TreeStyle")]=true;counts.trees+=1
  elseif plant.Name=="ParkShrub" then
   assert(#plant:GetChildren()==2)
   for _,p in ipairs(plant:GetChildren()) do assert(not p.CanCollide and not p.CanQuery) end
   local pos=plant:GetChildren()[1].Position
   assert(workspace:Raycast(pos+Vector3.new(0,4,0),Vector3.new(0,-9,0),ray),"Shrub lacks ground")
   far(pos,seats,4);far(pos,entries,11);counts.shrubs+=1
  elseif plant.Name=="FlowerCluster" then
   assert(not plant.CanCollide and not plant.CanQuery)
   assert(workspace:Raycast(plant.Position+Vector3.new(0,4,0),Vector3.new(0,-9,0),ray),"Flower lacks ground")
   counts.flowers+=1
  else error("Unexpected ecosystem object") end
 end
 counts.areas+=1;task.wait()
end
local n=0;for _ in pairs(styles) do n+=1 end
assert(counts.areas==24 and counts.trees==output:GetAttribute("TreeCount") and counts.shrubs==output:GetAttribute("ShrubCount") and counts.flowers==output:GetAttribute("FlowerCount") and n==4)
return string.format("%d trees, %d shrubs and %d flower clusters checked across %d lawns",counts.trees,counts.shrubs,counts.flowers,counts.areas)
