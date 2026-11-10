--!strict
-- Visual response to server-confirmed baton actions and replicated health changes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local feedback = ReplicatedStorage:WaitForChild("FNABKRemotes"):WaitForChild("AttackFeedback") :: RemoteEvent
local tracks: { [string]: AnimationTrack } = {}
local connections: { RBXScriptConnection } = {}
local attackIndex, hitIndex = 0, 0

local function setup(character: Model)
	for _, connection in ipairs(connections) do connection:Disconnect() end
	table.clear(connections)
	for _, track in pairs(tracks) do track:Stop(); track:Destroy() end
	table.clear(tracks)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid or not humanoid:IsA("Humanoid") then return end
	local animator = humanoid:WaitForChild("Animator", 10)
	if not animator or not animator:IsA("Animator") or player.Character ~= character then return end
	local ids: { [string]: string } = if humanoid.RigType == Enum.HumanoidRigType.R6 then
		{attack1="128366585935025", attack2="76772591818471", hit1="98905496439577", hit2="95766708417439"}
		else {attack1="79233365540309", attack2="91071199232918", hit1="103237702294782", hit2="123815350770080"}
	if humanoid.RigType == Enum.HumanoidRigType.R15 then ids.death = "114004512189159" end
	for name, id in pairs(ids) do
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. id
		local track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action2
		track.Looped = false
		tracks[name] = track
	end
	local health = humanoid.Health
	table.insert(connections, humanoid.HealthChanged:Connect(function(value: number)
		if value < health and value > 0 and player:GetAttribute("FNABKDowned") ~= true
			and player:GetAttribute("FNABKEliminated") ~= true then
			hitIndex = hitIndex % 2 + 1
			tracks["hit" .. hitIndex]:Play(0.1)
		end
		health = value
	end))
	local function updateElimination()
		local track = tracks.death
		if not track then return end
		if player:GetAttribute("FNABKEliminated") ~= true then
			track:Stop(0.1)
			track:AdjustSpeed(1)
			return
		end
		track.Priority = Enum.AnimationPriority.Action3
		track:Play(0.1)
		task.spawn(function()
			local deadline = os.clock() + 5
			while player.Character == character and track.IsPlaying and track.Length == 0 and os.clock() < deadline do task.wait(0.05) end
			if player.Character ~= character or not track.IsPlaying or track.Length == 0 then return end
			task.wait(math.max(0, track.Length - track.TimePosition - 0.05))
			if player.Character == character and player:GetAttribute("FNABKEliminated") == true and track.IsPlaying then track:AdjustSpeed(0) end
		end)
	end
	table.insert(connections, player:GetAttributeChangedSignal("FNABKEliminated"):Connect(updateElimination))
	updateElimination()
end

feedback.OnClientEvent:Connect(function(code: string)
	if code ~= "Hit" and code ~= "FriendlyHit" and code ~= "Defeated" and code ~= "WrongfulHit" and code ~= "Miss"
		and code ~= "OutOfRange" and code ~= "Blocked" then return end
	attackIndex = attackIndex % 2 + 1
	local track = tracks["attack" .. attackIndex]
	if track then track:Play(0.1) end
end)
player.CharacterAdded:Connect(setup)
if player.Character then task.spawn(setup, player.Character) end
