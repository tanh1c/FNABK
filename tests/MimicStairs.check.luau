-- Run in a fresh solo Studio Play server (SURV-06/07).
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local mimic = workspace.FNABKGraybox.Mimic
local original, originalMimic, anchored = character:GetPivot(), mimic:GetPivot(), root.Anchored
local stairs = Instance.new("Model")
stairs.Parent = workspace
for i = 0, 9 do
	local step = Instance.new("Part")
	step.Anchored, step.Size = true, Vector3.new(20, 1 + i, 4)
	step.Position, step.Parent = Vector3.new(0, 1000 + (i + 1) / 2, -i * 4), stairs
end
task.wait(1)
character:PivotTo(CFrame.new(0, 1013, -36)); root.Anchored = true
mimic:PivotTo(CFrame.lookAt(Vector3.new(0, 1004, 0), Vector3.new(0, 1004, -36)))
local start = mimic.PrimaryPart.Position
task.wait(6)
local finish = mimic.PrimaryPart.Position
assert(finish.Y - start.Y > 5 and start.Z - finish.Z > 25, "Mimic did not follow stairs")
character:PivotTo(original); root.Anchored = anchored
mimic:PivotTo(originalMimic); stairs:Destroy()
return "Mimic stairs check passed"
