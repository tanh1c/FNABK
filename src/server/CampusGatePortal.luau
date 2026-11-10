--!strict
-- AC-01/02/08/09: a recognizable, readable campus entrance at Gate 1.
-- The columns sit outside the 16-stud doorway and the lintel stays above it.
local CampusGatePortal = {}

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	canCollide: boolean
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = canCollide
	part.CanTouch = false
	part.CanQuery = canCollide
	part.CastShadow = canCollide
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function CampusGatePortal.Build(parent: Instance): Model
	local existing = parent:FindFirstChild("CampusGatePortal")
	if existing and existing:IsA("Model") then return existing end

	local portal = Instance.new("Model")
	portal.Name = "CampusGatePortal"
	portal:SetAttribute("CampusFeature", "Gate1Entrance")
	portal:SetAttribute("DecorativeOnly", false)
	portal.Parent = parent

	local navy = Color3.fromRGB(19, 36, 55)
	local teal = Color3.fromRGB(29, 144, 127)
	local amber = Color3.fromRGB(198, 149, 75)
	local stone = Color3.fromRGB(104, 122, 131)

	for side, z in ipairs({ -11.8, 11.8 }) do
		local base = makePart(portal, "GatePortalFooting" .. side, Vector3.new(3.2, 0.8, 3.2), Vector3.new(60, 0.4, z), stone, Enum.Material.Concrete, true)
		base.CastShadow = true
		makePart(portal, "GatePortalColumn" .. side, Vector3.new(2.4, 12.8, 2.4), Vector3.new(60, 7.2, z), navy, Enum.Material.Concrete, true)
		makePart(portal, "GatePortalTealBand" .. side, Vector3.new(2.56, 0.34, 2.56), Vector3.new(60, 11.8, z), teal, Enum.Material.Metal, false)
		makePart(portal, "GatePortalAmberBand" .. side, Vector3.new(2.56, 0.16, 2.56), Vector3.new(60, 2.6, z), amber, Enum.Material.Metal, false)
	end

	makePart(portal, "GatePortalLintel", Vector3.new(3, 2.2, 30), Vector3.new(60, 14.7, 0), navy, Enum.Material.Concrete, true)
	makePart(portal, "GatePortalCrown", Vector3.new(3.2, 0.34, 30.4), Vector3.new(60, 15.98, 0), teal, Enum.Material.Metal, false)

	local nameplate = makePart(
		portal,
		"GatePortalNameplate",
		Vector3.new(0.16, 1.45, 24),
		Vector3.new(58.36, 14.72, 0),
		teal,
		Enum.Material.SmoothPlastic,
		false
	)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "CampusName"
	surface.Face = Enum.NormalId.Left
	surface.CanvasSize = Vector2.new(1440, 100)
	surface.LightInfluence = 0
	surface.Parent = nameplate
	local label = Instance.new("TextLabel")
	label.Name = "Name"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "BACH KHOA  |  GATE 1"
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(241, 245, 247)
	label.TextScaled = true
	label.Parent = surface

	return portal
end

return table.freeze(CampusGatePortal)
