--!strict
-- Runtime-generated objective anchors; campus Marketplace details live in separate source modules.
local RunService = game:GetService("RunService")

local GrayboxMap = {}

local MAP_NAME = "FNABKGraybox"
local MIMIC_NAME = "Mimic"
local STUDENT_NAME = "Student"

local COLORS = {
	Floor = Color3.fromRGB(64, 76, 88),
	Wall = Color3.fromRGB(112, 122, 130),
	Spawn = Color3.fromRGB(29, 144, 127),
	A3 = Color3.fromRGB(198, 149, 75),
	Library = Color3.fromRGB(96, 126, 153),
	B4 = Color3.fromRGB(110, 138, 119),
	Mimic = Color3.fromRGB(78, 88, 98),
}

local function addBlock(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.Concrete
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CastShadow = false
	part.Parent = parent
	return part
end

local function addMimicPart(
	parent: Instance,
	name: string,
	size: Vector3,
	localPosition: Vector3,
	color: Color3,
	material: Enum.Material?
): Part
	local part = addBlock(parent, name, size, localPosition, color, material)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = name ~= "Root"
	return part
end

local function addStudioDebugLabel(
	model: Model,
	adornee: BasePart,
	title: string,
	textColor: Color3,
	getDetails: () -> string
)
	-- Keep identity labels out of published servers so they cannot reveal the Mimic to players.
	if not RunService:IsStudio() then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "FNABKStudioDebugLabel"
	billboard.Adornee = adornee
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 150
	billboard.Size = UDim2.fromOffset(190, 58)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 1.3, 0)
	billboard.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(16, 25, 36)
	label.BackgroundTransparency = 0.12
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = textColor
	label.TextScaled = true
	label.TextWrapped = true
	label.TextStrokeTransparency = 0.75
	label.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = label

	local function refresh()
		label.Text = title .. "\n" .. getDetails()
	end
	refresh()
	model:GetAttributeChangedSignal("MimicState"):Connect(refresh)
	model:GetAttributeChangedSignal("MimicHealth"):Connect(refresh)
	model:GetAttributeChangedSignal("StudentState"):Connect(refresh)
	model:GetAttributeChangedSignal("SurvivorHealth"):Connect(refresh)
end

local function createMimic(
	parent: Instance,
	maximumHealth: number,
	name: string?,
	position: Vector3?
): Model
	local mimic = Instance.new("Model")
	mimic.Name = name or MIMIC_NAME

	local root = addMimicPart(
		mimic,
		"Root",
		Vector3.new(2, 5, 2),
		Vector3.zero,
		COLORS.Mimic
	)
	root.Transparency = 1

	addMimicPart(mimic, "Torso", Vector3.new(2.4, 3.2, 1.5), Vector3.zero, COLORS.Mimic)
	local head = addMimicPart(mimic, "Head", Vector3.new(1.9, 1.9, 1.9), Vector3.new(0, 2.35, 0), COLORS.Mimic)
	addMimicPart(mimic, "LeftArm", Vector3.new(0.7, 3.2, 0.7), Vector3.new(-1.55, -0.2, 0), COLORS.Mimic)
	addMimicPart(mimic, "RightArm", Vector3.new(0.7, 3.2, 0.7), Vector3.new(1.55, -0.2, 0), COLORS.Mimic)
	addMimicPart(mimic, "LeftLeg", Vector3.new(0.85, 2.2, 0.9), Vector3.new(-0.55, -1.55, 0), COLORS.Mimic)
	addMimicPart(mimic, "RightLeg", Vector3.new(0.85, 2.2, 0.9), Vector3.new(0.55, -1.55, 0), COLORS.Mimic)
	addMimicPart(
		mimic,
		"LeftEye",
		Vector3.new(0.32, 0.32, 0.16),
		Vector3.new(-0.42, 2.4, -0.98),
		Color3.fromRGB(232, 96, 78),
		Enum.Material.Neon
	)
	addMimicPart(
		mimic,
		"RightEye",
		Vector3.new(0.32, 0.32, 0.16),
		Vector3.new(0.42, 2.4, -0.98),
		Color3.fromRGB(232, 96, 78),
		Enum.Material.Neon
	)

	mimic.PrimaryPart = root
	mimic:SetAttribute("NPCType", "Mimic")
	mimic:SetAttribute("MimicState", "Disguise")
	mimic:SetAttribute("MimicHealth", maximumHealth)
	mimic.Parent = parent
	local spawnPosition = position or Vector3.new(8, 2.5, 0)
	mimic:PivotTo(CFrame.lookAt(spawnPosition, spawnPosition + Vector3.new(-1, 0, 0)))
	addStudioDebugLabel(mimic, head, "MIMIC", Color3.fromRGB(255, 135, 112), function(): string
		local state = string.upper(tostring(mimic:GetAttribute("MimicState") or "UNKNOWN"))
		local health = mimic:GetAttribute("MimicHealth")
		local healthText = if typeof(health) == "number" then string.format("%d HP", math.floor(health)) else "? HP"
		return state .. " | " .. healthText
	end)
	return mimic
