-- Studio Play server: test reveal transitions with an avatar copy. SURV-06.
local character = assert(game.Players:GetPlayers()[1].Character)
local mimic, root, body = Instance.new("Model"), Instance.new("Part"), Instance.new("Part")
root.Name, root.Anchored, root.Parent = "Root", true, mimic
body.Name, body.Transparency, body.Parent = "Torso", .15, mimic
mimic.PrimaryPart, mimic.Parent = root, workspace
mimic:SetAttribute("MimicState", "Disguise")
assert(require(game.ServerScriptService.FNABKServer.MimicAppearancePreview).Attach(mimic, character))
local visual = assert(mimic:FindFirstChild("DisguiseVisualPreview"))
local head = assert(visual:FindFirstChild("Head"))
assert(head:IsA("BasePart") and body.Transparency == 1)
local original = head.Transparency
for _, state in ipairs({ "Chase", "Attack", "Stunned", "Defeated" }) do
	mimic:SetAttribute("MimicState", state)
	task.wait()
	assert(head.Transparency == 1 and not head.CanQuery and math.abs(body.Transparency - .15) < .001, state)
end
mimic:SetAttribute("MimicState", "Disguise")
task.wait()
assert(head.Transparency == original and head.CanQuery and body.Transparency == 1)
mimic:Destroy()
return "Mimic reveal checks passed"
