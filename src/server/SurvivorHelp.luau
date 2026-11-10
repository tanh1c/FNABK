--!strict
-- SURV-13: one shared help reward per survivor per in-game day.
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RescueHint = require(script.Parent:WaitForChild("RescueHint"))
local Inventory = require(script.Parent:WaitForChild("Inventory"))
local SurvivorHealth = require(script.Parent:WaitForChild("SurvivorHealth"))
local Help = {}

-- ponytail: defense timers are not saved; reject until their lifecycle is persisted.
function Help.snapshot(map: Instance, trust: IntValue, day: number): any?
	if type(day) ~= "number" or day % 1 ~= 0 or day < 1 or day > 5 or trust.Value < 0 or trust.Value > 100 then return nil end
	local entries, seen = {}, {}
	for _, npc in ipairs(map:GetDescendants()) do
		if not npc:IsA("Model") or npc:GetAttribute("NPCType") ~= "Student" then continue end
		local name, state = npc.Name, npc:GetAttribute("StudentState")
		local health = npc:GetAttribute("SurvivorHealth")
		local recoveryAt = npc:GetAttribute("SurvivorRecoveryAt")
		local recovery = if state == "Incapacitated" and type(recoveryAt) == "number" then math.max(0, recoveryAt - os.clock()) else nil
		local helpDay, quest, taken = npc:GetAttribute("HelpRewardDay") or 0, npc:GetAttribute("FoodQuestCompleted"), npc:GetAttribute("TradeTaken") or 0
		local wary = npc:GetAttribute("TradeWary") == true
		local waryStock, waryTaken = npc:GetAttribute("TradeWaryStock") or 0, npc:GetAttribute("TradeWaryTaken") or 0
		if name == "" or seen[name] or state == "Defending"
			or type(health) ~= "number" or health ~= health or health < 0 or health > 100
			or (state == "Incapacitated" and (health ~= 0 or recovery == nil or recovery ~= recovery or recovery > 60))
			or (state ~= "Incapacitated" and health == 0)
			or type(helpDay) ~= "number" or helpDay % 1 ~= 0 or helpDay < 0 or helpDay > day
			or (quest ~= nil and type(quest) ~= "boolean") or type(taken) ~= "number" or taken % 1 ~= 0 or taken < 0 or taken > 4
			or type(waryStock) ~= "number" or waryStock % 1 ~= 0 or waryStock < 0 or waryStock > 4
			or type(waryTaken) ~= "number" or waryTaken % 1 ~= 0 or waryTaken < 0 or waryTaken > waryStock
			or (trust.Value >= 70 and wary) or (trust.Value >= 30 and trust.Value < 70 and not wary)
			or (wary and waryStock ~= 4 - taken + waryTaken) then return nil end
		seen[name] = true
		table.insert(entries, { name = name, health = health, helpDay = helpDay, quest = quest == true, taken = taken,
			wary = wary, waryStock = waryStock, waryTaken = waryTaken, recovery = recovery })
	end
	table.sort(entries, function(a, b) return a.name < b.name end)
	return { version = 1, day = day, trust = trust.Value, students = entries }
end

