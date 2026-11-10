--!strict
-- AC-01/AC-04/AC-05/AC-07/AC-08 client slice: send intent and render server-owned feedback.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("FNABKRemotes")
local attackRequest = remotes:WaitForChild("AttackRequest") :: RemoteEvent
local attackFeedback = remotes:WaitForChild("AttackFeedback") :: RemoteEvent
local uvRequest = remotes:WaitForChild("UVRequest") :: RemoteEvent
local uvFeedback = remotes:WaitForChild("UVFeedback") :: RemoteEvent
local scannerRequest = remotes:WaitForChild("ScannerRequest") :: RemoteEvent
local scannerFeedback = remotes:WaitForChild("ScannerFeedback") :: RemoteEvent
local libraryFeedback = remotes:WaitForChild("LibraryFeedback") :: RemoteEvent
local b4Feedback = remotes:WaitForChild("B4Feedback") :: RemoteEvent
local gateFeedback = remotes:WaitForChild("GateFeedback") :: RemoteEvent
local reviveFeedback = remotes:WaitForChild("ReviveFeedback") :: RemoteEvent
local medkitFeedback = remotes:WaitForChild("MedkitFeedback") :: RemoteEvent
local medkitRequest = remotes:WaitForChild("MedkitRequest") :: RemoteEvent
local objectiveHint = remotes:WaitForChild("ObjectiveHint") :: RemoteEvent
local movementRequest = remotes:WaitForChild("MovementRequest") :: RemoteEvent

