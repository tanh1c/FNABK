-- Studio client command bar: move on the ground while running this check.
local player = game.Players.LocalPlayer
local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
local r6 = humanoid.RigType == Enum.HumanoidRigType.R6
local walk = if r6 then "88928064787947" else "75844816134286"
local run = if r6 then "74104654852598" else "110191333474252"
local expected = if humanoid.WalkSpeed > 12 then run else walk
for _, track in ipairs(humanoid.Animator:GetPlayingAnimationTracks()) do
	if track.Priority == Enum.AnimationPriority.Action and track.Animation.AnimationId == "rbxassetid://" .. expected then
		print("Expected locomotion track is playing: " .. expected)
		return
	end
end
error("Expected locomotion track is not playing; keep moving and repeat")