function Help.restore(map: Instance, trust: IntValue, data: any, day: number): boolean
	if type(data) ~= "table" or data.version ~= 1 or data.day ~= day or type(data.trust) ~= "number"
		or data.trust % 1 ~= 0 or data.trust < 0 or data.trust > 100 or type(data.students) ~= "table" then return false end
	local current = Help.snapshot(map, trust, day)
	if not current then return false end
	for _, student in ipairs(current.students) do if student.recovery ~= nil then return false end end
	local models, saved, count = {}, {}, 0
	for _, npc in ipairs(map:GetDescendants()) do
		if npc:IsA("Model") and npc:GetAttribute("NPCType") == "Student" then models[npc.Name] = npc end
	end
	for key in pairs(data.students) do
		if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > 256 then return false end
		count += 1
	end
	if count ~= #current.students then return false end
	for i = 1, count do
		local e = data.students[i]
		if type(e) ~= "table" or type(e.name) ~= "string" or not models[e.name] or saved[e.name]
			or type(e.health) ~= "number" or e.health ~= e.health or e.health < 0 or e.health > 100
			or (e.health == 0 and (type(e.recovery) ~= "number" or e.recovery ~= e.recovery or e.recovery < 0 or e.recovery > 60))
			or (e.health > 0 and e.recovery ~= nil)
			or type(e.helpDay) ~= "number" or e.helpDay % 1 ~= 0 or e.helpDay < 0 or e.helpDay > day
			or type(e.quest) ~= "boolean" or type(e.taken) ~= "number" or e.taken % 1 ~= 0 or e.taken < 0 or e.taken > 4
			or type(e.wary) ~= "boolean" or type(e.waryStock) ~= "number" or e.waryStock % 1 ~= 0 or e.waryStock < 0 or e.waryStock > 4
			or type(e.waryTaken) ~= "number" or e.waryTaken % 1 ~= 0 or e.waryTaken < 0 or e.waryTaken > e.waryStock
			or (data.trust >= 70 and e.wary) or (data.trust >= 30 and data.trust < 70 and not e.wary)
			or (e.wary and e.waryStock ~= 4 - e.taken + e.waryTaken) then return false end
		saved[e.name] = e
	end
	for name, npc in pairs(models) do
		local e = saved[name]
		if e.health == 0 then SurvivorHealth.Incapacitate(npc, e.recovery) else npc:SetAttribute("SurvivorHealth", e.health) end
		npc:SetAttribute("HelpRewardDay", if e.helpDay == 0 then nil else e.helpDay)
		npc:SetAttribute("FoodQuestCompleted", e.quest)
		npc:SetAttribute("TradeTaken", e.taken)
		npc:SetAttribute("TradeWaryStock", e.waryStock)
		npc:SetAttribute("TradeWaryTaken", e.waryTaken)
		npc:SetAttribute("TradeWary", e.wary)
	end
	trust.Value = data.trust
	return true
end

function Help.deliverFood(student: Model, trust: IntValue, items: Inventory.Slots): boolean
	if student:GetAttribute("NPCType") ~= "Student" or student:GetAttribute("StudentState") == "Incapacitated"
		or student:GetAttribute("FoodQuestCompleted") == true or Inventory.count(items, "Food") < 1 then return false end
	Inventory.removeFirst(items, "Food")
	student:SetAttribute("FoodQuestCompleted", true)
	trust.Value = math.clamp(trust.Value + 10, 0, 100)
	return true
end

function Help.award(student: Model, trust: IntValue, day: number): boolean
	if student:GetAttribute("NPCType") ~= "Student" or student:GetAttribute("StudentState") == "Incapacitated"
		or day % 1 ~= 0 or day < 1 or student:GetAttribute("HelpRewardDay") == day then return false end
	student:SetAttribute("HelpRewardDay", day)
	trust.Value = math.clamp(trust.Value + 10, 0, 100)
	return true
end

function Help.repair(student: Model, trust: IntValue, day: number, items: Inventory.Slots): boolean
	if Inventory.count(items, "Scrap") < 1 or not Help.award(student, trust, day) then return false end
	assert(Inventory.removeFirst(items, "Scrap"))
	return true
end

function Help.deliverWater(student: Model, trust: IntValue, day: number, items: Inventory.Slots): boolean
	if Inventory.count(items, "Water") < 1 or not Help.award(student, trust, day) then return false end
	assert(Inventory.removeFirst(items, "Water"))
	return true
end

