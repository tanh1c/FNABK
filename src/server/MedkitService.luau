--!strict
-- AC-01/AC-02/AC-09: server-owned pickup, inventory and healing.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local layout = require(ReplicatedStorage:WaitForChild("FNABKShared"):WaitForChild("CampusLayout"))
local Inventory = require(script.Parent:WaitForChild("Inventory"))
local Needs = require(script.Parent:WaitForChild("Needs"))
local SessionSupplies = require(script.Parent:WaitForChild("SessionSupplies"))
local Firearm = require(script.Parent:WaitForChild("Firearm"))
local DailySupply = require(script.Parent:WaitForChild("DailySupply"))
local SurvivorTrade = require(script.Parent:WaitForChild("SurvivorTrade"))

type MedkitConfig = {
	medkitHealAmount: number,
	medkitPickupRangeStuds: number,
}

local MedkitService = {}

local function activeCharacter(player: Player): (Model?, Humanoid?, BasePart?)
	local character = player.Character
	if not character or player:GetAttribute("FNABKDowned") == true
		or player:GetAttribute("FNABKEliminated") == true
		or character:GetAttribute("FNABKDowned") == true
		or character:GetAttribute("FNABKEliminated") == true then
		return nil, nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil, nil, nil
	end
	return character, humanoid, root
end

local SurvivorHealth = require(script.Parent:WaitForChild("SurvivorHealth"))
local SurvivorDefense = require(script.Parent:WaitForChild("SurvivorDefense"))
local SurvivorHelp = require(script.Parent:WaitForChild("SurvivorHelp"))
local BasePower = require(script.Parent:WaitForChild("BasePower"))
local Barricade = require(script.Parent:WaitForChild("Barricade"))
local BagLocation = require(script.Parent:WaitForChild("BagLocation"))
local EnemyHealth = require(script.Parent:WaitForChild("EnemyHealth"))

