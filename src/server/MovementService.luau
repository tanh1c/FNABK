--!strict
-- AC-01/AC-06/AC-09: server-owned stamina and one source of player speed.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

type Config = {
	playerMaxStamina: number, staminaDrainPerSecond: number,
	staminaRegenPerSecond: number, staminaRegenDelaySeconds: number,
	walkSpeed: number, sprintSpeed: number, crouchSpeed: number,
	cratePushWalkSpeed: number, crateCarryWalkSpeed: number,
}
type State = { sprint: boolean, crouch: boolean, stamina: number, lastSprint: number, exhausted: boolean }
local MovementService = {}

function MovementService.Start(config: Config)
	local remote = Instance.new("RemoteEvent")
	remote.Name = "MovementRequest"
	remote.Parent = ReplicatedStorage:WaitForChild("FNABKRemotes")
	local states: { [Player]: State } = {}
	local function apply(player: Player)
		local state = states[player]
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not state or not character or not humanoid then return end
		local incapacitated = humanoid.Health <= 0 or player:GetAttribute("FNABKDowned") == true
			or player:GetAttribute("FNABKEliminated") == true
			or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
		if incapacitated then
			state.sprint = false
			state.crouch = false
		end
		local speed = if incapacitated then 0 elseif state.crouch then config.crouchSpeed
			elseif state.sprint and not state.exhausted and state.stamina > 0 then config.sprintSpeed else config.walkSpeed
		if character:GetAttribute("FNABKCrateCarrying") == true then speed = math.min(speed, config.crateCarryWalkSpeed) end
		if character:GetAttribute("FNABKCratePushing") == true then speed = math.min(speed, config.cratePushWalkSpeed) end
		if humanoid.WalkSpeed ~= speed then humanoid.WalkSpeed = speed end
		player:SetAttribute("FNABKCrouching", state.crouch and not incapacitated)
	end
	local function watchCharacter(player: Player, character: Model)
		local state = states[player]
		if not state then return end
		state.sprint = false
		state.crouch = false
		character:GetAttributeChangedSignal("FNABKCrateCarrying"):Connect(function() apply(player) end)
		character:GetAttributeChangedSignal("FNABKCratePushing"):Connect(function() apply(player) end)
		character:GetAttributeChangedSignal("FNABKDowned"):Connect(function() apply(player) end)
		character:GetAttributeChangedSignal("FNABKEliminated"):Connect(function() apply(player) end)
		task.spawn(function()
			character:WaitForChild("Humanoid", 10)
			if player.Character == character then apply(player) end
		end)
	end
	local function register(player: Player)
		if states[player] then return end
		states[player] = { sprint=false, crouch=false, stamina=config.playerMaxStamina, lastSprint=-math.huge, exhausted=false }
		player:SetAttribute("FNABKStamina", config.playerMaxStamina)
		player:SetAttribute("FNABKCrouching", false)
		player:GetAttributeChangedSignal("FNABKDowned"):Connect(function() apply(player) end)
		player:GetAttributeChangedSignal("FNABKEliminated"):Connect(function() apply(player) end)
		player.CharacterAdded:Connect(function(character) watchCharacter(player, character) end)
		if player.Character then watchCharacter(player, player.Character) end
	end
	Players.PlayerAdded:Connect(register)
	Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
	for _, player in ipairs(Players:GetPlayers()) do register(player) end
	remote.OnServerEvent:Connect(function(player: Player, action: any, enabled: any)
		local state = states[player]
		if not state or typeof(action) ~= "string" or typeof(enabled) ~= "boolean" then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if enabled and (not character or not humanoid or humanoid.Health <= 0
			or player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true
			or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true) then return end
		if action == "Sprint" then
			state.sprint = enabled
			if not enabled then state.exhausted = false end
		elseif action == "Crouch" then state.crouch = enabled
		else return end
		apply(player)
	end)
	RunService.Heartbeat:Connect(function(dt: number)
		local now = os.clock()
		for player, state in pairs(states) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local active = humanoid and humanoid.Health > 0 and root and root:IsA("BasePart")
				and player:GetAttribute("FNABKDowned") ~= true and player:GetAttribute("FNABKEliminated") ~= true
				and character:GetAttribute("FNABKDowned") ~= true and character:GetAttribute("FNABKEliminated") ~= true
			local moving = active and root and root:IsA("BasePart") and Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude > 0.5
			local sprinting = moving and state.sprint and not state.crouch and not state.exhausted
				and character and character:GetAttribute("FNABKCrateCarrying") ~= true and character:GetAttribute("FNABKCratePushing") ~= true
			if sprinting then
				state.stamina = math.max(0, state.stamina - config.staminaDrainPerSecond * dt)
				state.lastSprint = now
				if state.stamina <= 0 then state.exhausted = true end
			elseif now - state.lastSprint >= config.staminaRegenDelaySeconds then
				state.stamina = math.min(config.playerMaxStamina, state.stamina + config.staminaRegenPerSecond * dt)
			end
			local rounded = math.floor(state.stamina + 0.5)
			if player:GetAttribute("FNABKStamina") ~= rounded then player:SetAttribute("FNABKStamina", rounded) end
			apply(player)
		end
	end)
	print("[FNABK][Movement] Sprint, crouch and stamina ready")
end
return table.freeze(MovementService)
