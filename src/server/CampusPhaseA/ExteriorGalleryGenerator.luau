--!strict
-- Builds real, walkable exterior school galleries and the classroom doors behind them.
local ExteriorGalleryGenerator = {}

type DoorOpening = {
	center: number,
	width: number,
	doorHeight: number,
}

type GalleryOpening = {
	kind: "door" | "window",
	center: number,
	width: number,
	doorHeight: number,
}

type DoorMap = { [number]: { [number]: { DoorOpening } } }

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	collidable: boolean,
	role: string
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.CanCollide = collidable
	item.CanTouch = false
	item.CanQuery = collidable
	item.CastShadow = collidable
	item.Material = material
	item.Color = color
	item.Size = size
	item.CFrame = cframe
	item:SetAttribute("ArchitectureRole", role)
	item.Parent = parent
	return item
end

local function makeGalleryWall(
	parent: Instance,
	frame: CFrame,
	name: string,
	side: number,
	layoutWidth: number,
	layoutLength: number,
	floorIndex: number,
	floorHeight: number,
	style: { [string]: any },
	buildingStyle: { [string]: any },
	doors: { DoorOpening }
)
	local thickness = style.outerWallThicknessStuds
	local baseY = floorIndex * floorHeight + style.floorSlabThicknessStuds
	local wallHeight = floorHeight - style.floorSlabThicknessStuds
	local doorPlaneX = side * (layoutWidth * 0.5 - thickness * 0.5)
	local zMin = -layoutLength * 0.5 + thickness + 0.35
	local zMax = layoutLength * 0.5 - thickness - 0.35
	local sortedDoors = table.clone(doors)
	table.sort(sortedDoors, function(a, b)
		return a.center < b.center
	end)
	local openings: { GalleryOpening } = {}
	local doorGapWidth = math.clamp(style.exteriorDoorWidthStuds * 0.82, 7.2, math.min(layoutLength * 0.24, 8.8))
	local classroomWindowWidth = math.clamp(layoutLength * 0.065, 6.2, 9.4)
	for index, door in ipairs(sortedDoors) do
		local doorCenter = math.clamp(door.center, zMin + doorGapWidth * 0.5, zMax - doorGapWidth * 0.5)
		table.insert(openings, { kind = "door", center = doorCenter, width = doorGapWidth, doorHeight = door.doorHeight })
		local leftClearance = doorCenter - (sortedDoors[index - 1] and sortedDoors[index - 1].center or zMin)
		local rightClearance = (sortedDoors[index + 1] and sortedDoors[index + 1].center or zMax) - doorCenter
		local direction = if rightClearance >= leftClearance then 1 else -1
		local windowOffset = doorGapWidth * 0.5 + classroomWindowWidth * 0.5 + 1.2
		local windowCenter = doorCenter + direction * windowOffset
		local fits = windowCenter - classroomWindowWidth * 0.5 >= zMin and windowCenter + classroomWindowWidth * 0.5 <= zMax
		if fits then
			for _, otherDoor in ipairs(sortedDoors) do
				if math.abs(windowCenter - otherDoor.center) < (classroomWindowWidth + doorGapWidth) * 0.5 + 0.8 then
					fits = false
					break
				end
			end
		end
		if fits then
			table.insert(openings, { kind = "window", center = windowCenter, width = classroomWindowWidth, doorHeight = 0 })
		end
	end
	table.sort(openings, function(a, b)
		return a.center < b.center
	end)
	local cursor = zMin
	local wallColor = buildingStyle.wallColor3
	local wallName = string.format("GalleryClassroomWall_F%02d_Side_%s", floorIndex + 1, if side < 0 then "West" else "East")
	local doorHeightLimit = math.min(style.exteriorDoorHeightStuds, wallHeight - 1.4)
	for index, opening in ipairs(openings) do
		local gapStart = math.max(cursor, opening.center - opening.width * 0.5)
		local gapEnd = math.min(zMax, opening.center + opening.width * 0.5)
		if gapStart - cursor > 0.9 then
			makePart(
				parent,
				string.format("%s_Wall_%02d", wallName, index),
				Vector3.new(thickness, wallHeight, gapStart - cursor),
				frame * CFrame.new(doorPlaneX, baseY + wallHeight * 0.5, (cursor + gapStart) * 0.5),
				wallColor,
				Enum.Material.Concrete,
				true,
				"ExteriorClassroomWall"
			)
		end
		if gapEnd > gapStart then
			local openingCenter = (gapStart + gapEnd) * 0.5
			local openingWidth = gapEnd - gapStart
			if opening.kind == "door" then
				local openingHeight = math.min(doorHeightLimit, opening.doorHeight)
				local headerHeight = wallHeight - openingHeight
				if headerHeight > 0.2 then
					makePart(parent, string.format("%s_DoorHeader_%02d", wallName, index), Vector3.new(thickness, headerHeight, openingWidth), frame * CFrame.new(doorPlaneX, baseY + openingHeight + headerHeight * 0.5, openingCenter), wallColor, Enum.Material.Concrete, true, "ExteriorClassroomDoorHeader")
				end
				local leafWidth = openingWidth * 0.78
				local leafHeight = math.max(4, openingHeight - 0.45)
				local jambWidth = 0.24
				for _, edge in ipairs({ -1, 1 }) do
					makePart(parent, string.format("GalleryClassroomDoorJamb_F%02d_%s_%02d_%d", floorIndex + 1, if side < 0 then "West" else "East", index, edge), Vector3.new(thickness + 0.16, openingHeight, jambWidth), frame * CFrame.new(doorPlaneX + side * 0.11, baseY + openingHeight * 0.5, openingCenter + edge * (openingWidth * 0.5 - jambWidth * 0.5)), buildingStyle.trimColor3, Enum.Material.SmoothPlastic, false, "ClassroomDoorFrame")
				end
			local leaf = makePart(parent, string.format("GalleryClassroomDoor_F%02d_Side_%s_%02d", floorIndex + 1, if side < 0 then "West" else "East", index), Vector3.new(0.16, leafHeight, leafWidth), frame * CFrame.new(doorPlaneX + side * 0.13, baseY + leafHeight * 0.5, openingCenter - openingWidth * 0.08), buildingStyle.accentColor3, Enum.Material.Wood, false, "PassableGalleryClassroomDoor")
			leaf.Transparency = 0.04
			else
				local windowHeight = math.min(5.2, wallHeight * 0.45)
				local windowBottom = baseY + 2.6
				local windowTop = math.min(baseY + wallHeight - 0.65, windowBottom + windowHeight)
				windowHeight = windowTop - windowBottom
				local sillHeight = windowBottom - baseY
				local headerHeight = baseY + wallHeight - windowTop
				if sillHeight > 0.2 then
					makePart(parent, string.format("%s_ClassroomWindowSillWall_%02d", wallName, index), Vector3.new(thickness, sillHeight, openingWidth), frame * CFrame.new(doorPlaneX, baseY + sillHeight * 0.5, openingCenter), wallColor, Enum.Material.Concrete, true, "ExteriorClassroomWindowSill")
				end
				if headerHeight > 0.2 then
					makePart(parent, string.format("%s_ClassroomWindowHeader_%02d", wallName, index), Vector3.new(thickness, headerHeight, openingWidth), frame * CFrame.new(doorPlaneX, windowTop + headerHeight * 0.5, openingCenter), wallColor, Enum.Material.Concrete, true, "ExteriorClassroomWindowHeader")
				end
				local pane = makePart(parent, string.format("GalleryClassroomWindow_F%02d_Side_%s_%02d", floorIndex + 1, if side < 0 then "West" else "East", index), Vector3.new(0.18, math.max(1, windowHeight - 0.34), openingWidth * 0.84), frame * CFrame.new(doorPlaneX + side * 0.14, (windowTop + windowBottom) * 0.5, openingCenter), buildingStyle.windowColor3, Enum.Material.Glass, false, "ClassroomWindowFromExteriorGallery")
				pane.Transparency = 0.16
				makePart(parent, string.format("GalleryClassroomWindowSill_F%02d_%s_%02d", floorIndex + 1, if side < 0 then "West" else "East", index), Vector3.new(thickness + 0.36, 0.26, openingWidth + 0.3), frame * CFrame.new(doorPlaneX + side * 0.12, windowBottom, openingCenter), buildingStyle.accentColor3, Enum.Material.SmoothPlastic, false, "ClassroomWindowSill")
			end
		end
		cursor = math.max(cursor, gapEnd)
	end
	if zMax - cursor > 0.9 then
		makePart(
			parent,
			wallName .. "_Wall_End",
			Vector3.new(thickness, wallHeight, zMax - cursor),
			frame * CFrame.new(doorPlaneX, baseY + wallHeight * 0.5, (cursor + zMax) * 0.5),
			wallColor,
			Enum.Material.Concrete,
			true,
			"ExteriorClassroomWall"
		)
	end
