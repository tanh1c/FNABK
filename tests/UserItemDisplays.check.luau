-- Run in Studio's command bar with the edited campus v6 in Workspace.
local campus=assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local displays=assert(campus:FindFirstChild("UserItemDisplays_v3_20261104"))
local originals=assert(game:GetService("ServerStorage"):FindFirstChild("FNABK_UserStarterTools_20261104"))
assert(#displays:GetChildren()==12 and #originals:GetChildren()==16, "Item displays or original Tools missing")
for _,model in ipairs(displays:GetChildren()) do
	assert(model:GetAttribute("VisualOnly")==true, "Display must be marked visual-only")
	for _,item in ipairs(model:GetDescendants()) do
		assert(not item:IsA("Tool") and not item:IsA("LuaSourceContainer") and not item:IsA("GuiBase"), "Unsafe instance in display")
		if item:IsA("BasePart") then assert(item.Anchored and not item.CanCollide, "Display must be nonblocking") end
	end
end
print("Item displays and original Tools checks passed")
