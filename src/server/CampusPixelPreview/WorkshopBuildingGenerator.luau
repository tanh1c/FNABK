--!strict
-- Native low-poly workshop shells used only by the detached pixel preview.
-- These replace classroom-building templates for C1, C2, and C3.

local WorkshopBuildingGenerator = {}

local STORY_STEP = 12.6

type WorkshopStyle = {
	kind: string,
	stories: number,
	wall: Color3,
	trim: Color3,
	accent: Color3,
	roof: Color3,
	frontWall: Color3,
}

local STYLES: { [string]: WorkshopStyle } = {
	C1 = {
		kind = "heavy_mechanical_workshop_high_bay_with_partial_upper_service_floor",
		stories = 2,
		wall = Color3.fromRGB(206, 205, 192),
		trim = Color3.fromRGB(236, 232, 216),
		accent = Color3.fromRGB(215, 121, 48),
		roof = Color3.fromRGB(80, 92, 99),
		frontWall = Color3.fromRGB(188, 189, 181),
	},
	C2 = {
		kind = "mechatronics_assembly_lab_blue_service_band",
		stories = 1,
		wall = Color3.fromRGB(225, 230, 225),
		trim = Color3.fromRGB(242, 241, 224),
		accent = Color3.fromRGB(38, 132, 186),
		roof = Color3.fromRGB(75, 91, 103),
		frontWall = Color3.fromRGB(211, 219, 216),
	},
	C3 = {
		kind = "single_story_mechanical_shop_red_steel_portals_and_crane_rail",
		stories = 1,
		wall = Color3.fromRGB(194, 193, 181),
		trim = Color3.fromRGB(222, 216, 195),
		accent = Color3.fromRGB(200, 83, 44),
		roof = Color3.fromRGB(73, 84, 90),
		frontWall = Color3.fromRGB(178, 177, 164),
	},
}

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	frame: CFrame,
	color: Color3,
	material: Enum.Material,
	collidable: boolean?
): Part
	local result = Instance.new("Part")
	result.Name = name
	result.Size = size
	result.CFrame = frame
	result.Anchored = true
	result.CanCollide = collidable ~= false
	result.CanTouch = false
	result.CanQuery = collidable ~= false
	result.CastShadow = true
	result.Material = material
	result.Color = color
	result.Parent = parent
	return result
end

local function at(frame: CFrame, x: number, y: number, z: number, pitch: number?): CFrame
	return frame * CFrame.new(x, y, z) * CFrame.Angles(pitch or 0, 0, 0)
end

local function addNameboard(parent: Instance, frame: CFrame, width: number, frontZ: number, displayName: string, accent: Color3)
	local boardWidth = math.clamp(width * 0.17, 17, 28)
	local board = part(
		parent,
		"WorkshopNameboard",
		Vector3.new(boardWidth, 3.6, 0.32),
		at(frame, 0, 8.8, frontZ),
		Color3.fromRGB(20, 49, 84),
		Enum.Material.SmoothPlastic,
		true
	)
	board:SetAttribute("DisplayName", displayName)
	local face = Instance.new("SurfaceGui")
	face.Name = "WorkshopNameboardFace"
	face.Face = Enum.NormalId.Back
	face.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	face.PixelsPerStud = 44
	face.LightInfluence = 0
	face.Parent = board
	local label = Instance.new("TextLabel")
	label.Name = "ReadableLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = displayName
	label.TextColor3 = Color3.fromRGB(248, 246, 231)
	label.TextScaled = true
	label.TextWrapped = false
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = face
	part(parent, "NameboardAccent", Vector3.new(boardWidth, 0.18, 0.4), at(frame, 0, 6.9, frontZ), accent, Enum.Material.Metal, false)
end