end

local function createStudent(parent: Instance, name: string?, position: Vector3?): Model
	local student = Instance.new("Model")
	student.Name = name or STUDENT_NAME

	local root = addMimicPart(student, "Root", Vector3.new(2, 5, 2), Vector3.zero, COLORS.Library)
	root.CanQuery = false
	addMimicPart(student, "Torso", Vector3.new(2.2, 3.1, 1.4), Vector3.zero, COLORS.Library)
	local head = addMimicPart(student, "Head", Vector3.new(1.7, 1.7, 1.7), Vector3.new(0, 2.3, 0), Color3.fromRGB(195, 166, 137))
	addMimicPart(student, "LeftArm", Vector3.new(0.65, 3, 0.65), Vector3.new(-1.4, -0.15, 0), COLORS.Library)
	addMimicPart(student, "RightArm", Vector3.new(0.65, 3, 0.65), Vector3.new(1.4, -0.15, 0), COLORS.Library)
	addMimicPart(student, "LeftLeg", Vector3.new(0.8, 2, 0.8), Vector3.new(-0.5, -1.55, 0), Color3.fromRGB(44, 57, 76))
	addMimicPart(student, "RightLeg", Vector3.new(0.8, 2, 0.8), Vector3.new(0.5, -1.55, 0), Color3.fromRGB(44, 57, 76))

	student.PrimaryPart = root
	student:SetAttribute("NPCType", "Student")
	student:SetAttribute("StudentState", "Idle")
	student:SetAttribute("SurvivorMaxHealth", 100)
	student:SetAttribute("SurvivorHealth", 100)
	student.Parent = parent
	student:PivotTo(CFrame.new(position or Vector3.new(-28, 2.5, 8)))
	addStudioDebugLabel(student, head, "STUDENT", Color3.fromRGB(116, 224, 206), function(): string
		return string.upper(tostring(student:GetAttribute("StudentState") or "UNKNOWN")) .. " | HP " .. tostring(student:GetAttribute("SurvivorHealth") or 100)
	end)
	return student
end

local function ensureLibrarySuspects(map: Folder, mimicMaximumHealth: number)
	local library = map:FindFirstChild("Library")
	if library then
		assert(library:IsA("Folder"), "Library must be a Folder")
	else
		library = Instance.new("Folder")
		library.Name = "Library"
		library.Parent = map
	end

	local suspects = library:FindFirstChild("Suspects")
	if suspects then
		assert(suspects:IsA("Folder"), "Library/Suspects must be a Folder")
	else
		suspects = Instance.new("Folder")
		suspects.Name = "Suspects"
		suspects.Parent = library
	end

	local suspectFolder = suspects :: Folder
	local studentA = suspectFolder:FindFirstChild("LibraryStudentA")
	if studentA then
		assert(studentA:IsA("Model"), "LibraryStudentA must be a Model")
	else
		studentA = createStudent(suspectFolder, "LibraryStudentA", Vector3.new(8, 2.5, 16))
	end
	studentA:SetAttribute("LibrarySuspectId", "StudentA")

	local mimic = suspectFolder:FindFirstChild("LibraryMimic")
	if mimic then
		assert(mimic:IsA("Model"), "LibraryMimic must be a Model")
	else
		mimic = createMimic(suspectFolder, mimicMaximumHealth, "LibraryMimic", Vector3.new(15, 2.5, 16))
	end
	mimic:SetAttribute("LibrarySuspectId", "Mimic")

	local studentB = suspectFolder:FindFirstChild("LibraryStudentB")
	if studentB then
		assert(studentB:IsA("Model"), "LibraryStudentB must be a Model")
	else
		studentB = createStudent(suspectFolder, "LibraryStudentB", Vector3.new(22, 2.5, 16))
	end
	studentB:SetAttribute("LibrarySuspectId", "StudentB")
