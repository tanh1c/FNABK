-- Run in Studio's command bar with campus v6 in Workspace.
local campus=assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local machine=assert(campus:FindFirstChild("UserVendingMachine_20261104"))
assert(machine:GetAttribute("VisualOnly")==true, "Machine must be marked visual-only")
local parts=0
for _, item in ipairs(machine:GetDescendants()) do
	assert(not item:IsA("Tool") and not item:IsA("LuaSourceContainer") and not item:IsA("GuiBase"), "Machine contains executable/UI content")
	if item:IsA("BasePart") then parts+=1;assert(item.Anchored and not item.CanCollide, "Machine must be nonblocking") end
end
assert(parts>0, "Machine contains no geometry")
print("Vending display checks passed")