local FEEDBACK: { [string]: { text: string, color: Color3 } } = {
	Hit = { text = "BATON HIT", color = Color3.fromRGB(140, 220, 180) },
	FriendlyHit = { text = "TEAMMATE HIT", color = Color3.fromRGB(255, 170, 110) },
	Defeated = { text = "MIMIC DEFEATED", color = Color3.fromRGB(140, 220, 180) },
	WrongfulHit = { text = "WRONGFUL HIT", color = Color3.fromRGB(240, 155, 105) },
	Miss = { text = "BATON MISS", color = Color3.fromRGB(210, 220, 230) },
	OutOfRange = { text = "OUT OF RANGE", color = Color3.fromRGB(240, 195, 100) },
	Blocked = { text = "LINE OF SIGHT BLOCKED", color = Color3.fromRGB(240, 195, 100) },
	NoBaton = { text = "EQUIP BATON (KEY 1)", color = Color3.fromRGB(240, 195, 100) },
	Rejected = { text = "ATTACK REJECTED", color = Color3.fromRGB(240, 130, 130) },
	UVStunned = { text = "MIMIC STUNNED", color = Color3.fromRGB(145, 200, 255) },
	UVAlreadyStunned = { text = "MIMIC ALREADY STUNNED", color = Color3.fromRGB(145, 200, 255) },
	UVNoDevice = { text = "UV DEVICE MISSING", color = Color3.fromRGB(240, 195, 100) },
	UVOutOfRange = { text = "UV OUT OF RANGE", color = Color3.fromRGB(240, 195, 100) },
	UVBlocked = { text = "UV LINE OF SIGHT BLOCKED", color = Color3.fromRGB(240, 195, 100) },
	UVMiss = { text = "UV MISS", color = Color3.fromRGB(210, 220, 230) },
	UVCooldown = { text = "UV RECHARGING", color = Color3.fromRGB(210, 220, 230) },
	UVRejected = { text = "UV REQUEST REJECTED", color = Color3.fromRGB(240, 130, 130) },
	ScanStarted = { text = "SCANNING NPC", color = Color3.fromRGB(145, 200, 255) },
	ScanAnomaly = { text = "ANOMALY SUSPECTED", color = Color3.fromRGB(240, 195, 100) },
	ScanClear = { text = "NO ANOMALY FOUND", color = Color3.fromRGB(140, 220, 180) },
	ScanNoScanner = { text = "SCANNER MISSING", color = Color3.fromRGB(240, 195, 100) },
	ScanOutOfRange = { text = "SCANNER OUT OF RANGE", color = Color3.fromRGB(240, 195, 100) },
	ScanBlocked = { text = "SCANNER LINE OF SIGHT BLOCKED", color = Color3.fromRGB(240, 195, 100) },
	ScanInterrupted = { text = "SCAN INTERRUPTED", color = Color3.fromRGB(240, 195, 100) },
	ScanMiss = { text = "SCANNER MISS", color = Color3.fromRGB(210, 220, 230) },
	ScanCooldown = { text = "SCANNER RECHARGING", color = Color3.fromRGB(210, 220, 230) },
	ScanRejected = { text = "SCAN REQUEST REJECTED", color = Color3.fromRGB(240, 130, 130) },
	LibraryLocked = { text = "LIBRARY LOCKED", color = Color3.fromRGB(240, 195, 100) },
	LibraryClue = { text = "EVIDENCE", color = Color3.fromRGB(145, 200, 255) },
	LibraryNeedEvidence = { text = "MORE EVIDENCE NEEDED", color = Color3.fromRGB(240, 195, 100) },
	LibraryWrongAccusation = { text = "NO ANOMALY FOUND", color = Color3.fromRGB(240, 195, 100) },
	LibraryMimicIdentified = { text = "MIMIC IDENTIFIED", color = Color3.fromRGB(140, 220, 180) },
	LibraryComplete = { text = "LIBRARY COMPLETE", color = Color3.fromRGB(140, 220, 180) },
	LibraryBlocked = { text = "NPC NOT VISIBLE", color = Color3.fromRGB(240, 195, 100) },
	LibraryRejected = { text = "INTERACTION REJECTED", color = Color3.fromRGB(240, 130, 130) },
	B4Locked = { text = "B4 LOCKED", color = Color3.fromRGB(240, 195, 100) },
	B4FuseCollected = { text = "FUSE COLLECTED", color = Color3.fromRGB(145, 200, 255) },
	B4NeedFuse = { text = "GENERATOR NEEDS FUSE", color = Color3.fromRGB(240, 195, 100) },
	B4PowerRestored = { text = "B4 POWER RESTORED", color = Color3.fromRGB(140, 220, 180) },
	B4Complete = { text = "B4 COMPLETE", color = Color3.fromRGB(140, 220, 180) },
	B4Blocked = { text = "GENERATOR NOT VISIBLE", color = Color3.fromRGB(240, 195, 100) },
	B4Rejected = { text = "B4 INTERACTION REJECTED", color = Color3.fromRGB(240, 130, 130) },
	GateLocked = { text = "GATE LOCKED", color = Color3.fromRGB(240, 195, 100) },
	GateHoldCancelled = { text = "GATE HOLD CANCELLED", color = Color3.fromRGB(240, 195, 100) },
	GateOpened = { text = "GATE 1 OPEN", color = Color3.fromRGB(140, 220, 180) },
	GateRejected = { text = "GATE INTERACTION REJECTED", color = Color3.fromRGB(240, 130, 130) },
	RoundWon = { text = "GROUP RESCUE", color = Color3.fromRGB(140, 220, 180) },
	RoundLost = { text = "RUN FAILED", color = Color3.fromRGB(240, 130, 130) },
	Downed = { text = "DOWNED", color = Color3.fromRGB(255, 205, 130) },
	Eliminated = { text = "ELIMINATED", color = Color3.fromRGB(240, 130, 130) },
	ReviveCancelled = { text = "REVIVE CANCELLED", color = Color3.fromRGB(240, 195, 100) },
	ReviveRejected = { text = "REVIVE REJECTED", color = Color3.fromRGB(240, 130, 130) },
	ReviveSuccess = { text = "TEAMMATE REVIVED", color = Color3.fromRGB(140, 220, 180) },
	YouWereRevived = { text = "YOU WERE REVIVED", color = Color3.fromRGB(140, 220, 180) },
	MedkitPickedUp = { text = "MEDKIT COLLECTED", color = Color3.fromRGB(140, 220, 180) },
	SupplyPickedUp = { text = "SUPPLY COLLECTED", color = Color3.fromRGB(140, 220, 180) },
	SupplyTaken = { text = "SUPPLY ALREADY TAKEN", color = Color3.fromRGB(240, 195, 100) },
	MedkitUsed = { text = "MEDKIT USED", color = Color3.fromRGB(140, 220, 180) },
	MedkitFull = { text = "INVENTORY FULL", color = Color3.fromRGB(240, 195, 100) },
	MedkitNoItem = { text = "NO MEDKIT", color = Color3.fromRGB(240, 195, 100) },
	MedkitFullHealth = { text = "HEALTH ALREADY FULL", color = Color3.fromRGB(240, 195, 100) },
	MedkitRejected = { text = "MEDKIT UNAVAILABLE", color = Color3.fromRGB(240, 130, 130) },
	QuestComplete = { text = "SURVIVOR HELPED", color = Color3.fromRGB(140, 220, 180) },
	QuestUnavailable = { text = "REQUEST UNAVAILABLE", color = Color3.fromRGB(240, 195, 100) },
	ObjectiveHint = { text = "HINT", color = Color3.fromRGB(145, 200, 255) },
}

