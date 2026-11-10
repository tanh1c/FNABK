--!strict
-- Builds walkable floor slabs, connected stairs, a central hall, bounded rooms and collision.
local WalkableInteriorGenerator = {}
local classroomLayoutGenerator = require(script.Parent:WaitForChild("ClassroomLayoutGenerator"))
local exteriorGalleryGenerator = require(script.Parent:WaitForChild("ExteriorGalleryGenerator"))

local CONCRETE = Color3.fromRGB(124, 129, 129)
local ENTRY_TRIM = Color3.fromRGB(74, 111, 127)

local function makeFolder(parent: Instance, name: string): Folder
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function makeBox(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string,
	collidable: boolean
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = collidable
	part.CanTouch = false
	part.CanQuery = collidable
	part.CastShadow = true
	part.Material = material
	part.Color = color
	part.Size = size
	part.CFrame = cframe
	part:SetAttribute("InteriorGeometryRole", role)
	part.Parent = parent
	return part
end

local function addFloorRect(parent: Instance, frame: CFrame, name: string, x: number, sizeX: number, z: number, sizeZ: number, y: number, thickness: number, color: Color3)
	if sizeX < 2 or sizeZ < 2 then
		return
	end
	makeBox(parent, name, Vector3.new(sizeX, thickness, sizeZ), frame * CFrame.new(x, y, z), color, Enum.Material.Concrete, "WalkableFloor", true)
end

local function createFloor(
	parent: Instance,
	frame: CFrame,
	width: number,
	depth: number,
	floorIndex: number,
	floorHeight: number,
	style: { [string]: any },
	stairX: number,
	stairCenterZ: number,
	stairRun: number
)
	local thickness = style.floorSlabThicknessStuds
	local centerY = floorIndex * floorHeight + thickness * 0.5
	local floorTag = string.format("WalkableFloor_%02d", floorIndex + 1)
	if floorIndex == 0 then
		addFloorRect(parent, frame, floorTag, 0, width, 0, depth, centerY, thickness, style.floorColor3)
		return
	end

	local holeWidth = math.min(width - 4, style.stairWidthStuds + 1.4)
	local holeDepth = math.min(depth - 4, stairRun + 2.0)
	local holeLeft = stairX - holeWidth * 0.5
	local holeRight = stairX + holeWidth * 0.5
	local holeFront = stairCenterZ - holeDepth * 0.5
	local holeBack = stairCenterZ + holeDepth * 0.5
	local leftWidth = holeLeft + width * 0.5
	local rightWidth = width * 0.5 - holeRight
	addFloorRect(parent, frame, floorTag .. "_West", -width * 0.5 + leftWidth * 0.5, leftWidth, 0, depth, centerY, thickness, style.floorColor3)
	addFloorRect(parent, frame, floorTag .. "_East", holeRight + rightWidth * 0.5, rightWidth, 0, depth, centerY, thickness, style.floorColor3)
	local southDepth = holeFront + depth * 0.5
	local northDepth = depth * 0.5 - holeBack
	addFloorRect(parent, frame, floorTag .. "_South", stairX, holeWidth, -depth * 0.5 + southDepth * 0.5, southDepth, centerY, thickness, style.floorColor3)
	addFloorRect(parent, frame, floorTag .. "_North", stairX, holeWidth, holeBack + northDepth * 0.5, northDepth, centerY, thickness, style.floorColor3)
end

local function createFrontWall(parent: Instance, frame: CFrame, width: number, depth: number, floorIndex: number, floorHeight: number, style: { [string]: any }, buildingStyle: { [string]: any }, storyCount: number)
	local thickness = style.outerWallThicknessStuds
	local bottom = floorIndex * floorHeight + style.floorSlabThicknessStuds
	local wallHeight = floorHeight - style.floorSlabThicknessStuds
	local centerY = bottom + wallHeight * 0.5
	local zFront = -depth * 0.5 + thickness * 0.5
	local doorWidth = math.min(style.exteriorDoorWidthStuds, width * 0.3)
	local doorHeight = math.min(style.exteriorDoorHeightStuds, wallHeight - 1.4)
	local openingWidth = if floorIndex == 0 then doorWidth else 0
	local openingHeight = if openingWidth > 0 then math.min(doorHeight, wallHeight - 0.8) else 0
	local wallColor = buildingStyle.wallColor3
	if openingWidth <= 0 then
		makeBox(parent, string.format("OuterWall_Floor_%02d_South", floorIndex + 1), Vector3.new(width, wallHeight, thickness), frame * CFrame.new(0, centerY, zFront), wallColor, Enum.Material.Concrete, "ExteriorWall", true)
		return
	end
	local sideWidth = (width - openingWidth) * 0.5
	makeBox(parent, string.format("OuterWall_Floor_%02d_South_West", floorIndex + 1), Vector3.new(sideWidth, wallHeight, thickness), frame * CFrame.new(-openingWidth * 0.5 - sideWidth * 0.5, centerY, zFront), wallColor, Enum.Material.Concrete, "ExteriorWall", true)
	makeBox(parent, string.format("OuterWall_Floor_%02d_South_East", floorIndex + 1), Vector3.new(sideWidth, wallHeight, thickness), frame * CFrame.new(openingWidth * 0.5 + sideWidth * 0.5, centerY, zFront), wallColor, Enum.Material.Concrete, "ExteriorWall", true)
	if wallHeight > openingHeight then
		local lintelHeight = wallHeight - openingHeight
		makeBox(parent, string.format("OuterWall_Floor_%02d_South_Lintel", floorIndex + 1), Vector3.new(openingWidth, lintelHeight, thickness), frame * CFrame.new(0, bottom + openingHeight + lintelHeight * 0.5, zFront), wallColor, Enum.Material.Concrete, "ExteriorWall", true)
	end
end

local function hasGallerySide(buildingStyle: { [string]: any }, side: number): boolean
	local layout = buildingStyle.galleryLayout or "single"
	return side == 1 or layout == "double" or layout == "wrap"
end

local function createOuterWalls(parent: Instance, frame: CFrame, width: number, depth: number, floorIndex: number, floorHeight: number, style: { [string]: any }, buildingStyle: { [string]: any }, storyCount: number)
	local thickness = style.outerWallThicknessStuds
	local bottom = floorIndex * floorHeight + style.floorSlabThicknessStuds
	local wallHeight = floorHeight - style.floorSlabThicknessStuds
	local centerY = bottom + wallHeight * 0.5
	local rotated = width > depth * 1.15
	if not (rotated and hasGallerySide(buildingStyle, 1)) then
		createFrontWall(parent, frame, width, depth, floorIndex, floorHeight, style, buildingStyle, storyCount)
	end
	if not (rotated and hasGallerySide(buildingStyle, -1)) then
		makeBox(parent, string.format("OuterWall_Floor_%02d_North", floorIndex + 1), Vector3.new(width, wallHeight, thickness), frame * CFrame.new(0, centerY, depth * 0.5 - thickness * 0.5), buildingStyle.wallColor3, Enum.Material.Concrete, "ExteriorWall", true)
	end
	if rotated or not hasGallerySide(buildingStyle, -1) then
		makeBox(parent, string.format("OuterWall_Floor_%02d_West", floorIndex + 1), Vector3.new(thickness, wallHeight, depth - thickness * 2), frame * CFrame.new(-width * 0.5 + thickness * 0.5, centerY, 0), buildingStyle.wallColor3, Enum.Material.Concrete, "ExteriorWall", true)
	end
	if rotated or not hasGallerySide(buildingStyle, 1) then
		makeBox(parent, string.format("OuterWall_Floor_%02d_East", floorIndex + 1), Vector3.new(thickness, wallHeight, depth - thickness * 2), frame * CFrame.new(width * 0.5 - thickness * 0.5, centerY, 0), buildingStyle.wallColor3, Enum.Material.Concrete, "ExteriorWall", true)
	end
end

local function createInteriorFrame(frame: CFrame, width: number, depth: number): (CFrame, number, number, number)
	if width > depth * 1.15 then
		return frame * CFrame.Angles(0, math.pi * 0.5, 0), depth, width, 1
	end
	return frame, width, depth, 0
end

local function createStaircase(
	parent: Instance,
	frame: CFrame,
	buildingId: string,
	width: number,
	floorIndex: number,
	floorHeight: number,
	style: { [string]: any },
	stairX: number,
	stairCenterZ: number,
	stairRun: number,
	buildingStyle: { [string]: any }
)
	local stairWidth = math.min(style.stairWidthStuds, width * 0.16)
	local stepCount = math.max(10, math.ceil(floorHeight / style.stairRiserTargetStuds))
	local riser = floorHeight / stepCount
	local tread = stairRun / stepCount
	local startZ = stairCenterZ - stairRun * 0.5
	local floorY = floorIndex * floorHeight + style.floorSlabThicknessStuds
	local slope = math.atan2(floorHeight, stairRun)
	for stepIndex = 1, stepCount do
		local stepHeight = riser * stepIndex
		local z = startZ + (stepIndex - 0.5) * tread
		makeBox(parent, string.format("%s_Stair_Floor_%02d_Step_%02d", buildingId, floorIndex + 1, stepIndex), Vector3.new(stairWidth, stepHeight, tread + 0.04), frame * CFrame.new(stairX, floorY + stepHeight * 0.5, z), CONCRETE:Lerp(buildingStyle.trimColor3, 0.08), Enum.Material.Concrete, "StairTread", true)
	end

	local railCenterY = floorY + floorHeight * 0.5 + 2.0
	for _, side in ipairs({ -1, 1 }) do
		local railX = stairX + side * (stairWidth * 0.5 + 0.35)
		makeBox(parent, string.format("%s_Stair_Floor_%02d_Rail_%s", buildingId, floorIndex + 1, if side < 0 then "West" else "East"), Vector3.new(0.26, 0.26, stairRun + 0.6), frame * CFrame.new(railX, railCenterY, stairCenterZ) * CFrame.Angles(-slope, 0, 0), buildingStyle.accentColor3, Enum.Material.Metal, "StairHandrail", true)
		for postIndex = 1, 2 do
			local postZ = startZ + stairRun * postIndex / 3
			local progress = (postZ - startZ) / stairRun
			local postBaseY = floorY + floorHeight * progress
			makeBox(parent, string.format("%s_Stair_Floor_%02d_RailPost_%s_%02d", buildingId, floorIndex + 1, if side < 0 then "West" else "East", postIndex), Vector3.new(0.22, 2.0, 0.22), frame * CFrame.new(railX, postBaseY + 1.0, postZ), buildingStyle.accentColor3, Enum.Material.Metal, "StairHandrail", true)
		end
	end
end

function WalkableInteriorGenerator.Build(
	parent: Instance,
	frame: CFrame,
	spec: { [string]: any },
	width: number,
	depth: number,
	floorHeight: number,
	floorCount: number,
	style: { [string]: any },
	buildingStyle: { [string]: any }
): { [string]: any }
	local structureFolder = makeFolder(parent, "WalkableStructure")
	local stairFolder = makeFolder(parent, "StairsAndLandings")
	local entryFolder = makeFolder(parent, "Entrance")
	local furnitureFolder = makeFolder(parent, "Furnishings")
	local interiorStyle = table.clone(style)
	interiorStyle.floorColor3 = buildingStyle.floorColor3
	local layoutFrame, layoutWidth, layoutLength, yawState = createInteriorFrame(frame, width, depth)
	local thickness = style.outerWallThicknessStuds
	local stairWidth = math.min(style.stairWidthStuds, layoutWidth * 0.16)
	local corridorWidth = math.min(style.corridorWidthStuds, layoutWidth * 0.28)
	local usableHalfWidth = layoutWidth * 0.5 - thickness
	local corridorWallX = corridorWidth * 0.5 + style.interiorWallThicknessStuds * 0.5
	local wingDepth = usableHalfWidth - corridorWallX - style.interiorWallThicknessStuds * 0.5
	local doorLocal = layoutFrame:PointToObjectSpace((frame * CFrame.new(0, 0, -depth * 0.5)).Position)
	local entrySide = if doorLocal.X < 0 then -1 else 1
	local stairSide = -entrySide
	local stairX = stairSide * (corridorWallX + style.interiorWallThicknessStuds * 0.5 + wingDepth * 0.5)
	local stepsPerFlight = math.max(10, math.ceil(floorHeight / style.stairRiserTargetStuds))
	local maxRun = math.max(12, layoutLength - thickness * 2 - 6)
	local stairRun = math.min(stepsPerFlight * style.stairTreadDepthStuds, maxRun * 0.55)
	local stairCenterZ = layoutLength * 0.5 - thickness - stairRun * 0.5 - 2
	local doorWidth = math.min(style.exteriorDoorWidthStuds, width * 0.3)
	local doorHeight = math.min(style.exteriorDoorHeightStuds, floorHeight - thickness - 1.4)
	local corridorFloorY = style.floorSlabThicknessStuds + 0.025

	for floorIndex = 0, floorCount - 1 do
		createFloor(structureFolder, layoutFrame, layoutWidth, layoutLength, floorIndex, floorHeight, interiorStyle, stairX, stairCenterZ, stairRun)
		createOuterWalls(structureFolder, frame, width, depth, floorIndex, floorHeight, style, buildingStyle, floorCount)
		if floorIndex < floorCount - 1 then
			createStaircase(stairFolder, layoutFrame, spec.id, layoutWidth, floorIndex, floorHeight, style, stairX, stairCenterZ, stairRun, buildingStyle)
		end
		makeBox(structureFolder, string.format("HallRunner_Floor_%02d", floorIndex + 1), Vector3.new(corridorWidth - 1.2, 0.08, layoutLength - thickness * 2 - 1), layoutFrame * CFrame.new(0, corridorFloorY, 0), buildingStyle.corridorColor3, Enum.Material.SmoothPlastic, "CorridorFloor", false)
	end

	local roofBaseY = floorHeight * floorCount + style.floorSlabThicknessStuds * 0.5
	makeBox(structureFolder, "WalkableRoofCap", Vector3.new(width + 1, style.floorSlabThicknessStuds, depth + 1), frame * CFrame.new(0, roofBaseY, 0), buildingStyle.trimColor3, Enum.Material.Concrete, "WalkableRoof", true)

	local frontZ = -depth * 0.5 - 0.22
	local entryBaseY = style.floorSlabThicknessStuds
	for _, side in ipairs({ -1, 1 }) do
		makeBox(entryFolder, if side < 0 then "EntryFrame_West" else "EntryFrame_East", Vector3.new(0.38, doorHeight, 0.38), frame * CFrame.new(side * (doorWidth * 0.5), entryBaseY + doorHeight * 0.5, frontZ), buildingStyle.accentColor3, Enum.Material.SmoothPlastic, "EntranceTrim", false)
	end
	makeBox(entryFolder, "EntryFrame_Header", Vector3.new(doorWidth + 0.38, 0.38, 0.38), frame * CFrame.new(0, entryBaseY + doorHeight + 0.2, frontZ), buildingStyle.accentColor3, Enum.Material.SmoothPlastic, "EntranceTrim", false)
	makeBox(entryFolder, "EntryApron", Vector3.new(doorWidth + 4, 0.35, 3.5), frame * CFrame.new(0, 0.42, -depth * 0.5 - 1.8), buildingStyle.floorColor3, Enum.Material.Concrete, "EntranceApron", true)

	local roomLayout = classroomLayoutGenerator.Build(structureFolder, furnitureFolder, frame, spec, width, depth, floorHeight, floorCount, style, buildingStyle, stairX, stairCenterZ, stairRun)
	local gallery = exteriorGalleryGenerator.Build(
		structureFolder,
		layoutFrame,
		layoutWidth,
		layoutLength,
		floorHeight,
		floorCount,
		style,
		buildingStyle,
		roomLayout.GalleryDoorCentersBySide
	)
	return {
		StairFlights = math.max(0, floorCount - 1),
		StepsPerFlight = stepsPerFlight,
		FurnitureParts = roomLayout.FurnitureParts,
		DoorWidthStuds = doorWidth,
		DoorHeightStuds = doorHeight,
		StairRunStuds = stairRun,
		StairCenterZ = stairCenterZ,
		StairCenterX = stairX,
		ClassroomCount = roomLayout.ClassroomCount,
		RoomCount = roomLayout.RoomCount,
		ClassroomsPerFloor = roomLayout.ClassroomsPerFloor,
		CorridorWidthStuds = roomLayout.CorridorWidthStuds,
		CorridorAxis = roomLayout.CorridorAxis,
		HallLightCount = roomLayout.HallLightCount,
		GalleryCount = gallery.GalleryCount,
		GalleryDeckCount = gallery.GalleryDeckCount,
		GalleryDoorCount = gallery.GalleryDoorCount,
		GalleryLightCount = gallery.GalleryLightCount,
		GalleryWidthStuds = gallery.GalleryWidthStuds,
		GalleryLayout = gallery.GalleryLayout,
		InteriorYawDegrees = yawState * 90,
	}
end

return table.freeze(WalkableInteriorGenerator)
