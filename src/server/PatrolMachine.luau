--!strict
-- SURV-07: provisional ambient patrol; server owns detection and damage.
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Machine = {}

function Machine.Start(map: Folder, position: Vector3, damage: (Player, number) -> number?, gunshot: BindableEvent, notice: RemoteEvent, status: StringValue): Model
	local model, root = Instance.new("Model"), Instance.new("Part")
	model.Name = "PatrolMachine"
	model:SetAttribute("NPCType", "Machine")
	model:SetAttribute("EnemyHealth", 90)
	model:SetAttribute("EnemyState", "Patrol")
	root.Name, root.Size, root.Anchored, root.CanCollide = "Root", Vector3.new(2, 4, 2), true, false
	root.Position, root.Color, root.Parent = position, Color3.fromRGB(80, 92, 90), model
	model.PrimaryPart, model.Parent = root, map
	local gallery = ServerStorage:FindFirstChild("FNABK_Marketplace_Roster_Gallery_20261104")
	local robots = gallery and gallery:FindFirstChild("RobotPreviews_20261104")
	local display = robots and robots:FindFirstChild("Robot 18978596124")
	local source = display and display:FindFirstChildWhichIsA("Model")
	if source then
		local visual = source:Clone()
		for _, item in ipairs(visual:GetDescendants()) do
			if item:IsA("LuaSourceContainer") then item:Destroy()
			elseif item:IsA("Humanoid") then item.EvaluateStateMachine, item.DisplayDistanceType = false, Enum.HumanoidDisplayDistanceType.None end
		end
		local _, size = visual:GetBoundingBox()
		if size.Y > 0 then visual:ScaleTo(visual:GetScale() * 4 / size.Y) end
		visual:PivotTo(root.CFrame)
		visual.Parent, root.Transparency = model, 1
		for _, item in ipairs(visual:GetDescendants()) do
			if item:IsA("BasePart") then item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, false, false, false end
		end
	end
	local mount = Instance.new("Attachment")
	mount.Position, mount.Parent = Vector3.new(0, 0, -1.1), root
	local lamp = Instance.new("SpotLight")
	lamp.Name, lamp.Face, lamp.Angle, lamp.Range, lamp.Brightness, lamp.Parent = "SensorLamp", Enum.NormalId.Front, 60, 30, 1.5, mount
	local heard: Vector3? = nil
	local heardAt = 0
	local connection = gunshot.Event:Connect(function(origin: Vector3, radius: number)
		if status.Value == "Running" and model.Parent and model:GetAttribute("EnemyState") ~= "Defeated" and (origin - root.Position).Magnitude <= radius then
			heard, heardAt = origin, os.clock()
		end
	end)
	task.spawn(function()
		local sight: { [Player]: number } = {}
		local current: Player? = nil
		local cooldown, last = 0, os.clock()
		local nextPath = 0
		local waypoints: { PathWaypoint } = {}
		local waypointIndex = 1
		local pathDestination: Vector3? = nil
		local home = position
		while model.Parent and model:GetAttribute("EnemyState") ~= "Defeated" and status.Value ~= "Won" and status.Value ~= "Lost" do
			local now = os.clock()
			local elapsed = math.min(now - last, .2)
			last = now
			if status.Value ~= "Running" then
				heard, current, sight = nil, nil, {}
				waypoints, pathDestination = {}, nil
				model:SetAttribute("EnemyState", "Patrol")
				task.wait(.1)
				continue
			end
			local best: Player? = nil
			local bestDistance = math.huge
			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local target = character and character:FindFirstChild("HumanoidRootPart")
				if character and humanoid and humanoid.Health > 0 and target and target:IsA("BasePart")
					and player:GetAttribute("FNABKDowned") ~= true and player:GetAttribute("FNABKEliminated") ~= true
					and character:GetAttribute("FNABKDowned") ~= true and character:GetAttribute("FNABKEliminated") ~= true then
					local delta = target.Position - root.Position
					local flat = Vector3.new(delta.X, 0, delta.Z)
					local facing = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
					local ray = RaycastParams.new()
					ray.FilterType, ray.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { model, character }
					local visible = not Workspace:Raycast(root.Position, delta, ray)
					local cone = lamp.Enabled and delta.Magnitude <= 30 and (flat.Magnitude < .01 or facing.Unit:Dot(flat.Unit) >= math.cos(math.rad(30)))
					if visible and cone then sight[player] = sight[player] or now else sight[player] = nil end
					local speed = Vector3.new(target.AssemblyLinearVelocity.X, 0, target.AssemblyLinearVelocity.Z).Magnitude
					local running = delta.Magnitude <= 16 and humanoid.WalkSpeed > 12 and speed > 12
					if (running or (sight[player] and now - sight[player] >= 1)) and delta.Magnitude < bestDistance then best, bestDistance = player, delta.Magnitude end
				else sight[player] = nil end
			end
			if best then
				if best ~= current then notice:FireClient(best, "MACHINE DETECTED YOU", "MachineAlert") end
				current = best
				local part = best.Character and best.Character:FindFirstChild("HumanoidRootPart")
				if part and part:IsA("BasePart") then heard, heardAt = part.Position, now end
			else current = nil end
			local destination: Vector3
			if heard and now - heardAt < 6 then
				model:SetAttribute("EnemyState", "Investigate")
				destination = heard
			else
				heard = nil
				model:SetAttribute("EnemyState", "Patrol")
				-- ponytail: short fixed patrol; replace with reviewed navigable waypoints.
				destination = home + Vector3.new(math.sin(now / 4) * 8, 0, 0)
			end
			if best and bestDistance < 4 and now >= cooldown then
				local targetRoot = best.Character and best.Character:FindFirstChild("HumanoidRootPart")
				local ray = RaycastParams.new()
				ray.FilterType, ray.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { model, best.Character }
				if targetRoot and targetRoot:IsA("BasePart") and not Workspace:Raycast(root.Position, targetRoot.Position - root.Position, ray) then
					damage(best, 18); cooldown = now + 2
				end
			end
			local delta = Vector3.new(destination.X - root.Position.X, 0, destination.Z - root.Position.Z)
			if delta.Magnitude > 2 and (not best or bestDistance >= 4) then
				local step = delta.Unit * math.min(delta.Magnitude, 9 * elapsed)
				local ray = RaycastParams.new()
				ray.FilterType, ray.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { model }
				if not Workspace:Raycast(root.Position, step + delta.Unit, ray) then
					model:PivotTo(CFrame.lookAt(root.Position + step, root.Position + step + delta.Unit))
				else
					if now >= nextPath then
						nextPath = now + 3
						local ground = RaycastParams.new()
						local ignored: { Instance } = { model }
						for _, player in ipairs(Players:GetPlayers()) do if player.Character then table.insert(ignored, player.Character) end end
						ground.FilterType, ground.FilterDescendantsInstances, ground.RespectCanCollide = Enum.RaycastFilterType.Exclude, ignored, true
						local function project(p: Vector3): Vector3
							local hit = Workspace:Raycast(p + Vector3.new(0, 2, 0), Vector3.new(0, -14, 0), ground)
							return if hit then hit.Position else p
						end
						local path = PathfindingService:CreatePath({ AgentRadius = 1.5, AgentHeight = 5, AgentCanJump = false, WaypointSpacing = 4 })
						local ok = pcall(function() path:ComputeAsync(project(root.Position), project(destination)) end)
						if not model.Parent or model:GetAttribute("EnemyState") == "Defeated" or status.Value ~= "Running" then continue end
						waypoints = if ok and path.Status == Enum.PathStatus.Success then path:GetWaypoints() else {}
						waypointIndex, pathDestination = 1, destination
					end
					if pathDestination and (pathDestination - destination).Magnitude <= 8 then
						while waypoints[waypointIndex] and (Vector3.new(waypoints[waypointIndex].Position.X, root.Position.Y, waypoints[waypointIndex].Position.Z) - root.Position).Magnitude < 2 do waypointIndex += 1 end
						local waypoint = waypoints[waypointIndex]
						if waypoint then
							local offset = Vector3.new(waypoint.Position.X - root.Position.X, 0, waypoint.Position.Z - root.Position.Z)
							if offset.Magnitude > .1 then
								local move = offset.Unit * math.min(offset.Magnitude, 9 * elapsed)
								if not Workspace:Raycast(root.Position, move + offset.Unit, ray) then model:PivotTo(CFrame.lookAt(root.Position + move, root.Position + move + offset.Unit)) end
							end
						end
					end
				end
			elseif not heard then
				model:PivotTo(CFrame.new(root.Position) * CFrame.Angles(0, math.sin(now / 2) * math.rad(70), 0))
			end
			task.wait(.1)
		end
		connection:Disconnect()
		if model.Parent then model:Destroy() end
	end)
	return model
end
return table.freeze(Machine)
