-- AI-assisted, native-Part rebuild of B1. Keeps the previous model in ServerStorage.
return function()
	local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local storage = game:GetService("ServerStorage")
	local old = assert(buildings:FindFirstChild("B1"), "B1 not found")
	assert(not storage:FindFirstChild("B1_BeforeUnifiedRebuild_v1"), "Existing backup must not be overwritten")
	local model = Instance.new("Model")
	model.Name = "B1"
	model:SetAttribute("CampusBuildingId", "B1")
	model:SetAttribute("BuildingDisplayName", "TÒA B1")
	model:SetAttribute("WalkableFloorCount", 3)
	model:SetAttribute("Architecture", "one continuous U-shaped building")
	local wallColor = Color3.fromRGB(216, 216, 201)
	local trimColor = Color3.fromRGB(43, 83, 108)
	local floorColor = Color3.fromRGB(179, 180, 169)
	local glassColor = Color3.fromRGB(35, 74, 95)
	local ground, storey = 0.8, 12.85714
	local function part(name, size, position, color, material, collides)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Position = name, size, position
		p.Color, p.Material = color, material
		p.Anchored, p.CanCollide, p.CanTouch = true, collides, false
		p.CanQuery = collides
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = model
		return p
	end
	local function slab(name, x0, x1, z0, z1, y, color)
		if x1-x0 > 0.1 and z1-z0 > 0.1 then
			part(name, Vector3.new(x1-x0, 0.8, z1-z0), Vector3.new((x0+x1)/2, y-0.4, (z0+z1)/2), color, Enum.Material.Concrete, true)
		end
	end
	-- One footprint: two wings and the connecting bar. Floor openings are only for stairs.
	for level = 1, 3 do
		local y = ground + (level-1)*storey
		if level == 1 then
			slab("WestFloor", 5387.3, 5420, 1574.3, 1690.4, y, floorColor)
		else
			local z0 = if level == 2 then 1590 else 1630
			local z1 = z0 + 29
			slab("WestFloorOuter", 5387.3, 5393, 1574.3, 1690.4, y, floorColor)
			slab("WestFloorInner", 5403, 5420, 1574.3, 1690.4, y, floorColor)
			slab("WestFloorBeforeStairs", 5393, 5403, 1574.3, z0, y, floorColor)
			slab("WestFloorAfterStairs", 5393, 5403, z1, 1690.4, y, floorColor)
		end
		slab("EastFloor", 5491.2, 5526.8, 1574.3, 1690.4, y, floorColor)
		slab("ConnectingFloor", 5387.3, 5526.8, 1690.3, 1724, y, floorColor)
	end
	task.wait()
	-- Each stair has its own opening in the slab above and lands on solid floor.
	for level = 1, 2 do
		local z0 = if level == 1 then 1590 else 1630
		for step = 1, 16 do
			local height = storey * step / 16
			part("Stair_" .. level .. "_" .. step, Vector3.new(9.5, height, 1.85),
				Vector3.new(5398, ground+(level-1)*storey+height/2, z0+(step-0.5)*1.8), floorColor, Enum.Material.Concrete, true)
		end
	end
	local function wallX(name, x0, x1, z, level, withWindows)
		local base = ground+(level-1)*storey
		local mid = (x0+x1)/2
		part(name, Vector3.new(x1-x0, storey-0.8, 0.65), Vector3.new(mid,base+(storey-0.8)/2,z), wallColor, Enum.Material.Concrete, true)
		if withWindows then
			local count = math.floor((x1-x0)/9)
			for i=1,count do
				local x = x0+(x1-x0)*(i-0.5)/count
				for _, side in ipairs({-1,1}) do
					part("Window", Vector3.new(4,4,0.12), Vector3.new(x,base+6,z+side*0.39), glassColor, Enum.Material.Glass, false)
				end
			end
		end
	end
	local function wallZ(name, x, z0, z1, level)
		local base = ground+(level-1)*storey
		part(name, Vector3.new(0.65,storey-0.8,z1-z0), Vector3.new(x,base+(storey-0.8)/2,(z0+z1)/2), wallColor, Enum.Material.Concrete, true)
		local count = math.floor((z1-z0)/9)
		for i=1,count do
			local z = z0+(z1-z0)*(i-0.5)/count
			for _, side in ipairs({-1,1}) do
				part("Window", Vector3.new(0.12,4,4), Vector3.new(x+side*0.39,base+6,z), glassColor, Enum.Material.Glass, false)
			end
		end
	end
	for level=1,3 do
		wallZ("WestOuterWall", 5387.3,1574.3,1724,level)
		wallZ("EastOuterWall", 5526.8,1574.3,1724,level)
		wallZ("CourtyardWestWall", 5420,1574.3,1690.3,level)
		wallZ("CourtyardEastWall", 5491.2,1574.3,1690.3,level)
		wallX("WestWingEnd", 5387.3,5420,1574.3,level,true)
		wallX("EastWingEnd", 5491.2,5526.8,1574.3,level,true)
		wallX("CourtyardBackWall", 5420,5491.2,1690.3,level,true)
		if level == 1 then
			wallX("FrontWallLeft",5387.3,5451.125,1724,level,true)
			wallX("FrontWallRight",5463.125,5526.8,1724,level,true)
			part("MainDoorHeader",Vector3.new(12,3.15,0.65),Vector3.new(5457.125,ground+10.4825,1724),wallColor,Enum.Material.Concrete,true)
		else
			wallX("FrontWall",5387.3,5526.8,1724,level,true)
		end
		task.wait()
	end
	local roofY = ground + 3*storey
	slab("WestRoof",5387.3,5420,1574.3,1690.4,roofY,floorColor)
	slab("EastRoof",5491.2,5526.8,1574.3,1690.4,roofY,floorColor)
	slab("ConnectingRoof",5387.3,5526.8,1690.3,1724,roofY,floorColor)
	for level=1,3 do
		local y=ground+(level-1)*storey+0.18
		if level == 1 then
			part("FrontBand",Vector3.new(63.8,0.36,0.2),Vector3.new(5419.2,y,1724.38),trimColor,Enum.Material.SmoothPlastic,false)
			part("FrontBand",Vector3.new(63.7,0.36,0.2),Vector3.new(5494.95,y,1724.38),trimColor,Enum.Material.SmoothPlastic,false)
		else
			part("FrontBand",Vector3.new(139.5,0.36,0.2),Vector3.new(5457.05,y,1724.38),trimColor,Enum.Material.SmoothPlastic,false)
		end
	end
	part("EntranceCanopy",Vector3.new(22,0.8,7),Vector3.new(5457.125,11.2,1727.4),trimColor,Enum.Material.SmoothPlastic,true)
	for _, x in ipairs({5446.8,5467.45}) do
		part("EntranceColumn",Vector3.new(1,10.8,1),Vector3.new(x,5.4,1730.5),wallColor,Enum.Material.Concrete,true)
	end
	local sign = part("B1Sign",Vector3.new(7,1.6,0.2),Vector3.new(5457.125,10.1,1731),trimColor,Enum.Material.SmoothPlastic,false)
	local gui = Instance.new("SurfaceGui")
	gui.Face, gui.LightInfluence, gui.Parent = Enum.NormalId.Back, 0, sign
	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency, label.Text = UDim2.fromScale(1,1), 1, "B1"
	label.TextColor3, label.TextScaled, label.Font, label.Parent = Color3.new(1,1,1), true, Enum.Font.GothamBold, gui
	assert(#model:GetChildren() < 600, "Unexpectedly large B1 rebuild")
	old.Name = "B1_BeforeUnifiedRebuild_v1"
	old.Parent = storage
	model.Parent = buildings
	return "Rebuilt B1 as one U-shaped shell with 3 floors, 2 stairs and one main entrance; previous model preserved"
end
