-- Validate the bounded decorative corrections against their preserved sizes.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local count=0
for _,b in ipairs(bs:GetChildren()) do
 local structure=b:FindFirstChild(b.Name) and b[b.Name]:FindFirstChild("WalkableStructure")
 local roof=structure and structure:FindFirstChild("WalkableRoofCap")
 for _,v in ipairs(b:GetDescendants()) do
  if v:IsA("BasePart") and v:GetAttribute("BeforeFacadeSize_v1") then
   assert(not v.CanCollide and v:GetAttribute("BeforeFacadeCFrame_v1"))
   if not v.Name:match("^ProjectingStairCore_") then
    assert(roof and v.Position.Y+v.Size.Y/2<=roof.Position.Y+roof.Size.Y/2+1.02)
   end
   count+=1
  end
 end
end
local b3=bs.B3.B3
assert(math.abs((b3.MassingFeatures.ProjectingStairCore_Cap.Position.Y+b3.MassingFeatures.ProjectingStairCore_Cap.Size.Y/2)-(b3.WalkableStructure.WalkableRoofCap.Position.Y+b3.WalkableStructure.WalkableRoofCap.Size.Y/2+10))<.05)
assert(count==99)
return "99 decorative facade corrections retain originals and fit their roofs"
