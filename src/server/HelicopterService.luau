--!strict
-- Temporary landed helicopter/boarding zone, server-owned (SURV-11).
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HelicopterService = {}

function HelicopterService.Start(campus: Model, phase: StringValue, finish: (boolean) -> (), saved: any?)
	local aboard: { [Player]: boolean } = {}
	local zone: BasePart? = nil
	local craft: Model? = nil
	local departed = false
	local members: { [number]: { name: string, player: Player? } } = {}
	local pending: { [number]: boolean } = {}
	if saved ~= nil then
		assert(phase.Value == "Boarding" and type(saved) == "table" and saved.version == 1 and type(saved.members) == "table", "Invalid helicopter snapshot")
		local count = 0
		for key in pairs(saved.members) do
			assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= 256, "Invalid helicopter roster")
			count += 1
		end
		for i = 1, count do
			local record = saved.members[i]
			assert(type(record) == "table" and type(record.userId) == "number" and record.userId ~= 0
				and record.userId % 1 == 0 and math.abs(record.userId) < math.huge
				and type(record.name) == "string" and #record.name > 0 and #record.name <= 100
				and type(record.aboard) == "boolean" and not members[record.userId], "Invalid helicopter member")
			members[record.userId] = { name = record.name, player = nil }
			pending[record.userId] = record.aboard
		end
	end
	local vote: { expires: number, votes: { [Player]: boolean } }? = nil
	local warned: { [Player]: boolean } = {}
	local remotes = ReplicatedStorage:WaitForChild("FNABKRemotes")
	local remote = Instance.new("RemoteEvent")
	remote.Name, remote.Parent = "DepartureVote", remotes
	local function roster()
		local result = {}
		for _, member in pairs(members) do
			local p = member.player
			if not p or not aboard[p] then
				table.insert(result, member.name .. " (" .. (if not p then "disconnected" elseif p:GetAttribute("FNABKEliminated") then "eliminated" elseif p:GetAttribute("FNABKDowned") then "downed" else "outside") .. ")")
			end
		end
		table.sort(result)
		return result
	end
	local function broadcast()
		remote:FireAllClients("Roster", roster())
	end
	local function remember(player: Player)
		members[player.UserId] = { name = player.DisplayName, player = player }
		player:GetAttributeChangedSignal("FNABKDowned"):Connect(broadcast)
		player:GetAttributeChangedSignal("FNABKEliminated"):Connect(broadcast)
		broadcast()
	end
	Players.PlayerAdded:Connect(remember)
	for _, player in ipairs(Players:GetPlayers()) do remember(player) end
	local function cancelVote()
		if vote then vote = nil; remote:FireAllClients("Canceled") end
	end
	local function updateRoster()
		if not zone then return end
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local inside = false
			if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0
				and player:GetAttribute("FNABKEliminated") ~= true and character:GetAttribute("FNABKEliminated") ~= true then
				local offset = zone.CFrame:PointToObjectSpace(root.Position)
				inside = math.abs(offset.X) <= zone.Size.X / 2 and math.abs(offset.Z) <= zone.Size.Z / 2 and offset.Y >= -1 and offset.Y <= 8
			end
			if (player:GetAttribute("FNABKDowned") == true or (character and character:GetAttribute("FNABKDowned") == true)) and not aboard[player] then inside = false end
			if (aboard[player] == true) ~= inside then
				cancelVote(); aboard[player] = inside
				if not inside then warned[player] = nil end
				broadcast()
			end
			player:SetAttribute("FNABKAboard", inside)
		end
	end
	local depart: () -> ()
	Players.PlayerRemoving:Connect(function(player)
		if members[player.UserId] then members[player.UserId].player = nil end
		if aboard[player] then cancelVote() end
		aboard[player] = nil
		pending[player.UserId] = nil
		warned[player] = nil
		player:SetAttribute("FNABKAboard", false)
		broadcast()
	end)
	remote.OnServerEvent:Connect(function(player, action, choice)
		if phase.Value == "Boarding" and not departed then updateRoster() end
		local character = player.Character
		if phase.Value ~= "Boarding" or departed or not aboard[player] or player:GetAttribute("FNABKDowned") == true
			or player:GetAttribute("FNABKEliminated") == true or not character
			or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true then return end
		if action == "Warning" then
			warned[player] = true
			remote:FireClient(player, "Warning", roster())
		elseif action == "CancelWarning" then
			warned[player] = nil
		elseif action == "Start" and warned[player] and not vote then
			warned[player] = nil
			vote = { expires = os.clock() + 10, votes = { [player] = true } }
			local count = 0
			for _, present in pairs(aboard) do if present then count += 1 end end
			if count == 1 then depart(); return end
			remote:FireAllClients("Started", 10)
		elseif action == "Vote" and vote and os.clock() < vote.expires and (choice == true or choice == false or choice == "withdraw") then
			vote.votes[player] = if choice == "withdraw" then nil else choice
			local yes, count = 0, 0
			for candidate, present in pairs(aboard) do
				if present then count += 1; if vote.votes[candidate] == true then yes += 1 end end
			end
			if yes > count / 2 then depart() end
		end
	end)
	local function arrive()
		if zone then return end
		local field = campus:FindFirstChild("FootballField", true)
		assert(field and field:IsA("Model"), "Football field missing")
		local cf = field:GetBoundingBox()
		local marking = field:FindFirstChild("CourtMarking")
		assert(marking and marking:IsA("BasePart"), "Football field surface missing")
		local pad = Instance.new("Part")
		pad.Name, pad.Size = "FNABKHelicopterBoarding", Vector3.new(20, 1, 14)
		pad.CFrame = CFrame.new(cf.Position.X, marking.Position.Y + 0.5, cf.Position.Z)
		pad.Anchored, pad.CanCollide = true, false
		pad.Color, pad.Material = Color3.fromRGB(100, 105, 91), Enum.Material.Metal
		pad.Parent = Workspace
		zone = pad
		-- ponytail: simple non-collidable aircraft shell; replace with a reviewed boardable model.
		local model = Instance.new("Model")
		model.Name = "FNABKRescueHelicopter"
		local function part(name: string, size: Vector3, offset: CFrame, color: Color3)
			local piece = Instance.new("Part")
			piece.Name, piece.Size, piece.CFrame = name, size, pad.CFrame * offset
			piece.Anchored, piece.CanCollide, piece.CanTouch, piece.CanQuery = true, false, false, false
			piece.Material, piece.Color, piece.Parent = Enum.Material.Metal, color, model
		end
		local hull, dark = Color3.fromRGB(102, 112, 100), Color3.fromRGB(43, 52, 50)
		part("Roof", Vector3.new(15, 1, 12), CFrame.new(1, 7, 0), hull)
		part("RearWall", Vector3.new(1, 7, 12), CFrame.new(8, 3.5, 0), hull)
		part("FrontWall", Vector3.new(1, 7, 12), CFrame.new(-6, 3.5, 0), hull)
		part("Cockpit", Vector3.new(6, 4, 10), CFrame.new(-9, 3, 0), dark)
		part("Tail", Vector3.new(15, 2, 2), CFrame.new(16, 4, 0), hull)
		part("TailFin", Vector3.new(3, 5, 1), CFrame.new(22, 6, 0), hull)
		part("RotorMast", Vector3.new(1, 2, 1), CFrame.new(1, 8.5, 0), dark)
		part("RotorA", Vector3.new(28, .3, 1), CFrame.new(1, 9.5, 0), dark)
		part("RotorB", Vector3.new(1, .3, 28), CFrame.new(1, 9.6, 0), dark)
		model.Parent = Workspace
		craft = model
	end
	phase.Changed:Connect(function()
		if phase.Value == "Boarding" then arrive() end
	end)
	if phase.Value == "Boarding" then arrive() end
	task.spawn(function()
		while phase.Parent do
			if phase.Value == "Boarding" and zone then
				updateRoster()
			end
			if vote and os.clock() >= vote.expires then cancelVote() end
			task.wait(0.1)
		end
	end)
	depart = function()
		if departed then return end
		updateRoster()
		departed = true
		cancelVote()
		local rescued = false
		local results = Instance.new("Folder")
		results.Name = "RescueResults"
		for userId, member in pairs(members) do
			local player = member.player
			local result = if not player then "Disconnected" elseif player:GetAttribute("FNABKEliminated") == true or (player.Character and player.Character:GetAttribute("FNABKEliminated") == true) then "Eliminated" elseif aboard[player] then "Rescued" else "LeftBehind"
			local entry = Instance.new("StringValue")
			entry.Name, entry.Value = tostring(userId), result
			entry:SetAttribute("DisplayName", member.name)
			entry.Parent = results
			if result == "Rescued" then rescued = true end
			if player then
				player:SetAttribute("FNABKRescueResult", result)
				player:SetAttribute("FNABKAboard", false)
			end
		end
		results:SetAttribute("GroupRescued", rescued)
		results.Parent = ReplicatedStorage:WaitForChild("FNABKRoundState")
		if craft then craft:Destroy(); craft = nil end
		finish(rescued)
	end
	local function isAboard(player: Player): boolean
		if phase.Value ~= "Boarding" or departed then return false end
		updateRoster()
		return aboard[player] == true
	end
	local function snapshot()
		if phase.Value ~= "Boarding" or departed then return nil end
		updateRoster()
		local result = {}
		for userId, member in pairs(members) do
			table.insert(result, { userId = userId, name = member.name, aboard = (member.player ~= nil and aboard[member.player] == true) or pending[userId] == true })
		end
		table.sort(result, function(a, b) return a.userId < b.userId end)
		return { version = 1, members = result }
	end
	-- ponytail: the coordinator calls after life state is restored; downed rejoin needs full life-state support.
	local function restoreAboard(player: Player): boolean
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if phase.Value ~= "Boarding" or departed or not zone or not pending[player.UserId] or not members[player.UserId]
			or members[player.UserId].player ~= player or not character or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
			or player:GetAttribute("FNABKEliminated") == true or character:GetAttribute("FNABKEliminated") == true
			or player:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKDowned") == true then return false end
		character:PivotTo(zone.CFrame * CFrame.new(0, 3, 0))
		pending[player.UserId] = nil
		return isAboard(player)
	end
	return depart, isAboard, snapshot, restoreAboard
end

return table.freeze(HelicopterService)
