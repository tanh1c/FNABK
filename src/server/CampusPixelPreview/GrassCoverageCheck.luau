local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local trees,seats,areas=0,0,0
for _,grass in ipairs(root.CampusExactGrass_v1:GetChildren()) do
 local t,s=0,0
 for _,folder in ipairs({root.CampusGrass_v1,root.CampusParkDetails_v1,root.CampusNarrowPlanting_v1,root.CampusPerimeterPlanting_v1,root.CampusNaturalLandscape_v1,root.CampusTreePolish_v1}) do
  local area=folder:FindFirstChild(grass.Name)
  if area then for _,v in ipairs(area:GetDescendants()) do
   if v:IsA("BasePart") and v.Name=="Trunk" then t+=1 end
   if v:IsA("Seat") then s+=1 end
  end end
 end
 assert(t>0 and s>0,grass.Name.." lacks tree or bench")
 trees+=t;seats+=s;areas+=1
end
assert(areas==24 and trees==201 and seats==41,string.format("Unexpected park totals: %d areas, %d trees, %d seats",areas,trees,seats))
return "24 grass areas each contain a tree and seat; 201 trees and 41 seats"
