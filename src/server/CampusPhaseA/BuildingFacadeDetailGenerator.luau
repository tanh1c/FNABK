--!strict
-- Adds per-building entry forms, legible signs, balconies, roof silhouettes and lights.
local BuildingFacadeDetailGenerator = {}
local styleResolver = require(script.Parent:WaitForChild("BuildingStyleResolver"))

local SIGN_NAVY = Color3.fromRGB(17, 43, 67)

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, collidable: boolean?): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.CanCollide = collidable == true
	item.CanTouch = false
	item.CanQuery = collidable == true
	item.CastShadow = collidable == true
	item.Material = material
	item.Color = color
	item.Size = size
	item.CFrame = cframe
	item.Parent = parent
	return item
end

local function addTextSurface(target: Part, text: string, textColor: Color3, backgroundColor: Color3, pixelsPerStud: number)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "ReadableLabel"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.PixelsPerStud = pixelsPerStud
	gui.Parent = target
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundColor3 = backgroundColor
	label.BackgroundTransparency = 0
	label.BorderSizePixel = 0
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = textColor
	label.TextScaled = false
	label.TextSize = 64
	label.TextWrapped = false
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextStrokeTransparency = 0.65
	label.Parent = gui
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 18)
	padding.PaddingRight = UDim.new(0, 18)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = label
end

local function addWallLight(parent: Instance, frame: CFrame, name: string, x: number, y: number, z: number, style: { [string]: any })
	local fixture = part(parent, name, Vector3.new(0.55, 1.1, 0.55), frame * CFrame.new(x, y, z), style.trimColor3, Enum.Material.Metal)
	local lens = part(parent, name .. "_Lens", Vector3.new(0.34, 0.68, 0.12), frame * CFrame.new(x, y, z - 0.32), style.lightColor3, Enum.Material.Neon)
	local glow = Instance.new("PointLight")
	glow.Name = "WarmCampusLight"
	glow.Color = style.lightColor3
	glow.Brightness = 1.05
	glow.Range = 18
	glow.Shadows = false
	glow.Parent = lens
	fixture:SetAttribute("ArchitectureRole", "ExteriorWallLight")
end

local function addBalcony(parent: Instance, frame: CFrame, name: string, depth: number, floorHeight: number, floorIndex: number, balconyWidth: number, balconyDepth: number, style: { [string]: any })
	local floorY = floorIndex * floorHeight + 0.8
	local frontZ = -depth * 0.5
	local slabCenterZ = frontZ - balconyDepth * 0.5 + 0.12
	local outerZ = frontZ - balconyDepth + 0.12
	local slab = part(parent, name .. "_Deck", Vector3.new(balconyWidth, 0.65, balconyDepth), frame * CFrame.new(0, floorY - 0.325, slabCenterZ), style.floorColor3, Enum.Material.Concrete, true)
	slab:SetAttribute("ArchitectureRole", "WalkableBalconyDeck")
	local railColor = style.accentColor3
	local railHeight = 2.25
	part(parent, name .. "_FrontRail", Vector3.new(balconyWidth, 0.24, 0.24), frame * CFrame.new(0, floorY + railHeight, outerZ), railColor, Enum.Material.Metal, true)
	for _, side in ipairs({ -1, 1 }) do
		local x = side * (balconyWidth * 0.5 - 0.12)
		part(parent, name .. "_SideRail_" .. side, Vector3.new(0.24, 0.24, balconyDepth), frame * CFrame.new(x, floorY + railHeight, slabCenterZ), railColor, Enum.Material.Metal, true)
		for postIndex = 0, 2 do
			local z = frontZ - balconyDepth * postIndex * 0.5 + 0.12
			part(parent, string.format("%s_SidePost_%d_%d", name, side, postIndex + 1), Vector3.new(0.24, railHeight, 0.24), frame * CFrame.new(x, floorY + railHeight * 0.5, z), railColor, Enum.Material.Metal, true)
		end
	end
	local postCount = math.clamp(math.ceil(balconyWidth / 12), 2, 26)
	for postIndex = 0, postCount do
		local x = -balconyWidth * 0.5 + balconyWidth * postIndex / postCount
		part(parent, string.format("%s_FrontPost_%02d", name, postIndex + 1), Vector3.new(0.24, railHeight, 0.24), frame * CFrame.new(x, floorY + railHeight * 0.5, outerZ), railColor, Enum.Material.Metal, true)
	end
	local awningDepth = math.min(if style.balconySpanMode == "full_gallery" then 2.5 else 1.8, balconyDepth * 0.58)
	part(parent, name .. "_Awning", Vector3.new(balconyWidth, 0.22, awningDepth), frame * CFrame.new(0, floorY + floorHeight - 0.8, frontZ - awningDepth * 0.5), style.trimColor3, Enum.Material.SmoothPlastic)
