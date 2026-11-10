--!strict
-- AC-01/02/03/07/08/09: spread the existing mission areas across the campus.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local layout = require(ReplicatedStorage:WaitForChild("FNABKShared"):WaitForChild("CampusLayout"))
local marketplaceBench = require(script.Parent:WaitForChild("MarketplaceBench"))
local marketplaceCampusComplex = require(script.Parent:WaitForChild("MarketplaceCampusComplex"))
local marketplaceSchool = require(script.Parent:WaitForChild("MarketplaceSchool"))
local marketplaceTree = require(script.Parent:WaitForChild("MarketplaceTree"))
local campusGatePortal = require(script.Parent:WaitForChild("CampusGatePortal"))
local campusBackdrop = require(script.Parent:WaitForChild("CampusBackdrop"))
local Lighting = game:GetService("Lighting")
local CampusExpansion = {}

local function translate(instance: Instance, offset: Vector3)
	if instance:IsA("Model") then
		instance:PivotTo(instance:GetPivot() + offset)
	elseif instance:IsA("BasePart") then
		instance.CFrame += offset
	else
		for _, child in ipairs(instance:GetChildren()) do
			translate(child, offset)
		end
	end
end

local function resize(map: Folder, name: string, size: Vector3, position: Vector3)
	local object = map:FindFirstChild(name)
	assert(object and object:IsA("BasePart"), "Missing campus boundary: " .. name)
	object.Size = size
	object.Position = position
end

local function mark(parent: Instance, name: string, position: Vector3, size: Vector3, color: Color3?)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Size = size
	p.Position = position
	p.Color = color or Color3.fromRGB(106, 118, 117)
	p.Material = Enum.Material.Concrete
	p.Parent = parent
end

