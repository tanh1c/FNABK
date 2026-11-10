--!strict
-- Prototype wave attackers (SURV-02/07); server owns spawn, movement and damage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Clock = require(script.Parent:WaitForChild("SurvivalClock"))
local Composition = require(script.Parent:WaitForChild("WaveComposition"))
local walkSpeed = require(ReplicatedStorage:WaitForChild("FNABKShared"):WaitForChild("GameConfig")).walkSpeed
local WaveService = {}

function WaveService.eligible(player: Player): boolean
	if player.Parent ~= Players or player:GetAttribute("FNABKEliminated") == true then return false end
	local character = player.Character
	if character and character:GetAttribute("FNABKEliminated") == true then return false end
	if player:GetAttribute("FNABKDowned") == true or (character and character:GetAttribute("FNABKDowned") == true) then return true end
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	-- ponytail: loading and waiting-to-respawn players are excluded until their wave policy is selected.
	return humanoid ~= nil and humanoid.Health > 0
end

function WaveService.Start(map: Folder, events: BindableEvent, applyDamage: (Player, number) -> number?, gunshot: BindableEvent)
	local state = ReplicatedStorage:WaitForChild("FNABKRoundState")
	local roundStatus: StringValue? = nil
	local notices = Instance.new("RemoteEvent")
	notices.Name, notices.Parent = "WaveNotice", ReplicatedStorage:WaitForChild("FNABKRemotes")
	local folder = Instance.new("Folder")
	folder.Name, folder.Parent = "WaveAttackers", map
	local generation = 0
	local warningGeneration = 0
	local beacon = Instance.new("Part")
	beacon.Name, beacon.Size, beacon.Transparency = "WaveWarningBeacon", Vector3.new(.5, .5, .5), 1
	beacon.Anchored, beacon.CanCollide, beacon.CanTouch, beacon.CanQuery = true, false, false, false
	beacon.Parent = map
	local beaconLight = Instance.new("PointLight")
	beaconLight.Name, beaconLight.Enabled, beaconLight.Range, beaconLight.Brightness = "WarningLight", false, 24, 2
	beaconLight.Color, beaconLight.Parent = Color3.fromRGB(255, 161, 76), beacon
	local function stopWarning()
		warningGeneration += 1
		beaconLight.Enabled = false
	end
	local function warnBase()
		stopWarning()
		local current = warningGeneration
		task.spawn(function()
			local start = os.clock()
			local lastBuilding: Model? = nil
			while warningGeneration == current and os.clock() - start < 30 do
				local active = state:FindFirstChild("ActiveBase")
				local anchors = Workspace:FindFirstChild("FNABKBaseClaimPoints")
				local powers = state:FindFirstChild("BuildingPower")
				local name = if active and active:IsA("StringValue") then active.Value else ""
				local point = anchors and anchors:FindFirstChild(name)
				local power = powers and powers:FindFirstChild(name)
				local campus = Workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6")
				local buildings = campus and campus:FindFirstChild("Buildings")
				local building = buildings and buildings:FindFirstChild(name)
				if point and point:IsA("BasePart") and building and building:IsA("Model") and power and power:IsA("BoolValue") and power.Value then
					if building ~= lastBuilding then
						local cf, size = building:GetBoundingBox()
						beacon.Position = (cf * CFrame.new(size.X / 2 + 1, size.Y / 2 + 1, 0)).Position
						lastBuilding = building
					end
					beaconLight.Enabled = math.floor((os.clock() - start) * 2) % 2 == 0
				else beaconLight.Enabled = false end
				task.wait(.1)
			end
			if warningGeneration == current then beaconLight.Enabled = false end
		end)
	end
	local machineNoticeAt: { [Player]: number } = {}
	Players.PlayerRemoving:Connect(function(player) machineNoticeAt[player] = nil end)
	local gallery = ServerStorage:FindFirstChild("FNABK_Marketplace_Roster_Gallery_20261104")
	local creatureNames = { "Creature 9921746699", "Creature 10699449494", "Creature 137189209569355" }
	local function retire(enemy: Model): boolean
		local key = if enemy:GetAttribute("NPCType") == "Mimic" then "MimicState" else "EnemyState"
		local state = enemy:GetAttribute(key)
		if state == "Retreat" or state == "Defeated" then return false end
		enemy:SetAttribute(key, "Retreat")
		task.spawn(function()
			local root, destination = enemy.PrimaryPart, enemy:GetAttribute("RetreatDestination")
			local deadline = os.clock() + 8
			local params = RaycastParams.new()
			params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { folder }
			local waypoints: { PathWaypoint } = {}
			local index = 1
			local attemptedPath = false
			while enemy.Parent and enemy:GetAttribute(key) == "Retreat" and root and typeof(destination) == "Vector3" and os.clock() < deadline do
				local delta = Vector3.new(destination.X - root.Position.X, 0, destination.Z - root.Position.Z)
				if delta.Magnitude < 1 then break end
				local step = delta.Unit * math.min(1, delta.Magnitude)
				if Workspace:Raycast(root.Position, step + delta.Unit, params) then
					if not attemptedPath then
						attemptedPath = true
						local path = PathfindingService:CreatePath({ AgentRadius = 1.5, AgentHeight = 5, AgentCanJump = false, WaypointSpacing = 4 })
						local ok = pcall(function() path:ComputeAsync(root.Position, destination) end)
						if not enemy.Parent or enemy:GetAttribute(key) ~= "Retreat" or os.clock() >= deadline then break end
						if ok and path.Status == Enum.PathStatus.Success then waypoints = path:GetWaypoints() end
					end
					while waypoints[index] and (Vector3.new(waypoints[index].Position.X, root.Position.Y, waypoints[index].Position.Z) - root.Position).Magnitude < 2 do index += 1 end
					local waypoint = waypoints[index]
					if not waypoint then break end
					local offset = Vector3.new(waypoint.Position.X - root.Position.X, 0, waypoint.Position.Z - root.Position.Z)
					if offset.Magnitude < 0.01 then break end
					step = offset.Unit * math.min(1, offset.Magnitude)
					if Workspace:Raycast(root.Position, step + offset.Unit, params) then break end
				end
				enemy:PivotTo(CFrame.lookAt(root.Position + step, root.Position + 2 * step))
				task.wait(0.1)
			end
			if not enemy.Parent then return end
			if enemy:GetAttribute(key) == "Defeated" then enemy:Destroy(); return end
			-- ponytail: inaccessible routes dissolve in place; add visibility-aware recovery.
			for _, part in ipairs(enemy:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
					TweenService:Create(part, TweenInfo.new(2), { Transparency = 1 }):Play()
				end
			end
			task.wait(2)
			if enemy.Parent then enemy:Destroy() end
		end)
		return true
	end
	local function retreat()
		stopWarning()
		generation += 1
		for _, enemy in ipairs(folder:GetChildren()) do
			if enemy:IsA("Model") then
				retire(enemy)
			end
		end
	end
	task.spawn(function()
		local status = state:WaitForChild("RoundStatus") :: StringValue
		roundStatus = status
		local function stopAtEnd()
			if status.Value == "Won" or status.Value == "Lost" then retreat() end
		end
		status.Changed:Connect(stopAtEnd)
		stopAtEnd()
	end)
	gunshot.Event:Connect(function(position: Vector3, radius: number)
		for _, enemy in ipairs(folder:GetChildren()) do
			if enemy:IsA("Model") and enemy.PrimaryPart and (enemy:GetAttribute("MimicState") == "Chase" or enemy:GetAttribute("EnemyState") == "Chase") and (enemy.PrimaryPart.Position - position).Magnitude <= radius then
				enemy:SetAttribute("HeardPosition", position)
				enemy:SetAttribute("HeardUntil", os.clock() + 8)
			end
		end
	end)
	local function startWave(night: number, grace: boolean)
		stopWarning()
		if #folder:GetChildren() > 0 then retreat() end
		if grace then
			-- ponytail: show a brief effect for all stragglers until per-player visibility is available.
			for _, enemy in ipairs(folder:GetChildren()) do
				if enemy:IsA("Model") and enemy.PrimaryPart then
					local effect = Instance.new("Part")
					effect.Name, effect.Shape, effect.Size = "RetreatEffect", Enum.PartType.Ball, Vector3.new(2, 2, 2)
					effect.Anchored, effect.CanCollide, effect.CanTouch, effect.CanQuery = true, false, false, false
					effect.Material, effect.Color, effect.Transparency = Enum.Material.Neon, Color3.fromRGB(170, 180, 165), 0.4
					effect.CFrame, effect.Parent = enemy.PrimaryPart.CFrame, map
					TweenService:Create(effect, TweenInfo.new(0.4), { Size = Vector3.new(4, 4, 4), Transparency = 1 }):Play()
					Debris:AddItem(effect, 0.5)
				end
				enemy:Destroy()
			end
		end
		local active = state:FindFirstChild("ActiveBase")
		local points = Workspace:FindFirstChild("FNABKBaseClaimPoints")
		local point = active and active:IsA("StringValue") and points and points:FindFirstChild(active.Value)
		if active and active:IsA("StringValue") and active.Value == "" then
			-- ponytail: initial spawn is a temporary fallback; review no-base wave placement.
			point = map:FindFirstChild("PlayerSpawn")
		end
		if not point or not point:IsA("BasePart") then notices:FireAllClients("Wave cannot spawn: base location unavailable"); return end
		local count = 0
		for _, player in ipairs(Players:GetPlayers()) do if WaveService.eligible(player) then count += 1 end end
		if count < 1 or count > 4 then return end
		local total, cap = Clock.waveSize(if grace then 5 else night, count)
		if not total or not cap then return end
		local composition = Composition.make(total, count, grace)
		generation += 1
		local wave = generation
		local basePosition = point.Position
		local function spawnPosition(angle: number): Vector3?
			local ignored: { Instance } = { folder }
			for _, player in ipairs(Players:GetPlayers()) do if player.Character then table.insert(ignored, player.Character) end end
			local ray = RaycastParams.new()
			ray.FilterType, ray.FilterDescendantsInstances, ray.RespectCanCollide = Enum.RaycastFilterType.Exclude, ignored, true
			local overlap = OverlapParams.new()
			overlap.FilterType, overlap.FilterDescendantsInstances, overlap.RespectCanCollide = Enum.RaycastFilterType.Exclude, ignored, true
			for attempt = 0, 35 do
				local direction = angle + (attempt % 12) * math.pi / 6
				local radius = 35 + math.floor(attempt / 12) * 8
				local candidate = basePosition + Vector3.new(math.cos(direction) * radius, 10, math.sin(direction) * radius)
				local floor = Workspace:Raycast(candidate, Vector3.new(0, -30, 0), ray)
				if floor and math.abs(floor.Position.Y - basePosition.Y) <= 3 then
					local position = floor.Position + Vector3.new(0, 2.1, 0)
					local occupied = false
					for _, player in ipairs(Players:GetPlayers()) do
						local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						if root and root:IsA("BasePart") and (root.Position - position).Magnitude < 5 then occupied = true; break end
					end
					if not occupied then
						for _, enemy in ipairs(folder:GetChildren()) do
							if enemy:IsA("Model") and enemy.PrimaryPart and (enemy.PrimaryPart.Position - position).Magnitude < 3 then occupied = true; break end
						end
					end
					if not occupied and #Workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(1.8, 3.8, 1.8), overlap) == 0 then return position end
				end
			end
			return nil
		end
		task.spawn(function()
			local spawned = 0
			local fullSince: number? = nil
			while generation == wave and spawned < total do
				if #folder:GetChildren() < cap then
					fullSince = nil
					local angle = (spawned + 1) * 2.4
					local position = spawnPosition(angle)
					if not position then task.wait(1); continue end
					spawned += 1
					local enemy = Instance.new("Model")
					local kind = composition[spawned]
					local speed = if kind == "Creature" then 16 elseif kind == "Machine" then 9 else 14
					local damage = if kind == "Creature" then 15 elseif kind == "Machine" then 18 else 20
					local cooldown = if kind == "Mimic" then 1.6 else 2
					enemy.Name = "Wave" .. kind
					local root = Instance.new("Part")
					root.Name, root.Size, root.Anchored = "Root", Vector3.new(2, 4, 2), true
					root.Position = position
					enemy:SetAttribute("RetreatDestination", basePosition + Vector3.new(math.cos(angle) * 55, 1, math.sin(angle) * 55))
					root.Color, root.CanCollide, root.Parent = Color3.fromRGB(97, 110, 74), false, enemy
					enemy.PrimaryPart = root
					if kind == "Machine" then
						local sensor = Instance.new("Attachment")
						sensor.Name, sensor.Position, sensor.Parent = "SensorMount", Vector3.new(0, 0, -1.1), root
						local lamp = Instance.new("SpotLight")
						lamp.Name, lamp.Face, lamp.Angle, lamp.Range = "SensorLamp", Enum.NormalId.Front, 60, 30
						lamp.Brightness, lamp.Color, lamp.Shadows, lamp.Parent = 1.5, Color3.fromRGB(214, 226, 199), true, sensor
					end
					local robots = gallery and gallery:FindFirstChild("RobotPreviews_20261104")
					local display = if kind == "Machine" then robots and robots:FindFirstChild("Robot 18978596124") elseif kind == "Mimic" then gallery and gallery:FindFirstChild("Student 1 / R6") else gallery and gallery:FindFirstChild(creatureNames[(spawned - 1) % #creatureNames + 1])
					local source = display and display:FindFirstChildWhichIsA("Model")
					if source then
						local visual = source:Clone()
						for _, item in ipairs(visual:GetDescendants()) do
							if item:IsA("LuaSourceContainer") then item:Destroy()
							elseif item:IsA("BasePart") then item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, false, false, false
							elseif item:IsA("Humanoid") then item.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
						end
						local _, size = visual:GetBoundingBox()
						if size.Y > 0 then visual:ScaleTo(visual:GetScale() * 4 / size.Y) end
						visual:PivotTo(root.CFrame)
						visual.Parent = enemy
						root.Transparency = 1
					end
					enemy:SetAttribute("NPCType", kind)
					enemy:SetAttribute("WaveKind", kind)
					local healthKey = if kind == "Mimic" then "MimicHealth" else "EnemyHealth"
					local stateKey = if kind == "Mimic" then "MimicState" else "EnemyState"
					enemy:SetAttribute(healthKey, if kind == "Creature" then 60 elseif kind == "Machine" then 90 else 75)
					enemy:SetAttribute(stateKey, "Chase")
					enemy.Parent = folder
					task.spawn(function()
						local attackAt = 0
						local nextPathAt = 0
						local waypoints: { PathWaypoint } = {}
						local index = 1
						local lastMoveTick = os.clock()
						local lastSeen: Vector3? = nil
						local lastSeenAt = 0
						local visionSince: { [Player]: number } = {}
						local previousTarget: Player? = nil
						local windupTarget: Player? = nil
						local windupAt = 0
						while enemy.Parent and generation == wave do
							local currentState = enemy:GetAttribute(stateKey)
							if currentState == "Stunned" then
								lastMoveTick = os.clock()
								windupTarget, previousTarget = nil, nil
								task.wait(0.1)
								continue
							elseif currentState ~= "Chase" then break end
							local now = os.clock()
							-- ponytail: cap delayed steps at 0.2 s to limit tunneling; use physics movement for smoother recovery.
							local travel = speed * math.min(now - lastMoveTick, 0.2)
							lastMoveTick = now
							local target: Player? = nil
							local distance = 40
							for _, player in ipairs(Players:GetPlayers()) do
								local character = player.Character
								local p = character and character:FindFirstChild("HumanoidRootPart")
								local humanoid = character and character:FindFirstChildOfClass("Humanoid")
								if p and p:IsA("BasePart") and humanoid and humanoid.Health > 0 and player:GetAttribute("FNABKDowned") ~= true and player:GetAttribute("FNABKEliminated") ~= true
									and character:GetAttribute("FNABKDowned") ~= true and character:GetAttribute("FNABKEliminated") ~= true then
									local d = (p.Position - root.Position).Magnitude
									if d < distance then
										local sight = RaycastParams.new()
										sight.FilterType, sight.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { folder, character }
										local visible = not Workspace:Raycast(root.Position, p.Position - root.Position, sight)
										if kind == "Machine" then
											local horizontal = Vector3.new(p.Position.X - root.Position.X, 0, p.Position.Z - root.Position.Z)
											local facing = root.CFrame.LookVector * Vector3.new(1, 0, 1)
											local inCone = d <= 30 and (horizontal.Magnitude < .01 or (facing.Magnitude > .01 and facing.Unit:Dot(horizontal.Unit) >= math.cos(math.rad(30))))
											if visible and inCone then visionSince[player] = visionSince[player] or now else visionSince[player] = nil end
											local velocity = Vector3.new(p.AssemblyLinearVelocity.X, 0, p.AssemblyLinearVelocity.Z).Magnitude
											local running = d <= 16 and humanoid.WalkSpeed > walkSpeed and velocity > walkSpeed
											if running or (visionSince[player] and now - visionSince[player] >= 1) then target, distance = player, d end
										elseif visible then target, distance = player, d end
									else visionSince[player] = nil end
								else visionSince[player] = nil
								end
							end
							local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
							if kind == "Machine" and target and target ~= previousTarget and now >= (machineNoticeAt[target] or 0) then
								machineNoticeAt[target] = now + 5
								notices:FireClient(target, "MACHINE DETECTED YOU", "MachineAlert")
							end
							previousTarget = target
							if targetRoot and targetRoot:IsA("BasePart") then lastSeen, lastSeenAt = targetRoot.Position, now end
							enemy:SetAttribute("WaveTargetUserId", if target then target.UserId else 0)
							local heard = enemy:GetAttribute("HeardPosition")
							local heardUntil = enemy:GetAttribute("HeardUntil")
							local activeBase = state:FindFirstChild("ActiveBase")
							local barrier = if kind == "Creature" and activeBase and activeBase:IsA("StringValue") and activeBase.Value == "B1"
								then map:FindFirstChild("B1Barricade") else nil
							if barrier and barrier:IsA("BasePart") and barrier.CanCollide then
								local strike = barrier:FindFirstChild("WaveStrike")
								if strike and strike:IsA("BindableEvent") and (root.Position - barrier.Position).Magnitude <= 7 then strike:Fire(enemy) end
							else barrier = nil end
							-- ponytail: shared eight-second last-known pursuit; add distinct Chase/Search states per enemy type.
							local destination = if targetRoot and targetRoot:IsA("BasePart") then targetRoot.Position elseif typeof(heard) == "Vector3" and typeof(heardUntil) == "number" and now < heardUntil then heard elseif lastSeen and now - lastSeenAt < 8 then lastSeen elseif barrier and barrier:IsA("BasePart") then barrier.Position else basePosition
							local delta = Vector3.new(destination.X - root.Position.X, 0, destination.Z - root.Position.Z)
							local blocked = false
							if target and targetRoot and distance < 4 then
								local params = RaycastParams.new()
								params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { enemy, target.Character }
								local hit = Workspace:Raycast(root.Position, targetRoot.Position - root.Position, params)
								blocked = hit ~= nil
								if not blocked and now >= attackAt then
									if kind ~= "Creature" then
										applyDamage(target, damage); attackAt = now + cooldown
									elseif windupTarget ~= target then
										windupTarget, windupAt = target, now + 1
										notices:FireClient(target, "CREATURE PREPARING TO STRIKE", "CreatureAlert")
									elseif now >= windupAt then
										applyDamage(target, damage); attackAt = now + cooldown
										windupTarget = nil
									end
								else windupTarget = nil end
							end
							if not target or distance >= 4 then windupTarget = nil end
							if (blocked or not target or distance >= 4) and delta.Magnitude > (if blocked then 0.1 else 3) then
								local params = RaycastParams.new()
								params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { enemy }
								local step = delta.Unit * math.min(delta.Magnitude, travel)
								if not Workspace:Raycast(root.Position, step + delta.Unit, params) then
									enemy:PivotTo(CFrame.lookAt(root.Position + step, root.Position + step + delta.Unit))
								else
									if os.clock() >= nextPathAt then
										nextPathAt = os.clock() + 3
										local path = PathfindingService:CreatePath({ AgentRadius = 1.5, AgentHeight = 5, AgentCanJump = false, WaypointSpacing = 5 })
										local ok = pcall(function() path:ComputeAsync(root.Position, destination) end)
										if not enemy.Parent or generation ~= wave then break end
										if enemy:GetAttribute(stateKey) ~= "Chase" then continue end
										waypoints = if ok and path.Status == Enum.PathStatus.Success then path:GetWaypoints() else {}
										index = 1
									end
									while waypoints[index] and (Vector3.new(waypoints[index].Position.X, root.Position.Y, waypoints[index].Position.Z) - root.Position).Magnitude < 2 do index += 1 end
									local waypoint = waypoints[index]
									if waypoint then
										local offset = Vector3.new(waypoint.Position.X - root.Position.X, 0, waypoint.Position.Z - root.Position.Z)
										if offset.Magnitude > 0.1 then
											local move = offset.Unit * math.min(offset.Magnitude, travel)
											if not Workspace:Raycast(root.Position, move + offset.Unit, params) then enemy:PivotTo(CFrame.lookAt(root.Position + move, root.Position + move + offset.Unit)) end
										end
									end
								end
							end
							task.wait(0.1)
						end
						if enemy.Parent and enemy:GetAttribute(stateKey) == "Defeated" then enemy:Destroy() end
					end)
				else
					fullSince = fullSince or os.clock()
					-- ponytail: retire oldest stalled attackers after 20 seconds; tune with real wave pacing.
					if os.clock() - fullSince >= 20 then
						local remaining = total - spawned
						for _, enemy in ipairs(folder:GetChildren()) do
							if remaining <= 0 then break end
							if enemy:IsA("Model") and retire(enemy) then remaining -= 1 end
						end
						fullSince = os.clock()
					end
				end
				task.wait(0.25)
			end
		end)
	end
	events.Event:Connect(function(event: string)
		if not roundStatus or roundStatus.Value ~= "Running" then return end
		local night = event:match("^NightWave:(%d+):%d+$")
		if night then startWave(tonumber(night) :: number, false)
		elseif event:match("^Wave:%d+$") then startWave(5, true)
		elseif event:match("^Retreat:") or event:match("^Day:") then retreat()
		elseif event:match("^WaveCanceled:%d+$") then stopWarning(); notices:FireAllClients("Attack canceled: distress signal sent")
		elseif event:match("Warning") then warnBase(); notices:FireAllClients("Attack incoming in 30 seconds", "Warning") end
	end)
end

return table.freeze(WaveService)
