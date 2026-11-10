--!strict
-- AC-05 UV slice: server validates device ownership and stun requests.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

type UVConfig = {
	uvStunSeconds: number,
	uvRangeStuds: number,
	uvCooldownSeconds: number,
}

local REMOTE_FOLDER_NAME = "FNABKRemotes"
local UV_DEVICE_NAME = "UV Device"
local REMOTE_MIN_INTERVAL_SECONDS = 0.08

local UVService = {}
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

local function createUVDevice(): Tool
	local tool = Instance.new("Tool")
	tool.Name = UV_DEVICE_NAME
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool.ToolTip = "UV Device | F to stun a Mimic"
	tool:SetAttribute("FNABKServerGrantedUV", true)
	return tool
end

local function hasServerUVDevice(player: Player): boolean
	local character = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack")
	local characterTool = character and character:FindFirstChild(UV_DEVICE_NAME)
	local backpackTool = backpack and backpack:FindFirstChild(UV_DEVICE_NAME)
	if characterTool and characterTool:IsA("Tool") and characterTool:GetAttribute("FNABKServerGrantedUV") == true then
		return true
	end
	if backpackTool and backpackTool:IsA("Tool") and backpackTool:GetAttribute("FNABKServerGrantedUV") == true then
		return true
	end
	return false
end

local function grantUVDevice(player: Player)
	if hasServerUVDevice(player) then
		return
	end

	local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
	if backpack and backpack:IsA("Backpack") then
		createUVDevice().Parent = backpack
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

local function hasLineOfSight(character: Model, playerRoot: BasePart, mimic: Model): boolean
	local mimicRoot = mimic.PrimaryPart
	if not mimicRoot then
		return false
	end

	local origin = playerRoot.Position + Vector3.new(0, 1.5, 0)
	local targetPosition = mimicRoot.Position + Vector3.new(0, 0.5, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = true

	local result = Workspace:Raycast(origin, targetPosition - origin, raycastParams)
	return result ~= nil and result.Instance:IsDescendantOf(mimic)
end

local function isKnownMimic(target: Model, map: Folder): boolean
	return target:IsDescendantOf(map)
		and target.PrimaryPart ~= nil
		and target:GetAttribute("NPCType") == "Mimic"
end

function UVService.Start(map: Folder, mimic: Model, config: UVConfig)
	if started then
		return
	end
	started = true

	local remotes = getOrCreateFolder(ReplicatedStorage, REMOTE_FOLDER_NAME)
	local uvRequest = makeRemote(remotes, "UVRequest")
	local uvFeedback = makeRemote(remotes, "UVFeedback")
	local lastRemoteAt: { [Player]: number } = {}
	local nextUVAt: { [Player]: number } = {}

	local function respond(player: Player, code: string, detail: string?)
		if detail then
			uvFeedback:FireClient(player, code, detail)
		else
			uvFeedback:FireClient(player, code)
		end
	end

	local function registerPlayer(player: Player)
		player.CharacterAdded:Connect(function()
			task.defer(grantUVDevice, player)
		end)
		task.defer(grantUVDevice, player)
	end

	Players.PlayerAdded:Connect(registerPlayer)
	Players.PlayerRemoving:Connect(function(player: Player)
		lastRemoteAt[player] = nil
		nextUVAt[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		registerPlayer(player)
	end

	uvRequest.OnServerEvent:Connect(function(player: Player, targetIntent: unknown)
		local now = os.clock()
		local previousRemoteAt = lastRemoteAt[player] or -math.huge
		if now - previousRemoteAt < REMOTE_MIN_INTERVAL_SECONDS then
			respond(player, "UVRejected", "Slow down")
			return
		end
		lastRemoteAt[player] = now

		if targetIntent ~= nil and typeof(targetIntent) ~= "Instance" then
			respond(player, "UVRejected", "Invalid target")
			return
		end
		if typeof(targetIntent) == "Instance" and not targetIntent:IsA("Model") then
			respond(player, "UVRejected", "Invalid target")
			return
		end

		local targetModel = targetIntent :: Model?
		if targetModel and not isKnownMimic(targetModel, map) then
			respond(player, "UVRejected", "Unknown NPC")
			return
		end

		local character, playerRoot = getAliveCharacter(player)
		if not character or not playerRoot then
			respond(player, "UVRejected", "Player is not alive")
			return
		end
		if not hasServerUVDevice(player) then
			respond(player, "UVNoDevice")
			return
		end

		local nextAllowedAt = nextUVAt[player] or 0
		if now < nextAllowedAt then
			respond(player, "UVCooldown", string.format("%.1fs", nextAllowedAt - now))
			return
		end
		nextUVAt[player] = now + config.uvCooldownSeconds

		if not targetModel then
			respond(player, "UVMiss")
			return
		end
		local target = targetModel :: Model
		if target:GetAttribute("MimicState") == "Defeated" or target:GetAttribute("MimicState") == "Retreat" then
			respond(player, "UVRejected", "Mimic unavailable")
			return
		end

		local targetRoot = target.PrimaryPart
		if not targetRoot then
			respond(player, "UVRejected", "Mimic has no root")
			return
		end
		local distance = (targetRoot.Position - playerRoot.Position).Magnitude
		if distance > config.uvRangeStuds then
			respond(player, "UVOutOfRange")
			return
		end
		if not hasLineOfSight(character, playerRoot, target) then
			respond(player, "UVBlocked")
			return
		end

		local stunnedUntil = target:GetAttribute("MimicStunnedUntil")
		if target:GetAttribute("MimicState") == "Stunned" and typeof(stunnedUntil) == "number" and stunnedUntil > now then
			respond(player, "UVAlreadyStunned", string.format("%.1fs left", stunnedUntil - now))
			return
		end

		local thisStunEndsAt = now + config.uvStunSeconds
		target:SetAttribute("MimicLastKnownPosition", playerRoot.Position)
		target:SetAttribute("MimicStunnedUntil", thisStunEndsAt)
		target:SetAttribute("MimicState", "Stunned")
		respond(player, "UVStunned", string.format("%.1fs", config.uvStunSeconds))
		print(string.format("[FNABK][UV] %s -> Stunned for %.1fs by %s", target.Name, config.uvStunSeconds, player.Name))

		if target ~= mimic then
			task.delay(config.uvStunSeconds, function()
				if target.Parent
					and target:GetAttribute("MimicStunnedUntil") == thisStunEndsAt
					and target:GetAttribute("MimicState") == "Stunned"
				then
					target:SetAttribute("MimicState", if target:GetAttribute("WaveKind") == "Mimic" then "Chase" else "Disguise")
				end
			end)
		end
	end)

	print("[FNABK][UV] AC-05 UV prototype ready; server validates range, LOS, device and cooldown")
end

return table.freeze(UVService)
