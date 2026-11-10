--!strict
-- R6/R15 presentation only. Prompts and life-state changes remain server-authoritative.
local Players = game:GetService("Players")
local PromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer
local tracks: { [string]: AnimationTrack } = {}
local generation = 0

local function updateDowned()
	local track = tracks.downed
	if not track then return end
	generation += 1
	local current = generation
	if player:GetAttribute("FNABKDowned") == true then
		track:Play(0.1)
		task.spawn(function()
			local deadline = os.clock() + 5
			while generation == current and track.IsPlaying and track.Length == 0 and os.clock() < deadline do task.wait(0.05) end
			if generation ~= current or not track.IsPlaying or track.Length == 0 then return end
			task.wait(math.max(0, track.Length - track.TimePosition - 0.05))
			if generation == current and track.IsPlaying then track:AdjustSpeed(0) end
		end)
	else
		track:Stop(0.1)
		track:AdjustSpeed(1)
	end
end

local function setup(character: Model)
	generation += 1
	for _, track in pairs(tracks) do track:Stop(); track:Destroy() end
	table.clear(tracks)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid or not humanoid:IsA("Humanoid") then return end
	local animator = humanoid:WaitForChild("Animator", 10)
	if not animator or not animator:IsA("Animator") or player.Character ~= character then return end
	local ids = if humanoid.RigType == Enum.HumanoidRigType.R6 then
		{downed="139628663016328", revive="77790417165995", repair="134563506155808", interact="77606334002221"}
		else {downed="108382007838962", revive="139124305936265", repair="89838570560322", interact="72916861854495"}
	for name, id in pairs(ids) do
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. id
		local track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action3
		track.Looped = name == "revive"
		tracks[name] = track
	end
	updateDowned()
end

PromptService.PromptButtonHoldBegan:Connect(function(prompt: ProximityPrompt, who: Player)
	if who == player and prompt.Name == "FNABKRevivePrompt" and tracks.revive then tracks.revive:Play(0.1) end
end)
PromptService.PromptButtonHoldEnded:Connect(function(prompt: ProximityPrompt, who: Player)
	if who == player and prompt.Name == "FNABKRevivePrompt" and tracks.revive then tracks.revive:Stop(0.1) end
end)
PromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, who: Player)
	if who ~= player then return end
	if prompt.Name == "B4GeneratorPrompt" and tracks.repair then tracks.repair:Play(0.1)
	elseif (prompt.Name == "B4FusePrompt" or prompt.Name == "CrateInteractionPrompt" or prompt.Name == "GateHoldPrompt") and tracks.interact then
		tracks.interact:Play(0.1)
	end
end)
player:GetAttributeChangedSignal("FNABKDowned"):Connect(updateDowned)
player.CharacterAdded:Connect(setup)
if player.Character then task.spawn(setup, player.Character) end
