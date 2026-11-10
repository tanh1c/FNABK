--!strict
-- AC-08 endgame slice: shared round clock, server-validated Gate 1 hold and exit result.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SurvivalClock = require(script.Parent:WaitForChild("SurvivalClock"))
local ClockSnapshot = require(script.Parent:WaitForChild("ClockSnapshot"))

type RoundConfig = {
	roundDurationSeconds: number,
	gateHoldSeconds: number,
	gateInteractionRangeStuds: number,
}

local REMOTE_FOLDER_NAME = "FNABKRemotes"
local GATE_FEEDBACK_NAME = "GateFeedback"
local GATE_PROMPT_NAME = "GateHoldPrompt"
local HOLD_END_GRACE_SECONDS = 1
-- The server may receive hold-start after the client has begun its prompt timer.
-- Keep the server's full five-second minimum while allowing normal event timing.
local PROMPT_NETWORK_BUFFER_SECONDS = 0.25
local ROUND_POLL_SECONDS = 0.1

local RoundService = {}

local function getOrCreateFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("Folder"), name .. " must be a Folder")
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function getOrCreateBoolValue(parent: Instance, name: string, initialValue: boolean): BoolValue
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("BoolValue"), name .. " must be a BoolValue")
		return existing
	end

	local value = Instance.new("BoolValue")
	value.Name = name
	value.Value = initialValue
	value.Parent = parent
	return value
end

local function getOrCreateIntValue(parent: Instance, name: string, initialValue: number): IntValue
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("IntValue"), name .. " must be an IntValue")
		return existing
	end

	local value = Instance.new("IntValue")
	value.Name = name
	value.Value = initialValue
	value.Parent = parent
	return value
end

local function getOrCreateStringValue(parent: Instance, name: string, initialValue: string): StringValue
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("StringValue"), name .. " must be a StringValue")
		return existing
	end

	local value = Instance.new("StringValue")
	value.Name = name
	value.Value = initialValue
	value.Parent = parent
	return value
end

local function makeRemote(parent: Folder, name: string): RemoteEvent
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("RemoteEvent"), name .. " must be a RemoteEvent")
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = parent
	return remote
end

local function getOrCreateGatePrompt(panel: BasePart, holdSeconds: number, range: number): ProximityPrompt
	local existing = panel:FindFirstChild(GATE_PROMPT_NAME)
	if existing then
		assert(existing:IsA("ProximityPrompt"), GATE_PROMPT_NAME .. " must be a ProximityPrompt")
	else
		existing = Instance.new("ProximityPrompt")
		existing.Name = GATE_PROMPT_NAME
		existing.Parent = panel
	end

	local prompt = existing :: ProximityPrompt
	prompt.ActionText = "Locked"
	prompt.ObjectText = "Gate 1"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = holdSeconds + PROMPT_NETWORK_BUFFER_SECONDS
	prompt.MaxActivationDistance = range
	prompt.RequiresLineOfSight = true
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	return prompt
end

