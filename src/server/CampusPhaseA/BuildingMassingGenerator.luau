--!strict
-- Adds profile-specific rooflines, portals, screens and projecting volumes to break up the repeated bar silhouette.
local BuildingMassingGenerator = {}

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	transparency: number?
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.Material = material
	item.Color = color
	item.Transparency = transparency or 0
	item.Size = size
	item.CFrame = cframe
	item.CastShadow = true
	item:SetAttribute("ArchitectureRole", "NonCollidingMassingDetail")
	item.Parent = parent
	return item
end

local function addEntrancePortal(parent: Instance, frame: CFrame, width: number, depth: number, floorHeight: number, style: { [string]: any }, kind: string): number
	local fraction = if kind == "monumental" then 0.72 else if kind == "twin" then 0.3 else if kind == "arcade" then 0.82 else 0.56
	local portalWidth = math.clamp(width * fraction, 14, width - 3)
	local projection = if kind == "monumental" then 11 else if kind == "arcade" then 8 else if kind == "twin" then 6.5 else 5.5
	local postWidth = if kind == "arcade" then 2.4 else if kind == "monumental" then 1.8 else 1.15
	local clearHeight = floorHeight * (if kind == "monumental" then 1.18 else 0.92)
	local frontZ = -depth * 0.5 - projection * 0.5 + 0.3
	local count = 0

	if kind == "twin" then
		for _, centerX in ipairs({ -width * 0.23, width * 0.23 }) do
			for _, side in ipairs({ -1, 1 }) do
				local x = centerX + side * portalWidth * 0.25
				part(parent, "TwinPortal_Pier_" .. tostring(centerX) .. "_" .. tostring(side), Vector3.new(postWidth, clearHeight, projection), frame * CFrame.new(x, clearHeight * 0.5, frontZ), style.accentColor3, Enum.Material.Concrete)
				count += 1
			end
			part(parent, "TwinPortal_Header_" .. tostring(centerX), Vector3.new(portalWidth * 0.52 + postWidth, 1.3, projection), frame * CFrame.new(centerX, clearHeight, frontZ), style.trimColor3, Enum.Material.Concrete)
			count += 1
		end
		return count
	end

	local pierCount = if kind == "arcade" then math.clamp(math.floor(portalWidth / 18), 3, 7) else 2
	for index = 0, pierCount do
		if kind ~= "arcade" and index > 0 then
			break
		end
		local x = -portalWidth * 0.5 + portalWidth * index / pierCount
		local isEdge = index == 0 or index == pierCount
		if isEdge or kind == "arcade" then
			part(parent, string.format("%sPortal_Pier_%02d", kind, index + 1), Vector3.new(postWidth, clearHeight, projection), frame * CFrame.new(x, clearHeight * 0.5, frontZ), style.accentColor3, Enum.Material.Concrete)
			count += 1
		end
	end
	part(parent, kind .. "Portal_DeepLintel", Vector3.new(portalWidth + postWidth, 1.45, projection + 0.6), frame * CFrame.new(0, clearHeight + 0.1, frontZ), style.trimColor3, Enum.Material.Concrete)
	part(parent, kind .. "Portal_AccentFascia", Vector3.new(portalWidth + postWidth, 0.62, 0.7), frame * CFrame.new(0, clearHeight - 0.72, frontZ - projection * 0.5), style.accentColor3, Enum.Material.Metal)
	return count + 2
end

