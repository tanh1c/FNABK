--!strict
-- AC-05 prototype: server owns scanner validation, timing, and result.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

type ScannerConfig = {
	scannerRangeStuds: number,
	scannerCooldownSeconds: number,
	scannerDurationSeconds: number,
}

local REMOTE_FOLDER_NAME = "FNABKRemotes"
local SCANNER_NAME = "Scanner"
local SCANNER_ATTRIBUTE = "FNABKServerGrantedScanner"
local REMOTE_MIN_INTERVAL_SECONDS = 0.08
local SCAN_POLL_INTERVAL_SECONDS = 0.1

local ScannerService = {}
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

local function createScanner(): Tool
	local tool = Instance.new("Tool")
	tool.Name = SCANNER_NAME
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool.ToolTip = "Scanner | Q to scan a nearby NPC"
	tool:SetAttribute(SCANNER_ATTRIBUTE, true)
	return tool
end

local function hasServerScanner(player: Player): boolean
	local character = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack")
	local characterTool = character and character:FindFirstChild(SCANNER_NAME)
	local backpackTool = backpack and backpack:FindFirstChild(SCANNER_NAME)
	if characterTool and characterTool:IsA("Tool") and characterTool:GetAttribute(SCANNER_ATTRIBUTE) == true then
		return true
	end
	if backpackTool and backpackTool:IsA("Tool") and backpackTool:GetAttribute(SCANNER_ATTRIBUTE) == true then
		return true
	end
	return false
end

local function grantScanner(player: Player)
	if hasServerScanner(player) then
		return
	end

	local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
	if backpack and backpack:IsA("Backpack") and not hasServerScanner(player) then
		createScanner().Parent = backpack
	end
end

local function getAliveCharacter(player: Player): (Model?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true
		or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
		or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
	then
		return character, nil
	end
	return character, root
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
		and (npcType == "Mimic" or npcType == "Student")
end

local function getScanFailure(
	player: Player,
	scanCharacter: Model,
	map: Folder,
	target: Model,
	config: ScannerConfig
): string?
	local character, playerRoot = getAliveCharacter(player)
	if character ~= scanCharacter or not playerRoot or not hasServerScanner(player) then
		return "ScanInterrupted"
	end
	if not isKnownNpc(target, map) then
		return "ScanInterrupted"
	end
	if (target.PrimaryPart.Position - playerRoot.Position).Magnitude > config.scannerRangeStuds then
		return "ScanOutOfRange"
	end
	if not hasLineOfSight(character, playerRoot, target) then
		return "ScanBlocked"
	end
	return nil
end

function ScannerService.Start(map: Folder, config: ScannerConfig)
	if started then
		return
	end
	started = true

	local remotes = getOrCreateFolder(ReplicatedStorage, REMOTE_FOLDER_NAME)
	local scannerRequest = makeRemote(remotes, "ScannerRequest")
	local scannerFeedback = makeRemote(remotes, "ScannerFeedback")
	local lastRemoteAt: { [Player]: number } = {}
	local nextScanAt: { [Player]: number } = {}
	local activeScanToken: { [Player]: number } = {}

	local function respond(player: Player, code: string, detail: string?)
		scannerFeedback:FireClient(player, code, detail)
	end

	local function registerPlayer(player: Player)
		player.CharacterAdded:Connect(function()
			task.defer(grantScanner, player)
		end)
		task.defer(grantScanner, player)
	end

	Players.PlayerAdded:Connect(registerPlayer)
	Players.PlayerRemoving:Connect(function(player: Player)
		lastRemoteAt[player] = nil
		nextScanAt[player] = nil
		activeScanToken[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		registerPlayer(player)
	end

	scannerRequest.OnServerEvent:Connect(function(player: Player, targetIntent: unknown)
		local now = os.clock()
		local previousRemoteAt = lastRemoteAt[player] or -math.huge
		if now - previousRemoteAt < REMOTE_MIN_INTERVAL_SECONDS then
			respond(player, "ScanRejected", "Slow down")
			return
		end
		lastRemoteAt[player] = now

		if targetIntent ~= nil and typeof(targetIntent) ~= "Instance" then
			respond(player, "ScanRejected", "Invalid target")
			return
		end
		if typeof(targetIntent) == "Instance" and not targetIntent:IsA("Model") then
			respond(player, "ScanRejected", "Invalid target")
			return
		end

		local targetModel = targetIntent :: Model?
		if targetModel and not isKnownNpc(targetModel, map) then
			respond(player, "ScanRejected", "Unknown NPC")
			return
		end

		local character, playerRoot = getAliveCharacter(player)
		if not character or not playerRoot then
			respond(player, "ScanRejected", "Player is not alive")
			return
		end
		if not hasServerScanner(player) then
			respond(player, "ScanNoScanner")
			return
		end

		local nextAllowedAt = nextScanAt[player] or 0
		if now < nextAllowedAt then
			respond(player, "ScanCooldown", string.format("%.1fs", nextAllowedAt - now))
			return
		end
		nextScanAt[player] = now + config.scannerCooldownSeconds

		if not targetModel then
			respond(player, "ScanMiss")
			return
		end
		local scanTarget = targetModel :: Model

		local targetRoot = scanTarget.PrimaryPart
		if not targetRoot then
			respond(player, "ScanRejected", "Target unavailable")
			return
		end
		if (targetRoot.Position - playerRoot.Position).Magnitude > config.scannerRangeStuds then
			respond(player, "ScanOutOfRange")
			return
		end
		if not hasLineOfSight(character, playerRoot, scanTarget) then
			respond(player, "ScanBlocked")
			return
		end

		local scanToken = (activeScanToken[player] or 0) + 1
		activeScanToken[player] = scanToken
		respond(player, "ScanStarted", string.format("%.1fs", config.scannerDurationSeconds))

		task.spawn(function()
			local scanCharacter = character
			local endsAt = os.clock() + config.scannerDurationSeconds
			while os.clock() < endsAt do
				local waitSeconds = math.min(SCAN_POLL_INTERVAL_SECONDS, math.max(0, endsAt - os.clock()))
				if waitSeconds > 0 then
					task.wait(waitSeconds)
				end
				if activeScanToken[player] ~= scanToken then
					return
				end

				local failure = getScanFailure(player, scanCharacter, map, scanTarget, config)
				if failure then
					activeScanToken[player] = nil
					if player.Parent then
						respond(player, failure)
					end
					return
				end
			end

			if activeScanToken[player] ~= scanToken then
				return
			end
			local failure = getScanFailure(player, scanCharacter, map, scanTarget, config)
			activeScanToken[player] = nil
			if failure then
				if player.Parent then
					respond(player, failure)
				end
				return
			end

			if scanTarget:GetAttribute("NPCType") == "Mimic" then
				respond(player, "ScanAnomaly", "MIMIC")
				print(string.format("[FNABK][Scanner] %s scanned a Mimic: ANOMALY SUSPECTED", player.Name))
			else
				respond(player, "ScanClear", "STUDENT")
				print(string.format("[FNABK][Scanner] %s scanned a Student: NO ANOMALY FOUND", player.Name))
			end
		end)
	end)

	print("[FNABK][Scanner] AC-05 prototype ready; server validates possession, target, range, LOS and cooldown")
end

return table.freeze(ScannerService)
