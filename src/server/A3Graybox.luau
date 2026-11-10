--!strict
-- AC-01/AC-06/AC-09: an A3 lab visual and circulation study using primitive parts.
local A3Graybox = {}

local COLORS = {
	Navy = Color3.fromRGB(19, 36, 55),
	Teal = Color3.fromRGB(29, 144, 127),
	Paper = Color3.fromRGB(241, 245, 247),
	Amber = Color3.fromRGB(198, 149, 75),
	Wall = Color3.fromRGB(119, 132, 137),
	Dark = Color3.fromRGB(52, 64, 72),
}

local function block(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, solid: boolean): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.CanCollide = solid
	part.CanTouch = false
	part.CanQuery = solid
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function sign(parent: Instance, name: string, position: Vector3, size: Vector3, text: string)
	local panel = block(parent, name, size, position, COLORS.Navy, Enum.Material.SmoothPlastic, false)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "SignFace"
	surface.Face = Enum.NormalId.Back
	surface.CanvasSize = Vector2.new(800, 160)
	surface.LightInfluence = 0
	surface.Parent = panel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = COLORS.Paper
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = surface
end

local function labTable(parent: Instance, name: string, position: Vector3)
	block(parent, name .. "Top", Vector3.new(2.4, 0.24, 7), position + Vector3.new(0, 1.65, 0), COLORS.Dark, Enum.Material.Metal, true)
	for _, xOffset in ipairs({ -0.92, 0.92 }) do
		for _, zOffset in ipairs({ -3.05, 3.05 }) do
			block(parent, name .. "Leg", Vector3.new(0.18, 1.5, 0.18), position + Vector3.new(xOffset, 0.75, zOffset), COLORS.Dark, Enum.Material.Metal, true)
		end
	end
	block(parent, name .. "Instrument", Vector3.new(1.35, 0.7, 1.25), position + Vector3.new(0, 2.12, -1.65), COLORS.Navy, Enum.Material.Metal, false)
	block(parent, name .. "InstrumentScreen", Vector3.new(0.78, 0.44, 0.08), position + Vector3.new(0, 2.2, -1.02), COLORS.Teal, Enum.Material.SmoothPlastic, false)
	block(parent, name .. "SampleTray", Vector3.new(0.85, 0.18, 0.55), position + Vector3.new(0, 1.86, 1.65), COLORS.Amber, Enum.Material.Metal, false)
end

local function ceilingLight(parent: Instance, name: string, position: Vector3)
	local panel = block(parent, name, Vector3.new(4.4, 0.16, 1.2), position, Color3.fromRGB(232, 225, 204), Enum.Material.SmoothPlastic, false)
	local light = Instance.new("PointLight")
	light.Name = "LabLight"
	light.Brightness = 1.1
	light.Range = 20
	light.Shadows = false
	light.Color = Color3.fromRGB(228, 222, 203)
	light.Parent = panel
end

