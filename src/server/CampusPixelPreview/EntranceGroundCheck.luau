-- Sample ground in front of the 20 modeled center-facing entrance canopies.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Include
p.FilterDescendantsInstances={root.CampusGround_v1,root.CampusExactGrass_v1,root.CampusGateAprons_v1}
p.RespectCanCollide=true
local count=0
for _,b in ipairs(root.Buildings:GetChildren()) do
 local entry=b:FindFirstChild("CenterFacingEntrance_v1")
 if entry then
  local canopy=entry.EntryCanopy
  for _,distance in ipairs({4,8,12,16}) do
   local pos=canopy.CFrame:PointToWorldSpace(Vector3.new(0,4-canopy.Position.Y,distance))
   assert(workspace:Raycast(pos,Vector3.new(0,-8,0),p),"No approach ground: "..b.Name)
   count+=1
  end
 end
end
assert(count==80)
return "80 ground samples outside 20 entrances checked"