local function createFeedbackLabel(): TextLabel
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local existingGui = playerGui:FindFirstChild("FNABKCombatFeedback")
	if existingGui then
		local existingLabel = existingGui:FindFirstChild("Message")
		if existingLabel and existingLabel:IsA("TextLabel") then
			return existingLabel
		end
		existingGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FNABKCombatFeedback"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "Message"
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 0.88, 0)
	label.Size = UDim2.fromOffset(370, 46)
	label.BackgroundColor3 = Color3.fromRGB(19, 36, 55)
	label.BackgroundTransparency = 0.15
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.TextStrokeTransparency = 0.7
	label.Visible = false
	label.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	return label
end

local feedbackLabel = createFeedbackLabel()
local feedbackVersion = 0

local roundState = ReplicatedStorage:WaitForChild("FNABKRoundState")
local roundStatus = roundState:WaitForChild("RoundStatus") :: StringValue
local roundTimeRemaining = roundState:WaitForChild("RoundTimeRemaining") :: IntValue
local survivalDay = roundState:WaitForChild("SurvivalDay") :: IntValue
local survivalPhase = roundState:WaitForChild("SurvivalPhase") :: StringValue

local function createRoundHud(): TextLabel
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local existingGui = playerGui:FindFirstChild("FNABKRoundHUD")
	if existingGui then
		local existingLabel = existingGui:FindFirstChild("Status")
		if existingLabel and existingLabel:IsA("TextLabel") then
			return existingLabel
		end
		existingGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FNABKRoundHUD"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "Status"
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0, 8)
	label.Size = UDim2.fromOffset(470, 38)
	label.BackgroundColor3 = Color3.fromRGB(19, 36, 55)
	label.BackgroundTransparency = 0.15
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.TextStrokeTransparency = 0.7
	label.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	return label
end

local roundHud = createRoundHud()
local objectiveHud = roundHud:Clone()
objectiveHud.Name = "Objective"
objectiveHud.Position = UDim2.new(0.5, 0, 0, 48)
objectiveHud.Size = UDim2.fromOffset(470, 30)
objectiveHud.Parent = roundHud.Parent
local objectives: Folder? = nil

local trustHud = roundHud:Clone()
trustHud.Name = "Trust"
trustHud.AnchorPoint = Vector2.new(1, 0)
trustHud.Position = UDim2.new(1, -12, 0, 92)
trustHud.Size = UDim2.fromOffset(190, 32)
trustHud.Text = "TRUST —"
trustHud.Parent = roundHud.Parent
task.spawn(function()
	local trust = roundState:WaitForChild("Trust") :: IntValue
	local function refreshTrust()
		local tier = if trust.Value >= 70 then "NORMAL" elseif trust.Value >= 30 then "WARY" else "NO TRADE"
		trustHud.Text = string.format("TRUST %d | %s", trust.Value, tier)
	end
	trust.Changed:Connect(refreshTrust)
	refreshTrust()
end)