local function addProjectingFloorPlates(parent: Instance, frame: CFrame, width: number, depth: number, floorHeight: number, storyCount: number, style: { [string]: any }, mode: string): number
	local plateCount = 0
	local longAxisRotated = width > depth * 1.15
	local layout = style.galleryLayout or "single"
	local useShortEnd = longAxisRotated and (layout == "double" or layout == "wrap")
	local faceSign = if useShortEnd then (if layout == "wrap" then -1 else 1) else (if longAxisRotated then 1 else -1)
	local selectedFloors: { number }
	if mode == "alternating" then
		selectedFloors = { 2, 4 }
	elseif mode == "stacked" then
		selectedFloors = {}
		for floorIndex = 2, storyCount - 1 do
			table.insert(selectedFloors, floorIndex)
		end
	else
		selectedFloors = { math.max(2, math.floor(storyCount * 0.5)), storyCount - 1 }
	end
	for index, floorNumber in ipairs(selectedFloors) do
		if floorNumber < storyCount then
			local facadeSpan = if useShortEnd then depth else width
			local span = facadeSpan * (if mode == "alternating" and index % 2 == 0 then 0.64 else 0.82)
			local offset = if mode == "alternating" and index % 2 == 0 then facadeSpan * 0.11 else -facadeSpan * 0.06
			-- Make the floor plates read as substantial Vietnamese-style verandas from a
			-- campus-scale view. They stay on the non-gallery face, so they do not narrow
			-- the exterior walking corridor.
			local projection = if mode == "stacked" then 8.2 else 7.2 + (index % 2) * 2.1
			local y = (floorNumber - 1) * floorHeight + 0.45
			local plateSize = if useShortEnd then Vector3.new(projection, 0.95, span) else Vector3.new(span, 0.95, projection)
			local plateX = if useShortEnd then faceSign * (width * 0.5 + projection * 0.5) else offset
			local plateZ = if useShortEnd then offset else faceSign * (depth * 0.5 + projection * 0.5)
			local slab = part(parent, string.format("ProjectingFacadePlate_F%02d", floorNumber), plateSize, frame * CFrame.new(plateX, y, plateZ), style.accentColor3, Enum.Material.Concrete)
			slab:SetAttribute("ArchitectureRole", "NonWalkableFacadeProjection")
			plateCount += 1
		end
	end
	return plateCount
end

local function addFrontScreen(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, style: { [string]: any }, variant: string): number
	local longAxisRotated = width > depth * 1.15
	local layout = style.galleryLayout or "single"
	local useShortEnd = longAxisRotated
	local span = if useShortEnd then depth else width
	local faceSign = if useShortEnd then 1 else -1
	if useShortEnd and layout == "wrap" then
		faceSign = -1
	end
	local finCount = math.clamp(math.floor(span / (if variant == "dense" then 7 else 12)), 4, 17)
	for index = 1, finCount do
		local along = -span * 0.43 + span * 0.86 * (index - 0.5) / finCount
		local height = if variant == "alternating" and index % 2 == 0 then bodyHeight * 0.56 else bodyHeight * 0.92
		local y = if variant == "alternating" and index % 2 == 0 then height * 0.5 + 0.25 * bodyHeight else bodyHeight * 0.5
		local finSize = if useShortEnd then Vector3.new(1.25, height, if variant == "dense" then 1.55 else 0.85) else Vector3.new(if variant == "dense" then 1.55 else 0.85, height, 1.25)
		local x = if useShortEnd then faceSign * (width * 0.5 + 0.95) else along
		local z = if useShortEnd then along else faceSign * (depth * 0.5 + 0.95)
		local fin = part(parent, string.format("DistinctEndScreenFin_%02d", index), finSize, frame * CFrame.new(x, y, z), style.accentColor3, Enum.Material.Concrete)
		fin:SetAttribute("ArchitectureRole", "NonCollidingFacadeSunScreen")
	end
	return finCount
end