local function addBayFacade(
	parent: Instance,
	frame: CFrame,
	style: WorkshopStyle,
	width: number,
	depth: number,
	count: number,
	wallHeight: number,
	openingWidth: number,
	openingHeight: number
)
	local frontZ = depth * 0.5 - 0.45
	local bottom = 0.75
	local step = width / count
	for index = 0, count do
		local x = -width * 0.5 + step * index
		part(parent, string.format("PortalPier_%02d", index + 1), Vector3.new(1.2, wallHeight, 0.9), at(frame, x, bottom + wallHeight * 0.5, frontZ), style.accent, Enum.Material.Metal, true)
	end
	for index = 0, count - 1 do
		local centerX = -width * 0.5 + step * (index + 0.5)
		local clearWidth = math.min(openingWidth, step - 2)
		local sideWidth = math.max(0.4, (step - clearWidth) * 0.5)
		local sideHeight = math.min(openingHeight, wallHeight - 1.4)
		local xLeft = centerX - clearWidth * 0.5 - sideWidth * 0.5
		local xRight = centerX + clearWidth * 0.5 + sideWidth * 0.5
		part(parent, string.format("PortalLeftReturn_%02d", index + 1), Vector3.new(sideWidth, wallHeight, 0.8), at(frame, xLeft, bottom + wallHeight * 0.5, frontZ), style.frontWall, Enum.Material.Concrete, true)
		part(parent, string.format("PortalRightReturn_%02d", index + 1), Vector3.new(sideWidth, wallHeight, 0.8), at(frame, xRight, bottom + wallHeight * 0.5, frontZ), style.frontWall, Enum.Material.Concrete, true)
		local headerHeight = math.max(1.2, wallHeight - sideHeight)
		part(parent, string.format("PortalHeader_%02d", index + 1), Vector3.new(clearWidth, headerHeight, 0.8), at(frame, centerX, bottom + sideHeight + headerHeight * 0.5, frontZ), style.frontWall, Enum.Material.Concrete, true)
		part(parent, string.format("OpenBayShadow_%02d", index + 1), Vector3.new(clearWidth - 0.3, sideHeight, 0.16), at(frame, centerX, bottom + sideHeight * 0.5, frontZ - 0.16), Color3.fromRGB(50, 58, 61), Enum.Material.SmoothPlastic, false)
		part(parent, string.format("SafetyStripe_%02d", index + 1), Vector3.new(clearWidth - 0.5, 0.24, 0.08), at(frame, centerX, bottom + 0.5, frontZ + 0.49), Color3.fromRGB(235, 178, 47), Enum.Material.Neon, false)
	end
	part(parent, "FrontContinuousLintel", Vector3.new(width, 0.9, 1.1), at(frame, 0, bottom + wallHeight - 0.45, frontZ), style.trim, Enum.Material.Concrete, true)
end

local function addSingleLevelShell(parent: Instance, frame: CFrame, style: WorkshopStyle, width: number, depth: number, wallHeight: number, bays: number, openingWidth: number, openingHeight: number)
	local floorCenterY = 0.35
	local floorThickness = 0.7
	local usableWidth = width - 0.8
	local usableDepth = depth - 0.8
	part(parent, "WorkshopWalkableFloor", Vector3.new(usableWidth, floorThickness, usableDepth), at(frame, 0, floorCenterY, 0), Color3.fromRGB(126, 127, 119), Enum.Material.Concrete, true)
	local wallBaseY = floorCenterY + floorThickness * 0.5
	local wallHeightActual = wallHeight - wallBaseY
	local rearZ = -depth * 0.5 + 0.45
	part(parent, "RearWorkshopWall", Vector3.new(usableWidth, wallHeightActual, 0.9), at(frame, 0, wallBaseY + wallHeightActual * 0.5, rearZ), style.wall, Enum.Material.Concrete, true)
	for side = -1, 1, 2 do
		local sideX = side * (width * 0.5 - 0.45)
		part(parent, if side < 0 then "EndWall_West" else "EndWall_East", Vector3.new(0.9, wallHeightActual, usableDepth), at(frame, sideX, wallBaseY + wallHeightActual * 0.5, 0), style.wall, Enum.Material.Concrete, true)
	end
	addBayFacade(parent, frame, style, usableWidth, usableDepth, bays, wallHeightActual, openingWidth, openingHeight)
	part(parent, "BackBlueOrSafetyBand", Vector3.new(usableWidth, 1.4, 0.45), at(frame, 0, wallBaseY + 2.0, rearZ + 0.7), style.accent, Enum.Material.SmoothPlastic, false)

	local roofY = wallHeight
	local roofDepth = usableDepth - 1.5
	part(parent, "RoofPanel_Front", Vector3.new(usableWidth, 0.65, roofDepth * 0.5), at(frame, 0, roofY, depth * 0.25, math.rad(4)), style.roof, Enum.Material.Metal, true)
	part(parent, "RoofPanel_Back", Vector3.new(usableWidth, 0.65, roofDepth * 0.5), at(frame, 0, roofY + 0.4, -depth * 0.25, math.rad(-4)), style.roof, Enum.Material.Metal, true)
end