local medkitHud = Instance.new("TextLabel")
medkitHud.Name = "MedkitStatus"
medkitHud.AnchorPoint = Vector2.new(1, 0)
medkitHud.Position = UDim2.new(1, -12, 0, 12)
medkitHud.Size = UDim2.fromOffset(190, 32)
medkitHud.BackgroundColor3 = Color3.fromRGB(19, 36, 55)
medkitHud.BackgroundTransparency = 0.15
medkitHud.BorderSizePixel = 0
medkitHud.Font = Enum.Font.GothamBold
medkitHud.TextColor3 = Color3.new(1, 1, 1)
medkitHud.TextScaled = true
medkitHud.Parent = roundHud.Parent
local function refreshMedkitHud()
	local count = localPlayer:GetAttribute("FNABKMedkitCount") or 0
	medkitHud.Text = if count > 0 then string.format("MEDKIT: %d | R", count) else "MEDKIT: 0"
end
localPlayer:GetAttributeChangedSignal("FNABKMedkitCount"):Connect(refreshMedkitHud)
refreshMedkitHud()

local staminaHud = Instance.new("TextLabel")
staminaHud.Name = "StaminaStatus"
staminaHud.AnchorPoint = Vector2.new(0, 1)
staminaHud.Position = UDim2.new(0, 12, 1, -74)
staminaHud.Size = UDim2.fromOffset(190, 32)
staminaHud.BackgroundColor3 = Color3.fromRGB(19, 36, 55)
staminaHud.BackgroundTransparency = 0.15
staminaHud.BorderSizePixel = 0
staminaHud.Font = Enum.Font.GothamBold
staminaHud.TextColor3 = Color3.new(1, 1, 1)
staminaHud.TextScaled = true
staminaHud.Parent = roundHud.Parent
local function refreshStaminaHud()
	local stamina = localPlayer:GetAttribute("FNABKStamina")
	staminaHud.Text = string.format("STAMINA %d/100%s", if typeof(stamina) == "number" then stamina else 100,
		if localPlayer:GetAttribute("FNABKCrouching") == true then " | CROUCH" else "")
end
localPlayer:GetAttributeChangedSignal("FNABKStamina"):Connect(refreshStaminaHud)
localPlayer:GetAttributeChangedSignal("FNABKCrouching"):Connect(refreshStaminaHud)
refreshStaminaHud()

local crouchRequested = false
local leftShiftHeld = false
local rightShiftHeld = false
local function clearMovementInput()
	leftShiftHeld = false
	rightShiftHeld = false
	crouchRequested = false
	movementRequest:FireServer("Sprint", false)
	movementRequest:FireServer("Crouch", false)
end
UserInputService.WindowFocusReleased:Connect(clearMovementInput)
localPlayer.CharacterAdded:Connect(clearMovementInput)
localPlayer:GetAttributeChangedSignal("FNABKDowned"):Connect(function()
	if localPlayer:GetAttribute("FNABKDowned") == true then clearMovementInput() end
end)
localPlayer:GetAttributeChangedSignal("FNABKEliminated"):Connect(function()
	if localPlayer:GetAttribute("FNABKEliminated") == true then clearMovementInput() end
end)