local function addSawtoothRoof(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, roofHeight: number, style: { [string]: any }, moduleTarget: number): number
	local count = math.clamp(math.floor(width / moduleTarget), 3, 8)
	local moduleWidth = width / count
	local halfDepth = math.clamp(depth * 0.23, 4, 13)
	local roofY = bodyHeight + roofHeight + 1.4
	local pitch = math.rad(16)
	local added = 0
	for index = 1, count do
		local x = -width * 0.5 + moduleWidth * (index - 0.5)
		for side = -1, 1, 2 do
			local panel = part(parent, string.format("ShedRoofModule_%02d_Slope_%d", index, side), Vector3.new(moduleWidth + 0.3, 0.72, halfDepth), frame * CFrame.new(x, roofY + halfDepth * 0.18, side * halfDepth * 0.5) * CFrame.Angles(side * pitch, 0, 0), style.trimColor3, Enum.Material.Metal)
			panel:SetAttribute("ArchitectureRole", "NonCollidingShedRoofPlane")
			added += 1
		end
		local clerestory = part(parent, string.format("ShedRoofClerestory_%02d", index), Vector3.new(moduleWidth * 0.68, 2.6, 0.28), frame * CFrame.new(x, roofY + halfDepth * 0.18 + 1.45, 0), style.windowColor3, Enum.Material.Glass, 0.12)
		clerestory:SetAttribute("ArchitectureRole", "NonCollidingRoofLantern")
		added += 1
	end
	return added
end

local function addRoofLanterns(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, roofHeight: number, style: { [string]: any }): number
	local added = 0
	local lanternWidth = math.clamp(width * 0.14, 12, 28)
	local lanternDepth = math.clamp(depth * 0.34, 7, 16)
	local roofY = bodyHeight + roofHeight
	for index = 1, 3 do
		local x = (index - 2) * width * 0.26
		part(parent, string.format("ClerestoryLantern_%02d_Curb", index), Vector3.new(lanternWidth, 2.2, lanternDepth), frame * CFrame.new(x, roofY + 1.1, 0), style.wallColor3, Enum.Material.Concrete)
		part(parent, string.format("ClerestoryLantern_%02d_Glass", index), Vector3.new(lanternWidth * 0.76, 2.7, 0.2), frame * CFrame.new(x, roofY + 2.45, -lanternDepth * 0.5), style.windowColor3, Enum.Material.Glass, 0.14)
		part(parent, string.format("ClerestoryLantern_%02d_Cap", index), Vector3.new(lanternWidth + 1.3, 0.48, lanternDepth + 1.4), frame * CFrame.new(x, roofY + 3.9, 0), style.accentColor3, Enum.Material.Metal)
		added += 3
	end
	return added
end

local function addRoofWing(
	parent: Instance,
	frame: CFrame,
	name: string,
	width: number,
	depth: number,
	bodyHeight: number,
	roofHeight: number,
	floorHeight: number,
	style: { [string]: any },
	centerX: number,
	centerZ: number,
	spanX: number,
	spanZ: number,
	heightFraction: number
): number
	local wingWidth = math.max(8, math.min(width * spanX, width - 4))
	local wingDepth = math.max(7, math.min(depth * spanZ, depth - 4))
	local wingHeight = math.max(4.5, floorHeight * heightFraction)
	local roofY = bodyHeight + roofHeight
	local baseY = roofY + wingHeight * 0.5
	local center = frame * CFrame.new(centerX, baseY, centerZ)
	local mass = part(parent, name .. "_UpperVolume", Vector3.new(wingWidth, wingHeight, wingDepth), center, style.wallColor3, Enum.Material.Concrete)
	mass:SetAttribute("ArchitectureRole", "DistinctRooflineVolume")
	part(parent, name .. "_Crown", Vector3.new(wingWidth + 1.4, 0.55, wingDepth + 1.4), center * CFrame.new(0, wingHeight * 0.5 + 0.24, 0), style.accentColor3, Enum.Material.Concrete)
	local glass = part(
		parent,
		name .. "_Clerestory",
		Vector3.new(math.max(4, wingWidth * 0.62), math.max(1.8, wingHeight * 0.26), 0.22),
		center * CFrame.new(0, -wingHeight * 0.06, -wingDepth * 0.5 - 0.14),
		style.windowColor3,
		Enum.Material.Glass,
		0.12
	)
	glass:SetAttribute("ArchitectureRole", "SmallRoofClerestory")
	return 3
end

