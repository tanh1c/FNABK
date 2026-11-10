-- Run in a fresh solo Studio Play server (SURV-06/07).
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local mimic = workspace.FNABKGraybox.Mimic
local original, originalMimic, anchored = character:GetPivot(), mimic:GetPivot(), root.Anchored
local floor = Instance.new("Part")
floor.Size, floor.Position, floor.Anchored, floor.Parent = Vector3.new(100, 1, 100), Vector3.new(0, 999.5, 0), true, workspace
character:PivotTo(CFrame.new(0, 1003, -25)); root.Anchored = true
mimic:PivotTo(CFrame.lookAt(Vector3.new(0, 1003, 0), Vector3.new(0, 1003, -25)))
local start = mimic.PrimaryPart.Position
task.wait(4)
assert((mimic.PrimaryPart.Position - start).Magnitude > 10, "Mimic did not pursue on elevated floor")
assert(math.abs(mimic.PrimaryPart.Position.Y - start.Y) < .1, "Mimic changed floors unexpectedly")
character:PivotTo(original); root.Anchored = anchored
mimic:PivotTo(originalMimic); floor:Destroy()
return "Elevated Mimic path check passed"
