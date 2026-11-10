-- Add a usable bench to the previously empty narrow grass triangle.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local area=assert(root.CampusNarrowPlanting_v1:FindFirstChild("grass23"))
assert(not area:FindFirstChild("NarrowStoneBench_v1"))
local origin=root:GetAttribute("PreviewOriginWorld")
local pos=Vector3.new(origin.X+1245,0,origin.Z+669)
local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include
p.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1,root.CampusGrass_v1,root.CampusParkDetails_v1,root.CampusNarrowPlanting_v1}
for _,v in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos+Vector3.new(0,2,0)),Vector3.new(6,4,4),p)) do assert(not v.CanCollide,"Bench site occupied: "..v:GetFullName()) end
local bench=Instance.new("Model");bench.Name="NarrowStoneBench_v1"
local seat=Instance.new("Seat");seat.Name="Seat";seat.Size=Vector3.new(5,.45,1.8);seat.Position=pos+Vector3.new(0,1.65,0)
seat.Color=Color3.fromRGB(174,174,162);seat.Material=Enum.Material.Concrete;seat.Anchored=true;seat.Parent=bench
for _,dx in ipairs({-1.8,1.8}) do
 local support=Instance.new("Part");support.Name="Support";support.Size=Vector3.new(.55,1.4,1.5);support.Position=pos+Vector3.new(dx,.85,0)
 support.Color=seat.Color;support.Material=seat.Material;support.Anchored=true;support.Parent=bench
end
local back=Instance.new("Part");back.Name="Backrest";back.Size=Vector3.new(5,1.45,.35);back.Position=pos+Vector3.new(0,2.6,.75)
back.Color=seat.Color;back.Material=seat.Material;back.Anchored=true;back.CanCollide=false;back.Parent=bench
bench.Parent=area
return "Added a usable stone bench inside grass23"
