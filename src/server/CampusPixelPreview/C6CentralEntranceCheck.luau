local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.C6
local entry=b.CenterFacingEntrance_v1
local door=entry.MainEntryDoor
local closed=door:GetAttribute("DoorClosed")
assert((-closed.LookVector).X>.99 and entry:GetAttribute("EntranceDirection")=="toward_central_road")
assert(b.SecondaryEntrance_v1.SecondaryEntryDoor:GetAttribute("CampusDoor"))
assert(game.ServerStorage.C6CentralEntranceOriginal_v1:FindFirstChild("OuterWall_Floor_01_North"))
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={door};ray.RespectCanCollide=true
for _,x in ipairs({-1,0,1}) do for _,y in ipairs({2.5,4.5,6.5}) do
 local start=closed:PointToWorldSpace(Vector3.new(x,y-closed.Y,8))
 assert(not workspace:Raycast(start,closed.LookVector*16,ray),"C6 main entry blocked")
end end
for _,z in ipairs({-6,-3,3,6,10,15}) do
 local point=closed:PointToWorldSpace(Vector3.new(0,4-closed.Y,z))
 assert(workspace:Raycast(point,Vector3.new(0,-7,0),ray),"C6 approach lacks floor")
end
local sign=b.C6CentralRaisedID_v1
assert(sign:GetAttribute("BuildingID")=="C6" and #sign:GetChildren()>2)
return "C6 central-side entrance, retained secondary entry and raised ID checked"
