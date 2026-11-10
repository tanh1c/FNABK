local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local output=root.CampusTreeVarietyGrass_v1
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1}
local trees,tufts,variants,heights=0,0,{},{}
for _,tree in ipairs(root:GetDescendants()) do
 if tree:IsA("Model") and tree:GetAttribute("TreeVariety_v1") ~= nil then
  trees+=1;variants[tree:GetAttribute("TreeVariety_v1")]=true;heights[tree:GetAttribute("TreeHeightDelta_v1")]=true
  local trunk=tree.Trunk;local base=trunk.Position-Vector3.new(0,trunk.Size.Y/2,0)
  local old=trunk:GetAttribute("BeforeVarietyFrame_v1");local size=trunk:GetAttribute("BeforeVarietySize_v1")
  assert(((old.Position-Vector3.new(0,size.Y/2,0))-base).Magnitude<.02 and trunk.CanCollide)
  local _,bounds=tree:GetBoundingBox();assert(bounds.X<=12 and bounds.Z<=12 and bounds.Y>=13 and bounds.Y<=28)
  for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(base+Vector3.new(0,14,0)),Vector3.new(12,28,12),overlap)) do
   assert(not p.CanCollide,"Tree intersects "..p:GetFullName())
  end
 end
end
for _,area in ipairs(output:GetChildren()) do
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.RespectCanCollide=true
 ray.FilterDescendantsInstances={root.CampusExactGrass_v1[area.Name],root.CampusNaturalLandscape_v1[area.Name]}
 for _,tuft in ipairs(area:GetChildren()) do
  assert(tuft.Name=="GrassTuft" and #tuft:GetChildren()==2)
  for _,p in ipairs(tuft:GetChildren()) do
   assert(not p.CanCollide and not p.CanQuery)
   local hit=workspace:Raycast(p.Position+Vector3.new(0,2,0),Vector3.new(0,-5,0),ray)
   assert(hit and math.abs(p.Position.Y-p.Size.Y*.46-hit.Position.Y)<.05,"Unsupported tuft")
  end
  tufts+=1
 end
end
local v,h=0,0;for _ in pairs(variants) do v+=1 end;for _ in pairs(heights) do h+=1 end
assert(trees==158 and v==4 and h==5 and tufts>=500 and tufts==output:GetAttribute("TuftCount"))
return string.format("%d trees, %d crown variants, %d height adjustments, %d supported grass tufts checked",trees,v,h,tufts)
