--!strict
-- Builds polygon outlines as horizontal Part ribbons. Interiors are never filled.

local PolygonFootprintGenerator = {}

local MAX_PART_EDGE_LENGTH = 1800
local ZERO_LENGTH_EPSILON = 1e-6

export type Point2 = { number }

export type Feature = {
	id: string,
	category: string,
	confidence: string?,
	polygonStuds: { Point2 },
}

export type Style = {
	color: Color3,
	width: number,
	height: number,
	centerY: number,
}

local function createRibbon(
	parent: Instance,
	featureId: string,
	edgeIndex: number,
	segmentIndex: number,
	pointA: Point2,
	pointB: Point2,
	origin: CFrame,
	style: Style,
	segmentLength: number
)
	local deltaX = pointB[1] - pointA[1]
	local deltaZ = pointB[2] - pointA[2]
	local midpointX = (pointA[1] + pointB[1]) * 0.5
	local midpointZ = (pointA[2] + pointB[2]) * 0.5
	local yaw = math.atan2(-deltaZ, deltaX)

	local part = Instance.new("Part")
	part.Name = string.format("Edge%02d_Segment%02d", edgeIndex, segmentIndex)
	part.Size = Vector3.new(segmentLength, style.height, style.width)
	part.CFrame = origin * CFrame.new(midpointX, style.centerY, midpointZ) * CFrame.Angles(0, yaw, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = style.color
	part:SetAttribute("SourceFeatureID", featureId)
	part:SetAttribute("SourceEdgeIndex", edgeIndex)
	part.Parent = parent
	return part
end

function PolygonFootprintGenerator.BuildOutline(
	parent: Instance,
	feature: Feature,
	origin: CFrame,
	style: Style
): Model
	assert(#feature.polygonStuds >= 3, string.format("Feature %s has fewer than three vertices", feature.id))
	assert(style.width > 0 and style.height > 0, "Outline style dimensions must be positive")

	local model = Instance.new("Model")
	model.Name = feature.id
	model:SetAttribute("PreviewOnly", true)
	model:SetAttribute("SourceFeatureID", feature.id)
	model:SetAttribute("SourceCategory", feature.category)
	model:SetAttribute("SourceConfidence", feature.confidence or "unspecified")
	model:SetAttribute("SourcePolygonVertexCount", #feature.polygonStuds)

	for edgeIndex, pointA in ipairs(feature.polygonStuds) do
		local pointB = feature.polygonStuds[(edgeIndex % #feature.polygonStuds) + 1]
		local deltaX = pointB[1] - pointA[1]
		local deltaZ = pointB[2] - pointA[2]
		local edgeLength = math.sqrt(deltaX * deltaX + deltaZ * deltaZ)
		if edgeLength > ZERO_LENGTH_EPSILON then
			local segmentCount = math.max(1, math.ceil(edgeLength / MAX_PART_EDGE_LENGTH))
			for segmentIndex = 1, segmentCount do
				local startAlpha = (segmentIndex - 1) / segmentCount
				local endAlpha = segmentIndex / segmentCount
				local startPoint = {
					pointA[1] + deltaX * startAlpha,
					pointA[2] + deltaZ * startAlpha,
				}
				local endPoint = {
					pointA[1] + deltaX * endAlpha,
					pointA[2] + deltaZ * endAlpha,
				}
				createRibbon(
					model,
					feature.id,
					edgeIndex,
					segmentIndex,
					startPoint,
					endPoint,
					origin,
					style,
					edgeLength / segmentCount
				)
			end
		end
	end

	model.Parent = parent
	return model
end

return PolygonFootprintGenerator