local function addClerestory(parent: Instance, frame: CFrame, width: number, _depth: number, y: number, glass: Color3, accent: Color3, count: number)
	local segment = (width - 4) / count
	for index = 1, count do
		local x = -width * 0.5 + 2 + segment * (index - 0.5)
		part(parent, string.format("ClerestoryCurb_%02d", index), Vector3.new(segment - 1, 1.2, 2.6), at(frame, x, y - 1, 0), accent, Enum.Material.Metal, true)
		part(parent, string.format("ClerestoryGlass_%02d", index), Vector3.new(segment - 1.1, 1.5, 0.28), at(frame, x, y + 0.25, -0.15), glass, Enum.Material.Glass, false).Transparency = 0.35
		part(parent, string.format("ClerestoryCap_%02d", index), Vector3.new(segment, 0.35, 3.2), at(frame, x, y + 1.2, 0), accent, Enum.Material.Metal, true)
	end
end

local function addMachine(parent: Instance, frame: CFrame, prefix: string, x: number, y: number, z: number, accent: Color3, compact: boolean)
	local sx = if compact then 4.6 else 5.4
	local sz = if compact then 3.2 else 4.4
	part(parent, prefix .. "Base", Vector3.new(sx, 1.4, sz), at(frame, x, y + 0.7, z), Color3.fromRGB(72, 80, 82), Enum.Material.Metal, true)
	part(parent, prefix .. "MachineBody", Vector3.new(sx * 0.58, 2.4, sz * 0.76), at(frame, x, y + 2.6, z - 0.2), accent, Enum.Material.Metal, true)
	part(parent, prefix .. "ControlPanel", Vector3.new(sx * 0.28, 1.4, 0.38), at(frame, x + sx * 0.22, y + 3.2, z + sz * 0.36), Color3.fromRGB(29, 50, 59), Enum.Material.SmoothPlastic, true)
	part(parent, prefix .. "WorkSurface", Vector3.new(sx * 0.9, 0.28, sz * 0.9), at(frame, x, y + 4.1, z), Color3.fromRGB(190, 190, 177), Enum.Material.Metal, true)
	part(parent, prefix .. "StatusLamp", Vector3.new(0.4, 0.4, 0.4), at(frame, x - sx * 0.28, y + 3.6, z + sz * 0.25), Color3.fromRGB(86, 208, 177), Enum.Material.Neon, false)
end

local function addInteriorLights(parent: Instance, frame: CFrame, width: number, _depth: number, y: number, count: number, tint: Color3)
	for index = 1, count do
		local x = -width * 0.5 + width * index / (count + 1)
		part(parent, string.format("IndustrialLight_%02d", index), Vector3.new(6, 0.22, 0.9), at(frame, x, y, 0), tint, Enum.Material.Neon, false)
	end
end

local function buildC1(parent: Instance, frame: CFrame, width: number, depth: number, displayName: string, style: WorkshopStyle)
	local wallHeight = 24.8
	addSingleLevelShell(parent, frame, style, width, depth, wallHeight, 8, 9.2, 9.7)
	-- C1 is a high-bay mechanics hall with a partial upper service/inspection floor.
	local upperWidth = width * 0.48
	local upperDepth = depth * 0.52
	local upperX = width * 0.16
	local deckY = STORY_STEP
	part(parent, "UpperWalkableServiceFloor", Vector3.new(upperWidth, 0.8, upperDepth), at(frame, upperX, deckY, -depth * 0.18), Color3.fromRGB(179, 179, 169), Enum.Material.Concrete, true)
	local roomWidth = upperWidth / 4
	for index = 0, 4 do
		local x = upperX - upperWidth * 0.5 + roomWidth * index
		part(parent, string.format("UpperRoomPartition_%02d", index + 1), Vector3.new(0.4, 8.8, upperDepth - 1), at(frame, x, deckY + 4.8, -depth * 0.18), style.wall, Enum.Material.Concrete, true)
	end
	part(parent, "UpperInspectionBalustrade", Vector3.new(upperWidth, 1.1, 0.45), at(frame, upperX, deckY + 1.0, depth * 0.12), style.accent, Enum.Material.Metal, true)
	part(parent, "UpperServiceRearWall", Vector3.new(upperWidth, 8.8, 0.65), at(frame, upperX, deckY + 4.8, -depth * 0.18 - upperDepth * 0.5), style.trim, Enum.Material.Concrete, true)
	part(parent, "UpperServiceFrontBand", Vector3.new(upperWidth, 1.0, 0.6), at(frame, upperX, deckY + 8.7, depth * 0.12), style.accent, Enum.Material.SmoothPlastic, false)
	-- 16 shallow steps rise to the upper inspection deck from the ground floor.
	local rise = (deckY - 0.35) / 16
	local run = 1.15
	local stairStartX = -width * 0.5 + 11
	for index = 1, 16 do
		local h = rise * index
		part(parent, string.format("UpperFloorStair_%02d", index), Vector3.new(run + 0.05, h, 5.8), at(frame, stairStartX + (index - 0.5) * run, 0.35 + h * 0.5, depth * 0.04), style.frontWall, Enum.Material.Concrete, true)
	end
	part(parent, "WorkshopWalkAisleMark", Vector3.new(width * 0.7, 0.08, 0.45), at(frame, 0, 0.77, 0), Color3.fromRGB(227, 178, 46), Enum.Material.Neon, false)
	for index = 1, 7 do
		local x = -width * 0.38 + width * 0.76 * (index - 0.5) / 7
		addMachine(parent, frame, string.format("MechanicalLathe_%02d", index), x, 0.8, -depth * 0.18, style.accent, false)
	end
	addClerestory(parent, frame, width, depth, 22.2, Color3.fromRGB(154, 209, 217), style.trim, 7)
	addInteriorLights(parent, frame, width * 0.76, depth, 18.7, 9, Color3.fromRGB(248, 225, 168))
	addNameboard(parent, frame, width, depth * 0.5 - 0.9, displayName, style.accent)
