--!strict
-- Server-owned Mimic FSM with timed UV Stunned state and delegated player damage.
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("FNABKShared")
local npcDefinitions = require(shared:WaitForChild("NPCDefinitions"))
local states = npcDefinitions.MimicStates

type MimicConfig = {
	mimicDetectionRangeStuds: number,
	mimicCrouchNoiseRangeStuds: number,
	mimicWalkNoiseRangeStuds: number,
	mimicSprintNoiseRangeStuds: number,
	mimicNoiseIntervalSeconds: number,
	walkSpeed: number,
	mimicFieldOfViewDegrees: number,
	mimicSuspiciousSeconds: number,
	mimicLostSightSeconds: number,
	mimicSearchSeconds: number,
	mimicSpeed: number,
	mimicAttackRangeStuds: number,
	mimicDamage: number,
	mimicAttackCooldownSeconds: number,
}

type VisibleTarget = {
	player: Player,
	root: BasePart,
	humanoid: Humanoid,
}

type ApplyPlayerDamage = (Player, number) -> number?

local UPDATE_INTERVAL_SECONDS = 0.1
local PATH_REFRESH_SECONDS = 0.8
local WAYPOINT_REACHED_STUDS = 2
local STUCK_RECOVERY_SECONDS = 1.5

local STATE_COLORS: { [string]: Color3 } = {
	Disguise = Color3.fromRGB(78, 88, 98),
	Suspicious = Color3.fromRGB(198, 149, 75),
	Chase = Color3.fromRGB(190, 70, 64),
	Attack = Color3.fromRGB(232, 96, 78),
	Search = Color3.fromRGB(60, 145, 155),
	Stunned = Color3.fromRGB(91, 151, 224),
	Defeated = Color3.fromRGB(35, 41, 47),
}

local MimicController = {}

local function horizontal(vector: Vector3): Vector3
	return Vector3.new(vector.X, 0, vector.Z)
end

