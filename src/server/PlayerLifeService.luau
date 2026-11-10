--!strict
-- AC-01/AC-08 player life slice: server-owned downed window and co-op revive.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local SessionLife = require(script.Parent:WaitForChild("SessionLife"))

type PlayerLifeConfig = {
	playerMaxHealth: number,
	walkSpeed: number,
	coOpDownedWindowSeconds: number,
	reviveHoldSeconds: number,
	reviveRangeStuds: number,
	reviveHealth: number,
}

type MovementSnapshot = {
	walkSpeed: number,
	jumpPower: number,
	jumpHeight: number,
	autoRotate: boolean,
}

type DownedRecord = {
	player: Player,
	character: Model,
	humanoid: Humanoid,
	root: BasePart,
	expiresAt: number,
	movement: MovementSnapshot,
	prompt: ProximityPrompt,
	statusLabel: TextLabel,
	holdStartedAt: { [Player]: number },
	holdEndedAt: { [Player]: number },
}

export type PlayerLifeController = {
	ApplyDamage: (Player, number, boolean?) -> number?,
	Snapshot: () -> any?,
}

local REMOTE_FOLDER_NAME = "FNABKRemotes"
local REVIVE_FEEDBACK_NAME = "ReviveFeedback"
local REVIVE_PROMPT_NAME = "FNABKRevivePrompt"
local DOWNED_GUI_NAME = "FNABKDownedStatus"
local HOLD_END_GRACE_SECONDS = 1

local PlayerLifeService = {}

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

local function getOrCreateRemote(parent: Folder, name: string): RemoteEvent
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

