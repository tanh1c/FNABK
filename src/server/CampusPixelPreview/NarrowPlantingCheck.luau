local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local m=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld")
local polygons={}
for _,f in ipairs(m.features) do if f.id=="grass20" or f.id=="grass23" then polygons[f.id]=f.polygonStuds end end
local function inside(poly,x,z)
 local yes=false;local a=poly[#poly]
 for _,v in ipairs(poly) do
  if (v[2]>z)~=(a[2]>z) and x<(a[1]-v[1])*(z-v[2])/(a[2]-v[2])+v[1] then yes=not yes end
  a=v
 end
 return yes
end
local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1}
local trees,flowers=0,0
for _,area in ipairs(root.CampusNarrowPlanting_v1:GetChildren()) do
 local poly=assert(polygons[area.Name])
 for _,tree in ipairs(area:GetChildren()) do
  if tree.Name=="NarrowStoneBench_v1" then
   assert(tree:FindFirstChildWhichIsA("Seat"))
   continue
  end
  local trunk=tree.Trunk;local x,z=trunk.Position.X-origin.X,trunk.Position.Z-origin.Z
  for _,dx in ipairs({-2.9,2.9}) do for _,dz in ipairs({-2.9,2.9}) do assert(inside(poly,x+dx,z+dz)) end end
  local cf,size=tree:GetBoundingBox();assert(size.Y<9)
  for _,v in ipairs(workspace:GetPartBoundsInBox(CFrame.new(trunk.Position.X,4.5,trunk.Position.Z),Vector3.new(6,9,6),p)) do assert(not v.CanCollide,tree.Name.." overlaps "..v:GetFullName()) end
  for _,v in ipairs(tree:GetChildren()) do if v.Name=="Flower" then flowers+=1 end end
  trees+=1
 end
end
assert(trees==11 and flowers==33)
return "11 added trees remain inside grass and clear of buildings and fences"

