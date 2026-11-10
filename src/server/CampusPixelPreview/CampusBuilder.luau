--!strict
-- Detached local preview builder. It is intentionally not required by Bootstrap.

local Manifest = require(script.Parent.CampusPreviewManifest)
local PolygonFootprintGenerator = require(script.Parent.PolygonFootprintGenerator)

local CampusBuilder = {}

local MAX_CANVAS_TILE_LENGTH = 1800

type OutlineStyle = {
	color: Color3,
	width: number,
	height: number,
	centerY: number,
}

local CATEGORY_STYLES: { [string]: OutlineStyle } = {
	building = {
		color = Color3.fromRGB(216, 139, 62),
		width = 3,
		height = 2.4,
		centerY = 1.2,
	},
	area = {
		color = Color3.fromRGB(67, 151, 105),
		width = 2,
		height = 0.5,
		centerY = 0.5,
	},
	boundary = {
		color = Color3.fromRGB(49, 103, 165),
		width = 2.5,
		height = 0.7,
		centerY = 0.7,
	},
}

local function createModel(name: string, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("PreviewOnly", true)
	model.Parent = parent
	return model
end

local function createPart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = material
	part.Color = color
	part.Parent = parent
	return part
end

local function buildCanvas(parent: Instance, origin: CFrame, widthStuds: number, depthStuds: number)
	local canvas = createModel("PixelCanvas", parent)
	local startX = 0
	local tileX = 0
	while startX < widthStuds do
		local tileWidth = math.min(MAX_CANVAS_TILE_LENGTH, widthStuds - startX)
		local startZ = 0
		local tileZ = 0
		while startZ < depthStuds do
			local tileDepth = math.min(MAX_CANVAS_TILE_LENGTH, depthStuds - startZ)
			createPart(
				canvas,
				string.format("Canvas_%02d_%02d", tileX + 1, tileZ + 1),
				Vector3.new(tileWidth, 0.5, tileDepth),
				origin * CFrame.new(startX + tileWidth * 0.5, -0.25, startZ + tileDepth * 0.5),
				Color3.fromRGB(52, 58, 66),
				Enum.Material.SmoothPlastic
			)
			startZ += tileDepth
			tileZ += 1
		end
		startX += tileWidth
		tileX += 1
	end
	return canvas
end

local function buildEntrances(parent: Instance, origin: CFrame, scale: number)
	local markersModel = createModel("DigitizedEntrances", parent)
	local diameter = math.clamp(6 * scale, 3, 24)
	for _, marker in ipairs(Manifest.entrances) do
		local x = marker.positionStuds[1]
		local z = marker.positionStuds[2]
		local markerModel = createModel(marker.id, markersModel)
		local part = createPart(
			markerModel,
			"EntrancePoint",
			Vector3.new(diameter, diameter, diameter),
			origin * CFrame.new(x, diameter * 0.5 + 0.1, z),
			Color3.fromRGB(224, 65, 61),
			Enum.Material.SmoothPlastic
		)
		part.Shape = Enum.PartType.Ball
		part:SetAttribute("PreviewMarkerID", marker.id)
		markerModel:SetAttribute("PixelX", marker.pixelPosition[1])
		markerModel:SetAttribute("PixelY", marker.pixelPosition[2])
	end
	return markersModel
end

local function countBaseParts(root: Instance): number
	local count = 0
	for _, item in ipairs(root:GetDescendants()) do
		if item:IsA("BasePart") then
			count += 1
		end
	end
	return count
end

function CampusBuilder.Build(parent: Instance, origin: CFrame, outputName: string?): (Model?, any)
	assert(typeof(parent) == "Instance", "A parent Instance is required")
	assert(typeof(origin) == "CFrame", "A CFrame origin is required")

	local name = outputName or Manifest.previewName
	if parent:FindFirstChild(name) then
		return nil, string.format("%s already exists under %s; refusing to replace or delete it", name, parent:GetFullName())
	end

	local root = Instance.new("Model")
	root.Name = name
	root:SetAttribute("PreviewOnly", true)
	root:SetAttribute("SourceStatus", "PROVISIONAL_PIXEL_SPACE_VISUALIZATION")
	root:SetAttribute("PreviewStudsPerPixel", Manifest.previewStudsPerPixel)
	root:SetAttribute("HorizontalMirrorApplied", Manifest.horizontalMirrorApplied == true)
	root:SetAttribute("MetersPerPixel", "null")
	root:SetAttribute("GeographicNorthAligned", false)
	root:SetAttribute("GameplayScriptsIncluded", false)
	root:SetAttribute("CollisionEnabled", false)

	local ok, buildError = pcall(function()
		local buildings = createModel("Buildings", root)
		local areas = createModel("Areas", root)
		local boundary = createModel("CampusBoundary", root)
		local styles = CATEGORY_STYLES

		local widthStuds = Manifest.sourceImage.widthPx * Manifest.previewStudsPerPixel
		local depthStuds = Manifest.sourceImage.heightPx * Manifest.previewStudsPerPixel
		buildCanvas(root, origin, widthStuds, depthStuds)

		for _, feature in ipairs(Manifest.features) do
			local parentModel: Model
			if feature.category == "building" then
				parentModel = buildings
			elseif feature.category == "boundary" then
				parentModel = boundary
			else
				parentModel = areas
			end
			local style = styles[feature.category]
			assert(style ~= nil, string.format("No visual style for category %s", feature.category))
			PolygonFootprintGenerator.BuildOutline(parentModel, feature, origin, style)
		end

		buildEntrances(root, origin, Manifest.previewStudsPerPixel)
	end)

	if not ok then
		root:Destroy()
		return nil, tostring(buildError)
	end

	if parent:FindFirstChild(name) then
		root:Destroy()
		return nil, string.format("%s appeared during build; refusing to replace or delete it", name)
	end

	local partCount = countBaseParts(root)
	root:SetAttribute("PreviewBasePartCount", partCount)
	root:SetAttribute("PreviewFeatureCount", #Manifest.features)
	root:SetAttribute("PreviewEntranceCount", #Manifest.entrances)
	root.Parent = parent

	return root, {
		basePartCount = partCount,
		featureCount = #Manifest.features,
		entranceCount = #Manifest.entrances,
		previewStudsPerPixel = Manifest.previewStudsPerPixel,
	}
end

return CampusBuilder
