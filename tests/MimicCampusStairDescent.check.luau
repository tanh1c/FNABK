-- Run in a fresh solo Studio Play server (SURV-06/07).
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local mimic = workspace.FNABKGraybox.Mimic
local original, originalMimic, anchored = character:GetPivot(), mimic:GetPivot(), root.Anchored
local b = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
local low, high = b.Stair_1_2, b.Stair_1_15
local bottom = low.Position + Vector3.new(0, low.Size.Y / 2 + 3, 0)
local top = high.Position + Vector3.new(0, high.Size.Y / 2 + 3, 0)
character:PivotTo(CFrame.new(bottom)); root.Anchored = true
mimic:PivotTo(CFrame.lookAt(top, Vector3.new(bottom.X, top.Y, bottom.Z)))
task.wait(8)
local distance = (mimic.PrimaryPart.Position - root.Position).Magnitude
assert(distance <= 3, "Mimic did not descend into three-dimensional attack range")
assert(mimic:GetAttribute("MimicState") == "Attack", "Mimic did not attack")
character:PivotTo(original); root.Anchored = anchored
mimic:PivotTo(originalMimic)
return "Campus Mimic stair descent check passed"
