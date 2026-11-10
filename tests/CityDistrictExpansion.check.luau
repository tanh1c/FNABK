-- Run in Studio's command bar with campus v6 and the city expansion present.
local campus = assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local ring = assert(campus:FindFirstChild("CityPerimeter_20261104"))
local city = assert(campus:FindFirstChild("CityDistrictExpansion_v2_20261104"))
local w,e,n,s = ring.WestRoad.Position.X,ring.EastRoad.Position.X,ring.NorthRoad.Position.Z,ring.SouthRoad.Position.Z
local counts = {west=0,east=0,north=0,south=0,inside=0}
local styles = {Shop=0,Apartment=0,Office=0,Townhouse=0}
local params = OverlapParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = {campus.Buildings,campus.CampusBoundaryAndGates_v1,ring}
params.RespectCanCollide = true
for _, p in ipairs(city:GetChildren()) do
	assert(p:IsA("BasePart") and p.Anchored, "City parts must be anchored")
	if styles[p.Name] then styles[p.Name] += 1 end
	if p.Name == "CityLot" then
		local v=p.Position
		local key=if v.X<w then "west" elseif v.X>e then "east" elseif v.Z<n then "north" elseif v.Z>s then "south" else "inside"
		counts[key] += 1
		assert(#workspace:GetPartBoundsInBox(CFrame.new(v.X,3,v.Z),Vector3.new(54,5,54),params)==0, "A city lot overlaps the existing campus")
	end
end
for name,count in pairs(counts) do assert(count>0,"No city lots in "..name) end
for name,count in pairs(styles) do assert(count>0,"Missing building style "..name) end
assert(city.CityUnderlay.CanCollide == false, "Underlay must not change campus collision")
print("City coverage, styles and campus clearance passed")