end

local function addEntry(parent: Instance, frame: CFrame, width: number, depth: number, floorHeight: number, entranceWidth: number, style: { [string]: any })
	local entryForm = style.entryForm
	local doorHeight = math.min(9, floorHeight - 2.6)
	local frontZ = -depth * 0.5
	local signWidth = math.min(width - 3, math.max(18, math.min(48, width * 0.56)))
	local signHeight = 3.6
	local signY = doorHeight + 3.3
	local signZ = frontZ - 1.2
	local boardFrame = frame * CFrame.new(0, signY, signZ)
	local housing = part(parent, "BuildingNameSignHousing", Vector3.new(signWidth + 0.8, signHeight + 0.65, 0.48), boardFrame * CFrame.new(0, 0, 0.18), style.trimColor3, Enum.Material.Metal)
	housing:SetAttribute("ArchitectureRole", "ProtrudingNameboardFrame")
	local board = part(parent, "ProtrudingBuildingName", Vector3.new(signWidth, signHeight, 0.72), boardFrame, SIGN_NAVY, Enum.Material.SmoothPlastic)
	board:SetAttribute("BuildingDisplayName", style.name)
	board:SetAttribute("NameboardTextSizePixels", 64)
	board:SetAttribute("NameboardTextScaled", false)
	addTextSurface(board, style.name, Color3.new(1, 1, 1), SIGN_NAVY, 24)
	for _, side in ipairs({ -1, 1 }) do
		part(parent, "SignStandOff_" .. side, Vector3.new(0.75, 0.5, 1.25), frame * CFrame.new(side * signWidth * 0.35, signY, frontZ - 0.48), style.trimColor3, Enum.Material.Metal)
	end

	local canopyWidth = math.min(width - 7, math.max(entranceWidth + 7, width * 0.34))
	local canopyDepth = 4.8
	if entryForm == "long_portico" or entryForm == "wide_arcade" or entryForm == "gallery_portico" or entryForm == "colonnade" then
		canopyWidth = math.min(width - 7, math.max(entranceWidth + 12, width * 0.62))
		canopyDepth = 6.8
	elseif entryForm == "cantilever" or entryForm == "deep_canopy" then
		canopyWidth = math.min(width - 7, math.max(entranceWidth + 10, width * 0.46))
		canopyDepth = 7.2
	elseif entryForm == "shopfront" or entryForm == "market_awning" then
		canopyWidth = math.min(width - 7, math.max(entranceWidth + 12, width * 0.68))
		canopyDepth = 5.6
	elseif entryForm == "service_gate" then
		canopyWidth = math.min(width - 7, math.max(entranceWidth + 4, width * 0.32))
		canopyDepth = 3.8
	end
	local canopyY = doorHeight + 0.55
	local canopyCenter = frame * CFrame.new(0, canopyY, frontZ - canopyDepth * 0.5 - 0.3)
	part(parent, "EntryCanopy", Vector3.new(canopyWidth, 0.55, canopyDepth), canopyCenter, style.trimColor3, Enum.Material.Concrete)
	part(parent, "EntryCanopyFascia", Vector3.new(canopyWidth, 0.6, 0.55), canopyCenter * CFrame.new(0, -0.02, -canopyDepth * 0.5 + 0.04), style.accentColor3, Enum.Material.SmoothPlastic)

	local postMode = entryForm == "long_portico" or entryForm == "wide_arcade" or entryForm == "gallery_portico" or entryForm == "colonnade" or entryForm == "library_portal" or entryForm == "lab_canopy" or entryForm == "split_portico" or entryForm == "glass_lobby" or entryForm == "deep_portico" or entryForm == "blue_portico" or entryForm == "compact_portico"
	if postMode then
		local postCount = math.clamp(math.floor(canopyWidth / 15), 2, 10)
		local columnHeight = canopyY - 0.275
		for index = 0, postCount do
			local x = -canopyWidth * 0.46 + canopyWidth * 0.92 * index / postCount
			if math.abs(x) > entranceWidth * 0.5 + 1.3 then
				part(parent, string.format("PorticoColumn_%02d", index + 1), Vector3.new(0.9, columnHeight, 0.9), frame * CFrame.new(x, columnHeight * 0.5, frontZ - canopyDepth * 0.62), style.accentColor3, Enum.Material.Concrete)
			end
		end
	elseif entryForm == "cantilever" or entryForm == "deep_canopy" then
		for _, side in ipairs({ -1, 1 }) do
			local brace = part(parent, "CanopyBrace_" .. side, Vector3.new(0.62, 4.6, 0.62), frame * CFrame.new(side * (entranceWidth * 0.5 + 2.1), canopyY - 1.25, frontZ - 1.1) * CFrame.Angles(math.rad(-34), 0, 0), style.accentColor3, Enum.Material.Metal)
			brace:SetAttribute("ArchitectureRole", "CantileverSupport")
		end
	else
		local columnHeight = canopyY - 0.275
		for _, side in ipairs({ -1, 1 }) do
			local x = side * (canopyWidth * 0.5 - 0.55)
			part(parent, "EntryCanopyColumn_" .. side, Vector3.new(0.65, columnHeight, 0.65), frame * CFrame.new(x, columnHeight * 0.5, frontZ - canopyDepth * 0.62), style.trimColor3, Enum.Material.Concrete)
		end
	end

	if entryForm == "corner_portal" or entryForm == "tower_entry" or entryForm == "stair_tower_entry" then
		local bladeX = -width * 0.32
		local bladeHeight = math.min(floorHeight * 2.25, floorHeight * 2.5)
		part(parent, "EntryIdentityBlade", Vector3.new(math.min(5.5, width * 0.12), bladeHeight, 1.1), frame * CFrame.new(bladeX, bladeHeight * 0.5, frontZ - 0.5), style.accentColor3, Enum.Material.SmoothPlastic)
	end
	if entryForm == "glass_lobby" then
		for _, side in ipairs({ -1, 1 }) do
			part(parent, "LobbyGlassWing_" .. side, Vector3.new(5.0, doorHeight * 0.82, 0.18), frame * CFrame.new(side * (entranceWidth * 0.5 + 3.2), doorHeight * 0.5, frontZ - 0.48), style.windowColor3, Enum.Material.Glass)
		end
	end
	if entryForm == "market_awning" then
		for index = 1, 5 do
			local x = -canopyWidth * 0.42 + canopyWidth * 0.84 * (index - 0.5) / 5
			part(parent, "AwningStripe_" .. index, Vector3.new(canopyWidth * 0.18, 0.14, canopyDepth * 0.95), canopyCenter * CFrame.new(x, 0.31, 0), if index % 2 == 0 then style.accentColor3 else style.trimColor3, Enum.Material.SmoothPlastic)
		end
	end
	for _, side in ipairs({ -1, 1 }) do
		addWallLight(parent, frame, "EntranceLamp_" .. side, side * (entranceWidth * 0.5 + 2.6), 4.5, frontZ - 0.45, style)
	end
