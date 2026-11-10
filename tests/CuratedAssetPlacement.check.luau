-- Run in Studio's command bar in the edited place.
local campus = assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local props = assert(campus:FindFirstChild("CuratedUserProps_20261104"))
local library = assert(game:GetService("ServerStorage"):FindFirstChild("FNABK_UserAssetLibrary_20261104"))
assert(#library:GetChildren() == 37, "Some original asset packages are missing")
assert(#props:GetChildren() == 16, "A curated visual is missing")
for _, model in ipairs(props:GetChildren()) do
	assert(model:GetAttribute("VisualOnly") == true, "Item must be identified as visual-only")
	for _, item in ipairs(model:GetDescendants()) do
		assert(not item:IsA("LuaSourceContainer") and not item:IsA("GuiBase"), "An imported script or UI escaped filtering")
		if item:IsA("BasePart") then assert(item.Anchored and not item.CanCollide, "Visual prop must not block paths") end
	end
end
print("Curated prop safety and original asset checks passed")
