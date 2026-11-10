--!strict
-- AC-01/02/09: distant campus context outside the 300 x 300 playable map.
-- All backdrop geometry is visual-only; mission routes and the perimeter stay
-- in CampusExpansion and retain their own collision.
local CampusBackdrop = {}

type BuildingSpec = {
	name: string,
	center: Vector3,
	width: number,
	depth: number,
	height: number,
	front: "North" | "South" | "East" | "West",
	accent: Color3,
}

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material
): Part
	local result = Instance.new("Part")
	result.Name = name
	result.Anchored = true
	result.CanCollide = false
	result.CanTouch = false
	result.CanQuery = false
	result.CastShadow = false
	result.TopSurface = Enum.SurfaceType.Smooth
	result.BottomSurface = Enum.SurfaceType.Smooth
	result.Size = size
	result.Position = position
	result.Color = color
	result.Material = material
	result.Parent = parent
	return result
end

local function buildDistantBuilding(parent: Instance, spec: BuildingSpec)
	local model = Instance.new("Model")
	model.Name = spec.name
	model:SetAttribute("DecorativeOnly", true)
	model:SetAttribute("CampusBackdrop", true)
	model.Parent = parent

	local baseHeight = spec.height - 6
	local upperHeight = 6
	local facingNorth = spec.front == "North"
	local facingSouth = spec.front == "South"
	local facingEast = spec.front == "East"
	local facingWest = spec.front == "West"
	local baseColor = Color3.fromRGB(62, 78, 90)
	local upperColor = Color3.fromRGB(78, 94, 106)
	local roofColor = Color3.fromRGB(48, 62, 75)

	local bodySize = Vector3.new(spec.width, baseHeight, spec.depth)
	local upperSize = Vector3.new(spec.width * 0.76, upperHeight, spec.depth * 0.78)
	part(model, "BackdropBase", bodySize, spec.center + Vector3.new(0, baseHeight / 2, 0), baseColor, Enum.Material.Concrete)
	part(model, "BackdropUpper", upperSize, spec.center + Vector3.new(0, baseHeight + upperHeight / 2, 0), upperColor, Enum.Material.Concrete)
	part(model, "BackdropRoof", Vector3.new(upperSize.X + 0.6, 0.45, upperSize.Z + 0.6), spec.center + Vector3.new(0, spec.height + 0.225, 0), roofColor, Enum.Material.Metal)

	local frontCFrameOffset: Vector3
	local bandSize: Vector3
	if facingNorth then
		frontCFrameOffset = Vector3.new(0, 0, -spec.depth / 2 - 0.12)
		bandSize = Vector3.new(spec.width - 12, 0.26, 0.2)
	elseif facingSouth then
		frontCFrameOffset = Vector3.new(0, 0, spec.depth / 2 + 0.12)
		bandSize = Vector3.new(spec.width - 12, 0.26, 0.2)
	elseif facingEast then
		frontCFrameOffset = Vector3.new(spec.width / 2 + 0.12, 0, 0)
		bandSize = Vector3.new(0.2, 0.26, spec.depth - 12)
	else
		frontCFrameOffset = Vector3.new(-spec.width / 2 - 0.12, 0, 0)
		bandSize = Vector3.new(0.2, 0.26, spec.depth - 12)
	end
	part(model, "CampusAccentBand", bandSize, spec.center + frontCFrameOffset + Vector3.new(0, baseHeight - 2, 0), spec.accent, Enum.Material.Metal)

	local columns = if facingNorth or facingSouth then 4 else 5
	local rows = { 5, 11, 17, spec.height - 3 }
	for rowIndex, y in ipairs(rows) do
		for bay = 1, columns do
			local fraction = bay / (columns + 1)
			local lit = (bay + rowIndex) % 4 == 0
			local glassColor = if lit then Color3.fromRGB(137, 143, 126) else Color3.fromRGB(58, 76, 91)
			local name = string.format("BackdropWindow%d_%d", rowIndex, bay)
			local windowSize: Vector3
			local windowOffset: Vector3
			if facingNorth or facingSouth then
				local x = (fraction - 0.5) * (spec.width - 18)
				local z = spec.center.Z + (if facingNorth then -spec.depth / 2 - 0.14 else spec.depth / 2 + 0.14)
				windowSize = Vector3.new(5.6, 2.6, 0.16)
				windowOffset = Vector3.new(x, y, z - spec.center.Z)
			else
				local z = (fraction - 0.5) * (spec.depth - 18)
				local x = spec.center.X + (if facingEast then spec.width / 2 + 0.14 else -spec.width / 2 - 0.14)
				windowSize = Vector3.new(0.16, 2.6, 5.6)
				windowOffset = Vector3.new(x - spec.center.X, y, z)
			end
			local window = part(model, name, windowSize, spec.center + windowOffset, glassColor, Enum.Material.Glass)
			window.Transparency = if lit then 0.2 else 0.34
		end
	end
end

function CampusBackdrop.Build(parent: Instance)
	if parent:FindFirstChild("CampusBackdrop") then return end
	local backdrop = Instance.new("Folder")
	backdrop.Name = "CampusBackdrop"
	backdrop:SetAttribute("DecorativeOnly", true)
	backdrop.Parent = parent

	-- This non-collidable ground sheet removes the floating-edge impression in
	-- overview shots without expanding the playable or pathfinding footprint.
	part(backdrop, "CampusBackdropGround", Vector3.new(1200, 1, 1200), Vector3.new(-90, -0.51, 0), Color3.fromRGB(75, 88, 82), Enum.Material.Grass)

	local buildings: { BuildingSpec } = {
		-- Keep silhouettes well beyond the playable fence so they read as distant
		-- campus context rather than more blocks competing with the real buildings.
		{ name = "NorthCampusBackdrop", center = Vector3.new(-90, 0, -390), width = 104, depth = 30, height = 22, front = "South", accent = Color3.fromRGB(29, 112, 104) },
		{ name = "SouthCampusBackdrop", center = Vector3.new(-110, 0, 390), width = 120, depth = 30, height = 22, front = "North", accent = Color3.fromRGB(154, 119, 68) },
		{ name = "WestCampusBackdrop", center = Vector3.new(-450, 0, 0), width = 30, depth = 126, height = 22, front = "East", accent = Color3.fromRGB(67, 112, 128) },
		{ name = "EastCampusBackdrop", center = Vector3.new(270, 0, 0), width = 30, depth = 116, height = 22, front = "West", accent = Color3.fromRGB(29, 112, 104) },
	}
	for _, spec in ipairs(buildings) do
		buildDistantBuilding(backdrop, spec)
	end
end

return table.freeze(CampusBackdrop)
