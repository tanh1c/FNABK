--!strict
-- SURV-07: one provisional listening creature outside scheduled base waves.
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Creature = {}

function Creature.Start(map: Folder, position: Vector3, damage: (Player, number) -> number?, gunshot: BindableEvent, notice: RemoteEvent, status: StringValue): Model
	local enemy = Instance.new("Model")
	enemy.Name = "ListeningCreature"
	enemy:SetAttribute("NPCType", "Creature")
	enemy:SetAttribute("EnemyHealth", 60)
	enemy:SetAttribute("EnemyState", "Hidden")
	local root = Instance.new("Part")
	root.Name, root.Size, root.Anchored = "Root", Vector3.new(2, 3, 2), true
	root.Color, root.Material = Color3.fromRGB(71, 84, 60), Enum.Material.Slate
	root.CanCollide, root.Position, root.Parent = false, position, enemy
	enemy.PrimaryPart, enemy.Parent = root, map
	local gallery = ServerStorage:FindFirstChild("FNABK_Marketplace_Roster_Gallery_20261104")
	local display = gallery and gallery:FindFirstChild("Creature 9921746699")
	local source = display and display:FindFirstChildWhichIsA("Model")
	if source then
		local visual = source:Clone()
		for _, item in ipairs(visual:GetDescendants()) do
			if item:IsA("LuaSourceContainer") then item:Destroy()
			elseif item:IsA("BasePart") then item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, false, false, false
			elseif item:IsA("Humanoid") then item.DisplayDistanceType, item.EvaluateStateMachine = Enum.HumanoidDisplayDistanceType.None, false end
		end
		local _, size = visual:GetBoundingBox()
		if size.Y > 0 then visual:ScaleTo(visual:GetScale() * 3 / size.Y) end
		visual:PivotTo(root.CFrame)
		visual.Parent, root.Transparency = enemy, 1
		for _, part in ipairs(visual:GetDescendants()) do
			if part:IsA("BasePart") then part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false end
		end
	end
	local heard: Vector3? = nil
	local heardAt = 0
	local connection = gunshot.Event:Connect(function(origin: Vector3, radius: number)
		if status.Value == "Running" and enemy.Parent and enemy:GetAttribute("EnemyState") ~= "Defeated" and (origin - root.Position).Magnitude <= radius then
			heard, heardAt = origin, os.clock()
		end
	end)
	task.spawn(function()
		local target: Player? = nil
		local windupTarget: Player? = nil
		local windupUntil, attackAt, nextPath = 0, 0, 0
		local waypoints: { PathWaypoint } = {}
		local index = 1
		local last = os.clock()
		while enemy.Parent and enemy:GetAttribute("EnemyState") ~= "Defeated" do
			if status.Value == "Won" or status.Value == "Lost" then break end
			if status.Value ~= "Running" then
				heard, target, windupUntil, windupTarget = nil, nil, 0, nil
				enemy:SetAttribute("EnemyState", "Hidden")
				last = os.clock()
				task.wait(.1)
				continue
			end
			local now = os.clock()
			local elapsed = math.min(now - last, .2)
			last = now
			local best: Player? = nil
			local bestDistance = math.huge
			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local part = character and character:FindFirstChild("HumanoidRootPart")
				if character and humanoid and humanoid.Health > 0 and part and part:IsA("BasePart")
					and player:GetAttribute("FNABKDowned") ~= true and player:GetAttribute("FNABKEliminated") ~= true
					and character:GetAttribute("FNABKDowned") ~= true and character:GetAttribute("FNABKEliminated") ~= true then
					local distance = (part.Position - root.Position).Magnitude
					local speed = Vector3.new(part.AssemblyLinearVelocity.X, 0, part.AssemblyLinearVelocity.Z).Magnitude
					local range = if player:GetAttribute("FNABKCrouching") == true then 5 elseif humanoid.WalkSpeed > 12 and speed > 12 then 24 else 12
					local params = RaycastParams.new()
					params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { enemy, character }
					local visible = heard ~= nil and now - heardAt < 6 and distance <= 20 and not Workspace:Raycast(root.Position, part.Position - root.Position, params)
					if ((speed >= 1 and distance <= range) or visible) and distance < bestDistance then best, bestDistance = player, distance end
				end
			end
			if best then
				target = best
				local part = best.Character and best.Character:FindFirstChild("HumanoidRootPart")
				if part and part:IsA("BasePart") then heard, heardAt = part.Position, now end
			end
			if target and (not target.Parent or target:GetAttribute("FNABKDowned") == true or target:GetAttribute("FNABKEliminated") == true
				or not target.Character or target.Character:GetAttribute("FNABKDowned") == true or target.Character:GetAttribute("FNABKEliminated") == true) then
				target, windupTarget, windupUntil = nil, nil, 0
			end
			if heard and now - heardAt < 6 then
				enemy:SetAttribute("EnemyState", "Investigate")
				local part = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
				local distance = if part and part:IsA("BasePart") then (part.Position - root.Position).Magnitude else math.huge
				local ray = RaycastParams.new()
				ray.FilterType, ray.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { enemy, target and target.Character }
				local visible = part and part:IsA("BasePart") and not Workspace:Raycast(root.Position, part.Position - root.Position, ray)
				if target and distance < 4 and visible and now >= attackAt then
					if windupUntil == 0 or windupTarget ~= target then
						windupTarget = target
						windupUntil = now + 1
						notice:FireClient(target, "CREATURE PREPARING TO STRIKE", "CreatureAlert")
					elseif now >= windupUntil then
						damage(target, 15); attackAt, windupUntil, windupTarget = now + 2, 0, nil
					end
				else windupUntil, windupTarget = 0, nil end
				local offset = Vector3.new(heard.X - root.Position.X, 0, heard.Z - root.Position.Z)
				if offset.Magnitude > 3 and distance >= 4 then
					local step = offset.Unit * math.min(16 * elapsed, offset.Magnitude)
					local params = RaycastParams.new()
					params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { enemy }
					if not Workspace:Raycast(root.Position, step + offset.Unit, params) then
						enemy:PivotTo(CFrame.lookAt(root.Position + step, root.Position + step + offset.Unit))
					else
						if now >= nextPath then
							nextPath = now + 3
							local path = PathfindingService:CreatePath({ AgentRadius = 1.5, AgentHeight = 5, AgentCanJump = false })
							local ok = pcall(function() path:ComputeAsync(root.Position, heard :: Vector3) end)
							if not enemy.Parent or enemy:GetAttribute("EnemyState") == "Defeated" or status.Value ~= "Running" then continue end
							waypoints = if ok and path.Status == Enum.PathStatus.Success then path:GetWaypoints() else {}
							index = 1
						end
						while waypoints[index] and (Vector3.new(waypoints[index].Position.X, root.Position.Y, waypoints[index].Position.Z) - root.Position).Magnitude < 2 do index += 1 end
						local waypoint = waypoints[index]
						if waypoint then
							local direction = Vector3.new(waypoint.Position.X - root.Position.X, 0, waypoint.Position.Z - root.Position.Z)
							if direction.Magnitude > .1 then
								local move = direction.Unit * math.min(direction.Magnitude, 16 * elapsed)
								if not Workspace:Raycast(root.Position, move + direction.Unit, params) then enemy:PivotTo(CFrame.lookAt(root.Position + move, root.Position + move + direction.Unit)) end
							end
						end
					end
				end
			else
				heard, target, windupUntil, windupTarget = nil, nil, 0, nil
				enemy:SetAttribute("EnemyState", "Hidden")
			end
			task.wait(.1)
		end
		connection:Disconnect()
		if enemy.Parent then enemy:Destroy() end
	end)
	return enemy
end
return table.freeze(Creature)
