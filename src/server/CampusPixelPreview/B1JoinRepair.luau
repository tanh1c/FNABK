-- AI-assisted B1 repair. The complete original is copied to ServerStorage first.
return function()
	error("B1 join repair disabled: previous Studio execution did not complete; review and test before reuse")
	local root = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local original = root.B1
	local body = original.B1_ContinuousBuilding
	local storage = game:GetService("ServerStorage")
	assert(not storage:FindFirstChild("B1_BeforeJoinRepair_v1"), "Backup already exists")
	assert(not body:FindFirstChild("B1_JoinRepair_v1"), "Repair already exists")
	local backup = original:Clone()
	backup.Name = "B1_BeforeJoinRepair_v1"
	backup.Parent = storage
	local repair = Instance.new("Folder")
	repair.Name = "B1_JoinRepair_v1"
	repair.Parent = body

	-- Seal the two leftover ground-floor door openings in the ends of the U.
	local wings = {}
	for _, folder in ipairs(body:GetChildren()) do
		if folder.Name == "WalkableStructure" then
			local lintel = folder:FindFirstChild("OuterWall_Floor_01_South_Lintel")
			if lintel and math.abs(lintel.Orientation.Y) < 1 then table.insert(wings, folder) end
		end
	end
	assert(#wings == 2, "Expected two wing end walls")
	for _, wing in ipairs(wings) do
		local lintel = wing.OuterWall_Floor_01_South_Lintel
		local wall = wing.OuterWall_Floor_01_South_West
		local fill = Instance.new("Part")
		fill.Name = "SealedFormerWingEntrance"
		fill.Size = Vector3.new(lintel.Size.X + 0.05, wall.Size.Y, wall.Size.Z)
		fill.CFrame = CFrame.new(lintel.Position.X, wall.Position.Y, lintel.Position.Z) * wall.CFrame.Rotation
		fill.Anchored = true
		fill.Material, fill.Color = wall.Material, wall.Color
		fill.CanCollide, fill.CanTouch, fill.CanQuery = true, false, true
		fill.Parent = repair
	end

	-- Open a narrow passage through intersecting template walls and rails at each junction.
	-- ponytail: handles the current axis-aligned template only; use polygon clipping for rotated wings.
	local cuts = 0
	local candidates = {}
	for _, part in ipairs(body:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide and not part:IsDescendantOf(repair) then
			local n = part.Name
			if n:match("^OuterWall_Floor_0[123]_North$") or n:match("^GalleryRail_East_Floor_0[123]_")
				or n:match("^GalleryClassroomWall_F0[123]_Side_East_") then
				table.insert(candidates, part)
			end
		end
	end
	for _, part in ipairs(candidates) do
		for _, x in ipairs({5403.66, 5507.80}) do
			for floor = 0, 2 do
				local center = part.CFrame:PointToObjectSpace(Vector3.new(x, 5.0 + floor * 12.85714, 1689.1))
				local sx = math.abs(part.CFrame.RightVector.X) * 4 + math.abs(part.CFrame.RightVector.Z) * 4
				local sz = math.abs(part.CFrame.LookVector.X) * 4 + math.abs(part.CFrame.LookVector.Z) * 4
				local half = part.Size * 0.5
				local lo = Vector3.new(math.max(-half.X, center.X - sx), math.max(-half.Y, center.Y - 4.2), math.max(-half.Z, center.Z - sz))
				local hi = Vector3.new(math.min(half.X, center.X + sx), math.min(half.Y, center.Y + 4.2), math.min(half.Z, center.Z + sz))
				if hi.X - lo.X > 0.05 and hi.Y - lo.Y > 0.05 and hi.Z - lo.Z > 0.05 then
					local function piece(a, b)
						local size = b - a
						if size.X > 0.05 and size.Y > 0.05 and size.Z > 0.05 then
							local clone = part:Clone()
							clone.Name = part.Name .. "_JoinTrim"
							clone.Size = size
							clone.CFrame = part.CFrame * CFrame.new((a + b) * 0.5)
							clone.Parent = repair
							table.insert(candidates, clone)
						end
					end
					piece(Vector3.new(-half.X,-half.Y,-half.Z), Vector3.new(lo.X,half.Y,half.Z))
					piece(Vector3.new(hi.X,-half.Y,-half.Z), Vector3.new(half.X,half.Y,half.Z))
					piece(Vector3.new(lo.X,-half.Y,-half.Z), Vector3.new(hi.X,lo.Y,half.Z))
					piece(Vector3.new(lo.X,hi.Y,-half.Z), Vector3.new(hi.X,half.Y,half.Z))
					piece(Vector3.new(lo.X,lo.Y,-half.Z), Vector3.new(hi.X,hi.Y,lo.Z))
					piece(Vector3.new(lo.X,lo.Y,hi.Z), Vector3.new(hi.X,hi.Y,half.Z))
					part:Destroy()
					cuts += 1
					break
				end
			end
			if not part.Parent then break end
		end
	end
	assert(cuts >= 6, "Expected wall cuts at both junctions on three floors")
	repair:SetAttribute("OriginalPartsCut", cuts)
	return string.format("Backup saved; sealed 2 wing openings; opened %d structural pieces at junctions", cuts)
end
