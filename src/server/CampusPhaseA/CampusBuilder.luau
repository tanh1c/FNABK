--!strict
-- Detached Phase B exterior and Phase C walkable previews. Not called by Bootstrap.
local Workspace = game:GetService("Workspace")

local manifest = require(script.Parent:WaitForChild("CampusManifest"))
local footprintGenerator = require(script.Parent:WaitForChild("BuildingFootprintGenerator"))
local academicBuildingGenerator = require(script.Parent:WaitForChild("AcademicBuildingGenerator"))
local missionBuildingGenerator = require(script.Parent:WaitForChild("MissionBuildingGenerator"))
local areaGenerator = require(script.Parent:WaitForChild("AreaGenerator"))
local roadBoundaryGenerator = require(script.Parent:WaitForChild("RoadBoundaryGenerator"))
local markerGenerator = require(script.Parent:WaitForChild("MarkerGenerator"))
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local CampusBuilder = {}

local MODEL_NAME = "FNABK_Campus_PhaseB_Exterior"
local GENERATED_BY = "CampusBuilder PhaseB"
local WALKABLE_MODEL_NAME = "FNABK_Campus_PhaseC_Interiors_v6_Walkable"
local STUDS_PER_METER = manifest.coordinateSystem.studsPerMeter
local ARCHITECTURE_STYLE = manifest.architectureStyle
-- Roblox caps each BasePart.Size dimension at 2,048 studs.
local MAX_PART_DIMENSION_STUDS = 2048

local function makeFolder(parent: Instance, name: string): Folder
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function createSiteCanvas(parent: Instance, origin: CFrame, walkable: boolean)
	local bounds = manifest.boundsMeters
	local widthStuds = bounds.widthX * STUDS_PER_METER
	local depthStuds = bounds.depthZ * STUDS_PER_METER
	local xSegmentCount = math.ceil(widthStuds / MAX_PART_DIMENSION_STUDS)
	local zSegmentCount = math.ceil(depthStuds / MAX_PART_DIMENSION_STUDS)
	local segmentWidth = widthStuds / xSegmentCount
	local segmentDepth = depthStuds / zSegmentCount

	for xIndex = 1, xSegmentCount do
		for zIndex = 1, zSegmentCount do
			local ground = Instance.new("Part")
			ground.Name = if xSegmentCount == 1 and zSegmentCount == 1
				then "SiteCanvas"
				else string.format("SiteCanvas_X%02d_Z%02d", xIndex, zIndex)
			ground.Anchored = true
			ground.CanCollide = walkable
			ground.CanTouch = false
			ground.CanQuery = walkable
			ground.CastShadow = false
			ground.Material = Enum.Material.SmoothPlastic
			ground.Color = Color3.fromRGB(83, 91, 95)
			ground.Size = Vector3.new(segmentWidth, 1, segmentDepth)
			ground.CFrame = origin * CFrame.new(
				(xIndex - 0.5) * segmentWidth,
				-0.5,
				(zIndex - 0.5) * segmentDepth
			)
			ground:SetAttribute("CanvasBoundsMeters", Vector3.new(bounds.widthX, 0, bounds.depthZ))
			ground:SetAttribute("CanvasSegmentBoundsMeters", Vector3.new(
				segmentWidth / STUDS_PER_METER,
				0,
				segmentDepth / STUDS_PER_METER
			))
			ground.Parent = parent
		end
	end
end

local function updateGeneratedMetrics(model: Model)
	local basePartCount = 0
	local collidablePartCount = 0
	local anchoredPartCount = 0
	local unanchoredPartCount = 0
	local stairFlightCount = 0
	local furniturePartCount = 0
	local classroomCount = 0
	local roomCount = 0
	local balconyCount = 0
	local exteriorGalleryCount = 0
	local galleryDeckCount = 0
	local galleryDoorCount = 0
	local galleryLightCount = 0
	local hallLightCount = 0
	local scriptCount = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			basePartCount += 1
			if descendant.CanCollide then
				collidablePartCount += 1
			end
			if descendant.Anchored then
				anchoredPartCount += 1
			else
				unanchoredPartCount += 1
			end
		elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
			scriptCount += 1
		elseif descendant:IsA("Model") and descendant:GetAttribute("CampusBuildingId") then
			stairFlightCount += descendant:GetAttribute("StairFlights") or 0
			furniturePartCount += descendant:GetAttribute("RepresentativeFurniturePartCount") or 0
			classroomCount += descendant:GetAttribute("ClassroomCount") or 0
			roomCount += descendant:GetAttribute("RoomCount") or 0
			balconyCount += descendant:GetAttribute("BalconyCount") or 0
			exteriorGalleryCount += descendant:GetAttribute("ExteriorGalleryCount") or 0
			galleryDeckCount += descendant:GetAttribute("GalleryDeckCount") or 0
			galleryDoorCount += descendant:GetAttribute("GalleryDoorCount") or 0
			galleryLightCount += descendant:GetAttribute("GalleryLightCount") or 0
			hallLightCount += descendant:GetAttribute("HallLightCount") or 0
		end
	end
	model:SetAttribute("GeneratedBasePartCount", basePartCount)
	model:SetAttribute("CollidableBasePartCount", collidablePartCount)
	model:SetAttribute("AnchoredBasePartCount", anchoredPartCount)
	model:SetAttribute("UnanchoredBasePartCount", unanchoredPartCount)
	model:SetAttribute("StairFlightCount", stairFlightCount)
	model:SetAttribute("RepresentativeFurniturePartCount", furniturePartCount)
	model:SetAttribute("ClassroomCount", classroomCount)
	model:SetAttribute("RoomCount", roomCount)
	model:SetAttribute("BalconyCount", balconyCount)
	model:SetAttribute("ExteriorGalleryCount", exteriorGalleryCount)
	model:SetAttribute("GalleryDeckCount", galleryDeckCount)
	model:SetAttribute("GalleryDoorCount", galleryDoorCount)
	model:SetAttribute("GalleryLightCount", galleryLightCount)
	model:SetAttribute("HallLightCount", hallLightCount)
	model:SetAttribute("ScriptCount", scriptCount)
	model:SetAttribute("ContainsScripts", scriptCount > 0)
