--!strict
-- AC-07: server-owned Library interviews, evidence and Key 2 accusation.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

type LibraryConfig = {
	libraryInteractionRangeStuds: number,
}

type SuspectRecord = {
	id: string,
	model: Model,
	anchor: BasePart,
	prompt: ProximityPrompt,
	interviewed: BoolValue,
	firstClue: string,
}

local REMOTE_FOLDER_NAME = "FNABKRemotes"
local LIBRARY_FEEDBACK_NAME = "LibraryFeedback"
local LIBRARY_STATE_NAME = "LibraryInvestigation"
local PROMPT_NAME = "LibraryInvestigationPrompt"

local LibraryInvestigationService = {}
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

local function hasLineOfSight(character: Model, root: BasePart, target: Model, anchor: BasePart): boolean
	local origin = root.Position + Vector3.new(0, 1.5, 0)
	local direction = anchor.Position - origin
	if direction.Magnitude <= 0.05 then
		return true
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = true

	local result = Workspace:Raycast(origin, direction, raycastParams)
	return result ~= nil and result.Instance:IsDescendantOf(target)
end

local function getOrCreatePrompt(anchor: BasePart, maxDistance: number, objectText: string): ProximityPrompt
	local existing = anchor:FindFirstChild(PROMPT_NAME)
	if existing then
		assert(existing:IsA("ProximityPrompt"), PROMPT_NAME .. " must be a ProximityPrompt")
	else
		existing = Instance.new("ProximityPrompt")
		existing.Name = PROMPT_NAME
		existing.Parent = anchor
	end

	local prompt = existing :: ProximityPrompt
	prompt.ActionText = "Interview"
	prompt.ObjectText = objectText
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = maxDistance
	prompt.RequiresLineOfSight = true
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	return prompt
end

