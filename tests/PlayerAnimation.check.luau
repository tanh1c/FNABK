-- Run in the Studio client during an active round with the server-granted Baton.
local player = game:GetService("Players").LocalPlayer
local character = assert(player.Character)
local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
local animator = assert(humanoid:FindFirstChildOfClass("Animator"))
local r6 = humanoid.RigType == Enum.HumanoidRigType.R6
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("FNABKRemotes")
local baton = assert(player.Backpack:FindFirstChild("Baton") or character:FindFirstChild("Baton"))
humanoid:EquipTool(baton)
local function findTrack(id)
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. id and track.Length > 0 then return track end
	end
end
local function waitFor(id, move, alternative)
	local deadline = os.clock() + 3
	while os.clock() < deadline do
		if move then humanoid:Move(Vector3.new(1, 0, 0), false) end
		if findTrack(id) or (alternative and findTrack(alternative)) then return true end
		task.wait(0.02)
	end
	return false
end
local ok, err = pcall(function()
	remotes.AttackRequest:FireServer(nil)
	assert(waitFor(if r6 then "128366585935025" else "79233365540309", false,
		if r6 then "76772591818471" else "91071199232918"), "Baton animation did not load")
	remotes.MovementRequest:FireServer("Sprint", true)
	assert(waitFor(if r6 then "74104654852598" else "110191333474252", true), "Sprint animation did not load")
	remotes.MovementRequest:FireServer("Sprint", false)
	remotes.MovementRequest:FireServer("Crouch", true)
	assert(waitFor(if r6 then "100285511964294" else "134199951542913", true), "Crouch animation did not load")
end)
remotes.MovementRequest:FireServer("Sprint", false)
remotes.MovementRequest:FireServer("Crouch", false)
humanoid:Move(Vector3.zero, false)
assert(ok, err)
print("Baton, sprint and crouch animations loaded")