end

local function buildC2(parent: Instance, frame: CFrame, width: number, depth: number, displayName: string, style: WorkshopStyle)
	local roofY = 11.8
	addSingleLevelShell(parent, frame, style, width, depth, roofY, 5, 13, 8.2)
	-- The mechatronics lab uses a low laboratory shell, a blue belt course, and modular test cells.
	local bandHeight = 1.25
	part(parent, "BlueMechatronicsBelt_Front", Vector3.new(width - 1.4, bandHeight, 0.55), at(frame, 0, 8.7, depth * 0.5 - 0.8), style.accent, Enum.Material.SmoothPlastic, false)
	part(parent, "BlueMechatronicsBelt_Rear", Vector3.new(width - 1.4, bandHeight, 0.55), at(frame, 0, 8.7, -depth * 0.5 + 0.8), style.accent, Enum.Material.SmoothPlastic, false)
	for index = 1, 7 do
		local x = -width * 0.42 + width * 0.84 * (index - 0.5) / 7
		part(parent, string.format("MechatronicsWindow_%02d", index), Vector3.new(11, 2.5, 0.22), at(frame, x, 6.4, depth * 0.5 - 0.66), Color3.fromRGB(144, 207, 220), Enum.Material.Glass, false).Transparency = 0.28
		part(parent, string.format("WindowMullion_%02d", index), Vector3.new(0.28, 2.9, 0.32), at(frame, x, 6.4, depth * 0.5 - 0.48), style.accent, Enum.Material.Metal, false)
	end
	for index = 1, 6 do
		local x = -width * 0.39 + width * 0.78 * (index - 0.5) / 6
		addMachine(parent, frame, string.format("MechatronicsTestCell_%02d", index), x, 0.8, -depth * 0.18, style.accent, true)
		part(parent, string.format("RobotCellGuard_%02d", index), Vector3.new(0.22, 2.2, 5.5), at(frame, x + 5.0, 1.9, -depth * 0.18), Color3.fromRGB(232, 190, 69), Enum.Material.Metal, true)
	end
	-- Roof monitors are narrow, segmented and glass-sided; the roof remains walkable geometry only.
	for index = 1, 5 do
		local x = -width * 0.42 + width * 0.84 * (index - 0.5) / 5
		part(parent, string.format("RoofMonitorBase_%02d", index), Vector3.new(16, 0.75, 2.6), at(frame, x, 12.1, -depth * 0.16), style.roof, Enum.Material.Metal, true)
		part(parent, string.format("RoofMonitorGlass_%02d", index), Vector3.new(15.4, 1.4, 0.25), at(frame, x, 13.05, -depth * 0.16), Color3.fromRGB(146, 202, 217), Enum.Material.Glass, false).Transparency = 0.3
		part(parent, string.format("RoofMonitorCap_%02d", index), Vector3.new(16.4, 0.35, 3), at(frame, x, 13.95, -depth * 0.16), style.accent, Enum.Material.Metal, true)
	end
	addInteriorLights(parent, frame, width * 0.8, depth, 10.4, 7, Color3.fromRGB(210, 235, 247))
	addNameboard(parent, frame, width, depth * 0.5 - 0.9, displayName, style.accent)
end