function Help.Start(map: Folder)
	local round = ReplicatedStorage:WaitForChild("FNABKRoundState")
	local day = round:WaitForChild("SurvivalDay") :: IntValue
	local status = round:WaitForChild("RoundStatus") :: StringValue
	local trust = round:WaitForChild("Trust") :: IntValue
	for _, student in ipairs(map:GetDescendants()) do
		if not student:IsA("Model") or student:GetAttribute("NPCType") ~= "Student" or not student.PrimaryPart then continue end
		local anchor = student.PrimaryPart
		local info = Instance.new("ProximityPrompt")
		info.Name, info.ActionText, info.ObjectText = "SurvivorInfo", "Ask about rescue", "Survivor"
		info.KeyboardKeyCode, info.MaxActivationDistance, info.RequiresLineOfSight = Enum.KeyCode.H, 6, false
		info.Parent = anchor
		info.Triggered:Connect(function(player)
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if status.Value ~= "Running" or student:GetAttribute("StudentState") == "Incapacitated"
				or player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true
				or not character or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
				or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
				or (root.Position - anchor.Position).Magnitude > 6 then return end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, anchor.Position - origin, params)
			if not hit or not hit.Instance:IsDescendantOf(student) then return end
			local objectives = round:FindFirstChild("RescueObjectives")
			local phase = round:FindFirstChild("SurvivalPhase")
			local remote = ReplicatedStorage.FNABKRemotes:FindFirstChild("ObjectiveHint")
			if not objectives or not phase or not phase:IsA("StringValue") or not remote or not remote:IsA("RemoteEvent") then return end
			local power, frequency, transmitter, sent = objectives:FindFirstChild("Power"), objectives:FindFirstChild("Frequency"), objectives:FindFirstChild("Transmitter"), objectives:FindFirstChild("SignalSent")
			if not power or not frequency or not transmitter or not sent or not power:IsA("BoolValue") or not frequency:IsA("BoolValue") or not transmitter:IsA("BoolValue") or not sent:IsA("BoolValue") then return end
			remote:FireClient(player, RescueHint.current(power.Value, frequency.Value, transmitter.Value, sent.Value, phase.Value))
		end)
		-- ponytail: native debris placeholder; replace with reviewed environmental props.
		local debris = Instance.new("Part")
		debris.Name, debris.Size = "SurvivorDebris", Vector3.new(3, 1, 2)
		debris.CFrame = anchor.CFrame * CFrame.new(4, -1.5, 0)
		debris.Anchored, debris.CanCollide, debris.Color = true, false, Color3.fromRGB(105, 94, 76)
		debris.Parent = map
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name, prompt.ActionText, prompt.ObjectText = "SurvivorHelp", "Clear debris", "Survivor"
		prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 3.25, 6, false
		prompt.Parent = debris
		local holds: { [Player]: number } = {}
		local function valid(player: Player): boolean
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if status.Value ~= "Running" or student:GetAttribute("StudentState") == "Incapacitated"
				or player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true
				or not character or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
				or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
				or (root.Position - debris.Position).Magnitude > 6 then return false end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, debris.Position - origin, params)
			return hit ~= nil and hit.Instance == debris
		end
		prompt.PromptButtonHoldBegan:Connect(function(player)
			holds[player] = if valid(player) then os.clock() else nil
			local started = holds[player]
			if not started then return end
			task.spawn(function()
				while holds[player] == started do
					if not valid(player) then holds[player] = nil; return end
					task.wait(0.1)
				end
			end)
		end)
		prompt.PromptButtonHoldEnded:Connect(function(player)
			local started = holds[player]
			if started and os.clock() - started < 3 then holds[player] = nil
			elseif started then task.delay(1, function() if holds[player] == started then holds[player] = nil end end) end
		end)
		prompt.Triggered:Connect(function(player)
			local started = holds[player]
			holds[player] = nil
			if started and os.clock() - started >= 3 and valid(player) then Help.award(student, trust, day.Value) end
		end)
		local function refresh()
			local available = student:GetAttribute("HelpRewardDay") ~= day.Value
			debris.Transparency, debris.CanQuery = if available then 0 else 1, available
			prompt.Enabled = available and student:GetAttribute("StudentState") ~= "Incapacitated"
		end
		student:GetAttributeChangedSignal("HelpRewardDay"):Connect(refresh)
		student:GetAttributeChangedSignal("StudentState"):Connect(refresh)
		day.Changed:Connect(refresh)
		refresh()
	end
end
return table.freeze(Help)