end

local function ensureB4Generator(map: Folder)
	local b4 = map:FindFirstChild("B4")
	if b4 then
		assert(b4:IsA("Folder"), "B4 must be a Folder")
	else
		b4 = Instance.new("Folder")
		b4.Name = "B4"
		b4.Parent = map
	end
	local b4Folder = b4 :: Folder

	local fuse = b4Folder:FindFirstChild("SpareFuse")
	if fuse then
		assert(fuse:IsA("Part"), "B4/SpareFuse must be a Part")
	else
		fuse = addBlock(
			b4Folder,
			"SpareFuse",
			Vector3.new(1.2, 0.7, 1.2),
			Vector3.new(30, 0.35, -25),
			Color3.fromRGB(224, 190, 105),
			Enum.Material.Metal
		)
	end
	(fuse :: Part).CanCollide = false

	local generator = b4Folder:FindFirstChild("Generator")
	if generator then
		assert(generator:IsA("Part"), "B4/Generator must be a Part")
	else
		generator = addBlock(
			b4Folder,
			"Generator",
			Vector3.new(4, 5, 3),
			Vector3.new(45, 2.5, -25),
			COLORS.B4,
			Enum.Material.Metal
		)
	end

	local indicator = b4Folder:FindFirstChild("GeneratorIndicator")
	if indicator then
		assert(indicator:IsA("Part"), "B4/GeneratorIndicator must be a Part")
	else
		indicator = addBlock(
			b4Folder,
			"GeneratorIndicator",
			Vector3.new(0.7, 0.35, 0.15),
			Vector3.new(45, 4.1, -26.58),
			Color3.fromRGB(224, 88, 70),
			Enum.Material.Neon
		)
		indicator.CanCollide = false
	end
	indicator.Anchored = true
	indicator.CanCollide = false
	indicator.CanTouch = false
	indicator.CanQuery = false
end

local function ensureGateWallPart(
	map: Folder,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3
)
	local existing = map:FindFirstChild(name)
	if existing then
		assert(existing:IsA("Part"), name .. " must be a Part")
		local part = existing :: Part
		part.Anchored = true
		part.Size = size
		part.Position = position
		part.Color = color
		part.Transparency = 0
		part.CanCollide = true
		part.CanQuery = true
		return
	end

	addBlock(map, name, size, position, color)
end

