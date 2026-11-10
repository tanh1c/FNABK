--!strict
-- Draws schematic road slabs and the estimated campus parcel outline.
local RoadBoundaryGenerator = {}

type RoadSpec = {
	id: string,
	label: string,
	centerMeters: { number },
	sizeMeters: { number },
	rotationDegrees: number,
	confidence: string,
	kind: string?,
	displayLabel: boolean?,
}

type Point = { number }

local ROAD_COLOR = Color3.fromRGB(74, 80, 84)
local WALK_COLOR = Color3.fromRGB(147, 151, 147)
local BOUNDARY_COLOR = Color3.fromRGB(207, 171, 103)
-- Roblox caps each BasePart.Size dimension at 2,048 studs.
local MAX_PART_DIMENSION_STUDS = 2048

local function makeRoad(parent: Instance, origin: CFrame, spec: RoadSpec, scale: number)
	local length = spec.sizeMeters[1] * scale
	local width = spec.sizeMeters[2] * scale
	local lengthSegmentCount = math.ceil(length / MAX_PART_DIMENSION_STUDS)
	local widthSegmentCount = math.ceil(width / MAX_PART_DIMENSION_STUDS)
	local segmentLength = length / lengthSegmentCount
	local segmentWidth = width / widthSegmentCount
	local roadFrame = origin
		* CFrame.new(spec.centerMeters[1] * scale, 0.15, spec.centerMeters[2] * scale)
		* CFrame.Angles(0, math.rad(spec.rotationDegrees), 0)
	local roadKind = spec.kind or (if string.find(spec.id, "Street") then "external_street" else "pedestrian_path")
	local roadColor = if roadKind == "external_street" then ROAD_COLOR else WALK_COLOR

	for lengthIndex = 1, lengthSegmentCount do
		for widthIndex = 1, widthSegmentCount do
			local road = Instance.new("Part")
			road.Name = if lengthSegmentCount == 1 and widthSegmentCount == 1
				then spec.id
				else string.format("%s_Segment%02d_%02d", spec.id, lengthIndex, widthIndex)
			road.Anchored = true
			road.CanCollide = false
			road.CanTouch = false
			road.CanQuery = false
			road.CastShadow = false
			road.Material = Enum.Material.SmoothPlastic
			road.Color = roadColor
			road.Size = Vector3.new(segmentLength, 0.8, segmentWidth)
			local offsetX = -length * 0.5 + (lengthIndex - 0.5) * segmentLength
			local offsetZ = -width * 0.5 + (widthIndex - 0.5) * segmentWidth
			road.CFrame = roadFrame * CFrame.new(offsetX, 0, offsetZ)
			road:SetAttribute("MapLabel", spec.label)
			road:SetAttribute("RoadConfidence", spec.confidence)
			road:SetAttribute("RoadKind", roadKind)
			road:SetAttribute("DisplayLabel", spec.displayLabel ~= false and spec.label ~= "")
			road:SetAttribute("RoadSegmentX", lengthIndex)
			road:SetAttribute("RoadSegmentZ", widthIndex)
			road.Parent = parent
		end
	end
end

local function makeBoundarySegments(
	parent: Instance,
	origin: CFrame,
	first: Point,
	second: Point,
	index: number,
	scale: number
)
	local dx = second[1] - first[1]
	local dz = second[2] - first[2]
	local length = math.sqrt(dx * dx + dz * dz) * scale
	local centerX = (first[1] + second[1]) * 0.5 * scale
	local centerZ = (first[2] + second[2]) * 0.5 * scale
	local yaw = -math.atan2(dz, dx)
	local segmentCount = math.ceil(length / MAX_PART_DIMENSION_STUDS)
	local segmentLength = length / segmentCount
	local edgeFrame = origin * CFrame.new(centerX, 2.5, centerZ) * CFrame.Angles(0, yaw, 0)

	for segmentIndex = 1, segmentCount do
		local segment = Instance.new("Part")
		segment.Name = if segmentCount == 1
			then string.format("ParcelEdge%02d", index)
			else string.format("ParcelEdge%02d_Segment%02d", index, segmentIndex)
		segment.Anchored = true
		segment.CanCollide = false
		segment.CanTouch = false
		segment.CanQuery = false
		segment.CastShadow = false
		segment.Material = Enum.Material.SmoothPlastic
		segment.Color = BOUNDARY_COLOR
		segment.Size = Vector3.new(segmentLength, 5, 1.5)
		local offsetX = -length * 0.5 + (segmentIndex - 0.5) * segmentLength
		segment.CFrame = edgeFrame * CFrame.new(offsetX, 0, 0)
		segment:SetAttribute("BoundaryConfidence", "estimated_from_reference_map")
		segment:SetAttribute("BoundarySegmentIndex", segmentIndex)
		segment:SetAttribute("BoundarySegmentCount", segmentCount)
		segment.Parent = parent
	end
end

function RoadBoundaryGenerator.Build(
	parent: Instance,
	origin: CFrame,
	manifest: { [string]: any },
	studsPerMeter: number
)
	for _, road in ipairs(manifest.roads) do
		makeRoad(parent, origin, road, studsPerMeter)
	end

	local boundary: { Point } = manifest.boundaryPointsMeters
	for index, point in ipairs(boundary) do
		local nextPoint = boundary[index % #boundary + 1]
		makeBoundarySegments(parent, origin, point, nextPoint, index, studsPerMeter)
	end
end

return table.freeze(RoadBoundaryGenerator)