local function structure(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = true
	p.CanTouch = false
	p.CanQuery = true
	p.CastShadow = true
	p.Size = size
	p.Position = position
	p.Color = color
	p.Material = material
	p.Parent = parent
	return p
end

local function detail(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local p = structure(parent, name, size, position, color, material)
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	return p
end

local function pathLamp(parent: Instance, x: number, z: number)
	local pole = Instance.new("Part")
	pole.Name = "CampusPathLampPole"
	pole.Anchored = true
	pole.CanCollide = true
	pole.CanQuery = false
	pole.CanTouch = false
	pole.CastShadow = false
	pole.Size = Vector3.new(0.45, 7, 0.45)
	pole.Position = Vector3.new(x, 3.5, z)
	pole.Color = Color3.fromRGB(43, 53, 66)
	pole.Material = Enum.Material.Metal
	pole.Parent = parent
	local lamp = Instance.new("Part")
	lamp.Name = "CampusPathLamp"
	lamp.Anchored = true
	lamp.CanCollide = false
	lamp.CanQuery = false
	lamp.CanTouch = false
	lamp.CastShadow = false
	lamp.Size = Vector3.new(1.6, 0.45, 1.6)
	lamp.Position = Vector3.new(x, 7.1, z)
	lamp.Color = Color3.fromRGB(235, 224, 190)
	lamp.Material = Enum.Material.Neon
	lamp.Parent = parent
	local light = Instance.new("PointLight")
	light.Name = "PathLight"
	light.Brightness = 2
	light.Range = 36
	light.Shadows = false
	light.Color = Color3.fromRGB(227, 220, 190)
	light.Parent = lamp
end

local function treeWell(parent: Instance, name: string, position: Vector3, accent: Color3)
	local bed = Instance.new("Folder")
	bed.Name = name
	bed.Parent = parent
	local cx, cz = position.X, position.Z
	local soil = detail(bed, "Soil", Vector3.new(7.6, 0.08, 6.2), Vector3.new(cx, 0.08, cz), Color3.fromRGB(77, 83, 66), Enum.Material.Ground)
	soil.CanTouch = false
	for _, side in ipairs({ -1, 1 }) do
		local longEdge = detail(bed, "StoneEdging", Vector3.new(7.8, 0.28, 0.22), Vector3.new(cx, 0.16, cz + side * 3), Color3.fromRGB(117, 127, 127), Enum.Material.Concrete)
		longEdge.CanCollide = true
		local endStone = detail(bed, "StoneEnd", Vector3.new(0.22, 0.28, 6.1), Vector3.new(cx + side * 3.8, 0.16, cz), Color3.fromRGB(117, 127, 127), Enum.Material.Concrete)
		endStone.CanCollide = true
	end
	local shrubOffsets = { Vector3.new(-2.25, 0.42, -2), Vector3.new(2.25, 0.42, -2), Vector3.new(-2.25, 0.42, 2), Vector3.new(2.25, 0.42, 2) }
	for index, offset in ipairs(shrubOffsets) do
		local shrub = detail(bed, "LowShrub", Vector3.new(0.82, 0.72, 0.82), position + offset, Color3.fromRGB(53, 102, 76), Enum.Material.SmoothPlastic)
		shrub.Shape = Enum.PartType.Ball
		if index == 1 or index == 4 then
			local blossom = detail(bed, "Blossom", Vector3.new(0.22, 0.22, 0.22), position + offset + Vector3.new(0, 0.3, 0), accent, Enum.Material.SmoothPlastic)
			blossom.Shape = Enum.PartType.Ball
		end
	end
end

local function wayfindingBoard(parent: Instance, position: Vector3)
	local post = detail(parent, "WayfindingPost", Vector3.new(0.42, 5.5, 0.42), position + Vector3.new(0, 2.75, 0), Color3.fromRGB(35, 53, 67), Enum.Material.Metal)
	post.CanTouch = false
	post.CanCollide = true
	local board = detail(parent, "WayfindingBoard", Vector3.new(8.5, 2.5, 0.38), position + Vector3.new(0, 5.5, 0), Color3.fromRGB(19, 36, 55), Enum.Material.SmoothPlastic)
	board.CanCollide = true
	local face = Instance.new("SurfaceGui")
	face.Name = "CampusDirections"
	face.Face = Enum.NormalId.Back
	face.CanvasSize = Vector2.new(850, 250)
	face.LightInfluence = 0
	face.Parent = board
	local label = Instance.new("TextLabel")
	label.Name = "Directions"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "A3 LAB     •     LIBRARY     •     B4"
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(223, 232, 231)
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = face
	local accent = detail(parent, "WayfindingAccent", Vector3.new(8.1, 0.12, 0.42), position + Vector3.new(0, 4.22, 0), Color3.fromRGB(29, 144, 127), Enum.Material.Metal)
	accent.CanTouch = false
end

local function perimeterDetails(parent: Instance)
	-- These are visual ribs on the existing collidable bounds; detail() keeps
	-- them query-free and non-collidable so the wall remains the only blocker.
	local darkMetal = Color3.fromRGB(47, 64, 76)
	local warmTrim = Color3.fromRGB(143, 112, 69)
	local segments = {
		{ name = "West", center = Vector3.new(-240, 0, 0), length = 300, alongX = false },
		{ name = "North", center = Vector3.new(-90, 0, -150), length = 300, alongX = true },
		{ name = "South", center = Vector3.new(-90, 0, 150), length = 300, alongX = true },
		{ name = "EastNorth", center = Vector3.new(60, 0, -79), length = 142, alongX = false },
		{ name = "EastSouth", center = Vector3.new(60, 0, 79), length = 142, alongX = false },
	}

	for _, segment in ipairs(segments) do
		local capSize = if segment.alongX then Vector3.new(segment.length, 0.38, 2.3) else Vector3.new(2.3, 0.38, segment.length)
		local cap = detail(parent, "PerimeterCap" .. segment.name, capSize, segment.center + Vector3.new(0, 10.08, 0), darkMetal, Enum.Material.Metal)
		cap.CastShadow = true
		local first = -segment.length / 2 + 10
		local last = segment.length / 2 - 10
		for offset = first, last, 24 do
			local postSize = if segment.alongX then Vector3.new(0.82, 9.65, 0.48) else Vector3.new(0.48, 9.65, 0.82)
			local inward = if segment.name == "West" then Vector3.new(1.28, 0, 0)
				elseif segment.name == "EastNorth" or segment.name == "EastSouth" then Vector3.new(-1.28, 0, 0)
				elseif segment.name == "North" then Vector3.new(0, 0, 1.28)
				else Vector3.new(0, 0, -1.28)
			local along = if segment.alongX then Vector3.new(offset, 0, 0) else Vector3.new(0, 0, offset)
			local pier = detail(parent, "PerimeterPier" .. segment.name, postSize, segment.center + along + inward + Vector3.new(0, 4.82, 0), Color3.fromRGB(80, 94, 101), Enum.Material.Concrete)
			pier.CastShadow = true
		end
		local bandSize = if segment.alongX then Vector3.new(segment.length, 0.14, 0.12) else Vector3.new(0.12, 0.14, segment.length)
		local bandOffset = if segment.name == "West" then Vector3.new(1.18, 1.45, 0)
			elseif segment.name == "EastNorth" or segment.name == "EastSouth" then Vector3.new(-1.18, 1.45, 0)
			elseif segment.name == "North" then Vector3.new(0, 1.45, 1.18)
			else Vector3.new(0, 1.45, -1.18)
		detail(parent, "PerimeterBand" .. segment.name, bandSize, segment.center + bandOffset, warmTrim, Enum.Material.Metal)
	end
end

local function courtyardFountain(parent: Instance, position: Vector3)
	-- Solid masonry blocks body traversal; water and small decorative fittings
	-- remain non-collidable so they cannot catch players on the paved plaza.
	local fountain = Instance.new("Model")
	fountain.Name = "CampusQuadFountain"
	fountain:SetAttribute("DecorativeOnly", true)
	fountain:SetAttribute("HasSolidMasonry", true)
	fountain.Parent = parent

	local function basinPart(name: string, diameter: number, height: number, y: number, color: Color3, material: Enum.Material, collidable: boolean)
		local createPart = if collidable then structure else detail
		local basin = createPart(fountain, name, Vector3.new(height, diameter, diameter), position + Vector3.new(0, y, 0), color, material)
		basin.Shape = Enum.PartType.Cylinder
		basin.CFrame = CFrame.new(position + Vector3.new(0, y, 0)) * CFrame.Angles(0, 0, math.rad(90))
		return basin
	end

	basinPart("StonePlinth", 8, 0.55, 0.3, Color3.fromRGB(71, 88, 96), Enum.Material.Slate, true)
	-- Raise a square masonry basin into a visible body-height landmark. Flat
	-- sides block walking; the circular rim and water keep the fountain language.
	structure(fountain, "OuterBasin", Vector3.new(6.8, 3.4, 6.8), position + Vector3.new(0, 1.75, 0), Color3.fromRGB(119, 131, 130), Enum.Material.Concrete)
	basinPart("BasinRim", 6.25, 0.22, 3.5, Color3.fromRGB(164, 157, 134), Enum.Material.Sandstone, true)
	local water = basinPart("StillWater", 5.82, 0.12, 3.55, Color3.fromRGB(57, 143, 155), Enum.Material.Glass, false)
	water.Transparency = 0.25
	local column = structure(fountain, "CenterColumn", Vector3.new(2.1, 0.9, 0.9), position + Vector3.new(0, 4.6, 0), Color3.fromRGB(47, 64, 76), Enum.Material.Metal)
	column.Shape = Enum.PartType.Cylinder
	column.CFrame = CFrame.new(position + Vector3.new(0, 4.6, 0)) * CFrame.Angles(0, 0, math.rad(90))
	local finial = detail(fountain, "AmberFinial", Vector3.new(0.82, 0.82, 0.82), position + Vector3.new(0, 5.83, 0), Color3.fromRGB(198, 149, 75), Enum.Material.Metal)
	finial.Shape = Enum.PartType.Ball
	local label = detail(fountain, "CampusQuadPlaque", Vector3.new(3.4, 0.72, 0.16), position + Vector3.new(0, 1.5, -4.15), Color3.fromRGB(19, 36, 55), Enum.Material.SmoothPlastic)
	local face = Instance.new("SurfaceGui")
	face.Name = "QuadName"
	face.Face = Enum.NormalId.Front
	face.CanvasSize = Vector2.new(680, 144)
	face.LightInfluence = 0
	face.Parent = label
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Name"
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "CAMPUS QUAD"
	textLabel.TextColor3 = Color3.fromRGB(225, 234, 250)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.Parent = face
end

local function dividerMonument(parent: Instance, divider: BasePart)
	-- Keep the original divider collision and sight-blocking job. Dress both
	-- faces as campus wayfinding panels with parts that cannot catch players.
	local dressing = Instance.new("Model")
	dressing.Name = "CampusQuadDividerDress"
	dressing:SetAttribute("DecorativeOnly", true)
	dressing.Parent = parent
	divider.Material = Enum.Material.Slate
	divider.Color = Color3.fromRGB(58, 75, 86)

	local x, y, z = divider.Position.X, divider.Position.Y, divider.Position.Z
	local halfX, halfZ = divider.Size.X / 2, divider.Size.Z / 2
	detail(dressing, "DividerCrown", Vector3.new(divider.Size.X + 0.4, 0.3, divider.Size.Z + 0.4), Vector3.new(x, y + divider.Size.Y / 2 + 0.1, z), Color3.fromRGB(35, 53, 67), Enum.Material.Metal)
	for _, side in ipairs({ -1, 1 }) do
		local faceX = x + side * (halfX + 0.1)
		local panel = detail(dressing, "DividerFacePanel", Vector3.new(0.16, 6.4, divider.Size.Z - 5), Vector3.new(faceX, y, z), Color3.fromRGB(77, 96, 104), Enum.Material.Concrete)
		panel.CastShadow = true
		for _, zOffset in ipairs({ -halfZ + 3, halfZ - 3 }) do
			detail(dressing, "DividerAccentPier", Vector3.new(0.2, 6.7, 0.34), Vector3.new(faceX + side * 0.12, y, z + zOffset), Color3.fromRGB(29, 144, 127), Enum.Material.Metal)
		end
		for _, bandY in ipairs({ y - 3.7, y + 3.7 }) do
			detail(dressing, "DividerWarmBand", Vector3.new(0.2, 0.14, divider.Size.Z - 4), Vector3.new(faceX + side * 0.12, bandY, z), Color3.fromRGB(143, 112, 69), Enum.Material.Metal)
		end
		local board = detail(
			dressing,
			"DividerWayfindingBoard",
			Vector3.new(0.34, 1.35, divider.Size.Z - 10),
			Vector3.new(x + side * (halfX + 0.34), y + 2.35, z),
			Color3.fromRGB(19, 36, 55),
			Enum.Material.SmoothPlastic
		)
		local surface = Instance.new("SurfaceGui")
		surface.Name = "CampusRouteLabel"
		surface.Face = if side > 0 then Enum.NormalId.Right else Enum.NormalId.Left
		surface.CanvasSize = Vector2.new(1200, 80)
		surface.LightInfluence = 0
		surface.Parent = board
		local label = Instance.new("TextLabel")
		label.Name = "Routes"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = "FNABK CAMPUS  |  A3  -  LIBRARY  -  B4"
		label.TextColor3 = Color3.fromRGB(225, 234, 250)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 44
		label.TextScaled = false
		label.TextWrapped = false
		label.Parent = surface
	end
end

local function campusBuilding(
	parent: Instance,
	name: string,
	origin: Vector3,
	width: number,
	depth: number,
	height: number,
	frontDirection: number,
	doorOffset: number,
	title: string,
	passThrough: boolean,
	accentColor: Color3,
	doorWidthOverride: number?
)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("CampusStructure", true)
	model.Parent = parent
	local x, z = origin.X, origin.Z
	local backDirection = -frontDirection
	local halfWidth = width / 2
	local wallThickness = 1
	local doorWidth = doorWidthOverride or (if passThrough then 14 else 10)
	local doorHeight = math.min(8.4, height - 2.6)
	local wallColor = if name == "CampusLibrary" then Color3.fromRGB(205, 202, 190)
		elseif name == "A3EngineeringLab" then Color3.fromRGB(183, 193, 190)
		elseif name == "B4GeneratorRoom" then Color3.fromRGB(164, 177, 178)
		else Color3.fromRGB(194, 201, 195)
	local rearColor = if name == "CampusLibrary" then Color3.fromRGB(132, 132, 120)
		elseif name == "A3EngineeringLab" then Color3.fromRGB(115, 132, 136)
		elseif name == "B4GeneratorRoom" then Color3.fromRGB(91, 108, 116)
		else Color3.fromRGB(132, 143, 143)
	local trimColor = Color3.fromRGB(35, 53, 67)
	local sillColor = Color3.fromRGB(148, 157, 154)
	local concrete = Enum.Material.Concrete

	structure(model, "EntryWingFloor", Vector3.new(width, 0.2, depth), Vector3.new(x, 0.1, z + backDirection * depth / 2), Color3.fromRGB(91, 102, 106), concrete)
	structure(model, "FlatRoof", Vector3.new(width + 2, 0.8, depth + 2), Vector3.new(x, height + 0.4, z + backDirection * depth / 2), Color3.fromRGB(45, 58, 70), concrete)
	if not passThrough then
		structure(model, "RearWall", Vector3.new(width, height, wallThickness), Vector3.new(x, height / 2, z + backDirection * depth), rearColor, concrete)
	end
	for _, side in ipairs({ -1, 1 }) do
		structure(model, "SideWall", Vector3.new(wallThickness, height, depth), Vector3.new(x + side * (halfWidth - wallThickness / 2), height / 2, z + backDirection * depth / 2), rearColor, concrete)
		local sideFaceX = x + side * (halfWidth + 0.08)
		local sideWindowWidth = math.min(7.4, depth * 0.28)
		for station, fraction in ipairs({ 0.28, 0.72 }) do
			local sideCenterZ = z + backDirection * depth * fraction
			for row, bounds in ipairs({ { 3.1, 5.85 }, { 9.1, 11.85 } }) do
				local suffix = string.format("%d_%d_%d", side, station, row)
				local paneHeight = bounds[2] - bounds[1]
				local paneCenterY = (bounds[1] + bounds[2]) / 2
				local lit = (station + row) % 3 == 0
				local pane = detail(model, "SideWindowGlass" .. suffix, Vector3.new(0.14, paneHeight - 0.28, sideWindowWidth - 0.3), Vector3.new(sideFaceX, paneCenterY, sideCenterZ), if lit then Color3.fromRGB(185, 164, 128) else Color3.fromRGB(74, 112, 139), Enum.Material.Glass)
				pane.Transparency = 0.16
				for _, endSide in ipairs({ -1, 1 }) do
					detail(model, "SideWindowJamb" .. suffix, Vector3.new(0.22, paneHeight + 0.28, 0.2), Vector3.new(sideFaceX + side * 0.08, paneCenterY, sideCenterZ + endSide * sideWindowWidth / 2), sillColor, Enum.Material.SmoothPlastic)
				end
				detail(model, "SideWindowMullion" .. suffix, Vector3.new(0.24, paneHeight, 0.16), Vector3.new(sideFaceX + side * 0.08, paneCenterY, sideCenterZ), accentColor, Enum.Material.Metal)
				detail(model, "SideWindowSill" .. suffix, Vector3.new(0.26, 0.2, sideWindowWidth + 0.3), Vector3.new(sideFaceX + side * 0.08, bounds[1] - 0.08, sideCenterZ), sillColor, Enum.Material.Concrete)
				detail(model, "SideWindowHeader" .. suffix, Vector3.new(0.26, 0.2, sideWindowWidth + 0.3), Vector3.new(sideFaceX + side * 0.08, bounds[2] + 0.08, sideCenterZ), accentColor, Enum.Material.Metal)
				local shade = detail(model, "SideWindowSunshade" .. suffix, Vector3.new(0.9, 0.24, sideWindowWidth + 0.8), Vector3.new(sideFaceX + side * 0.65, bounds[2] + 0.22, sideCenterZ), trimColor, Enum.Material.Metal)
				shade.CastShadow = true
			end
		end
		-- AC-01/02/03/07/08/09: break up the broad side elevations with
		-- restrained story bands and a central pier; these stay visual-only.
		local sideCenterZ = z + backDirection * depth / 2
		detail(model, "SidePlinth", Vector3.new(0.32, 1.1, depth - 1.5), Vector3.new(sideFaceX, 0.62, sideCenterZ), rearColor, concrete)
		detail(model, "SideStoryBand", Vector3.new(0.72, 0.58, depth - 1.5), Vector3.new(sideFaceX, 7.4, sideCenterZ), accentColor, Enum.Material.Metal)
		detail(model, "SideCornice", Vector3.new(0.58, 0.48, depth + 1), Vector3.new(sideFaceX, height - 0.52, sideCenterZ), trimColor, Enum.Material.Metal)
		detail(model, "SideFacadePier", Vector3.new(0.36, height - 1.6, 0.54), Vector3.new(sideFaceX, (height + 1.6) / 2, sideCenterZ), accentColor, Enum.Material.Metal)
	end

	-- Split each facade at door/window edges. Glass fills window gaps and blocks
	-- characters, while CanQuery=false lets gameplay sight rays pass through.
	local function wallOpening(label: string, wallZ: number, wallDirection: number)
		local wallLeft = -halfWidth + wallThickness / 2
		local wallRight = halfWidth - wallThickness / 2
		local openings = {
			{
				kind = "Door",
				center = doorOffset,
				left = math.clamp(doorOffset - doorWidth / 2, wallLeft, wallRight),
				right = math.clamp(doorOffset + doorWidth / 2, wallLeft, wallRight),
				bottom = 0,
				top = doorHeight,
				row = 0,
			},
		}
		local windowWidth = if width >= 76 then 10 else math.min(8.2, math.max(6.8, width * 0.16))
		local windowRows = {
			{ 2.6, 5.9 },
			{ 9.1, 12.2 },
		}
		for _, fraction in ipairs({ -0.38, -0.2, 0.2, 0.38 }) do
			local center = width * fraction
			local edgeClearance = (doorWidth + windowWidth) / 2 + 2.5
			if math.abs(center - doorOffset) <= edgeClearance then continue end
			local left = math.clamp(center - windowWidth / 2, wallLeft, wallRight)
			local right = math.clamp(center + windowWidth / 2, wallLeft, wallRight)
			if right - left >= windowWidth - 0.2 then
				for row, vertical in ipairs(windowRows) do
					table.insert(openings, {
						kind = "Window",
						center = center,
						left = left,
						right = right,
						bottom = vertical[1],
						top = math.min(vertical[2], height - 1.7),
						row = row,
					})
				end
			end
		end
		table.sort(openings, function(a, b)
			return a.left < b.left
		end)

		local boundaries = { wallLeft, wallRight }
		for _, opening in ipairs(openings) do
			table.insert(boundaries, opening.left)
			table.insert(boundaries, opening.right)
		end
		table.sort(boundaries)
		local uniqueBoundaries = {}
		for _, boundary in ipairs(boundaries) do
			if #uniqueBoundaries == 0 or math.abs(boundary - uniqueBoundaries[#uniqueBoundaries]) > 0.01 then
				table.insert(uniqueBoundaries, boundary)
			end
		end

		local function wallSegment(segmentName: string, left: number, right: number, bottom: number, top: number)
			if right - left < 0.08 or top - bottom < 0.08 then return end
			structure(
				model,
				label .. segmentName,
				Vector3.new(right - left, top - bottom, wallThickness),
				Vector3.new(x + (left + right) / 2, (bottom + top) / 2, wallZ),
				wallColor,
				concrete
			)
		end

		for index = 1, #uniqueBoundaries - 1 do
			local left = uniqueBoundaries[index]
			local right = uniqueBoundaries[index + 1]
			local center = (left + right) / 2
			local activeOpenings = {}
			for _, candidate in ipairs(openings) do
				if center > candidate.left and center < candidate.right then
					table.insert(activeOpenings, candidate)
				end
			end
			table.sort(activeOpenings, function(a, b)
				return a.bottom < b.bottom
			end)
			local cursor = 0
			for openingIndex, opening in ipairs(activeOpenings) do
				if opening.bottom > cursor then
					wallSegment(string.format("WallBay%dSegment%d", index, openingIndex), left, right, cursor, opening.bottom)
				end
				cursor = math.max(cursor, opening.top)
			end
			if cursor < height then
				wallSegment("WallBay" .. index .. "Upper", left, right, cursor, height)
			end
		end

		for index, opening in ipairs(openings) do
			if opening.kind == "Door" then
				for _, side in ipairs({ -1, 1 }) do
					detail(model, label .. "DoorFrame" .. side, Vector3.new(0.42, doorHeight, 0.34), Vector3.new(x + opening.center + side * (doorWidth / 2 + 0.08), doorHeight / 2, wallZ + wallDirection * 0.56), accentColor, Enum.Material.Metal)
				end
			else
				local paneHeight = opening.top - opening.bottom
				local paneCenterY = (opening.top + opening.bottom) / 2
				local lit = (index + opening.row) % 3 == 0
				local pane = detail(model, label .. "WindowGlass" .. index, Vector3.new(windowWidth - 0.42, paneHeight - 0.34, 0.16), Vector3.new(x + opening.center, paneCenterY, wallZ + wallDirection * 0.57), if lit then Color3.fromRGB(190, 170, 135) else Color3.fromRGB(82, 126, 151), Enum.Material.Glass)
				pane.Transparency = 0.16
				pane.CanCollide = true
				local faceZ = wallZ + wallDirection * 0.68
				for _, side in ipairs({ -1, 1 }) do
					detail(model, label .. "WindowJamb" .. index, Vector3.new(0.24, paneHeight + 0.32, 0.22), Vector3.new(x + opening.center + side * (windowWidth / 2), paneCenterY, faceZ), sillColor, Enum.Material.SmoothPlastic)
				end
				detail(model, label .. "WindowMullion" .. index, Vector3.new(0.16, paneHeight, 0.24), Vector3.new(x + opening.center, paneCenterY, faceZ), accentColor, Enum.Material.Metal)
				detail(model, label .. "WindowSill" .. index, Vector3.new(windowWidth + 0.35, 0.22, 0.34), Vector3.new(x + opening.center, opening.bottom - 0.08, faceZ), sillColor, Enum.Material.Concrete)
				detail(model, label .. "WindowHeader" .. index, Vector3.new(windowWidth + 0.35, 0.22, 0.34), Vector3.new(x + opening.center, opening.top + 0.08, faceZ), accentColor, Enum.Material.Metal)
				local shade = detail(model, label .. "WindowSunshade" .. index, Vector3.new(windowWidth + 0.8, 0.24, 1.2), Vector3.new(x + opening.center, opening.top + 0.22, wallZ + wallDirection * 0.9), trimColor, Enum.Material.Metal)
				shade.CastShadow = true
			end
		end
	end

	wallOpening("Front", z, frontDirection)
	if passThrough then
		wallOpening("Rear", z + backDirection * depth, backDirection)
	end

	-- Taller pilasters frame the entrances and make the shell read like an
	-- academic building from the courtyard, without covering windows or doors.
	for _, side in ipairs({ -1, 1 }) do
		detail(model, "FacadeCornerPier", Vector3.new(1.35, height - 1.4, 0.65), Vector3.new(x + side * (halfWidth - 1.05), (height + 1.4) / 2, z + frontDirection * 0.72), trimColor, Enum.Material.Concrete)
		local entryPierOffset = doorOffset + side * (doorWidth / 2 + 1.3)
		local windowWidth = if width >= 76 then 10 else math.min(8.2, math.max(6.8, width * 0.16))
		local overlapsWindow = false
		for _, fraction in ipairs({ -0.38, -0.2, 0.2, 0.38 }) do
			if math.abs(width * fraction - entryPierOffset) < windowWidth / 2 + 1.25 then
				overlapsWindow = true
				break
			end
		end
		if math.abs(entryPierOffset) < halfWidth - 2 and not overlapsWindow then
			local pier = detail(model, "EntryFacadePier", Vector3.new(0.72, height - 1.8, 0.55), Vector3.new(x + entryPierOffset, (height + 1.8) / 2, z + frontDirection * 0.73), accentColor, Enum.Material.Metal)
		end
	end

	local frontFaceZ = z + frontDirection * 0.64
	detail(model, "FrontPlinth", Vector3.new(width - 1.5, 1.1, 0.38), Vector3.new(x, 0.62, frontFaceZ), rearColor, concrete)
	detail(model, "FrontBeltTrim", Vector3.new(width - 1.5, 0.28, 0.3), Vector3.new(x, 1.65, frontFaceZ), sillColor, Enum.Material.Metal)
	detail(model, "FrontStoryBand", Vector3.new(width - 1.5, 0.58, 0.72), Vector3.new(x, 7.4, frontFaceZ), accentColor, Enum.Material.Metal)
	detail(model, "FrontCornice", Vector3.new(width + 1.2, 0.48, 0.58), Vector3.new(x, height - 0.52, frontFaceZ), trimColor, Enum.Material.Metal)
	detail(model, "RoofFrontParapet", Vector3.new(width + 1, 1.1, 0.7), Vector3.new(x, height + 1.22, z + frontDirection * (wallThickness / 2 + 0.72)), trimColor, concrete)
	for _, side in ipairs({ -1, 1 }) do
		detail(model, "RoofSideParapet", Vector3.new(0.7, 1.1, depth - 0.8), Vector3.new(x + side * (halfWidth + 0.72), height + 1.22, z + backDirection * depth / 2), trimColor, concrete)
	end
	local rooftopVent = detail(model, "RooftopVent", Vector3.new(math.min(12, width * 0.22), 1.6, math.min(8, depth * 0.35)), Vector3.new(x - width * 0.24, height + 1.45, z + backDirection * (depth * 0.68)), Color3.fromRGB(82, 97, 105), Enum.Material.Metal)
	rooftopVent.CastShadow = true
	local towerWidth = math.min(doorWidth + 7, 30)
	local towerCenter = Vector3.new(x + doorOffset, height + 1.42, z + frontDirection * 1.38)
	-- Raised entry massing and its emissive slots mark the building at night;
	-- both use decorative Parts so existing doors and windows keep their physics.
	local entryTower = detail(model, "EntryTower", Vector3.new(towerWidth, 3.1, 3.5), towerCenter, accentColor, Enum.Material.Concrete)
	entryTower.CastShadow = true
	detail(model, "EntryTowerCrown", Vector3.new(towerWidth + 1, 0.42, 4), towerCenter + Vector3.new(0, 1.78, 0), trimColor, Enum.Material.Metal)
	for _, side in ipairs({ -1, 1 }) do
		detail(
			model,
			"EntryTowerClerestory",
			Vector3.new(0.32, 1.35, 0.12),
			Vector3.new(x + doorOffset + side * (towerWidth / 2 - 0.85), height + 1.42, z + frontDirection * 3.18),
			Color3.fromRGB(147, 181, 177),
			Enum.Material.Glass
		)
	end
	local canopyY = doorHeight + 0.8
	local canopy = structure(model, "EntryCanopy", Vector3.new(doorWidth + 6, 0.65, 4.6), Vector3.new(x + doorOffset, canopyY, z + frontDirection * 2.25), accentColor, Enum.Material.Metal)
	canopy.CanQuery = false
	for slat = -2, 2 do
		detail(model, "CanopyUndersideSlat", Vector3.new(0.22, 0.12, 4.1), Vector3.new(x + doorOffset + slat * (doorWidth + 4) / 5, canopyY - 0.4, z + frontDirection * 2.35), trimColor, Enum.Material.Metal)
	end
	for _, side in ipairs({ -1, 1 }) do
		local supportHeight = canopyY - 0.45
		structure(model, "CanopySupport", Vector3.new(0.62, supportHeight, 0.62), Vector3.new(x + doorOffset + side * (doorWidth / 2 + 1.55), supportHeight / 2, z + frontDirection * 3.75), trimColor, Enum.Material.Metal)
	end
	local entryApron = detail(model, "EntryApron", Vector3.new(doorWidth + 12, 0.06, 8), Vector3.new(x + doorOffset, 0.035, z + frontDirection * 5.6), Color3.fromRGB(154, 160, 156), Enum.Material.Concrete)
	entryApron.CanTouch = false
	local threshold = detail(model, "EntryThreshold", Vector3.new(doorWidth - 0.5, 0.08, 2.5), Vector3.new(x + doorOffset, 0.12, z + frontDirection * 1), Color3.fromRGB(198, 149, 75), Enum.Material.Metal)
	threshold.CanTouch = false
	local plaque = detail(
		model,
		"BuildingPlaque",
		Vector3.new(towerWidth - 4, 1.3, 0.16),
		Vector3.new(x + doorOffset, towerCenter.Y, z + frontDirection * 3.2),
		Color3.fromRGB(19, 36, 55),
		Enum.Material.SmoothPlastic
	)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "BuildingName"
	surface.Face = if frontDirection > 0 then Enum.NormalId.Back else Enum.NormalId.Front
	local canvasHeight = 100
	surface.CanvasSize = Vector2.new(math.round(plaque.Size.X / plaque.Size.Y * canvasHeight), canvasHeight)
	surface.LightInfluence = 0
	surface.Parent = plaque
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(223, 232, 231)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 52
	label.TextScaled = false
	label.TextWrapped = false
	label.Text = title
	label.Parent = surface
	local entryLight = Instance.new("PointLight")
	entryLight.Name = "EntryLight"
	entryLight.Brightness = 1.3
	entryLight.Range = 31
	entryLight.Shadows = false
	entryLight.Color = Color3.fromRGB(207, 211, 184)
	entryLight.Parent = canopy
end

local function verticalCylinderDetail(
	parent: Instance,
	name: string,
	position: Vector3,
	height: number,
	diameter: number,
	color: Color3,
	material: Enum.Material
): Part
	local column = detail(parent, name, Vector3.new(height, diameter, diameter), position, color, material)
	column.Shape = Enum.PartType.Cylinder
	column.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	return column
end

local function campusAtrium(
	parent: Instance,
	name: string,
	center: Vector3,
	width: number,
	depth: number,
	baseY: number,
	wallHeight: number,
	frameColor: Color3
)
	-- A light framed glass pavilion gives the academic roofs a stepped silhouette
	-- without adding collision above the walkable ground floor.
	detail(parent, name .. "Base", Vector3.new(width, 0.24, depth), center + Vector3.new(0, baseY + 0.12, 0), frameColor, Enum.Material.Metal)
	local wallY = baseY + wallHeight / 2
	local glassColor = Color3.fromRGB(112, 166, 184)
	for _, side in ipairs({ -1, 1 }) do
		local glass = detail(parent, name .. "LongGlass", Vector3.new(width - 0.5, wallHeight - 0.35, 0.16), center + Vector3.new(0, wallY, side * (depth / 2 - 0.08)), glassColor, Enum.Material.Glass)
		glass.Transparency = 0.23
		local endGlass = detail(parent, name .. "EndGlass", Vector3.new(0.16, wallHeight - 0.35, depth - 0.5), center + Vector3.new(side * (width / 2 - 0.08), wallY, 0), glassColor, Enum.Material.Glass)
		endGlass.Transparency = 0.23
		local sideCornice = detail(parent, name .. "SideCornice", Vector3.new(0.35, 0.28, depth), center + Vector3.new(side * (width / 2 - 0.06), baseY + wallHeight - 0.02, 0), frameColor, Enum.Material.Metal)
		sideCornice.CastShadow = true
	end
	for _, side in ipairs({ -1, 1 }) do
		local cornice = detail(parent, name .. "FrontCornice", Vector3.new(width, 0.28, 0.35), center + Vector3.new(0, baseY + wallHeight - 0.02, side * (depth / 2 - 0.06)), frameColor, Enum.Material.Metal)
		cornice.CastShadow = true
	end
	for index = 1, 4 do
		local xOffset = -width / 2 + width * index / 5
		detail(parent, name .. "GlassMullion", Vector3.new(0.14, wallHeight - 0.2, 0.24), center + Vector3.new(xOffset, wallY, -depth / 2 + 0.04), frameColor, Enum.Material.Metal)
		detail(parent, name .. "GlassMullion", Vector3.new(0.14, wallHeight - 0.2, 0.24), center + Vector3.new(xOffset, wallY, depth / 2 - 0.04), frameColor, Enum.Material.Metal)
	end
	local roofGlass = detail(parent, name .. "RoofGlass", Vector3.new(width - 0.3, 0.16, depth - 0.3), center + Vector3.new(0, baseY + wallHeight + 0.06, 0), glassColor, Enum.Material.Glass)
	roofGlass.Transparency = 0.2
	for index = 1, 3 do
		local zOffset = -depth / 2 + depth * index / 4
		detail(parent, name .. "RoofRib", Vector3.new(width, 0.12, 0.16), center + Vector3.new(0, baseY + wallHeight + 0.16, zOffset), frameColor, Enum.Material.Metal)
	end
end

local function campusIdentityDetails(buildings: Folder)
	-- AC-01/02/03/06/07/08/09: make the campus buildings recognizable by role
	-- while keeping mission openings and ground-floor collision unchanged.
	local northWing = buildings:FindFirstChild("NorthAcademicWing")
	if northWing and not northWing:GetAttribute("SourceAssetId") then
		structure(northWing, "AcademicClockTower", Vector3.new(9, 10, 9), Vector3.new(-31, 19, -60), Color3.fromRGB(48, 65, 78), Enum.Material.Concrete)
		detail(northWing, "AcademicClockTowerCornice", Vector3.new(10, 0.55, 10), Vector3.new(-31, 24.2, -60), Color3.fromRGB(35, 53, 67), Enum.Material.Metal)
		local dome = detail(northWing, "AcademicClockTowerDome", Vector3.new(8.8, 4.4, 8.8), Vector3.new(-31, 26.6, -60), Color3.fromRGB(67, 131, 154), Enum.Material.Slate)
		dome.Shape = Enum.PartType.Ball
		verticalCylinderDetail(northWing, "AcademicTowerFinial", Vector3.new(-31, 29.5, -60), 1.4, 0.48, Color3.fromRGB(198, 149, 75), Enum.Material.Metal)
		local clockFace = detail(northWing, "AcademicClockFace", Vector3.new(0.22, 4.1, 4.1), Vector3.new(-31, 21.7, -55.38), Color3.fromRGB(19, 36, 55), Enum.Material.SmoothPlastic)
		clockFace.Shape = Enum.PartType.Cylinder
		clockFace.CFrame = CFrame.new(clockFace.Position) * CFrame.Angles(0, -math.rad(90), 0)
		for hour = 0, 11 do
			local angle = hour * math.pi / 6
			local mark = detail(
				northWing,
				"AcademicClockMarker",
				Vector3.new(0.1, 0.38, 0.08),
				Vector3.new(-31 + math.sin(angle) * 1.55, 21.7 + math.cos(angle) * 1.55, -55.12),
				Color3.fromRGB(218, 207, 168),
				Enum.Material.Neon
			)
			mark.CFrame = CFrame.new(mark.Position) * CFrame.Angles(0, 0, -angle)
		end
		local hourHand = detail(northWing, "AcademicClockHourHand", Vector3.new(0.12, 0.95, 0.08), Vector3.new(-31, 21.96, -55.1), Color3.fromRGB(232, 223, 195), Enum.Material.Neon)
		hourHand.CFrame = CFrame.new(hourHand.Position) * CFrame.Angles(0, 0, math.rad(-40))
		local minuteHand = detail(northWing, "AcademicClockMinuteHand", Vector3.new(0.1, 1.38, 0.08), Vector3.new(-30.76, 21.7, -55.08), Color3.fromRGB(232, 223, 195), Enum.Material.Neon)
		minuteHand.CFrame = CFrame.new(minuteHand.Position) * CFrame.Angles(0, 0, math.rad(45))
	end

	local southWing = buildings:WaitForChild("SouthAcademicWing")
	if not southWing:GetAttribute("SourceAssetId") then
		campusAtrium(southWing, "StudentCommonsAtrium", Vector3.new(-22, 0, 60), 20, 8, 14.46, 2.1, Color3.fromRGB(67, 131, 154))
	end

	local library = buildings:WaitForChild("CampusLibrary")
	campusAtrium(library, "LibraryReadingHall", Vector3.new(5, 0, 122.5), 27, 12, 16.46, 2.55, Color3.fromRGB(35, 53, 67))
	local libraryCanopyHeight = math.min(8.4, 16 - 2.6) + 0.8
	local libraryDoorCenterX = 5 + 18
	for _, offset in ipairs({ -7.5, 7.5 }) do
		local column = verticalCylinderDetail(
			library,
			"LibraryPorticoColumn",
			Vector3.new(libraryDoorCenterX + offset, libraryCanopyHeight / 2, 110.5),
			libraryCanopyHeight,
			0.86,
			Color3.fromRGB(205, 202, 190),
			Enum.Material.Sandstone
		)
		column.CanCollide = true
		column.CanQuery = true
		local capital = detail(library, "LibraryPorticoCapital", Vector3.new(1.35, 0.32, 1.35), Vector3.new(libraryDoorCenterX + offset, libraryCanopyHeight - 0.12, 110.5), Color3.fromRGB(198, 149, 75), Enum.Material.Metal)
		capital.CastShadow = true
	end

	local a3 = buildings:WaitForChild("A3EngineeringLab")
	for _, x in ipairs({ -138, -126, -114 }) do
		local grille = detail(a3, "A3RearVentPanel", Vector3.new(6.6, 4.4, 0.16), Vector3.new(x, 8.1, -80.58), Color3.fromRGB(35, 53, 67), Enum.Material.Metal)
		grille.CastShadow = true
		for slat = 1, 4 do
			detail(a3, "A3RearVentSlat", Vector3.new(6.1, 0.12, 0.12), Vector3.new(x, 6.6 + slat * 0.72, -80.72), Color3.fromRGB(29, 144, 127), Enum.Material.Metal)
		end
	end

	local b4 = buildings:WaitForChild("B4GeneratorRoom")
	for _, x in ipairs({ -12, 3, 18 }) do
		local grille = detail(b4, "B4RearVentPanel", Vector3.new(7.4, 4.8, 0.16), Vector3.new(x, 8.3, -132.58), Color3.fromRGB(35, 53, 67), Enum.Material.Metal)
		grille.CastShadow = true
		for slat = 1, 4 do
			detail(b4, "B4RearVentSlat", Vector3.new(6.9, 0.14, 0.12), Vector3.new(x, 6.7 + slat * 0.78, -132.72), Color3.fromRGB(198, 149, 75), Enum.Material.Metal)
		end
	end
end

local function campusRoleRoofDetails(buildings: Folder)
	-- AC-01/06/07/08/09: give the objective buildings distinct utility silhouettes.
	local a3 = buildings:WaitForChild("A3EngineeringLab")
	for index, x in ipairs({ -137, -115 }) do
		local unit = detail(a3, "A3RoofChiller" .. index, Vector3.new(6.5, 2, 5.2), Vector3.new(x, 17.8, -65), Color3.fromRGB(89, 105, 113), Enum.Material.Metal)
		unit.CastShadow = true
		local fan = detail(a3, "A3RoofFan" .. index, Vector3.new(1.8, 0.28, 1.8), Vector3.new(x, 18.94, -65), Color3.fromRGB(29, 144, 127), Enum.Material.Metal)
		fan.Shape = Enum.PartType.Cylinder
	end
	detail(a3, "A3RoofConduit", Vector3.new(1.1, 0.22, 13), Vector3.new(-126, 17.05, -65), Color3.fromRGB(198, 149, 75), Enum.Material.Metal)

	local library = buildings:WaitForChild("CampusLibrary")
	local skylight = detail(library, "LibraryAtriumSkylight", Vector3.new(22, 0.48, 8), Vector3.new(5, 19.34, 122.5), Color3.fromRGB(103, 166, 179), Enum.Material.Glass)
	skylight.Transparency = 0.18
	for _, x in ipairs({ -5, 5, 15 }) do
		detail(library, "LibraryAtriumSkylightRib", Vector3.new(0.24, 0.2, 8.4), Vector3.new(x, 19.63, 122.5), Color3.fromRGB(35, 53, 67), Enum.Material.Metal)
	end

	local b4 = buildings:WaitForChild("B4GeneratorRoom")
	for index, x in ipairs({ -10, 10 }) do
		local stack = detail(b4, "B4ExhaustStack" .. index, Vector3.new(2.8, 4, 2.8), Vector3.new(3 + x, 18.8, -117), Color3.fromRGB(72, 89, 101), Enum.Material.Metal)
		stack.Shape = Enum.PartType.Cylinder
		stack.CastShadow = true
		local cap = detail(b4, "B4ExhaustCap" .. index, Vector3.new(3.3, 0.32, 3.3), Vector3.new(3 + x, 20.96, -117), Color3.fromRGB(198, 149, 75), Enum.Material.Metal)
		cap.Shape = Enum.PartType.Cylinder
	end
end

local function setCampusLighting()
	Lighting.ClockTime = 0.2
	Lighting.Brightness = 3.55
	Lighting.Ambient = Color3.fromRGB(145, 157, 171)
	Lighting.OutdoorAmbient = Color3.fromRGB(160, 172, 186)
	Lighting.EnvironmentDiffuseScale = 0.62
	Lighting.EnvironmentSpecularScale = 0.2
	Lighting.FogColor = Color3.fromRGB(39, 51, 72)
	Lighting.FogStart = 210
	Lighting.FogEnd = 720
	local sky = Lighting:FindFirstChild("FNABKCampusSky") :: Sky?
	if not sky then
		sky = Instance.new("Sky")
		sky.Name = "FNABKCampusSky"
		sky.Parent = Lighting
	end
	for _, side in ipairs({ "Bk", "Dn", "Ft", "Lf", "Rt", "Up" }) do
		sky["Skybox" .. side] = "rbxasset://textures/sky/sky512_" .. string.lower(side) .. ".tex"
	end
	sky.CelestialBodiesShown = false
	sky.StarCount = 0
	sky.SunAngularSize = 0
	sky.MoonAngularSize = 0
	local atmosphere = Lighting:FindFirstChild("FNABKCampusAtmosphere") :: Atmosphere?
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "FNABKCampusAtmosphere"
		atmosphere.Parent = Lighting
	end
	atmosphere.Color = Color3.fromRGB(116, 140, 184)
	atmosphere.Decay = Color3.fromRGB(28, 42, 70)
	atmosphere.Density = 0.1
	atmosphere.Glare = 0
	atmosphere.Haze = 0.22
	atmosphere.Offset = -0.08
	local grade = Lighting:FindFirstChild("FNABKCampusGrade") :: ColorCorrectionEffect?
	if not grade then
		grade = Instance.new("ColorCorrectionEffect")
		grade.Name = "FNABKCampusGrade"
		grade.Parent = Lighting
	end
	grade.Brightness = 0.022
	grade.Contrast = 0.015
	grade.Saturation = -0.025
	grade.TintColor = Color3.fromRGB(225, 234, 250)
end

function CampusExpansion.Build(map: Folder)
	if map:GetAttribute("CampusExpanded") then return end
	resize(map, "CourtyardFloor", Vector3.new(300, 1, 300), Vector3.new(-90, -0.5, 0))
	local courtyardFloor = map:FindFirstChild("CourtyardFloor") :: BasePart
	courtyardFloor.Material = Enum.Material.Grass
	courtyardFloor.Color = Color3.fromRGB(90, 108, 87)
	resize(map, "BoundaryWest", Vector3.new(2, 10, 300), Vector3.new(-240, 5, 0))
	resize(map, "BoundaryNorth", Vector3.new(300, 10, 2), Vector3.new(-90, 5, -150))
	resize(map, "BoundarySouth", Vector3.new(300, 10, 2), Vector3.new(-90, 5, 150))
	resize(map, "BoundaryEastNorth", Vector3.new(2, 10, 142), Vector3.new(60, 5, -79))
	resize(map, "BoundaryEastSouth", Vector3.new(2, 10, 142), Vector3.new(60, 5, 79))
	local divider = map:FindFirstChild("SightlineDivider")
	if divider and divider:IsA("BasePart") then
		divider.Position = Vector3.new(-86, 6, 34)
	end
	setCampusLighting()

	for _, name in ipairs({"A3", "A3Environment", "A3LabBlocker"}) do
		translate(map:WaitForChild(name), layout.a3)
	end
	for _, name in ipairs({"Library", "LibraryCover"}) do
		translate(map:WaitForChild(name), layout.library)
	end
	for _, name in ipairs({"B4", "B4GeneratorBlocker"}) do
		translate(map:WaitForChild(name), layout.b4)
	end
	for _, name in ipairs({ "A3LabBlocker", "B4GeneratorBlocker" }) do
		local placeholder = map:FindFirstChild(name)
		if placeholder and placeholder:IsA("BasePart") then
			placeholder.Transparency = 1
			placeholder.CanCollide = false
			placeholder.CanTouch = false
			placeholder.CanQuery = false
		end
	end
	local environment = map:WaitForChild("CampusEnvironment")
	translate(environment:WaitForChild("Library"), layout.library)
	translate(environment:WaitForChild("B4"), layout.b4)
	local crate = map:WaitForChild("A3"):WaitForChild("FuseCrate") :: BasePart
	crate:SetAttribute("FNABKResetPosition", crate.Position)
	map:SetAttribute("CrateResetBoundsMin", Vector3.new(-238, -10, -148))
	map:SetAttribute("CrateResetBoundsMax", Vector3.new(58, 30, 148))

	local paths = Instance.new("Folder")
	paths.Name = "CampusPaths"
	paths.Parent = map
	campusBackdrop.Build(paths)
	if divider and divider:IsA("BasePart") then
		dividerMonument(paths, divider)
	end
	local greenery = Instance.new("Folder")
	greenery.Name = "CampusGreenways"
	greenery.Parent = paths
	for _, lawnSpec in ipairs({
		{ "NorthTreeLawn", Vector3.new(-90, 0.02, -139), Vector3.new(278, 0.04, 18) },
		{ "SouthTreeLawn", Vector3.new(-90, 0.02, 139), Vector3.new(278, 0.04, 18) },
		{ "WestGardenLawn", Vector3.new(-219, 0.02, 0), Vector3.new(40, 0.04, 190) },
	}) do
		local lawn = detail(greenery, lawnSpec[1] :: string, lawnSpec[3] :: Vector3, lawnSpec[2] :: Vector3, Color3.fromRGB(70, 94, 74), Enum.Material.Grass)
		lawn.CanTouch = false
	end
	mark(paths, "MainWalk", Vector3.new(-90, 0.035, -6), Vector3.new(300, 0.07, 12))
	mark(paths, "MainWalkEdgeNorth", Vector3.new(-90, 0.047, -12.65), Vector3.new(300, 0.024, 0.18), Color3.fromRGB(198, 149, 75))
	mark(paths, "MainWalkEdgeSouth", Vector3.new(-90, 0.047, 0.65), Vector3.new(300, 0.024, 0.18), Color3.fromRGB(29, 144, 127))
	mark(paths, "A3Walk", Vector3.new(-130, 0.035, -29), Vector3.new(10, 0.07, 46))
	mark(paths, "LibraryWalk", Vector3.new(23, 0.035, 45), Vector3.new(10, 0.07, 140))
	mark(paths, "B4Walk", Vector3.new(18, 0.035, -54), Vector3.new(10, 0.07, 96))
	mark(paths, "GateWalk", Vector3.new(43, 0.035, 4), Vector3.new(34, 0.07, 10))
	mark(paths, "GatePlaza", Vector3.new(37, 0.025, 15), Vector3.new(38, 0.05, 25))
	mark(paths, "GatePlazaBorderNorth", Vector3.new(37, 0.048, 2.25), Vector3.new(38, 0.026, 0.22), Color3.fromRGB(67, 131, 154))
	mark(paths, "GatePlazaBorderSouth", Vector3.new(37, 0.048, 27.75), Vector3.new(38, 0.026, 0.22), Color3.fromRGB(198, 149, 75))
	local courtyardPavers = detail(paths, "CourtyardPaverField", Vector3.new(150, 0.04, 56), Vector3.new(-12, 0.02, 34), Color3.fromRGB(111, 121, 121), Enum.Material.Concrete)
	courtyardPavers.CanTouch = false
	for x = -84, 60, 8 do
		mark(paths, "CourtyardTileJoint", Vector3.new(x, 0.051, 34), Vector3.new(0.045, 0.018, 56), Color3.fromRGB(66, 78, 81))
	end
	for z = 10, 58, 8 do
		mark(paths, "CourtyardTileJoint", Vector3.new(-12, 0.051, z), Vector3.new(150, 0.018, 0.045), Color3.fromRGB(66, 78, 81))
	end
	for x = 25, 55, 6 do
		mark(paths, "GatePlazaTileJoint", Vector3.new(x, 0.052, 15), Vector3.new(0.045, 0.02, 25), Color3.fromRGB(58, 73, 80))
	end
	for z = 3, 27, 6 do
		mark(paths, "GatePlazaTileJoint", Vector3.new(37, 0.052, z), Vector3.new(38, 0.02, 0.045), Color3.fromRGB(58, 73, 80))
	end
	for x = -228, 48, 12 do
		mark(paths, "MainWalkTileJoint", Vector3.new(x, 0.078, -6), Vector3.new(0.045, 0.018, 12), Color3.fromRGB(67, 79, 82))
	end
	for z = -49, -9, 8 do
		mark(paths, "A3WalkTileJoint", Vector3.new(-130, 0.078, z), Vector3.new(10, 0.018, 0.045), Color3.fromRGB(67, 79, 82))
	end
	for z = -22, 110, 10 do
		mark(paths, "LibraryWalkTileJoint", Vector3.new(23, 0.078, z), Vector3.new(10, 0.018, 0.045), Color3.fromRGB(67, 79, 82))
	end
	for z = -98, -10, 10 do
		mark(paths, "B4WalkTileJoint", Vector3.new(18, 0.078, z), Vector3.new(10, 0.018, 0.045), Color3.fromRGB(67, 79, 82))
	end
	wayfindingBoard(paths, Vector3.new(-4, 0, -19))
	for _, x in ipairs({ -130, 20, 43 }) do
		for stripe = -2, 2 do
			mark(paths, "CrosswalkStripe", Vector3.new(x + stripe * 1.3, 0.08, -6), Vector3.new(0.48, 0.02, 8))
		end
	end
	local gardens = {
		{ "NorthTreeWell01", Vector3.new(-195, 0, -138), Color3.fromRGB(29, 144, 127) },
		{ "NorthTreeWell02", Vector3.new(-115, 0, -138), Color3.fromRGB(198, 149, 75) },
		{ "NorthTreeWell03", Vector3.new(-35, 0, -138), Color3.fromRGB(67, 131, 154) },
		{ "NorthTreeWell04", Vector3.new(35, 0, -138), Color3.fromRGB(198, 149, 75) },
		{ "SouthTreeWell01", Vector3.new(-195, 0, 138), Color3.fromRGB(67, 131, 154) },
		{ "SouthTreeWell02", Vector3.new(-115, 0, 138), Color3.fromRGB(29, 144, 127) },
		{ "SouthTreeWell03", Vector3.new(-35, 0, 138), Color3.fromRGB(198, 149, 75) },
		{ "SouthTreeWell04", Vector3.new(35, 0, 138), Color3.fromRGB(29, 144, 127) },
		{ "WestTreeWell01", Vector3.new(-218, 0, -60), Color3.fromRGB(198, 149, 75) },
		{ "WestTreeWell02", Vector3.new(-218, 0, 60), Color3.fromRGB(67, 131, 154) },
	}
	for _, bed in ipairs(gardens) do
		treeWell(greenery, bed[1] :: string, bed[2] :: Vector3, bed[3] :: Color3)
	end
	local buildings = Instance.new("Folder")
	buildings.Name = "CampusBuildings"
	buildings.Parent = paths
	perimeterDetails(buildings)
	campusGatePortal.Build(buildings)
	local campusComplex = marketplaceCampusComplex.Build(buildings, "WestAcademicComplex", Vector3.new(-185, 0, 90), 0, 0.22)
	if not campusComplex then
		campusBuilding(buildings, "NorthAcademicWing", Vector3.new(0, 0, -50), 88, 20, 14, 1, 5, "ENGINEERING WING  /  B4", true, Color3.fromRGB(29, 144, 127))
	end
	local southAcademicWing = marketplaceSchool.Build(buildings, "SouthAcademicWing", Vector3.new(-75, 0, 70), math.rad(90), 30)
	if not southAcademicWing then
		campusBuilding(buildings, "SouthAcademicWing", Vector3.new(0, 0, 50), 88, 20, 14, -1, 5, "STUDENT SERVICES  /  LIBRARY", true, Color3.fromRGB(67, 131, 154))
	end
	local northAcademicWing = marketplaceSchool.Build(buildings, "NorthAcademicHall", Vector3.new(-185, 0, -85), math.rad(90), 30)
	if not northAcademicWing then
		campusBuilding(buildings, "NorthAcademicHall", Vector3.new(-185, 0, -85), 44, 22, 18, 1, 0, "NORTH ACADEMIC HALL", false, Color3.fromRGB(67, 131, 154))
	end
	-- Give the radius-2 Mimic agent enough navmesh clearance through the lab entry.
	campusBuilding(buildings, "A3EngineeringLab", Vector3.new(-126, 0, -50), 48, 30, 16, 1, 0, "A3  /  ENGINEERING LAB", false, Color3.fromRGB(29, 144, 127), 16)
	campusBuilding(buildings, "CampusLibrary", Vector3.new(5, 0, 115), 56, 30, 16, -1, 18, "LIBRARY  /  STUDENT ARCHIVE", false, Color3.fromRGB(198, 149, 75))
	campusBuilding(buildings, "B4GeneratorRoom", Vector3.new(3, 0, -102), 56, 30, 16, 1, 15, "B4  /  GENERATOR ROOM", false, Color3.fromRGB(116, 105, 145))
	-- The optional residential-looking annex was removed so the playable area
	-- reads as one coherent academic campus rather than a mixed housing block.
	map:SetAttribute("CampusAnnexIncluded", false)
	mark(paths, "NorthAcademicWalk", Vector3.new(-185, 0.035, -27), Vector3.new(12, 0.07, 42))
	local northWingApron = detail(paths, "NorthAcademicApron", Vector3.new(28, 0.04, 12), Vector3.new(-185, 0.02, -49), Color3.fromRGB(108, 119, 119), Enum.Material.Concrete)
	northWingApron.CanTouch = false
	for _, side in ipairs({ -1, 1 }) do
		structure(buildings, "B4GeneratorAccessWall", Vector3.new(4, 9, 3), Vector3.new(3 + side * 7, 4.5, -93), Color3.fromRGB(104, 119, 128), Enum.Material.Concrete)
	end
	campusIdentityDetails(buildings)
	campusRoleRoofDetails(buildings)
	marketplaceBench.Build(paths, Vector3.new(-95, 2.6, 18))
	marketplaceBench.Build(paths, Vector3.new(17, 2.6, 68))
	marketplaceBench.Build(paths, Vector3.new(17, 2.6, -70))
	for _, position in ipairs({ Vector3.new(-200, 0, -6), Vector3.new(-150, 0, -6), Vector3.new(-100, 0, -6), Vector3.new(-50, 0, -6), Vector3.new(0, 0, -6), Vector3.new(45, 0, -6), Vector3.new(25, 0, 48), Vector3.new(25, 0, -52) }) do
		pathLamp(paths, position.X, position.Z)
	end
	courtyardFountain(paths, Vector3.new(-12, 0.02, 34))
	local trees = {
		{ "NorthTree01", Vector3.new(-195, 0, -138) }, { "NorthTree02", Vector3.new(-115, 0, -138) },
		{ "NorthTree03", Vector3.new(-35, 0, -138) }, { "NorthTree04", Vector3.new(35, 0, -138) },
		{ "SouthTree01", Vector3.new(-195, 0, 138) }, { "SouthTree02", Vector3.new(-115, 0, 138) },
		{ "SouthTree03", Vector3.new(-35, 0, 138) }, { "SouthTree04", Vector3.new(35, 0, 138) },
		{ "WestTree01", Vector3.new(-218, 0, -60) }, { "WestTree02", Vector3.new(-218, 0, 60) },
	}
	-- Compact campus ornamentals, about 2.64–2.78 studs tall. The hidden 3.2-stud
	-- trunk proxy reaches the R15 collision body while leaving foliage passable.
	local treeScale = 0.075
	for index, entry in ipairs(trees) do
		local variant = if index % 2 == 0 then "Tree2" else "Tree4"
		marketplaceTree.Build(paths, entry[1] :: string, entry[2] :: Vector3, math.rad((index * 47) % 360), treeScale, variant)
	end
	map:SetAttribute("CampusTreeCount", #trees)
	map:SetAttribute("CampusTreeVariantCount", 2)
	map:SetAttribute("CampusTreeSourceAssetId", 8556375773)
	map:SetAttribute("CampusTreeScale", treeScale)
	map:SetAttribute("CampusTreeMinHeight", 35.184753 * treeScale)
	map:SetAttribute("CampusTreeMaxHeight", 37 * treeScale)
	map:SetAttribute("CampusTreeCollisionProxyCount", #trees)
	map:SetAttribute("CampusMarketplaceSchool", campusComplex ~= nil or southAcademicWing ~= nil or northAcademicWing ~= nil)
	map:SetAttribute("CampusMarketplaceSchoolCount", (if campusComplex then 1 else 0) + (if southAcademicWing then 1 else 0) + (if northAcademicWing then 1 else 0))
	map:SetAttribute("CampusWestSchoolAssetId", if campusComplex then 10403432220 else 0)
	map:SetAttribute("CampusWestSchoolScale", if campusComplex then 0.22 else 0)
	map:SetAttribute("CampusSouthSchoolAssetId", if southAcademicWing then 7932859944 else 0)
	map:SetAttribute("CampusSouthSchoolScale", if southAcademicWing then 30 else 0)
	map:SetAttribute("CampusNorthSchoolAssetId", if northAcademicWing then 7932859944 else 0)
	map:SetAttribute("CampusNorthSchoolScale", if northAcademicWing then 30 else 0)
	map:SetAttribute("CampusSchoolSourceAssetId", if campusComplex then 10403432220 elseif southAcademicWing or northAcademicWing then 7932859944 else 0)
	map:SetAttribute("CampusSchoolSourceScale", if campusComplex then 0.22 elseif southAcademicWing or northAcademicWing then 30 else 0)
	map:SetAttribute("CampusExpanded", true)
end

return table.freeze(CampusExpansion)
