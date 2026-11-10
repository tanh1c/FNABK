--!strict
-- Creates inert, color-coded map anchors; mission services do not consume them.
local MarkerGenerator = {}

local COLORS: { [string]: Color3 } = {
	Gate = Color3.fromRGB(229, 153, 64),
	Spawn = Color3.fromRGB(64, 206, 165),
	Exit = Color3.fromRGB(237, 91, 79),
	ObjectiveBuilding = Color3.fromRGB(245, 196, 75),
	PuzzleProp = Color3.fromRGB(86, 184, 219),
	PuzzleTarget = Color3.fromRGB(161, 213, 98),
	Pickup = Color3.fromRGB(207, 172, 93),
	NPCSpawn = Color3.fromRGB(113, 166, 235),
	MimicSpawn = Color3.fromRGB(219, 83, 92),
}

function MarkerGenerator.Build(parent: Instance, origin: CFrame, markers: { any }, studsPerMeter: number)
	local groups: { [string]: Folder } = {}
	local markerCount = 0

	for _, marker in ipairs(markers) do
		local group = groups[marker.group]
		if not group then
			group = Instance.new("Folder")
			group.Name = marker.group
			group.Parent = parent
			groups[marker.group] = group
		end

		local part = Instance.new("Part")
		part.Name = marker.id
		part.Shape = Enum.PartType.Ball
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = COLORS[marker.markerType] or Color3.fromRGB(245, 245, 245)
		part.Transparency = 0.15
		-- Keep marker anchors visible above the uniform Phase A building volumes.
		part.Size = Vector3.new(10, 10, 10)
		part.CFrame = origin * CFrame.new(
			marker.positionMeters[1] * studsPerMeter,
			13,
			marker.positionMeters[2] * studsPerMeter
		)
		part:SetAttribute("IsPhaseAGameplayMarker", true)
		part:SetAttribute("MarkerId", marker.id)
		part:SetAttribute("MarkerType", marker.markerType)
		part:SetAttribute("MarkerConfidence", marker.confidence)
		part.Parent = group
		markerCount += 1
	end

	return markerCount
end

return table.freeze(MarkerGenerator)
