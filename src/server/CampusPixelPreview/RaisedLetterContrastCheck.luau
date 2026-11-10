local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local changed, preserved = 0, 0
for _, building in ipairs(buildings:GetChildren()) do
 local sign = assert(building:FindFirstChild("RaisedBuildingID_v1"))
 for _, part in ipairs(sign:GetDescendants()) do
  if part:IsA("BasePart") and part.Name == "RaisedLetterStroke" then
   if building.Name == "B1" then
    assert(part:GetAttribute("BeforeContrastColor_v1") == nil)
    preserved += 1
   else
    assert(part:GetAttribute("BeforeContrastColor_v1") and part.Color == Color3.fromRGB(28, 58, 78))
    changed += 1
   end
  end
 end
end
for _, part in ipairs(buildings.A2.A2_LibraryIdentity_v1:GetDescendants()) do
 if part:IsA("BasePart") and (part.Name == "RaisedLibraryLetter" or part.Name == "VietnameseMark") then
  assert(part:GetAttribute("BeforeContrastColor_v1") and part.Color == Color3.fromRGB(28, 58, 78))
  changed += 1
 end
end
assert(changed == 546 and preserved == 18)
return "546 raised strokes darkened; 18 B1 strokes preserved"