local function addTerracedRoofPavilions(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, roofHeight: number, floorHeight: number, style: { [string]: any }, arrangement: string): number
	local count = 0
	local positions = if arrangement == "diagonal"
		then { { -0.32, -0.18, 0.18, 0.32, 0.42 }, { 0.0, 0.02, 0.24, 0.28, 0.66 }, { 0.32, 0.21, 0.18, 0.25, 0.88 } }
		else if arrangement == "stepped"
		then { { -0.32, 0.0, 0.18, 0.62, 0.42 }, { 0.0, 0.0, 0.18, 0.62, 0.66 }, { 0.32, 0.0, 0.18, 0.62, 0.9 } }
		else if arrangement == "staggered"
		then { { -0.3, -0.18, 0.2, 0.3, 0.86 }, { 0.0, 0.02, 0.22, 0.28, 0.58 }, { 0.3, 0.21, 0.2, 0.25, 0.38 } }
		else { { -0.34, 0.12, 0.2, 0.42, 0.72 }, { 0.0, -0.08, 0.28, 0.3, 0.48 }, { 0.34, 0.12, 0.2, 0.42, 0.72 } }
	for index, item in ipairs(positions) do
		count += addRoofWing(parent, frame, string.format("TerracedPavilion_%02d", index), width, depth, bodyHeight, roofHeight, floorHeight, style, width * item[1], depth * item[2], item[3], item[4], item[5])
	end
	return count
end

local function addCourtyardRoofWings(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, roofHeight: number, floorHeight: number, style: { [string]: any }): number
	local added = 0
	local wingHeight = math.max(5, floorHeight * 0.62)
	local roofY = bodyHeight + roofHeight
	local sideWidth = math.max(8, width * 0.18)
	local sideDepth = depth * 0.62
	for _, sign in ipairs({ -1, 1 }) do
		local center = frame * CFrame.new(sign * width * 0.37, roofY + wingHeight * 0.5, depth * 0.03)
		local volume = part(parent, "CourtyardRoofSideWing_" .. sign, Vector3.new(sideWidth, wingHeight, sideDepth), center, style.wallColor3, Enum.Material.Concrete)
		volume:SetAttribute("ArchitectureRole", "RoofCourtyardSideWing")
		part(parent, "CourtyardRoofSideWingCap_" .. sign, Vector3.new(sideWidth + 1.1, 0.55, sideDepth + 1.1), center * CFrame.new(0, wingHeight * 0.5 + 0.24, 0), style.accentColor3, Enum.Material.Concrete)
		added += 2
	end
	local backWidth = width * 0.66
	local backDepth = math.max(7, depth * 0.16)
	local back = frame * CFrame.new(0, roofY + wingHeight * 0.5, depth * 0.36)
	local backVolume = part(parent, "CourtyardRoofBackWing", Vector3.new(backWidth, wingHeight, backDepth), back, style.wallColor3, Enum.Material.Concrete)
	backVolume:SetAttribute("ArchitectureRole", "RoofCourtyardBackWing")
	part(parent, "CourtyardRoofBackCap", Vector3.new(backWidth + 1.1, 0.55, backDepth + 1.1), back * CFrame.new(0, wingHeight * 0.5 + 0.24, 0), style.accentColor3, Enum.Material.Concrete)
	return added + 2
end

local function addSplitRoofWings(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, roofHeight: number, floorHeight: number, style: { [string]: any }, offsetZ: number): number
	local added = 0
	for index, sign in ipairs({ -1, 1 }) do
		local centerX = sign * width * 0.235
		added += addRoofWing(parent, frame, string.format("SplitRoofWing_%02d", index), width, depth, bodyHeight, roofHeight, floorHeight, style, centerX, offsetZ, 0.34, 0.72, if index == 1 then 0.68 else 0.92)
	end
	return added
end

