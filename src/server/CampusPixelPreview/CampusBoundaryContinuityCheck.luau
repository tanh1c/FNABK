-- Verify traced edge coverage, treating only the three intentional gate openings as gaps.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld")
local polygon
for _, feature in ipairs(manifest.features) do if feature.id=="CampusBoundary" then polygon=feature.polygonStuds end end
assert(polygon and #polygon==10)
local spanCount,gateCount=0,0
for i,a in ipairs(polygon) do
 local b=polygon[i%#polygon+1]
 local dx,dz=b[1]-a[1],b[2]-a[2]
 local length=math.sqrt(dx*dx+dz*dz)
 local right=Vector3.new(dx/length,0,dz/length)
 local frame=CFrame.fromMatrix(Vector3.new(origin.X+a[1],0,origin.Z+a[2]),right,Vector3.yAxis,right:Cross(Vector3.yAxis))
 local edge=root.CampusBoundaryAndGates_v1["BoundaryEdge_"..i]
 local intervals={}
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={edge};ray.RespectCanCollide=true
 for _, item in ipairs(edge:GetChildren()) do
  if item:IsA("BasePart") and item.Name=="BoundaryBase" then
   local x=frame:PointToObjectSpace(item.Position).X
   table.insert(intervals,{x-item.Size.X/2,x+item.Size.X/2})
   local hit=workspace:Raycast(frame:PointToWorldSpace(Vector3.new(x,3,-2)),frame.LookVector*-4,ray)
   assert(hit and hit.Instance.Name=="FenceBarrier","Missing barrier on edge "..i)
   spanCount+=1
  elseif item:IsA("Model") and item.Name:match("^CampusGate_") then
   local header=item.GateHeader
   local x=frame:PointToObjectSpace(header.Position).X
   local half=(header.Size.X-2)/2
   table.insert(intervals,{x-half,x+half})
   gateCount+=1
  end
 end
 table.sort(intervals,function(x,y) return x[1]<y[1] end)
 local cursor=0
 for _, interval in ipairs(intervals) do
  assert(interval[1]-cursor<=.05,"Unexpected boundary gap on edge "..i)
  cursor=math.max(cursor,interval[2])
 end
 assert(length-cursor<=.05,"Unexpected gap at end of boundary edge "..i)
end
assert(spanCount==295 and gateCount==3)
return "10 boundary edges covered by 295 barriers and three intentional gate openings"
