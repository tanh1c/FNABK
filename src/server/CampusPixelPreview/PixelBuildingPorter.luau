--!strict
-- Copies the finished, detached Phase C building models onto the provisional
-- pixel-space layout. This module is editor-invoked and is not required by Bootstrap.

local PixelManifest = require(script.Parent:WaitForChild("CampusPreviewManifest"))
local WorkshopBuildingGenerator = require(script.Parent:WaitForChild("WorkshopBuildingGenerator"))

local PixelBuildingPorter = {}

local SOURCE_ROOT_NAME = "FNABK_Campus_PhaseC_Interiors_v6_Walkable"
local DEFAULT_OUTPUT_NAME = "FNABK_Campus_PixelBuildings_PhaseC_v6"
local B1_COURTYARD_SAMPLE_PIXEL = Vector2.new(291, 650)

-- These are visual source models for new identities, not ID aliases.
local TEMPLATE_BY_ID: { [string]: string } = {
	B3 = "B6",
	B11 = "B7",
	B12 = "Facility1",
	Canteen = "B10",
	Facility7 = "B8",
	KioskOISP = "Kiosk8",
}

local DISPLAY_NAME_BY_ID: { [string]: string } = {
	C1 = "XƯỞNG CƠ KHÍ C1",
	C2 = "XƯỞNG CƠ ĐIỆN TỬ C2",
	C3 = "XƯỞNG CƠ KHÍ C3",
	B3 = "TÒA B3",
	B11 = "TÒA B11",
	B12 = "TÒA B12",
	Canteen = "CĂNG TIN",
	Facility7 = "NHÀ PHỤ 7",
	KioskOISP = "KIOSK OISP",
}

local CONFIRMED_STORIES_BY_ID: { [string]: number } = {
	A1 = 3,
	A2 = 3,
	A3 = 2,
	A4 = 5,
	A5 = 4,
	B1 = 3,
	B2 = 3,
	B3 = 2,
	B4 = 6,
	B6 = 3,
	B8 = 3,
	B9 = 3,
	B11 = 2,
	B12 = 2,
	C1 = 2,
	C2 = 1,
	C3 = 1,
	C4 = 5,
	C5 = 5,
	C6 = 5,
	Canteen = 2,
	Facility7 = 3,
	KioskOISP = 1,
}

type Point2 = { number }
type Rect = { minX: number, maxX: number, minZ: number, maxZ: number }

local function round(value: number): number
	return math.floor(value * 1000 + 0.5) / 1000
end

local function getSourceModels(sourceRoot: Model): { [string]: Model }
	local result: { [string]: Model } = {}
	for _, groupName in ipairs({ "AcademicBuildings", "MissionBuildings" }) do
		local group = sourceRoot:FindFirstChild(groupName)
		assert(group, "Phase C source is missing " .. groupName)
		for _, child in ipairs(group:GetChildren()) do
			if child:IsA("Model") then
				local id = child:GetAttribute("CampusBuildingId")
				if typeof(id) == "string" then
					assert(result[id] == nil, "Duplicate source building ID: " .. id)
					result[id] = child
				end
			end
		end
	end
	return result
end

local function localBounds(model: Model, frame: CFrame): (number, number, number, number)
	local minX, maxX = math.huge, -math.huge
	local minZ, maxZ = math.huge, -math.huge
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local partFrame = frame:ToObjectSpace(descendant.CFrame)
			local half = descendant.Size * 0.5
			for sx = -1, 1, 2 do
				for sy = -1, 1, 2 do
					for sz = -1, 1, 2 do
						local point = partFrame:PointToWorldSpace(Vector3.new(half.X * sx, half.Y * sy, half.Z * sz))
						minX = math.min(minX, point.X)
						maxX = math.max(maxX, point.X)
						minZ = math.min(minZ, point.Z)
						maxZ = math.max(maxZ, point.Z)
					end
				end
			end
		end
	end
	assert(minX < maxX and minZ < maxZ, "Source building has no usable BasePart footprint: " .. model.Name)
	return minX, maxX, minZ, maxZ
end

local function pointInPolygon(x: number, z: number, polygon: { Point2 }): boolean
	local inside = false
	local previousIndex = #polygon
	for index = 1, #polygon do
		local current = polygon[index]
		local previous = polygon[previousIndex]
		local currentZ = current[2]
		local previousZ = previous[2]
		if (currentZ > z) ~= (previousZ > z) then
			local crossingX = (previous[1] - current[1]) * (z - currentZ) / (previousZ - currentZ) + current[1]
			if x < crossingX then
				inside = not inside
			end
		end
		previousIndex = index
	end
	return inside
end

local function clusteredCoordinates(values: { number }): { number }
	table.sort(values)
	local result: { number } = {}
	local counts: { number } = {}
	for _, value in ipairs(values) do
		local last = #result
		if last == 0 or math.abs(value - result[last]) > 1.8 then
			table.insert(result, value)
		table.insert(counts, 1)
		else
			local count = counts[last] + 1
			result[last] = (result[last] * counts[last] + value) / count
			counts[last] = count
		end
	end
	return result
end

