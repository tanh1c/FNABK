--!strict
-- Builds one estimated Phase B exterior or Phase C walkable building.
local BuildingFootprintGenerator = {}
local facadeGenerator = require(script.Parent:WaitForChild("FacadeGenerator"))
local walkableInteriorGenerator = require(script.Parent:WaitForChild("WalkableInteriorGenerator"))
local facadeDetailGenerator = require(script.Parent:WaitForChild("BuildingFacadeDetailGenerator"))
local buildingMassingGenerator = require(script.Parent:WaitForChild("BuildingMassingGenerator"))
local styleResolver = require(script.Parent:WaitForChild("BuildingStyleResolver"))

type FootprintSpec = {
	id: string,
	label: string,
	category: string,
	centerMeters: { number },
	sizeMeters: { number },
	rotationDegrees: number,
	confidence: string,
	estimatedStories: number,
}

type ArchitectureStyle = {
	academicFloorHeightMetersEstimate: number,
	serviceFloorHeightMetersEstimate: number,
	floorHeightStatus: string,
	roofCapHeightStuds: number,
	floorBandHeightStuds: number,
	windowHeightFraction: number,
}

type InteriorStyle = { [string]: any }

local function studs(valueMeters: number, studsPerMeter: number): number
	return valueMeters * studsPerMeter
end

