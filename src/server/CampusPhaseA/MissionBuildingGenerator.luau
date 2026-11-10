--!strict
-- Builds objective-area exterior shells without moving/replacing gameplay objects.
local MissionBuildingGenerator = {}

function MissionBuildingGenerator.Build(
	parent: Instance,
	origin: CFrame,
	manifest: { [string]: any },
	studsPerMeter: number,
	architectureStyle: { [string]: any },
	footprintGenerator: any,
	geometryMode: string?,
	interiorStyle: { [string]: any }?
)
	local count = 0
	local totalEstimatedStories = 0
	local buildBatch = 0
	for _, building in ipairs(manifest.buildingFootprints) do
		if building.category == "mission" or building.category == "library" then
			local model = footprintGenerator.Build(parent, origin, building, studsPerMeter, architectureStyle, geometryMode, interiorStyle)
			count += 1
			totalEstimatedStories += model:GetAttribute("EstimatedStories") or 0
			buildBatch += 1
			if geometryMode == "walkable" and buildBatch % 2 == 0 then
				task.wait()
			end
		end
	end
	return count, totalEstimatedStories
end

return table.freeze(MissionBuildingGenerator)