-- Finds temporary rectangular build regions inside B1's orthogonal U footprint.
-- They are flattened into one connected B1 model after generation; the source
-- polygon remains canonical in CampusPixelGeometry.json.
local function decomposeB1(polygon: { Point2 }, manifest: any): { Rect }
	local xs: { number } = {}
	local zs: { number } = {}
	for _, point in ipairs(polygon) do
		table.insert(xs, point[1])
		table.insert(zs, point[2])
	end
	xs = clusteredCoordinates(xs)
	zs = clusteredCoordinates(zs)
	assert(#xs == 4 and #zs == 3, "B1 is no longer the expected three-wing U footprint; review its polygon before porting")
	local sampleX = if manifest.horizontalMirrorApplied == true
		then manifest.sourceImage.widthPx - B1_COURTYARD_SAMPLE_PIXEL.X
		else B1_COURTYARD_SAMPLE_PIXEL.X
	local sampleZ = manifest.sourceImage.heightPx - B1_COURTYARD_SAMPLE_PIXEL.Y
	assert(not pointInPolygon(sampleX, sampleZ, polygon), "B1 courtyard sample must remain outside the building polygon")

	local active: { [string]: Rect } = {}
	local completed: { Rect } = {}
	for zIndex = 1, #zs - 1 do
		local current: { [string]: Rect } = {}
		local xIndex = 1
		while xIndex < #xs do
			if pointInPolygon((xs[xIndex] + xs[xIndex + 1]) * 0.5, (zs[zIndex] + zs[zIndex + 1]) * 0.5, polygon) then
				local firstX = xIndex
				while xIndex + 1 < #xs and pointInPolygon((xs[xIndex + 1] + xs[xIndex + 2]) * 0.5, (zs[zIndex] + zs[zIndex + 1]) * 0.5, polygon) do
					xIndex += 1
				end
				local lastX = xIndex + 1
				local key = tostring(firstX) .. ":" .. tostring(lastX)
				local rect = active[key]
				if rect and math.abs(rect.maxZ - zs[zIndex]) < 1.8 then
					rect.maxZ = zs[zIndex + 1]
				else
					rect = { minX = xs[firstX], maxX = xs[lastX], minZ = zs[zIndex], maxZ = zs[zIndex + 1] }
				end
				current[key] = rect
			end
			xIndex += 1
		end
		for key, rect in pairs(active) do
			if current[key] == nil then
				table.insert(completed, rect)
			end
		end
		active = current
	end
	for _, rect in pairs(active) do
		table.insert(completed, rect)
	end
	assert(#completed == 3, "B1 U footprint must produce three temporary geometry regions")
	table.sort(completed, function(a, b)
		local centerAZ = (a.minZ + a.maxZ) * 0.5
		local centerBZ = (b.minZ + b.maxZ) * 0.5
		if math.abs(centerAZ - centerBZ) > 2 then
			return centerAZ < centerBZ
		end
		return a.minX < b.minX
	end)
	return completed
end

local function targetFrameForPolygon(polygon: { Point2 }, origin: CFrame, centerX: number, centerZ: number, sourceMajorAxisIsX: boolean): (CFrame, number, number)
	local longest = -math.huge
	local axisX, axisZ = 1, 0
	for index = 1, #polygon do
		local current = polygon[index]
		local nextPoint = polygon[index % #polygon + 1]
		local dx = nextPoint[1] - current[1]
		local dz = nextPoint[2] - current[2]
		local length = math.sqrt(dx * dx + dz * dz)
		if length > longest then
			longest = length
			axisX, axisZ = dx / length, dz / length
		end
	end
	if axisX < 0 or (math.abs(axisX) < 1e-6 and axisZ < 0) then
		axisX, axisZ = -axisX, -axisZ
	end
	local yaw = if sourceMajorAxisIsX then -math.atan2(axisZ, axisX) else math.atan2(axisX, axisZ)
	local center = origin * CFrame.new(centerX, 0, centerZ)
	local frame = center * CFrame.Angles(0, yaw, 0)
	local minX, maxX = math.huge, -math.huge
	local minZ, maxZ = math.huge, -math.huge
	for _, point in ipairs(polygon) do
		local worldPoint = origin:PointToWorldSpace(Vector3.new(point[1], 0, point[2]))
		local localPoint = frame:PointToObjectSpace(worldPoint)
		minX = math.min(minX, localPoint.X)
		maxX = math.max(maxX, localPoint.X)
		minZ = math.min(minZ, localPoint.Z)
		maxZ = math.max(maxZ, localPoint.Z)
	end
	return frame, maxX - minX, maxZ - minZ
end

local function rectTargetFrame(rect: Rect, origin: CFrame, sourceMajorAxisIsX: boolean): (CFrame, number, number)
	local width = rect.maxX - rect.minX
	local depth = rect.maxZ - rect.minZ
	local targetMajorAxisIsX = width >= depth
	local rotate90 = sourceMajorAxisIsX ~= targetMajorAxisIsX
	local yaw = if rotate90 then math.pi * 0.5 else 0
	local frame = origin * CFrame.new((rect.minX + rect.maxX) * 0.5, 0, (rect.minZ + rect.maxZ) * 0.5) * CFrame.Angles(0, yaw, 0)
	return frame, if rotate90 then depth else width, if rotate90 then width else depth
end

-- Some imported/source models have a stored pivot rotation that can leave the
-- fitted geometry on the opposite rectangle axis. Compare the actual bounds in
-- the pixel-map frame and rotate only when the X/Z extents are clearly swapped.
local function alignRectFootprintAxes(model: Model, rect: Rect, origin: CFrame): boolean
	local minX, maxX, minZ, maxZ = localBounds(model, origin)
	local actualWidth = maxX - minX
	local actualDepth = maxZ - minZ
	local targetWidth = rect.maxX - rect.minX
	local targetDepth = rect.maxZ - rect.minZ
	local directError = math.abs(actualWidth - targetWidth) / targetWidth
		+ math.abs(actualDepth - targetDepth) / targetDepth
	local swappedError = math.abs(actualWidth - targetDepth) / targetDepth
		+ math.abs(actualDepth - targetWidth) / targetWidth
	if swappedError + 0.01 >= directError then
		return false
	end

	local boundsFrame = select(1, model:GetBoundingBox())
	local centerInMapFrame = origin:PointToObjectSpace(boundsFrame.Position)
	local pivot = origin * CFrame.new(centerInMapFrame)
	local turn = pivot * CFrame.Angles(0, math.pi * 0.5, 0) * pivot:Inverse()
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CFrame = turn * descendant.CFrame
		end
	end

	local fixedMinX, fixedMaxX, fixedMinZ, fixedMaxZ = localBounds(model, origin)
	local fixedWidth = fixedMaxX - fixedMinX
	local fixedDepth = fixedMaxZ - fixedMinZ
	assert(
		math.abs(fixedWidth - targetWidth) <= math.max(2, targetWidth * 0.04)
			and math.abs(fixedDepth - targetDepth) <= math.max(2, targetDepth * 0.04),
		"B1 wing bounds still do not match its footprint rectangle"
	)
	return true
end

-- Re-centers and scales the fitted clone from its measured bounds so every
-- outside face stays on the polygon rectangle, even if its source pivot is off.
local function fitModelToRect(model: Model, rect: Rect, origin: CFrame): (number, number)
	local minX, maxX, minZ, maxZ = localBounds(model, origin)
	local sourceCenterX, sourceCenterZ = (minX + maxX) * 0.5, (minZ + maxZ) * 0.5
	local sourceWidth, sourceDepth = maxX - minX, maxZ - minZ
	local targetWidth, targetDepth = rect.maxX - rect.minX, rect.maxZ - rect.minZ
	local scaleX, scaleZ = targetWidth / sourceWidth, targetDepth / sourceDepth
	local targetCenterX, targetCenterZ = (rect.minX + rect.maxX) * 0.5, (rect.minZ + rect.maxZ) * 0.5
	for index, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local relative = origin:ToObjectSpace(descendant.CFrame)
			local sizeXScale, sizeZScale = scaleX, scaleZ
			if math.abs(relative.RightVector.X) < math.abs(relative.RightVector.Z) then
				sizeXScale, sizeZScale = scaleZ, scaleX
			end
			descendant.Size = Vector3.new(
				math.max(0.05, descendant.Size.X * sizeXScale),
				descendant.Size.Y,
				math.max(0.05, descendant.Size.Z * sizeZScale)
			)
			local offset = relative.Position
			descendant.CFrame = origin * CFrame.new(
				targetCenterX + (offset.X - sourceCenterX) * scaleX,
				offset.Y,
				targetCenterZ + (offset.Z - sourceCenterZ) * scaleZ
			) * relative.Rotation
		elseif descendant:IsA("Attachment") then
			local position = descendant.Position
			descendant.Position = Vector3.new(position.X * scaleX, position.Y, position.Z * scaleZ)
		end
		if index % 500 == 0 then
			task.wait()
		end
	end
	local fixedMinX, fixedMaxX, fixedMinZ, fixedMaxZ = localBounds(model, origin)
	assert(
		math.abs(fixedMinX - rect.minX) < 0.08
			and math.abs(fixedMaxX - rect.maxX) < 0.08
			and math.abs(fixedMinZ - rect.minZ) < 0.08
			and math.abs(fixedMaxZ - rect.maxZ) < 0.08,
		"Fitted B1 wing does not align to its footprint rectangle"
	)
	return scaleX, scaleZ
end

-- Deepens only the U crossbar toward the open courtyard so it overlaps both
-- side wings at their shared edge. The far/outer edge remains pinned to the
-- traced polygon edge; no geometry is shifted beyond the outside footprint.
local function extendB1CrossbarIntoArms(model: Model, rect: Rect, origin: CFrame, overlapStuds: number): number
	local minX, maxX, minZ, maxZ = localBounds(model, origin)
	local sourceDepth = maxZ - minZ
	assert(sourceDepth > 1 and math.abs(maxZ - rect.maxZ) < 0.08, "B1 crossbar must be fitted to its outer edge first")
	local depthScale = (sourceDepth + overlapStuds) / sourceDepth
	local parts: { BasePart } = {}
	local attachments: { Attachment } = {}
	local scalesByPart: { [BasePart]: { x: number, z: number } } = {}

	for index, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local relative = origin:ToObjectSpace(descendant.CFrame)
			local sizeXScale, sizeZScale = 1, 1
			if math.abs(relative.RightVector.Z) > math.abs(relative.LookVector.Z) then
				sizeXScale = depthScale
			else
				sizeZScale = depthScale
			end
			descendant.Size = Vector3.new(
				math.max(0.05, descendant.Size.X * sizeXScale),
				descendant.Size.Y,
				math.max(0.05, descendant.Size.Z * sizeZScale)
			)
			local position = relative.Position
			local pinnedZ = rect.maxZ - (rect.maxZ - position.Z) * depthScale
			descendant.CFrame = origin * CFrame.new(position.X, position.Y, pinnedZ) * relative.Rotation
			scalesByPart[descendant] = { x = sizeXScale, z = sizeZScale }
			table.insert(parts, descendant)
		elseif descendant:IsA("Attachment") and descendant.Parent:IsA("BasePart") then
			table.insert(attachments, descendant)
		end
		if index % 500 == 0 then
			task.wait()
		end
	end

	for _, attachment in ipairs(attachments) do
		local scale = scalesByPart[attachment.Parent :: BasePart]
		if scale then
			local position = attachment.Position
			attachment.Position = Vector3.new(position.X * scale.x, position.Y, position.Z * scale.z)
		end
	end

	local _, _, _, expandedMaxZ = localBounds(model, origin)
	local correctionZ = rect.maxZ - expandedMaxZ
	if math.abs(correctionZ) > 0.001 then
		local correction = origin:VectorToWorldSpace(Vector3.new(0, 0, correctionZ))
		for _, part in ipairs(parts) do
			part.CFrame = CFrame.new(part.Position + correction) * part.CFrame.Rotation
		end
	end

	local fixedMinX, fixedMaxX, fixedMinZ, fixedMaxZ = localBounds(model, origin)
	assert(
		math.abs(fixedMinX - rect.minX) < 0.1
			and math.abs(fixedMaxX - rect.maxX) < 0.1
			and math.abs(fixedMaxZ - rect.maxZ) < 0.1,
		"B1 crossbar overlap moved its outer footprint edge"
	)
	local actualOverlap = rect.minZ - fixedMinZ
	assert(actualOverlap >= overlapStuds * 0.75, "B1 crossbar does not overlap both side-wing joins")
	return actualOverlap
end

local function getFloorIndex(instance: Instance, stopAt: Instance): number?
	local current: Instance? = instance
	while current and current ~= stopAt do
		local index = current:GetAttribute("FloorIndex")
		if typeof(index) == "number" then
			return index
		end
		local digits = string.match(current.Name, "^WalkableFloor_(%d+)")
			or string.match(current.Name, "^Floor_(%d+)")
			or string.match(current.Name, "_Floor_(%d+)")
			or string.match(current.Name, "_F(%d+)")
			or string.match(current.Name, "^F(%d+)_")
		if digits then
			return tonumber(digits)
		end
		current = current.Parent
	end
	return nil
end

local function collectWalkableLevels(model: Model, frame: CFrame): { [number]: number }
	local sums: { [number]: number } = {}
	local counts: { [number]: number } = {}
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local digits = string.match(descendant.Name, "^WalkableFloor_(%d+)")
			local level = if digits then tonumber(digits) else nil
			if level then
				local y = frame:PointToObjectSpace(descendant.Position).Y
				sums[level] = (sums[level] or 0) + y
				counts[level] = (counts[level] or 0) + 1
			end
		end
	end
	local levels: { [number]: number } = {}
	for level, sum in pairs(sums) do
		levels[level] = sum / (counts[level] :: number)
	end
	return levels
end

local function inferFloorStep(levels: { [number]: number }, model: Model): number
	local indices: { number } = {}
	for index in pairs(levels) do
		table.insert(indices, index)
	end
	table.sort(indices)
	local total, intervals = 0, 0
	for index = 2, #indices do
		local difference = (levels[indices[index]] - levels[indices[index - 1]]) / (indices[index] - indices[index - 1])
		if difference > 5 then
			total += difference
			intervals += 1
		end
	end
	if intervals > 0 then
		return total / intervals
	end
	local configured = model:GetAttribute("FloorClearHeightStuds")
	if typeof(configured) == "number" and configured > 5 then
		return configured + 0.8
	end
	return 12.8
end

local function renamedFloorToken(name: string, fromStory: number, toStory: number): string
	local from = string.format("%02d", fromStory)
	local to = string.format("%02d", toStory)
	name = string.gsub(name, "^F" .. from .. "_", "F" .. to .. "_")
	name = string.gsub(name, "_F" .. from .. "([^%d])", "_F" .. to .. "%1")
	name = string.gsub(name, "_Floor_" .. from, "_Floor_" .. to)
	name = string.gsub(name, "^Floor_" .. from, "Floor_" .. to)
	name = string.gsub(name, "WalkableFloor_" .. from, "WalkableFloor_" .. to)
	return name
end

local function isRoofFeature(instance: Instance): boolean
	local name = string.lower(instance.Name)
	for _, token in ipairs({ "roof", "crown", "clerestory", "parapet", "rooftop", "water_tank", "watertank", "lantern", "pavilion" }) do
		if string.find(name, token, 1, true) then
			return true
		end
	end
	return false
end

local function adjustStoryGeometry(model: Model, sourceFrame: CFrame, confirmedStories: number)
	local sourceStories = model:GetAttribute("EstimatedStories")
	if typeof(sourceStories) ~= "number" then
		sourceStories = 1
	end
	local maxIndexedStory = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		local floorIndex = getFloorIndex(descendant, model)
		if floorIndex then
			maxIndexedStory = math.max(maxIndexedStory, floorIndex)
		end
	end
	sourceStories = math.max(sourceStories, maxIndexedStory)
	local levels = collectWalkableLevels(model, sourceFrame)
	local floorStep = inferFloorStep(levels, model)
	local sourceTopY = levels[sourceStories] or levels[maxIndexedStory] or 0
	local packagesToDuplicate: { Instance } = {}
	if confirmedStories > sourceStories then
		for _, descendant in ipairs(model:GetDescendants()) do
			if getFloorIndex(descendant, model) == sourceStories then
				local parentIndex = descendant.Parent and getFloorIndex(descendant.Parent, model)
				if parentIndex ~= sourceStories and (descendant:IsA("Model") or descendant:IsA("Folder") or descendant:IsA("BasePart")) then
					table.insert(packagesToDuplicate, descendant)
				end
			end
		end
		assert(#packagesToDuplicate > 0, "Cannot extend source building floor packages to confirmed story count")
		for storyIndex = sourceStories + 1, confirmedStories do
			for _, package in ipairs(packagesToDuplicate) do
				if package.Parent then
					local clone = package:Clone()
					clone.Name = renamedFloorToken(clone.Name, sourceStories, storyIndex) .. string.format("_AddedFloor_%02d", storyIndex)
					clone.Parent = package.Parent
					for _, descendant in ipairs(clone:GetDescendants()) do
						local index = descendant:GetAttribute("FloorIndex")
						if typeof(index) == "number" then
							descendant:SetAttribute("FloorIndex", storyIndex)
						end
						descendant.Name = renamedFloorToken(descendant.Name, sourceStories, storyIndex)
						if descendant:GetAttribute("FloorIndex") == nil and getFloorIndex(descendant, clone) == sourceStories then
							descendant:SetAttribute("FloorIndex", storyIndex)
						end
						descendant:SetAttribute("GeneratedStoryIndex", storyIndex)
						if descendant:IsA("BasePart") then
							descendant.CFrame = CFrame.new(0, floorStep * (storyIndex - sourceStories), 0) * descendant.CFrame
						end
					end
					if clone:IsA("BasePart") then
						clone.CFrame = CFrame.new(0, floorStep * (storyIndex - sourceStories), 0) * clone.CFrame
					end
					clone:SetAttribute("FloorIndex", storyIndex)
					clone:SetAttribute("GeneratedStoryIndex", storyIndex)
				end
			end
		end
	elseif confirmedStories < sourceStories then
		local toRemove: { Instance } = {}
		for _, descendant in ipairs(model:GetDescendants()) do
			local floorIndex = getFloorIndex(descendant, model)
			if floorIndex and floorIndex > confirmedStories then
				local parentIndex = descendant.Parent and getFloorIndex(descendant.Parent, model)
				if parentIndex == nil or parentIndex <= confirmedStories then
					table.insert(toRemove, descendant)
				end
			end
		end
		for _, descendant in ipairs(toRemove) do
			if descendant.Parent then
				descendant:Destroy()
			end
		end
	end
	local deltaY = (confirmedStories - sourceStories) * floorStep
	if deltaY ~= 0 then
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") and getFloorIndex(descendant, model) == nil and isRoofFeature(descendant) then
				descendant.CFrame = CFrame.new(0, deltaY, 0) * descendant.CFrame
			end
		end
	end
	model:SetAttribute("EstimatedStories", confirmedStories)
	model:SetAttribute("ConfirmedStories", confirmedStories)
	model:SetAttribute("WalkableFloorCount", confirmedStories)
	model:SetAttribute("StoryCountIncludesGroundFloor", true)
	model:SetAttribute("StoryEstimateStatus", "user_confirmed_2026_11_01")
	model:SetAttribute("StoryCountGeometryAdjusted", true)
	model:SetAttribute("StorySourceCount", sourceStories)
	model:SetAttribute("StoryStepStuds", round(floorStep))
	model:SetAttribute("SourceTopFloorY", round(sourceTopY))
end

local function getFloorBounds(model: Model, level: number): (Rect?, number?, number?, Color3?, Enum.Material?)
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	local floorY: number? = nil
	local thickness: number? = nil
	local color: Color3? = nil
	local material: Enum.Material? = nil
	local prefix = string.format("WalkableFloor_%02d", level)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and string.sub(descendant.Name, 1, #prefix) == prefix then
			local partFrame = descendant.CFrame
			local half = descendant.Size * 0.5
			local extentX = math.abs(partFrame.RightVector.X) * half.X + math.abs(partFrame.UpVector.X) * half.Y + math.abs(partFrame.LookVector.X) * half.Z
			local extentZ = math.abs(partFrame.RightVector.Z) * half.X + math.abs(partFrame.UpVector.Z) * half.Y + math.abs(partFrame.LookVector.Z) * half.Z
			minX, maxX = math.min(minX, partFrame.Position.X - extentX), math.max(maxX, partFrame.Position.X + extentX)
			minZ, maxZ = math.min(minZ, partFrame.Position.Z - extentZ), math.max(maxZ, partFrame.Position.Z + extentZ)
			floorY = floorY or partFrame.Position.Y
			thickness = thickness or descendant.Size.Y
			color = color or descendant.Color
			material = material or descendant.Material
		end
	end
	if minX == math.huge or floorY == nil then
		return nil, nil, nil, nil, nil
	end
	return { minX = minX, maxX = maxX, minZ = minZ, maxZ = maxZ }, floorY, thickness, color, material
end

local function buildB1SeamConnectors(parent: Model, origin: CFrame, regions: { Rect }, stories: number): number
	local link = parent:FindFirstChild("B1_BuildRegion_ConnectingBar")
	assert(link and link:IsA("Model"), "B1 crossbar is missing")
	local seamRoot = Instance.new("Model")
	seamRoot.Name = "B1_FloorSeamConnectors"
	seamRoot:SetAttribute("InteriorCourtyardPreserved", true)
	seamRoot.Parent = parent
	local connectors = 0
	local linkRect = regions[3]
	for wingIndex = 1, 2 do
		local armName = if wingIndex == 1 then "B1_BuildRegion_WestArm" else "B1_BuildRegion_EastArm"
		local arm = parent:FindFirstChild(armName)
		assert(arm and arm:IsA("Model"), "Missing B1 side arm " .. armName)
		local armRect = regions[wingIndex]
		for level = 1, stories do
			local armFloor, armY, armThickness, armColor, armMaterial = getFloorBounds(arm, level)
			local linkFloor, linkY, linkThickness, linkColor, linkMaterial = getFloorBounds(link, level)
			if armFloor and linkFloor and armY and linkY then
				local spanX0 = math.max(armFloor.minX, linkFloor.minX, origin.Position.X + armRect.minX + 0.4)
				local spanX1 = math.min(armFloor.maxX, linkFloor.maxX, origin.Position.X + armRect.maxX - 0.4)
				local z0 = math.min(armFloor.maxZ, linkFloor.minZ)
				local z1 = math.max(armFloor.maxZ, linkFloor.minZ)
				if spanX1 - spanX0 > 2 and z1 - z0 > 0.05 then
					local thickness = math.clamp(armThickness or linkThickness or 0.8, 0.2, 1.2)
					local localCenter = Vector3.new((spanX0 + spanX1) * 0.5, (armY + linkY) * 0.5, (z0 + z1) * 0.5)
					local bridge = Instance.new("Part")
					bridge.Name = string.format("Join_B1_Arm_%d_Floor_%02d", wingIndex, level)
					bridge.Size = Vector3.new(spanX1 - spanX0 + 0.08, thickness, z1 - z0 + 0.08)
					bridge.CFrame = origin * CFrame.new(origin:PointToObjectSpace(localCenter))
					bridge.Anchored = true
					bridge.CanCollide = true
					bridge.CanTouch = false
					bridge.CanQuery = true
					bridge.Material = armMaterial or linkMaterial or Enum.Material.Concrete
					bridge.Color = armColor or linkColor or Color3.fromRGB(180, 178, 169)
					bridge:SetAttribute("FloorIndex", level)
					bridge:SetAttribute("B1SeamConnector", true)
					bridge.Parent = seamRoot
					connectors += 1
				end
			end
		end
	end
	seamRoot:SetAttribute("ConnectorPartCount", connectors)
	return connectors
end

local function removeB1SourceEntrance(model: Model)
	local sourceEntrance = model:FindFirstChild("Entrance")
	if sourceEntrance then
		sourceEntrance:Destroy()
	end

	local architectureDetails = model:FindFirstChild("ArchitectureDetails")
	if not architectureDetails then
		return
	end
	local remove: { Instance } = {}
	for _, child in ipairs(architectureDetails:GetChildren()) do
		local name = child.Name
		if name == "EntryCanopy"
			or name == "EntryCanopyFascia"
			or string.sub(name, 1, #"EntranceLamp_") == "EntranceLamp_" then
			table.insert(remove, child)
		end
	end
	for _, child in ipairs(remove) do
		child:Destroy()
	end
end

local function createB1EntrancePart(
	parent: Model,
	origin: CFrame,
	name: string,
	size: Vector3,
	localPosition: Vector3,
	color: Color3,
	material: Enum.Material,
	canCollide: boolean
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = origin * CFrame.new(localPosition.X, localPosition.Y, localPosition.Z)
	part.Anchored = true
	part.CanCollide = canCollide
	part.CanTouch = false
	part.CanQuery = canCollide
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("B1MainEntrancePart", true)
	part.Parent = parent
	return part
end

local function worldBounds(part: BasePart): (number, number, number, number, number, number)
	local half = part.Size * 0.5
	local extentX = math.abs(part.CFrame.RightVector.X) * half.X
		+ math.abs(part.CFrame.UpVector.X) * half.Y
		+ math.abs(part.CFrame.LookVector.X) * half.Z
	local extentY = math.abs(part.CFrame.RightVector.Y) * half.X
		+ math.abs(part.CFrame.UpVector.Y) * half.Y
		+ math.abs(part.CFrame.LookVector.Y) * half.Z
	local extentZ = math.abs(part.CFrame.RightVector.Z) * half.X
		+ math.abs(part.CFrame.UpVector.Z) * half.Y
		+ math.abs(part.CFrame.LookVector.Z) * half.Z
	return part.Position.X - extentX, part.Position.X + extentX,
		part.Position.Y - extentY, part.Position.Y + extentY,
		part.Position.Z - extentZ, part.Position.Z + extentZ
end

local function makeB1DoorWallSegment(
	wall: BasePart,
	axis: string,
	name: string,
	minX: number,
	maxX: number,
	minY: number,
	maxY: number
): BasePart?
	local width = maxX - minX
	local height = maxY - minY
	if width < 0.1 or height < 0.1 then
		return nil
	end
	local segment = wall:Clone()
	segment.Name = name
	segment:SetAttribute("B1MainDoorCutSegment", true)
	local size = wall.Size
	if axis == "X" then
		size = Vector3.new(width, height, wall.Size.Z)
	else
		size = Vector3.new(wall.Size.X, height, width)
	end
	segment.Size = size
	segment.CFrame = CFrame.new((minX + maxX) * 0.5, (minY + maxY) * 0.5, wall.Position.Z) * wall.CFrame.Rotation
	segment.Parent = wall.Parent
	return segment
end

local function cutB1MainDoorOpening(
	crossbar: Model,
	origin: CFrame,
	rect: Rect,
	centerX: number,
	clearWidth: number,
	clearHeight: number
): number
	local edgePoint = origin:PointToWorldSpace(Vector3.new(centerX, 0, rect.maxZ))
	local outerZ = edgePoint.Z
	local openingMinX = edgePoint.X - clearWidth * 0.5
	local openingMaxX = edgePoint.X + clearWidth * 0.5
	local floorY = 0.8
	local openingTopY = floorY + clearHeight
	local candidateWalls: { BasePart } = {}
	for _, descendant in ipairs(crossbar:GetDescendants()) do
		if descendant:IsA("BasePart") and string.sub(descendant.Name, 1, #"OuterWall_Floor_01_") == "OuterWall_Floor_01_" then
			local minX, maxX, minY, maxY, minZ, maxZ = worldBounds(descendant)
			local rightX = math.abs(descendant.CFrame.RightVector.X)
			local lookX = math.abs(descendant.CFrame.LookVector.X)
			local longAxis = if rightX >= lookX then "X" else "Z"
			local horizontalSpan = maxX - minX
			if descendant.CanCollide
				and horizontalSpan > clearWidth + 8
				and maxY > openingTopY
				and minY <= floorY + 1
				and minZ < outerZ + 0.75
				and maxZ > outerZ - 1.5
				and math.abs(descendant.CFrame.UpVector.Y) > 0.99
				and (if longAxis == "X" then rightX else lookX) > 0.99 then
				table.insert(candidateWalls, descendant)
			end
		end
	end
	assert(#candidateWalls == 1, "B1 crossbar must have exactly one ground-floor outer wall for its main doorway")

	local wall = candidateWalls[1]
	local wallMinX, wallMaxX, wallMinY, wallMaxY = worldBounds(wall)
	assert(openingMinX > wallMinX + 2 and openingMaxX < wallMaxX - 2, "B1 main doorway does not fit within the crossbar wall")
	local longAxis = if math.abs(wall.CFrame.RightVector.X) >= math.abs(wall.CFrame.LookVector.X) then "X" else "Z"
	local longAxisWorldX = if longAxis == "X" then math.abs(wall.CFrame.RightVector.X) else math.abs(wall.CFrame.LookVector.X)
	assert(longAxisWorldX > 0.99, "B1 crossbar outer doorway wall must run parallel to the crossbar")
	local addedParts = 0
	local left = makeB1DoorWallSegment(wall, longAxis, "OuterWall_Floor_01_LeftOfMainDoor", wallMinX, openingMinX, wallMinY, wallMaxY)
	local right = makeB1DoorWallSegment(wall, longAxis, "OuterWall_Floor_01_RightOfMainDoor", openingMaxX, wallMaxX, wallMinY, wallMaxY)
	local lintel = makeB1DoorWallSegment(wall, longAxis, "OuterWall_Floor_01_MainDoorLintel", openingMinX, openingMaxX, openingTopY, wallMaxY)
	if left then addedParts += 1 end
	if right then addedParts += 1 end
	if lintel then addedParts += 1 end
	local wallParent = wall.Parent
	wall:Destroy()
	local netPartDelta = addedParts - 1

	local decorationsToRemove: { BasePart } = {}
	for _, descendant in ipairs(crossbar:GetDescendants()) do
		if descendant:IsA("BasePart") and not descendant.CanCollide then
			local minX, maxX, minY, maxY, minZ, maxZ = worldBounds(descendant)
			if maxX > openingMinX and minX < openingMaxX
				and maxY > floorY and minY < openingTopY
				and minZ < outerZ + 0.75 and maxZ > outerZ - 1.5 then
				table.insert(decorationsToRemove, descendant)
			end
		end
	end
	for _, decoration in ipairs(decorationsToRemove) do
		decoration:Destroy()
		netPartDelta -= 1
	end
	wallParent:SetAttribute("B1MainDoorOpeningCut", true)
	wallParent:SetAttribute("B1MainDoorClearWidthStuds", clearWidth)
	return netPartDelta
end

local function mergeB1SectionsIntoOneBody(body: Model, sectionNames: { string })
	for _, sectionName in ipairs(sectionNames) do
		local section = body:FindFirstChild(sectionName)
		assert(section and section:IsA("Model"), "Missing B1 source section to merge: " .. sectionName)
		for _, child in ipairs(section:GetChildren()) do
			child.Parent = body
		end
		section:Destroy()
	end
	body:SetAttribute("AssemblyType", "single_connected_U_shaped_building")
	body:SetAttribute("SourceSectionModelsMerged", #sectionNames)
	body:SetAttribute("GeometryRegionsAreImplementationOnly", true)
end

-- The U's opening is on its min-Z side. Its main entrance belongs at the center
-- of the connected crossbar's max-Z exterior edge, opposite the open end.
local function buildB1MainEntrance(parent: Model, origin: CFrame, crossbar: Model, crossbarRect: Rect): (number, number)
	local centerX = (crossbarRect.minX + crossbarRect.maxX) * 0.5
	local outerEdgeZ = crossbarRect.maxZ
	local clearWidth = 12
	local doorClearHeight = 8.9
	local doorPlaneZ = outerEdgeZ - 0.7
	local wallPartDelta = cutB1MainDoorOpening(crossbar, origin, crossbarRect, centerX, clearWidth, doorClearHeight)
	local portalWidth = math.min(24, crossbarRect.maxX - crossbarRect.minX)
	local portal = Instance.new("Model")
	portal.Name = "B1_MainEntrance"
	portal:SetAttribute("EntranceLocation", "center_of_connected_crossbar_outer_edge_maxZ")
	portal:SetAttribute("EntranceSide", "outside_of_connected_crossbar_opposite_the_U_opening")
	portal:SetAttribute("EntryDirection", "from_crossbar_maxZ_toward_courtyard_minZ")
	portal:SetAttribute("DoorCenterWorld", origin:PointToWorldSpace(Vector3.new(centerX, 0, doorPlaneZ)))
	portal:SetAttribute("DoorwayClearWidthStuds", clearWidth)
	portal:SetAttribute("DoorwayClearHeightStuds", doorClearHeight)
	portal:SetAttribute("CourtyardRemainsOpen", true)
	portal.Parent = parent

	local concrete = Color3.fromRGB(224, 222, 211)
	local concreteDark = Color3.fromRGB(183, 183, 176)
	local campusBlue = Color3.fromRGB(20, 91, 158)
	local portalDepth = 8
	local portalCenterZ = outerEdgeZ + portalDepth * 0.5 - 0.35
	local outerColumnOffset = portalWidth * 0.5 - 1.1
	local jambOffset = clearWidth * 0.5 + 0.45
	local partCount = 0
	local function add(name: string, size: Vector3, localPosition: Vector3, color: Color3, material: Enum.Material, canCollide: boolean)
		createB1EntrancePart(portal, origin, name, size, localPosition, color, material, canCollide)
		partCount += 1
	end

	add(
		"MainEntranceThreshold",
		Vector3.new(portalWidth, 0.8, portalDepth),
		Vector3.new(centerX, 0.4, portalCenterZ),
		concreteDark,
		Enum.Material.Concrete,
		true
	)
	add("PortalPillar_Left", Vector3.new(1.4, 12, 1.2), Vector3.new(centerX - outerColumnOffset, 6, outerEdgeZ + 3.6), concrete, Enum.Material.Concrete, true)
	add("PortalPillar_Right", Vector3.new(1.4, 12, 1.2), Vector3.new(centerX + outerColumnOffset, 6, outerEdgeZ + 3.6), concrete, Enum.Material.Concrete, true)
	add("DoorJamb_Left", Vector3.new(0.9, 8.9, 1), Vector3.new(centerX - jambOffset, 4.45, doorPlaneZ), concrete, Enum.Material.Concrete, true)
	add("DoorJamb_Right", Vector3.new(0.9, 8.9, 1), Vector3.new(centerX + jambOffset, 4.45, doorPlaneZ), concrete, Enum.Material.Concrete, true)
	add("DoorHeader", Vector3.new(clearWidth + 2, 1.2, 1), Vector3.new(centerX, 10.3, doorPlaneZ), concrete, Enum.Material.Concrete, true)
	add("EntryCanopy", Vector3.new(portalWidth, 0.8, portalDepth), Vector3.new(centerX, 11.2, portalCenterZ), campusBlue, Enum.Material.SmoothPlastic, true)
	add("EntryCanopyFascia", Vector3.new(portalWidth, 0.65, 0.45), Vector3.new(centerX, 10.8, outerEdgeZ + 0.25), campusBlue, Enum.Material.SmoothPlastic, false)

	local nameplate = createB1EntrancePart(
		portal,
		origin,
		"B1_EntranceNameplate",
		Vector3.new(8, 1.1, 0.3),
		Vector3.new(centerX, 10.05, outerEdgeZ + 0.22),
		campusBlue,
		Enum.Material.SmoothPlastic,
		false
	)
	partCount += 1
	local surface = Instance.new("SurfaceGui")
	surface.Name = "EntranceSign"
	surface.Face = Enum.NormalId.Back
	surface.LightInfluence = 0
	surface.Parent = nameplate
	local label = Instance.new("TextLabel")
	label.Name = "BuildingID"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "B1"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = surface

	parent:SetAttribute("B1MainEntranceCount", 1)
	parent:SetAttribute("B1MainEntranceCenterX", centerX)
	parent:SetAttribute("B1MainEntranceOuterEdgeZ", outerEdgeZ)
	parent:SetAttribute("B1MainEntranceClearWidthStuds", clearWidth)
	return partCount, wallPartDelta
end

local function getScriptCount(model: Model): number
	local count = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
			count += 1
		end
	end
	return count
end

local function updateIdentity(model: Model, templateId: string, buildingId: string, displayName: string)
	local sourceDisplayName = model:GetAttribute("BuildingDisplayName")
	model.Name = buildingId
	model:SetAttribute("CampusBuildingId", buildingId)
	model:SetAttribute("MapLabel", displayName)
	model:SetAttribute("BuildingDisplayName", displayName)
	model:SetAttribute("PortedFromBuildingId", templateId)
	model:SetAttribute("PortUsesVisualTemplateOnly", templateId ~= buildingId)
	model:SetAttribute("FootprintConfidence", "pixel_geometry_estimate_not_surveyed")
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:GetAttribute("CampusBuildingId") ~= nil then
			descendant:SetAttribute("CampusBuildingId", buildingId)
		end
		if descendant:GetAttribute("BuildingDisplayName") ~= nil then
			descendant:SetAttribute("BuildingDisplayName", displayName)
		end
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			if typeof(sourceDisplayName) == "string" and descendant.Text == sourceDisplayName then
				descendant.Text = displayName
			end
		end
	end
end

local function removeNameboard(model: Model)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant.Name == "BuildingNameSignHousing" or descendant.Name == "ProtrudingBuildingName" or string.sub(descendant.Name, 1, 12) == "SignStandOff_" then
			descendant:Destroy()
		end
	end
end

local function transformClone(
	model: Model,
	sourceFrame: CFrame,
	targetFrame: CFrame,
	targetWidth: number,
	targetDepth: number,
	templateId: string,
	buildingId: string,
	displayName: string
): (number, number, number)
	local minX, maxX, minZ, maxZ = localBounds(model, sourceFrame)
	local sourceWidth = maxX - minX
	local sourceDepth = maxZ - minZ
	local scaleX = targetWidth / sourceWidth
	local scaleZ = targetDepth / sourceDepth
	assert(scaleX > 0 and scaleZ > 0, "Invalid scale for " .. buildingId)

	local descendants = model:GetDescendants()
	for index, descendant in ipairs(descendants) do
		if descendant:IsA("BasePart") then
			local relative = sourceFrame:ToObjectSpace(descendant.CFrame)
			local position = relative.Position
			local xScale = scaleX
			local zScale = scaleZ
			if math.abs(relative.RightVector.X) < math.abs(relative.RightVector.Z) then
				xScale, zScale = scaleZ, scaleX
			end
			descendant.Size = Vector3.new(
				math.max(0.05, descendant.Size.X * xScale),
				descendant.Size.Y,
				math.max(0.05, descendant.Size.Z * zScale)
			)
			descendant.CFrame = targetFrame * CFrame.new(position.X * scaleX, position.Y, position.Z * scaleZ) * relative.Rotation
		elseif descendant:IsA("Attachment") then
			local position = descendant.Position
			descendant.Position = Vector3.new(position.X * scaleX, position.Y, position.Z * scaleZ)
		end
		if index % 500 == 0 then
			task.wait()
		end
	end
	updateIdentity(model, templateId, buildingId, displayName)
	return scaleX, scaleZ, #descendants
end

local function makeSourceFrame(sourceModel: Model, sourceOrigin: Vector3): CFrame
	-- The Studio ModuleScript may be stale relative to the built scene, so use
	-- the source model's floor plane instead of metric manifest centers.
	for _, descendant in ipairs(sourceModel:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "WalkableFloor_01" then
			return CFrame.new(descendant.Position.X, sourceOrigin.Y, descendant.Position.Z) * descendant.CFrame.Rotation
		end
	end
	local pivot = sourceModel:GetPivot()
	return CFrame.new(pivot.Position.X, sourceOrigin.Y, pivot.Position.Z) * pivot.Rotation
end

local function countParts(root: Instance): (number, number, number)
	local parts, unanchored, scripts = 0, 0, 0
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") then
			parts += 1
			if not descendant.Anchored then
				unanchored += 1
			end
		elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
			scripts += 1
		end
	end
	return parts, unanchored, scripts
end

-- manifestOverride accepts a fresh Studio snapshot when require() still holds
-- an older table after Rojo has synchronized CampusPreviewManifest.Source.
function PixelBuildingPorter.Build(parent: Instance, destinationOrigin: CFrame, sourceRoot: Model?, outputName: string?, manifestOverride: any?): (Model?, any)
	assert(typeof(parent) == "Instance", "A parent Instance is required")
	assert(typeof(destinationOrigin) == "CFrame", "A destination CFrame is required")
	local manifest = manifestOverride or PixelManifest
	assert(type(manifest) == "table" and type(manifest.features) == "table", "A valid CampusPreviewManifest is required")
	local outlineRoot = parent:FindFirstChild("FNABK_Campus_PixelPreview_v1")
	if outlineRoot then
		local outlineMirror = outlineRoot:GetAttribute("HorizontalMirrorApplied")
		if typeof(outlineMirror) == "boolean" then
			assert(
				outlineMirror == (manifest.horizontalMirrorApplied == true),
				"CampusPreviewManifest mirror state does not match the existing pixel outline; refresh the manifest before building"
			)
		end
		local outlineScale = outlineRoot:GetAttribute("PreviewStudsPerPixel")
		if typeof(outlineScale) == "number" then
			assert(
				math.abs(outlineScale - manifest.previewStudsPerPixel) < 1e-6,
				"CampusPreviewManifest scale does not match the existing pixel outline; refresh the manifest before building"
			)
		end
	end
	local resolvedSource = sourceRoot or parent:FindFirstChild(SOURCE_ROOT_NAME)
	assert(resolvedSource and resolvedSource:IsA("Model"), "Build the detached v6 Phase C source first: " .. SOURCE_ROOT_NAME)
	assert(resolvedSource:GetAttribute("BuildComplete") == true, "Source Phase C campus is incomplete")
	assert(resolvedSource:GetAttribute("GameplayIntegrated") == false, "Refusing to port from a gameplay-integrated map")
	assert(resolvedSource:GetAttribute("GeneratedBy") == "CampusBuilder PhaseC", "Source is not the generated detached Phase C campus")
	assert(resolvedSource:GetAttribute("ArchitectureStyleRevision") == "VN_Campus_v8_SchoolBlockSilhouettes", "Source Phase C architecture revision is not the reviewed v8 model")

	local name = outputName or DEFAULT_OUTPUT_NAME
	assert(parent:FindFirstChild(name) == nil, name .. " already exists; refusing to replace or delete it")
	local sourceOrigin = resolvedSource:GetAttribute("LocalOriginWorld")
	assert(typeof(sourceOrigin) == "Vector3", "Source Phase C root has no LocalOriginWorld")
	local sourceModels = getSourceModels(resolvedSource)
	local root = Instance.new("Model")
	root.Name = name
	root:SetAttribute("PreviewOnly", true)
	root:SetAttribute("GeometryStage", "PhaseC_PixelBuildingPort")
	root:SetAttribute("SourceStatus", manifest.status)
	root:SetAttribute("PreviewStudsPerPixel", manifest.previewStudsPerPixel)
	root:SetAttribute("HorizontalMirrorApplied", manifest.horizontalMirrorApplied == true)
	root:SetAttribute("MetersPerPixel", "null")
	root:SetAttribute("GeographicNorthAligned", false)
	root:SetAttribute("GameplayIntegrated", false)
	root:SetAttribute("GameplayScriptsIncluded", false)
	root:SetAttribute("CollisionEnabled", true)
	root:SetAttribute("StoryCountSource", "user_confirmed_2026_11_01")
	root:SetAttribute("StoryCountIncludesGroundFloor", true)
	root:SetAttribute("StoryCountOverrideCount", 23)
	root:SetAttribute("SourceModelRoot", resolvedSource:GetFullName())
	root:SetAttribute("PreviewOriginWorld", destinationOrigin.Position)
	root:SetAttribute("BuildComplete", false)
	root.Parent = parent

	local ok, result = pcall(function()
		local buildings = Instance.new("Folder")
		buildings.Name = "Buildings"
		buildings.Parent = root
		local logicalCount = 0
		local exactIdCount = 0
		local templateCount = 0
		local connectedBodyCount = 0
		local b1AxisCorrectionCount = 0
		local b1CornerOverlapStuds = 0
		local totalPartCount = 0
		local b1SeamConnectorCount = 0
		local b1MainEntrancePartCount = 0
		local portEntries = {}

		for _, feature in ipairs(manifest.features) do
			if feature.category == "building" then
				local templateId = TEMPLATE_BY_ID[feature.id] or feature.id
				local sourceModel = sourceModels[templateId]
				assert(sourceModel, "No existing Phase C source model for " .. feature.id .. " (template " .. templateId .. ")")
				local targetPolygon = feature.polygonStuds :: { Point2 }
				local displayName = DISPLAY_NAME_BY_ID[feature.id] or (sourceModel:GetAttribute("BuildingDisplayName") :: string)
				local confirmedStories = CONFIRMED_STORIES_BY_ID[feature.id]
				assert(confirmedStories, "No user-confirmed story count for " .. feature.id)
				local isWorkshop = feature.id == "C1" or feature.id == "C2" or feature.id == "C3"
				if not isWorkshop then
					assert(getScriptCount(sourceModel) == 0, "Refusing to clone a building containing scripts: " .. templateId)
				end
				local buildingModel = Instance.new("Model")
				buildingModel.Name = feature.id
				buildingModel:SetAttribute("CampusBuildingId", feature.id)
				buildingModel:SetAttribute("MapLabel", displayName)
				buildingModel:SetAttribute("BuildingDisplayName", displayName)
				buildingModel:SetAttribute("SourcePolygonVertexCount", #targetPolygon)
				buildingModel:SetAttribute("FootprintGeometrySource", "CampusPreviewManifest.polygonStuds")
				buildingModel:SetAttribute("FootprintConfidence", "pixel_geometry_estimate_not_surveyed")
				buildingModel:SetAttribute("PortedFromBuildingId", if isWorkshop then "NativeWorkshopBuildingGenerator" else templateId)
				buildingModel:SetAttribute("PortUsesVisualTemplateOnly", templateId ~= feature.id)
				buildingModel:SetAttribute("EstimatedStories", confirmedStories)
				buildingModel:SetAttribute("ConfirmedStories", confirmedStories)
				buildingModel:SetAttribute("WalkableFloorCount", confirmedStories)
				buildingModel:SetAttribute("StoryCountIncludesGroundFloor", true)
				buildingModel:SetAttribute("StoryEstimateStatus", "user_confirmed_2026_11_01")
				buildingModel.Parent = buildings

				if isWorkshop then
					local minX, maxX = math.huge, -math.huge
					local minZ, maxZ = math.huge, -math.huge
					for _, point in ipairs(targetPolygon) do
						minX, maxX = math.min(minX, point[1]), math.max(maxX, point[1])
						minZ, maxZ = math.min(minZ, point[2]), math.max(maxZ, point[2])
					end
					local targetFrame, targetWidth, targetDepth = targetFrameForPolygon(
						targetPolygon,
						destinationOrigin,
						(minX + maxX) * 0.5,
						(minZ + maxZ) * 0.5,
						true
					)
					local workshop, descendantCount = WorkshopBuildingGenerator.Build(
						buildingModel,
						targetFrame,
						targetWidth,
						targetDepth,
						feature.id,
						displayName,
						confirmedStories
					)
					local partCount = select(1, countParts(workshop))
					totalPartCount += partCount
					buildingModel:SetAttribute("WorkshopSpecialization", workshop:GetAttribute("WorkshopSpecialization"))
					buildingModel:SetAttribute("ArchitectureType", workshop:GetAttribute("ArchitectureType"))
					buildingModel:SetAttribute("ArchitectureRevision", "PixelWorkshop_v1")
					table.insert(portEntries, {
						id = feature.id, templateId = "NativeWorkshopBuildingGenerator",
						stories = confirmedStories, parts = partCount, descendants = descendantCount,
						architecture = workshop:GetAttribute("ArchitectureType"),
					})
					task.wait()
				elseif feature.id == "B1" then
					local sourceFrame = makeSourceFrame(sourceModel, sourceOrigin)
					local regions = decomposeB1(targetPolygon, manifest)
					local regionNames = { "WestArm", "EastArm", "ConnectingBar" }
					local continuousBody = Instance.new("Model")
					continuousBody.Name = "B1_ContinuousBuilding"
					continuousBody:SetAttribute("AssemblyType", "single_connected_U_shaped_building")
					continuousBody.Parent = buildingModel
					for regionIndex, rect in ipairs(regions) do
						local clone = sourceModel:Clone()
						assert(clone, "Could not clone source B1 model")
						clone.Name = "B1_BuildRegion_" .. regionNames[regionIndex]
						if regionIndex ~= 3 then
							removeNameboard(clone)
						end
						removeB1SourceEntrance(clone)
						adjustStoryGeometry(clone, sourceFrame, confirmedStories)
						local sourceMinX, sourceMaxX, sourceMinZ, sourceMaxZ = localBounds(clone, sourceFrame)
						local sourceMajorX = (sourceMaxX - sourceMinX) >= (sourceMaxZ - sourceMinZ)
						local targetFrame, targetWidth, targetDepth = rectTargetFrame(rect, destinationOrigin, sourceMajorX)
						local scaleX, scaleZ, descendantCount = transformClone(clone, sourceFrame, targetFrame, targetWidth, targetDepth, templateId, feature.id, displayName)
						local axesCorrected = alignRectFootprintAxes(clone, rect, destinationOrigin)
						local fitScaleX, fitScaleZ = fitModelToRect(clone, rect, destinationOrigin)
						local cornerOverlapStuds = if regionIndex == 3
							then extendB1CrossbarIntoArms(clone, rect, destinationOrigin, 2.25)
							else 0
						if regionIndex == 3 then
							b1CornerOverlapStuds = cornerOverlapStuds
						end
						clone.Name = "B1_BuildRegion_" .. regionNames[regionIndex]
						clone:SetAttribute("B1GeometryRegion", regionNames[regionIndex])
						clone:SetAttribute("B1FootprintAxesCorrected", axesCorrected)
						clone:SetAttribute("B1FootprintFit", if regionIndex == 3 then "outer_edge_pinned_with_inner_join_overlap" else "exact_polygon_rectangle")
						clone:SetAttribute("B1CornerOverlapStuds", round(cornerOverlapStuds))
						clone:SetAttribute("PortScaleXZ", Vector2.new(round(scaleX * fitScaleX), round(scaleZ * fitScaleZ)))
						clone.Parent = continuousBody
						local partCount = select(1, countParts(clone))
						totalPartCount += partCount
						if axesCorrected then
							b1AxisCorrectionCount += 1
						end
						table.insert(portEntries, {
							id = "B1/build_region_" .. regionIndex, templateId = templateId,
							scaleX = round(scaleX * fitScaleX), scaleZ = round(scaleZ * fitScaleZ), parts = partCount,
							descendants = descendantCount, axesCorrected = axesCorrected, fitScaleX = round(fitScaleX), fitScaleZ = round(fitScaleZ),
							cornerOverlapStuds = round(cornerOverlapStuds),
						})
						task.wait()
					end
					b1SeamConnectorCount = buildB1SeamConnectors(continuousBody, destinationOrigin, regions, confirmedStories)
					totalPartCount += b1SeamConnectorCount
					local crossbar = continuousBody:FindFirstChild("B1_BuildRegion_ConnectingBar")
					assert(crossbar and crossbar:IsA("Model"), "B1 continuous body is missing its crossbar during entrance construction")
					local doorPartDelta
					b1MainEntrancePartCount, doorPartDelta = buildB1MainEntrance(continuousBody, destinationOrigin, crossbar, regions[3])
					totalPartCount += b1MainEntrancePartCount + doorPartDelta
					mergeB1SectionsIntoOneBody(continuousBody, {
						"B1_BuildRegion_WestArm",
						"B1_BuildRegion_EastArm",
						"B1_BuildRegion_ConnectingBar",
					})
					assert(
						continuousBody:FindFirstChild("B1_BuildRegion_WestArm") == nil
							and continuousBody:FindFirstChild("B1_BuildRegion_EastArm") == nil
							and continuousBody:FindFirstChild("B1_BuildRegion_ConnectingBar") == nil,
						"B1 implementation regions must not remain as separate child models"
					)
					connectedBodyCount = 1
					continuousBody:SetAttribute("MainEntranceLocation", "center_of_connected_crossbar_outer_edge_maxZ")
					continuousBody:SetAttribute("MainEntranceClearWidthStuds", 12)
					buildingModel:SetAttribute("B1SeamConnectorCount", b1SeamConnectorCount)
					buildingModel:SetAttribute("B1MainEntrancePartCount", b1MainEntrancePartCount)
					buildingModel:SetAttribute("B1CornerOverlapStuds", round(b1CornerOverlapStuds))
					buildingModel:SetAttribute("B1AssemblyType", "single_connected_U_shaped_building")
					buildingModel:SetAttribute("B1FootprintFit", "single_connected_U_with_centered_crossbar_outer_entrance")
					buildingModel:SetAttribute("B1ConnectedBodyCount", 1)
					buildingModel:SetAttribute("B1PolygonDecompositionRegionCount", 3)
				else
					local sourceFrame = makeSourceFrame(sourceModel, sourceOrigin)
					local clone = sourceModel:Clone()
					assert(clone, "Could not clone source building model " .. templateId)
					adjustStoryGeometry(clone, sourceFrame, confirmedStories)
					local sourceMinX, sourceMaxX, sourceMinZ, sourceMaxZ = localBounds(clone, sourceFrame)
					local sourceMajorX = (sourceMaxX - sourceMinX) >= (sourceMaxZ - sourceMinZ)
					local minX, maxX = math.huge, -math.huge
					local minZ, maxZ = math.huge, -math.huge
					for _, point in ipairs(targetPolygon) do
						minX, maxX = math.min(minX, point[1]), math.max(maxX, point[1])
						minZ, maxZ = math.min(minZ, point[2]), math.max(maxZ, point[2])
					end
					local centerX, centerZ = (minX + maxX) * 0.5, (minZ + maxZ) * 0.5
					local targetFrame, targetWidth, targetDepth = targetFrameForPolygon(targetPolygon, destinationOrigin, centerX, centerZ, sourceMajorX)
					local scaleX, scaleZ, descendantCount = transformClone(clone, sourceFrame, targetFrame, targetWidth, targetDepth, templateId, feature.id, displayName)
					clone.Name = feature.id
					clone:SetAttribute("PortScaleXZ", Vector2.new(round(scaleX), round(scaleZ)))
					clone:SetAttribute("SourcePolygonVertexCount", #targetPolygon)
					clone:SetAttribute("FootprintGeometrySource", "CampusPreviewManifest.polygonStuds")
					clone:SetAttribute("ConfirmedStories", confirmedStories)
					clone:SetAttribute("StoryCountIncludesGroundFloor", true)
					clone:SetAttribute("StoryEstimateStatus", "user_confirmed_2026_11_01")
					clone.Parent = buildingModel
					local partCount = select(1, countParts(clone))
					totalPartCount += partCount
					table.insert(portEntries, {
						id = feature.id, templateId = templateId,
						stories = confirmedStories, scaleX = round(scaleX), scaleZ = round(scaleZ), parts = partCount,
						descendants = descendantCount,
					})
					task.wait()
				end

			logicalCount += 1
			if TEMPLATE_BY_ID[feature.id] then
				templateCount += 1
			else
				exactIdCount += 1
			end
		end
		end

		assert(logicalCount == 23, "Expected 23 pixel building identities")
		assert(exactIdCount == 17 and templateCount == 6, "Unexpected exact/template identity split")
		local anchoredParts, unanchoredParts, scriptCount = countParts(buildings)
		root:SetAttribute("BuildingModelCount", logicalCount)
		root:SetAttribute("ExactIDModelCount", exactIdCount)
		root:SetAttribute("TemplateDerivedModelCount", templateCount)
		root:SetAttribute("B1ConnectedBodyCount", connectedBodyCount)
		root:SetAttribute("B1AxisCorrectionCount", b1AxisCorrectionCount)
		root:SetAttribute("B1SeamConnectorCount", b1SeamConnectorCount)
		root:SetAttribute("B1MainEntranceCount", 1)
		root:SetAttribute("B1MainEntranceLocation", "center_of_connected_crossbar_outer_edge_maxZ")
		root:SetAttribute("B1AssemblyType", "single_connected_U_shaped_building")
		root:SetAttribute("B1MainEntrancePartCount", b1MainEntrancePartCount)
		root:SetAttribute("B1CornerOverlapStuds", round(b1CornerOverlapStuds))
		root:SetAttribute("GeneratedBasePartCount", anchoredParts)
		root:SetAttribute("UnanchoredBasePartCount", unanchoredParts)
		root:SetAttribute("ScriptCount", scriptCount)
		root:SetAttribute("PortedPartCountExpected", totalPartCount)
		root:SetAttribute("UnresolvedExistingIDs", "B10,B1A,B7,Facility1,Facility2,Kiosk8")
		root:SetAttribute("BuildComplete", true)
		return {
			BuildingModelCount = logicalCount,
			ExactIDModelCount = exactIdCount,
			TemplateDerivedModelCount = templateCount,
			B1ConnectedBodyCount = connectedBodyCount,
			B1AxisCorrectionCount = b1AxisCorrectionCount,
			B1CornerOverlapStuds = round(b1CornerOverlapStuds),
			B1MainEntrancePartCount = b1MainEntrancePartCount,
			BasePartCount = anchoredParts,
			UnanchoredPartCount = unanchoredParts,
			ScriptCount = scriptCount,
			PortEntries = portEntries,
		}
	end)

	if not ok then
		root:Destroy()
		return nil, tostring(result)
	end
	return root, result
end

return table.freeze(PixelBuildingPorter)
