--!strict
-- AC-08 first slice: server-owned B4 fuse pickup, generator repair and Key 3.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

type B4Config = {
	b4InteractionRangeStuds: number,
}

local REMOTE_FOLDER_NAME = "FNABKRemotes"
local FEEDBACK_REMOTE_NAME = "B4Feedback"
local FUSE_PROMPT_NAME = "B4FusePrompt"
local GENERATOR_PROMPT_NAME = "B4GeneratorPrompt"
local POWER_COLOR = Color3.fromRGB(29, 144, 127)
local OFF_COLOR = Color3.fromRGB(224, 88, 70)

local B4GeneratorService = {}

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

local function getOrCreatePrompt(part: BasePart, name: string, objectText: string, range: number): ProximityPrompt
	local existing = part:FindFirstChild(name)
	if existing then
		assert(existing:IsA("ProximityPrompt"), name .. " must be a ProximityPrompt")
	else
		existing = Instance.new("ProximityPrompt")
		existing.Name = name
		existing.Parent = part
	end

	local prompt = existing :: ProximityPrompt
	prompt.ObjectText = objectText
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = range
	prompt.RequiresLineOfSight = true
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	return prompt
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

function B4GeneratorService.Start(map: Folder, config: B4Config)
	if map:GetAttribute("B4GeneratorStarted") == true then
		return
	end
	map:SetAttribute("B4GeneratorStarted", true)

	local b4 = map:FindFirstChild("B4")
	assert(b4 and b4:IsA("Folder"), "Graybox is missing B4")
	local fuseInstance = b4:FindFirstChild("SpareFuse")
	local generatorInstance = b4:FindFirstChild("Generator")
	local indicatorInstance = b4:FindFirstChild("GeneratorIndicator")
	assert(fuseInstance and fuseInstance:IsA("BasePart"), "B4 is missing SpareFuse")
	assert(generatorInstance and generatorInstance:IsA("BasePart"), "B4 is missing Generator")
	assert(indicatorInstance and indicatorInstance:IsA("BasePart"), "B4 is missing GeneratorIndicator")
	local fuse = fuseInstance :: BasePart
	local generator = generatorInstance :: BasePart
	local indicator = indicatorInstance :: BasePart

	local roundStateInstance = ReplicatedStorage:WaitForChild("FNABKRoundState")
	assert(roundStateInstance:IsA("Folder"), "FNABKRoundState must be a Folder")
	local roundState = roundStateInstance :: Folder
	local dataKeys = roundState:WaitForChild("DataKeys")
	assert(dataKeys:IsA("Folder"), "DataKeys must be a Folder")
	local keyTwoInstance = dataKeys:WaitForChild("Key2")
	local keyThreeInstance = dataKeys:WaitForChild("Key3")
	assert(keyTwoInstance:IsA("BoolValue"), "Key2 must be a BoolValue")
	assert(keyThreeInstance:IsA("BoolValue"), "Key3 must be a BoolValue")
	local keyTwo = keyTwoInstance :: BoolValue
	local keyThree = keyThreeInstance :: BoolValue
	local fuseFound = getOrCreateBoolValue(roundState, "B4FuseFound", false)
	local powerRestored = getOrCreateBoolValue(roundState, "B4PowerRestored", false)
	if keyThree.Value then
		fuseFound.Value = true
		powerRestored.Value = true
	end

	local remoteFolder = getOrCreateFolder(ReplicatedStorage, REMOTE_FOLDER_NAME)
	local feedback = makeRemote(remoteFolder, FEEDBACK_REMOTE_NAME)
	local fusePrompt = getOrCreatePrompt(fuse, FUSE_PROMPT_NAME, "Spare Fuse", config.b4InteractionRangeStuds)
	local generatorPrompt = getOrCreatePrompt(
		generator,
		GENERATOR_PROMPT_NAME,
		"B4 Generator",
		config.b4InteractionRangeStuds
	)

	local function respond(player: Player, code: string, detail: string?)
		feedback:FireClient(player, code, detail)
	end

	local function refreshState()
		local fuseVisible = not fuseFound.Value and not powerRestored.Value
		fuse.Transparency = if fuseVisible then 0 else 1
		fuse.CanCollide = false
		fuse.CanTouch = fuseVisible
		fuse.CanQuery = fuseVisible
		fusePrompt.Enabled = fuseVisible
		fusePrompt.ActionText = if keyTwo.Value then "Collect Fuse" else "Locked"

		generatorPrompt.Enabled = not powerRestored.Value
		generatorPrompt.ActionText = if not keyTwo.Value then "Locked" else if fuseFound.Value then "Restore Power" else "Find Fuse"
		indicator.Color = if powerRestored.Value then POWER_COLOR else OFF_COLOR
		indicator.Material = Enum.Material.Neon
		generator:SetAttribute("PowerRestored", powerRestored.Value)
		b4:SetAttribute("PowerRestored", powerRestored.Value)
		map:SetAttribute("B4PowerRestored", powerRestored.Value)
	end

	local function validateInteraction(player: Player, target: BasePart): boolean
		local character, root = getAliveCharacter(player)
		if not character or not root then
			respond(player, "B4Rejected", "Player is not alive")
			return false
		end
		if (root.Position - target.Position).Magnitude > config.b4InteractionRangeStuds then
			respond(player, "B4Rejected", "Move closer")
			return false
		end
		if not hasLineOfSight(character, root, target) then
			respond(player, "B4Blocked")
			return false
		end
		return true
	end

	fusePrompt.Triggered:Connect(function(player: Player)
		if not validateInteraction(player, fuse) then
			return
		end
		if not keyTwo.Value then
			respond(player, "B4Locked", "Complete the Library investigation first")
			return
		end
		if powerRestored.Value or fuseFound.Value then
			return
		end

		fuseFound.Value = true
		respond(player, "B4FuseCollected", "Install it at the generator")
		print(string.format("[FNABK][B4] %s collected the Spare Fuse", player.Name))
		refreshState()
	end)

	generatorPrompt.Triggered:Connect(function(player: Player)
		if not validateInteraction(player, generator) then
			return
		end
		if not keyTwo.Value then
			respond(player, "B4Locked", "Complete the Library investigation first")
			return
		end
		if powerRestored.Value then
			respond(player, "B4Complete", "Data Key 3 is already secured")
			return
		end
		if not fuseFound.Value then
			respond(player, "B4NeedFuse", "Find and collect the Spare Fuse first")
			return
		end

		fuseFound.Value = true
		powerRestored.Value = true
		keyThree.Value = true
		respond(player, "B4PowerRestored", "Data Key 3 collected")
		print(string.format("[FNABK][B4] %s restored generator power; Data Key 3 collected", player.Name))
		refreshState()
	end)

	keyTwo.Changed:Connect(refreshState)
	keyThree.Changed:Connect(function()
		if keyThree.Value then
			fuseFound.Value = true
			powerRestored.Value = true
		end
		refreshState()
	end)
	fuseFound.Changed:Connect(refreshState)
	powerRestored.Changed:Connect(refreshState)
	refreshState()
	print("[FNABK][B4] AC-08 first slice ready; Key 3 requires Key 2, fuse pickup and generator interaction")
end

return table.freeze(B4GeneratorService)