end

local function addParapet(parent: Instance, frame: CFrame, width: number, depth: number, roofY: number, style: { [string]: any })
	local h = 1.45
	part(parent, "RoofParapet_Front", Vector3.new(width + 1.2, h, 0.75), frame * CFrame.new(0, roofY + h * 0.5, -depth * 0.5), style.accentColor3, Enum.Material.Concrete)
	part(parent, "RoofParapet_Back", Vector3.new(width + 1.2, h, 0.75), frame * CFrame.new(0, roofY + h * 0.5, depth * 0.5), style.trimColor3, Enum.Material.Concrete)
	for _, side in ipairs({ -1, 1 }) do
		part(parent, "RoofParapet_Side_" .. side, Vector3.new(0.75, h, depth + 0.4), frame * CFrame.new(side * width * 0.5, roofY + h * 0.5, 0), style.trimColor3, Enum.Material.Concrete)
	end
end

local function addRoofDetails(parent: Instance, frame: CFrame, width: number, depth: number, bodyHeight: number, roofHeight: number, floorHeight: number, style: { [string]: any })
	local roofY = bodyHeight + roofHeight
	local roofForm = style.roofForm
	if roofForm == "stair_tower" or roofForm == "small_tower" or roofForm == "service_tower" or roofForm == "central_crown" or roofForm == "library_crown" then
		local towerWidth = if roofForm == "small_tower" then math.min(14, width * 0.42) else if roofForm == "library_crown" then math.min(28, width * 0.36) else math.min(20, width * 0.28)
		local towerDepth = math.min(22, math.max(9, depth * 0.35))
		local towerHeight = if roofForm == "small_tower" then floorHeight * 0.55 else floorHeight * 0.82
		local x = if roofForm == "central_crown" or roofForm == "library_crown" then 0 else -width * 0.27
		local tower = part(parent, "RooftopStairOrCrownTower", Vector3.new(towerWidth, towerHeight, towerDepth), frame * CFrame.new(x, roofY + towerHeight * 0.5, 0), style.wallColor3, Enum.Material.SmoothPlastic)
		tower:SetAttribute("ArchitectureRole", "EstimatedRooftopStairVolume")
		part(parent, "RooftopTowerAccent", Vector3.new(towerWidth + 0.6, 0.65, towerDepth + 0.6), frame * CFrame.new(x, roofY + towerHeight - 0.3, 0), style.accentColor3, Enum.Material.SmoothPlastic)
	elseif roofForm == "vent_stack" or roofForm == "utility_vents" or roofForm == "sawtooth" then
		for index = 1, 3 do
			local x = (index - 2) * math.min(10, width * 0.18)
			local vent = part(parent, "RoofVent_" .. index, Vector3.new(4.2, if roofForm == "sawtooth" then 3.3 else 2.2, 3.2), frame * CFrame.new(x, roofY + 1.15, depth * 0.16), style.trimColor3, Enum.Material.Metal)
			vent:SetAttribute("ArchitectureRole", "RooftopServiceDetail")
		end
	elseif roofForm == "water_tank" then
		local tank = part(parent, "RoofWaterTank", Vector3.new(4.8, 6.2, 4.8), frame * CFrame.new(width * 0.22, roofY + 3.1, depth * 0.18), style.trimColor3, Enum.Material.Metal)
		tank.Shape = Enum.PartType.Cylinder
		tank:SetAttribute("ArchitectureRole", "EstimatedRooftopUtility")
		part(parent, "TankSupportFrame", Vector3.new(6.0, 0.7, 6.0), frame * CFrame.new(width * 0.22, roofY + 0.35, depth * 0.18), style.accentColor3, Enum.Material.Metal)
	elseif roofForm == "roof_pergola" or roofForm == "solar_frame" then
		for index = 0, 4 do
			local x = -width * 0.3 + width * 0.6 * index / 4
			part(parent, string.format("RoofFrameBeam_%02d", index + 1), Vector3.new(0.45, 0.6, depth * 0.55), frame * CFrame.new(x, roofY + 1.1, 0), style.accentColor3, Enum.Material.Metal)
		end
		part(parent, "RoofFrameRidge", Vector3.new(width * 0.62, 0.45, 0.45), frame * CFrame.new(0, roofY + 1.1, 0), style.trimColor3, Enum.Material.Metal)
	elseif roofForm == "clerestory" then
		part(parent, "ClerestoryGlassBand", Vector3.new(math.min(width * 0.62, 68), 2.8, math.min(depth * 0.5, 10)), frame * CFrame.new(0, roofY + 1.7, 0), style.windowColor3, Enum.Material.Glass)
		part(parent, "ClerestoryTopCap", Vector3.new(math.min(width * 0.64, 70), 0.6, math.min(depth * 0.52, 11)), frame * CFrame.new(0, roofY + 3.25, 0), style.accentColor3, Enum.Material.SmoothPlastic)
	elseif roofForm == "long_cornice" or roofForm == "blue_cornice" or roofForm == "parapet_gallery" or roofForm == "flat_parapet" or roofForm == "parapet" then
		addParapet(parent, frame, width, depth, roofY, style)
	elseif roofForm == "central_shed" or roofForm == "roof_shed" then
		local ridge = part(parent, "RaisedRoofRidge", Vector3.new(width * 0.42, 2.4, math.max(4, depth * 0.26)), frame * CFrame.new(0, roofY + 1.2, 0), style.trimColor3, Enum.Material.SmoothPlastic)
		ridge:SetAttribute("ArchitectureRole", "EstimatedRoofMonitor")
	elseif roofForm == "awnings" then
		for index = 1, 3 do
			part(parent, "RoofAwningLayer_" .. index, Vector3.new(width * (0.62 - index * 0.06), 0.45, depth * 0.7), frame * CFrame.new(0, roofY + index * 0.62, 0), if index % 2 == 1 then style.accentColor3 else style.trimColor3, Enum.Material.SmoothPlastic)
		end
	end
	if roofForm == "library_crown" then
		part(parent, "LibraryRoofCornice_Front", Vector3.new(width + 1.0, 0.5, 0.9), frame * CFrame.new(0, roofY + 0.3, -depth * 0.5), style.accentColor3, Enum.Material.SmoothPlastic)
	end
