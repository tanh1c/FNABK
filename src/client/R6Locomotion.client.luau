--!strict
-- Player locomotion presentation; movement and stamina remain server-owned.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local config = require(ReplicatedStorage:WaitForChild("FNABKShared"):WaitForChild("GameConfig"))

local function setup(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid or not humanoid:IsA("Humanoid") then return end
	local r6 = humanoid.RigType == Enum.HumanoidRigType.R6
	local animate = character:WaitForChild("Animate", 10)
	if not animate or player.Character ~= character then return end
	local function replace(name: string, id: string)
		local folder = animate:FindFirstChild(name)
		if folder then
			for _, animation in ipairs(folder:GetChildren()) do
				if animation:IsA("Animation") then animation.AnimationId = id end
			end
		end
	end
	replace("idle", if r6 then "rbxassetid://100934330110279" else "rbxassetid://82363943430170")
	replace("walk", if r6 then "rbxassetid://88928064787947" else "rbxassetid://75844816134286")
	replace("run", if r6 then "rbxassetid://74104654852598" else "rbxassetid://110191333474252")

	local animator = humanoid:WaitForChild("Animator", 10)
	if not animator or not animator:IsA("Animator") then return end
	local walkAnimation = Instance.new("Animation")
	walkAnimation.AnimationId = if r6 then "rbxassetid://88928064787947" else "rbxassetid://75844816134286"
	local runAnimation = Instance.new("Animation")
	runAnimation.AnimationId = if r6 then "rbxassetid://74104654852598" else "rbxassetid://110191333474252"
	local crouchAnimation = Instance.new("Animation")
	crouchAnimation.AnimationId = if r6 then "rbxassetid://100285511964294" else "rbxassetid://134199951542913"
	local walkTrack = animator:LoadAnimation(walkAnimation)
	local runTrack = animator:LoadAnimation(runAnimation)
	local crouchTrack = animator:LoadAnimation(crouchAnimation)
	for _, track in ipairs({walkTrack, runTrack, crouchTrack}) do
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
	end
	local connection: RBXScriptConnection
	connection = RunService.Heartbeat:Connect(function()
		if player.Character ~= character or not character.Parent then
			connection:Disconnect()
			for _, track in ipairs({walkTrack, runTrack, crouchTrack}) do track:Stop(); track:Destroy() end
			walkAnimation:Destroy()
			runAnimation:Destroy()
			crouchAnimation:Destroy()
			return
		end
		local moving = humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0.01
			and humanoid.FloorMaterial ~= Enum.Material.Air and player:GetAttribute("FNABKDowned") ~= true
			and player:GetAttribute("FNABKEliminated") ~= true
		local crouching = player:GetAttribute("FNABKCrouching") == true
		local sprinting = moving and not crouching and humanoid.WalkSpeed > config.walkSpeed
		local crouchWalking = moving and crouching
		local walking = moving and not crouching and not sprinting
		if walking and not walkTrack.IsPlaying then walkTrack:Play(0.15)
		elseif not walking and walkTrack.IsPlaying then walkTrack:Stop(0.15) end
		if sprinting and not runTrack.IsPlaying then runTrack:Play(0.15)
		elseif not sprinting and runTrack.IsPlaying then runTrack:Stop(0.15) end
		if crouchWalking and not crouchTrack.IsPlaying then crouchTrack:Play(0.15)
		elseif not crouchWalking and crouchTrack.IsPlaying then crouchTrack:Stop(0.15) end
	end)
end

player.CharacterAdded:Connect(setup)
if player.Character then task.spawn(setup, player.Character) end
