--!strict
-- AC-04 prototype: clients identify a target; this module owns all combat outcomes.
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

type CombatConfig = {
	batonDamage: number,
	batonRangeStuds: number,
	batonCooldownSeconds: number,
	mimicHealth: number,
	trustInitial: number,
	wrongfulHitTrustPenalty: number,
	wrongfulHitAlertIncrease: number,
}

local REMOTE_FOLDER_NAME = "FNABKRemotes"
local ROUND_STATE_FOLDER_NAME = "FNABKRoundState"
local BATON_NAME = "Baton"
local REMOTE_MIN_INTERVAL_SECONDS = 0.08
local STUDENT_FLEE_DISTANCE = 28
local STUDENT_FLEE_SPEED = 10

local CombatService = {}
local started = false

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

local function makeRemote(folder: Folder, name: string): RemoteEvent
	local existing = folder:FindFirstChild(name)
	if existing then
		assert(existing:IsA("RemoteEvent"), name .. " must be a RemoteEvent")
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote
end

local function createBaton(): Tool
	local tool = Instance.new("Tool")
	tool.Name = BATON_NAME
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.ToolTip = "Baton | 25 damage | 7 studs"
	tool:SetAttribute("FNABKServerGranted", true)

	local library = ServerStorage:FindFirstChild("FNABK_UserStarterTools_20261104")
	local original = library and library:FindFirstChild("StunStick")
	local sourceHandle = original and original:FindFirstChild("Handle")
	if original and original:IsA("Tool") and sourceHandle and sourceHandle:IsA("BasePart") then
		local handle: BasePart? = nil
		for _, part in ipairs(original:GetChildren()) do
			if not part:IsA("BasePart") or part.Name == "ShockPart" then continue end
			local copy = part:Clone()
			for _, child in ipairs(copy:GetDescendants()) do
				if not child:IsA("DataModelMesh") then child:Destroy() end
			end
			copy.Anchored, copy.CanCollide, copy.CanTouch, copy.CanQuery, copy.Massless = false, false, false, false, true
			copy.CFrame = sourceHandle.CFrame:ToObjectSpace(part.CFrame)
			copy.Parent = tool
			if part == sourceHandle then handle = copy end
		end
		assert(handle, "Baton handle missing")
		for _, part in ipairs(tool:GetChildren()) do
			if part:IsA("BasePart") and part ~= handle then
				local weld = Instance.new("WeldConstraint")
				weld.Part0, weld.Part1, weld.Parent = handle, part, handle
			end
		end
		tool.Grip = original.Grip
		return tool
	end

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.25, 3, 0.25)
	handle.Color = Color3.fromRGB(47, 55, 66)
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.CanTouch = false
	handle.CanQuery = false
	handle.Massless = true
	handle.Parent = tool

	return tool
end

local function hasEquippedServerBaton(player: Player): boolean
	local character = player.Character
	if not character then
		return false
	end

	local baton = character:FindFirstChild(BATON_NAME)
	return baton ~= nil
		and baton:IsA("Tool")
		and baton:GetAttribute("FNABKServerGranted") == true
end

local function grantBaton(player: Player)
	local character = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
	if not backpack or not backpack:IsA("Backpack") then
		return
	end

	local existingInCharacter = character and character:FindFirstChild(BATON_NAME)
	local existingInBackpack = backpack:FindFirstChild(BATON_NAME)
	if existingInCharacter or existingInBackpack then
		return
	end

	createBaton().Parent = backpack
end

local function isPlayerAlive(player: Player): (Model?, Humanoid?, BasePart?)
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

