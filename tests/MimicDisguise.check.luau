-- Run on the Studio Play server with the existing gallery (SURV-06).
local mimic = workspace.FNABKGraybox.Mimic
local visual = assert(mimic:FindFirstChild("DisguiseVisualPreview"), "missing student disguise")
assert(visual:FindFirstChild("Humanoid") and visual:FindFirstChild("Torso"), "missing student body")
for _, instance in ipairs(visual:GetDescendants()) do
	assert(not instance:IsA("LuaSourceContainer") and not instance:IsA("GuiBase"), "unsafe visual descendant")
	if instance:IsA("BasePart") then assert(not instance.CanCollide and not instance.CanTouch) end
end
local old = mimic:GetPivot()
local relative = old:ToObjectSpace(visual:GetPivot())
mimic:PivotTo(old * CFrame.new(3, 0, 0))
assert((mimic:GetPivot():ToObjectSpace(visual:GetPivot()).Position - relative.Position).Magnitude < .05, "visual did not follow Mimic")
mimic:PivotTo(old)
return "Mimic disguise checks passed"
