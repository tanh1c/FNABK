-- Run from the Studio client command bar on a living R15 player during Play Test.
local player = game:GetService("Players").LocalPlayer
local humanoid = assert(player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
assert(humanoid.RigType == Enum.HumanoidRigType.R15, "Use an R15 character")
assert(player:GetAttribute("FNABKDowned") ~= true and player:GetAttribute("FNABKEliminated") ~= true, "Use a living player")
local animator = assert(humanoid:FindFirstChildOfClass("Animator"))
local old = player:GetAttribute("FNABKDowned")
local function track()
	for _, item in ipairs(animator:GetPlayingAnimationTracks()) do
		if item.Animation and item.Animation.AnimationId == "rbxassetid://108382007838962" then return item end
	end
end
local ok, err = pcall(function()
	player:SetAttribute("FNABKDowned", true) -- Client-only presentation test; no server damage.
	local deadline = os.clock() + 5
	repeat task.wait(0.05) until (track() and track().Length > 0) or os.clock() >= deadline
	assert(track() and track().Length > 0, "Downed animation did not load")
end)
player:SetAttribute("FNABKDowned", old)
task.wait(0.2)
assert(ok, err)
assert(not track(), "Downed animation did not stop after recovery")
print("R15 downed presentation checks passed")
