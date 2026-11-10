-- Run in the Studio command bar with the edited campus v6.
local campus=assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local props=assert(campus:FindFirstChild("UserLabEquipment_20261104"))
assert(#props:GetChildren()==2,"Expected two laboratory displays")
for _,model in ipairs(props:GetChildren()) do
	assert(model:GetAttribute("VisualOnly")==true,"Lab equipment must be marked visual-only")
	for _,v in ipairs(model:GetDescendants()) do
		assert(not v:IsA("LuaSourceContainer") and not v:IsA("Tool") and not v:IsA("GuiBase"),"Unsafe lab instance")
		if v:IsA("BasePart") then assert(v.Anchored and not v.CanCollide,"Lab display must not obstruct paths") end
	end
end
print("Lab equipment checks passed")
