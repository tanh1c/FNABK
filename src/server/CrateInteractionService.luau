--!strict
-- AC-06 / CR-001: pick up and place the FuseCrate, with slower body-contact pushing.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

type InteractionConfig = {
	cratePushRangeStuds: number,
	cratePushWalkSpeed: number,
	crateCarryWalkSpeed: number,
}

type ContactState = {
	humanoid: Humanoid,
	parts: { [BasePart]: boolean },
	isSlowed: boolean,
	runningConnection: RBXScriptConnection?,
}

local PROMPT_NAME = "CrateInteractionPrompt"
local CARRY_WELD_NAME = "CrateCarryWeld"
local BODY_PUSH_OWNER_EXTRA_DISTANCE = 2
local MAX_CRATE_SPEED = 8
local MAX_CRATE_ANGULAR_SPEED = 3
local PHYSICS_CHECK_INTERVAL = 0.1
-- Leave a small gap between the box and character so dropping it does not
-- immediately re-trigger the slower body-push movement state.
local CARRY_OFFSET = CFrame.new(0, -0.25, -3.6)

local CrateInteractionService = {}

local function getAliveCharacter(player: Player): (Model?, Humanoid?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true
		or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
		or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
	then
		return character, humanoid, nil
	end

	return character, humanoid, root
end

local function canReachCrate(character: Model, root: BasePart, crate: BasePart, maxDistance: number): boolean
	if (root.Position - crate.Position).Magnitude > maxDistance then
		return false
	end

	local origin = root.Position + Vector3.new(0, 0.5, 0)
	local direction = crate.Position - origin
	if direction.Magnitude <= 0.05 then
		return true
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = true

	local result = Workspace:Raycast(origin, direction, raycastParams)
	return result == nil or result.Instance == crate
end

local function getOrCreatePrompt(crate: BasePart, maxDistance: number): ProximityPrompt
	local existing = crate:FindFirstChild(PROMPT_NAME)
	if existing then
		assert(existing:IsA("ProximityPrompt"), PROMPT_NAME .. " must be a ProximityPrompt")
	else
		existing = Instance.new("ProximityPrompt")
		existing.Name = PROMPT_NAME
		existing.Parent = crate
	end

	local prompt = existing :: ProximityPrompt
	prompt.ActionText = "Pick Up"
	prompt.ObjectText = "Fuse Crate"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = maxDistance
	prompt.RequiresLineOfSight = true
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	return prompt
end

function CrateInteractionService.Start(map: Folder, config: InteractionConfig)
	if map:GetAttribute("CrateInteractionStarted") == true then
		return
	end
	map:SetAttribute("CrateInteractionStarted", true)

	local a3 = map:FindFirstChild("A3")
	assert(a3 and a3:IsA("Folder"), "Graybox is missing A3")
	local crateInstance = a3:FindFirstChild("FuseCrate")
	assert(crateInstance and crateInstance:IsA("BasePart"), "A3 is missing its FuseCrate")
	local crate = crateInstance :: BasePart
	local prompt = getOrCreatePrompt(crate, config.cratePushRangeStuds)

	local contactStates: { [Player]: ContactState } = {}
	local activeBodyPushOwner: Player? = nil
	local activeCarrier: Player? = nil
	local carrierHumanoid: Humanoid? = nil
	local carryWeld: WeldConstraint? = nil
	local deathConnection: RBXScriptConnection? = nil
	local carryGeneration = 0

	local function setAutomaticNetworkOwnership()
		if not crate.Parent or crate.Anchored then
			return
		end
		pcall(function()
			crate:SetNetworkOwnershipAuto()
		end)
	end

	local function restorePlayerWalkSpeed(state: ContactState)
		local character = state.humanoid.Parent
		if character and character:IsA("Model") then
			character:SetAttribute("FNABKCratePushing", false)
		end
		state.isSlowed = false
	end

	local function clearContactState(player: Player)
		local state = contactStates[player]
		if not state then
			return
		end
		contactStates[player] = nil
		restorePlayerWalkSpeed(state)
		if state.runningConnection then
			state.runningConnection:Disconnect()
			state.runningConnection = nil
		end

		if activeBodyPushOwner == player then
			activeBodyPushOwner = nil
			setAutomaticNetworkOwnership()
		end
	end

	local function isPushingIntoCrate(player: Player, state: ContactState): boolean
		if activeCarrier == player or next(state.parts) == nil then
			return false
		end

		local _, humanoid, root = getAliveCharacter(player)
		if humanoid ~= state.humanoid or not root then
			return false
		end

		local moveDirection = humanoid.MoveDirection
		local toCrate = crate.Position - root.Position
		local horizontalMove = Vector3.new(moveDirection.X, 0, moveDirection.Z)
		local horizontalToCrate = Vector3.new(toCrate.X, 0, toCrate.Z)
		if horizontalMove.Magnitude <= 0.05 or horizontalToCrate.Magnitude <= 0.05 then
			return false
		end

		return horizontalMove.Unit:Dot(horizontalToCrate.Unit) >= 0.35
	end

	local function updateContactSlow(player: Player, state: ContactState)
		if contactStates[player] ~= state then
			return
		end
		if not state.humanoid.Parent or state.humanoid.Health <= 0 then
			clearContactState(player)
			return
		end

		if isPushingIntoCrate(player, state) then
			if not state.isSlowed then
				local character = state.humanoid.Parent
				if character then character:SetAttribute("FNABKCratePushing", true) end
				state.isSlowed = true
			end
			if activeBodyPushOwner == nil or activeBodyPushOwner == player then
				activeBodyPushOwner = player
				pcall(function()
					crate:SetNetworkOwner(player)
				end)
			end
		else
			restorePlayerWalkSpeed(state)
			if activeBodyPushOwner == player then
				activeBodyPushOwner = nil
				setAutomaticNetworkOwnership()
			end
		end
	end

	local function restoreAllContactSlows()
		local playersToClear: { Player } = {}
		for player in pairs(contactStates) do
			table.insert(playersToClear, player)
		end
		for _, player in ipairs(playersToClear) do
			clearContactState(player)
		end
		activeBodyPushOwner = nil
		setAutomaticNetworkOwnership()
	end

	local function dropCrate(player: Player, reason: string)
		if activeCarrier ~= player then
			return
		end

		local humanoid = carrierHumanoid
		carrierHumanoid = nil
		if humanoid and humanoid.Parent then
			humanoid.Parent:SetAttribute("FNABKCrateCarrying", false)
		end

		activeCarrier = nil
		carryGeneration += 1
		if deathConnection then
			deathConnection:Disconnect()
			deathConnection = nil
		end
		if carryWeld then
			carryWeld:Destroy()
			carryWeld = nil
		end

		crate:SetAttribute("IsCarried", false)
		crate:SetAttribute("CarrierUserId", nil)
		crate.CanCollide = true
		crate.CanTouch = true
		crate.Anchored = false
		crate.AssemblyLinearVelocity = Vector3.zero
		crate.AssemblyAngularVelocity = Vector3.zero
		setAutomaticNetworkOwnership()

		prompt.ActionText = "Pick Up"
		print(string.format("[FNABK][A3] %s placed down the FuseCrate (%s)", player.Name, reason))
	end

	local function startCarrying(player: Player)
		if activeCarrier or crate.Parent ~= a3 or crate:GetAttribute("IsCarried") == true then
			return
		end

		local character, humanoid, root = getAliveCharacter(player)
		if not character or not humanoid or not root or humanoid.Sit then
			return
		end
		if not canReachCrate(character, root, crate, config.cratePushRangeStuds) then
			return
		end

		restoreAllContactSlows()
		local existingWeld = crate:FindFirstChild(CARRY_WELD_NAME)
		if existingWeld then
			existingWeld:Destroy()
		end
		crate.AssemblyLinearVelocity = Vector3.zero
		crate.AssemblyAngularVelocity = Vector3.zero
		crate.CFrame = root.CFrame * CARRY_OFFSET
		crate.Anchored = false
		-- Keep the box physically present while carried; the weld shares character motion.
		crate.CanCollide = true
		crate.CanTouch = false
		crate:SetAttribute("IsCarried", true)
		crate:SetAttribute("CarrierUserId", player.UserId)

		local weld = Instance.new("WeldConstraint")
		weld.Name = CARRY_WELD_NAME
		weld.Part0 = root
		weld.Part1 = crate
		weld.Parent = crate
		carryWeld = weld
		pcall(function()
			-- The character and carried crate share one responsive physics owner.
			crate:SetNetworkOwner(player)
		end)

		activeCarrier = player
		carrierHumanoid = humanoid
		character:SetAttribute("FNABKCrateCarrying", true)
		prompt.ActionText = "Place Down"
		print(string.format("[FNABK][A3] %s picked up the FuseCrate", player.Name))

		deathConnection = humanoid.Died:Connect(function()
			dropCrate(player, "carrier down")
		end)
		carryGeneration += 1
		local thisCarry = carryGeneration
		task.spawn(function()
			while activeCarrier == player and carryGeneration == thisCarry do
				task.wait(0.2)
				if activeCarrier ~= player or carryGeneration ~= thisCarry then
					return
				end

				local currentCharacter, currentHumanoid, currentRoot = getAliveCharacter(player)
				if currentCharacter ~= character
					or currentHumanoid ~= humanoid
					or not currentHumanoid
					or currentHumanoid.Health <= 0
					or not currentRoot
					or crate.Parent ~= a3
				then
					dropCrate(player, "carrier unavailable")
					return
				end

				local minimum = map:GetAttribute("CrateResetBoundsMin")
				local maximum = map:GetAttribute("CrateResetBoundsMax")
				if typeof(minimum) == "Vector3" and typeof(maximum) == "Vector3" then
					local position = crate.Position
					if position.X < minimum.X or position.X > maximum.X
						or position.Y < minimum.Y or position.Y > maximum.Y
						or position.Z < minimum.Z or position.Z > maximum.Z
					then
						dropCrate(player, "crate left reset bounds")
						return
					end
				end
			end
		end)
	end

	local function getTouchingPlayer(part: BasePart): (Player?, Humanoid?, BasePart?)
		local character = part:FindFirstAncestorOfClass("Model")
		if not character then
			return nil, nil, nil
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player or player.Character ~= character then
			return nil, nil, nil
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true
			or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
			or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
		then
			return player, humanoid, nil
		end
		return player, humanoid, root
	end

	crate.Touched:Connect(function(otherPart: BasePart)
		if activeCarrier or crate:GetAttribute("IsCarried") == true then
			return
		end
		local player, humanoid, root = getTouchingPlayer(otherPart)
		if not player or not humanoid or not root then
			return
		end
		if (root.Position - crate.Position).Magnitude > config.cratePushRangeStuds + BODY_PUSH_OWNER_EXTRA_DISTANCE then
			return
		end

		local state = contactStates[player]
		if not state or state.humanoid ~= humanoid then
			if state then
				clearContactState(player)
			end
			state = {
				humanoid = humanoid,
				parts = {},
				isSlowed = false,
				runningConnection = nil,
			}
			contactStates[player] = state
			state.runningConnection = humanoid.Running:Connect(function()
				updateContactSlow(player, state)
			end)
		end
		state.parts[otherPart] = true
		updateContactSlow(player, state)
	end)

	crate.TouchEnded:Connect(function(otherPart: BasePart)
		local player = getTouchingPlayer(otherPart)
		local state = player and contactStates[player]
		if not state or not state.parts[otherPart] then
			return
		end
		state.parts[otherPart] = nil
		if next(state.parts) == nil then
			clearContactState(player)
		else
			updateContactSlow(player, state)
		end
	end)

	prompt.Triggered:Connect(function(player: Player)
		if activeCarrier == player then
			local character, _, root = getAliveCharacter(player)
			if character and root and (root.Position - crate.Position).Magnitude <= config.cratePushRangeStuds + 1 then
				dropCrate(player, "placed with E")
			end
			return
		end
		startCarrying(player)
	end)

	local function registerPlayer(player: Player)
		player.CharacterAdded:Connect(function()
			dropCrate(player, "carrier respawned")
			clearContactState(player)
		end)
	end
	Players.PlayerAdded:Connect(registerPlayer)
	Players.PlayerRemoving:Connect(function(player: Player)
		dropCrate(player, "carrier left")
		clearContactState(player)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		registerPlayer(player)
	end

	task.spawn(function()
		local lastPosition = crate.Position
		local lastSampleTime = os.clock()
		while crate.Parent do
			task.wait(PHYSICS_CHECK_INTERVAL)
			for player, state in pairs(contactStates) do
				updateContactSlow(player, state)
			end
			if not crate.Parent or crate:GetAttribute("IsCarried") == true then
				lastPosition = crate.Position
				lastSampleTime = os.clock()
				continue
			end

			local now = os.clock()
			local elapsed = math.max(now - lastSampleTime, PHYSICS_CHECK_INTERVAL)
			local currentPosition = crate.Position
			local minimum = map:GetAttribute("CrateResetBoundsMin")
			local maximum = map:GetAttribute("CrateResetBoundsMax")
			local previousWasInBounds = typeof(minimum) == "Vector3" and typeof(maximum) == "Vector3"
				and lastPosition.X >= minimum.X and lastPosition.X <= maximum.X
				and lastPosition.Y >= minimum.Y and lastPosition.Y <= maximum.Y
				and lastPosition.Z >= minimum.Z and lastPosition.Z <= maximum.Z
			local currentIsInBounds = typeof(minimum) == "Vector3" and typeof(maximum) == "Vector3"
				and currentPosition.X >= minimum.X and currentPosition.X <= maximum.X
				and currentPosition.Y >= minimum.Y and currentPosition.Y <= maximum.Y
				and currentPosition.Z >= minimum.Z and currentPosition.Z <= maximum.Z
			local maximumDisplacement = MAX_CRATE_SPEED * elapsed + 1
			if previousWasInBounds and currentIsInBounds
				and (currentPosition - lastPosition).Magnitude > maximumDisplacement
			then
				crate.CFrame = CFrame.new(lastPosition) * crate.CFrame.Rotation
				crate.AssemblyLinearVelocity = Vector3.zero
				crate.AssemblyAngularVelocity = Vector3.zero
				pcall(function()
					crate:SetNetworkOwner(nil)
				end)
				currentPosition = lastPosition
			end
			local velocity = crate.AssemblyLinearVelocity
			if velocity.Magnitude > MAX_CRATE_SPEED then
				crate.AssemblyLinearVelocity = velocity.Unit * MAX_CRATE_SPEED
			end
			local angularVelocity = crate.AssemblyAngularVelocity
			if angularVelocity.Magnitude > MAX_CRATE_ANGULAR_SPEED then
				crate.AssemblyAngularVelocity = angularVelocity.Unit * MAX_CRATE_ANGULAR_SPEED
			end
			lastPosition = currentPosition
			lastSampleTime = now
		end
	end)

	print("[FNABK][A3] AC-06 ready; E picks up or places the crate, body contact pushes at reduced speed")
end

return table.freeze(CrateInteractionService)