function MedkitService.Start(map: Folder, config: MedkitConfig, applyDamage: (Player, number, boolean?) -> number?, gunshot: BindableEvent, dayEvents: BindableEvent)
	local remotes = ReplicatedStorage:WaitForChild("FNABKRemotes")
	local roundState = ReplicatedStorage:WaitForChild("FNABKRoundState")
	local roundStatus = roundState:WaitForChild("RoundStatus") :: StringValue
	local request = Instance.new("RemoteEvent")
	request.Name = "MedkitRequest"
	request.Parent = remotes
	local feedback = Instance.new("RemoteEvent")
	feedback.Name = "MedkitFeedback"
	feedback.Parent = remotes
	local inventorySnapshot = Instance.new("RemoteEvent")
	inventorySnapshot.Name = "InventorySnapshot"
	inventorySnapshot.Parent = remotes
	local inventorySync = Instance.new("RemoteEvent")
	inventorySync.Name = "InventorySync"
	inventorySync.Parent = remotes
	local consume = Instance.new("RemoteEvent")
	consume.Name = "ConsumeRequest"
	consume.Parent = remotes
	local share = Instance.new("RemoteEvent")
	share.Name = "ShareRequest"
	share.Parent = remotes
	local shareFeedback = Instance.new("RemoteEvent")
	shareFeedback.Name = "ShareFeedback"
	shareFeedback.Parent = remotes
	local gunRequest = Instance.new("RemoteEvent")
	gunRequest.Name, gunRequest.Parent = "PistolRequest", remotes
	local storageRemote = Instance.new("RemoteEvent")
	storageRemote.Name, storageRemote.Parent = "BaseStorage", remotes

	local inventories: { [Player]: Inventory.Slots } = {}
	local needs: { [Player]: Needs.State } = {}
	local sessions = SessionSupplies.new()
	local lastSync: { [Player]: number } = {}
	local lastConsume: { [Player]: number } = {}
	local bandaging: { [Player]: { id: string } } = {}
	local lastShare: { [Player]: number } = {}
	local revisions: { [Player]: number } = {}
	local firearms: { [Player]: { [string]: { id: string, tool: Tool, state: Firearm.State, reloadVersion: number } } } = {}
	local absentFirearms: { [number]: { [string]: { id: string, tool: Tool, state: Firearm.State, reloadVersion: number } } } = {}
	local bags = {}
	local worldWeapons = {}
	local worldSupplies = {}
	local heldWeapons = Instance.new("Folder")
	heldWeapons.Name, heldWeapons.Parent = "FNABKDisconnectedFirearms", ServerStorage
	local function refreshNeeds(player: Player)
		player:SetAttribute("FNABKFood", needs[player].food)
		player:SetAttribute("FNABKWater", needs[player].water)
	end
	local function refresh(player: Player)
		revisions[player] = (revisions[player] or 0) + 1
		local count = Inventory.count(inventories[player], "Medkit")
		player:SetAttribute("FNABKMedkitCount", count)
		player:SetAttribute("FNABKHasMedkit", count > 0)
		inventorySnapshot:FireClient(player, Inventory.summary(inventories[player]), revisions[player])
	end
	local function cancelBoxReload(player: Player, item: Inventory.Item)
		if bandaging[player] and bandaging[player].id == item.id then bandaging[player] = nil end
		for _, entry in pairs(firearms[player] or {}) do
			if entry.state.reloadBox == item.id then
				entry.reloadVersion += 1
				Firearm.cancelReload(entry.state)
				entry.tool:SetAttribute("Reloading", false)
			end
		end
	end
	local function dropBag(player: Player, position: Vector3)
		bandaging[player] = nil
		local slots = inventories[player]
		local weapons = firearms[player]
		if not slots or not weapons or (#slots == 0 and not next(weapons)) then return end
		local base = roundState:FindFirstChild("ActiveBase")
		local points = Workspace:FindFirstChild("FNABKBaseClaimPoints")
		local anchor = base and base:IsA("StringValue") and points and points:FindFirstChild(base.Value)
		local spawn = map:FindFirstChild("PlayerSpawn")
		local fallback = if anchor and anchor:IsA("BasePart") then anchor.Position + Vector3.new(0, 2, 0) else nil
		local spawnPosition = if spawn and spawn:IsA("BasePart") then spawn.Position + Vector3.new(0, 2, 0) else nil
		local bagPosition = BagLocation.resolve(position, Workspace.FallenPartsDestroyHeight, fallback, spawnPosition)
		if not bagPosition then warn("[FNABK] Recovery bag retained in inventory: no safe location"); return end
		local bag = Instance.new("Part")
		bag.Name, bag.Size, bag.Position = "RecoveryBag", Vector3.new(2, 1, 1.5), bagPosition
		bag.Anchored, bag.CanCollide, bag.Color = true, false, Color3.fromRGB(103, 82, 55)
		bag.Parent = map
		-- Snapshot first: failure while creating the bag must not consume the source inventory.
		local contents = Inventory.snapshot(slots)
		local bagWeapons: { [string]: { id: string, tool: Tool, state: Firearm.State, reloadVersion: number } } = {}
		bags[bag] = { owner = player.UserId, items = contents, weapons = bagWeapons }
		bag.Destroying:Connect(function() bags[bag] = nil end)
		for kind, entry in pairs(weapons) do
			entry.reloadVersion += 1
			Firearm.cancelReload(entry.state)
			entry.tool:SetAttribute("Reloading", false)
			entry.tool.Parent = bag
			bagWeapons[kind], weapons[kind] = entry, nil
		end
		table.clear(slots)
		refresh(player)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText, prompt.ObjectText = "Take item", player.DisplayName .. "'s bag"
		prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = 6, false, bag
		prompt.Enabled = #contents > 0
		prompt.Triggered:Connect(function(taker: Player)
			local character, _, root = activeCharacter(taker)
			local destination = inventories[taker]
			if roundStatus.Value ~= "Running" or not character or not root or not destination or (root.Position - bag.Position).Magnitude > 6 then return end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, bag.Position - origin, params)
			if not hit or hit.Instance ~= bag then return end
			if not Inventory.transferFirstFitting(contents, destination) then feedback:FireClient(taker, "MedkitFull"); return end
			refresh(taker)
			prompt.Enabled = #contents > 0
			if #contents == 0 and not next(bagWeapons) then bag:Destroy() end
		end)
		local weaponPrompt = Instance.new("ProximityPrompt")
		weaponPrompt.ActionText, weaponPrompt.ObjectText = "Take weapon", player.DisplayName .. "'s bag"
		weaponPrompt.KeyboardKeyCode, weaponPrompt.MaxActivationDistance, weaponPrompt.RequiresLineOfSight = Enum.KeyCode.F, 6, false
		weaponPrompt.Enabled, weaponPrompt.Parent = next(bagWeapons) ~= nil, bag
		weaponPrompt.Triggered:Connect(function(taker: Player)
			local character, _, root = activeCharacter(taker)
			local owned, backpack = firearms[taker], taker:FindFirstChildOfClass("Backpack")
			if roundStatus.Value ~= "Running" or not bag.Parent or not character or not root or not owned or not backpack or (root.Position - bag.Position).Magnitude > 6 then return end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, bag.Position - origin, params)
			if not hit or hit.Instance ~= bag then return end
			local chosen: string? = nil
			for kind in pairs(bagWeapons) do if not owned[kind] then chosen = kind; break end end
			if not chosen then shareFeedback:FireClient(taker, "You already carry these weapons"); return end
			local entry = bagWeapons[chosen]
			bagWeapons[chosen], owned[chosen] = nil, entry
			entry.tool.Parent = backpack
			weaponPrompt.Enabled = next(bagWeapons) ~= nil
			if #contents == 0 and not next(bagWeapons) then bag:Destroy() end
		end)
	end
	local function register(player: Player)
		local session = sessions:get(player.UserId)
		inventories[player] = session.items
		needs[player] = session.needs
		local restored = absentFirearms[player.UserId] or {}
		absentFirearms[player.UserId] = nil
		firearms[player] = restored
		task.spawn(function()
			local backpack = player:WaitForChild("Backpack", 10)
			if not backpack or not backpack:IsA("Backpack") or firearms[player] ~= restored then return end
			for _, entry in pairs(restored) do
				if entry.tool.Parent == heldWeapons then entry.tool.Parent = backpack end
			end
		end)
		refreshNeeds(player)
		refresh(player)
	end
	Players.PlayerAdded:Connect(register)
	Players.PlayerRemoving:Connect(function(player)
		bandaging[player] = nil
		local owned = firearms[player]
		if owned then
			for _, entry in pairs(owned) do
				entry.reloadVersion += 1
				Firearm.cancelReload(entry.state)
				entry.tool:SetAttribute("Reloading", false)
				entry.tool.Parent = heldWeapons
			end
			absentFirearms[player.UserId] = owned
		end
		inventories[player] = nil; needs[player] = nil; lastSync[player] = nil; lastConsume[player] = nil; lastShare[player] = nil; revisions[player] = nil; firearms[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		register(player)
	end
	local storages: { [string]: Inventory.Slots } = {}
	local storageRevision: { [string]: number } = {}
	local storagePoints: { [string]: BasePart } = {}
	local storageUpgraded: { [string]: boolean } = {}
	local defenseState: Barricade.State? = nil
	local defensePart: BasePart? = nil
	local updateDefense: (() -> ())? = nil
	local defenseRestored = false
	local function storageAccess(player: Player, name: string): boolean
		local point = storagePoints[name]
		local character, _, root = activeCharacter(player)
		if roundStatus.Value ~= "Running" or not point or not character or not root or (point.Position - root.Position).Magnitude > 6 then return false end
		local params = RaycastParams.new()
		params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
		local origin = root.Position + Vector3.new(0, 1.5, 0)
		local hit = Workspace:Raycast(origin, point.Position - origin, params)
		return hit ~= nil and hit.Instance == point
	end
	local function sendStorage(player: Player, name: string, open: boolean?)
		storageRemote:FireClient(player, if open then "Open" else "Update", name, Inventory.summary(storages[name]), storageRevision[name], storageUpgraded[name] == true)
	end
	local function updateNearbyStorage(name: string)
		for _, player in ipairs(Players:GetPlayers()) do
			if storageAccess(player, name) then sendStorage(player, name) end
		end
	end
	local anchors = Workspace:WaitForChild("FNABKBaseClaimPoints")
	-- ponytail: B1 left entrance only; mark other entrances after exit routes are reviewed.
	local campus = Workspace:WaitForChild("FNABK_Campus_PixelBuildings_PhaseC_v6")
	local b1 = campus:FindFirstChild("B1", true)
	local doors = b1 and b1:FindFirstChild("B1_MainEntryDoors_v1")
	local door = doors and doors:FindFirstChild("MainDoorLeft")
	if door and door:IsA("BasePart") then
		local closed = door:GetAttribute("DoorClosed")
		if typeof(closed) == "CFrame" then
			local barricade = Instance.new("Part")
			barricade.Name, barricade.Size, barricade.CFrame = "B1Barricade", Vector3.new(5.8, 7.5, .6), closed
			barricade.Anchored, barricade.CanCollide, barricade.Color = true, false, Color3.fromRGB(101, 79, 55)
			barricade.Transparency, barricade.Parent = 1, map
			local state = Barricade.new()
			defenseState, defensePart = state, barricade
			local frame = Instance.new("Folder")
			frame.Name, frame.Parent = "DamagedFrame", barricade
			for _, x in ipairs({ -2.6, 2.6 }) do
				local post = Instance.new("Part")
				post.Size, post.CFrame = Vector3.new(.3, 7.5, .6), closed * CFrame.new(x, 0, 0)
				post.Anchored, post.CanCollide, post.CanTouch, post.CanQuery = true, false, false, false
				post.Color, post.Transparency, post.Parent = barricade.Color, 1, frame
			end
			local prompt = Instance.new("ProximityPrompt")
			prompt.Name, prompt.ActionText, prompt.ObjectText = "BarricadePrompt", "Install: 3 scrap + 1 cloth", "B1 defense"
			prompt.KeyboardKeyCode, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = Enum.KeyCode.L, 6, false
			prompt.Parent = barricade
			local function refreshBarricade()
				barricade:SetAttribute("Health", state.health)
				barricade:SetAttribute("Installed", state.installed)
				barricade.CanCollide = state.installed and state.health > 0
				barricade.Transparency = if barricade.CanCollide then .15 else 1
				for _, post in ipairs(frame:GetChildren()) do if post:IsA("BasePart") then post.Transparency = if state.installed and state.health == 0 then 0 else 1 end end
				prompt.ActionText = if not state.installed then "Install: 3 scrap + 1 cloth" elseif state.health < 100 then "Repair: 2 scrap" else "Barricade intact"
			end
			updateDefense = refreshBarricade
			local strike = Instance.new("BindableEvent")
			strike.Name, strike.Parent = "WaveStrike", barricade
			local lastStrike: { [Model]: number } = setmetatable({}, { __mode = "k" }) :: any
			strike.Event:Connect(function(enemy: Model)
				local active = roundState:FindFirstChild("ActiveBase")
				local phase = roundState:FindFirstChild("SurvivalPhase")
				local waves = map:FindFirstChild("WaveAttackers")
				if roundStatus.Value ~= "Running" or not active or not active:IsA("StringValue") or active.Value ~= "B1"
					or not phase or not phase:IsA("StringValue") or (phase.Value ~= "Night" and phase.Value ~= "SignalGrace" and phase.Value ~= "RescueWait")
					or not waves or typeof(enemy) ~= "Instance" or not enemy:IsA("Model") or enemy.Parent ~= waves
					or enemy:GetAttribute("NPCType") ~= "Creature" or enemy:GetAttribute("EnemyState") ~= "Chase"
					or not enemy.PrimaryPart or (enemy.PrimaryPart.Position - barricade.Position).Magnitude > 7
					or os.clock() - (lastStrike[enemy] or -math.huge) < 2 then return end
				local ray = RaycastParams.new()
				ray.FilterType, ray.FilterDescendantsInstances, ray.RespectCanCollide = Enum.RaycastFilterType.Exclude, { enemy, door }, true
				local hit = Workspace:Raycast(enemy.PrimaryPart.Position, barricade.Position - enemy.PrimaryPart.Position, ray)
				if not hit or hit.Instance ~= barricade then return end
				if Barricade.damage(state, 20) then lastStrike[enemy] = os.clock(); refreshBarricade() end
			end)
			prompt.Triggered:Connect(function(player)
				local character, _, root = activeCharacter(player)
				local slots = inventories[player]
				local active = roundState:FindFirstChild("ActiveBase")
				if roundStatus.Value ~= "Running" or not active or not active:IsA("StringValue") or active.Value ~= "B1"
					or not character or not root or not slots or (root.Position - barricade.Position).Magnitude > 6 then return end
				local ray = RaycastParams.new()
				ray.FilterType, ray.FilterDescendantsInstances, ray.RespectCanCollide = Enum.RaycastFilterType.Exclude, { character, barricade, door }, true
				if Workspace:Raycast(root.Position, barricade.Position - root.Position, ray) then return end
				if not state.installed or state.health == 0 then
					local overlap = OverlapParams.new()
					overlap.FilterType, overlap.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { barricade }
					for _, part in ipairs(Workspace:GetPartBoundsInBox(barricade.CFrame, barricade.Size, overlap)) do
						local model = part:FindFirstAncestorOfClass("Model")
						if model and model:FindFirstChildOfClass("Humanoid") then shareFeedback:FireClient(player, "Clear the doorway first"); return end
					end
				end
				local changed = if state.installed then Barricade.repair(state, slots) else Barricade.install(state, slots)
				if changed then refreshBarricade(); refresh(player) else shareFeedback:FireClient(player, "Barricade intact or materials missing") end
			end)
			refreshBarricade()
		end
	end
	for _, anchor in ipairs(anchors:GetChildren()) do
		if not anchor:IsA("BasePart") then continue end
		local chest = Instance.new("Part")
		chest.Name, chest.Size, chest.Position = "Storage_" .. anchor.Name, Vector3.new(2, 1.5, 1.5), anchor.Position + Vector3.new(3, 0, 0)
		chest.Anchored, chest.CanCollide, chest.Color, chest.Parent = true, false, Color3.fromRGB(92, 79, 62), map
		storages[anchor.Name], storageRevision[anchor.Name], storagePoints[anchor.Name] = Inventory.new(), 0, chest
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText, prompt.ObjectText, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = "Open storage", anchor.Name, 6, false
		prompt.Parent = chest
		prompt.Triggered:Connect(function(player) if storageAccess(player, anchor.Name) then sendStorage(player, anchor.Name, true) end end)
	end
	storageRemote.OnServerEvent:Connect(function(player, action, name, slot, revision)
		if type(name) ~= "string" or not storages[name] or not storageAccess(player, name) or type(revision) ~= "number" then return end
		local inventory = inventories[player]
		if not inventory then return end
		if action == "Upgrade" then
			if revision ~= revisions[player] then sendStorage(player, name); refresh(player); return end
			if storageUpgraded[name] then shareFeedback:FireClient(player, "Storage already upgraded"); return end
			if Inventory.count(inventory, "Scrap") < 2 then shareFeedback:FireClient(player, "Need 2 scrap"); return end
			Inventory.removeFirst(inventory, "Scrap")
			Inventory.removeFirst(inventory, "Scrap")
			storageUpgraded[name] = true
			storageRevision[name] += 1
			refresh(player)
			updateNearbyStorage(name)
			shareFeedback:FireClient(player, "Storage expanded")
			return
		end
		if type(slot) ~= "number" or slot % 1 ~= 0 or slot < 1 or slot > (if action == "Take" and storageUpgraded[name] then 16 else 8) then return end
		local source, destination = if action == "Deposit" then inventory else storages[name], if action == "Deposit" then storages[name] else inventory
		if action ~= "Deposit" and action ~= "Take" then return end
		if revision ~= (if action == "Deposit" then revisions[player] else storageRevision[name]) then sendStorage(player, name); refresh(player); return end
		local moved = source[slot] and source[slot][1]
		if Inventory.transfer(source, destination, slot, 1, if action == "Deposit" and storageUpgraded[name] then 16 else 8) then
			if action == "Deposit" and moved then cancelBoxReload(player, moved) end
			storageRevision[name] += 1
			refresh(player)
			updateNearbyStorage(name)
			return
		end
		if moved then shareFeedback:FireClient(player, "Unable to transfer item; check available space") end
		sendStorage(player, name)
	end)
	local trust = roundState:WaitForChild("Trust") :: IntValue
	for _, student in ipairs(map:GetDescendants()) do
		if not student:IsA("Model") or student:GetAttribute("NPCType") ~= "Student" or not student.PrimaryPart then continue end
		local root = student.PrimaryPart
		local function updateWary()
			local wary = student:GetAttribute("TradeWary") == true
			local taken = student:GetAttribute("TradeTaken") or 0
			local nowWary = trust.Value >= 30 and trust.Value < 70
			if nowWary and not wary then
				student:SetAttribute("TradeWaryStock", 4 - taken)
				student:SetAttribute("TradeWaryTaken", 0)
				student:SetAttribute("TradeWary", true)
			elseif trust.Value >= 70 and wary then
				student:SetAttribute("TradeWary", false)
				student:SetAttribute("TradeWaryStock", 0)
				student:SetAttribute("TradeWaryTaken", 0)
			end
		end
		trust.Changed:Connect(updateWary)
		updateWary()
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name, prompt.ActionText, prompt.ObjectText = "SurvivorTrade", "Trade 1 scrap for water", "Survivor"
		prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = 6, false, root
		prompt.Triggered:Connect(function(player)
			local character, _, playerRoot = activeCharacter(player)
			local slots = inventories[player]
			if roundStatus.Value ~= "Running" or student:GetAttribute("StudentState") == "Incapacitated" or not character or not playerRoot or not slots or (playerRoot.Position - root.Position).Magnitude > 6 then return end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = playerRoot.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, root.Position - origin, params)
			if not hit or not hit.Instance:IsDescendantOf(student) then return end
			local taken = student:GetAttribute("TradeTaken") or 0
			local wary = student:GetAttribute("TradeWary") == true
			local waryStock, waryTaken = student:GetAttribute("TradeWaryStock") or 0, student:GetAttribute("TradeWaryTaken") or 0
			local available = if wary then SurvivorTrade.available(trust.Value, waryStock, waryTaken) else SurvivorTrade.available(trust.Value, 4, taken)
			if available == 0 then shareFeedback:FireClient(player, "Survivor cannot trade right now"); return end
			if Inventory.count(slots, "Scrap") == 0 then shareFeedback:FireClient(player, "Need 1 scrap to trade"); return end
			-- ponytail: fixed scrap-for-water exchange; replace after economy review.
			local scratch = Inventory.snapshot(slots)
			Inventory.removeFirst(scratch, "Scrap")
			local water = { id = HttpService:GenerateGUID(false), kind = "Water" }
			if not Inventory.add(scratch, water) then shareFeedback:FireClient(player, "Inventory full"); return end
			Inventory.removeFirst(slots, "Scrap")
			assert(Inventory.add(slots, water))
			taken += 1
			if wary then student:SetAttribute("TradeWaryTaken", waryTaken + 1) end
			student:SetAttribute("TradeTaken", taken)
			refresh(player)
			shareFeedback:FireClient(player, "Traded 1 scrap for water")
		end)
		local quest = Instance.new("ProximityPrompt")
		quest.Name, quest.ActionText, quest.ObjectText = "SurvivorFoodQuest", "Give 1 food", "Survivor request"
		quest.KeyboardKeyCode, quest.MaxActivationDistance, quest.RequiresLineOfSight = Enum.KeyCode.J, 6, false
		quest.Enabled, quest.Parent = student:GetAttribute("FoodQuestCompleted") ~= true, root
		student:GetAttributeChangedSignal("FoodQuestCompleted"):Connect(function()
			quest.Enabled = student:GetAttribute("FoodQuestCompleted") ~= true
		end)
		quest.Triggered:Connect(function(player)
			local character, _, playerRoot = activeCharacter(player)
			local slots = inventories[player]
			if roundStatus.Value ~= "Running" or student:GetAttribute("StudentState") == "Incapacitated" or not character or not playerRoot or not slots or (playerRoot.Position - root.Position).Magnitude > 6 then return end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = playerRoot.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, root.Position - origin, params)
			if not hit or not hit.Instance:IsDescendantOf(student) then return end
			if SurvivorHelp.deliverFood(student, trust, slots) then
				quest.Enabled = false
				refresh(player)
				feedback:FireClient(player, "QuestComplete", "Trust " .. trust.Value)
			else
				feedback:FireClient(player, "QuestUnavailable", "Need food or already completed")
			end
		end)
		-- ponytail: simple repair point; replace the block with a reviewed prop.
		local repair = Instance.new("Part")
		repair.Name, repair.Size = "SurvivorRepair", Vector3.new(1.5, 1, 1)
		repair.CFrame = root.CFrame * CFrame.new(-3, -1.5, 0)
		repair.Anchored, repair.CanCollide, repair.Color, repair.Parent = true, false, Color3.fromRGB(72, 78, 73), map
		local repairPrompt = Instance.new("ProximityPrompt")
		repairPrompt.Name, repairPrompt.ActionText, repairPrompt.ObjectText = "SurvivorRepair", "Repair: 1 scrap", "Survivor equipment"
		repairPrompt.KeyboardKeyCode, repairPrompt.HoldDuration, repairPrompt.MaxActivationDistance = Enum.KeyCode.U, 3.25, 6
		repairPrompt.RequiresLineOfSight, repairPrompt.Parent = false, repair
		local day = roundState:WaitForChild("SurvivalDay") :: IntValue
		local waterPrompt = Instance.new("ProximityPrompt")
		waterPrompt.Name, waterPrompt.ActionText, waterPrompt.ObjectText = "SurvivorWater", "Give 1 water", "Daily help"
		waterPrompt.KeyboardKeyCode, waterPrompt.MaxActivationDistance, waterPrompt.RequiresLineOfSight, waterPrompt.Parent = Enum.KeyCode.Y, 6, false, root
		waterPrompt.Triggered:Connect(function(player)
			local character, _, playerRoot = activeCharacter(player)
			local slots = inventories[player]
			if roundStatus.Value ~= "Running" or student:GetAttribute("StudentState") == "Incapacitated"
				or student:GetAttribute("HelpRewardDay") == day.Value or not character or not playerRoot
				or not slots or (playerRoot.Position - root.Position).Magnitude > 6 then return end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = playerRoot.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, root.Position - origin, params)
			if not hit or not hit.Instance:IsDescendantOf(student) then return end
			if SurvivorHelp.deliverWater(student, trust, day.Value, slots) then
				refresh(player)
				feedback:FireClient(player, "QuestComplete", "Water delivered; Trust " .. trust.Value)
			else feedback:FireClient(player, "QuestUnavailable", "Need 1 water") end
		end)
		local repairHolds: { [Player]: number } = {}
		local function canRepair(player: Player): boolean
			local character, _, playerRoot = activeCharacter(player)
			if roundStatus.Value ~= "Running" or student:GetAttribute("StudentState") == "Incapacitated"
				or student:GetAttribute("HelpRewardDay") == day.Value or not character or not playerRoot
				or not inventories[player] or (playerRoot.Position - repair.Position).Magnitude > 6 then return false end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = playerRoot.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, repair.Position - origin, params)
			return hit ~= nil and hit.Instance == repair
		end
		repairPrompt.PromptButtonHoldBegan:Connect(function(player)
			local started = os.clock()
			repairHolds[player] = if canRepair(player) then started else nil
			if not repairHolds[player] then return end
			task.spawn(function()
				while repairHolds[player] == started do
					if not canRepair(player) then repairHolds[player] = nil; return end
					task.wait(.1)
				end
			end)
		end)
		repairPrompt.PromptButtonHoldEnded:Connect(function(player)
			local started = repairHolds[player]
			if started and os.clock() - started < 3 then repairHolds[player] = nil
			elseif started then task.delay(1, function() if repairHolds[player] == started then repairHolds[player] = nil end end) end
		end)
		repairPrompt.Triggered:Connect(function(player)
			local started = repairHolds[player]
			repairHolds[player] = nil
			local slots = inventories[player]
			if not started or os.clock() - started < 3 or not slots or not canRepair(player) then return end
			if SurvivorHelp.repair(student, trust, day.Value, slots) then
				refresh(player)
				feedback:FireClient(player, "QuestComplete", "Equipment repaired; Trust " .. trust.Value)
			else feedback:FireClient(player, "QuestUnavailable", "Need 1 scrap") end
		end)
		local function refreshRepair()
			local available = student:GetAttribute("HelpRewardDay") ~= day.Value and student:GetAttribute("StudentState") ~= "Incapacitated"
			repairPrompt.Enabled, waterPrompt.Enabled = available, available
		end
		student:GetAttributeChangedSignal("HelpRewardDay"):Connect(refreshRepair)
		student:GetAttributeChangedSignal("StudentState"):Connect(refreshRepair)
		day.Changed:Connect(refreshRepair)
		refreshRepair()
	end
	inventorySync.OnServerEvent:Connect(function(player: Player)
		local now = os.clock()
		if not inventories[player] or now - (lastSync[player] or -math.huge) < 1 then return end
		lastSync[player] = now
		inventorySnapshot:FireClient(player, Inventory.summary(inventories[player]), revisions[player])
	end)
	consume.OnServerEvent:Connect(function(player: Player, kind: unknown, slot: unknown, revision: unknown)
		if kind == "DiscardEmptyAmmo" then
			local slots = inventories[player]
			if roundStatus.Value ~= "Running" or not activeCharacter(player) or not slots
				or typeof(slot) ~= "number" or slot % 1 ~= 0 or slot < 1 or slot > 8
				or typeof(revision) ~= "number" or revision ~= revisions[player] then return end
			local stack = slots[slot]
			if not stack then return end
			for index, item in ipairs(stack) do
				if (item.kind == "PistolAmmo" or item.kind == "ShotgunAmmo" or item.kind == "RifleAmmo") and item.rounds == 0 then
					Inventory.remove(slots, slot, index)
					refresh(player)
					shareFeedback:FireClient(player, "Empty ammunition box discarded")
					return
				end
			end
			return
		end
		if kind ~= "Food" and kind ~= "Water" and kind ~= "Cloth" and kind ~= "Bandage" then return end
		local now = os.clock()
		if now - (lastConsume[player] or -math.huge) < 0.2 then return end
		lastConsume[player] = now
		local slots, state = inventories[player], needs[player]
		local _, humanoid = activeCharacter(player)
		if roundStatus.Value ~= "Running" or not slots or not state or not humanoid
			or Inventory.count(slots, kind) == 0 then return end
		if kind == "Cloth" then
			if Inventory.craftBandage(slots, HttpService:GenerateGUID(false)) then refresh(player); shareFeedback:FireClient(player, "Crafted bandage")
			else shareFeedback:FireClient(player, "Inventory full") end
			return
		elseif kind == "Bandage" then
			if bandaging[player] or humanoid.Health >= humanoid.MaxHealth then return end
			local itemId: string? = nil
			for _, stack in ipairs(slots) do if stack[1].kind == "Bandage" then itemId = stack[1].id; break end end
			if not itemId then return end
			local use = { id = itemId }
			bandaging[player] = use
			local previousHealth, interrupted = humanoid.Health, false
			local connection = humanoid.HealthChanged:Connect(function(value)
				if value < previousHealth then interrupted = true end
				previousHealth = value
			end)
			shareFeedback:FireClient(player, "Using bandage (3 seconds)")
			task.delay(3, function()
				connection:Disconnect()
				if bandaging[player] ~= use then return end
				bandaging[player] = nil
				local _, current = activeCharacter(player)
				if interrupted or roundStatus.Value ~= "Running" or current ~= humanoid or inventories[player] ~= slots or humanoid.Health >= humanoid.MaxHealth then return end
				for slot, stack in ipairs(slots) do
					for index, item in ipairs(stack) do
						if item.id == itemId and item.kind == "Bandage" then
							Inventory.remove(slots, slot, index)
							humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 15)
							refresh(player)
							shareFeedback:FireClient(player, "Bandage applied")
							return
						end
					end
				end
			end)
			return
		end
		if not Needs.consume(state, kind) then return end
		Inventory.removeFirst(slots, kind)
		refreshNeeds(player)
		refresh(player)
	end)
	share.OnServerEvent:Connect(function(player: Player, slot: unknown, expectedKind: unknown, revision: unknown)
		if typeof(slot) ~= "number" or slot % 1 ~= 0 or slot < 1 or slot > 8 or typeof(expectedKind) ~= "string" or typeof(revision) ~= "number" then return end
		local now = os.clock()
		if now - (lastShare[player] or -math.huge) < 0.3 then return end
		lastShare[player] = now
		local source = inventories[player]
		local character, _, root = activeCharacter(player)
		if roundStatus.Value ~= "Running" or not source or not character or not root then return end
		local stack = source[slot]
		if revision ~= revisions[player] or not stack or stack[1].kind ~= expectedKind then
			inventorySnapshot:FireClient(player, Inventory.summary(source), revisions[player])
			shareFeedback:FireClient(player, "Inventory changed; select the item again")
			return
		end
		local nearest: Player? = nil
		local best = config.medkitPickupRangeStuds
		for _, target in ipairs(Players:GetPlayers()) do
			if target == player or not inventories[target] then continue end
			local targetCharacter, _, targetRoot = activeCharacter(target)
			if not targetCharacter or not targetRoot then continue end
			local distance = (targetRoot.Position - root.Position).Magnitude
			if distance > best then continue end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, targetRoot.Position - origin, params)
			if hit and hit.Instance:IsDescendantOf(targetCharacter) then nearest, best = target, distance end
		end
		local moved = stack[1]
		if not nearest then shareFeedback:FireClient(player, "No teammate within reach")
		elseif not Inventory.transfer(source, inventories[nearest], slot, 1) then shareFeedback:FireClient(player, "Teammate inventory is full")
		else
			cancelBoxReload(player, moved)
			refresh(player)
			refresh(nearest)
			shareFeedback:FireClient(player, "Gave " .. expectedKind .. " to " .. nearest.DisplayName)
			shareFeedback:FireClient(nearest, "Received " .. expectedKind .. " from " .. player.DisplayName)
		end
	end)
	local accumulated = 0
	RunService.Heartbeat:Connect(function(dt)
		if roundStatus.Value ~= "Running" then accumulated = 0; return end
		accumulated += dt
		if accumulated < 1 then return end
		local elapsed = accumulated
		accumulated = 0
		for player, state in pairs(needs) do
			local _, humanoid = activeCharacter(player)
			if humanoid then
				local damage = Needs.advance(state, elapsed)
				refreshNeeds(player)
				if damage > 0 then applyDamage(player, damage, false) end
			end
		end
	end)

	local folder = Instance.new("Folder")
	folder.Name = "Medkits"
	folder.Parent = map
	local first = map:GetAttribute("FNABKMedkitA3")
	local second = map:GetAttribute("FNABKMedkitB4")
	local positions = {
		if typeof(first) == "Vector3" then first else Vector3.new(-46, 0.6, -15) + layout.a3,
		if typeof(second) == "Vector3" then second else Vector3.new(38, 0.6, -28) + layout.b4,
	}
	local function registerPickup(box: BasePart, visual: Model?, kind: string?, rounds: number?, unmarked: boolean?, supplyPoint: string?, itemId: string?)
		kind = kind or "Medkit"
		local item = { id = itemId or HttpService:GenerateGUID(false), kind = kind, rounds = rounds }
		worldSupplies[box] = { item = item, point = supplyPoint, slot = box:GetAttribute("SupplySlot"),
			unmarked = unmarked == true, visual = if visual then visual.Name else nil }
		box.Destroying:Connect(function() worldSupplies[box] = nil end)
		local marker = Instance.new("BillboardGui")
		marker.Name = "Marker"
		marker.Size = UDim2.fromOffset(110, 28)
		marker.StudsOffset = Vector3.new(0, 1.5, 0)
		marker.AlwaysOnTop = true
		marker.Parent = box
		marker.Enabled = not unmarked
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 0.2
		label.BackgroundColor3 = Color3.fromRGB(100, 35, 35)
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Text = "+ " .. string.upper(kind)
		label.Parent = marker
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Pick Up"
		prompt.ObjectText = kind
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.MaxActivationDistance = config.medkitPickupRangeStuds
		-- Camera occlusion should not hide the prompt; the server verifies LOS.
		prompt.RequiresLineOfSight = false
		prompt.Parent = box
		local collected = false
		prompt.Triggered:Connect(function(player: Player)
			if collected then feedback:FireClient(player, "SupplyTaken"); return end
			if roundStatus.Value ~= "Running" then return end
			local character, _, root = activeCharacter(player)
			if not character or not root or (root.Position - box.Position).Magnitude > config.medkitPickupRangeStuds then
				feedback:FireClient(player, "MedkitRejected", "Move closer")
				return
			end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { character }
			params.IgnoreWater = true
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, box.Position - origin, params)
			if not hit or hit.Instance ~= box then
				feedback:FireClient(player, "MedkitRejected", "Item is blocked")
				return
			end
			local slots = inventories[player]
			if not slots then return end
			local accepted = Inventory.add(slots, item)
			if not accepted then
				feedback:FireClient(player, "MedkitFull")
				return
			end
			collected = true
			worldSupplies[box] = nil
			if box:GetAttribute("SupplySlot") ~= nil then box.Parent = map end
			box.CanQuery = false
			refresh(player)
			-- ponytail: keep the prompt briefly for racing pickups; replace with item-ID requests for reliable late feedback.
			task.delay(1, function() if visual then visual:Destroy() else box:Destroy() end end)
			feedback:FireClient(player, if kind == "Medkit" then "MedkitPickedUp" else "SupplyPickedUp", if kind == "Medkit" then "Press R to heal" else kind .. " collected")
		end)
	end
	local dailyFolder = Instance.new("Folder")
	dailyFolder.Name, dailyFolder.Parent = "DailySupplies", map
	local processedDay = 1
	local dailyRestored = false
	local function createDaily(point: string, index: number, position: Vector3, kind: string, rounds: number?, id: string?)
		local stock = dailyFolder:FindFirstChild(point)
		if not stock then stock = Instance.new("Folder"); stock.Name, stock.Parent = point, dailyFolder end
		local box = Instance.new("Part")
		box.Name, box.Size, box.Position = kind, Vector3.new(1.2, .8, .8), position
		box.Color, box.Anchored, box.CanCollide = Color3.fromRGB(104, 109, 76), true, false
		box:SetAttribute("SupplySlot", index)
		box.Parent = stock
		registerPickup(box, nil, kind, rounds, true, point, id)
	end
	dayEvents.Event:Connect(function(event: string)
		local day = tonumber(event:match("^Day:(%d+)$"))
		if not day or day <= processedDay then return end
		local playerCount = #Players:GetPlayers()
		if playerCount < 1 or playerCount > 4 then return end
		local anchors = Workspace:FindFirstChild("FNABKBaseClaimPoints")
		if not anchors then return end
		local candidates = anchors:GetChildren()
		table.sort(candidates, function(a, b) return a.Name < b.Name end)
		if #candidates == 0 then return end
		local active = roundState:FindFirstChild("ActiveBase")
		local selected = {}
		-- ponytail: rotate five existing ground-floor anchors; replace with reviewed loot points.
		for offset = 0, math.min(4, #candidates - 1) do
			local anchor = candidates[(day * 5 + offset - 1) % #candidates + 1]
			if not anchor:IsA("BasePart") then continue end
			local stock = dailyFolder:FindFirstChild(anchor.Name)
			if not stock then stock = Instance.new("Folder"); stock.Name, stock.Parent = anchor.Name, dailyFolder end
			table.insert(selected, { id = anchor.Name, stock = #stock:GetChildren(), base = active ~= nil and active:IsA("StringValue") and active.Value == anchor.Name })
		end
		local allocation = DailySupply.points(day, playerCount, selected)
		for _, item in ipairs(allocation) do
			local stock = dailyFolder:FindFirstChild(item.point) :: Folder
			local anchor = anchors:FindFirstChild(item.point) :: BasePart
			local used: { [number]: boolean } = {}
			for _, existing in ipairs(stock:GetChildren()) do
				local slot = existing:GetAttribute("SupplySlot")
				if typeof(slot) == "number" then used[slot] = true end
			end
			local index = 0
			while used[index] do index += 1 end
			local rounds = ({ PistolAmmo = 20, ShotgunAmmo = 10, RifleAmmo = 30 })[item.kind]
			createDaily(item.point, index, anchor.Position + Vector3.new((index % 5 - 2) * 1.5, 0, 4 + math.floor(index / 5) * 1.5), item.kind, rounds, nil)
		end
		processedDay = day
		dailyFolder:SetAttribute("ProcessedDay", day)
	end)
	for index, position in ipairs(positions) do
		local box = Instance.new("Part")
		box.Name = "Medkit" .. index
		box.Size = Vector3.new(2, 1.2, 1.4)
		box.Position = position
		box.Color = Color3.fromRGB(225, 230, 220)
		box.Material = Enum.Material.SmoothPlastic
		box.Anchored = true
		box.CanCollide = false
		box.Parent = folder
		registerPickup(box, nil)
	end
	-- ponytail: provisional early-route placements; review accessibility and distribution.
	for index, position in ipairs(positions) do
		for n = 1, 3 do
			local scrap = Instance.new("Part")
			scrap.Name, scrap.Size, scrap.Position = "Scrap" .. ((index - 1) * 3 + n), Vector3.new(1, .6, 1), position + Vector3.new(3 + (n - 1) * 2, 0, 3)
			scrap.Color, scrap.Anchored, scrap.CanCollide, scrap.Parent = Color3.fromRGB(115, 105, 90), true, false, folder
			registerPickup(scrap, nil, "Scrap")
		end
		local cloth = Instance.new("Part")
		cloth.Name, cloth.Size, cloth.Position = "Cloth" .. index, Vector3.new(1, .5, 1), position + Vector3.new(-3, 0, 3)
		cloth.Color, cloth.Anchored, cloth.CanCollide, cloth.Parent = Color3.fromRGB(175, 168, 144), true, false, folder
		registerPickup(cloth, nil, "Cloth")
		for n = 1, 2 do
			local electronics = Instance.new("Part")
			electronics.Name, electronics.Size = "Electronics" .. index .. "_" .. n, Vector3.new(1, .5, 1)
			electronics.Position = position + Vector3.new(3 + (n - 1) * 2, 0, 6)
			electronics.Color, electronics.Anchored, electronics.CanCollide, electronics.Parent = Color3.fromRGB(73, 91, 88), true, false, folder
			registerPickup(electronics, nil, "Electronics")
		end
		-- ponytail: temporary initial supplies; review route access and visual placement.
		for n = 1, 2 do
			for _, kind in ipairs({ "Food", "Water" }) do
				local item = Instance.new("Part")
				item.Name, item.Size = "Initial" .. kind .. index .. "_" .. n, Vector3.new(1, .7, 1)
				item.Position = position + Vector3.new(-7 + (n - 1) * 2, 0, if kind == "Food" then -3 else -5)
				item.Color = if kind == "Food" then Color3.fromRGB(153, 111, 72) else Color3.fromRGB(98, 143, 163)
				item.Anchored, item.CanCollide, item.Parent = true, false, folder
				registerPickup(item, nil, kind)
			end
		end
	end
	local powerStates = Instance.new("Folder")
	powerStates.Name, powerStates.Parent = "BuildingPower", roundState
	local campusBuildings = Workspace:WaitForChild("FNABK_Campus_PixelBuildings_PhaseC_v6"):WaitForChild("Buildings")
	for _, anchor in ipairs(anchors:GetChildren()) do
		if not anchor:IsA("BasePart") then continue end
		local powered = Instance.new("BoolValue")
		powered.Name, powered.Parent = anchor.Name, powerStates
		local building = campusBuildings:FindFirstChild(anchor.Name)
		if building then BasePower.bindLights(building, powered) end
		local point = Instance.new("Part")
		point.Name, point.Size, point.Position = "Power_" .. anchor.Name, Vector3.new(1.5, 1.5, 1), anchor.Position + Vector3.new(-3, 0, 0)
		point.Color, point.Anchored, point.CanCollide, point.Parent = Color3.fromRGB(74, 82, 77), true, false, map
		local light = Instance.new("PointLight")
		light.Name, light.Enabled, light.Range, light.Brightness = "RestoredLight", false, 24, 1.5
		light.Color, light.Parent = Color3.fromRGB(255, 220, 164), point
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name, prompt.ActionText, prompt.ObjectText = "RestorePower", "Restore power: 2 electronics + 2 scrap", anchor.Name
		prompt.KeyboardKeyCode, prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = Enum.KeyCode.P, 6, false, point
		local function refreshPower()
			light.Enabled, prompt.Enabled = powered.Value, not powered.Value
		end
		powered.Changed:Connect(refreshPower)
		refreshPower()
		prompt.Triggered:Connect(function(player)
			local character, _, root = activeCharacter(player)
			local inventory = inventories[player]
			if roundStatus.Value ~= "Running" or not character or not root or not inventory or (root.Position - point.Position).Magnitude > 6 then return end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, point.Position - origin, params)
			if not hit or hit.Instance ~= point then return end
			if BasePower.restore(powered, inventory) then
				refresh(player)
				shareFeedback:FireClient(player, anchor.Name .. " power restored")
			else shareFeedback:FireClient(player, "Need 2 electronics and 2 scrap") end
		end)
	end
	local function addSharedStarterSupplies(player: Player)
		local participant = sessions:claimShared(player.UserId)
		if not participant or participant == 1 then return end
		-- ponytail: shared pickups use the early-route anchors; replace with reviewed containers.
		for index, position in ipairs(positions) do
			for _, kind in ipairs({ "Food", "Water" }) do
				local item = Instance.new("Part")
				item.Name, item.Size = "Coop" .. participant .. kind .. index, Vector3.new(1, .7, 1)
				item.Position = position + Vector3.new(-7 + (participant - 2) * 2, 0, if kind == "Food" then -7 else -9)
				item.Color = if kind == "Food" then Color3.fromRGB(153, 111, 72) else Color3.fromRGB(98, 143, 163)
				item.Anchored, item.CanCollide, item.Parent = true, false, folder
				registerPickup(item, nil, kind)
			end
		end
	end
	Players.PlayerAdded:Connect(addSharedStarterSupplies)
	for _, player in ipairs(Players:GetPlayers()) do addSharedStarterSupplies(player) end
	local ammunition = Instance.new("Folder")
	ammunition.Name = "Ammunition"
	ammunition.Parent = map
	-- ponytail: three native placeholder boxes near B4; replace placement with the daily supply system.
	for index, spec in ipairs({ { "PistolAmmo", 20 }, { "ShotgunAmmo", 10 }, { "RifleAmmo", 30 } }) do
		local box = Instance.new("Part")
		box.Name = spec[1] :: string
		box.Size = Vector3.new(1.2, 0.8, 0.8)
		box.Position = positions[2] + Vector3.new(index * 3, 0, 0)
		box.Color = Color3.fromRGB(104, 109, 76)
		box.Anchored, box.CanCollide = true, false
		box.Parent = ammunition
		registerPickup(box, nil, spec[1] :: string, spec[2] :: number)
	end
	-- ponytail: temporary pickups near B4; replace with world item ownership and persistence.
	for _, spec in ipairs({ { "Pistol", "Handgun", -3 }, { "Rifle", "M16A4", -6 }, { "Shotgun", "Shotgun", -9 } }) do
	local kind, asset, offset = spec[1] :: string, spec[2] :: string, spec[3] :: number
	local pickup = Instance.new("Part")
	local weaponId = HttpService:GenerateGUID(false)
	worldWeapons[pickup] = { id = weaponId, kind = kind }
	pickup.Destroying:Connect(function() worldWeapons[pickup] = nil end)
	pickup.Name, pickup.Size = kind .. "Pickup", Vector3.new(1.5, 1, 1)
	pickup.Position = positions[2] + Vector3.new(offset, 0, 0)
	pickup.Anchored, pickup.CanCollide = true, false
	pickup.Color, pickup.Parent = Color3.fromRGB(45, 47, 51), ammunition
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText, prompt.ObjectText = "Pick up", kind
	prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 6, false
	prompt.Parent = pickup
	prompt.Triggered:Connect(function(player)
		local owned = firearms[player]
		if not owned or owned[kind] or not pickup.Parent or roundStatus.Value ~= "Running" then return end
		local character, _, root = activeCharacter(player)
		if not character or not root or (root.Position - pickup.Position).Magnitude > 6 then return end
		local params = RaycastParams.new()
		params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
		local origin = root.Position + Vector3.new(0, 1.5, 0)
		local hit = Workspace:Raycast(origin, pickup.Position - origin, params)
		if not hit or hit.Instance ~= pickup then return end
		local backpack = player:FindFirstChildOfClass("Backpack")
		if not backpack then return end
		local tool = Instance.new("Tool")
		tool.Name, tool.CanBeDropped = kind, false
		local library = ServerStorage:FindFirstChild("FNABK_UserStarterTools_20261104")
		local original = library and library:FindFirstChild(asset)
		local source = original and original:FindFirstChild("Handle")
		local handle = if source and source:IsA("BasePart") then source:Clone() else Instance.new("Part")
		for _, child in ipairs(handle:GetDescendants()) do child:Destroy() end
		handle.Name, handle.Anchored, handle.CanCollide, handle.CanTouch, handle.CanQuery, handle.Massless = "Handle", false, false, false, false, true
		handle.Parent = tool
		local state = Firearm.new(kind)
		local entry = { id = weaponId, tool = tool, state = state, reloadVersion = 0 }
		owned[kind] = entry
		tool:SetAttribute("Loaded", 0)
		tool.Unequipped:Connect(function() entry.reloadVersion += 1; Firearm.cancelReload(state); tool:SetAttribute("Reloading", false) end)
		tool.Parent = backpack
		pickup:Destroy()
	end)
	end
	gunRequest.OnServerEvent:Connect(function(player, action, direction)
		local owned, slots = firearms[player], inventories[player]
		local character, _, root = activeCharacter(player)
		if roundStatus.Value ~= "Running" or not owned or not slots or not character or not root then return end
		local entry = if owned.Pistol and owned.Pistol.tool.Parent == character then owned.Pistol elseif owned.Rifle and owned.Rifle.tool.Parent == character then owned.Rifle elseif owned.Shotgun and owned.Shotgun.tool.Parent == character then owned.Shotgun else nil
		if not entry then return end
		local state = entry.state
		if action == "Reload" then
			local chosen
			for _, stack in ipairs(slots) do
				if stack[1].kind == state.kind .. "Ammo" then
					for _, item in ipairs(stack) do if item.rounds and item.rounds > 0 then chosen = item; break end end
				end
				if chosen then break end
			end
			if not chosen or not Firearm.startReload(state, chosen :: any, os.clock()) then return end
			entry.tool:SetAttribute("Reloading", true)
			entry.reloadVersion += 1
			local version = entry.reloadVersion
			task.spawn(function()
				while state.reloadAt and entry.reloadVersion == version do
					task.wait(math.max(0, state.reloadAt - os.clock()))
					if entry.reloadVersion ~= version then return end
					if firearms[player] ~= owned or owned[state.kind] ~= entry or entry.tool.Parent ~= character or not activeCharacter(player) or roundStatus.Value ~= "Running" then Firearm.cancelReload(state); entry.tool:SetAttribute("Reloading", false); return end
					local hasBox = false
					for _, stack in ipairs(inventories[player] or {}) do for _, item in ipairs(stack) do if item == chosen then hasBox = true end end end
					if not hasBox then Firearm.cancelReload(state); entry.tool:SetAttribute("Reloading", false); return end
					if Firearm.finishReload(state, chosen :: any, os.clock()) then
						entry.tool:SetAttribute("Loaded", state.loaded)
						refresh(player)
					elseif state.reloadAt and os.clock() >= state.reloadAt then
						Firearm.cancelReload(state)
					end
					if not state.reloadAt then entry.tool:SetAttribute("Reloading", false) end
				end
			end)
		elseif action == "Fire" and typeof(direction) == "Vector3" and direction.X == direction.X and direction.Y == direction.Y and direction.Z == direction.Z and direction.Magnitude > 0.9 and direction.Magnitude < 1.1 then
			if not Firearm.fire(state, os.clock()) then return end
			player:SetAttribute("FNABKImmuneUntil", nil)
			entry.reloadVersion += 1
			entry.tool:SetAttribute("Reloading", false)
			entry.tool:SetAttribute("Loaded", state.loaded)
			gunshot:Fire(root.Position, if state.kind == "Rifle" then 120 elseif state.kind == "Shotgun" then 100 else 60)
			-- ponytail: built-in temporary cue; replace with reviewed firearm audio.
			local sound = Instance.new("Sound")
			sound.Name, sound.SoundId, sound.Volume = "FirearmCue", "rbxasset://sounds//metal2.mp3", .6
			sound.PlaybackSpeed = if state.kind == "Rifle" then 1.5 elseif state.kind == "Shotgun" then .7 else 1
			sound.RollOffMaxDistance, sound.Parent = 120, root
			sound:Play()
			Debris:AddItem(sound, 3)
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local aim = CFrame.lookAt(Vector3.zero, direction.Unit)
			local totals: { [Model]: number } = {}
			local pellets = if state.kind == "Shotgun" then 6 else 1
			for i = 1, pellets do
				-- ponytail: fixed narrow six-ray spread; tune after shotgun playtesting.
				local angle = (i - 1) * math.pi / 3
				local ray = if pellets == 1 then direction.Unit else (direction.Unit + aim.RightVector * math.cos(angle) * 0.025 + aim.UpVector * math.sin(angle) * 0.025).Unit
				local hit = Workspace:Raycast(origin, ray * (if pellets == 1 then 300 else 65), params)
				local instance = hit and hit.Instance
				while instance and instance ~= Workspace do
					if instance:IsA("Model") and (Players:GetPlayerFromCharacter(instance) or (instance:IsDescendantOf(map) and (instance:GetAttribute("NPCType") == "Student" or instance:GetAttribute("NPCType") == "Mimic" or instance:GetAttribute("NPCType") == "Creature" or instance:GetAttribute("NPCType") == "Machine"))) then
						local damage = if pellets == 1 then (if state.kind == "Rifle" then 35 else 25) else Firearm.shotgunPelletDamage((hit :: RaycastResult).Distance)
						totals[instance] = (totals[instance] or 0) + damage
						break
					end
					instance = instance.Parent
				end
			end
			local wrongful = false
			for instance, damage in pairs(totals) do
				local target = Players:GetPlayerFromCharacter(instance)
				if target and target ~= player and damage > 0 then applyDamage(target, 5)
				elseif instance:GetAttribute("NPCType") == "Student" and damage > 0 then
					local hit = SurvivorHealth.Hit(instance, damage)
					if hit then SurvivorDefense.attacked(instance, player, applyDamage) end
					wrongful = hit or wrongful
				else
					EnemyHealth.damage(instance, damage)
				end
			end
			if wrongful then
				local trust = roundState:FindFirstChild("Trust")
				if trust and trust:IsA("IntValue") then trust.Value = math.max(0, trust.Value - 10) end
				feedback:FireClient(player, "WrongfulHit", "Survivor hit")
			end
		end
	end)
	local campus = Workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6")
	local props = campus and campus:FindFirstChild("CuratedUserProps_20261104")
	local kit = props and props:FindFirstChild("MedicalKit")
	if kit and kit:IsA("Model") then
		local bounds, size = kit:GetBoundingBox()
		local anchor = Instance.new("Part")
		anchor.Name = "MedkitPickupAnchor"
		anchor.Size, anchor.CFrame = size, bounds
		anchor.Transparency, anchor.Anchored = 1, true
		anchor.CanCollide, anchor.CanTouch, anchor.CanQuery = false, false, true
		anchor.Parent = kit
		kit:SetAttribute("VisualOnly", false)
		registerPickup(anchor, kit)
	end
	for name, kind in pairs({ FoodApple = "Food", CannedFood = "Food", WaterBottle = "Water", CanteenWater = "Water" }) do
		local visual = props and props:FindFirstChild(name)
		if visual and visual:IsA("Model") then
			local bounds, size = visual:GetBoundingBox()
			local anchor = Instance.new("Part")
			anchor.Name = "SupplyPickupAnchor"
			anchor.Size, anchor.CFrame = size, bounds
			anchor.Transparency, anchor.Anchored = 1, true
			anchor.CanCollide, anchor.CanTouch, anchor.CanQuery = false, false, true
			anchor.Parent = visual
			registerPickup(anchor, visual, kind)
		end
	end

	request.OnServerEvent:Connect(function(player: Player)
		local _, humanoid = activeCharacter(player)
		if roundStatus.Value ~= "Running" or not humanoid then
			feedback:FireClient(player, "MedkitRejected")
		elseif not inventories[player] or Inventory.count(inventories[player], "Medkit") == 0 then
			feedback:FireClient(player, "MedkitNoItem")
		elseif humanoid.Health >= humanoid.MaxHealth then
			feedback:FireClient(player, "MedkitFullHealth")
		else
			local before = humanoid.Health
			Inventory.removeFirst(inventories[player], "Medkit")
			refresh(player)
			humanoid.Health = math.min(humanoid.MaxHealth, before + config.medkitHealAmount)
			feedback:FireClient(player, "MedkitUsed", string.format("+%d HP", math.floor(humanoid.Health - before + 0.5)))
		end
	end)
	print("[FNABK][Medkit] Pickups ready; R heals the carrier")
	local function snapshotSupplies()
		local buildings, bagSnapshots, carried, pickups, supplies = {}, {}, {}, {}, {}
		local now = os.clock()
		local function weaponSnapshot(owned)
			local result = {}
			for kind, entry in pairs(owned) do
				local state = Firearm.snapshot(entry.state, now)
				if not state then return nil end
				state.id = entry.id
				result[kind] = state
			end
			return result
		end
		for player, owned in pairs(firearms) do
			local saved = weaponSnapshot(owned)
			if not saved then return nil end
			table.insert(carried, { owner = player.UserId, weapons = saved })
		end
		for userId, owned in pairs(absentFirearms) do
			local saved = weaponSnapshot(owned)
			if not saved then return nil end
			table.insert(carried, { owner = userId, weapons = saved })
		end
		table.sort(carried, function(a, b) return a.owner < b.owner end)
		for name, slots in pairs(storages) do
			table.insert(buildings, { name = name, upgraded = storageUpgraded[name] == true, items = Inventory.snapshot(slots) })
		end
		table.sort(buildings, function(a, b) return a.name < b.name end)
		for bag, record in pairs(bags) do
			local weapons = weaponSnapshot(record.weapons)
			if not weapons then return nil end
			local p = bag.Position
			table.insert(bagSnapshots, { owner = record.owner, position = { p.X, p.Y, p.Z }, items = Inventory.snapshot(record.items), weapons = weapons })
		end
		for pickup, record in pairs(worldWeapons) do
			local p = pickup.Position
			table.insert(pickups, { id = record.id, kind = record.kind, loaded = 0, cooldown = 0, position = { p.X, p.Y, p.Z } })
		end
		for box, record in pairs(worldSupplies) do
			local p = box.Position
			table.insert(supplies, { item = table.clone(record.item), position = { p.X, p.Y, p.Z }, point = record.point,
				slot = record.slot, unmarked = record.unmarked, visual = record.visual })
		end
		return { players = sessions:snapshot(), buildings = buildings, bags = bagSnapshots, carried = carried,
			weaponPickups = pickups, supplies = supplies, processedDay = processedDay }
	end
	-- ponytail: fresh daily stock only; the complete coordinator must restore all other state before use.
	local function restoreDaily(snapshot: any): boolean
		if dailyRestored or processedDay ~= 1 or #dailyFolder:GetChildren() ~= 0 then return false end
		local expected = {}
		for name in pairs(storages) do expected[name] = true end
		local _, _, _, _, _, supplies = SessionSupplies.restoreBuildings(snapshot, expected)
		if not supplies then return false end
		for _, entry in ipairs(supplies) do
			if entry.point then
				createDaily(entry.point, entry.slot, Vector3.new(table.unpack(entry.position)), entry.item.kind, entry.item.rounds, entry.item.id)
			end
		end
		processedDay = snapshot.processedDay
		dailyRestored = true
		dailyFolder:SetAttribute("ProcessedDay", processedDay)
		return true
	end
	local function defenseSnapshot()
		return if defenseState then { B1 = { installed = defenseState.installed, health = defenseState.health } } else nil
	end
	-- ponytail: one B1 defense; add reviewed entrances as their state is implemented.
	local function restoreDefense(data: any): boolean
		if defenseRestored or not defenseState or not defensePart or not updateDefense or type(data) ~= "table" then return false end
		for key in pairs(data) do if key ~= "B1" then return false end end
		local restored = Barricade.restore(data.B1)
		if not restored or defenseState.installed or defenseState.health ~= 0 then return false end
		if restored.installed and restored.health > 0 then
			local overlap = OverlapParams.new()
			overlap.FilterType, overlap.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { defensePart }
			for _, part in ipairs(Workspace:GetPartBoundsInBox(defensePart.CFrame, defensePart.Size, overlap)) do
				local model = part:FindFirstAncestorOfClass("Model")
				if model and model:FindFirstChildOfClass("Humanoid") then return false end
			end
		end
		defenseState.installed, defenseState.health = restored.installed, restored.health
		defenseRestored = true
		updateDefense()
		return true
	end
	return function(player: Player, position: Vector3)
		dropBag(player, position)
		local state = needs[player]
		if state then state.food, state.water, state.deprived = 50, 50, 0; refreshNeeds(player) end
	end, snapshotSupplies, restoreDaily, defenseSnapshot, restoreDefense
end

return table.freeze(MedkitService)