local function ensureGate1(map: Folder)
	-- Replace the original solid east boundary with wall segments around a gate opening.
	local legacyWall = map:FindFirstChild("BoundaryEast")
	if legacyWall and legacyWall:IsA("BasePart") then
		legacyWall.Transparency = 1
		legacyWall.CanCollide = false
		legacyWall.CanQuery = false
	end
	ensureGateWallPart(map, "BoundaryEastNorth", Vector3.new(2, 12, 32), Vector3.new(60, 6, -24), COLORS.Wall)
	ensureGateWallPart(map, "BoundaryEastSouth", Vector3.new(2, 12, 32), Vector3.new(60, 6, 24), COLORS.Wall)

	local gate = map:FindFirstChild("Gate1")
	if gate then
		assert(gate:IsA("Folder"), "Gate1 must be a Folder")
	else
		gate = Instance.new("Folder")
		gate.Name = "Gate1"
		gate.Parent = map
	end
	local gateFolder = gate :: Folder

	local function ensureGatePart(
		name: string,
		size: Vector3,
		position: Vector3,
		color: Color3,
		material: Enum.Material
	): Part
		local existing = gateFolder:FindFirstChild(name)
		if existing then
			assert(existing:IsA("Part"), "Gate1/" .. name .. " must be a Part")
			local part = existing :: Part
			part.Anchored = true
			part.Size = size
			part.Position = position
			part.Color = color
			part.Material = material
			return part
		end
		return addBlock(gateFolder, name, size, position, color, material)
	end

	local gateColor = Color3.fromRGB(66, 80, 91)
	ensureGatePart("LeftPost", Vector3.new(2, 10, 1), Vector3.new(60, 5, -8.5), gateColor, Enum.Material.Metal)
	ensureGatePart("RightPost", Vector3.new(2, 10, 1), Vector3.new(60, 5, 8.5), gateColor, Enum.Material.Metal)
	ensureGatePart("TopBeam", Vector3.new(2, 1, 18), Vector3.new(60, 10.5, 0), gateColor, Enum.Material.Metal)
	local gateDoor = ensureGatePart(
		"GateDoor",
		Vector3.new(1, 10, 16),
		Vector3.new(60, 5, 0),
		Color3.fromRGB(126, 87, 63),
		Enum.Material.WoodPlanks
	)
	gateDoor.CanCollide = true
	gateDoor.CanQuery = true

	local controlPanel = ensureGatePart(
		"ControlPanel",
		Vector3.new(0.7, 2, 1),
		Vector3.new(56, 2, 0),
		Color3.fromRGB(184, 78, 65),
		Enum.Material.Metal
	)
	controlPanel.CanCollide = false
	controlPanel.CanTouch = false

	local walkway = ensureGatePart(
		"ExitWalkway",
		Vector3.new(18, 1, 22),
		Vector3.new(69, -0.5, 0),
		COLORS.Spawn,
		Enum.Material.Concrete
	)
	walkway.CanCollide = true

	local exitZone = ensureGatePart(
		"ExitZone",
		Vector3.new(12, 6, 12),
		Vector3.new(69, 3, 0),
		Color3.new(1, 1, 1),
		Enum.Material.SmoothPlastic
	)
	exitZone.Transparency = 1
	exitZone.CanCollide = false
	exitZone.CanTouch = false
	exitZone.CanQuery = false
end

local function addSpawn(parent: Instance)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlayerSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Size = Vector3.new(7, 0.2, 7)
	-- A01 places the spawn and locked Gate 1 in the courtyard hub.
	spawn.Position = Vector3.new(50, 0.1, 14)
	spawn.Color = COLORS.Spawn
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.CanTouch = false
	spawn.CanQuery = false
	spawn.CastShadow = false
	spawn.Parent = parent
	return spawn
end

local function ensureA3Puzzle(map: Folder)
	local a3 = map:FindFirstChild("A3")
	if a3 then
		assert(a3:IsA("Folder"), "A3 must be a Folder")
	else
		a3 = Instance.new("Folder")
		a3.Name = "A3"
		a3.Parent = map
	end

	local existingCrate = a3:FindFirstChild("FuseCrate")
	if existingCrate then
		assert(existingCrate:IsA("Part"), "A3/FuseCrate must be a Part")
	else
		local crate = Instance.new("Part")
		crate.Name = "FuseCrate"
		crate.Size = Vector3.new(4, 4, 4)
		crate.CFrame = CFrame.new(-34, 2, -13)
		crate.Color = COLORS.A3
		crate.Material = Enum.Material.WoodPlanks
		crate.Anchored = false
		crate.CanCollide = true
		crate.CanTouch = true
		crate.CanQuery = true
		crate.TopSurface = Enum.SurfaceType.Smooth
		crate.BottomSurface = Enum.SurfaceType.Smooth
		crate.CastShadow = false
		crate:SetAttribute("FNABKResetPosition", crate.Position)
		crate.Parent = a3
	end
	local crateInstance = a3:FindFirstChild("FuseCrate")
	assert(crateInstance and crateInstance:IsA("Part"), "A3/FuseCrate must be a Part")
	local crate = crateInstance :: Part
	crate.CanCollide = true
	-- Keep the physics-enabled crate light enough for a deliberate push interaction.
	crate.CustomPhysicalProperties = PhysicalProperties.new(0.3, 0.25, 0, 1, 1)

	local existingPlate = a3:FindFirstChild("PressurePlate")
	if existingPlate then
		assert(existingPlate:IsA("Part"), "A3/PressurePlate must be a Part")
	else
		local plate = addBlock(
			a3,
			"PressurePlate",
			Vector3.new(8, 0.04, 8),
			Vector3.new(-24, -0.015, -13),
			COLORS.A3,
			Enum.Material.Metal
		)
	end
	local plateInstance = a3:FindFirstChild("PressurePlate")
	assert(plateInstance and plateInstance:IsA("Part"), "A3/PressurePlate must be a Part")
	local plate = plateInstance :: Part
	plate.Size = Vector3.new(8, 0.04, 8)
	plate.Position = Vector3.new(-24, -0.015, -13)
	plate.Anchored = true
	-- The floor should carry the crate; this thin plate is a visual trigger area, not a step.
	plate.CanCollide = false
	plate.CanTouch = true

	map:SetAttribute("CrateResetBoundsMin", Vector3.new(-58, -10, -38))
	map:SetAttribute("CrateResetBoundsMax", Vector3.new(58, 30, 38))