local function hasLineOfSight(character: Model, playerRoot: BasePart, target: Model): boolean
	local targetRoot = target.PrimaryPart
	if not targetRoot then
		return false
	end

	local origin = playerRoot.Position + Vector3.new(0, 1.5, 0)
	local targetPosition = targetRoot.Position + Vector3.new(0, 0.5, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = true

	local result = Workspace:Raycast(origin, targetPosition - origin, raycastParams)
	return result ~= nil and result.Instance:IsDescendantOf(target)
end

local function isKnownNpc(target: Model, map: Folder): boolean
	local npcType = target:GetAttribute("NPCType")
	return target:IsDescendantOf(map)
		and target.PrimaryPart ~= nil
		and (npcType == "Mimic" or npcType == "Student" or npcType == "Creature" or npcType == "Machine")
end

local function nearbyNpc(character: Model, root: BasePart, map: Folder, range: number): Model?
	local nearest: Model? = nil
	local nearestDistance = range
	local facing = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
	if facing.Magnitude < 0.01 then return nil end
	facing = facing.Unit
	for _, candidate in ipairs(map:GetDescendants()) do
		if not candidate:IsA("Model") or not isKnownNpc(candidate, map) then continue end
		if candidate:GetAttribute("MimicState") == "Defeated" or candidate:GetAttribute("EnemyState") == "Defeated" then continue end
		local targetRoot = candidate.PrimaryPart :: BasePart
		local offset = targetRoot.Position - root.Position
		local horizontal = Vector3.new(offset.X, 0, offset.Z)
		local distance = offset.Magnitude
		if distance <= nearestDistance and horizontal.Magnitude > 0.01
			and facing:Dot(horizontal.Unit) >= 0.5 and hasLineOfSight(character, root, candidate) then
			nearest, nearestDistance = candidate, distance
		end
	end
	return nearest
end

local SurvivorHealth = require(script.Parent:WaitForChild("SurvivorHealth"))
local SurvivorDefense = require(script.Parent:WaitForChild("SurvivorDefense"))
local EnemyHealth = require(script.Parent:WaitForChild("EnemyHealth"))

local function fleeStudent(student: Model, attackerRoot: BasePart)
	local studentRoot = student.PrimaryPart
	if not studentRoot or student:GetAttribute("FleeingStarted") == true then
		return
	end
	student:SetAttribute("FleeingStarted", true)

	local away = Vector3.new(
		studentRoot.Position.X - attackerRoot.Position.X,
		0,
		studentRoot.Position.Z - attackerRoot.Position.Z
	)
	if away.Magnitude < 0.1 then
		away = Vector3.new(1, 0, 0)
	else
		away = away.Unit
	end

	local destination = studentRoot.Position + away * STUDENT_FLEE_DISTANCE
	local path = PathfindingService:CreatePath({
		AgentRadius = 1.5,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentCanClimb = false,
		WaypointSpacing = 4,
	})
	local computed = pcall(function()
		path:ComputeAsync(studentRoot.Position, destination)
	end)
	if not computed or path.Status ~= Enum.PathStatus.Success then
		warn("[FNABK][Combat] Student flee path unavailable")
		student:SetAttribute("FleeingStarted", false)
		return
	end

	task.spawn(function()
		for _, waypoint in ipairs(path:GetWaypoints()) do
			if not student.Parent or not studentRoot.Parent then
				return
			end

			while student.Parent and studentRoot.Parent and student:GetAttribute("StudentState") == "Fleeing" do
				local currentPosition = studentRoot.Position
				local targetPosition = Vector3.new(waypoint.Position.X, currentPosition.Y, waypoint.Position.Z)
				local offset = Vector3.new(targetPosition.X - currentPosition.X, 0, targetPosition.Z - currentPosition.Z)
				if offset.Magnitude <= 1.5 then
					break
				end

				local deltaTime = task.wait(0.05)
				if student:GetAttribute("StudentState") ~= "Fleeing" then return end
				local direction = offset.Unit
				local step = math.min(STUDENT_FLEE_SPEED * deltaTime, offset.Magnitude)
				local nextPosition = currentPosition + direction * step
				student:PivotTo(CFrame.lookAt(nextPosition, nextPosition + direction))
			end
		end
		student:SetAttribute("FleeingStarted", false)
	end)
end

function CombatService.Start(map: Folder, mimic: Model, config: CombatConfig, applyDamage: (Player, number) -> number?)
	if started then
		return
	end
	started = true

	local remotesFolder = getOrCreateFolder(ReplicatedStorage, REMOTE_FOLDER_NAME)
	local attackRequest = makeRemote(remotesFolder, "AttackRequest")
	local attackFeedback = makeRemote(remotesFolder, "AttackFeedback")
	local roundState = getOrCreateFolder(ReplicatedStorage, ROUND_STATE_FOLDER_NAME)
	local trust = getOrCreateIntValue(roundState, "Trust", config.trustInitial)
	local alert = getOrCreateIntValue(roundState, "Alert", 0)
	mimic:SetAttribute("MimicHealth", config.mimicHealth)

	local lastRemoteAt: { [Player]: number } = {}
	local nextAttackAt: { [Player]: number } = {}

	local function respond(player: Player, code: string, detail: string?)
		attackFeedback:FireClient(player, code, detail)
	end

	local function registerPlayer(player: Player)
		player.CharacterAdded:Connect(function()
			task.defer(grantBaton, player)
		end)
		task.defer(grantBaton, player)
	end

	Players.PlayerAdded:Connect(registerPlayer)
	Players.PlayerRemoving:Connect(function(player: Player)
		lastRemoteAt[player] = nil
		nextAttackAt[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		registerPlayer(player)
	end

	attackRequest.OnServerEvent:Connect(function(player: Player, targetIntent: unknown)
		local status = roundState:FindFirstChild("RoundStatus")
		if not status or not status:IsA("StringValue") or status.Value ~= "Running" then return end
		local now = os.clock()
		local previousRemoteAt = lastRemoteAt[player] or -math.huge
		if now - previousRemoteAt < REMOTE_MIN_INTERVAL_SECONDS then
			respond(player, "Rejected", "Slow down")
			return
		end
		lastRemoteAt[player] = now

		if targetIntent ~= nil and typeof(targetIntent) ~= "Instance" then
			respond(player, "Rejected", "Invalid target")
			return
		end
		if typeof(targetIntent) == "Instance" and not targetIntent:IsA("Model") then
			respond(player, "Rejected", "Invalid target")
			return
		end

		local targetModel = targetIntent :: Model?
		local targetPlayer = if targetModel then Players:GetPlayerFromCharacter(targetModel) else nil
		if targetModel and not targetPlayer and not isKnownNpc(targetModel, map) then
			respond(player, "Rejected", "Unknown NPC")
			return
		end
		if targetPlayer then
			local _, _, targetRoot = isPlayerAlive(targetPlayer)
			if targetPlayer == player or not targetRoot or targetPlayer.Character ~= targetModel then
				respond(player, "Rejected", "Invalid teammate")
				return
			end
		end

		local character, _, playerRoot = isPlayerAlive(player)
		if not character or not playerRoot then
			respond(player, "Rejected", "Player is not alive")
			return
		end
		if not hasEquippedServerBaton(player) then
			respond(player, "NoBaton")
			return
		end

		local nextAllowedAt = nextAttackAt[player] or 0
		if now < nextAllowedAt then
			respond(player, "Cooldown")
			return
		end
		nextAttackAt[player] = now + config.batonCooldownSeconds
		player:SetAttribute("FNABKImmuneUntil", nil)

		-- ponytail: one nearby target in a 120-degree forward arc; replace with a validated swept hitbox if melee expands.
		if not targetModel then targetModel = nearbyNpc(character, playerRoot, map, config.batonRangeStuds) end
		if not targetModel then
			respond(player, "Miss")
			return
		end
		local target = targetModel :: Model
		local npcType = target:GetAttribute("NPCType")
		if target:GetAttribute("MimicState") == "Defeated" or target:GetAttribute("EnemyState") == "Defeated" then
			respond(player, "Miss", "Mimic already defeated")
			return
		end

		local targetRoot = target.PrimaryPart
		if not targetRoot then
			respond(player, "Rejected", "Target has no root")
			return
		end
		local distance = (targetRoot.Position - playerRoot.Position).Magnitude
		if distance > config.batonRangeStuds then
			respond(player, "OutOfRange")
			return
		end
		if not hasLineOfSight(character, playerRoot, target) then
			respond(player, "Blocked")
			return
		end
		if targetPlayer then
			local before = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
			local oldHealth = before and before.Health
			local after = applyDamage(targetPlayer, 5)
			if oldHealth and after and after < oldHealth then respond(player, "FriendlyHit", targetPlayer.DisplayName)
			else respond(player, "Miss") end
			return
		end

		if npcType == "Student" then
			if not SurvivorHealth.Hit(target, config.batonDamage) then respond(player, "Miss"); return end
			trust.Value = math.max(0, trust.Value - config.wrongfulHitTrustPenalty)
			alert.Value += config.wrongfulHitAlertIncrease
			SurvivorDefense.attacked(target, player, applyDamage)
			respond(player, "WrongfulHit", string.format("Trust %d | Alert %d", trust.Value, alert.Value))
			print(string.format("[FNABK][Combat] Wrongful hit; Trust=%d, Alert=%d", trust.Value, alert.Value))
			return
		end

		local remainingHealth = EnemyHealth.damage(target, config.batonDamage)
		if not remainingHealth then respond(player, "Miss"); return end
		if remainingHealth <= 0 then
			for _, descendant in ipairs(target:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Name ~= "Root" then
					descendant.Color = Color3.fromRGB(35, 41, 47)
					descendant.Material = Enum.Material.Slate
				end
			end
			respond(player, "Defeated")
			print(string.format("[FNABK][Combat] %s -> Defeated", npcType))
			return
		end

		respond(player, "Hit", string.format("%d HP", remainingHealth))
		print(string.format("[FNABK][Combat] %s hit; HP=%d", npcType, remainingHealth))
	end)

	print("[FNABK][Combat] AC-04 prototype ready; server owns damage, Trust, Alert and NPC state")
end

return table.freeze(CombatService)
