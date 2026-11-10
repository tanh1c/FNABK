-- AI-assisted repair; run one phase at a time in Studio after reviewing the backup.
return function(phase, wingIndex, floor)
	local b1 = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
	local body = b1.B1_ContinuousBuilding
	local storage = game:GetService("ServerStorage")
	if phase == "seal" then
		assert(not storage:FindFirstChild("B1_BeforeConnectionPass_v1"), "Backup already exists")
		assert(not body:FindFirstChild("B1_ConnectionPass_v1"), "Repair already exists")
		local wings = {}
		for _, folder in ipairs(body:GetChildren()) do
			local lintel = folder.Name == "WalkableStructure" and folder:FindFirstChild("OuterWall_Floor_01_South_Lintel")
			if lintel and math.abs(lintel.Orientation.Y) < 1 then table.insert(wings, folder) end
		end
		assert(#wings == 2, "Expected two original wing walls")
		local backup = b1:Clone()
		backup.Name = "B1_BeforeConnectionPass_v1"
		backup.Parent = storage
		local repair = Instance.new("Folder")
		repair.Name = "B1_ConnectionPass_v1"
		repair.Parent = body
		for _, wing in ipairs(wings) do
			local lintel, wall = wing.OuterWall_Floor_01_South_Lintel, wing.OuterWall_Floor_01_South_West
			local fill = Instance.new("Part")
			fill.Name = "SealedFormerWingEntrance"
			fill.Size = Vector3.new(lintel.Size.X + 0.05, wall.Size.Y, wall.Size.Z)
			fill.CFrame = CFrame.new(lintel.Position.X, wall.Position.Y, lintel.Position.Z) * wall.CFrame.Rotation
			fill.Anchored, fill.CanCollide, fill.CanTouch = true, true, false
			fill.Material, fill.Color = wall.Material, wall.Color
			fill.Parent = repair
		end
		return "Backup created; two wing-end openings sealed"
	end
	if phase == "check" then
		local repair = assert(body:FindFirstChild("B1_ConnectionPass_v1"))
		assert(repair:GetAttribute("RoofUnified") and repair:FindFirstChild("SealedFormerCrossbarEntrance"))
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = {b1}
		params.RespectCanCollide = true
		for wing, x in ipairs({5403.66, 5507.80}) do
			for level = 1, 3 do
				assert(repair:GetAttribute(string.format("Join_%d_%d", wing, level)))
				local y = 3 + (level - 1) * 12.85714
				assert(not workspace:Raycast(Vector3.new(x,y,1682), Vector3.new(0,0,14), params), "Blocked join")
			end
			local hit = workspace:Raycast(Vector3.new(x,3,1569), Vector3.new(0,0,12), params)
			assert(hit and hit.Instance.Name == "SealedFormerWingEntrance", "Wing end is open")
		end
		local side = workspace:Raycast(Vector3.new(5385,3,1707.125), Vector3.new(18,0,0), params)
		assert(side and side.Instance.Name == "SealedFormerCrossbarEntrance", "Crossbar end is open")
		return "Six join centerlines clear; three former openings sealed"
	end
	if phase == "roof" then
		local repair = assert(body:FindFirstChild("B1_ConnectionPass_v1"))
		assert(not repair:GetAttribute("RoofUnified"), "Roof already processed")
		local roofs, remove = {}, {}
		for _, part in ipairs(body:GetDescendants()) do
			if part:IsA("BasePart") then
				if part.Name == "WalkableRoofCap" then table.insert(roofs, part) end
				if part.Name:match("^TerracedPavilion_") or (part.Name == "RoofParapet_Back" and math.abs(part.Orientation.Y) < 1) then
					table.insert(remove, part)
				end
			end
		end
		assert(#roofs == 3 and #remove == 29, "Unexpected roof layout")
		for _, roof in ipairs(roofs) do
			if math.abs(roof.Orientation.Y) < 1 then
				local cap = Instance.new("Part")
				cap.Name = "RoofJoin"
				cap.Size = Vector3.new(roof.Size.X, roof.Size.Y, 2)
				cap.CFrame = CFrame.new(roof.Position.X, roof.Position.Y, 1689.75)
				cap.Color, cap.Material = roof.Color, roof.Material
				cap.Anchored, cap.CanCollide, cap.CanTouch = true, true, false
				cap.Parent = repair
			end
		end
		for _, part in ipairs(remove) do part:Destroy() end
		repair:SetAttribute("RoofUnified", true)
		return "Connected roof caps and removed 29 repeated roof details"
	end
	if phase == "seal-crossbar" then
		local repair = assert(body:FindFirstChild("B1_ConnectionPass_v1"))
		assert(not repair:FindFirstChild("SealedFormerCrossbarEntrance"), "Already sealed")
		for _, folder in ipairs(body:GetChildren()) do
			local lintel = folder.Name == "WalkableStructure" and folder:FindFirstChild("OuterWall_Floor_01_South_Lintel")
			if lintel and math.abs(lintel.Orientation.Y) > 80 then
				local wall = folder.OuterWall_Floor_01_South_West
				local fill = Instance.new("Part")
				fill.Name = "SealedFormerCrossbarEntrance"
				fill.Size = Vector3.new(lintel.Size.X + 0.05, wall.Size.Y, wall.Size.Z)
				fill.CFrame = CFrame.new(lintel.Position.X, wall.Position.Y, lintel.Position.Z) * wall.CFrame.Rotation
				fill.Anchored, fill.CanCollide, fill.CanTouch = true, true, false
				fill.Color, fill.Material = wall.Color, wall.Material
				fill.Parent = repair
				return "Crossbar end opening sealed"
			end
		end
		error("Crossbar end wall not found")
	end
	assert(phase == "join" and (wingIndex == 1 or wingIndex == 2) and floor >= 1 and floor <= 3, "Invalid repair phase")
	local repair = assert(body:FindFirstChild("B1_ConnectionPass_v1"), "Run seal phase first")
	local marker = string.format("Join_%d_%d", wingIndex, floor)
	assert(not repair:GetAttribute(marker), "Join already processed")
	local x = ({5403.66, 5507.80})[wingIndex]
	local center = Vector3.new(x, 5 + (floor - 1) * 12.85714, 1689.1)
	local candidates = {}
	for _, p in ipairs(body:GetDescendants()) do
		if p:IsA("BasePart") and p.CanCollide then
			local name = p.Name
			if name:match("^OuterWall_Floor_0[123]_North") or name:match("^GalleryRail_East_Floor_0[123]_")
				or name:match("^GalleryClassroomWall_F0[123]_Side_East_") then
				local localCenter = p.CFrame:PointToObjectSpace(center)
				local rx, rz = p.CFrame.RightVector, p.CFrame.LookVector
				local sx, sz = (math.abs(rx.X) + math.abs(rx.Z)) * 4, (math.abs(rz.X) + math.abs(rz.Z)) * 4
				local h = p.Size * 0.5
				local lo = Vector3.new(math.max(-h.X, localCenter.X-sx), math.max(-h.Y, localCenter.Y-4.2), math.max(-h.Z, localCenter.Z-sz))
				local hi = Vector3.new(math.min(h.X, localCenter.X+sx), math.min(h.Y, localCenter.Y+4.2), math.min(h.Z, localCenter.Z+sz))
				if hi.X-lo.X > 0.05 and hi.Y-lo.Y > 0.05 and hi.Z-lo.Z > 0.05 then
					assert(math.abs(p.CFrame.UpVector.Y) > 0.99 and #p:GetChildren() == 0, "Unexpected wall geometry")
					table.insert(candidates, {part=p, lo=lo, hi=hi, half=h})
				end
			end
		end
	end
	assert(#candidates > 0 and #candidates <= 20, "Unexpected number of intersecting walls")
	for _, item in ipairs(candidates) do
		local p, lo, hi, h = item.part, item.lo, item.hi, item.half
		local function piece(a, b)
			local size = b-a
			if size.X > 0.05 and size.Y > 0.05 and size.Z > 0.05 then
				local q = p:Clone()
				q.Name = p.Name .. "_Trim"
				q.Size, q.CFrame = size, p.CFrame * CFrame.new((a+b)*0.5)
				q.Parent = repair
			end
		end
		piece(Vector3.new(-h.X,-h.Y,-h.Z),Vector3.new(lo.X,h.Y,h.Z))
		piece(Vector3.new(hi.X,-h.Y,-h.Z),Vector3.new(h.X,h.Y,h.Z))
		piece(Vector3.new(lo.X,-h.Y,-h.Z),Vector3.new(hi.X,lo.Y,h.Z))
		piece(Vector3.new(lo.X,hi.Y,-h.Z),Vector3.new(hi.X,h.Y,h.Z))
		piece(Vector3.new(lo.X,lo.Y,-h.Z),Vector3.new(hi.X,hi.Y,lo.Z))
		piece(Vector3.new(lo.X,lo.Y,hi.Z),Vector3.new(hi.X,hi.Y,h.Z))
		p:Destroy()
	end
	repair:SetAttribute(marker, #candidates)
	return marker .. ": opened " .. #candidates .. " wall or rail pieces"
end
