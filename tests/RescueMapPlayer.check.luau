-- Studio Play client: open M first; temporarily moves the local character.
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local marker = player.PlayerGui:WaitForChild("FNABKRescueMap"):FindFirstChild("PlayerMarker", true)
assert(marker and marker:IsA("TextLabel") and marker.Visible)
local original, anchored = character:GetPivot(), root.Anchored
root.Anchored = true
character:PivotTo(CFrame.new(100000, 1000, 100000))
task.wait(.2)
assert(marker.Text == "EDGE" and marker.Position.X.Scale == 1 and marker.Position.Y.Scale == 1)
character:PivotTo(original)
root.Anchored = anchored
task.wait(.2)
assert(marker.Visible)
return "Rescue map player marker passed"