end

local function addEdgeRail(
	parent: Instance,
	frame: CFrame,
	name: string,
	x: number,
	zCenter: number,
	length: number,
	floorIndex: number,
	floorHeight: number,
	slabThickness: number,
	style: { [string]: any },
	buildingStyle: { [string]: any }
)
	local floorTop = floorIndex * floorHeight + slabThickness
	local railColor = buildingStyle.galleryRailColor3
	if buildingStyle.galleryRailStyle == "concrete_parapet" or buildingStyle.galleryRailStyle == "painted_wall" then
		local parapetHeight = if buildingStyle.galleryRailStyle == "painted_wall" then 2.8 else 2.25
		makePart(parent, name .. "_Parapet", Vector3.new(0.48, parapetHeight, length), frame * CFrame.new(x, floorTop + parapetHeight * 0.5, zCenter), railColor, Enum.Material.Concrete, true, "GalleryGuardrail")
		makePart(parent, name .. "_Coping", Vector3.new(0.66, 0.22, length), frame * CFrame.new(x, floorTop + parapetHeight + 0.11, zCenter), buildingStyle.trimColor3, Enum.Material.Concrete, true, "GalleryRailCoping")
		return
	end

	local railHeight = if buildingStyle.galleryRailStyle == "timber_balustrade" then 3.05 else 3.35
	local parapetHeight = 1.8
	local parapetColor = buildingStyle.wallColor3:Lerp(buildingStyle.accentColor3, 0.16)
	makePart(parent, name .. "_LowParapet", Vector3.new(0.48, parapetHeight, length), frame * CFrame.new(x, floorTop + parapetHeight * 0.5, zCenter), parapetColor, Enum.Material.Concrete, true, "GalleryGuardrail")
	makePart(parent, name .. "_TopRail", Vector3.new(0.28, 0.28, length), frame * CFrame.new(x, floorTop + railHeight, zCenter), railColor, Enum.Material.Metal, true, "GalleryTopRail")
	local spacing = if buildingStyle.galleryRailStyle == "timber_balustrade" then 4.3 else 7.2
	local postCount = math.max(1, math.ceil(length / spacing))
	local balusterHeight = railHeight - parapetHeight - 0.18
	for index = 0, postCount do
		local z = zCenter - length * 0.5 + length * index / postCount
		makePart(parent, string.format("%s_Baluster_%02d", name, index + 1), Vector3.new(0.22, balusterHeight, 0.22), frame * CFrame.new(x, floorTop + parapetHeight + balusterHeight * 0.5, z), railColor, Enum.Material.Metal, true, "GalleryBaluster")
	end