end

function CampusBuilder.Build(parent: Instance?, origin: CFrame?, requestedModelName: string?, geometryMode: string?): Model
	local buildParent = parent or Workspace
	local buildOrigin = origin or CFrame.new()
	local modelName = requestedModelName or MODEL_NAME
	local walkableMode = geometryMode == "walkable"
	local existing = buildParent:FindFirstChild(modelName)
	if existing then
		error(modelName .. " already exists; this builder never overwrites or deletes existing instances", 2)
	end

	local model = Instance.new("Model")
	model.Name = modelName
	model:SetAttribute("GeneratedBy", if walkableMode then "CampusBuilder PhaseC" else GENERATED_BY)
	model:SetAttribute("Project", manifest.project)
	model:SetAttribute("Phase", if walkableMode then "C" else "B")
	model:SetAttribute("GeometryStage", if walkableMode then "PhaseC_WalkableInterior" else "PhaseB_ExteriorLowPoly")
	model:SetAttribute("MapStatus", manifest.status)
	model:SetAttribute("GameplayIntegrated", false)
	model:SetAttribute("ContainsScripts", false)
	model:SetAttribute("BuildComplete", false)
	model:SetAttribute("MetersPerStud", manifest.coordinateSystem.robloxMetersPerStud)
	model:SetAttribute("NorthAxis", manifest.coordinateSystem.zAxis)
	model:SetAttribute("EstimatedLandAreaSquareMeters", manifest.reportedLandAreaSquareMeters)
	model:SetAttribute("LayoutMode", manifest.layoutIntent.mode)
	model:SetAttribute("NominalMinimumBuildingSpacingMeters", manifest.layoutIntent.minimumBuildingSpacingMeters)
	model:SetAttribute("WalkablePreview", walkableMode)
	model:SetAttribute("StructuralCollisionEnabled", walkableMode)
	model:SetAttribute("EstimatedInteriorLayout", if walkableMode then "exterior_galleries_with_classrooms_behind_estimated_not_measured" else "not_generated")
	model:SetAttribute("ArchitectureStyleRevision", if walkableMode then "VN_Campus_v8_SchoolBlockSilhouettes" else "exterior_v2")
	model:SetAttribute("LocalOriginWorld", buildOrigin.Position)
	model.Parent = buildParent

	createSiteCanvas(model, buildOrigin, walkableMode)
	local roadFolder = makeFolder(model, "RoadsAndParcelOutline")
	roadBoundaryGenerator.Build(roadFolder, buildOrigin, manifest, STUDS_PER_METER)

	local areaFolder = makeFolder(model, "OpenAreas")
	for _, area in ipairs(manifest.openAreas) do
		areaGenerator.Build(areaFolder, buildOrigin, area, STUDS_PER_METER)
	end

	local academicFolder = makeFolder(model, "AcademicBuildings")
	local academicCount, academicStories = academicBuildingGenerator.Build(
		academicFolder,
		buildOrigin,
		manifest,
		STUDS_PER_METER,
		ARCHITECTURE_STYLE,
		footprintGenerator,
		geometryMode,
		manifest.interiorStyle
	)

	local missionFolder = makeFolder(model, "MissionBuildings")
	local missionCount, missionStories = missionBuildingGenerator.Build(
		missionFolder,
		buildOrigin,
		manifest,
		STUDS_PER_METER,
		ARCHITECTURE_STYLE,
		footprintGenerator,
		geometryMode,
		manifest.interiorStyle
	)

	local markerFolder = makeFolder(model, "GameplayMarkers_Estimated")
	local markerCount = markerGenerator.Build(markerFolder, buildOrigin, manifest.markers, STUDS_PER_METER)
	model:SetAttribute("BuildingModelCount", academicCount + missionCount)
	model:SetAttribute("EstimatedStoryCountTotal", academicStories + missionStories)
	model:SetAttribute("GameplayMarkerCount", markerCount)
	updateGeneratedMetrics(model)
	model:SetAttribute("BuildComplete", true)
	return model
end

