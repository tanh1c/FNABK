--!strict
-- Builds the internal corridor and separately bounded classrooms behind exterior galleries.
local ClassroomLayoutGenerator = {}
local furnitureGenerator = require(script.Parent:WaitForChild("InteriorFurnitureGenerator"))

local function makeBox(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, role: string): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = true
	part.CanTouch = false
	part.CanQuery = true
	part.CastShadow = true
	part.Material = Enum.Material.Concrete
	part.Color = color
	part.Size = size
	part.CFrame = cframe
	part:SetAttribute("InteriorGeometryRole", role)
	part.Parent = parent
	return part
end

local function buildWallWithGaps(
	parent: Instance,
	frame: CFrame,
	name: string,
	x: number,
	zMin: number,
	zMax: number,
	baseY: number,
	wallHeight: number,
	wallThickness: number,
	wallColor: Color3,
	gaps: { { center: number, width: number } },
	doorHeight: number
)
	for _, gap in ipairs(gaps) do
		assert(typeof(gap.center) == "number" and typeof(gap.width) == "number", "Room doorway gaps must contain numeric center and width values")
	end
	table.sort(gaps, function(a, b)
		return a.center < b.center
	end)
	local cursor = zMin
	for index, gap in ipairs(gaps) do
		local gapStart = math.max(cursor, gap.center - gap.width * 0.5)
		local gapEnd = math.min(zMax, gap.center + gap.width * 0.5)
		if gapStart - cursor > 1 then
			makeBox(parent, string.format("%s_Wall_%02d", name, index), Vector3.new(wallThickness, wallHeight, gapStart - cursor), frame * CFrame.new(x, baseY + wallHeight * 0.5, (cursor + gapStart) * 0.5), wallColor, "InteriorWall")
		end
		if gapEnd > gapStart and wallHeight > doorHeight then
			local headerHeight = wallHeight - doorHeight
			makeBox(parent, string.format("%s_Header_%02d", name, index), Vector3.new(wallThickness, headerHeight, gapEnd - gapStart), frame * CFrame.new(x, baseY + doorHeight + headerHeight * 0.5, (gapStart + gapEnd) * 0.5), wallColor, "InteriorDoorHeader")
		end
		cursor = math.max(cursor, gapEnd)
	end
	if zMax - cursor > 1 then
		makeBox(parent, name .. "_Wall_End", Vector3.new(wallThickness, wallHeight, zMax - cursor), frame * CFrame.new(x, baseY + wallHeight * 0.5, (cursor + zMax) * 0.5), wallColor, "InteriorWall")
	end
end

local function getRoomType(style: { [string]: any }, floorIndex: number, bayIndex: number): string
	if style.roomType == "laboratory" and bayIndex % 3 == 0 then
		return "laboratory"
	elseif style.roomType == "technical" and floorIndex == 0 and bayIndex == 1 then
		return "generator"
	elseif style.roomType == "technical" then
		return "laboratory"
	elseif style.roomType == "library" then
		return if bayIndex % 3 == 0 then "study" else "library"
	elseif style.roomType == "service" then
		return if bayIndex % 2 == 0 then "service" else "storage"
	elseif style.roomType == "storage" then
		return if bayIndex % 2 == 0 then "storage" else "service"
	end
	return "classroom"
end

