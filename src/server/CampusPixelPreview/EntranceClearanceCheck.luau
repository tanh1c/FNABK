-- Check main entrance approaches with only their own main leaves excluded.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local tested=0
for _,b in ipairs(bs:GetChildren()) do
 local entry=b:FindFirstChild("CenterFacingEntrance_v1")
 if entry then
  local canopy=entry.EntryCanopy;local excluded={}
  for _,part in ipairs(entry:GetChildren()) do
   if part:IsA("BasePart") and part:GetAttribute("CampusDoor") then table.insert(excluded,part) end
  end
  local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Exclude;p.FilterDescendantsInstances=excluded;p.RespectCanCollide=true
  for _,x in ipairs({-1,0,1}) do
   for _,y in ipairs({2.5,5,7}) do
    local origin=canopy.CFrame:PointToWorldSpace(Vector3.new(x,y-canopy.Position.Y,9))
    local hit=workspace:Raycast(origin,canopy.CFrame.LookVector*15,p)
    assert(not hit,b.Name.." entrance blocked by "..(hit and hit.Instance:GetFullName() or "unknown"))
    tested+=1
   end
  end
 end
end
assert(tested==180)
return "180 main entrance rays clear with main leaves excluded"
