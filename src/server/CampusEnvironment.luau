--!strict
-- AC-01/02/03/07/08/09: low-poly campus layout around the existing mission anchors.
local CampusEnvironment = {}
local C = {
	Navy = Color3.fromRGB(19, 36, 55), Teal = Color3.fromRGB(29, 144, 127),
	Paper = Color3.fromRGB(223, 232, 231), Amber = Color3.fromRGB(198, 149, 75),
	Wall = Color3.fromRGB(105, 121, 130), Dark = Color3.fromRGB(48, 61, 69),
	Wood = Color3.fromRGB(112, 86, 65), Green = Color3.fromRGB(78, 110, 87),
	Book1 = Color3.fromRGB(75, 111, 127), Book2 = Color3.fromRGB(165, 118, 80),
}

local function part(parent: Instance, name: string, pos: Vector3, size: Vector3, color: Color3, solid: boolean, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.CanCollide = solid
	p.CanQuery = solid
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function sign(parent: Instance, name: string, pos: Vector3, size: Vector3, face: Enum.NormalId, title: string, subtitle: string)
	local p = part(parent, name, pos, size, C.Navy, false)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "Label"
	surface.Face = face
	surface.CanvasSize = Vector2.new(800, 240)
	surface.LightInfluence = 0
	surface.Parent = p
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = title .. "\n" .. subtitle
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = C.Paper
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = surface
end

local function floorMark(parent: Instance, name: string, x: number, z: number, sx: number, sz: number, color: Color3)
	part(parent, name, Vector3.new(x, 0.015, z), Vector3.new(sx, 0.02, sz), color, false)
end

local function lamp(parent: Instance, name: string, x: number, z: number)
	part(parent, name .. "Pole", Vector3.new(x, 3.5, z), Vector3.new(0.4, 7, 0.4), C.Dark, true, Enum.Material.Metal)
	local bulb = part(parent, name .. "Lamp", Vector3.new(x, 7.2, z), Vector3.new(1.4, 0.5, 1.4), C.Amber, false, Enum.Material.SmoothPlastic)
	local light = Instance.new("PointLight")
	light.Name = "SoftLight"
	light.Brightness = 1
	light.Range = 28
	light.Shadows = false
	light.Color = Color3.fromRGB(227, 220, 190)
	light.Parent = bulb
end

local function bench(parent: Instance, name: string, x: number, z: number)
	part(parent, name .. "Seat", Vector3.new(x, 1.2, z), Vector3.new(5, 0.35, 1.6), C.Wood, true, Enum.Material.Wood)
	part(parent, name .. "Back", Vector3.new(x, 2.3, z + 0.7), Vector3.new(5, 1.8, 0.25), C.Wood, true, Enum.Material.Wood)
	for _, dx in ipairs({-1.8, 1.8}) do
		part(parent, name .. "Support", Vector3.new(x + dx, 0.55, z), Vector3.new(0.25, 1.1, 1.25), C.Dark, true, Enum.Material.Metal)
	end
end

local function shelf(parent: Instance, name: string, x: number, z: number)
	part(parent, name .. "Case", Vector3.new(x, 3, z), Vector3.new(5.4, 6, 1.2), C.Wood, true, Enum.Material.Wood)
	for row = 0, 2 do
		for column = 0, 5 do
			local color = if (row + column) % 2 == 0 then C.Book1 else C.Book2
			part(parent, name .. "Book", Vector3.new(x - 2 + column * 0.8, 1 + row * 1.8, z - 0.67), Vector3.new(0.55, 1.35, 0.18), color, false)
		end
	end
end

local function readingTable(parent: Instance, name: string, x: number, z: number)
	part(parent, name .. "Surface", Vector3.new(x, 1.15, z), Vector3.new(10, 0.3, 3.2), C.Wood, true, Enum.Material.Wood)
	for _, dx in ipairs({ -4.25, 4.25 }) do
		for _, dz in ipairs({ -1.15, 1.15 }) do
			part(parent, name .. "Leg", Vector3.new(x + dx, 0.57, z + dz), Vector3.new(0.28, 1.14, 0.28), C.Dark, true, Enum.Material.Metal)
		end
	end
	for index, dx in ipairs({ -2.7, 2.7 }) do
		part(parent, name .. "Book", Vector3.new(x + dx, 1.38, z), Vector3.new(0.55, 0.14, 0.78), if index == 1 then C.Book1 else C.Book2, false, Enum.Material.SmoothPlastic)
	end
end

local function ceilingPanel(parent: Instance, name: string, position: Vector3, brightness: number, range: number)
	local lens = part(parent, name, position, Vector3.new(4.4, 0.16, 1.2), C.Paper, false, Enum.Material.SmoothPlastic)
	local light = Instance.new("PointLight")
	light.Name = "CeilingLight"
	light.Brightness = brightness
	light.Range = range
	light.Shadows = false
	light.Color = Color3.fromRGB(232, 226, 208)
	light.Parent = lens
end

local function planter(parent: Instance, name: string, x: number, z: number)
	part(parent, name .. "Base", Vector3.new(x, 0.6, z), Vector3.new(6, 1.2, 3), C.Dark, true, Enum.Material.Concrete)
	part(parent, name .. "Soil", Vector3.new(x, 1.25, z), Vector3.new(5.4, 0.2, 2.4), C.Wood, false)
	for i = -1, 1 do
		local bush = part(parent, name .. "Plant", Vector3.new(x + i * 1.5, 2, z), Vector3.new(1.7, 1.7, 1.7), C.Green, true)
		bush.Shape = Enum.PartType.Ball
	end
end

function CampusEnvironment.Build(map: Folder)
	if map:FindFirstChild("CampusEnvironment") then return end
	local env = Instance.new("Folder")
	env.Name = "CampusEnvironment"
	env.Parent = map
	local courtyard = Instance.new("Folder"); courtyard.Name = "Courtyard"; courtyard.Parent = env
	local library = Instance.new("Folder"); library.Name = "Library"; library.Parent = env
	local b4 = Instance.new("Folder"); b4.Name = "B4"; b4.Parent = env
	local gate = Instance.new("Folder"); gate.Name = "Gate"; gate.Parent = env
	planter(courtyard, "PlanterWest", -48, 34)
	planter(courtyard, "PlanterCentre", -15, 34)
	planter(courtyard, "PlanterEast", 46, 34)

	-- Open circulation around spawn, cover and central divider; marks do not
	-- participate in collisions, line of sight, or objective raycasts.
	floorMark(courtyard, "A3Approach", -30, -5, 15, 0.18, C.Amber)
	floorMark(courtyard, "LibraryApproach", 2, 10, 22, 0.18, C.Book1)
	floorMark(courtyard, "B4Approach", 37, -33, 13, 0.18, C.Green)
	floorMark(courtyard, "GateApproach", 45, 8, 20, 0.18, C.Teal)
	bench(courtyard, "WestBench", -52, 20)
	bench(courtyard, "EastBench", 45, 30)
	lamp(courtyard, "WestLight", -52, 9)
	lamp(courtyard, "CentralLight", -4, -32)
	lamp(courtyard, "EastLight", 52, 12)
	sign(courtyard, "CampusBoard", Vector3.new(-51, 5.5, -7), Vector3.new(7, 2, 0.3), Enum.NormalId.Back, "CAMPUS", "A3  /  LIBRARY  /  B4  /  GATE 1")
	part(courtyard, "CentralSignPost", Vector3.new(-3, 3.1, -6), Vector3.new(0.3, 6.2, 0.3), C.Dark, false, Enum.Material.Metal)
	sign(courtyard, "CentralDirections", Vector3.new(-3, 6.6, -6), Vector3.new(12, 1.8, 0.3), Enum.NormalId.Back, "LIBRARY  /  B4", "FOLLOW CAMPUS PASSAGES")
	part(courtyard, "EastSignPost", Vector3.new(30, 3.1, 18), Vector3.new(0.3, 6.2, 0.3), C.Dark, false, Enum.Material.Metal)
	sign(courtyard, "EastDirections", Vector3.new(30, 6.6, 18), Vector3.new(10, 1.8, 0.3), Enum.NormalId.Front, "B4  /  GATE 1", "GENERATOR  /  EXIT")

	-- Library shelves sit along the back of the existing cover, away from the
	-- three interview anchors at z=16. Two short end returns leave the front open.
	part(library, "LeftReturn", Vector3.new(5, 4, 23), Vector3.new(1, 8, 4), C.Wall, true, Enum.Material.Concrete)
	part(library, "RightReturn", Vector3.new(25, 4, 23), Vector3.new(1, 8, 4), C.Wall, true, Enum.Material.Concrete)
	sign(library, "LibrarySign", Vector3.new(15, 6.7, 21.35), Vector3.new(11, 1.8, 0.2), Enum.NormalId.Front, "LIBRARY", "STUDENT INFORMATION DESK")
	shelf(library, "ShelfWest", 9, 21.35)
	shelf(library, "ShelfEast", 21, 21.35)
	part(library, "NoticeBoard", Vector3.new(15, 3.6, 21.32), Vector3.new(4.5, 3, 0.2), C.Dark, false)
	part(library, "NoticePaper", Vector3.new(15, 3.6, 21.19), Vector3.new(3.2, 2, 0.08), C.Paper, false)
	floorMark(library, "InvestigationBoundary", 15, 11, 20, 0.18, C.Book1)

	-- Furnish the shell behind the interview plaza without moving its three NPCs.
	shelf(library, "ArchiveShelfWest", -6, 42)
	shelf(library, "ArchiveShelfEast", 36, 42)
	sign(library, "ReadingRoomSign", Vector3.new(15, 7.3, 44.5), Vector3.new(13, 2, 0.18), Enum.NormalId.Front, "BACH KHOA LIBRARY", "READING ROOM  /  ARCHIVE")
	readingTable(library, "ReadingTable", 15, 37)
	ceilingPanel(library, "ReadingRoomCeilingLight", Vector3.new(15, 14.6, 37), 1.1, 20)

	-- B4 is on the south side of the existing blocker; the fuse, generator and
	-- medkit locations remain open, with access around both ends of the blocker.
	part(b4, "RearWall", Vector3.new(43, 4.5, -36), Vector3.new(23, 9, 1), C.Wall, true, Enum.Material.Concrete)
	part(b4, "RearTrim", Vector3.new(43, 0.5, -35.42), Vector3.new(23, 0.7, 0.12), C.Dark, false, Enum.Material.Metal)
	sign(b4, "B4Sign", Vector3.new(43, 7, -35.35), Vector3.new(12, 1.8, 0.2), Enum.NormalId.Back, "B4", "GENERATOR ROOM")
	part(b4, "ConduitHorizontal", Vector3.new(45, 5.2, -35.3), Vector3.new(12, 0.25, 0.25), C.Dark, false, Enum.Material.Metal)
	part(b4, "ConduitVertical", Vector3.new(50.8, 3.2, -35.3), Vector3.new(0.25, 4, 0.25), C.Dark, false, Enum.Material.Metal)
	part(b4, "ElectricalCabinet", Vector3.new(51, 2.5, -34.8), Vector3.new(3, 5, 1), C.Dark, false, Enum.Material.Metal)
	part(b4, "CabinetMark", Vector3.new(51, 2.7, -34.23), Vector3.new(1, 1, 0.12), C.Amber, false)
	floorMark(b4, "GeneratorZoneWest", 40, -25, 0.16, 8, C.Amber)
	floorMark(b4, "GeneratorZoneEast", 50, -25, 0.16, 8, C.Amber)
	lamp(b4, "B4Light", 55, -30)
	part(b4, "InteriorEquipmentWest", Vector3.new(22, 2.5, -53), Vector3.new(4, 5, 1.4), C.Dark, true, Enum.Material.Metal)
	part(b4, "InteriorEquipmentEast", Vector3.new(64, 2.5, -53), Vector3.new(4, 5, 1.4), C.Dark, true, Enum.Material.Metal)
	sign(b4, "InteriorPowerDiagram", Vector3.new(43, 8.2, -55.4), Vector3.new(15, 2.2, 0.18), Enum.NormalId.Back, "B4 POWER DISTRIBUTION", "GENERATOR  /  MAIN BUS")
	ceilingPanel(b4, "B4InteriorCeilingLightWest", Vector3.new(30, 27, -52), 1.4, 25)
	ceilingPanel(b4, "B4InteriorCeilingLightEast", Vector3.new(56, 27, -52), 1.4, 25)

	-- Gate signage is mounted above the existing opening; no geometry occupies
	-- the control panel, doorway, exit walkway, or exit trigger.
	sign(gate, "GateTitle", Vector3.new(58.8, 12, 0), Vector3.new(0.25, 2, 15), Enum.NormalId.Left, "GATE 1", "CAMPUS EXIT")
	sign(gate, "CourtyardWelcome", Vector3.new(32, 7, 26), Vector3.new(8, 1.5, 0.3), Enum.NormalId.Front, "GATE 1", "CAMPUS COURTYARD")
	part(gate, "GateAccentLeft", Vector3.new(58.75, 4.5, -10), Vector3.new(0.25, 9, 0.3), C.Teal, false, Enum.Material.Neon)
	part(gate, "GateAccentRight", Vector3.new(58.75, 4.5, 10), Vector3.new(0.25, 9, 0.3), C.Teal, false, Enum.Material.Neon)
	print("[FNABK][Map] Courtyard, Library, B4 and Gate environment ready")
end

return table.freeze(CampusEnvironment)
