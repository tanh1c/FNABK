local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local landscape=root.CampusNaturalLandscape_v1
local trees,mounds,tufts,areas=0,0,0,0
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1}
for _,area in ipairs(landscape:GetChildren()) do
 local grass=assert(root.CampusExactGrass_v1:FindFirstChild(area.Name))
 local floor=RaycastParams.new();floor.FilterType=Enum.RaycastFilterType.Include;floor.FilterDescendantsInstances={grass};floor.RespectCanCollide=true
 local support={grass}
 for _,v in ipairs(area:GetChildren()) do if v.Name=="GrassMound" then table.insert(support,v) end end
 local surface=RaycastParams.new();surface.FilterType=Enum.RaycastFilterType.Include;surface.FilterDescendantsInstances=support;surface.RespectCanCollide=true
 local localTufts=0
 for _,model in ipairs(area:GetChildren()) do
  if model.Name=="LargeParkTree" then
   local trunk=assert(model:FindFirstChild("Trunk"));local base=trunk.Position-Vector3.new(0,trunk.Size.Y/2,0)
   local _,size=model:GetBoundingBox()
   if model:GetAttribute("TreeVariety_v1")~=nil then assert(size.Y>=13 and size.Y<=28)
   elseif model:GetAttribute("PolishedTree_v1") then assert(size.Y>=16 and size.Y<=24) else assert(size.Y>=12 and size.Y<=16.5) end
   for _,x in ipairs({-6,0,6}) do for _,z in ipairs({-6,0,6}) do assert(workspace:Raycast(base+Vector3.new(x,5,z),Vector3.new(0,-10,0),floor),"Tree outside grass") end end
   for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(base+Vector3.new(0,7.5,0)),Vector3.new(13,15,13),overlap)) do assert(not p.CanCollide,"Tree overlaps "..p:GetFullName()) end
   trees+=1
  elseif model.Name=="GrassMound" then
   local cf,size=model:GetBoundingBox();assert(size.Y>=.54 and size.Y<=.76 and #model:GetChildren()==3)
   for _,x in ipairs({-6.5,0,6.5}) do for _,z in ipairs({-5.5,0,5.5}) do assert(workspace:Raycast(cf.Position+Vector3.new(x,5,z),Vector3.new(0,-10,0),floor),"Mound outside grass") end end
   local moundRay=RaycastParams.new();moundRay.FilterType=Enum.RaycastFilterType.Include;moundRay.FilterDescendantsInstances={model};moundRay.RespectCanCollide=true
   for _,z in ipairs({-5,-3,0,3,5}) do assert(workspace:Raycast(cf.Position+Vector3.new(0,5,z),Vector3.new(0,-10,0),moundRay),"Mound surface gap") end
   for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(cf.Position.X,1,cf.Position.Z),Vector3.new(14,2,12),overlap)) do assert(not p.CanCollide,"Mound overlaps "..p:GetFullName()) end
   mounds+=1
  elseif model.Name=="GrassTuft" then
   assert(#model:GetChildren()==2)
   for _,blade in ipairs(model:GetChildren()) do
    assert(blade:IsA("BasePart") and not blade.CanCollide and not blade.CanQuery)
    local hit=workspace:Raycast(blade.Position+Vector3.new(0,2,0),Vector3.new(0,-5,0),surface)
    assert(hit and math.abs((blade.Position.Y-.46)-hit.Position.Y)<.15,"Grass tuft unsupported")
   end
   localTufts+=1;tufts+=1
  end
 end
 assert(localTufts>=8,"Grass area lacks tufts: "..area.Name)
 areas+=1
end
assert(areas==24 and trees==11 and mounds==16 and tufts>=300)
assert(landscape:GetAttribute("LargeTreeCount")==trees and landscape:GetAttribute("MoundCount")==mounds and landscape:GetAttribute("TuftCount")==tufts)
return string.format("%d larger trees, %d supported low mounds and %d grass tufts checked across 24 areas",trees,mounds,tufts)