function BuildingFootprintGenerator.Build(
	parent: Instance,
	origin: CFrame,
	spec: FootprintSpec,
	studsPerMeter: number,
	architectureStyle: ArchitectureStyle,
	geometryMode: string?,
	interiorStyle: InteriorStyle?
): Model
	local centerX = studs(spec.centerMeters[1], studsPerMeter)
	local centerZ = studs(spec.centerMeters[2], studsPerMeter)
	local width = studs(spec.sizeMeters[1], studsPerMeter)
	local depth = studs(spec.sizeMeters[2], studsPerMeter)
	local storyCount = spec.estimatedStories
	if storyCount < 2 then
		error(spec.id .. " requires at least two estimated stories", 2)
	end

	local floorHeightMeters = if spec.category == "service"
		then architectureStyle.serviceFloorHeightMetersEstimate
		else architectureStyle.academicFloorHeightMetersEstimate
	local floorHeightStuds = studs(floorHeightMeters, studsPerMeter)
	local bodyHeightStuds = floorHeightStuds * storyCount
	local roofHeightStuds = architectureStyle.roofCapHeightStuds
	local walkableMode = geometryMode == "walkable"
	local buildingStyle = styleResolver.Resolve(spec.id, spec.category)
	local buildingFrame = origin
		* CFrame.new(centerX, 0, centerZ)
		* CFrame.Angles(0, math.rad(spec.rotationDegrees), 0)

	local model = Instance.new("Model")
	model.Name = spec.id
	model:SetAttribute("CampusBuildingId", spec.id)
	model:SetAttribute("MapLabel", spec.label)
	model:SetAttribute("BuildingCategory", spec.category)
	model:SetAttribute("FootprintConfidence", spec.confidence)
	model:SetAttribute("GeometryStage", if walkableMode then "PhaseC_WalkableInterior" else "PhaseB_ExteriorLowPoly")
	model:SetAttribute("EstimatedStories", storyCount)
	model:SetAttribute("StoryEstimateStatus", "estimated_from_reference_only")
	model:SetAttribute("EstimatedFloorHeightMeters", floorHeightMeters)
	model:SetAttribute("FloorHeightStatus", architectureStyle.floorHeightStatus)
	model:SetAttribute("EstimatedBuildingHeightMeters", storyCount * floorHeightMeters + roofHeightStuds / studsPerMeter)
	model:SetAttribute("MeasuredBuildingHeight", false)
	model:SetAttribute("StructuralCollisionEnabled", walkableMode)
	model:SetAttribute("EntranceSideEstimate", "south")
	model:SetAttribute("InteriorLayoutStatus", if walkableMode then "fictionalized_rooms_estimated_not_measured" else "not_generated")
	model:SetAttribute("BuildingDisplayName", buildingStyle.name)
	model:SetAttribute("ArchitectureArchetype", buildingStyle.archetype)
	model:SetAttribute("BuildingForm", buildingStyle.buildingForm)
	model:SetAttribute("GalleryLayout", buildingStyle.galleryLayout)
	model:SetAttribute("GalleryRailStyle", buildingStyle.galleryRailStyle)
	model:SetAttribute("GallerySupportStyle", buildingStyle.gallerySupportStyle)
	model:SetAttribute("GalleryRoofStyle", buildingStyle.galleryRoofStyle)
	model:SetAttribute("FacadeComposition", buildingStyle.facadeComposition)
	model:SetAttribute("EntryForm", buildingStyle.entryForm)
	model:SetAttribute("RoofForm", buildingStyle.roofForm)
	model:SetAttribute("FacadeSignature", buildingStyle.facadeSignature)
	model:SetAttribute("ExteriorPalette", buildingStyle.wallColor)
	model:SetAttribute("FacadeVariationStatus", "distinct_native_composition_estimate_not_surveyed")
	local facadeEntranceWidth: number? = nil
	if walkableMode then
		local style = interiorStyle or error("Phase C requires the interiorStyle manifest section", 2)
		model:SetAttribute("WalkableFloorCount", storyCount)
		model:SetAttribute("FloorClearHeightStuds", floorHeightStuds - style.floorSlabThicknessStuds)
		model:SetAttribute("FloorClearHeightMetersEstimate", floorHeightMeters - style.floorSlabThicknessStuds / studsPerMeter)
		model:SetAttribute("FloorSlabThicknessStuds", style.floorSlabThicknessStuds)
		local generatedInterior = walkableInteriorGenerator.Build(model, buildingFrame, spec, width, depth, floorHeightStuds, storyCount, style, buildingStyle)
		model:SetAttribute("StairFlights", generatedInterior.StairFlights)
		model:SetAttribute("StepsPerFlight", generatedInterior.StepsPerFlight)
		model:SetAttribute("StairRunStudsEstimate", generatedInterior.StairRunStuds)
		model:SetAttribute("EstimatedEntranceWidthStuds", generatedInterior.DoorWidthStuds)
		model:SetAttribute("EstimatedEntranceHeightStuds", generatedInterior.DoorHeightStuds)
		model:SetAttribute("RepresentativeFurniturePartCount", generatedInterior.FurnitureParts)
		model:SetAttribute("ClassroomCount", generatedInterior.ClassroomCount)
		model:SetAttribute("RoomCount", generatedInterior.RoomCount)
		local floorRoomCounts = {}
		for _, count in ipairs(generatedInterior.ClassroomsPerFloor) do
			table.insert(floorRoomCounts, tostring(count))
		end
		model:SetAttribute("ClassroomsPerFloor", table.concat(floorRoomCounts, ","))
		model:SetAttribute("CorridorWidthStuds", generatedInterior.CorridorWidthStuds)
		model:SetAttribute("CorridorAxisEstimate", generatedInterior.CorridorAxis)
		model:SetAttribute("HallLightCount", generatedInterior.HallLightCount)
		model:SetAttribute("ExteriorGalleryCount", generatedInterior.GalleryCount)
		model:SetAttribute("GalleryDeckCount", generatedInterior.GalleryDeckCount)
		model:SetAttribute("GalleryDoorCount", generatedInterior.GalleryDoorCount)
		model:SetAttribute("GalleryLightCount", generatedInterior.GalleryLightCount)
		model:SetAttribute("GalleryWidthStuds", generatedInterior.GalleryWidthStuds)
		model:SetAttribute("GalleryLayout", generatedInterior.GalleryLayout)
		model:SetAttribute("ExteriorGalleryStatus", "walkable_exterior_gallery_with_classroom_doors_and_windows_estimated")
		model:SetAttribute("InteriorYawDegrees", generatedInterior.InteriorYawDegrees)
		facadeEntranceWidth = generatedInterior.DoorWidthStuds
	else
		local body = Instance.new("Part")
		body.Name = "MainVolume"
		body.Anchored = true
		body.CanCollide = false
		body.CanTouch = false
		body.CanQuery = false
		body.CastShadow = true
		body.Material = Enum.Material.SmoothPlastic
		body.Color = buildingStyle.wallColor3
		body.Size = Vector3.new(width, bodyHeightStuds, depth)
		body.CFrame = buildingFrame * CFrame.new(0, bodyHeightStuds * 0.5, 0)
		body.Parent = model
		model.PrimaryPart = body

		local base = Instance.new("Part")
		base.Name = "GroundPlinth"
		base.Anchored = true
		base.CanCollide = false
		base.CanTouch = false
		base.CanQuery = false
		base.CastShadow = false
		base.Material = Enum.Material.SmoothPlastic
		base.Color = buildingStyle.trimColor3:Lerp(Color3.new(1, 1, 1), 0.2)
		base.Size = Vector3.new(width + 0.8, 0.8, depth + 0.8)
		base.CFrame = buildingFrame * CFrame.new(0, 0.4, 0)
		base.Parent = model

		local roof = Instance.new("Part")
		roof.Name = "RoofCap"
		roof.Anchored = true
		roof.CanCollide = false
		roof.CanTouch = false
		roof.CanQuery = false
		roof.CastShadow = true
		roof.Material = Enum.Material.SmoothPlastic
		roof.Color = buildingStyle.trimColor3
		roof.Size = Vector3.new(width + 1.0, roofHeightStuds, depth + 1.0)
		roof.CFrame = buildingFrame * CFrame.new(0, bodyHeightStuds + roofHeightStuds * 0.5 - 0.05, 0)
		roof.Parent = model
	end

	facadeGenerator.Build(
		model,
		buildingFrame,
		width,
		depth,
		floorHeightStuds,
		storyCount,
		spec.category,
		architectureStyle,
		facadeEntranceWidth,
		buildingStyle
	)
	local detailEntranceWidth = facadeEntranceWidth or math.min(10, width * 0.3)
	model:SetAttribute("BalconyCount", facadeDetailGenerator.Build(model, buildingFrame, width, depth, floorHeightStuds, storyCount, roofHeightStuds, detailEntranceWidth, buildingStyle, walkableMode))
	if walkableMode then
		local massing = buildingMassingGenerator.Build(model, buildingFrame, width, depth, floorHeightStuds, storyCount, roofHeightStuds, buildingStyle)
		model:SetAttribute("MassingFeature", massing.Feature)
		model:SetAttribute("MassingPartCount", massing.PartCount)
	end
	local partCount = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			partCount += 1
		end
	end
	model:SetAttribute("GeneratedBasePartCount", partCount)
	model.Parent = parent
	return model
end

return table.freeze(BuildingFootprintGenerator)