local function refreshRoundHud()
	local seconds = math.max(0, roundTimeRemaining.Value)
	local timeText = string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
	local function complete(name: string): boolean
		local value = objectives and objectives:FindFirstChild(name)
		return value ~= nil and value:IsA("BoolValue") and value.Value
	end
	local count = (if complete("Power") then 1 else 0)
		+ (if complete("Frequency") then 1 else 0)
		+ (if complete("Transmitter") then 1 else 0)
	local result = localPlayer:GetAttribute("FNABKRescueResult")
	local terminal = roundStatus.Value == "Won" or roundStatus.Value == "Lost"
	local objectiveText = if terminal and result == "Rescued"
		then "YOU WERE RESCUED"
		elseif terminal and result == "LeftBehind"
		then "YOU WERE LEFT BEHIND"
		elseif terminal and result == "Eliminated"
		then "YOU WERE ELIMINATED"
		elseif roundStatus.Value == "Won"
		then "GROUP RESCUED — CHECKING YOUR RESULT"
		elseif roundStatus.Value == "Lost"
		then "RUN FAILED"
		elseif roundStatus.Value == "Waiting"
		then "WAITING FOR THE RUN"
		elseif localPlayer:GetAttribute("FNABKDowned") == true
		then "DOWNED — WAIT FOR A TEAMMATE"
		elseif localPlayer:GetAttribute("FNABKEliminated") == true
		then "ELIMINATED"
		elseif survivalPhase.Value == "Boarding"
		then "BOARD THE HELICOPTER AT THE SPORTS FIELD"
		elseif survivalPhase.Value == "RescueWait"
		then "REACH THE SPORTS FIELD — HELICOPTER APPROACHING"
		elseif complete("SignalSent")
		then "SIGNAL SENT — SURVIVE THROUGH NIGHT 5"
		elseif not objectives
		then "LOCATING RESCUE STATIONS"
		elseif count == 3
		then "RETURN TO THE TRANSMITTER AND SEND THE SIGNAL [G]"
		else string.format("RESCUE STATIONS %d/3 — OPEN MAP [M]", count)
	roundHud.Text = string.format("DAY %d   |   %s   |   %s", survivalDay.Value, string.upper(survivalPhase.Value), timeText)
	objectiveHud.Text = objectiveText
	if terminal and (result == "LeftBehind" or result == "Eliminated") then
		roundHud.TextColor3 = Color3.fromRGB(240, 130, 130)
	elseif roundStatus.Value == "Won" then
		roundHud.TextColor3 = Color3.fromRGB(140, 220, 180)
	elseif roundStatus.Value == "Lost" then
		roundHud.TextColor3 = Color3.fromRGB(240, 130, 130)
	elseif localPlayer:GetAttribute("FNABKDowned") == true then
		roundHud.TextColor3 = Color3.fromRGB(255, 205, 130)
	elseif localPlayer:GetAttribute("FNABKEliminated") == true then
		roundHud.TextColor3 = Color3.fromRGB(240, 130, 130)
	else
		roundHud.TextColor3 = Color3.new(1, 1, 1)
	end
end

roundStatus.Changed:Connect(refreshRoundHud)
roundTimeRemaining.Changed:Connect(refreshRoundHud)
survivalDay.Changed:Connect(refreshRoundHud)
survivalPhase.Changed:Connect(refreshRoundHud)
localPlayer:GetAttributeChangedSignal("FNABKDowned"):Connect(refreshRoundHud)
localPlayer:GetAttributeChangedSignal("FNABKEliminated"):Connect(refreshRoundHud)
localPlayer:GetAttributeChangedSignal("FNABKRescueResult"):Connect(refreshRoundHud)
refreshRoundHud()
task.spawn(function()
	local folder = roundState:WaitForChild("RescueObjectives") :: Folder
	objectives = folder
	for _, name in ipairs({ "Power", "Frequency", "Transmitter", "SignalSent" }) do
		folder:WaitForChild(name).Changed:Connect(refreshRoundHud)
	end
	refreshRoundHud()
end)

local function hideOwnRevivePrompt(instance: Instance)
	if instance:IsA("ProximityPrompt") and instance.Name == "FNABKRevivePrompt" then
		instance.Enabled = false
	end
end

local function watchOwnCharacter(character: Model)
	for _, descendant in ipairs(character:GetDescendants()) do
		hideOwnRevivePrompt(descendant)
	end
	character.DescendantAdded:Connect(hideOwnRevivePrompt)
end

localPlayer.CharacterAdded:Connect(watchOwnCharacter)
if localPlayer.Character then
	watchOwnCharacter(localPlayer.Character)
end

