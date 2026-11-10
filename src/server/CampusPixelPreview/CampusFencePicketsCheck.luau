local boundary = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.CampusBoundaryAndGates_v1
local pickets = boundary.FencePickets_v1
local function key(v) return string.format("%.2f:%.2f:%.2f",v.X,v.Y,v.Z) end
local locations, count = {}, 0
for _, p in ipairs(pickets:GetDescendants()) do
 if p:IsA("BasePart") then
  assert(p.Name=="FencePicket" and not p.CanCollide and not p.CanQuery and p.Transparency==0)
  local k=key(p.Position);locations[k]=(locations[k] or 0)+1;count+=1
 end
end
local expected = 0
for _, edge in ipairs(boundary:GetChildren()) do
 if edge:IsA("Model") and edge.Name:match("^BoundaryEdge_") then
  for _, base in ipairs(edge:GetChildren()) do
   if base:IsA("BasePart") and base.Name=="BoundaryBase" then
    for _, fraction in ipairs({-.25,0,.25}) do
     local k=key((base.CFrame*CFrame.new(base.Size.X*fraction,3.4,0)).Position)
     assert(locations[k] and locations[k]>0,"Missing picket at "..k)
     locations[k]-=1;expected+=1
    end
   end
  end
 end
end
assert(count==885 and expected==count)
return "885 visible noncolliding pickets match 295 boundary spans"
