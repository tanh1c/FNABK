local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local count=0
for _,b in ipairs(bs:GetChildren()) do
 local folder=b:FindFirstChild("StairStringers_v1")
 if folder then for _,v in ipairs(folder:GetChildren()) do
  assert(v:IsA("BasePart") and v.Anchored and not v.CanCollide and not v.CanQuery)
  count+=1
 end end
end
assert(count==66)
return "66 noncolliding stair stringers present"