end

function BuildingFacadeDetailGenerator.Build(
	parent: Instance,
	frame: CFrame,
	width: number,
	depth: number,
	floorHeight: number,
	storyCount: number,
	roofHeight: number,
	entranceWidth: number,
	style: { [string]: any },
	walkableMode: boolean?
): number
	local folder = Instance.new("Folder")
	folder.Name = "ArchitectureDetails"
	folder.Parent = parent
	addEntry(folder, frame, width, depth, floorHeight, entranceWidth, style)

	local balconyCount = 0
	if not walkableMode then
		for floorIndex = 1, storyCount - 1 do
			if styleResolver.HasBalcony(style, floorIndex, storyCount) then
				local balconyWidth = if style.balconySpanMode == "full_gallery"
					then math.max(width - 8, width * 0.88)
					else if style.balconySpanMode == "wide_gallery"
						then math.min(width - 8, 100, math.max(17, width * (style.balconyWidthFraction or 0.72)))
						else math.min(width - 8, 72, math.max(17, width * (style.balconyWidthFraction or 0.46)))
				local balconyDepth = math.max(3.0, math.min(style.balconyDepthStuds or 3.6, 5.2))
				addBalcony(folder, frame, string.format("Balcony_Floor_%02d", floorIndex + 1), depth, floorHeight, floorIndex, balconyWidth, balconyDepth, style)
				balconyCount += 1
			end
		end
	end

	local bodyHeight = floorHeight * storyCount
	if style.facadeComposition == "industrial_slots" or style.facadeComposition == "utility_slots" or style.facadeComposition == "louvered_lab" then
		for index = 1, 5 do
			local x = -math.min(width * 0.34, 48) + math.min(width * 0.68, 96) * (index - 1) / 4
			part(folder, "FacadeVentBlade_" .. index, Vector3.new(0.55, math.max(4, bodyHeight * 0.68), 0.46), frame * CFrame.new(x, bodyHeight * 0.5, -depth * 0.5 - 0.42), style.accentColor3, Enum.Material.Metal)
		end
	end
	if not walkableMode and (style.facadeComposition == "open_gallery" or style.facadeComposition == "loggia_bays") then
		for floorIndex = 1, storyCount - 1 do
			part(folder, string.format("GallerySoffit_Floor_%02d", floorIndex + 1), Vector3.new(if style.balconySpanMode == "full_gallery" then math.max(width - 8, width * 0.88) else math.min(width - 5, 66), 0.32, 1.2), frame * CFrame.new(0, floorIndex * floorHeight + 0.8, -depth * 0.5 - 0.1), style.trimColor3, Enum.Material.SmoothPlastic)
		end
	end
	if style.facadeComposition == "blue_horizontal_bands" then
		for floorIndex = 0, storyCount - 1 do
			part(folder, "BlueFacadeBand_" .. floorIndex, Vector3.new(width + 1.0, 0.48, 0.5), frame * CFrame.new(0, floorIndex * floorHeight + 1.1, -depth * 0.5 - 0.32), style.accentColor3, Enum.Material.SmoothPlastic)
		end
	end
	addRoofDetails(folder, frame, width, depth, bodyHeight, roofHeight, floorHeight, style)
	return balconyCount
end

return table.freeze(BuildingFacadeDetailGenerator)