end

local function addGalleryCanopy(
	parent: Instance,
	frame: CFrame,
	name: string,
	centerX: number,
	zCenter: number,
	galleryWidth: number,
	length: number,
	floorIndex: number,
	floorHeight: number,
	buildingStyle: { [string]: any }
)
	local roofStyle = buildingStyle.galleryRoofStyle
	if roofStyle == "open_sky" then
		return
	end
	local roofY = floorIndex * floorHeight + floorHeight - 0.72
	local roofColor = buildingStyle.galleryRoofColor3
	if roofStyle == "pergola" or roofStyle == "striped_awning" then
		local railColor = if roofStyle == "striped_awning" then buildingStyle.accentColor3 else roofColor
		local beamDepth = if roofStyle == "striped_awning" then 0.75 else 0.46
		local beamCount = math.max(2, math.ceil(length / 9))
		for index = 0, beamCount do
			local z = zCenter - length * 0.5 + length * index / beamCount
			makePart(parent, string.format("%s_CrossBeam_%02d", name, index + 1), Vector3.new(galleryWidth + 0.7, 0.28, beamDepth), frame * CFrame.new(centerX, roofY, z), railColor, Enum.Material.Metal, false, "GalleryPergolaBeam")
		end
		for side = -1, 1, 2 do
			makePart(parent, name .. "_LongBeam_" .. side, Vector3.new(0.32, 0.32, length), frame * CFrame.new(centerX + side * (galleryWidth * 0.5 - 0.18), roofY, zCenter), roofColor, Enum.Material.Metal, false, "GalleryPergolaBeam")
		end
		return
	end
	local depth = if roofStyle == "deep_eaves" then galleryWidth + 1.8 else galleryWidth + 0.8
	makePart(parent, name .. "_Canopy", Vector3.new(depth, 0.38, length + 0.5), frame * CFrame.new(centerX, roofY, zCenter), roofColor, Enum.Material.Concrete, false, "GalleryCanopy")
	if roofStyle == "deep_eaves" then
		makePart(parent, name .. "_Fascia", Vector3.new(0.35, 0.72, length + 0.7), frame * CFrame.new(centerX + math.sign(centerX) * (depth * 0.5 - 0.16), roofY - 0.08, zCenter), buildingStyle.accentColor3, Enum.Material.SmoothPlastic, false, "GalleryFascia")
	end
