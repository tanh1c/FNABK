local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local ray=RaycastParams.new();ray.RespectCanCollide=true
local count=0
for _,name in ipairs({"B3","B4","B9","C4","C5","Facility7","Canteen"}) do
 local entry=buildings[name].CenterFacingEntrance_v1
 local sign=entry.EntranceWayfinding_v1
 local gui=assert(sign:FindFirstChildOfClass("SurfaceGui"))
 assert(not sign.CanCollide and not gui.AlwaysOnTop and gui.Face==Enum.NormalId.Back)
 assert(gui:FindFirstChildOfClass("TextLabel").Text=="LỐI VÀO")
 for _,distance in ipairs({3,5}) do
  local start=sign.Position-sign.CFrame.LookVector*distance
  start=Vector3.new(start.X,3.8,start.Z)
  assert(workspace:Raycast(start,Vector3.new(0,-6,0),ray),"No entrance approach floor: "..name)
  assert(not workspace:Raycast(start,(sign.Position-start)*.98,ray),"Entrance wayfinding blocked: "..name)
 end
 count+=1
end
assert(count==7)
return "Seven entrance labels have sampled ground and unobstructed exterior sightlines"