local function addCornerRoofComposition(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, roofHeight: number, floorHeight: number, style: { [string]: any }): number
	local roofY = bodyHeight + roofHeight
	local longHeight = math.max(5, floorHeight * 0.68)
	local shortHeight = math.max(5, floorHeight * 0.84)
	local longWidth = math.max(16, width * 0.72)
	local longDepth = math.max(7, depth * 0.18)
	local shortWidth = math.max(7, width * 0.19)
	local shortDepth = math.max(12, depth * 0.52)
	local longCenter = frame * CFrame.new(0, roofY + longHeight * 0.5, depth * 0.34)
	local shortCenter = frame * CFrame.new(width * 0.32, roofY + shortHeight * 0.5, depth * 0.12)
	local longWing = part(parent, "CornerRoof_LongWing", Vector3.new(longWidth, longHeight, longDepth), longCenter, style.wallColor3, Enum.Material.Concrete)
	longWing:SetAttribute("ArchitectureRole", "DistinctLShapedRoofWing")
	local shortWing = part(parent, "CornerRoof_ShortWing", Vector3.new(shortWidth, shortHeight, shortDepth), shortCenter, style.wallColor3, Enum.Material.Concrete)
	shortWing:SetAttribute("ArchitectureRole", "DistinctLShapedRoofWing")
	part(parent, "CornerRoof_LongCoping", Vector3.new(longWidth + 1, 0.5, longDepth + 1), longCenter * CFrame.new(0, longHeight * 0.5 + 0.22, 0), style.accentColor3, Enum.Material.Concrete)
	part(parent, "CornerRoof_ShortCoping", Vector3.new(shortWidth + 1, 0.5, shortDepth + 1), shortCenter * CFrame.new(0, shortHeight * 0.5 + 0.22, 0), style.trimColor3, Enum.Material.Concrete)
	return 4
end

local function addCantileverRoofHall(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, roofHeight: number, floorHeight: number, style: { [string]: any }, spanFraction: number): number
	local hallWidth = math.max(14, width * spanFraction)
	local hallDepth = math.max(10, depth * 0.46)
	local hallHeight = math.max(6, floorHeight * 0.72)
	local projection = math.min(depth * 0.16, 10)
	local center = frame * CFrame.new(0, bodyHeight + roofHeight + hallHeight * 0.5, -depth * 0.24 - projection * 0.35)
	local volume = part(parent, "CantileverRoofLectureHall", Vector3.new(hallWidth, hallHeight, hallDepth), center, style.wallColor3, Enum.Material.Concrete)
	volume:SetAttribute("ArchitectureRole", "ProjectingLectureHallVolume")
	part(parent, "CantileverRoofLectureHallCap", Vector3.new(hallWidth + 2, 0.7, hallDepth + projection), center * CFrame.new(0, hallHeight * 0.5 + 0.32, -projection * 0.24), style.accentColor3, Enum.Material.Concrete)
	part(parent, "CantileverRoofLectureHallBand", Vector3.new(hallWidth * 0.76, math.max(2.1, hallHeight * 0.32), 0.22), center * CFrame.new(0, 0, -hallDepth * 0.5 - 0.14), style.windowColor3, Enum.Material.Glass, 0.1)
	return 3
end