function MimicController.Start(mimic: Model, config: MimicConfig, applyPlayerDamage: ApplyPlayerDamage, gunshot: BindableEvent)
	if mimic:GetAttribute("ControllerStarted") == true then
		return
	end

	local root = mimic.PrimaryPart
	assert(root, "Mimic requires a PrimaryPart")
	mimic:SetAttribute("ControllerStarted", true)

	local currentState = states.Disguise
	local lastKnownPosition: Vector3? = nil
	local lastSeenAt = 0
	local suspiciousUntil = 0
	local searchStartedAt = 0
	local nextAttackAt = 0
	local nextNoiseCheckAt = 0
	local suspiciousFromNoise = false

	local waypoints: { PathWaypoint } = {}
	local nextWaypointIndex = 1
	local nextPathAt = 0
	local routeNeedsRefresh = false
	local blockedConnection: RBXScriptConnection? = nil
	local stuckSeconds = 0
	local lastMovementPosition = root.Position
	local lastPathWarningAt = -math.huge

	local function updateLastKnownPosition(position: Vector3)
		lastKnownPosition = position
		mimic:SetAttribute("MimicLastKnownPosition", position)
	end

	local function targetDistance(targetRoot: BasePart): number
		return (targetRoot.Position - root.Position).Magnitude
	end

	local function setState(nextState: string)
		if currentState == nextState then
			return
		end

		local previousState = currentState
		currentState = nextState
		mimic:SetAttribute("MimicState", currentState)

		local torso = mimic:FindFirstChild("Torso")
		local color = STATE_COLORS[nextState]
		if torso and torso:IsA("BasePart") and color then
			torso.Color = color
		end

		if nextState == states.Search and lastKnownPosition then
			print(string.format(
				"[FNABK][Mimic] %s -> %s; last-known=(%.1f, %.1f, %.1f)",
				previousState,
				nextState,
				lastKnownPosition.X,
				lastKnownPosition.Y,
				lastKnownPosition.Z
			))
		else
			print(string.format("[FNABK][Mimic] %s -> %s", previousState, nextState))
		end
	end
	gunshot.Event:Connect(function(position: Vector3, radius: number)
		local observedState = mimic:GetAttribute("MimicState")
		if not mimic.Parent or observedState == states.Defeated or observedState == states.Stunned
			or currentState == states.Defeated or currentState == states.Stunned
			or currentState == states.Chase or currentState == states.Attack then return end
		if (root.Position - position).Magnitude > radius then return end
		updateLastKnownPosition(position)
		suspiciousFromNoise = true
		suspiciousUntil = os.clock() + config.mimicSuspiciousSeconds
		setState(states.Suspicious)
	end)

	local function findVisibleTarget(): VisibleTarget?
		local mimicPivot = mimic:GetPivot()
		local origin = mimicPivot.Position + Vector3.new(0, 2, 0)
		local forward = horizontal(mimicPivot.LookVector)
		if forward.Magnitude <= 0 then
			return nil
		end
		forward = forward.Unit

		local nearestTarget: VisibleTarget? = nil
		local nearestDistance = math.huge
		local minimumFacingDot = math.cos(math.rad(config.mimicFieldOfViewDegrees * 0.5))

		for _, player in ipairs(Players:GetPlayers()) do
			if player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true then
				continue
			end
			local character = player.Character
			if not character then
				continue
			end
			if character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true then
				continue
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local targetRoot = character:FindFirstChild("HumanoidRootPart")
			if not humanoid or humanoid.Health <= 0 or not targetRoot or not targetRoot:IsA("BasePart") then
				continue
			end

			local offset = horizontal(targetRoot.Position - mimicPivot.Position)
			local distance = offset.Magnitude
			if distance <= 0 or distance > config.mimicDetectionRangeStuds then
				continue
			end
			if forward:Dot(offset.Unit) < minimumFacingDot then
				continue
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { mimic, character }
			raycastParams.IgnoreWater = true

			local targetPosition = targetRoot.Position + Vector3.new(0, 1, 0)
			local obstruction = Workspace:Raycast(origin, targetPosition - origin, raycastParams)
			if obstruction == nil and distance < nearestDistance then
				nearestDistance = distance
				nearestTarget = {
					player = player,
					root = targetRoot,
					humanoid = humanoid,
				}
			end
		end

		return nearestTarget
	end

	-- Hearing uses server-observed horizontal motion and grounded state. It does
	-- not reveal a hidden player as a visible combat target through a wall.
	local function findHeardPosition(): Vector3?
		local nearest: Vector3? = nil
		local nearestDistance = math.huge
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
			if not character or not humanoid or humanoid.Health <= 0 or not targetRoot or not targetRoot:IsA("BasePart")
				or player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true
				or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
				or humanoid.FloorMaterial == Enum.Material.Air then continue end
			local speed = horizontal(targetRoot.AssemblyLinearVelocity).Magnitude
			if speed < 1 then continue end
			local range = if player:GetAttribute("FNABKCrouching") == true then config.mimicCrouchNoiseRangeStuds
				elseif humanoid.WalkSpeed > config.walkSpeed and speed > config.walkSpeed then config.mimicSprintNoiseRangeStuds
				else config.mimicWalkNoiseRangeStuds
			local distance = horizontal(targetRoot.Position - root.Position).Magnitude
			if distance <= range and distance < nearestDistance then
				nearest = targetRoot.Position
				nearestDistance = distance
			end
		end
		return nearest
	end

	local function attackTarget(target: VisibleTarget, now: number)
		if now < nextAttackAt or target.humanoid.Health <= 0 then
			return
		end

		nextAttackAt = now + config.mimicAttackCooldownSeconds
		local remainingHealth = applyPlayerDamage(target.player, config.mimicDamage)
		print(string.format(
			"[FNABK][Mimic] Attack hit %s for %d; HP=%.0f",
			target.humanoid.Parent and target.humanoid.Parent.Name or "player",
			config.mimicDamage,
			remainingHealth or target.humanoid.Health
		))
	end

	local function computeRoute(destination: Vector3)
		if blockedConnection then
			blockedConnection:Disconnect()
			blockedConnection = nil
		end

		local path = PathfindingService:CreatePath({
			-- ponytail: fit the current root; use per-rig bounds for larger enemies.
			AgentRadius = math.max(root.Size.X, root.Size.Z) / 2,
			AgentHeight = 6,
			AgentCanJump = false,
			AgentCanClimb = false,
			WaypointSpacing = 4,
		})

		local groundParams = RaycastParams.new()
		local ignored: { Instance } = { mimic }
		for _, player in ipairs(Players:GetPlayers()) do if player.Character then table.insert(ignored, player.Character) end end
		groundParams.FilterType, groundParams.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, ignored
		groundParams.RespectCanCollide = true
		local function ground(position: Vector3): Vector3
			local hit = Workspace:Raycast(position + Vector3.new(0, 2, 0), Vector3.new(0, -14, 0), groundParams)
			return if hit then hit.Position else position
		end
		local startPosition, endPosition = ground(root.Position), ground(destination)
		local computed, errorMessage = pcall(function()
			path:ComputeAsync(startPosition, endPosition)
		end)

		if not computed or path.Status ~= Enum.PathStatus.Success then
			waypoints = {}
			nextWaypointIndex = 1
			routeNeedsRefresh = false
			if os.clock() - lastPathWarningAt >= 5 then
				lastPathWarningAt = os.clock()
				local reason = tostring(errorMessage)
				if computed then
					reason = path.Status.Name
				end
				warn(string.format("[FNABK][Mimic] Path unavailable; retrying. %s", reason))
			end
			return
		end

		waypoints = path:GetWaypoints()
		nextWaypointIndex = 1
		while nextWaypointIndex <= #waypoints do
			local waypointPosition = waypoints[nextWaypointIndex].Position + Vector3.new(0, root.Size.Y / 2, 0) - root.Position
			if waypointPosition.Magnitude > WAYPOINT_REACHED_STUDS then
				break
			end
			nextWaypointIndex += 1
		end

		routeNeedsRefresh = false
		if blockedConnection then
			blockedConnection:Disconnect()
		end
		blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex: number)
			if blockedWaypointIndex >= nextWaypointIndex then
				routeNeedsRefresh = true
			end
		end)
	end

	local function moveAlongRoute(deltaTime: number): boolean
		while nextWaypointIndex <= #waypoints do
			local waypoint = waypoints[nextWaypointIndex]
			local currentPosition = root.Position
			local targetPosition = waypoint.Position + Vector3.new(0, root.Size.Y / 2, 0)
			local offset = targetPosition - currentPosition
			if offset.Magnitude <= WAYPOINT_REACHED_STUDS then
				nextWaypointIndex += 1
				continue
			end

			local direction = offset.Unit
			local distance = math.min(config.mimicSpeed * deltaTime, offset.Magnitude)
			local nextPosition = currentPosition + direction * distance
			local facing = horizontal(direction)
			mimic:PivotTo(if facing.Magnitude > 0.001 then CFrame.lookAt(nextPosition, nextPosition + facing) else CFrame.new(nextPosition) * mimic:GetPivot().Rotation)
			return true
		end

		return false
	end

	local function moveToward(destination: Vector3, now: number, deltaTime: number)
		if routeNeedsRefresh or now >= nextPathAt then
			computeRoute(destination)
			nextPathAt = now + PATH_REFRESH_SECONDS
		end

		local wasMoving = moveAlongRoute(deltaTime)
		if not wasMoving then
			stuckSeconds = 0
			lastMovementPosition = root.Position
			return
		end

		local displacement = (root.Position - lastMovementPosition).Magnitude
		if displacement < 0.1 then
			stuckSeconds += deltaTime
		else
			stuckSeconds = 0
		end
		lastMovementPosition = root.Position

		if stuckSeconds >= STUCK_RECOVERY_SECONDS then
			stuckSeconds = 0
			routeNeedsRefresh = true
			warn("[FNABK][Mimic] Stuck recovery: recalculating path")
		end
	end

	print(string.format(
		"[FNABK][Mimic] Started; detect=%dst, attack=%dst, FOV=%ddeg, speed=%dst/s",
		config.mimicDetectionRangeStuds,
		config.mimicAttackRangeStuds,
		config.mimicFieldOfViewDegrees,
		config.mimicSpeed
	))

	task.spawn(function()
		while mimic.Parent and mimic:GetAttribute("MimicState") ~= states.Defeated do
			local deltaTime = task.wait(UPDATE_INTERVAL_SECONDS)
			if mimic:GetAttribute("MimicState") == states.Defeated then
				currentState = states.Defeated
				break
			end
			local now = os.clock()
			if mimic:GetAttribute("MimicState") == states.Stunned and currentState ~= states.Stunned then
				local stunLastKnownPosition = mimic:GetAttribute("MimicLastKnownPosition")
				if typeof(stunLastKnownPosition) == "Vector3" then
					lastKnownPosition = stunLastKnownPosition
				end
				lastSeenAt = now
				setState(states.Stunned)
			end
			local visibleTarget = findVisibleTarget()
			local heardPosition: Vector3? = nil
			if now >= nextNoiseCheckAt and currentState ~= states.Stunned then
				nextNoiseCheckAt = now + config.mimicNoiseIntervalSeconds
				heardPosition = findHeardPosition()
			end

			if currentState == states.Disguise then
				if visibleTarget then
					suspiciousFromNoise = false
					updateLastKnownPosition(visibleTarget.root.Position)
					lastSeenAt = now
					suspiciousUntil = now + config.mimicSuspiciousSeconds
					setState(states.Suspicious)
				elseif heardPosition then
					updateLastKnownPosition(heardPosition)
					suspiciousFromNoise = true
					suspiciousUntil = now + config.mimicSuspiciousSeconds
					print("[FNABK][Mimic] Heard movement; investigating")
					setState(states.Suspicious)
				end
			elseif currentState == states.Suspicious then
				if visibleTarget then
					suspiciousFromNoise = false
					updateLastKnownPosition(visibleTarget.root.Position)
					lastSeenAt = now
					if now >= suspiciousUntil then
						nextPathAt = 0
						setState(states.Chase)
					end
				elseif suspiciousFromNoise then
					if heardPosition then updateLastKnownPosition(heardPosition) end
					if now >= suspiciousUntil then
						searchStartedAt = now
						nextPathAt = 0
						setState(states.Search)
					end
				else
					setState(states.Disguise)
				end
			elseif currentState == states.Chase then
				if visibleTarget then
					updateLastKnownPosition(visibleTarget.root.Position)
					lastSeenAt = now
					if targetDistance(visibleTarget.root) <= config.mimicAttackRangeStuds then
						setState(states.Attack)
						attackTarget(visibleTarget, now)
					end
				elseif lastKnownPosition and now - lastSeenAt > config.mimicLostSightSeconds then
					searchStartedAt = now
					nextPathAt = 0
					setState(states.Search)
				end
			elseif currentState == states.Attack then
				if visibleTarget then
					updateLastKnownPosition(visibleTarget.root.Position)
					lastSeenAt = now
					if targetDistance(visibleTarget.root) > config.mimicAttackRangeStuds then
						nextPathAt = 0
						setState(states.Chase)
					else
						attackTarget(visibleTarget, now)
					end
				elseif lastKnownPosition and now - lastSeenAt > config.mimicLostSightSeconds then
					searchStartedAt = now
					nextPathAt = 0
					setState(states.Search)
				else
					setState(states.Chase)
				end
			elseif currentState == states.Stunned then
				local stunnedUntil = mimic:GetAttribute("MimicStunnedUntil")
				if typeof(stunnedUntil) ~= "number" or now >= stunnedUntil then
					mimic:SetAttribute("MimicStunnedUntil", nil)
					nextPathAt = 0
					setState(states.Chase)
				end
			elseif currentState == states.Search then
				if visibleTarget then
					updateLastKnownPosition(visibleTarget.root.Position)
					lastSeenAt = now
					suspiciousFromNoise = false
					suspiciousUntil = now + config.mimicSuspiciousSeconds
					setState(states.Suspicious)
				elseif heardPosition then
					updateLastKnownPosition(heardPosition)
					searchStartedAt = now
				elseif now - searchStartedAt >= config.mimicSearchSeconds then
					setState(states.Disguise)
					if blockedConnection then
						blockedConnection:Disconnect()
						blockedConnection = nil
					end
					waypoints = {}
					nextWaypointIndex = 1
					lastKnownPosition = nil
					mimic:SetAttribute("MimicLastKnownPosition", nil)
				end
			end

			if (currentState == states.Chase or currentState == states.Search) and lastKnownPosition then
				moveToward(lastKnownPosition, now, deltaTime)
			end
		end

		if blockedConnection then
			blockedConnection:Disconnect()
		end
	end)
end

return table.freeze(MimicController)
