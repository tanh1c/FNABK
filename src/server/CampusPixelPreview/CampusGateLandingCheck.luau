local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Include
p.FilterDescendantsInstances={root.CampusGround_v1,root.CampusGateAprons_v1};p.RespectCanCollide=true
local n=0
for _,g in ipairs(root.CampusBoundaryAndGates_v1:GetDescendants()) do
 if g:IsA("Model") and g.Name:match("^CampusGate_") then
  local h=g.GateHeader
  for _,z in ipairs({-14,-8,-2,2,8}) do
   local pos=h.CFrame:PointToWorldSpace(Vector3.new(0,3-h.Position.Y,z))
   assert(workspace:Raycast(pos,Vector3.new(0,-5,0),p),"No gate floor: "..g.Name)
   n+=1
  end
 end
end
assert(n==15)
return "Three gates have sampled ground on both sides"
