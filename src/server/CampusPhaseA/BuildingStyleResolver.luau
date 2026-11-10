--!strict
-- Converts the per-building JSON architecture palette into Roblox colors and detail rules.
local BuildingStyleResolver = {}

local DEFAULTS = {
	name = "TÒA",
	archetype = "teaching_wing",
	wallColor = "#E8DFC9",
	trimColor = "#C9B58A",
	accentColor = "#C98154",
	windowColor = "#31596B",
	floorColor = "#AAA69C",
	corridorColor = "#B7AA8F",
	lightColor = "#FFE1A1",
	roomType = "classroom",
	facadeComposition = "horizontal_ribbon",
	entryForm = "simple_portal",
	roofForm = "parapet",
	facadeSignature = "Estimate; review required.",
	buildingForm = "long_gallery_wing",
	galleryLayout = "single",
	galleryWidthStuds = 5.4,
	galleryRailStyle = "metal_balustrade",
	gallerySupportStyle = "slender_columns",
	galleryRoofStyle = "continuous",
	facadeBayCount = 7,
	facadeFinCount = 0,
	balconyPattern = "alternating",
	balconySpanMode = "compact",
	balconyWidthFraction = 0.48,
	balconyDepthStuds = 3.6,
	sunshadePattern = "continuous",
	classroomBayLengthStuds = 36,
	maxClassroomBays = 9,
}

local function hexColor(value: string?): Color3
	local hex = if value then string.gsub(value, "^#", "") else ""
	if #hex ~= 6 then
		return Color3.fromRGB(232, 223, 201)
	end
	local red = tonumber(string.sub(hex, 1, 2), 16) or 232
	local green = tonumber(string.sub(hex, 3, 4), 16) or 223
	local blue = tonumber(string.sub(hex, 5, 6), 16) or 201
	return Color3.fromRGB(red, green, blue)
end

function BuildingStyleResolver.Resolve(buildingId: string, category: string): { [string]: any }
	local source = (script.Parent:WaitForChild("CampusManifest") :: ModuleScript)
	local manifest = require(source)
	local configured = manifest.buildingStyles and manifest.buildingStyles[buildingId] or nil
	local style = table.clone(DEFAULTS)
	if configured then
		for key, value in pairs(configured) do
			style[key] = value
		end
	elseif category == "library" then
		style.name = "THƯ VIỆN"
		style.archetype = "library"
		style.roomType = "library"
		style.wallColor = "#F0E5CE"
		style.accentColor = "#2E8B86"
	elseif category == "service" then
		style.name = "NHÀ PHỤ"
		style.archetype = "service_block"
		style.roomType = "storage"
		style.wallColor = "#D6D4C7"
		style.accentColor = "#9E7652"
	end
	style.wallColor3 = hexColor(style.wallColor)
	style.trimColor3 = hexColor(style.trimColor)
	style.accentColor3 = hexColor(style.accentColor)
	style.windowColor3 = hexColor(style.windowColor)
	style.floorColor3 = hexColor(style.floorColor)
	style.corridorColor3 = hexColor(style.corridorColor)
	style.lightColor3 = hexColor(style.lightColor)
	style.galleryFloorColor3 = style.floorColor3:Lerp(style.wallColor3, 0.28)
	style.galleryRailColor3 = style.accentColor3
	style.galleryRoofColor3 = style.trimColor3
	style.galleryColumnColor3 = style.wallColor3
	style.galleryLightColor3 = style.lightColor3
	return style
end

function BuildingStyleResolver.HasBalcony(style: { [string]: any }, floorIndex: number, storyCount: number): boolean
	if floorIndex <= 0 or floorIndex >= storyCount then
		return false
	end
	local pattern = style.balconyPattern
	if pattern == "stacked" then
		return true
	elseif pattern == "alternating" then
		return floorIndex % 2 == 1
	elseif pattern == "paired" then
		return floorIndex == 1 or floorIndex == storyCount - 1
	elseif pattern == "single" then
		return floorIndex == math.max(1, math.floor(storyCount * 0.5))
	end
	return false
end

return table.freeze(BuildingStyleResolver)
