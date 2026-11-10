local preview=assert(workspace:FindFirstChild("FNABK_Campus_PixelPreview_v1_B1Review_v6"))
local parts={}
for _,name in ipairs({"Buildings","Areas","CampusBoundary"}) do
 for _,part in ipairs(preview[name]:GetDescendants()) do
  if part:IsA("BasePart") and part.Name:match("^Edge%d+_Segment%d+$") then
   assert(not part.CanCollide)
   table.insert(parts,part)
  end
 end
end
assert(#parts==266,"Unexpected traced-outline count")
for _,part in ipairs(parts) do
 if part:GetAttribute("BeforeOutlineHiddenTransparency_v1")==nil then
  part:SetAttribute("BeforeOutlineHiddenTransparency_v1",part.Transparency)
 end
 part.Transparency=1
end
return string.format("Hidden %d plot and boundary outline segments",#parts)
