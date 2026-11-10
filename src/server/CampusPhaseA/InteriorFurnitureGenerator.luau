--!strict
-- Compact furniture sets make each bounded classroom, lab, library or service room readable.
local InteriorFurnitureGenerator = {}

local DARK_WOOD = Color3.fromRGB(77, 65, 54)
local METAL = Color3.fromRGB(91, 103, 107)

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string,
	collidable: boolean?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = collidable ~= false
	part.CanTouch = false
	part.CanQuery = collidable ~= false
	part.CastShadow = true
	part.Material = material
	part.Color = color
	part.Size = size
	part.CFrame = cframe
	part:SetAttribute("InteriorGeometryRole", role)
	part.Parent = parent
	return part
end

local function makeClassroom(parent: Instance, frame: CFrame, side: number, x: number, z: number, floorY: number, bayLength: number, wingDepth: number, style: { [string]: any }): number
	local tableCount = 2
	local studentDeskWidth = math.min(5.4, wingDepth * 0.3)
	local deskDepth = math.min(3.2, bayLength * 0.2)
	local deskX = x + side * math.min(2.0, wingDepth * 0.12)
	for index = 1, tableCount do
		local zOffset = (index - 1.5) * math.min(9, bayLength * 0.24)
		makePart(parent, "StudentDesk_" .. index, Vector3.new(studentDeskWidth, 2.45, deskDepth), frame * CFrame.new(deskX, floorY + 1.45, z + zOffset), style.trimColor3, Enum.Material.Wood, "Furniture")
		local benchX = deskX - side * (studentDeskWidth * 0.5 + 1.45)
		makePart(parent, "StudentBench_" .. index, Vector3.new(2.5, 1.2, deskDepth), frame * CFrame.new(benchX, floorY + 0.7, z + zOffset), METAL, Enum.Material.Wood, "Furniture")
	end
	makePart(parent, "TeacherDesk", Vector3.new(5.6, 2.2, 3.2), frame * CFrame.new(x + side * wingDepth * 0.18, floorY + 1.25, z + bayLength * 0.32), DARK_WOOD, Enum.Material.Wood, "Furniture")
	makePart(parent, "Whiteboard", Vector3.new(0.18, 2.3, math.min(7, bayLength * 0.35)), frame * CFrame.new(x + side * (wingDepth * 0.5 - 0.8), floorY + 6.1, z - bayLength * 0.3), Color3.fromRGB(230, 234, 225), Enum.Material.SmoothPlastic, "Furniture", false)
	makePart(parent, "WhiteboardTrim", Vector3.new(0.25, 0.18, math.min(7.4, bayLength * 0.37)), frame * CFrame.new(x + side * (wingDepth * 0.5 - 0.72), floorY + 4.85, z - bayLength * 0.3), style.accentColor3, Enum.Material.Metal, "Furniture", false)
	return 7
end

local function makeLibrary(parent: Instance, frame: CFrame, side: number, x: number, z: number, floorY: number, bayLength: number, wingDepth: number, style: { [string]: any }): number
	local shelfX = x + side * (wingDepth * 0.32)
	for index = 1, 2 do
		local shelfZ = z + (index - 1.5) * math.min(10, bayLength * 0.24)
		makePart(parent, "Bookcase_" .. index .. "_Frame", Vector3.new(1, 6, math.min(8, bayLength * 0.32)), frame * CFrame.new(shelfX, floorY + 3.3, shelfZ), DARK_WOOD, Enum.Material.Wood, "Furniture")
		for level = 1, 3 do
			makePart(parent, string.format("Bookcase_%d_Shelf_%d", index, level), Vector3.new(2.8, 0.25, math.min(8, bayLength * 0.32)), frame * CFrame.new(shelfX - side * 0.45, floorY + 1.55 + level * 1.3, shelfZ), style.trimColor3, Enum.Material.Wood, "Furniture")
		end
	end
	makePart(parent, "ReadingTable", Vector3.new(math.min(8, wingDepth * 0.48), 0.65, math.min(5, bayLength * 0.22)), frame * CFrame.new(x - side * 1.4, floorY + 2.5, z), style.trimColor3, Enum.Material.Wood, "Furniture")
	for index = 1, 2 do
		makePart(parent, "ReadingChair_" .. index, Vector3.new(1.8, 1.55, 1.8), frame * CFrame.new(x - side * 1.4, floorY + 1.3, z + (index - 1.5) * 4.5), METAL, Enum.Material.Metal, "Furniture")
	end
	return 11
