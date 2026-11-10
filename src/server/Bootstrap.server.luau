--!strict
-- Starts the server-owned graybox and the A3, Library, B4, Gate and player-life slices.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("FNABKShared")
local config = require(shared:WaitForChild("GameConfig"))
local HostIdentity = require(script.Parent:WaitForChild("HostIdentity"))
local Players = game:GetService("Players")
local admitted: { [Player]: boolean } = {}
local function admit(player: Player)
	if admitted[player] then return end
	local count = 0
	local ownerPresent = false
	for member in pairs(admitted) do count += 1; if member.UserId == game.PrivateServerOwnerId then ownerPresent = true end end
	if not HostIdentity.canAdmit(count, config.maxPlayers, player.UserId, game.PrivateServerOwnerId, ownerPresent) then
		player:Kick("This run is full or the remaining place is reserved for its host.")
		return
	end
	admitted[player] = true
end
Players.PlayerAdded:Connect(admit)
Players.PlayerRemoving:Connect(function(player) admitted[player] = nil end)
for _, player in ipairs(Players:GetPlayers()) do admit(player) end

local server = script.Parent
local grayboxMap = require(server:WaitForChild("GrayboxMap"))
local campusGameplayAdapter = require(server:WaitForChild("CampusGameplayAdapter"))
local mimicController = require(server:WaitForChild("MimicController"))
local mimicAppearancePreview = require(server:WaitForChild("MimicAppearancePreview"))

local combatService = require(server:WaitForChild("CombatService"))
local uvService = require(server:WaitForChild("UVService"))
local scannerService = require(server:WaitForChild("ScannerService"))
local a3PuzzleService = require(server:WaitForChild("A3PuzzleService"))
local crateInteractionService = require(server:WaitForChild("CrateInteractionService"))
local libraryInvestigationService = require(server:WaitForChild("LibraryInvestigationService"))
local b4GeneratorService = require(server:WaitForChild("B4GeneratorService"))
local roundService = require(server:WaitForChild("RoundService"))
local playerLifeService = require(server:WaitForChild("PlayerLifeService"))
local medkitService = require(server:WaitForChild("MedkitService"))
local objectiveHintService = require(server:WaitForChild("ObjectiveHintService"))
local movementService = require(server:WaitForChild("MovementService"))
local baseService = require(server:WaitForChild("BaseService"))
local rescueObjectives = require(server:WaitForChild("RescueObjectives"))
local helicopterService = require(server:WaitForChild("HelicopterService"))
local waveService = require(server:WaitForChild("WaveService"))
local ambushCreature = require(server:WaitForChild("AmbushCreature"))
local patrolMachine = require(server:WaitForChild("PatrolMachine"))
local survivorHelp = require(server:WaitForChild("SurvivorHelp"))

local campus = Workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6")
assert(campus and campus:IsA("Model"), "Selected campus v6 is missing from Workspace")
local map, mimic, student = grayboxMap.Build(Workspace, config.mimicHealth)
campusGameplayAdapter.Place(map, campus)
task.spawn(function()
	-- ponytail: choose once at startup; replace with reviewed encounter rotation.
	task.wait(5)
	local characters = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then table.insert(characters, player.Character) end
	end
	local copy = if mimic:GetAttribute("MimicState") == "Disguise" and #characters >= 2 and math.random(2) == 1 then characters[math.random(1, #characters)] else nil
	if not mimicAppearancePreview.Attach(mimic, copy) and copy then mimicAppearancePreview.Attach(mimic) end
end)
local applyPlayerDamage: (Player, number) -> number? = function() return nil end
local gunshot = Instance.new("BindableEvent")
combatService.Start(map, mimic, config, function(player, amount) return applyPlayerDamage(player, amount) end)
uvService.Start(map, mimic, config)
scannerService.Start(map, config)
a3PuzzleService.Start(map, config)
crateInteractionService.Start(map, config)
libraryInvestigationService.Start(map, config)
b4GeneratorService.Start(map, config)
local waveEvents = Instance.new("BindableEvent")
waveEvents.Name, waveEvents.Parent = "SurvivalEvents", script
waveService.Start(map, waveEvents, function(player, amount) return applyPlayerDamage(player, amount) end, gunshot)
local signal, finish = roundService.Start(map, config, waveEvents)
assert(signal and finish, "Round already started")
survivorHelp.Start(map)
rescueObjectives.Start(campus, signal)
local phase = ReplicatedStorage.FNABKRoundState:WaitForChild("SurvivalPhase") :: StringValue
local depart, isAboard = helicopterService.Start(campus, phase, finish)
phase.Changed:Connect(function() if phase.Value == "Departed" then depart() end end)
baseService.Start(campus)
local onRespawn: (Player, Vector3) -> () = function() end
local playerLife = playerLifeService.Start(config, function(player, position) onRespawn(player, position) end, isAboard)
local lifeCapture = Instance.new("BindableFunction")
lifeCapture.Name, lifeCapture.Parent = "PartialLifeSnapshot", script
lifeCapture.OnInvoke = playerLife.Snapshot
applyPlayerDamage = playerLife.ApplyDamage
movementService.Start(config)
local snapshotSupplies
onRespawn, snapshotSupplies = medkitService.Start(map, config, playerLife.ApplyDamage, gunshot, waveEvents)
-- ponytail: partial server-only capture; replace with the complete, validated world-save coordinator.
local suppliesCapture = Instance.new("BindableFunction")
suppliesCapture.Name, suppliesCapture.Parent = "PartialSuppliesSnapshot", script
suppliesCapture.OnInvoke = snapshotSupplies
objectiveHintService.Start(config)
mimicController.Start(mimic, config, playerLife.ApplyDamage, gunshot)
-- ponytail: one early-route encounter; replace after encounter placement review.
local spawn = map:FindFirstChild("PlayerSpawn")
if spawn and spawn:IsA("BasePart") then
	local params = RaycastParams.new()
	params.RespectCanCollide = true
	local hit = Workspace:Raycast(spawn.Position + Vector3.new(30, 10, 0), Vector3.new(0, -30, 0), params)
	if hit then
		local position = hit.Position + Vector3.new(0, 1.6, 0)
		local overlap = OverlapParams.new()
		overlap.RespectCanCollide = true
		if #Workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(2, 3, 2), overlap) == 0 then
			ambushCreature.Start(map, position, playerLife.ApplyDamage, gunshot, ReplicatedStorage.FNABKRemotes.WaveNotice, ReplicatedStorage.FNABKRoundState.RoundStatus)
		end
	end
	for _, offset in ipairs({ Vector3.new(0, 0, 45), Vector3.new(0, 0, -45), Vector3.new(45, 0, 0), Vector3.new(-45, 0, 0) }) do
		local machineHit = Workspace:Raycast(spawn.Position + offset + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0), params)
		if not machineHit then continue end
		local position = machineHit.Position + Vector3.new(0, 2.1, 0)
		local overlap = OverlapParams.new()
		overlap.RespectCanCollide = true
		if #Workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(2, 4, 2), overlap) == 0 then
			patrolMachine.Start(map, position, playerLife.ApplyDamage, gunshot, ReplicatedStorage.FNABKRemotes.WaveNotice, ReplicatedStorage.FNABKRoundState.RoundStatus)
			break
		end
	end
end

print(string.format("[FNABK] Campus v6 ready; A3, Library, B4, Gate and revive slices enabled; design round=%ds", config.roundDurationSeconds))
