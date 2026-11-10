--!strict
-- Generates profile-driven school facades from native Roblox parts.
local FacadeGenerator = {}
local styleResolver = require(script.Parent:WaitForChild("BuildingStyleResolver"))

local function createDetail(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, transparency: number?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = material
	part.Color = color
	part.Transparency = transparency or 0
	part.Size = size
	part.CFrame = cframe
	part.Parent = parent
	return part
end

local function addRibbon(
	parent: Instance,
	name: string,
	center: CFrame,
	span: number,
	windowHeight: number,
	panelDepth: number,
	longAxis: "x" | "z",
	style: { [string]: any },
	bayCount: number,
	outwardSign: number
)
	if span < 4 or windowHeight < 1.5 then
		return
	end
	local backingSize = if longAxis == "x" then Vector3.new(span, windowHeight + 0.42, 0.28) else Vector3.new(0.28, windowHeight + 0.42, span)
	local glassSize = if longAxis == "x" then Vector3.new(span - 0.48, windowHeight - 0.32, panelDepth) else Vector3.new(panelDepth, windowHeight - 0.32, span - 0.48)
	createDetail(parent, name .. "_WarmFrame", backingSize, center, style.trimColor3, Enum.Material.SmoothPlastic)
	local paneOffset = if longAxis == "x" then CFrame.new(0, 0, outwardSign * 0.19) else CFrame.new(outwardSign * 0.19, 0, 0)
	local glass = createDetail(parent, name .. "_Glass", glassSize, center * paneOffset, style.windowColor3, Enum.Material.Glass, 0.13)
	glass:SetAttribute("FacadeRole", "DecorativeWindowGlazing")
	local mullionCount = math.clamp(bayCount - 1, 0, 13)
	for index = 1, mullionCount do
		local along = -span * 0.5 + span * index / (mullionCount + 1)
		local mullionSize = if longAxis == "x" then Vector3.new(0.18, windowHeight, 0.34) else Vector3.new(0.34, windowHeight, 0.18)
		local offset = if longAxis == "x" then CFrame.new(along, 0, outwardSign * 0.01) else CFrame.new(outwardSign * 0.01, 0, along)
		createDetail(parent, name .. string.format("_Mullion_%02d", index), mullionSize, center * offset, style.accentColor3, Enum.Material.Metal)
	end
	local sillSize = if longAxis == "x" then Vector3.new(span + 0.3, 0.32, 0.7) else Vector3.new(0.7, 0.32, span + 0.3)
	local sillOffset = if longAxis == "x" then CFrame.new(0, -windowHeight * 0.5 - 0.18, outwardSign * 0.22) else CFrame.new(outwardSign * 0.22, -windowHeight * 0.5 - 0.18, 0)
	createDetail(parent, name .. "_Sill", sillSize, center * sillOffset, style.accentColor3, Enum.Material.SmoothPlastic)
end

local function addPunchedWindows(
	parent: Instance,
	name: string,
	center: CFrame,
	span: number,
	windowHeight: number,
	panelDepth: number,
	longAxis: "x" | "z",
	style: { [string]: any },
	bayCount: number,
	outwardSign: number,
	stagger: number
)
	if span < 5 then
		addRibbon(parent, name, center, span, windowHeight, panelDepth, longAxis, style, 2, outwardSign)
		return
	end
	-- Long school blocks need enough narrow bays to read as punched classroom
	-- windows. A handful of panes across a 200+ stud wall made the whole facade
	-- look like a curtain wall even when the palette called for solid masonry.
	local count = math.clamp(math.max(math.floor(bayCount), math.ceil(span / 24)), 1, 16)
	local margin = math.min(2.2, span * 0.055)
	local usableSpan = math.max(4, span - margin * 2)
	local cell = usableSpan / count
	local panelSpan = math.clamp(cell * 0.46, 5.2, 9.2)
	for index = 1, count do
		local offset = (index - 0.5) * cell + (if index % 2 == 0 then stagger else -stagger)
		local along = -span * 0.5 + margin + offset
		along = math.clamp(along, -span * 0.5 + margin + panelSpan * 0.5, span * 0.5 - margin - panelSpan * 0.5)
		local localOffset = if longAxis == "x" then CFrame.new(along, 0, 0) else CFrame.new(0, 0, along)
		local paneOffset = if longAxis == "x" then CFrame.new(0, 0, outwardSign * 0.19) else CFrame.new(outwardSign * 0.19, 0, 0)
		local glassSize = if longAxis == "x" then Vector3.new(panelSpan - 0.36, windowHeight - 0.28, panelDepth) else Vector3.new(panelDepth, windowHeight - 0.28, panelSpan - 0.36)
		local glass = createDetail(parent, string.format("%s_Window_%02d_Glass", name, index), glassSize, center * localOffset * paneOffset, style.windowColor3, Enum.Material.Glass, 0.13)
		glass:SetAttribute("FacadeRole", "DecorativeWindowGlazing")
		local sillSize = if longAxis == "x" then Vector3.new(panelSpan + 0.42, 0.22, 0.58) else Vector3.new(0.58, 0.22, panelSpan + 0.42)
		local sillOffset = if longAxis == "x" then CFrame.new(0, -windowHeight * 0.5 - 0.11, outwardSign * 0.22) else CFrame.new(outwardSign * 0.22, -windowHeight * 0.5 - 0.11, 0)
		createDetail(parent, string.format("%s_Window_%02d_Sill", name, index), sillSize, center * localOffset * sillOffset, style.accentColor3, Enum.Material.Concrete)
	end
end

local function addWindowRow(
	parent: Instance,
	name: string,
	center: CFrame,
	span: number,
	windowHeight: number,
	panelDepth: number,
	longAxis: "x" | "z",
	style: { [string]: any },
	bayCount: number,
	outwardSign: number,
	floorIndex: number,
	isFront: boolean
)
	local composition = style.facadeComposition
	local stagger = if composition == "staggered_bays" or composition == "alternating_screens" then math.min(2.3, span / math.max(8, bayCount * 4)) * (if floorIndex % 2 == 1 then 1 else -1) else 0
	local height = windowHeight
	if composition == "industrial_slots" or composition == "utility_slots" then
		height = math.max(2.2, windowHeight * 0.4)
		center *= CFrame.new(0, math.min(1.6, windowHeight * 0.16), 0)
	end

	if isFront and (composition == "central_curtainwall" or composition == "split_curtainwall") and longAxis == "x" then
		local curtainWidth = math.min(30, span * 0.3)
		local sideSpan = (span - curtainWidth) * 0.5
		for _, side in ipairs({ -1, 1 }) do
			local sideCenter = center * CFrame.new(side * (curtainWidth * 0.5 + sideSpan * 0.5), 0, 0)
			addPunchedWindows(parent, name .. (if side < 0 then "_WingLeft" else "_WingRight"), sideCenter, sideSpan, height, panelDepth, longAxis, style, math.max(2, math.floor(bayCount * sideSpan / span)), outwardSign, stagger)
		end
		local curtainCenter = center * CFrame.new(0, 0, outwardSign * 0.025)
		addRibbon(parent, name .. "_AtriumGlass", curtainCenter, curtainWidth, height, panelDepth, longAxis, style, math.max(4, math.floor(curtainWidth / 5)), outwardSign)
		return
	end

	-- HCMUT-style teaching wings read as solid walls with individual openings. Keep
	-- full-width glazing for the small, named central lobby feature only.
	if (composition == "shopfront_upper_grid" or composition == "market_frontage") and floorIndex == 0 then
		addPunchedWindows(parent, name .. "_ShopfrontBays", center, span, height, panelDepth, longAxis, style, math.max(2, math.floor(bayCount * 0.45)), outwardSign, stagger)
	else
		addPunchedWindows(parent, name, center, span, height, panelDepth, longAxis, style, bayCount, outwardSign, stagger)
	end
end

local function addSunshade(parent: Instance, name: string, frame: CFrame, width: number, depth: number, floorIndex: number, floorHeight: number, style: { [string]: any })
	if style.sunshadePattern == "none" then
		return
	end
	local y = (floorIndex + 0.5) * floorHeight + 2.2
	local zOffset = -depth * 0.5 - 0.62
	local shadeWidth = math.min(width + 0.7, 1800)
	local shadeDepth = if style.facadeComposition == "deep_recess_bays" then 1.9 else 1.05
	createDetail(parent, name, Vector3.new(shadeWidth, 0.32, shadeDepth), frame * CFrame.new(0, y, zOffset), style.trimColor3, Enum.Material.SmoothPlastic)
end

local function addCompositionAccents(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, floorHeight: number, style: { [string]: any })
	local composition = style.facadeComposition
	local frontZ = -depth * 0.5 - 0.34
	if composition == "vertical_screen" or composition == "screened_bays" or composition == "alternating_screens" or composition == "corner_tower" then
		local finCount = math.clamp(style.facadeFinCount or math.ceil(width / 11), 5, 26)
		for index = 1, finCount do
			local x = -width * 0.44 + width * 0.88 * (index - 0.5) / finCount
			local finWidth = if composition == "corner_tower" and (index == 1 or index == finCount) then 1.6 else 0.65
			createDetail(parent, string.format("VerticalSunScreen_%02d", index), Vector3.new(finWidth, bodyHeight + 0.5, 0.52), frame * CFrame.new(x, bodyHeight * 0.5, frontZ), style.accentColor3, Enum.Material.Metal)
		end
	end
	if composition == "framed_piers" or composition == "colonnade_bays" or composition == "blue_horizontal_bands" then
		local pierCount = math.clamp(math.floor(width / 30), 3, 12)
		for index = 0, pierCount do
			local x = -width * 0.46 + width * 0.92 * index / pierCount
			local isColonnade = composition == "colonnade_bays"
			local height = if isColonnade then floorHeight else bodyHeight
			local y = if isColonnade then floorHeight * 0.5 else bodyHeight * 0.5
			local pierWidth = if isColonnade then 1.05 else 0.85
			createDetail(parent, string.format("FacadePier_%02d", index + 1), Vector3.new(pierWidth, height, 0.72), frame * CFrame.new(x, y, frontZ - 0.14), style.trimColor3, Enum.Material.Concrete)
		end
	end
	if composition == "corner_tower" or composition == "split_curtainwall" then
		local featureWidth = math.min(4.8, width * 0.12)
		createDetail(parent, "FacadeIdentityBlade", Vector3.new(featureWidth, bodyHeight + floorHeight * 0.35, 0.92), frame * CFrame.new(-width * 0.34, bodyHeight * 0.5, frontZ - 0.18), style.trimColor3, Enum.Material.SmoothPlastic)
	end
end

function FacadeGenerator.Build(
	parent: Instance,
	buildingFrame: CFrame,
	width: number,
	depth: number,
	floorHeightStuds: number,
	storyCount: number,
	category: string,
	style: { [string]: any },
	entranceWidthStuds: number?,
	buildingStyle: { [string]: any }?
)
	local resolvedStyle = buildingStyle or styleResolver.Resolve("", category)
	local folder = Instance.new("Folder")
	folder.Name = "FacadeDetails"
	folder.Parent = parent
	local buildingHeight = floorHeightStuds * storyCount
	local windowHeight = math.min(floorHeightStuds * style.windowHeightFraction, floorHeightStuds * 0.48)
	local bandHeight = math.min(style.floorBandHeightStuds, floorHeightStuds * 0.08)
	local bandColor = resolvedStyle.accentColor3
	local frontSpan = math.max(4, width - math.min(10, width * 0.18))
	local sideSpan = math.max(4, depth - math.min(10, depth * 0.18))
	local archetype = resolvedStyle.archetype
	local bayCount = math.clamp(resolvedStyle.facadeBayCount or (if archetype == "long_ribbon" then 14 else if archetype == "library" then 8 else if archetype == "vertical_bar" then 5 else 7), 3, 16)
	local sideBays = math.clamp(math.floor(sideSpan / 17), 3, 7)
	local panelDepth = 0.12
	local galleryLayout = resolvedStyle.galleryLayout or "single"
	local hasBothGallerySides = galleryLayout == "double" or galleryLayout == "wrap"
	local longAxisRotated = width > depth * 1.15
	local skipFrontWindows = longAxisRotated
	local skipBackWindows = longAxisRotated and hasBothGallerySides
	local skipLeftWindows = not longAxisRotated and hasBothGallerySides
	local skipRightWindows = not longAxisRotated

	for floorIndex = 0, storyCount - 1 do
		local windowY = (floorIndex + 0.5) * floorHeightStuds
		local floorTag = string.format("Floor_%02d", floorIndex + 1)
		local balconyDoor = styleResolver.HasBalcony(resolvedStyle, floorIndex, storyCount)
		local centerGap = if floorIndex == 0 then entranceWidthStuds or 0 else if balconyDoor then math.min(8, width * 0.18) else 0
		if not skipFrontWindows then
			if centerGap > 0 and frontSpan > centerGap + 4 then
				local sidePane = (frontSpan - centerGap) * 0.5
				for _, side in ipairs({ -1, 1 }) do
					local centerX = side * (centerGap * 0.5 + sidePane * 0.5)
					local center = buildingFrame * CFrame.new(centerX, windowY, -(depth * 0.5 + 0.04))
					addWindowRow(folder, "Windows_Front_" .. floorTag .. (if side < 0 then "_West" else "_East"), center, sidePane, windowHeight, panelDepth, "x", resolvedStyle, math.max(2, math.floor(bayCount * sidePane / frontSpan)), -1, floorIndex, true)
				end
			else
				addWindowRow(folder, "Windows_Front_" .. floorTag, buildingFrame * CFrame.new(0, windowY, -(depth * 0.5 + 0.04)), frontSpan, windowHeight, panelDepth, "x", resolvedStyle, bayCount, -1, floorIndex, true)
			end
		end
		if not skipBackWindows then
			addWindowRow(folder, "Windows_Back_" .. floorTag, buildingFrame * CFrame.new(0, windowY, depth * 0.5 + 0.04), frontSpan, windowHeight, panelDepth, "x", resolvedStyle, bayCount, 1, floorIndex, false)
		end
		if not skipLeftWindows then
			addWindowRow(folder, "Windows_Left_" .. floorTag, buildingFrame * CFrame.new(-(width * 0.5 + 0.04), windowY, 0), sideSpan, windowHeight, panelDepth, "z", resolvedStyle, sideBays, -1, floorIndex, false)
		end
		if not skipRightWindows then
			addWindowRow(folder, "Windows_Right_" .. floorTag, buildingFrame * CFrame.new(width * 0.5 + 0.04, windowY, 0), sideSpan, windowHeight, panelDepth, "z", resolvedStyle, sideBays, 1, floorIndex, false)
		end
		if floorIndex < storyCount - 1 then
			local bandY = (floorIndex + 1) * floorHeightStuds
			local bandDepth = if resolvedStyle.facadeComposition == "deep_recess_bays" then 0.9 else 0.24
			createDetail(folder, "StoryBand_Front_" .. floorTag, Vector3.new(width + 0.2, bandHeight, bandDepth), buildingFrame * CFrame.new(0, bandY, -(depth * 0.5 + 0.08)), bandColor, Enum.Material.SmoothPlastic)
			createDetail(folder, "StoryBand_Back_" .. floorTag, Vector3.new(width + 0.2, bandHeight, 0.24), buildingFrame * CFrame.new(0, bandY, depth * 0.5 + 0.08), bandColor, Enum.Material.SmoothPlastic)
			createDetail(folder, "StoryBand_Left_" .. floorTag, Vector3.new(0.24, bandHeight, depth + 0.2), buildingFrame * CFrame.new(-(width * 0.5 + 0.08), bandY, 0), bandColor, Enum.Material.SmoothPlastic)
			createDetail(folder, "StoryBand_Right_" .. floorTag, Vector3.new(0.24, bandHeight, depth + 0.2), buildingFrame * CFrame.new(width * 0.5 + 0.08, bandY, 0), bandColor, Enum.Material.SmoothPlastic)
		end
		if style.sunshadePattern == "continuous" or resolvedStyle.facadeComposition == "deep_recess_bays" or resolvedStyle.facadeComposition == "blue_horizontal_bands" then
			addSunshade(folder, "Sunshade_Front_" .. floorTag, buildingFrame, width, depth, floorIndex, floorHeightStuds, resolvedStyle)
		end
	end

	addCompositionAccents(folder, buildingFrame, width, depth, buildingHeight, floorHeightStuds, resolvedStyle)
	local columnColor = resolvedStyle.trimColor3
	for _, xSign in ipairs({ -1, 1 }) do
		for _, zSign in ipairs({ -1, 1 }) do
			createDetail(folder, string.format("CornerPier_%s_%s", if xSign < 0 then "Left" else "Right", if zSign < 0 then "Front" else "Back"), Vector3.new(0.5, buildingHeight - 0.7, 0.5), buildingFrame * CFrame.new(xSign * (width * 0.5 + 0.025), buildingHeight * 0.5, zSign * (depth * 0.5 + 0.025)), columnColor, Enum.Material.SmoothPlastic)
		end
	end
	return folder
end

return table.freeze(FacadeGenerator)