end

function GrayboxMap.Build(workspaceRoot: Instance, mimicMaximumHealth: number): (Folder, Model, Model)
	local existing = workspaceRoot:FindFirstChild(MAP_NAME)
	if existing then
		assert(existing:GetAttribute("GeneratedByFNABK") == true, MAP_NAME .. " already exists and is not owned by this prototype")
		local existingMimic = existing:FindFirstChild(MIMIC_NAME)
		assert(existingMimic and existingMimic:IsA("Model"), "Existing graybox is missing its Mimic model")
		local existingStudent = existing:FindFirstChild(STUDENT_NAME)
		assert(existingStudent and existingStudent:IsA("Model"), "Existing graybox is missing its Student model")
		assert(existing:IsA("Folder"), MAP_NAME .. " must be a Folder")
		ensureA3Puzzle(existing)
		ensureLibrarySuspects(existing, mimicMaximumHealth)
		ensureB4Generator(existing)
		ensureGate1(existing)
		return existing, existingMimic, existingStudent
	end

	local map = Instance.new("Folder")
	map.Name = MAP_NAME
	map:SetAttribute("GeneratedByFNABK", true)
	map.Parent = workspaceRoot

	addBlock(map, "CourtyardFloor", Vector3.new(120, 1, 80), Vector3.new(0, -0.5, 0), COLORS.Floor, Enum.Material.Slate)
	addSpawn(map)

	-- A simple perimeter leaves enough room to test navigation around cover.
	addBlock(map, "BoundaryWest", Vector3.new(2, 12, 80), Vector3.new(-60, 6, 0), COLORS.Wall)
	addBlock(map, "BoundaryNorth", Vector3.new(120, 12, 2), Vector3.new(0, 6, -40), COLORS.Wall)
	addBlock(map, "BoundarySouth", Vector3.new(120, 12, 2), Vector3.new(0, 6, 40), COLORS.Wall)

	-- These named blocks provide readable A3, Library, and B4 placeholders without claiming full rooms.
	addBlock(map, "A3LabBlocker", Vector3.new(24, 9, 3), Vector3.new(-26, 4.5, -23), COLORS.A3)
	addBlock(map, "LibraryCover", Vector3.new(18, 8, 7), Vector3.new(15, 4, 25), COLORS.Library)
	addBlock(map, "B4GeneratorBlocker", Vector3.new(18, 9, 3), Vector3.new(43, 4.5, -18), COLORS.B4)

	-- The divider has open ends so PathfindingService can route the Mimic around it.
	addBlock(map, "SightlineDivider", Vector3.new(3, 12, 36), Vector3.new(24, 6, 0), COLORS.Wall)
	addBlock(map, "CourtyardCover", Vector3.new(10, 7, 6), Vector3.new(-12, 3.5, 14), COLORS.Wall)

	local mimic = createMimic(map, mimicMaximumHealth)
	local student = createStudent(map)
	ensureA3Puzzle(map)
	ensureLibrarySuspects(map, mimicMaximumHealth)
	ensureB4Generator(map)
	ensureGate1(map)
	return map, mimic, student
end

return table.freeze(GrayboxMap)
