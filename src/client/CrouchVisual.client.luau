--!strict
-- Local presentation of the server's replicated crouch state for all players.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

type PoseJoint = Motor6D | AnimationConstraint
local crouchJoints: { [PoseJoint]: boolean } = {}
local runningVolumes: { [Sound]: number } = {}

local function crouchAnimationPlaying(character: Model): boolean
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then return false end
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		local animation = track.Animation
		if animation and (animation.AnimationId == "rbxassetid://100285511964294"
			or animation.AnimationId == "rbxassetid://134199951542913") then return true end
	end
	return false
end

local function applyPose(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local torso = character:FindFirstChild(if humanoid.RigType == Enum.HumanoidRigType.R15 then "LowerTorso" else "Torso")
	if not torso then return end
	for _, name in ipairs(if humanoid.RigType == Enum.HumanoidRigType.R15 then { "Waist", "LeftHip", "RightHip" } else { "Left Hip", "Right Hip" }) do
		local joint = character:FindFirstChild(name, true)
		if joint and (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) then
			crouchJoints[joint] = true
			-- Override the animation pose only while crouched; the normal Animator
			-- resumes after the state changes. R6 and R15 use different joint names.
			joint.Transform = CFrame.Angles(math.rad(if name == "Waist" then 20 else -35), 0, 0)
		end
	end
end

-- Apply after Animator evaluation and before the physics joint transform batch.
RunService.PreSimulation:Connect(function()
	local activeJoints: { [PoseJoint]: boolean } = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then continue end
		local crouching = player:GetAttribute("FNABKCrouching") == true
		if crouching and not crouchAnimationPlaying(character) then
			applyPose(character)
			for joint in pairs(crouchJoints) do
				if joint:IsDescendantOf(character) then activeJoints[joint] = true end
			end
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		local sound = root and root:FindFirstChild("Running")
		if sound and sound:IsA("Sound") then
			if runningVolumes[sound] == nil then runningVolumes[sound] = sound.Volume end
			sound.Volume = runningVolumes[sound] * (if crouching then 0.25 else 1)
		end
	end
	for joint in pairs(crouchJoints) do
		if not joint.Parent then
			crouchJoints[joint] = nil
		elseif not activeJoints[joint] then
			joint.Transform = CFrame.identity
			crouchJoints[joint] = nil
		end
	end
	for sound in pairs(runningVolumes) do
		if not sound.Parent then runningVolumes[sound] = nil end
	end
end)