local function addStairCore(
	parent: Instance,
	frame: CFrame,
	width: number,
	depth: number,
	bodyHeight: number,
	floorHeight: number,
	style: { [string]: any }
): number
	local coreWidth = math.clamp(math.min(width * 0.22, 12), 7, 12)
	local coreDepth = math.clamp(math.min(depth * 0.3, 14), 7, 14)
	local totalHeight = bodyHeight + floorHeight * 0.52
	local rotated = width > depth * 1.15
	local coreX: number
	local coreZ: number
	if rotated then
		coreX = width * 0.5 + coreWidth * 0.3
		coreZ = depth * 0.12
	else
		coreX = width * 0.2
		coreZ = depth * 0.5 + coreDepth * 0.3
	end
	local center = frame * CFrame.new(coreX, totalHeight * 0.5, coreZ)
	local body = part(parent, "ProjectingStairCore_Volume", Vector3.new(coreWidth, totalHeight, coreDepth), center, style.wallColor3, Enum.Material.Concrete)
	body:SetAttribute("ArchitectureRole", "ProjectingStairCore")
	part(parent, "ProjectingStairCore_Cap", Vector3.new(coreWidth + 1.1, 0.8, coreDepth + 1.1), frame * CFrame.new(coreX, totalHeight + 0.4, coreZ), style.accentColor3, Enum.Material.Concrete)
	local slitWidth = 0.62
	local slitHeight = math.min(6.8, floorHeight * 0.58)
	for floorIndex = 0, math.max(0, math.floor(bodyHeight / floorHeight) - 1) do
		local windowY = floorIndex * floorHeight + floorHeight * 0.5
		local slitSize = if rotated then Vector3.new(0.14, slitHeight, coreDepth * 0.48) else Vector3.new(coreWidth * 0.48, slitHeight, 0.14)
		local slitCFrame = if rotated
			then frame * CFrame.new(coreX + coreWidth * 0.5 + 0.09, windowY, coreZ)
			else frame * CFrame.new(coreX, windowY, coreZ + coreDepth * 0.5 + 0.09)
		part(parent, string.format("ProjectingStairCore_Slit_%02d", floorIndex + 1), slitSize, slitCFrame, style.windowColor3, Enum.Material.Glass, 0.12)
		part(parent, string.format("ProjectingStairCore_Band_%02d", floorIndex + 1), Vector3.new(coreWidth + 0.35, 0.26, coreDepth + 0.35), frame * CFrame.new(coreX, (floorIndex + 1) * floorHeight, coreZ), style.trimColor3, Enum.Material.SmoothPlastic)
	end
	local bladeSize = if rotated then Vector3.new(0.48, totalHeight * 0.72, 0.85) else Vector3.new(0.85, totalHeight * 0.72, 0.48)
	local bladeCFrame = if rotated
		then frame * CFrame.new(coreX + coreWidth * 0.5 + 0.16, totalHeight * 0.5, coreZ - coreDepth * 0.28)
		else frame * CFrame.new(coreX + coreWidth * 0.32, totalHeight * 0.5, coreZ + coreDepth * 0.5 + 0.16)
	part(parent, "ProjectingStairCore_IdentityBlade", bladeSize, bladeCFrame, style.accentColor3, Enum.Material.Metal)
	return 3 + math.max(0, math.floor(bodyHeight / floorHeight)) * 2
end

local function addLaboratoryMonitors(
	parent: Instance,
	frame: CFrame,
	width: number,
	depth: number,
	bodyHeight: number,
	roofHeight: number,
	style: { [string]: any }
): number
	local monitorCount = 3
	local monitorWidth = math.clamp(math.min(width * 0.2, 42), 18, 42)
	local monitorDepth = math.clamp(depth * 0.11, 6, 10)
	local monitorHeight = 3.4
	local roofY = bodyHeight + roofHeight + monitorHeight * 0.5
	for index = 1, monitorCount do
		local z = -depth * 0.3 + depth * 0.3 * (index - 1)
		local center = frame * CFrame.new(0, roofY, z)
		part(parent, string.format("LaboratoryRoofMonitor_%02d", index), Vector3.new(monitorWidth, monitorHeight, monitorDepth), center, style.wallColor3, Enum.Material.Concrete)
		part(parent, string.format("LaboratoryRoofMonitor_Glass_%02d", index), Vector3.new(monitorWidth * 0.66, monitorHeight * 0.56, 0.16), center * CFrame.new(0, -0.12, -monitorDepth * 0.5 - 0.1), style.windowColor3, Enum.Material.Glass, 0.16)
		part(parent, string.format("LaboratoryRoofMonitor_Cap_%02d", index), Vector3.new(monitorWidth + 1, 0.32, monitorDepth + 0.9), center * CFrame.new(0, monitorHeight * 0.5 + 0.16, 0), style.accentColor3, Enum.Material.Metal)
	end
	return monitorCount * 3
end