local function buildC3(parent: Instance, frame: CFrame, width: number, depth: number, displayName: string, style: WorkshopStyle)
	local roofY = 12.1
	addSingleLevelShell(parent, frame, style, width, depth, roofY, 6, 10.5, 8.8)
	-- C3's identity is its exposed red portal frame, continuous overhead crane rail, and sawtooth roof.
	for index = 1, 7 do
		local x = -width * 0.46 + width * 0.92 * (index - 1) / 6
		part(parent, string.format("RedPortalColumn_%02d", index), Vector3.new(0.75, 10.4, 1.0), at(frame, x, 5.95, -depth * 0.5 + 2.2), style.accent, Enum.Material.Metal, true)
		part(parent, string.format("RedPortalTie_%02d", index), Vector3.new(0.75, 0.75, depth - 4), at(frame, x, 11.2, 0), style.accent, Enum.Material.Metal, true)
	end
	part(parent, "OverheadCraneRail_Front", Vector3.new(width * 0.84, 0.8, 0.8), at(frame, 0, 9.4, depth * 0.24), Color3.fromRGB(52, 61, 67), Enum.Material.Metal, true)
	part(parent, "OverheadCraneRail_Back", Vector3.new(width * 0.84, 0.8, 0.8), at(frame, 0, 9.4, -depth * 0.24), Color3.fromRGB(52, 61, 67), Enum.Material.Metal, true)
	part(parent, "BridgeCraneBeam", Vector3.new(1.2, 1.1, depth * 0.5), at(frame, width * 0.1, 9.0, 0), style.accent, Enum.Material.Metal, true)
	part(parent, "BridgeCraneHoist", Vector3.new(1.6, 2.2, 1.6), at(frame, width * 0.1, 7.35, 0), Color3.fromRGB(62, 72, 75), Enum.Material.Metal, true)
	for index = 1, 8 do
		local x = -width * 0.42 + width * 0.84 * (index - 0.5) / 8
		part(parent, string.format("RoofSawtoothPanel_%02d", index), Vector3.new(width * 0.84 / 8 - 0.8, 0.55, depth * 0.42), at(frame, x, 13.25, 0, if index % 2 == 0 then math.rad(-7) else math.rad(7)), style.roof, Enum.Material.Metal, true)
		part(parent, string.format("RoofVentMonitor_%02d", index), Vector3.new(width * 0.84 / 8 - 1, 1.0, 0.5), at(frame, x, 14.0, -depth * 0.08), Color3.fromRGB(120, 177, 187), Enum.Material.Glass, false).Transparency = 0.35
	end
	for index = 1, 6 do
		local x = -width * 0.4 + width * 0.8 * (index - 0.5) / 6
		addMachine(parent, frame, string.format("MechanicalWorkbench_%02d", index), x, 0.8, -depth * 0.18, style.accent, false)
	end
	addInteriorLights(parent, frame, width * 0.78, depth, 10.6, 8, Color3.fromRGB(248, 224, 165))
	addNameboard(parent, frame, width, depth * 0.5 - 0.9, displayName, style.accent)
end

function WorkshopBuildingGenerator.Build(
	parent: Instance,
	frame: CFrame,
	width: number,
	depth: number,
	buildingId: string,
	displayName: string,
	stories: number
): (Model, number)
	local style = STYLES[buildingId]
	assert(style, "No workshop architecture profile for " .. buildingId)
	assert(stories == style.stories, "Workshop story count does not match user-confirmed profile for " .. buildingId)
	assert(width > 8 and depth > 8, "Workshop footprint is too small for architecture: " .. buildingId)
	local inset = 1.2
	local usableWidth = width - inset
	local usableDepth = depth - inset
	local model = Instance.new("Model")
	model.Name = "WorkshopArchitecture"
	model:SetAttribute("CampusBuildingId", buildingId)
	model:SetAttribute("BuildingDisplayName", displayName)
	model:SetAttribute("ArchitectureType", style.kind)
	model:SetAttribute("WorkshopSpecialization", if buildingId == "C2" then "mechatronics" else "mechanical")
	model:SetAttribute("ArchitectureRevision", "PixelWorkshop_v1")
	model:SetAttribute("StoryCountIncludesGroundFloor", true)
	model:SetAttribute("EstimatedStories", stories)
	model:SetAttribute("WalkableFloorCount", stories)
	model:SetAttribute("StoryEstimateStatus", "user_confirmed_2026_11_01")
	model.Parent = parent

	if buildingId == "C1" then
		buildC1(model, frame, usableWidth, usableDepth, displayName, style)
	elseif buildingId == "C2" then
		buildC2(model, frame, usableWidth, usableDepth, displayName, style)
	else
		buildC3(model, frame, usableWidth, usableDepth, displayName, style)
	end
	return model, #model:GetDescendants()
end

return table.freeze(WorkshopBuildingGenerator)