local function getAliveCharacter(player: Player): (Model?, Humanoid?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end
	if player:GetAttribute("FNABKDowned") == true
		or player:GetAttribute("FNABKEliminated") == true
		or character:GetAttribute("FNABKDowned") == true
		or character:GetAttribute("FNABKEliminated") == true
	then
		return character, character:FindFirstChildOfClass("Humanoid"), nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return character, humanoid, nil
	end
	return character, humanoid, root
end

local function hasLineOfSight(character: Model, root: BasePart, target: BasePart): boolean
	local origin = root.Position + Vector3.new(0, 1.5, 0)
	local direction = target.Position - origin
	if direction.Magnitude <= 0.05 then
		return true
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = true

	local result = Workspace:Raycast(origin, direction, raycastParams)
	return result ~= nil and result.Instance == target
end

local function isInsideZone(zone: BasePart, position: Vector3): boolean
	local localPosition = zone.CFrame:PointToObjectSpace(position)
	local halfSize = zone.Size / 2
	return math.abs(localPosition.X) <= halfSize.X
		and math.abs(localPosition.Y) <= halfSize.Y
		and math.abs(localPosition.Z) <= halfSize.Z
end

function RoundService.Start(map: Folder, config: RoundConfig, waveEvents: BindableEvent, savedClock: any?)
	if map:GetAttribute("RoundServiceStarted") == true then
		return
	end
	local clock = if savedClock == nil then SurvivalClock.new() else ClockSnapshot.restore(savedClock)
	assert(clock, "Invalid or unsupported clock snapshot")
	map:SetAttribute("RoundServiceStarted", true)

	local gate = map:FindFirstChild("Gate1")
	assert(gate and gate:IsA("Folder"), "Graybox is missing Gate1")
	local doorInstance = gate:FindFirstChild("GateDoor")
	local panelInstance = gate:FindFirstChild("ControlPanel")
	local exitZoneInstance = gate:FindFirstChild("ExitZone")
	assert(doorInstance and doorInstance:IsA("BasePart"), "Gate1 is missing GateDoor")
	assert(panelInstance and panelInstance:IsA("BasePart"), "Gate1 is missing ControlPanel")
	assert(exitZoneInstance and exitZoneInstance:IsA("BasePart"), "Gate1 is missing ExitZone")
	local door = doorInstance :: BasePart
	local panel = panelInstance :: BasePart
	local exitZone = exitZoneInstance :: BasePart

	local roundState = getOrCreateFolder(ReplicatedStorage, "FNABKRoundState")
	local dataKeys = roundState:WaitForChild("DataKeys")
	assert(dataKeys:IsA("Folder"), "DataKeys must be a Folder")
	local keyOneInstance = dataKeys:WaitForChild("Key1")
	local keyTwoInstance = dataKeys:WaitForChild("Key2")
	local keyThreeInstance = dataKeys:WaitForChild("Key3")
	assert(keyOneInstance:IsA("BoolValue"), "Key1 must be a BoolValue")
	assert(keyTwoInstance:IsA("BoolValue"), "Key2 must be a BoolValue")
	assert(keyThreeInstance:IsA("BoolValue"), "Key3 must be a BoolValue")
	local keys = { keyOneInstance :: BoolValue, keyTwoInstance :: BoolValue, keyThreeInstance :: BoolValue }
	local roundStatus = getOrCreateStringValue(roundState, "RoundStatus", "Waiting")
	local timeRemaining = getOrCreateIntValue(roundState, "RoundTimeRemaining", config.roundDurationSeconds)
	local survivalDay = getOrCreateIntValue(roundState, "SurvivalDay", 1)
	local survivalPhase = getOrCreateStringValue(roundState, "SurvivalPhase", "Day")
	local lossReason = getOrCreateStringValue(roundState, "RoundLossReason", "")
	local gateOpened = getOrCreateBoolValue(roundState, "GateOpened", false)
	local feedback = makeRemote(getOrCreateFolder(ReplicatedStorage, REMOTE_FOLDER_NAME), GATE_FEEDBACK_NAME)
	local prompt = getOrCreateGatePrompt(panel, config.gateHoldSeconds, config.gateInteractionRangeStuds)
	local holdStartedAt: { [Player]: number } = {}
	local holdEndedAt: { [Player]: number } = {}
	local lastTick: number? = nil

	-- ponytail: the coordinator must restore all world state before a saved clock is enabled.
	roundStatus.Value = "Waiting"
	timeRemaining.Value = math.ceil(clock.remaining)
	survivalDay.Value = clock.day
	survivalPhase.Value = clock.phase
	Lighting.ClockTime = SurvivalClock.lightingTime(clock)
	lossReason.Value = ""
	gateOpened.Value = false

	local function allKeysCollected(): boolean
		return keys[1].Value and keys[2].Value and keys[3].Value
	end

	local function respond(player: Player, code: string, detail: string?)
		feedback:FireClient(player, code, detail)
	end

	local function refreshGate()
		local isTerminal = roundStatus.Value == "Won" or roundStatus.Value == "Lost"
		-- ponytail: A01 gate remains scenery until rescue objectives replace it.
		prompt.Enabled = false
		prompt.ActionText = if allKeysCollected() then "Open Gate" else "Locked"
		door.CanCollide = not gateOpened.Value
		door.CanQuery = not gateOpened.Value
		door.Transparency = if gateOpened.Value then 1 else 0
		panel.Color = if gateOpened.Value then Color3.fromRGB(29, 144, 127) else Color3.fromRGB(184, 78, 65)
		gate:SetAttribute("Opened", gateOpened.Value)
		map:SetAttribute("GateOpened", gateOpened.Value)
		if isTerminal then
			prompt.Enabled = false
		end
	end

	local function finishRound(result: "Won" | "Lost", reason: string)
		if roundStatus.Value ~= "Running" then
			return
		end
		roundStatus.Value = result
		lossReason.Value = if result == "Lost" then reason else ""
		holdStartedAt = {}
		holdEndedAt = {}
		refreshGate()
		if result == "Won" then
			feedback:FireAllClients("RoundWon", "The rescue helicopter departed")
			print("[FNABK][Round] At least one player was rescued")
		else
			local message = if reason == "Timeout" then "The signal deadline expired" elseif reason == "NoOneBoarded" then "No one boarded the helicopter" else "The whole team is down"
			feedback:FireAllClients("RoundLost", message)
			print(string.format("[FNABK][Round] Lost: %s", reason))
		end
	end

	local function validateGateInteraction(player: Player): (boolean, string?)
		if not prompt.Enabled then return false, "Rescue objectives are not available yet" end
		if roundStatus.Value ~= "Running" then
			return false, "Round is not active"
		end
		if not allKeysCollected() then
			return false, "Collect all three Data Keys first"
		end
		local character, _, root = getAliveCharacter(player)
		if not character or not root then
			return false, "Player is not alive"
		end
		if (root.Position - panel.Position).Magnitude > config.gateInteractionRangeStuds then
			return false, "Move closer to the Gate panel"
		end
		if not hasLineOfSight(character, root, panel) then
			return false, "The Gate panel is blocked"
		end
		return true, nil
	end

	local function beginRound()
		if roundStatus.Value ~= "Waiting" then
			return
		end
		roundStatus.Value = "Running"
		lastTick = os.clock()
		timeRemaining.Value = math.ceil(clock.remaining)
		refreshGate()
		print("[FNABK][Round] Started survival day 1")
	end

	local function hasActiveOrLoadingPlayer(): boolean
		for _, player in ipairs(Players:GetPlayers()) do
			if player:GetAttribute("FNABKDowned") == true and (player:GetAttribute("FNABKRespawns") or 0) > 0 then return true end
			if player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true then
				continue
			end
			local character = player.Character
			if not character then
				-- A joining or respawning teammate may still be able to act.
				return true
			end
			if character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true then
				continue
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health > 0 then
				return true
			end
		end
		return false
	end

	local function watchCharacter(player: Player, character: Model)
		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid", 10)
			if not humanoid or not humanoid:IsA("Humanoid") then
				return
			end
			humanoid.Died:Connect(function()
				task.delay(0.15, function()
					if roundStatus.Value == "Running" and #Players:GetPlayers() > 0 and not hasActiveOrLoadingPlayer() then
						finishRound("Lost", "TeamDowned")
					end
				end)
			end)
		end)
	end

	local registeredPlayers: { [Player]: boolean } = {}
	local function checkPlayerLifeState()
		task.defer(function()
			if roundStatus.Value == "Running" and #Players:GetPlayers() > 0 and not hasActiveOrLoadingPlayer() then
				finishRound("Lost", "TeamDowned")
			end
		end)
	end

	local function registerPlayer(player: Player)
		if registeredPlayers[player] then
			return
		end
		registeredPlayers[player] = true
		player:GetAttributeChangedSignal("FNABKDowned"):Connect(checkPlayerLifeState)
		player:GetAttributeChangedSignal("FNABKEliminated"):Connect(checkPlayerLifeState)
		player:GetAttributeChangedSignal("FNABKRespawns"):Connect(checkPlayerLifeState)
		player.CharacterAdded:Connect(function(character: Model)
			watchCharacter(player, character)
			beginRound()
		end)
		if player.Character then
			watchCharacter(player, player.Character)
		end
		beginRound()
	end

	Players.PlayerAdded:Connect(registerPlayer)
	Players.PlayerRemoving:Connect(function(player: Player)
		registeredPlayers[player] = nil
		holdStartedAt[player] = nil
		holdEndedAt[player] = nil
		task.defer(function()
			if roundStatus.Value == "Running" and #Players:GetPlayers() > 0 and not hasActiveOrLoadingPlayer() then
				finishRound("Lost", "TeamDowned")
			end
		end)
	end)

	prompt.PromptButtonHoldBegan:Connect(function(player: Player)
		holdStartedAt[player] = nil
		holdEndedAt[player] = nil
		if gateOpened.Value then
			return
		end
		local valid, detail = validateGateInteraction(player)
		if not valid then
			respond(player, if allKeysCollected() then "GateRejected" else "GateLocked", detail)
			return
		end
		-- Hold input events are client-originated. This timestamp and final server checks
		-- prevent a zero-duration Triggered request from opening the Gate.
		holdStartedAt[player] = os.clock()
	end)

	prompt.PromptButtonHoldEnded:Connect(function(player: Player)
		local startedAt = holdStartedAt[player]
		if not startedAt then
			return
		end
		local endedAt = os.clock()
		if endedAt - startedAt < config.gateHoldSeconds then
			holdStartedAt[player] = nil
			holdEndedAt[player] = nil
			respond(player, "GateHoldCancelled", "Keep holding E for five seconds")
		else
			-- Some clients report hold-end just before Triggered; allow a short event-order grace.
			holdEndedAt[player] = endedAt
		end
	end)

	prompt.Triggered:Connect(function(player: Player)
		if gateOpened.Value then
			return
		end
		local startedAt = holdStartedAt[player]
		local now = os.clock()
		if not startedAt or now - startedAt < config.gateHoldSeconds then
			holdStartedAt[player] = nil
			holdEndedAt[player] = nil
			local detail = if not allKeysCollected()
				then "Collect all three Data Keys first"
				else "Hold E at the panel for five seconds"
			respond(player, if allKeysCollected() then "GateRejected" else "GateLocked", detail)
			return
		end
		local releasedAt = holdEndedAt[player]
		if releasedAt and now - releasedAt > HOLD_END_GRACE_SECONDS then
			holdStartedAt[player] = nil
			holdEndedAt[player] = nil
			respond(player, "GateRejected", "The hold expired; try again")
			return
		end

		local valid, detail = validateGateInteraction(player)
		holdStartedAt[player] = nil
		holdEndedAt[player] = nil
		if not valid then
			respond(player, if allKeysCollected() then "GateRejected" else "GateLocked", detail)
			return
		end

		gateOpened.Value = true
		refreshGate()
		respond(player, "GateOpened", "Enter the exit beyond the Gate")
		print(string.format("[FNABK][Gate] %s held the control panel for %.1f seconds; Gate 1 opened", player.Name, now - startedAt))
	end)

	for _, key in ipairs(keys) do
		key.Changed:Connect(refreshGate)
	end
	gateOpened.Changed:Connect(refreshGate)
	roundStatus.Changed:Connect(refreshGate)
	for _, player in ipairs(Players:GetPlayers()) do
		registerPlayer(player)
	end
	refreshGate()

	task.spawn(function()
		while map.Parent do
			if roundStatus.Value == "Running" then
				local now = os.clock()
				local events = SurvivalClock.advance(clock, if lastTick then now - lastTick else 0)
				lastTick = now
				survivalDay.Value, survivalPhase.Value = clock.day, clock.phase
				timeRemaining.Value = math.max(0, math.ceil(clock.remaining))
				Lighting.ClockTime = SurvivalClock.lightingTime(clock)
				for _, event in ipairs(events) do
					waveEvents:Fire(event)
					if event == "SignalDeadlineExpired" then finishRound("Lost", "Timeout") end
				end
			else
				lastTick = nil
			end
			task.wait(ROUND_POLL_SECONDS)
		end
	end)

	print("[FNABK][Round] Survival clock active; rescue objectives and waves are not connected")
	return function(): boolean
		return roundStatus.Value == "Running" and SurvivalClock.signal(clock)
	end, function(rescued: boolean)
		if roundStatus.Value ~= "Running" then return end
		clock.phase, clock.remaining = "Departed", 0
		finishRound(if rescued then "Won" else "Lost", if rescued then "Rescued" else "NoOneBoarded")
		timeRemaining.Value, survivalPhase.Value = 0, "Departed"
	end, function()
		return ClockSnapshot.capture(clock)
	end
end

return table.freeze(RoundService)