end

local function addSupports(
	parent: Instance,
	frame: CFrame,
	name: string,
	outerX: number,
	zCenter: number,
	length: number,
	floorIndex: number,
	floorHeight: number,
	slabThickness: number,
	buildingStyle: { [string]: any }
)
	local supportStyle = buildingStyle.gallerySupportStyle
	if supportStyle == "cantilever" or supportStyle == "bracketed" then
		local spacing = 22
		local count = math.max(1, math.floor(length / spacing))
		for index = 0, count do
			local z = zCenter - length * 0.5 + length * index / count
			local brace = makePart(parent, string.format("%s_Bracket_%02d", name, index + 1), Vector3.new(0.38, 2.6, 0.52), frame * CFrame.new(outerX - math.sign(outerX) * 1.1, floorIndex * floorHeight + slabThickness + 1.1, z) * CFrame.Angles(0, 0, math.rad(if outerX > 0 then 32 else -32)), buildingStyle.accentColor3, Enum.Material.Metal, false, "GalleryCantileverSupport")
			brace.CastShadow = false
		end
		return
	elseif supportStyle == "none" then
		return
	end

	local columnHeight = math.max(6, floorHeight - 2.2)
	local spacing = if supportStyle == "heavy_piers" then 15 else 21
	local count = math.max(1, math.floor(length / spacing))
	local width = if supportStyle == "heavy_piers" then 1.25 else if supportStyle == "slender_columns" then 0.68 else 0.92
	for index = 0, count do
		local z = zCenter - length * 0.5 + length * index / count
		local column = makePart(parent, string.format("%s_Column_%02d", name, index + 1), Vector3.new(width, columnHeight, width), frame * CFrame.new(outerX, floorIndex * floorHeight + slabThickness + columnHeight * 0.5, z), buildingStyle.galleryColumnColor3, Enum.Material.Concrete, true, "GallerySupportColumn")
		column:SetAttribute("ColumnStyle", supportStyle)
	end
