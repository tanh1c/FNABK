local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local output=root.CampusRemainingAreas_v1
local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld")
local function inside(poly,x,z)
 local hit=false;local a=poly[#poly]
 for _,b in ipairs(poly) do if (a[2]>z)~=(b[2]>z) and x<(a[1]-b[1])*(z-b[2])/(a[2]-b[2])+b[1] then hit=not hit end;a=b end
 return hit
end
local names={FootballField=true,EastPlaza=true,OpenField=true,SportArea=true,Parking=true,Parking2=true,parking3=true,StudentSpace=true,basketballField=true}
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.RespectCanCollide=true
ray.FilterDescendantsInstances={root.Buildings,root.CampusExactGrass_v1,root.CampusBoundaryAndGates_v1}
local count,seats,fixtures=0,0,0
for _,f in ipairs(manifest.features) do if names[f.id] then
 local area=assert(output:FindFirstChild(f.id));assert(area:GetAttribute("SurfaceTriangles")>=2)
 for _,p in ipairs(area:GetChildren()) do if p:IsA("BasePart") and p.Name~="AreaSurface" then
  assert(p.Anchored)
  for _,dx in ipairs({-.5,0,.5}) do for _,dz in ipairs({-.5,0,.5}) do
   local x,z=p.Position.X-origin.X+dx*p.Size.X,p.Position.Z-origin.Z+dz*p.Size.Z
   assert(inside(f.polygonStuds,x,z),"Outside area: "..p:GetFullName())
   local hit=workspace:Raycast(Vector3.new(origin.X+x,30,origin.Z+z),Vector3.new(0,-30,0),ray)
   assert(not hit,"Facility overlaps existing geometry")
  end end
  if p:IsA("Seat") then seats+=1 end;fixtures+=1
 end end
 count+=1
end end
assert(count==9 and seats==21 and fixtures>100)
assert(output.FootballField:FindFirstChild("GoalCrossbar") and output.basketballField:FindFirstChild("Backboard"))
for _,id in ipairs({"Parking","Parking2","parking3"}) do assert(output[id]:FindFirstChild("ShelterRoof")) end
return string.format("%d areas, %d fixtures and %d seats checked within traced outlines",count,fixtures,seats)