end

local function makeLaboratory(parent: Instance, frame: CFrame, side: number, x: number, z: number, floorY: number, bayLength: number, wingDepth: number, style: { [string]: any }): number
	local benchWidth = math.min(7.2, wingDepth * 0.42)
	for index = 1, 2 do
		local benchZ = z + (index - 1.5) * math.min(10, bayLength * 0.22)
		makePart(parent, "LabBench_" .. index, Vector3.new(benchWidth, 0.75, math.min(4.2, bayLength * 0.18)), frame * CFrame.new(x, floorY + 2.7, benchZ), style.accentColor3, Enum.Material.SmoothPlastic, "Furniture")
		makePart(parent, "LabInstrument_" .. index, Vector3.new(2.8, 1.4, 1.7), frame * CFrame.new(x + side * 1.4, floorY + 3.75, benchZ), METAL, Enum.Material.Metal, "Furniture")
		makePart(parent, "LabStool_" .. index, Vector3.new(2, 1.25, 2), frame * CFrame.new(x - side * math.min(5, wingDepth * 0.3), floorY + 0.65, benchZ), METAL, Enum.Material.Metal, "Furniture")
	end
	makePart(parent, "SafetyCabinet", Vector3.new(3.2, 5.5, 2.4), frame * CFrame.new(x + side * (wingDepth * 0.36), floorY + 2.95, z + bayLength * 0.33), Color3.fromRGB(194, 205, 187), Enum.Material.Metal, "Furniture")
	return 7
end

local function makeTechnical(parent: Instance, frame: CFrame, side: number, x: number, z: number, floorY: number, bayLength: number, wingDepth: number, style: { [string]: any }): number
	for index = 1, 2 do
		local zOffset = (index - 1.5) * math.min(10, bayLength * 0.22)
		makePart(parent, "EquipmentCabinet_" .. index, Vector3.new(math.min(7, wingDepth * 0.42), 5.2, 4.2), frame * CFrame.new(x + side * 1.5, floorY + 2.8, z + zOffset), Color3.fromRGB(113, 119, 109), Enum.Material.Metal, "Furniture")
		makePart(parent, "ControlPanel_" .. index, Vector3.new(4.6, 1.4, 0.4), frame * CFrame.new(x + side * 1.5, floorY + 5.1, z + zOffset - side * 2.25), style.accentColor3, Enum.Material.Metal, "Furniture")
	end
	return 4
end

local function makeStorage(parent: Instance, frame: CFrame, side: number, x: number, z: number, floorY: number, bayLength: number, wingDepth: number, style: { [string]: any }): number
	for index = 1, 2 do
		local zOffset = (index - 1.5) * math.min(9, bayLength * 0.22)
		makePart(parent, "StorageRack_" .. index .. "_Back", Vector3.new(0.35, 6.2, math.min(8, bayLength * 0.3)), frame * CFrame.new(x + side * wingDepth * 0.3, floorY + 3.2, z + zOffset), METAL, Enum.Material.Metal, "Furniture")
		for level = 1, 3 do
			makePart(parent, string.format("StorageRack_%d_Shelf_%d", index, level), Vector3.new(3.2, 0.32, math.min(8, bayLength * 0.3)), frame * CFrame.new(x + side * (wingDepth * 0.3 - 0.55), floorY + 1.35 + level * 1.45, z + zOffset), style.trimColor3, Enum.Material.Metal, "Furniture")
		end
	end
	return 8
end

function InteriorFurnitureGenerator.BuildRoom(
	parent: Instance,
	frame: CFrame,
	roomType: string,
	side: number,
	x: number,
	z: number,
	bayLength: number,
	wingDepth: number,
	floorY: number,
	style: { [string]: any }
): number
	if roomType == "library" or roomType == "study" then
		return makeLibrary(parent, frame, side, x, z, floorY, bayLength, wingDepth, style)
	elseif roomType == "laboratory" then
		return makeLaboratory(parent, frame, side, x, z, floorY, bayLength, wingDepth, style)
	elseif roomType == "generator" or roomType == "technical" then
		return makeTechnical(parent, frame, side, x, z, floorY, bayLength, wingDepth, style)
	elseif roomType == "storage" or roomType == "service" then
		return makeStorage(parent, frame, side, x, z, floorY, bayLength, wingDepth, style)
	end
	return makeClassroom(parent, frame, side, x, z, floorY, bayLength, wingDepth, style)
end

return table.freeze(InteriorFurnitureGenerator)
