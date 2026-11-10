local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
local group=assert(b:FindFirstChild("CanteenAccessibleStair_v1"))
local t=group.Treads
local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={b}
local previous
for i=1,16 do
 local s=assert(t:FindFirstChild(string.format("CanteenStair_%02d",i)))
 assert(s.CanCollide and s.Size.X>=3.5 and s.Size.Z>=1.5)
 local top=s.Position.Y+s.Size.Y/2
 if previous then assert(math.abs(top-previous-12.85714/16)<.02) end
 previous=top
 local cf=s.CFrame*CFrame.new(0,s.Size.Y/2+1,0)
 for _,v in ipairs(workspace:GetPartBoundsInBox(cf,Vector3.new(s.Size.X-.1,.5,s.Size.Z-.1),p)) do
  assert(not v.CanCollide or v:IsDescendantOf(group) or v.Name:match("^WalkableFloor_01"),s.Name.." blocked by "..v:GetFullName())
 end
end
assert(math.abs(previous-13.65714)<.03)
assert(game.ServerStorage:FindFirstChild("CanteenStairBefore_v1"))
return "16 wide Canteen steps, headroom samples and retained originals checked"