local function displayFeedback(code: string, detail: string?)
	local definition = FEEDBACK[code] or FEEDBACK.Rejected
	feedbackVersion += 1
	local thisVersion = feedbackVersion
	local isClue = code == "LibraryClue" or code == "ObjectiveHint"
	feedbackLabel.Size = if isClue then UDim2.fromOffset(620, 76) else UDim2.fromOffset(370, 46)
	feedbackLabel.Text = if detail and detail ~= "" then definition.text .. "  |  " .. detail else definition.text
	feedbackLabel.TextColor3 = definition.color
	feedbackLabel.Visible = true

	local isRoundResult = code == "RoundWon" or code == "RoundLost"
	task.delay(if isClue or isRoundResult then 5 else 1.6, function()
		if feedbackVersion == thisVersion and feedbackLabel.Parent then
			feedbackLabel.Visible = false
		end
	end)
end

local function equippedBaton(): boolean
	local character = localPlayer.Character
	local baton = character and character:FindFirstChild("Baton")
	return baton ~= nil and baton:IsA("Tool")
end

local function getAimedNpc(includePlayers: boolean?): Model?
	local camera = Workspace.CurrentCamera
	if not camera then
		return nil
	end

	local mousePosition = UserInputService:GetMouseLocation()
	local unitRay = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = if localPlayer.Character then { localPlayer.Character } else {}
	raycastParams.IgnoreWater = true

	local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 250, raycastParams)
	if not result then
		return nil
	end

	local instance: Instance? = result.Instance
	while instance and instance ~= Workspace do
		if instance:IsA("Model") then
			if includePlayers and Players:GetPlayerFromCharacter(instance) then return instance end
			local npcType = instance:GetAttribute("NPCType")
			if npcType == "Mimic" or npcType == "Student" then
				return instance
			end
		end
		instance = instance.Parent
	end
	return nil
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if equippedBaton() then
			-- This is only target intent. The server rechecks target, range, LOS and cooldown.
			attackRequest:FireServer(getAimedNpc(true))
		end
	elseif input.KeyCode == Enum.KeyCode.F then
		-- UV uses the same target-intent pattern; the server owns the stun and its duration.
		uvRequest:FireServer(getAimedNpc())
	elseif input.KeyCode == Enum.KeyCode.Q then
		-- Scanner sends only the aimed NPC; the server owns scan duration and classification.
		scannerRequest:FireServer(getAimedNpc())
	elseif input.KeyCode == Enum.KeyCode.R then
		medkitRequest:FireServer()
	elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		if input.KeyCode == Enum.KeyCode.LeftShift then leftShiftHeld = true else rightShiftHeld = true end
		movementRequest:FireServer("Sprint", true)
	elseif input.KeyCode == Enum.KeyCode.C then
		crouchRequested = not crouchRequested
		movementRequest:FireServer("Crouch", crouchRequested)
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
	if input.KeyCode == Enum.KeyCode.LeftShift then leftShiftHeld = false
	elseif input.KeyCode == Enum.KeyCode.RightShift then rightShiftHeld = false
	else return end
	movementRequest:FireServer("Sprint", leftShiftHeld or rightShiftHeld)
end)

attackFeedback.OnClientEvent:Connect(function(code: string, detail: string?)
	if code == "Cooldown" then return end
	displayFeedback(code, detail)
end)

uvFeedback.OnClientEvent:Connect(function(code: string, detail: string?)
	displayFeedback(code, detail)
end)

scannerFeedback.OnClientEvent:Connect(function(code: string, detail: string?)
	displayFeedback(code, detail)
end)

libraryFeedback.OnClientEvent:Connect(function(code: string, detail: string?)
	displayFeedback(code, detail)
end)

b4Feedback.OnClientEvent:Connect(function(code: string, detail: string?)
	displayFeedback(code, detail)
end)

gateFeedback.OnClientEvent:Connect(function(code: string, detail: string?)
	displayFeedback(code, detail)
end)

reviveFeedback.OnClientEvent:Connect(function(code: string, detail: string?)
	displayFeedback(code, detail)
end)

medkitFeedback.OnClientEvent:Connect(function(code: string, detail: string?)
	displayFeedback(code, detail)
end)

objectiveHint.OnClientEvent:Connect(function(detail: string)
	displayFeedback("ObjectiveHint", detail)
end)

print("[FNABK] Round HUD, Gate/revive feedback, Baton, UV, Scanner, Library and B4 ready")