function LibraryInvestigationService.Start(map: Folder, config: LibraryConfig)
	if started then
		return
	end
	started = true

	local library = map:FindFirstChild("Library")
	assert(library and library:IsA("Folder"), "Graybox is missing Library")
	local suspectsFolder = library:FindFirstChild("Suspects")
	assert(suspectsFolder and suspectsFolder:IsA("Folder"), "Library is missing Suspects")

	local roundStateInstance = ReplicatedStorage:WaitForChild("FNABKRoundState")
	assert(roundStateInstance:IsA("Folder"), "FNABKRoundState must be a Folder")
	local roundState = roundStateInstance :: Folder
	local dataKeys = roundState:WaitForChild("DataKeys")
	assert(dataKeys:IsA("Folder"), "DataKeys must be a Folder")
	local keyOneInstance = dataKeys:WaitForChild("Key1")
	local keyTwoInstance = dataKeys:WaitForChild("Key2")
	assert(keyOneInstance:IsA("BoolValue"), "Key1 must be a BoolValue")
	assert(keyTwoInstance:IsA("BoolValue"), "Key2 must be a BoolValue")
	local keyOne = keyOneInstance :: BoolValue
	local keyTwo = keyTwoInstance :: BoolValue

	local libraryState = getOrCreateFolder(roundState, LIBRARY_STATE_NAME)
	local interviewedA = getOrCreateBoolValue(libraryState, "StudentAInterviewed", false)
	local interviewedB = getOrCreateBoolValue(libraryState, "StudentBInterviewed", false)
	local interviewedMimic = getOrCreateBoolValue(libraryState, "MimicInterviewed", false)
	local mimicCluesFound = getOrCreateIntValue(libraryState, "MimicCluesFound", 0)
	local feedback = makeRemote(getOrCreateFolder(ReplicatedStorage, REMOTE_FOLDER_NAME), LIBRARY_FEEDBACK_NAME)

	local definitions = {
		{
			id = "StudentA",
			modelName = "LibraryStudentA",
			objectText = "Library Student A",
			firstClue = "ID BK-041 matches her answer: she is reviewing circuits in A3.",
			interviewed = interviewedA,
		},
		{
			id = "Mimic",
			modelName = "LibraryMimic",
			objectText = "Library Student B",
			firstClue = "Badge BK-017 conflicts with the ID he gives: BK-071.",
			interviewed = interviewedMimic,
		},
		{
			id = "StudentB",
			modelName = "LibraryStudentB",
			objectText = "Library Student C",
			firstClue = "ID BK-052 matches his answer: he is waiting for his lab partner.",
			interviewed = interviewedB,
		},
	}
	local suspects: { SuspectRecord } = {}
	for _, definition in ipairs(definitions) do
		local modelInstance = suspectsFolder:FindFirstChild(definition.modelName)
		assert(modelInstance and modelInstance:IsA("Model"), definition.modelName .. " is missing")
		local model = modelInstance :: Model
		assert(model:GetAttribute("LibrarySuspectId") == definition.id, definition.modelName .. " has the wrong suspect ID")
		local anchorInstance = model:FindFirstChild("Head") or model.PrimaryPart
		assert(anchorInstance and anchorInstance:IsA("BasePart"), definition.modelName .. " has no prompt anchor")
		local anchor = anchorInstance :: BasePart
		local prompt = getOrCreatePrompt(anchor, config.libraryInteractionRangeStuds, definition.objectText)
		table.insert(suspects, {
			id = definition.id,
			model = model,
			anchor = anchor,
			prompt = prompt,
			interviewed = definition.interviewed,
			firstClue = definition.firstClue,
		})
	end

	local function canIdentifyMimic(): boolean
		return interviewedA.Value and interviewedB.Value and interviewedMimic.Value and mimicCluesFound.Value >= 2
	end

	local function updatePrompts()
		for _, suspect in ipairs(suspects) do
			suspect.prompt.Enabled = not keyTwo.Value
			suspect.prompt.ActionText = if keyOne.Value and canIdentifyMimic() then "Accuse" else "Interview"
			if not keyOne.Value then
				suspect.prompt.ActionText = "Locked"
			end
		end
	end

	local function respond(player: Player, code: string, detail: string?)
		feedback:FireClient(player, code, detail)
	end

	for _, suspect in ipairs(suspects) do
		suspect.prompt.Triggered:Connect(function(player: Player)
			local character, root = getAliveCharacter(player)
			if not character or not root then
				respond(player, "LibraryRejected", "Player is not alive")
				return
			end
			if (root.Position - suspect.anchor.Position).Magnitude > config.libraryInteractionRangeStuds then
				respond(player, "LibraryRejected", "Move closer to the NPC")
				return
			end
			if not hasLineOfSight(character, root, suspect.model, suspect.anchor) then
				respond(player, "LibraryBlocked")
				return
			end
			if not keyOne.Value then
				respond(player, "LibraryLocked", "Restore A3 power first")
				return
			end
			if keyTwo.Value then
				respond(player, "LibraryComplete", "Data Key 2 is already secured")
				return
			end

			if suspect.id == "Mimic" then
				if not interviewedMimic.Value then
					interviewedMimic.Value = true
					mimicCluesFound.Value = 1
					respond(player, "LibraryClue", suspect.firstClue)
				elseif mimicCluesFound.Value < 2 then
					mimicCluesFound.Value = 2
					respond(player, "LibraryClue", "He repeats his greeting, then gives a different class section when asked again.")
				elseif canIdentifyMimic() then
					keyTwo.Value = true
					libraryState:SetAttribute("MimicIdentified", true)
					map:SetAttribute("LibraryMimicIdentified", true)
					respond(player, "LibraryMimicIdentified", "Data Key 2 collected")
					print(string.format("[FNABK][Library] %s identified the Mimic; Data Key 2 collected", player.Name))
				else
					respond(player, "LibraryNeedEvidence", "Interview all three; the badge and class-section clues are recorded")
				end
			else
				if not suspect.interviewed.Value then
					suspect.interviewed.Value = true
					respond(player, "LibraryClue", suspect.firstClue)
				elseif canIdentifyMimic() then
					respond(player, "LibraryWrongAccusation", "This student's ID and answer are consistent")
				else
					respond(player, "LibraryClue", suspect.firstClue)
				end
			end

			updatePrompts()
		end)
	end

	keyOne.Changed:Connect(updatePrompts)
	keyTwo.Changed:Connect(updatePrompts)
	updatePrompts()
	print("[FNABK][Library] AC-07 investigation ready; Key 2 requires three interviews, two Mimic clues and correct accusation")
end

return table.freeze(LibraryInvestigationService)
