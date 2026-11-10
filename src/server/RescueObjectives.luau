--!strict
-- Temporary shared rescue stations (SURV-01/11); assignments are server-owned.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RescueObjectives = {}

-- The complete run must be validated and restored atomically by the future save coordinator.
function RescueObjectives.snapshot(folder: Folder): { [string]: any }?
	local result = { version = 1, stations = {}, sent = false }
	for _, kind in ipairs({ "Power", "Frequency", "Transmitter" }) do
		local flag = folder:FindFirstChild(kind)
		if not flag or not flag:IsA("BoolValue") then return nil end
		local building, position = flag:GetAttribute("Building"), flag:GetAttribute("Position")
		if type(building) ~= "string" or typeof(position) ~= "Vector3" then return nil end
		result.stations[kind] = { building = building, x = position.X, y = position.Y, z = position.Z, complete = flag.Value }
	end
	local sent = folder:FindFirstChild("SignalSent")
	if not sent or not sent:IsA("BoolValue") then return nil end
	result.sent = sent.Value
	return result
end

function RescueObjectives.Start(campus: Model, signal: () -> boolean, saved: any?)
	local round = ReplicatedStorage:WaitForChild("FNABKRoundState")
	local status = round:WaitForChild("RoundStatus") :: StringValue
	local random = Random.new()
	-- ponytail: candidate floors are placeholders; review each accessible mission location.
	local specs = {
		{ "Power", { "B3", "B4", "B6" } },
		{ "Frequency", { "A1", "A2", "A4" } },
		{ "Transmitter", { "C1", "C2", "C3" } },
	}
	local selected = {}
	if saved ~= nil then
		assert(type(saved) == "table" and saved.version == 1 and type(saved.stations) == "table" and type(saved.sent) == "boolean", "Invalid rescue snapshot")
	end
	for _, spec in ipairs(specs) do
		local kind, candidates = spec[1] :: string, spec[2] :: { string }
		local available = {}
		for _, name in ipairs(candidates) do
			local building = campus.Buildings:FindFirstChild(name)
			local floor: BasePart? = nil
			if building then
				for _, part in ipairs(building:GetDescendants()) do
					if part:IsA("BasePart") and (part.Name:find("WalkableFloor") or part.Name == "WestFloor") and (not floor or part.Position.Y < floor.Position.Y) then floor = part end
				end
			end
			if floor then table.insert(available, { floor = floor, name = name }) end
		end
		assert(#available > 0, "No candidate floor for " .. kind)
		local entry = if saved then saved.stations[kind] else nil
		local choice = if not saved then available[random:NextInteger(1, #available)] else nil
		if saved then
			assert(type(entry) == "table" and type(entry.building) == "string" and type(entry.complete) == "boolean"
				and type(entry.x) == "number" and type(entry.y) == "number" and type(entry.z) == "number"
				and math.abs(entry.x) < 100000 and math.abs(entry.y) < 100000 and math.abs(entry.z) < 100000, "Invalid rescue station")
			for _, candidate in ipairs(available) do
				if candidate.name == entry.building then choice = candidate; break end
			end
			assert(choice, "Saved rescue building unavailable")
			local expected = choice.floor.CFrame * CFrame.new(4, choice.floor.Size.Y / 2 + 1, 0)
			assert((expected.Position - Vector3.new(entry.x, entry.y, entry.z)).Magnitude < 0.05, "Saved rescue station moved")
		end
		selected[kind] = { choice = choice, complete = if entry then entry.complete else false }
	end
	if saved and saved.sent then
		for _, station in pairs(selected) do assert(station.complete, "Signal without rescue objectives") end
	end
	local folder = Instance.new("Folder")
	folder.Name, folder.Parent = "RescueObjectives", round
	local points = Instance.new("Folder")
	points.Name, points.Parent = "FNABKRescueStations", Workspace
	local flags: { BoolValue } = {}
	local lastPoint: BasePart? = nil
	local function createStation(kind: string, floor: BasePart): BasePart
		local point = Instance.new("Part")
		point.Name, point.Size = kind, Vector3.new(2, 2, 2)
		point.CFrame = floor.CFrame * CFrame.new(4, floor.Size.Y / 2 + 1, 0)
		point.Anchored, point.CanCollide = true, false
		point.Color = if kind == "Power" then Color3.fromRGB(78, 88, 82) elseif kind == "Frequency" then Color3.fromRGB(154, 142, 113) else Color3.fromRGB(68, 76, 73)
		point.Parent = points
		local detail = Instance.new("Part")
		detail.Name = if kind == "Power" then "Switch" elseif kind == "Frequency" then "FrequencyRecord" else "Antenna"
		detail.Size = if kind == "Power" then Vector3.new(.25, .8, .25) elseif kind == "Frequency" then Vector3.new(1.4, .08, 1) else Vector3.new(.12, 2, .12)
		detail.CFrame = point.CFrame * (if kind == "Power" then CFrame.new(0, .25, -1.1) elseif kind == "Frequency" then CFrame.new(0, 1.05, 0) else CFrame.new(.65, 1.9, 0))
		detail.Color = if kind == "Frequency" then Color3.fromRGB(226, 219, 194) else Color3.fromRGB(35, 39, 37)
		detail.CanCollide, detail.CanTouch, detail.CanQuery, detail.Massless = false, false, false, true
		detail.Parent = point
		local weld = Instance.new("WeldConstraint")
		weld.Part0, weld.Part1, weld.Parent = point, detail, detail
		return point
	end
	local function prompt(point: BasePart, action: string, callback: (Player) -> (), hold: number?): ProximityPrompt
		local p = Instance.new("ProximityPrompt")
		p.ActionText, p.ObjectText = action, point.Name
		p.MaxActivationDistance, p.RequiresLineOfSight = 6, false
		p.KeyboardKeyCode = Enum.KeyCode.G
		p.HoldDuration = if hold then hold + .25 else 0
		p.Parent = point
		local started: { [Player]: number } = {}
		local function eligible(player: Player): boolean
			if not p.Enabled or not player.Parent or status.Value ~= "Running" or player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true then return false end
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not character or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
				or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") or (root.Position - point.Position).Magnitude > 6 then return false end
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, point.Position - origin, params)
			return hit ~= nil and hit.Instance == point
		end
		if hold then
			p.PromptButtonHoldBegan:Connect(function(player)
				started[player] = if eligible(player) then os.clock() else nil
				local began = started[player]
				if not began then return end
				task.spawn(function()
					while started[player] == began do
						if not eligible(player) then started[player] = nil; break end
						task.wait(.1)
					end
				end)
			end)
			p.PromptButtonHoldEnded:Connect(function(player)
				local began = started[player]
				if began and os.clock() - began < hold then started[player] = nil
				elseif began then task.delay(.5, function() if started[player] == began then started[player] = nil end end) end
			end)
		end
		p.Triggered:Connect(function(player)
			local began = started[player]
			started[player] = nil
			if (not hold or (began and os.clock() - began >= hold)) and eligible(player) then callback(player) end
		end)
		return p
	end
	for _, spec in ipairs(specs) do
		local kind = spec[1] :: string
		local choice = selected[kind].choice
		local floor = choice.floor
		local station = createStation(kind, floor)
		if saved then
			local entry = saved.stations[kind]
			station.CFrame = CFrame.new(entry.x, entry.y, entry.z) * station.CFrame.Rotation
		end
		local flag = Instance.new("BoolValue")
		flag.Name = kind
		flag:SetAttribute("Building", choice.name)
		-- ponytail: candidates use the lowest detected floor; replace with reviewed floor identifiers.
		flag:SetAttribute("Floor", "Lowest level")
		flag:SetAttribute("Position", station.Position)
		flag.Value = selected[kind].complete
		flag.Parent = folder
		table.insert(flags, flag)
		local action: ProximityPrompt
		local actionText = if kind == "Power" then "Restore power" elseif kind == "Frequency" then "Find frequency" else "Collect transmitter"
		action = prompt(station, actionText, function() flag.Value = true; action.Enabled = false end, if kind == "Power" then 3 else nil)
		action.Enabled = not flag.Value
		lastPoint = station
	end
	local transmitter = lastPoint :: BasePart
	local sent = Instance.new("BoolValue")
	sent.Name, sent.Parent = "SignalSent", folder
	sent.Value = if saved then saved.sent else false
	local signalPrompt: ProximityPrompt
	signalPrompt = prompt(transmitter, "Send signal", function()
		for _, flag in ipairs(flags) do if not flag.Value then return end end
		if not sent.Value and signal() then sent.Value = true; signalPrompt.Enabled = false end
	end)
	signalPrompt.Enabled = not sent.Value and flags[1].Value and flags[2].Value and flags[3].Value
	for _, flag in ipairs(flags) do
		flag.Changed:Connect(function()
			for _, required in ipairs(flags) do if not required.Value then return end end
			if not sent.Value then signalPrompt.Enabled = true end
		end)
	end
end

return table.freeze(RescueObjectives)
