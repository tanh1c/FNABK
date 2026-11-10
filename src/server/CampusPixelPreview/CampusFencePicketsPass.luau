-- ponytail: three visible bars per span; increase density only after target-device profiling.
local boundary = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.CampusBoundaryAndGates_v1
assert(not boundary:FindFirstChild("FencePickets_v1"))
local plans = {}
for _, edge in ipairs(boundary:GetChildren()) do
 if edge:IsA("Model") and edge.Name:match("^BoundaryEdge_") then
  for _, base in ipairs(edge:GetChildren()) do
   if base:IsA("BasePart") and base.Name == "BoundaryBase" then
    assert(base.Size.X > 2 and base.Size.Y > 0)
    for _, fraction in ipairs({-.25, 0, .25}) do
     table.insert(plans, base.CFrame * CFrame.new(base.Size.X*fraction, 3.4, 0))
    end
   end
  end
 end
end
assert(#plans == 885, "Unexpected fence span count; nothing changed")
local output = Instance.new("Folder"); output.Name = "FencePickets_v1"; output.Parent = boundary
for first = 1, #plans, 90 do
 local batch = Instance.new("Folder"); batch.Name = "Pickets_" .. first
 for i = first, math.min(first+89, #plans) do
  local p = Instance.new("Part");p.Name="FencePicket";p.Size=Vector3.new(.22,4.6,.22);p.CFrame=plans[i]
  p.Color=Color3.fromRGB(48,73,85);p.Material=Enum.Material.Metal;p.Anchored=true
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=batch
 end
 batch.Parent=output
 task.wait()
end
return "Added 885 visible fence pickets across 295 existing spans"
