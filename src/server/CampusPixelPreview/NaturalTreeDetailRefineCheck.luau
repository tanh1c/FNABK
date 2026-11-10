local root = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local count = 0
for _, tree in ipairs(root:GetDescendants()) do
 if tree:IsA("Model") and tree:GetAttribute("TreeDetailRefined_v1") then
  count += 1
  local trunk = tree.Trunk
  assert(trunk.Transparency == 1 and trunk.CanCollide and trunk:GetAttribute("BeforeBarkRefineTransparency_v1") ~= nil)
  local bark = tree.BarkDetail_v1:GetChildren()
  assert(#bark == 2)
  for _, p in ipairs(bark) do
   assert(p.Name == "BarkSegment" and not p.CanCollide and not p.CanQuery)
   assert((Vector3.new(p.Position.X, 0, p.Position.Z) - Vector3.new(trunk.Position.X, 0, trunk.Position.Z)).Magnitude < .01)
  end
  local layers, leaflets = 0, 0
  for _, p in ipairs(tree.DetailedCanopy_v1:GetChildren()) do
   if p.Name == "FoliageLayer" then layers += 1 elseif p.Name == "Leaflet" then leaflets += 1 end
   assert(not p.CanCollide and not p.CanQuery)
  end
  if tree:GetAttribute("TreeStyle_v1") == 0 then assert(leaflets == 14 and layers == 0)
  else assert(layers == 3 and leaflets == 0) end
 end
end
assert(count == 158 and root.CampusTreeDetailRefine_v1:GetAttribute("TreeCount") == count)
return "158 refined trees checked for trunk alignment and decorative foliage"