local function getCharacterParts(player: Player): (Model?, Humanoid?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return character, humanoid, nil
	end
	return character, humanoid, root
end

local function isIncapacitated(player: Player): boolean
	local character = player.Character
	return player:GetAttribute("FNABKDowned") == true
		or player:GetAttribute("FNABKEliminated") == true
		or (character ~= nil and (
			character:GetAttribute("FNABKDowned") == true
			or character:GetAttribute("FNABKEliminated") == true
		))
end

local function getActiveCharacter(player: Player): (Model?, Humanoid?, BasePart?)
	local character, humanoid, root = getCharacterParts(player)
	if isIncapacitated(player) then
		return character, humanoid, nil
	end
	return character, humanoid, root
end

local function setMovementLocked(humanoid: Humanoid, root: BasePart)
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function createDownedStatus(root: BasePart): TextLabel
	local previous = root:FindFirstChild(DOWNED_GUI_NAME)
	if previous then
		previous:Destroy()
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = DOWNED_GUI_NAME
	billboard.Adornee = root
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(190, 36)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.Parent = root

	local label = Instance.new("TextLabel")
	label.Name = "Status"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(43, 31, 26)
	label.BackgroundTransparency = 0.15
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.Text = "DOWNED"
	label.TextColor3 = Color3.fromRGB(255, 205, 130)
	label.TextScaled = true
	label.TextStrokeTransparency = 0.65
	label.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = label
	return label
end

local function createRevivePrompt(root: BasePart, target: Player, config: PlayerLifeConfig): ProximityPrompt
	local previous = root:FindFirstChild(REVIVE_PROMPT_NAME)
	if previous then
		previous:Destroy()
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = REVIVE_PROMPT_NAME
	prompt.ActionText = "Revive"
	prompt.ObjectText = target.DisplayName
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = config.reviveHoldSeconds
	prompt.MaxActivationDistance = config.reviveRangeStuds
	-- The prompt is attached at the character root, which can be hidden behind the
	-- target's own body from a third-person camera. Server raycasts still enforce LOS.
	prompt.RequiresLineOfSight = false
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	prompt.Enabled = true
	prompt.Parent = root
	return prompt
end

function PlayerLifeService.Start(config: PlayerLifeConfig, onRespawn: (Player, Vector3) -> (), isAboard: ((Player) -> boolean)?, savedLife: any?): PlayerLifeController
	-- ponytail: only living/eliminated records are supported; restore downed timers through the complete coordinator.
	local sessions = if savedLife == nil then SessionLife.new() else SessionLife.restore(savedLife)
	assert(sessions, "Invalid life snapshot")
	local roundState = ReplicatedStorage:WaitForChild("FNABKRoundState")
	local roundStatusInstance = roundState:WaitForChild("RoundStatus")
	assert(roundStatusInstance:IsA("StringValue"), "RoundStatus must be a StringValue")
	local roundStatus = roundStatusInstance :: StringValue

	local remotes = getOrCreateFolder(ReplicatedStorage, REMOTE_FOLDER_NAME)
	local feedback = getOrCreateRemote(remotes, REVIVE_FEEDBACK_NAME)
	local downedPlayers: { [Player]: DownedRecord } = {}
	local registeredPlayers: { [Player]: boolean } = {}
	local lostDownedState = false
	local restoredHealth: { [Player]: number } = {}
	local lastHealth: { [Player]: number } = {}

	local function respond(player: Player, code: string, detail: string?)
		feedback:FireClient(player, code, detail)
	end

	local function cancelReviveHolds(rescuer: Player)
		for _, record in pairs(downedPlayers) do
			if record.holdStartedAt[rescuer] then
				record.holdStartedAt[rescuer] = nil
				record.holdEndedAt[rescuer] = nil
				respond(rescuer, "ReviveCancelled", "Revive interrupted; hold again")
			end
		end
	end

	local function cleanupRecord(record: DownedRecord, preserveStatus: boolean?)
		record.holdStartedAt = {}
		record.holdEndedAt = {}
		record.prompt.Enabled = false
		if record.prompt.Parent then
			record.prompt:Destroy()
		end
		if not preserveStatus then
			local billboard = record.statusLabel.Parent
			if billboard and billboard:IsA("BillboardGui") then
				billboard:Destroy()
			end
		end
	end

	local function markEliminated(player: Player, reason: string, expectedRecord: DownedRecord?)
		local record = downedPlayers[player]
		if expectedRecord and record ~= expectedRecord then
			return
		end
		if record then
			downedPlayers[player] = nil
			cleanupRecord(record, true)
			record.statusLabel.Text = "ELIMINATED"
			record.statusLabel.BackgroundColor3 = Color3.fromRGB(55, 27, 31)
			record.statusLabel.TextColor3 = Color3.fromRGB(255, 145, 145)
		end

		player:SetAttribute("FNABKDowned", false)
		player:SetAttribute("FNABKEliminated", true)
		local character = record and record.character or player.Character
		if character then
			character:SetAttribute("FNABKDowned", false)
			character:SetAttribute("FNABKEliminated", true)
			local humanoid = record and record.humanoid or character:FindFirstChildOfClass("Humanoid")
			local root = record and record.root or character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid:IsA("Humanoid") and humanoid.Health > 0
				and root and root:IsA("BasePart")
			then
				if humanoid.Health ~= 1 then
					humanoid.Health = 1
				end
				setMovementLocked(humanoid, root)
			end
		end

		respond(player, "Eliminated", reason)
		print(string.format("[FNABK][Life] %s eliminated: %s", player.Name, reason))
	end

	local function respawn(player: Player, character: Model, humanoid: Humanoid, root: BasePart, record: DownedRecord?): boolean
		local remaining = player:GetAttribute("FNABKRespawns")
		if typeof(remaining) ~= "number" or remaining <= 0 then return false end
		onRespawn(player, root.Position)
		if record then downedPlayers[player] = nil; cleanupRecord(record) end
		player:SetAttribute("FNABKRespawns", remaining - 1)
		player:SetAttribute("FNABKDowned", false)
		player:SetAttribute("FNABKEliminated", false)
		character:SetAttribute("FNABKDowned", false)
		character:SetAttribute("FNABKEliminated", false)
		local base = roundState:FindFirstChild("ActiveBase")
		local points = Workspace:FindFirstChild("FNABKBaseClaimPoints")
		local point = base and base:IsA("StringValue") and points and points:FindFirstChild(base.Value)
		local fallback = Workspace:FindFirstChild("FNABKGraybox")
		local spawn = fallback and fallback:FindFirstChild("PlayerSpawn")
		local location = if point and point:IsA("BasePart") then point.Position elseif spawn and spawn:IsA("BasePart") then spawn.Position else root.Position
		character:PivotTo(CFrame.new(location + Vector3.new(0, 4, 0)))
		humanoid.Health = humanoid.MaxHealth
		humanoid.JumpPower = if record then record.movement.jumpPower else 50
		humanoid.JumpHeight = if record then record.movement.jumpHeight else 7.2
		humanoid.AutoRotate = true
		player:SetAttribute("FNABKImmuneUntil", os.clock() + 5)
		respond(player, "YouWereRevived", "Respawned at base")
		return true
	end

	local function hasLineOfSight(rescuerCharacter: Model, rescuerRoot: BasePart, targetCharacter: Model, targetRoot: BasePart): boolean
		local origin = rescuerRoot.Position + Vector3.new(0, 1.5, 0)
		local destination = targetRoot.Position + Vector3.new(0, 1, 0)
		local direction = destination - origin
		if direction.Magnitude <= 0.05 then
			return true
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { rescuerCharacter }
		raycastParams.IgnoreWater = true
		local result = Workspace:Raycast(origin, direction, raycastParams)
		return result ~= nil and result.Instance:IsDescendantOf(targetCharacter)
	end

	local function validateRevive(rescuer: Player, record: DownedRecord): (boolean, string?)
		if roundStatus.Value ~= "Running" then
			return false, "The round is not active"
		end
		if downedPlayers[record.player] ~= record or record.player:GetAttribute("FNABKDowned") ~= true then
			return false, "That player is no longer downed"
		end
		if os.clock() >= record.expiresAt then
			return false, "The revive window has expired"
		end
		if rescuer == record.player then
			return false, "A teammate must revive you"
		end

		local rescuerCharacter, _, rescuerRoot = getActiveCharacter(rescuer)
		if not rescuerCharacter or not rescuerRoot then
			return false, "You must be standing to revive a teammate"
		end
		if (rescuerRoot.Position - record.root.Position).Magnitude > config.reviveRangeStuds then
			return false, "Move closer to the downed player"
		end
		if not hasLineOfSight(rescuerCharacter, rescuerRoot, record.character, record.root) then
			return false, "The downed player is blocked from view"
		end
		return true, nil
	end

	local function completeRevive(rescuer: Player, record: DownedRecord)
		if downedPlayers[record.player] ~= record then
			return
		end
		downedPlayers[record.player] = nil
		cleanupRecord(record)

		local target = record.player
		local character = record.character
		local humanoid = record.humanoid
		local root = record.root
		target:SetAttribute("FNABKDowned", false)
		target:SetAttribute("FNABKEliminated", false)
		character:SetAttribute("FNABKDowned", false)
		character:SetAttribute("FNABKEliminated", false)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		-- MovementService restores speed from the current inputs and crate state.
		humanoid.JumpPower = record.movement.jumpPower
		humanoid.JumpHeight = record.movement.jumpHeight
		humanoid.AutoRotate = record.movement.autoRotate
		humanoid.Health = math.min(config.reviveHealth, humanoid.MaxHealth)

		local displayName = target.DisplayName
		respond(rescuer, "ReviveSuccess", string.format("%s is back with %d HP", displayName, config.reviveHealth))
		respond(target, "YouWereRevived", string.format("Your teammate restored you to %d HP", config.reviveHealth))
		print(string.format("[FNABK][Life] %s revived %s at %.0f HP", rescuer.Name, target.Name, humanoid.Health))
	end

	local function beginDownedWindow(player: Player, character: Model, humanoid: Humanoid, root: BasePart)
		local now = os.clock()
		local statusLabel = createDownedStatus(root)
		local prompt = createRevivePrompt(root, player, config)
		local record: DownedRecord = {
			player = player,
			character = character,
			humanoid = humanoid,
			root = root,
			expiresAt = now + config.coOpDownedWindowSeconds,
			movement = {
				walkSpeed = humanoid.WalkSpeed,
				jumpPower = humanoid.JumpPower,
				jumpHeight = humanoid.JumpHeight,
				autoRotate = humanoid.AutoRotate,
			},
			prompt = prompt,
			statusLabel = statusLabel,
			holdStartedAt = {},
			holdEndedAt = {},
		}
		downedPlayers[player] = record
		player:SetAttribute("FNABKDowned", true)
		player:SetAttribute("FNABKEliminated", false)
		character:SetAttribute("FNABKDowned", true)
		character:SetAttribute("FNABKEliminated", false)
		humanoid.Health = 1
		setMovementLocked(humanoid, root)
		respond(player, "Downed", string.format("A teammate has %d seconds to revive you", config.coOpDownedWindowSeconds))
		print(string.format("[FNABK][Life] %s downed; revive window=%ds", player.Name, config.coOpDownedWindowSeconds))

		prompt.PromptButtonHoldBegan:Connect(function(rescuer: Player)
			record.holdStartedAt[rescuer] = nil
			record.holdEndedAt[rescuer] = nil
			local valid, detail = validateRevive(rescuer, record)
			if not valid then
				respond(rescuer, "ReviveRejected", detail)
				return
			end
			record.holdStartedAt[rescuer] = os.clock()
			local startedAt = record.holdStartedAt[rescuer]
			task.spawn(function()
				while downedPlayers[player] == record and record.holdStartedAt[rescuer] == startedAt do
					local valid = validateRevive(rescuer, record)
					if not valid then
						record.holdStartedAt[rescuer] = nil
						record.holdEndedAt[rescuer] = nil
						respond(rescuer, "ReviveCancelled", "Revive interrupted; hold again")
						break
					end
					task.wait(0.1)
				end
			end)
		end)

		prompt.PromptButtonHoldEnded:Connect(function(rescuer: Player)
			local startedAt = record.holdStartedAt[rescuer]
			if not startedAt then
				return
			end
			local endedAt = os.clock()
			if endedAt - startedAt < config.reviveHoldSeconds then
				record.holdStartedAt[rescuer] = nil
				record.holdEndedAt[rescuer] = nil
				respond(rescuer, "ReviveCancelled", string.format("Keep holding E for %d seconds", config.reviveHoldSeconds))
			else
				record.holdEndedAt[rescuer] = endedAt
			end
		end)

		prompt.Triggered:Connect(function(rescuer: Player)
			local startedAt = record.holdStartedAt[rescuer]
			local nowAt = os.clock()
			if not startedAt or nowAt - startedAt < config.reviveHoldSeconds then
				record.holdStartedAt[rescuer] = nil
				record.holdEndedAt[rescuer] = nil
				respond(rescuer, "ReviveRejected", string.format("Hold E for %d seconds to revive", config.reviveHoldSeconds))
				return
			end
			local endedAt = record.holdEndedAt[rescuer]
			if endedAt and nowAt - endedAt > HOLD_END_GRACE_SECONDS then
				record.holdStartedAt[rescuer] = nil
				record.holdEndedAt[rescuer] = nil
				respond(rescuer, "ReviveRejected", "The hold expired; try again")
				return
			end

			local valid, detail = validateRevive(rescuer, record)
			record.holdStartedAt[rescuer] = nil
			record.holdEndedAt[rescuer] = nil
			if not valid then
				respond(rescuer, "ReviveRejected", detail)
				return
			end
			completeRevive(rescuer, record)
		end)

		task.spawn(function()
			while downedPlayers[player] == record and roundStatus.Value == "Running" do
				local remaining = math.max(0, math.ceil(record.expiresAt - os.clock()))
				statusLabel.Text = string.format("DOWNED | %ds", remaining)
				if remaining <= 0 then
					break
				end
				task.wait(1)
			end
		end)

		task.delay(config.coOpDownedWindowSeconds, function()
			if downedPlayers[player] == record and roundStatus.Value == "Running" then
				if not respawn(player, character, humanoid, root, record) then markEliminated(player, "The revive window expired", record) end
			end
		end)
	end

	local function applyDamage(player: Player, amount: number, attacked: boolean?): number?
		if roundStatus.Value ~= "Running" or type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount >= math.huge or isIncapacitated(player) then
			return nil
		end

		local character, humanoid, root = getActiveCharacter(player)
		if not character or not humanoid or not root then
			return nil
		end
		if (if isAboard then isAboard(player) else player:GetAttribute("FNABKAboard") == true) then return humanoid.Health end
		local immuneUntil = player:GetAttribute("FNABKImmuneUntil")
		if typeof(immuneUntil) == "number" and os.clock() < immuneUntil then return humanoid.Health end
		if attacked ~= false then cancelReviveHolds(player) end
		if character:FindFirstChildOfClass("ForceField") then
			return humanoid.Health
		end

		if humanoid.Health > amount then
			humanoid:TakeDamage(amount)
			return humanoid.Health
		end

		if #Players:GetPlayers() > 1 then
			beginDownedWindow(player, character, humanoid, root)
		elseif not respawn(player, character, humanoid, root, nil) then
			player:SetAttribute("FNABKDowned", false)
			player:SetAttribute("FNABKEliminated", true)
			character:SetAttribute("FNABKDowned", false)
			character:SetAttribute("FNABKEliminated", true)
			humanoid.Health = 1
			setMovementLocked(humanoid, root)
			respond(player, "Eliminated", "No teammate is available to revive you")
			print(string.format("[FNABK][Life] %s eliminated; no active teammate could revive", player.Name))
		end
		return humanoid.Health
	end

	local function watchCharacter(player: Player, character: Model)
		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid", 10)
			local root = character:WaitForChild("HumanoidRootPart", 10)
			if not humanoid or not humanoid:IsA("Humanoid") or not root or not root:IsA("BasePart") then
				return
			end

			humanoid.MaxHealth = config.playerMaxHealth
			lastHealth[player] = humanoid.Health
			-- Roblox's default character health regeneration can otherwise make a
			-- downed/eliminated player look alive while movement remains locked.
			humanoid.HealthChanged:Connect(function(health: number)
				if player.Character == character then lastHealth[player] = math.clamp(health, 0, 100) end
				if health > 1 and isIncapacitated(player) and player.Character == character then
					humanoid.Health = 1
				end
			end)
			if player:GetAttribute("FNABKDowned") == true then
				local record = downedPlayers[player]
				if not record or record.character ~= character then
					markEliminated(player, "Character reset while downed", record)
				end
			end

			local eliminated = player:GetAttribute("FNABKEliminated") == true
			local downed = player:GetAttribute("FNABKDowned") == true
			character:SetAttribute("FNABKDowned", downed)
			character:SetAttribute("FNABKEliminated", eliminated)
			if downed or eliminated then
				humanoid.Health = 1
				setMovementLocked(humanoid, root)
			else
				if restoredHealth[player] then
					local base = roundState:FindFirstChild("ActiveBase")
					local points = Workspace:FindFirstChild("FNABKBaseClaimPoints")
					local point = base and base:IsA("StringValue") and points and points:FindFirstChild(base.Value)
					local map = Workspace:FindFirstChild("FNABKGraybox")
					local spawn = map and map:FindFirstChild("PlayerSpawn")
					local destination = if point and point:IsA("BasePart") then point elseif spawn and spawn:IsA("BasePart") then spawn else nil
					if destination then character:PivotTo(CFrame.new(destination.Position + Vector3.new(0, 4, 0))) end
				end
				humanoid.Health = math.clamp(restoredHealth[player] or humanoid.MaxHealth, 1, humanoid.MaxHealth)
				restoredHealth[player] = nil
			end

			humanoid.Died:Connect(function()
				local record = downedPlayers[player]
				if record and record.character == character then
					markEliminated(player, "Downed character died", record)
				else
					player:SetAttribute("FNABKDowned", false)
					player:SetAttribute("FNABKEliminated", true)
					character:SetAttribute("FNABKDowned", false)
					character:SetAttribute("FNABKEliminated", true)
				end
			end)
		end)
	end

	local function registerPlayer(player: Player)
		if registeredPlayers[player] then
			return
		end
		registeredPlayers[player] = true
		local saved = sessions.get(player.UserId)
		player:SetAttribute("FNABKRespawns", if saved then saved.respawns else 3)
		player:SetAttribute("FNABKDowned", false)
		player:SetAttribute("FNABKEliminated", if saved then saved.eliminated else false)
		if saved and not saved.eliminated then restoredHealth[player] = saved.health end
		player.CharacterAdded:Connect(function(character: Model)
			watchCharacter(player, character)
		end)
		if player.Character then
			watchCharacter(player, player.Character)
		end
	end

	Players.PlayerAdded:Connect(registerPlayer)
	Players.PlayerRemoving:Connect(function(player: Player)
		registeredPlayers[player] = nil
		local character = player.Character
		if player:GetAttribute("FNABKDowned") == true or (character and character:GetAttribute("FNABKDowned") == true) then
			lostDownedState = true
		end
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local lives = player:GetAttribute("FNABKRespawns")
		-- ponytail: offline downed/revive timers are not retained; replace with a persistent downed record.
		sessions.save(player.UserId, if typeof(lives) == "number" then lives else 3,
			if humanoid then math.clamp(humanoid.Health, 0, 100) else (lastHealth[player] or 100),
			player:GetAttribute("FNABKEliminated") == true)
		restoredHealth[player] = nil
		lastHealth[player] = nil
		local record = downedPlayers[player]
		if record then
			downedPlayers[player] = nil
			cleanupRecord(record)
		end
		for _, otherRecord in pairs(downedPlayers) do
			otherRecord.holdStartedAt[player] = nil
			otherRecord.holdEndedAt[player] = nil
		end
	end)

	roundStatus.Changed:Connect(function()
		if roundStatus.Value == "Running" then
			return
		end
		for _, record in pairs(downedPlayers) do
			record.prompt.Enabled = false
			record.holdStartedAt = {}
			record.holdEndedAt = {}
		end
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		registerPlayer(player)
	end

	print(string.format(
		"[FNABK][Life] AC-01/AC-08 revive ready; downed=%ds, hold=%.1fs, range=%.1f, HP=%d",
		config.coOpDownedWindowSeconds,
		config.reviveHoldSeconds,
		config.reviveRangeStuds,
		config.reviveHealth
	))
	local function snapshot()
		if lostDownedState then return nil end
		local copy = SessionLife.restore(sessions.snapshot())
		if not copy then return nil end
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local lives = player:GetAttribute("FNABKRespawns")
			local eliminated = player:GetAttribute("FNABKEliminated")
			-- ponytail: downed timers are not serialized; reject until the full life-state save exists.
			if player:GetAttribute("FNABKDowned") == true or (character and character:GetAttribute("FNABKDowned") == true)
				or not humanoid or typeof(lives) ~= "number" or type(eliminated) ~= "boolean" then return nil end
			if not pcall(copy.save, player.UserId, lives, math.clamp(humanoid.Health, 0, 100), eliminated) then return nil end
		end
		return copy.snapshot()
	end
	return table.freeze({ ApplyDamage = applyDamage, Snapshot = snapshot })
end

return table.freeze(PlayerLifeService)
