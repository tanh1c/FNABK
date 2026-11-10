-- Sample the traced ground polygon independently of trees, floors and grass.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local m=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld");local poly
for _,f in ipairs(m.features) do if f.id=="CampusBoundary" then poly=f.polygonStuds end end
assert(poly)
local function inside(x,z)
 local yes=false;local j=#poly
 for i=1,#poly do
  local a,b=poly[i],poly[j]
  if (a[2]>z)~=(b[2]>z) and x<(b[1]-a[1])*(z-a[2])/(b[2]-a[2])+a[1] then yes=not yes end
  j=i
 end
 return yes
end
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={root.CampusGround_v1};params.RespectCanCollide=true
local samples=0
for x=0,1400,20 do
 for z=300,1000,20 do
  local h=workspace:Raycast(Vector3.new(origin.X+x,4,origin.Z+z),Vector3.new(0,-8,0),params)
  assert((h~=nil)==inside(x,z),string.format("Boundary coverage mismatch at %d,%d",x,z))
  samples+=1
 end
end
return string.format("%d ground samples agree with traced boundary",samples)