local function addLibraryPodium(
	parent: Instance,
	frame: CFrame,
	width: number,
	depth: number,
	style: { [string]: any }
): number
	local platformWidth = math.min(width * 0.68, 104)
	local frontZ = -depth * 0.5 - 1.6
	local stepDepth = 1.75
	local stepRise = 0.38
	for index = 1, 3 do
		local stepWidth = platformWidth + (3 - index) * 3.2
		local centerZ = frontZ - stepDepth * (3 - index + 0.5)
		local step = Instance.new("Part")
		step.Name = string.format("LibraryPodiumStep_%02d", index)
		step.Anchored = true
		step.CanCollide = true
		step.CanTouch = false
		step.CanQuery = true
		step.CastShadow = true
		step.Material = Enum.Material.Concrete
		step.Color = style.floorColor3
		step.Size = Vector3.new(stepWidth, stepRise, stepDepth + 0.25)
		step.CFrame = frame * CFrame.new(0, stepRise * (index - 0.5), centerZ)
		step:SetAttribute("ArchitectureRole", "WalkableLibraryEntryPodium")
		step.Parent = parent
	end
	return 3
end

function BuildingMassingGenerator.Build(
	parent: Instance,
	frame: CFrame,
	width: number,
	depth: number,
	floorHeight: number,
	storyCount: number,
	roofHeight: number,
	style: { [string]: any }
): { [string]: any }
	local folder = Instance.new("Folder")
	folder.Name = "MassingFeatures"
	folder.Parent = parent
	local form = style.buildingForm or "long_gallery_wing"
	local bodyHeight = floorHeight * storyCount
	local addedParts = 0
	local feature = form
	if form == "vertical_stair_tower_block" then
		addedParts += addStairCore(folder, frame, width, depth, bodyHeight, floorHeight, style)
		addedParts += addFrontScreen(folder, frame, width, depth, bodyHeight, style, "dense")
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "twin")
	elseif form == "stepped_long_veranda" then
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "alternating")
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		addedParts += addTerracedRoofPavilions(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, "diagonal")
		feature = "offset_veranda_plates_with_ground_arcade"
	elseif form == "arcaded_courtyard_wing" then
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "stacked")
		addedParts += addCourtyardRoofWings(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style)
		feature = "three_sided_cloister_with_roof_courtyard_wings"
	elseif form == "cantilevered_lecture_hall" then
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "monumental")
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "alternating")
		addedParts += addCantileverRoofHall(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, 0.86)
		feature = "projecting_lecture_hall_portal_and_upper_hall_volume"
	elseif form == "library_double_podium" then
		addedParts += addLibraryPodium(folder, frame, width, depth, style)
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "monumental")
		addedParts += addRoofLanterns(folder, frame, width, depth, bodyHeight, roofHeight, style)
		feature = "library_podium_atrium_and_three_roof_lanterns"
	elseif form == "laboratory_screened_bar" then
		addedParts += addLaboratoryMonitors(folder, frame, width, depth, bodyHeight, roofHeight, style)
		addedParts += addSawtoothRoof(folder, frame, width, depth, bodyHeight, roofHeight, style, 28)
		addedParts += addFrontScreen(folder, frame, width, depth, bodyHeight, style, "dense")
		feature = "laboratory_sawtooth_roof_screen_and_vent_monitors"
	elseif form == "split_portico_block" then
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "twin")
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "alternating")
		addedParts += addSplitRoofWings(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, -depth * 0.04)
		feature = "split_twin_porticos_with_separated_upper_wings"
	elseif form == "garden_pavilion_wing" then
		addedParts += addRoofLanterns(folder, frame, width, depth, bodyHeight, roofHeight, style)
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		addedParts += addTerracedRoofPavilions(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, "cluster")
		feature = "garden_pavilion_with_lanterns_and_roof_pavilions"
	elseif form == "stacked_open_gallery_block" then
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "stacked")
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		addedParts += addRoofWing(folder, frame, "B4_RoofHall", width, depth, bodyHeight, roofHeight, floorHeight, style, 0, depth * 0.12, 0.78, 0.34, 0.58)
		feature = "deeply_stacked_open_galleries_with_offset_roof_hall"
	elseif form == "stair_core_colonnade" then
		addedParts += addStairCore(folder, frame, width, depth, bodyHeight, floorHeight, style)
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		feature = "projecting_stair_core_and_pilotis_entry"
	elseif form == "long_cantilevered_bar" then
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "alternating")
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "monumental")
		addedParts += addCantileverRoofHall(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, 0.68)
		feature = "alternating_cantilevered_edges_with_long_roof_bar"
	elseif form == "screened_double_bar" then
		addedParts += addFrontScreen(folder, frame, width, depth, bodyHeight, style, "dense")
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "stacked")
		addedParts += addTerracedRoofPavilions(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, "stepped")
		feature = "double_gallery_with_screened_bays_and_roof_pods"
	elseif form == "shopfront_teaching_block" then
		addedParts += addSawtoothRoof(folder, frame, width, depth, bodyHeight, roofHeight, style, 22)
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "monumental")
		feature = "shopfront_teaching_hall_with_sawtooth_roof"
	elseif form == "deep_colonnaded_gallery" then
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "stacked")
		addedParts += addSplitRoofWings(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, depth * 0.1)
		feature = "full_length_cloister_with_twin_roof_wings"
	elseif form == "recessed_veranda_bar" then
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "stacked")
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "monumental")
		addedParts += addCornerRoofComposition(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style)
		feature = "deep_recessed_bays_with_l_shaped_roof_wing"
	elseif form == "blue_band_double_gallery" then
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "stacked")
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		addedParts += addSplitRoofWings(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, -depth * 0.12)
		feature = "blue_double_gallery_with_split_rooftop_wings"
	elseif form == "stacked_loggia_tower" then
		addedParts += addStairCore(folder, frame, width, depth, bodyHeight, floorHeight, style)
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "stacked")
		feature = "paired_loggia_tower_with_projecting_balcony_edges"
	elseif form == "clerestory_pergola_wing" then
		addedParts += addRoofLanterns(folder, frame, width, depth, bodyHeight, roofHeight, style)
		addedParts += addSawtoothRoof(folder, frame, width, depth, bodyHeight, roofHeight, style, 32)
		feature = "narrow_pergola_wing_with_repeated_clerestory_sheds"
	elseif form == "compact_stair_tower" then
		addedParts += addStairCore(folder, frame, width, depth, bodyHeight, floorHeight, style)
		addedParts += addFrontScreen(folder, frame, width, depth, bodyHeight, style, "alternating")
		feature = "compact_vertical_core_and_split_height_screens"
	elseif form == "alternating_screen_wing" then
		addedParts += addFrontScreen(folder, frame, width, depth, bodyHeight, style, "alternating")
		addedParts += addProjectingFloorPlates(folder, frame, width, depth, floorHeight, storyCount, style, "alternating")
		addedParts += addTerracedRoofPavilions(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style, "staggered")
		feature = "alternating_screen_bays_and_staggered_roof_pavilions"
	elseif form == "striped_market_pavilion" then
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "monumental")
		feature = "low_market_pavilion_with_layered_striped_awnings"
	elseif form == "utility_tower_porch" then
		addedParts += addStairCore(folder, frame, width, depth, bodyHeight, floorHeight, style)
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		feature = "utility_chimney_tower_and_service_porch"
	elseif form == "service_portico_block" then
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "arcade")
		addedParts += addRoofWing(folder, frame, "ServiceRoofRoom", width, depth, bodyHeight, roofHeight, floorHeight, style, width * 0.22, depth * 0.1, 0.42, 0.34, 0.34)
		feature = "low_service_portico_with_flat_parapet_and_roof_room"
	else
		addedParts += addEntrancePortal(folder, frame, width, depth, floorHeight, style, "monumental")
	end
	return { Feature = feature, PartCount = addedParts }
end

return table.freeze(BuildingMassingGenerator)