function ClassroomLayoutGenerator.Build(
	structure: Instance,
	furnishings: Instance,
	frame: CFrame,
	spec: { [string]: any },
	width: number,
	depth: number,
	floorHeight: number,
	floorCount: number,
	style: { [string]: any },
	buildingStyle: { [string]: any },
	stairX: number,
	stairCenterZ: number,
	stairRun: number
): { [string]: any }
	local rotated = width > depth * 1.15
	local layoutFrame = if rotated then frame * CFrame.Angles(0, math.pi * 0.5, 0) else frame
	local layoutWidth = if rotated then depth else width
	local layoutLength = if rotated then width else depth
	local outerThickness = style.outerWallThicknessStuds
	local innerThickness = style.interiorWallThicknessStuds
	local corridorWidth = math.min(style.corridorWidthStuds, layoutWidth * 0.28)
	local usableHalfWidth = layoutWidth * 0.5 - outerThickness
	local corridorWallX = corridorWidth * 0.5 + innerThickness * 0.5
	local wingDepth = usableHalfWidth - corridorWallX - innerThickness * 0.5
	local wingCenterX = corridorWallX + innerThickness * 0.5 + wingDepth * 0.5
	local endInset = outerThickness + 0.9
	local usableLength = math.max(24, layoutLength - endInset * 2)
	local desiredBayLength = buildingStyle.classroomBayLengthStuds or 36
	local bayCount = math.clamp(math.floor(usableLength / desiredBayLength), 2, buildingStyle.maxClassroomBays or 9)
	if bayCount > 3 and bayCount % 2 == 0 then
		bayCount -= 1
	end
	local bayLength = usableLength / bayCount
	local lengthMin = -usableLength * 0.5
	local centers = {}
	for bayIndex = 1, bayCount do
		table.insert(centers, lengthMin + bayLength * (bayIndex - 0.5))
	end
	local doorPosition = frame * CFrame.new(0, 0, -depth * 0.5)
	local doorLocal = layoutFrame:PointToObjectSpace(doorPosition.Position)
	local entrySide = if doorLocal.X < 0 then -1 else 1
	local stairSide = -entrySide
	local wallHeight = math.min(style.interiorWallHeightStuds, floorHeight - style.floorSlabThicknessStuds - 0.45)
	local doorHeight = math.min(style.interiorDoorHeightStuds, wallHeight - 0.8)
	local wallColor = buildingStyle.wallColor3:Lerp(Color3.new(1, 1, 1), 0.04)
	local roomsBuilt = 0
	local classroomsPerFloor: { number } = {}
	local classroomCount = 0
	local furniturePartCount = 0
	local roomNumber = 0
	local lightCount = 0
	local galleryDoorsBySide: { [number]: { [number]: { { center: number, width: number, doorHeight: number } } } } = {
		[-1] = {},
		[1] = {},
	}

	for floorIndex = 0, floorCount - 1 do
		galleryDoorsBySide[-1][floorIndex + 1] = {}
		galleryDoorsBySide[1][floorIndex + 1] = {}
		local baseY = floorIndex * floorHeight + style.floorSlabThicknessStuds
		local zMin = -layoutLength * 0.5 + outerThickness + 0.35
		local zMax = layoutLength * 0.5 - outerThickness - 0.35
		local sideGaps: { [number]: { { center: number, width: number } } } = { [-1] = {}, [1] = {} }
		local stairGapWidth = math.min(math.max(style.interiorDoorWidthStuds, style.stairWidthStuds + 2), wingDepth - 1)

		for side in ipairs({ -1, 1 }) do
			local sign = if side == 1 then 1 else -1
			for bayIndex, center in ipairs(centers) do
					local lobby = rotated and floorIndex == 0 and sign == entrySide and bayIndex == math.ceil(bayCount * 0.5)
				local overlapsStair = sign == stairSide and math.abs(center - stairCenterZ) < (bayLength + stairRun) * 0.5
				if lobby then
				table.insert(sideGaps[sign], { center = center, width = bayLength - 0.8 })
			elseif overlapsStair then
				table.insert(sideGaps[sign], { center = stairCenterZ, width = stairGapWidth })
			else
				table.insert(sideGaps[sign], { center = center, width = math.min(style.interiorDoorWidthStuds, bayLength * 0.42) })
			end
		end
			buildWallWithGaps(
				structure,
				layoutFrame,
				string.format("CorridorWall_F%02d_Side_%s", floorIndex + 1, if sign < 0 then "West" else "East"),
				sign * corridorWallX,
				zMin,
				zMax,
				baseY,
				wallHeight,
				innerThickness,
				wallColor,
				sideGaps[sign],
				doorHeight
			)
		end

		for side in ipairs({ -1, 1 }) do
			local sign = if side == 1 then 1 else -1
			for boundaryIndex = 0, bayCount do
				local boundaryZ = lengthMin + bayLength * boundaryIndex
				if boundaryZ >= zMin + 1 and boundaryZ <= zMax - 1 then
					local inStairHall = sign == stairSide and math.abs(boundaryZ - stairCenterZ) < stairRun * 0.5 + 1
					if not inStairHall then
						makeBox(
							structure,
							string.format("RoomDivider_F%02d_Side_%s_%02d", floorIndex + 1, if sign < 0 then "West" else "East", boundaryIndex),
							Vector3.new(wingDepth, wallHeight, innerThickness),
							layoutFrame * CFrame.new(sign * wingCenterX, baseY + wallHeight * 0.5, boundaryZ),
							wallColor,
							"RoomDivider"
						)
					end
				end
			end
		end

		local floorRoomCount = 0
		for side in ipairs({ -1, 1 }) do
			local sign = if side == 1 then 1 else -1
			for bayIndex, center in ipairs(centers) do
				local lobby = rotated and floorIndex == 0 and sign == entrySide and bayIndex == math.ceil(bayCount * 0.5)
				local overlapsStair = sign == stairSide and math.abs(center - stairCenterZ) < (bayLength + stairRun) * 0.5
				if lobby then
					table.insert(galleryDoorsBySide[sign][floorIndex + 1], {
						center = center,
						width = math.min(style.exteriorDoorWidthStuds, bayLength * 0.4),
						doorHeight = math.min(style.exteriorDoorHeightStuds, wallHeight - 1.4),
					})
					local lobbyModel = Instance.new("Model")
					lobbyModel.Name = "GroundFloorEntryLobby"
					lobbyModel:SetAttribute("RoomType", "EntryLobby")
					lobbyModel:SetAttribute("FloorIndex", 1)
					lobbyModel.Parent = furnishings
					roomsBuilt += 1
				elseif overlapsStair then
					if not structure:FindFirstChild(string.format("StairHall_F%02d", floorIndex + 1)) then
						local stairHall = Instance.new("Model")
						stairHall.Name = string.format("StairHall_F%02d", floorIndex + 1)
						stairHall:SetAttribute("RoomType", "StairHall")
						stairHall:SetAttribute("FloorIndex", floorIndex + 1)
						stairHall.Parent = structure
					end
				else
					table.insert(galleryDoorsBySide[sign][floorIndex + 1], {
						center = center,
						width = math.min(math.max(style.exteriorDoorWidthStuds, style.interiorDoorWidthStuds), bayLength * 0.42),
						doorHeight = math.min(style.exteriorDoorHeightStuds, wallHeight - 1.4),
					})
					roomNumber += 1
					local roomType = getRoomType(buildingStyle, floorIndex, bayIndex)
					local room = Instance.new("Model")
					room.Name = string.format("F%02d_%s_%02d", floorIndex + 1, if roomType == "classroom" then "Classroom" else roomType, roomNumber)
					room:SetAttribute("RoomType", roomType)
					room:SetAttribute("FloorIndex", floorIndex + 1)
					room:SetAttribute("RoomNumber", roomNumber)
					room:SetAttribute("EstimatedRoomBoundsStuds", Vector3.new(wingDepth, wallHeight, bayLength))
					room.Parent = furnishings
					local roomCenterX = sign * wingCenterX
					local furnitureAdded = furnitureGenerator.BuildRoom(room, layoutFrame, roomType, sign, roomCenterX, center, bayLength, wingDepth, baseY, buildingStyle)
					room:SetAttribute("FurniturePartCount", furnitureAdded)
					furniturePartCount += furnitureAdded
					roomsBuilt += 1
					if roomType == "classroom" then
						floorRoomCount += 1
						classroomCount += 1
				end
				end
			end
		end
		table.insert(classroomsPerFloor, floorRoomCount)

		local longLightCount = math.clamp(math.ceil(layoutLength / 130), 1, 3)
		for lightIndex = 1, longLightCount do
			local z = -layoutLength * 0.5 + outerThickness + (layoutLength - outerThickness * 2) * (lightIndex - 0.5) / longLightCount
			local fixture = Instance.new("Part")
			fixture.Name = string.format("HallLight_F%02d_%02d", floorIndex + 1, lightIndex)
			fixture.Anchored = true
			fixture.CanCollide = false
			fixture.CanTouch = false
			fixture.CanQuery = false
			fixture.CastShadow = false
			fixture.Material = Enum.Material.Neon
			fixture.Color = buildingStyle.lightColor3
			fixture.Size = Vector3.new(1.4, 0.18, 3.2)
			fixture.CFrame = layoutFrame * CFrame.new(0, floorIndex * floorHeight + floorHeight - 0.5, z)
			fixture.Parent = structure
			local light = Instance.new("PointLight")
			light.Name = "HallGlow"
			light.Color = buildingStyle.lightColor3
			light.Brightness = 0.65
			light.Range = 22
			light.Shadows = false
			light.Parent = fixture
			lightCount += 1
		end
	end

	return {
		RoomCount = roomsBuilt,
		ClassroomCount = classroomCount,
		ClassroomsPerFloor = classroomsPerFloor,
		CorridorWidthStuds = corridorWidth,
		CorridorAxis = if rotated then "world_x_estimated" else "world_z_estimated",
		HallLightCount = lightCount,
		RoomNumberCount = roomNumber,
		GalleryDoorCentersBySide = galleryDoorsBySide,
		StairSide = stairSide,
		LayoutFrame = layoutFrame,
		LayoutWidth = layoutWidth,
		LayoutLength = layoutLength,
		WingCenterX = wingCenterX,
		WingDepth = wingDepth,
		BayCount = bayCount,
		BayLength = bayLength,
		FurnitureParts = furniturePartCount,
	}
end

return table.freeze(ClassroomLayoutGenerator)
