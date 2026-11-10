-- ponytail: B1 retains light letters against its darker sampled backdrop; refine after visual review.
local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local parts = {}
for _, building in ipairs(buildings:GetChildren()) do
 local sign = assert(building:FindFirstChild("RaisedBuildingID_v1"), "Missing sign: " .. building.Name)
 if building.Name ~= "B1" then
  for _, part in ipairs(sign:GetDescendants()) do
   if part:IsA("BasePart") and part.Name == "RaisedLetterStroke" then table.insert(parts, part) end
  end
 end
end
for _, part in ipairs(buildings.A2.A2_LibraryIdentity_v1:GetDescendants()) do
 if part:IsA("BasePart") and (part.Name == "RaisedLibraryLetter" or part.Name == "VietnameseMark") then table.insert(parts, part) end
end
assert(#parts > 300)
for _, part in ipairs(parts) do assert(part:GetAttribute("BeforeContrastColor_v1") == nil) end
for _, part in ipairs(parts) do
 part:SetAttribute("BeforeContrastColor_v1", part.Color)
 part.Color = Color3.fromRGB(28, 58, 78)
end
return "Darkened " .. #parts .. " raised letter strokes; original colors retained"
