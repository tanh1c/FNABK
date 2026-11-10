-- Run in a fresh solo Studio Play server with the existing gallery (SURV-06).
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local original = character:GetPivot()
character:PivotTo(CFrame.new(0, 1003, 0))
local mimic = workspace.FNABKGraybox.Mimic
local visual = assert(mimic:FindFirstChild("DisguiseVisualPreview"))
local head, torso = visual:FindFirstChild("Head"), visual:FindFirstChild("Torso")
assert(head and head:IsA("BasePart") and torso and torso:IsA("BasePart"))
local initial = torso.CFrame:ToObjectSpace(head.CFrame)
local largest = 0
for _ = 1, 80 do
	local relative = torso.CFrame:ToObjectSpace(head.CFrame)
	local _, angle = initial:ToObjectSpace(relative):ToAxisAngle()
	largest = math.max(largest, math.abs(angle))
	task.wait(.05)
end
assert(largest > math.rad(8), "Mimic head tell was not observed")
character:PivotTo(original)
return "Mimic visual tell check passed"