end

local function addGalleryLights(
	parent: Instance,
	frame: CFrame,
	name: string,
	centerX: number,
	zCenter: number,
	length: number,
	floorIndex: number,
	floorHeight: number,
	buildingStyle: { [string]: any }
): number
	local count = math.clamp(math.ceil(length / 120), 1, 3)
	for index = 1, count do
		local z = zCenter - length * 0.5 + length * (index - 0.5) / count
		local fixture = makePart(parent, string.format("%s_Light_%02d", name, index), Vector3.new(1.3, 0.16, 2.4), frame * CFrame.new(centerX, floorIndex * floorHeight + floorHeight - 1.1, z), buildingStyle.galleryLightColor3, Enum.Material.Neon, false, "GalleryLightFixture")
		local light = Instance.new("PointLight")
		light.Name = "WarmGalleryLight"
		light.Color = buildingStyle.galleryLightColor3
		light.Brightness = 0.48
		light.Range = 20
		light.Shadows = false
		light.Parent = fixture
	end
	return count
end

function ExteriorGalleryGenerator.Build(
	parent: Instance,
	frame: CFrame,
	layoutWidth: number,
	layoutLength: number,
	floorHeight: number,
	floorCount: number,
	style: { [string]: any },
	buildingStyle: { [string]: any },
	doorsBySide: DoorMap
): { [string]: any }
	local folder = Instance.new("Folder")
	folder.Name = "ExteriorGalleries"
	folder.Parent = parent
	local circulation = buildingStyle.galleryLayout or "single"
	local gallerySides = if circulation == "double" or circulation == "wrap" then { -1, 1 } else { 1 }
	-- A school gallery should read and work as a corridor at avatar scale, not as
	-- a narrow balcony. Keep a clear ~2 m minimum while preserving profile widths.
	local galleryWidth = math.clamp(math.max(buildingStyle.galleryWidthStuds or 7.2, 7.2), 7.2, 10)
	local slabThickness = style.floorSlabThicknessStuds
	local wallThickness = style.outerWallThicknessStuds
	local zMin = -layoutLength * 0.5 + wallThickness + 0.35
	local zMax = layoutLength * 0.5 - wallThickness - 0.35
	local galleryLength = zMax - zMin
	local galleryCenterZ = (zMin + zMax) * 0.5
	local doorCount = 0
	local deckCount = 0
	local lightCount = 0

	for _, side in ipairs(gallerySides) do
		for floorIndex = 0, floorCount - 1 do
			local doors = doorsBySide[side] and doorsBySide[side][floorIndex + 1] or {}
			doorCount += #doors
			makeGalleryWall(folder, frame, string.format("GalleryWall_%s", if side < 0 then "West" else "East"), side, layoutWidth, layoutLength, floorIndex, floorHeight, style, buildingStyle, doors)

			local centerX = side * (layoutWidth * 0.5 + galleryWidth * 0.5 - 0.38)
			local floorCenterY = floorIndex * floorHeight + slabThickness * 0.5
			local deck = makePart(folder, string.format("GalleryDeck_%s_Floor_%02d", if side < 0 then "West" else "East", floorIndex + 1), Vector3.new(galleryWidth + 0.76, slabThickness, galleryLength), frame * CFrame.new(centerX, floorCenterY, galleryCenterZ), buildingStyle.galleryFloorColor3, Enum.Material.Concrete, true, "WalkableExteriorGalleryDeck")
			deck:SetAttribute("GalleryWidthStuds", galleryWidth)
			deckCount += 1

			local outerX = side * (layoutWidth * 0.5 + galleryWidth - 0.38)
			local railName = string.format("GalleryRail_%s_Floor_%02d", if side < 0 then "West" else "East", floorIndex + 1)
			addEdgeRail(folder, frame, railName, outerX, galleryCenterZ, galleryLength, floorIndex, floorHeight, slabThickness, style, buildingStyle)
			local endHeight = 3.0
			for _, endSign in ipairs({ -1, 1 }) do
				if not (circulation == "wrap" and endSign > 0) then
					local endZ = if endSign < 0 then zMin else zMax
					makePart(folder, string.format("%s_EndPost_%d", railName, endSign), Vector3.new(0.34, endHeight, 0.34), frame * CFrame.new(outerX, floorIndex * floorHeight + slabThickness + endHeight * 0.5, endZ), buildingStyle.galleryRailColor3, Enum.Material.Metal, true, "GalleryEndGuard")
					makePart(folder, string.format("%s_EndRail_%d", railName, endSign), Vector3.new(galleryWidth, 0.26, 0.26), frame * CFrame.new(outerX - side * galleryWidth * 0.5, floorIndex * floorHeight + slabThickness + endHeight, endZ), buildingStyle.galleryRailColor3, Enum.Material.Metal, true, "GalleryEndGuard")
				end
			end
			addGalleryCanopy(folder, frame, string.format("GalleryCanopy_%s_Floor_%02d", if side < 0 then "West" else "East", floorIndex + 1), centerX, galleryCenterZ, galleryWidth, galleryLength, floorIndex, floorHeight, buildingStyle)
			addSupports(folder, frame, string.format("GallerySupport_%s_Floor_%02d", if side < 0 then "West" else "East", floorIndex + 1), outerX, galleryCenterZ, galleryLength, floorIndex, floorHeight, slabThickness, buildingStyle)
			lightCount += addGalleryLights(folder, frame, string.format("Gallery_%s_Floor_%02d", if side < 0 then "West" else "East", floorIndex + 1), centerX, galleryCenterZ, galleryLength, floorIndex, floorHeight, buildingStyle)
		end
	end

	local connectorCount = 0
	if circulation == "wrap" then
		local connectorZ = layoutLength * 0.5 + galleryWidth * 0.5 - 0.38
		local connectorWidth = layoutWidth + galleryWidth * 2 - 0.76
		local outsideZ = connectorZ + galleryWidth * 0.5 - 0.32
		for floorIndex = 0, floorCount - 1 do
			makePart(folder, string.format("GalleryCornerLanding_Floor_%02d", floorIndex + 1), Vector3.new(connectorWidth, slabThickness, galleryWidth + 0.76), frame * CFrame.new(0, floorIndex * floorHeight + slabThickness * 0.5, connectorZ), buildingStyle.galleryFloorColor3, Enum.Material.Concrete, true, "WalkableGalleryCornerLanding")
			makePart(folder, string.format("GalleryCornerRail_Floor_%02d", floorIndex + 1), Vector3.new(connectorWidth, 2.45, 0.38), frame * CFrame.new(0, floorIndex * floorHeight + slabThickness + 1.225, outsideZ), buildingStyle.galleryRailColor3, Enum.Material.Concrete, true, "GalleryGuardrail")
			addGalleryCanopy(folder, frame, string.format("GalleryCornerCanopy_Floor_%02d", floorIndex + 1), 0, connectorZ, connectorWidth, galleryWidth, floorIndex, floorHeight, buildingStyle)
			connectorCount += 1
		end
	end

	return {
		GalleryCount = #gallerySides,
		GalleryDeckCount = deckCount + connectorCount,
		GalleryDoorCount = doorCount,
		GalleryLightCount = lightCount,
		GalleryWidthStuds = galleryWidth,
		GalleryLayout = circulation,
		GallerySides = gallerySides,
	}
end

return table.freeze(ExteriorGalleryGenerator)
