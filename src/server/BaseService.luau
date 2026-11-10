--!strict
-- SURV-03/04: server-owned active-building selection; upgrades and storage follow later.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Proposal = require(script.Parent:WaitForChild("BaseProposal"))
local HostIdentity = require(script.Parent:WaitForChild("HostIdentity"))
local BaseService = {}

function BaseService.Start(campus: Model, saved: any?)
	local buildings = campus:FindFirstChild("Buildings")
	assert(buildings, "Campus buildings missing")
	local restored = ""
	if saved ~= nil then
		assert(type(saved) == "table" and saved.version == 1 and type(saved.active) == "string", "Invalid base snapshot")
		restored = saved.active
		if restored ~= "" then
			local matches, validFloor = 0, false
			for _, building in ipairs(buildings:GetChildren()) do
				if building:IsA("Model") and building.Name == restored then
					matches += 1
					for _, part in ipairs(building:GetDescendants()) do
						if part:IsA("BasePart") and (part.Name:find("WalkableFloor") or part.Name == "WestFloor") then validFloor = true end
					end
				end
			end
			assert(matches == 1 and validFloor, "Saved base is missing or ambiguous")
		end
	end
	local round = ReplicatedStorage:WaitForChild("FNABKRoundState")
	local status = round:WaitForChild("RoundStatus") :: StringValue
	local active = Instance.new("StringValue")
	active.Name = "ActiveBase"
	active.Value = restored
	active.Parent = round
	local host = round:FindFirstChild("HostUserId")
	if not host then
		host = Instance.new("IntValue")
		host.Name = "HostUserId"
		host.Parent = round
	end
	assert(host:IsA("IntValue"), "HostUserId must be an IntValue")
	-- PrivateServerOwnerId comes from Roblox, not join data supplied by a client.
	local privateOwner = HostIdentity.resolve(host.Value, false, 0, game.PrivateServerOwnerId)
	if privateOwner then host.Value = privateOwner end
	local function assignStudioHost(player: Player)
		if not RunService:IsStudio() or host.Value ~= 0 then return end
		-- ponytail: Studio chooses the first test player; a production lobby must provision the host.
		local resolved = HostIdentity.resolve(0, true, player.UserId)
		if resolved then host.Value = resolved end
	end
	Players.PlayerAdded:Connect(assignStudioHost)
	for _, player in ipairs(Players:GetPlayers()) do assignStudioHost(player) end
	local remotes = ReplicatedStorage:WaitForChild("FNABKRemotes")
	local notice = Instance.new("RemoteEvent")
	notice.Name, notice.Parent = "BaseNotice", remotes
	local confirm = Instance.new("RemoteEvent")
	confirm.Name, confirm.Parent = "BaseConfirm", remotes
	local proposal = Proposal.new()
	local function canAct(player: Player): boolean
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		return player.Parent == Players and player:GetAttribute("FNABKDowned") ~= true
			and player:GetAttribute("FNABKEliminated") ~= true and character ~= nil
			and character:GetAttribute("FNABKDowned") ~= true and character:GetAttribute("FNABKEliminated") ~= true
			and humanoid ~= nil and humanoid.Health > 0
	end
	local function cancelProposal()
		if proposal.pending then
			Proposal.cancel(proposal)
			notice:FireAllClients("Canceled")
		end
	end
	Players.PlayerRemoving:Connect(function(player)
		if proposal.pending and proposal.pending.host == player.UserId then cancelProposal() end
	end)
	host.Changed:Connect(cancelProposal)
	status.Changed:Connect(function() if status.Value ~= "Running" then cancelProposal() end end)
	confirm.OnServerEvent:Connect(function(player: Player, id: unknown)
		if typeof(id) ~= "number" or id % 1 ~= 0 or status.Value ~= "Running" or host.Value ~= player.UserId or not canAct(player) then return end
		local building = Proposal.confirm(proposal, id, player.UserId, os.clock())
		if building then active.Value = building; notice:FireAllClients("Confirmed", building) end
	end)
	local anchors = Instance.new("Folder")
	anchors.Name = "FNABKBaseClaimPoints"
	anchors.Parent = Workspace
	for _, building in ipairs(buildings:GetChildren()) do
		if not building:IsA("Model") then continue end
		local floor: BasePart? = nil
		for _, part in ipairs(building:GetDescendants()) do
			if not part:IsA("BasePart") or not (part.Name:find("WalkableFloor") or part.Name == "WestFloor") then continue end
			if not floor or part.Position.Y < floor.Position.Y then floor = part end
		end
		if not floor then warn("[FNABK][Base] No floor for " .. building.Name); continue end
		local point = Instance.new("Part")
		point.Name = building.Name
		point.Size = Vector3.new(1, 1, 1)
		point.CFrame = floor.CFrame * CFrame.new(0, floor.Size.Y / 2 + 1, 0)
		point.Anchored, point.CanCollide, point.CanTouch = true, false, false
		point.Transparency = 1
		point.Parent = anchors
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText, prompt.ObjectText = "Choose base", building.Name
		prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 6, false
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.Parent = point
		prompt.Triggered:Connect(function(player: Player)
			if status.Value ~= "Running" or not canAct(player) then return end
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not character or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
				or (root.Position - point.Position).Magnitude > 6 then return end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { character }
			local origin = root.Position + Vector3.new(0, 1.5, 0)
			local hit = Workspace:Raycast(origin, point.Position - origin, params)
			if not hit or hit.Instance ~= point then return end
			if proposal.pending then notice:FireClient(player, "Pending"); return end
			if HostIdentity.canClaimSolo(#Players:GetPlayers(), host.Value, player.UserId) then
				active.Value = building.Name
				notice:FireAllClients("Confirmed", building.Name)
				return
			end
			local hostPlayer = Players:GetPlayerByUserId(host.Value)
			if not hostPlayer then notice:FireClient(player, "Unavailable"); return end
			local id = Proposal.begin(proposal, building.Name, hostPlayer.UserId, os.clock())
			if not id then notice:FireClient(player, "Pending"); return end
			notice:FireAllClients("Proposed", building.Name, id, hostPlayer.UserId)
			task.delay(10, function()
				if proposal.pending and proposal.pending.id == id then
					notice:FireAllClients("Ready", building.Name, id, hostPlayer.UserId)
				end
			end)
		end)
	end
	-- ponytail: a pending relocation is discarded on resume; add persistence only if design requires it.
	return function() return { version = 1, active = active.Value } end
end

return table.freeze(BaseService)