function A3Graybox.Build(map: Folder)
	if map:FindFirstChild("A3Environment") then return end
	local env = Instance.new("Folder")
	env.Name = "A3Environment"
	env.Parent = map

	-- Short wall returns define the lab's back corners while the front remains
	-- open for players and the 4-stud crate. Existing crate and plate remain in place.
	block(env, "WestReturn", Vector3.new(1, 9, 6), Vector3.new(-39, 4.5, -20), COLORS.Wall, Enum.Material.Concrete, true)
	block(env, "EastReturn", Vector3.new(1, 9, 6), Vector3.new(-13, 4.5, -20), COLORS.Wall, Enum.Material.Concrete, true)
	block(env, "BackLowerTrim", Vector3.new(24, 0.5, 0.15), Vector3.new(-26, 0.35, -21.36), COLORS.Dark, Enum.Material.Metal, false)
	block(env, "BackUpperTrim", Vector3.new(24, 0.45, 0.15), Vector3.new(-26, 8.4, -21.36), COLORS.Dark, Enum.Material.Metal, false)
	sign(env, "A3LabSign", Vector3.new(-26, 7.0, -21.25), Vector3.new(13, 2, 0.25), "A3  /  ENGINEERING LAB")
	block(env, "A3SignAccent", Vector3.new(13, 0.16, 0.12), Vector3.new(-26, 5.9, -21.09), COLORS.Amber, Enum.Material.SmoothPlastic, false)

	-- The empty two-storey shell gets a compact lab interior along its side walls.
	-- The central floor stays clear, and all mission crate/plate positions remain outside.
	labTable(env, "WestLabBench", Vector3.new(-46.5, 0, -38))
	labTable(env, "EastLabBench", Vector3.new(-5.5, 0, -38))
	sign(env, "LabSafetyBoard", Vector3.new(-26, 6.1, -44.9), Vector3.new(14, 2.4, 0.18), "ENGINEERING LAB  /  SAFETY FIRST")
	block(env, "LabSafetyBoardAccent", Vector3.new(14, 0.14, 0.12), Vector3.new(-26, 4.75, -44.78), COLORS.Amber, Enum.Material.Metal, false)
	ceilingLight(env, "WestCeilingLight", Vector3.new(-36, 14.7, -38))
	ceilingLight(env, "EastCeilingLight", Vector3.new(-16, 14.7, -38))
	block(env, "LabEntrySafetyStripe", Vector3.new(10, 0.02, 0.16), Vector3.new(-26, 0.018, -31.5), COLORS.Amber, Enum.Material.SmoothPlastic, false)

	-- Floor markings are non-queryable and do not intercept plate raycasts.
	block(env, "RouteLineWest", Vector3.new(0.25, 0.02, 13), Vector3.new(-40.5, 0.015, -6.5), COLORS.Amber, Enum.Material.SmoothPlastic, false)
	block(env, "RouteLineEast", Vector3.new(0.25, 0.02, 13), Vector3.new(-11.5, 0.015, -6.5), COLORS.Amber, Enum.Material.SmoothPlastic, false)
	block(env, "PlateGuideWest", Vector3.new(0.15, 0.02, 9), Vector3.new(-28.5, 0.012, -13), COLORS.Teal, Enum.Material.SmoothPlastic, false)
	block(env, "PlateGuideEast", Vector3.new(0.15, 0.02, 9), Vector3.new(-19.5, 0.012, -13), COLORS.Teal, Enum.Material.SmoothPlastic, false)

	-- Wall-mounted graphics make the puzzle legible without adding new gameplay.
	sign(env, "PowerPanelLabel", Vector3.new(-18, 4.0, -21.24), Vector3.new(5.5, 1.2, 0.2), "POWER / A3")
	block(env, "PowerPanelBase", Vector3.new(5.8, 3.4, 0.3), Vector3.new(-18, 2.5, -21.35), COLORS.Dark, Enum.Material.Metal, false)
	block(env, "PanelIndicator", Vector3.new(0.4, 0.4, 0.16), Vector3.new(-19.8, 2.7, -21.12), COLORS.Amber, Enum.Material.Neon, false)
	block(env, "PanelIndicator2", Vector3.new(0.4, 0.4, 0.16), Vector3.new(-18.8, 2.7, -21.12), COLORS.Teal, Enum.Material.Neon, false)

	-- One low-cost wayfinding marker near A3; labels describe destinations,
	-- not mission completion or NPC identity.
	block(env, "WayfindingPost", Vector3.new(0.45, 6, 0.45), Vector3.new(-50, 3, 5), COLORS.Dark, Enum.Material.Metal, false)
	sign(env, "WayfindingBoard", Vector3.new(-50, 6.7, 5), Vector3.new(9, 1.5, 0.4), "A3  /  LIBRARY  /  B4  /  GATE")

	print("[FNABK][Map] A3 lab graybox and wayfinding ready")
end

return table.freeze(A3Graybox)
