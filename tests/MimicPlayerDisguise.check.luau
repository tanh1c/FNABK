-- Studio Play server: copy current character to a temporary Mimic, SURV-06.
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local originalArchivable = character.Archivable
local mimic, root = Instance.new("Model"), Instance.new("Part")
root.Name, root.Anchored, root.Parent = "Root", true, mimic
mimic.PrimaryPart, mimic.Parent = root, workspace
local attachment = require(game.ServerScriptService.FNABKServer.MimicAppearancePreview)
assert(attachment.Attach(mimic, character))
assert(character.Archivable == originalArchivable)
local visual = assert(mimic:FindFirstChild("DisguiseVisualPreview"))
assert(visual:FindFirstChild("Head") and visual:FindFirstChildOfClass("Humanoid"))
for _, item in ipairs(visual:GetDescendants()) do
	assert(not item:IsA("LuaSourceContainer") and not item:IsA("GuiBase") and not item:IsA("Tool") and not item:IsA("ForceField"))
	if item:IsA("BasePart") then assert(not item.CanCollide and not item.CanTouch) end
	if item:IsA("Humanoid") then assert(not item.EvaluateStateMachine and item.DisplayDistanceType == Enum.HumanoidDisplayDistanceType.None) end
end
local old = mimic:GetPivot():ToObjectSpace(visual:GetPivot())
mimic:PivotTo(CFrame.new(10, 1000, 0))
assert((mimic:GetPivot():ToObjectSpace(visual:GetPivot()).Position - old.Position).Magnitude < .05)
mimic:Destroy()
return "Player disguise checks passed"