function CampusBuilder.RefreshWalkable(model: Model): { [string]: any }
	assert(model:IsA("Model"), "RefreshWalkable expects a Model")
	assert(model.Name == WALKABLE_MODEL_NAME, "Refusing to refresh an unexpected campus preview name")
	assert(model:GetAttribute("Phase") == "C", "RefreshWalkable only updates a Phase C preview")
	assert(model:GetAttribute("GeneratedBy") == "CampusBuilder PhaseC", "RefreshWalkable only updates a source-generated Phase C preview")
	assert(model:GetAttribute("GameplayIntegrated") == false, "Refusing to refresh a gameplay-integrated map")
	assert(model:GetAttribute("BuildComplete") == true, "Refusing to refresh a preview that is not fully built")
	local academicFolder = model:FindFirstChild("AcademicBuildings")
	local missionFolder = model:FindFirstChild("MissionBuildings")
	assert(academicFolder and missionFolder, "Preview is missing one or more building groups")
	local originalById: { [string]: Model } = {}
	for _, group in ipairs({ academicFolder, missionFolder }) do
		for _, child in ipairs(group:GetChildren()) do
			if child:IsA("Model") and child:GetAttribute("CampusBuildingId") then
				local id = child:GetAttribute("CampusBuildingId")
				assert(not originalById[id], "Duplicate building id in preview: " .. tostring(id))
				originalById[id] = child
			end
		end
	end
	assert(#manifest.buildingFootprints == 23, "Unexpected manifest building count")
	for _, spec in ipairs(manifest.buildingFootprints) do
		assert(originalById[spec.id], "Preview is missing building " .. spec.id)
	end
	local originPosition = model:GetAttribute("LocalOriginWorld")
	assert(typeof(originPosition) == "Vector3", "Preview does not expose its saved world origin")
	local origin = CFrame.new(originPosition)
	local staging = Instance.new("Folder")
	staging.Name = "FNABK_CampusStyleRefresh_" .. HttpService:GenerateGUID(false)
	staging.Parent = ServerStorage
	local stagedById: { [string]: Model } = {}
	local ok, buildError = pcall(function()
		for index, spec in ipairs(manifest.buildingFootprints) do
			local replacement = footprintGenerator.Build(staging, origin, spec, STUDS_PER_METER, ARCHITECTURE_STYLE, "walkable", manifest.interiorStyle)
			stagedById[spec.id] = replacement
			if index % 2 == 0 then
				task.wait()
			end
		end
	end)
	if not ok then
		staging:Destroy()
		error("Style refresh staging failed; the existing preview was preserved: " .. tostring(buildError), 2)
	end

	local committed: { { id: string, old: Model, replacement: Model, parent: Instance, oldName: string } } = {}
	local commitOk, commitError = pcall(function()
		model:SetAttribute("BuildComplete", false)
		for index, spec in ipairs(manifest.buildingFootprints) do
			local old = originalById[spec.id]
			local replacement = stagedById[spec.id]
			local parent = old.Parent
			local oldName = old.Name
			table.insert(committed, { id = spec.id, old = old, replacement = replacement, parent = parent, oldName = oldName })
			old.Name = "__StyleRefreshBackup_" .. spec.id
			replacement.Parent = parent
			replacement.Name = oldName
			if index % 2 == 0 then
				task.wait()
			end
		end
	end)
	if not commitOk then
		for _, item in ipairs(committed) do
			item.replacement:Destroy()
			item.old.Name = item.oldName
		end
		model:SetAttribute("BuildComplete", true)
		staging:Destroy()
		error("Style refresh commit failed; the previous buildings were restored: " .. tostring(commitError), 2)
	end

	for _, item in ipairs(committed) do
		item.old:Destroy()
	end
	staging:Destroy()
	model:SetAttribute("ArchitectureStyleRevision", "VN_Campus_v8_SchoolBlockSilhouettes")
	model:SetAttribute("EstimatedInteriorLayout", "exterior_galleries_with_classrooms_behind_estimated_not_measured")
	model:SetAttribute("LastRefreshLocalTime", os.date("!%Y-%m-%dT%H:%M:%SZ"))
	updateGeneratedMetrics(model)
	model:SetAttribute("BuildComplete", true)
	return {
		BuildingCount = #manifest.buildingFootprints,
		BasePartCount = model:GetAttribute("GeneratedBasePartCount"),
		CollidablePartCount = model:GetAttribute("CollidableBasePartCount"),
		ClassroomCount = model:GetAttribute("ClassroomCount"),
		RoomCount = model:GetAttribute("RoomCount"),
		BalconyCount = model:GetAttribute("BalconyCount"),
		ExteriorGalleryCount = model:GetAttribute("ExteriorGalleryCount"),
		GalleryDeckCount = model:GetAttribute("GalleryDeckCount"),
		GalleryDoorCount = model:GetAttribute("GalleryDoorCount"),
		GalleryLightCount = model:GetAttribute("GalleryLightCount"),
		HallLightCount = model:GetAttribute("HallLightCount"),
		ScriptCount = model:GetAttribute("ScriptCount"),
	}
end

return table.freeze(CampusBuilder)
