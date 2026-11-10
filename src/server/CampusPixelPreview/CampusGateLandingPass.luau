-- Small provisional landings allow crossing the three perimeter gates.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusGateAprons_v1"))
local gates={}
for _,g in ipairs(root.CampusBoundaryAndGates_v1:GetDescendants()) do
 if g:IsA("Model") and g.Name:match("^CampusGate_") then table.insert(gates,g) end
end
assert(#gates==3)
local group=Instance.new("Folder");group.Name="CampusGateAprons_v1"
for _,g in ipairs(gates) do
 local h=assert(g:FindFirstChild("GateHeader"))
 local part=Instance.new("Part");part.Name=g.Name.."_Landing"
 part.Size=Vector3.new(h.Size.X-2,.25,24)
 part.CFrame=h.CFrame*CFrame.new(0,-h.Position.Y-.145,-6)
 part.Color=Color3.fromRGB(115,119,116);part.Material=Enum.Material.Concrete
 part.Anchored=true;part.CanCollide=true;part.CanTouch=false;part.CastShadow=false
 part.Parent=group
end
group.Parent=root
return "Added three temporary gate landings"
