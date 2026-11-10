-- Run in the Studio client during an R6 playtest, while moving and holding Shift.
local player = game:GetService("Players").LocalPlayer
local character = assert(player.Character)
local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
assert(humanoid.RigType == Enum.HumanoidRigType.R6, "Select an R6 avatar for this test")
local animate = assert(character:FindFirstChild("Animate"))
assert(animate.idle.Animation1.AnimationId == "rbxassetid://100934330110279", "R6 idle is not configured")
assert(animate.walk.WalkAnim.AnimationId == "rbxassetid://88928064787947", "R6 walk is not configured")
local animator = assert(humanoid:FindFirstChildOfClass("Animator"))
local running = false
for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
	if track.Animation and track.Animation.AnimationId == "rbxassetid://74104654852598" then running = true end
end
assert(running, "Move and hold Shift before running this check")
print("R6 idle, walk and sprint checks passed")
