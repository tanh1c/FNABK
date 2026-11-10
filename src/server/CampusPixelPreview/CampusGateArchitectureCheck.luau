local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local new=root.CampusGateArchitecture_v1
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances={root};ray.RespectCanCollide=true
local count,samples,labels=0,0,0
for _,g in ipairs(root.CampusBoundaryAndGates_v1:GetDescendants()) do
 if g:IsA("Model") and g.Name:match("^CampusGate_%d+$") then
  local h=g.GateHeader;local portal=assert(new:FindFirstChild(g.Name))
  assert(h.Transparency==1 and not h.CanCollide and not h.CanQuery)
  for _,gui in ipairs(h:GetChildren()) do if gui:IsA("SurfaceGui") then assert(not gui.Enabled);labels+=1 end end
  assert(portal.HighLintel.Position.Y>=19 and portal.HighLintel.Size.X>=36)
  for _,x in ipairs({-12,-6,0,6,12}) do for _,y in ipairs({2,6,12,16}) do
   local start=h.CFrame:PointToWorldSpace(Vector3.new(x,y-h.Position.Y,-10))
   local direction=h.CFrame:VectorToWorldSpace(Vector3.new(0,0,20))
   local hit=workspace:Raycast(start,direction,ray)
   assert(not hit,"Gate passage blocked: "..g.Name)
   samples+=1
  end end
  count+=1
 end
end
assert(count==3 and labels==6 and samples==60)
return string.format("%d large gates, %d disabled labels and %d clear passage rays checked",count,labels,samples)
