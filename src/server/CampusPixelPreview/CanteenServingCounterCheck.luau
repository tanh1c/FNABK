local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
local counter = building.CanteenServingCounter_v1
local base = counter.CounterBase
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={building.Canteen.WalkableStructure};ray.RespectCanCollide=true
for _,x in ipairs({-2.8,2.8}) do for _,z in ipairs({-.8,.8}) do
 local hit=workspace:Raycast(base.CFrame:PointToWorldSpace(Vector3.new(x,3,z)),Vector3.new(0,-7,0),ray)
 assert(hit and hit.Instance.Name:match("^WalkableFloor") and math.abs(hit.Position.Y-(base.Position.Y-base.Size.Y/2))<.1)
end end
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={building}
for _,x in ipairs({-2,0,2}) do
 local p=base.CFrame:PointToWorldSpace(Vector3.new(x,1,-3))
 for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(p),Vector3.new(1.8,4.5,1.8),overlap)) do
  assert(not part.CanCollide or part.Name:match("^WalkableFloor"),"Counter approach blocked: "..part:GetFullName())
 end
end
-- The center aisle between dining rows connects the main entry area to the counter.
for x=5277,5317,2 do
 local center=Vector3.new(x,3.3,1969.3)
 local hit=workspace:Raycast(center,Vector3.new(0,-5,0),ray)
 assert(hit and hit.Instance.Name:match("^WalkableFloor"),"Aisle lacks floor")
 for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(center),Vector3.new(1.7,4.5,1.7),overlap)) do
  assert(not part.CanCollide or part.Name:match("^WalkableFloor"),"Canteen aisle blocked: "..part:GetFullName())
 end
end
local gui=counter.ServiceSign:FindFirstChildOfClass("SurfaceGui")
assert(gui and not gui.AlwaysOnTop and gui:FindFirstChildOfClass("TextLabel").Text=="QUẦY PHỤC VỤ")
assert(#counter:GetChildren()==8)
return "Canteen counter support, sign and 21 central aisle samples checked"
