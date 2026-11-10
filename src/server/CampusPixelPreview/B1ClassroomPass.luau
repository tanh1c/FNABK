-- AI-assisted classroom and open-gallery pass for the unified B1 shell.
return function()
	local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local b1 = buildings.B1
	local storage = game:GetService("ServerStorage")
	assert(b1:GetAttribute("Architecture") == "one continuous U-shaped building", "Expected unified B1 shell")
	assert(not b1:FindFirstChild("B1_OpenGalleryAndClassrooms_v1"), "Classroom pass already present")
	assert(not storage:FindFirstChild("B1_BeforeClassroomPass_v1"), "Backup already exists")
	local backup = b1:Clone()
	backup.Name = "B1_BeforeClassroomPass_v1"
	backup.Parent = storage
	local all = Instance.new("Folder")
	all.Name = "B1_OpenGalleryAndClassrooms_v1"
	local ivory = Color3.fromRGB(221, 220, 207)
	local blue = Color3.fromRGB(42, 79, 100)
	local dark = Color3.fromRGB(43, 58, 61)
	local wood = Color3.fromRGB(142, 104, 72)
	local board = Color3.fromRGB(38, 76, 62)
	local ground, spacing = 0.8, 12.85714
	local function part(parent, name, size, pos, color, material, collide)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Position = name, size, pos
		p.Color, p.Material = color, material
		p.Anchored, p.CanCollide, p.CanTouch = true, collide, false
		p.CanQuery, p.CastShadow = collide, collide
		p.Parent = parent
		return p
	end
	local function wall(parent, name, x0, x1, z0, z1, base)
		if x1-x0 > 0.05 and z1-z0 > 0.05 then
			part(parent,name,Vector3.new(x1-x0,11.8,z1-z0),Vector3.new((x0+x1)/2,base+5.9,(z0+z1)/2),ivory,Enum.Material.Concrete,true)
		end
	end
	local function sign(parent, id, position, orientation)
		local p = part(parent,"RoomSign",Vector3.new(2.5,1.2,0.15),position,blue,Enum.Material.SmoothPlastic,false)
		p.Orientation = Vector3.new(0,orientation,0)
		local surface = Instance.new("SurfaceGui")
		surface.Face, surface.LightInfluence, surface.Parent = Enum.NormalId.Front, 0, p
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency, label.Text = UDim2.fromScale(1,1), 1, id
		label.TextColor3, label.TextScaled, label.Font, label.Parent = Color3.new(1,1,1), true, Enum.Font.GothamBold, surface
	end
	local function desk(parent,x,z,base)
		part(parent,"DeskTop",Vector3.new(3,0.22,1.6),Vector3.new(x,base+2.35,z),wood,Enum.Material.WoodPlanks,true)
		for _, dx in ipairs({-1.25,1.25}) do
			part(parent,"DeskLeg",Vector3.new(0.15,2.25,1.3),Vector3.new(x+dx,base+1.125,z),dark,Enum.Material.Metal,false)
		end
		part(parent,"ChairSeat",Vector3.new(1.4,0.18,1.3),Vector3.new(x,base+1.25,z-1.65),wood,Enum.Material.WoodPlanks,false)
		part(parent,"ChairBack",Vector3.new(1.4,1.5,0.16),Vector3.new(x,base+1.9,z-2.25),wood,Enum.Material.WoodPlanks,false)
	end
	local function boardX(parent,x,z,base)
		part(parent,"ChalkboardFrame",Vector3.new(0.18,4.4,8.4),Vector3.new(x,base+6,z),wood,Enum.Material.WoodPlanks,false)
		part(parent,"Chalkboard",Vector3.new(0.2,4,8),Vector3.new(x+0.03,base+6,z),board,Enum.Material.SmoothPlastic,false)
	end
	local function roomWing(parent,side,z0,z1,base,id)
		local east = side == "East"
		local roomX0, roomX1, corridorX = if east then 5498.2 else 5387.65, if east then 5526.45 else 5413, if east then 5498.2 else 5413
		local center, gap = (z0+z1)/2, 4.4
		wall(parent,"RoomDivider",roomX0,roomX1,z0,z0+0.25,base)
		wall(parent,"RoomDivider",roomX0,roomX1,z1-0.25,z1,base)
		wall(parent,"CorridorWall",corridorX-0.18,corridorX+0.18,z0,center-gap/2,base)
		wall(parent,"CorridorWall",corridorX-0.18,corridorX+0.18,center+gap/2,z1,base)
		part(parent,"DoorHeader",Vector3.new(0.36,3.6,gap),Vector3.new(corridorX,base+10,center),ivory,Enum.Material.Concrete,true)
		local sx = if east then corridorX-0.24 else corridorX+0.24
		sign(parent,id,Vector3.new(sx,base+8.4,center+3),if east then -90 else 90)
		local bx = if east then 5526.05 else 5387.95
		boardX(parent,bx,center,base)
		local first = if east then 5507 else 5393
		for _, x in ipairs({first,first+6}) do for _, z in ipairs({z0+4,z1-3}) do desk(parent,x,z,base) end end
	end
	local function roomBar(parent,x0,x1,base,id)
		local center, gap = (x0+x1)/2, 4.4
		wall(parent,"RoomDivider",x0,x0+0.25,1698,1723.65,base)
		wall(parent,"RoomDivider",x1-0.25,x1,1698,1723.65,base)
		wall(parent,"CorridorWall",x0,center-gap/2,1697.82,1698.18,base)
		wall(parent,"CorridorWall",center+gap/2,x1,1697.82,1698.18,base)
		part(parent,"DoorHeader",Vector3.new(gap,3.6,0.36),Vector3.new(center,base+10,1698),ivory,Enum.Material.Concrete,true)
		sign(parent,id,Vector3.new(center+3.2,base+8.4,1697.75),0)
		part(parent,"ChalkboardFrame",Vector3.new(8.4,4.4,0.18),Vector3.new(center,base+6,1723.4),wood,Enum.Material.WoodPlanks,false)
		part(parent,"Chalkboard",Vector3.new(8,4,0.2),Vector3.new(center,base+6,1723.36),board,Enum.Material.SmoothPlastic,false)
		for _, x in ipairs({center-3,center+3}) do for _, z in ipairs({1706,1715}) do desk(parent,x,z,base) end end
	end
	local function railZ(parent,x,z0,z1,base)
		part(parent,"GalleryHandrail",Vector3.new(0.25,0.25,z1-z0),Vector3.new(x,base+3.3,(z0+z1)/2),blue,Enum.Material.Metal,true)
		part(parent,"GalleryGuard",Vector3.new(0.2,3,z1-z0),Vector3.new(x,base+1.6,(z0+z1)/2),blue,Enum.Material.Metal,true).Transparency = 0.6
		for z=z0,z1,12 do part(parent,"GalleryPost",Vector3.new(0.45,3.5,0.45),Vector3.new(x,base+1.75,z),ivory,Enum.Material.Concrete,true) end
	end
	for floor=1,3 do
		local base = ground+(floor-1)*spacing
		local folder = Instance.new("Folder")
		folder.Name = "Floor_" .. floor
		folder.Parent = all
		local number = 0
		local function nextId() number += 1; return string.format("B1-%d%02d",floor,number) end
		for z=1575,1665,15 do roomWing(folder,"East",z,z+15,base,nextId()) end
		for _, bounds in ipairs({{1575,1588},{1662,1676},{1676,1689}}) do roomWing(folder,"West",bounds[1],bounds[2],base,nextId()) end
		for _, bounds in ipairs({{5421,5436},{5436,5451},{5463,5477},{5477,5491}}) do roomBar(folder,bounds[1],bounds[2],base,nextId()) end
		railZ(folder,5420,1575,1690,base)
		railZ(folder,5491.2,1575,1690,base)
		part(folder,"GalleryHandrail",Vector3.new(71.2,0.25,0.25),Vector3.new(5455.6,base+3.3,1690.3),blue,Enum.Material.Metal,true)
		local guard=part(folder,"GalleryGuard",Vector3.new(71.2,3,0.2),Vector3.new(5455.6,base+1.6,1690.3),blue,Enum.Material.Metal,true)
		guard.Transparency = 0.6
		for x=5420,5491,12 do part(folder,"GalleryPost",Vector3.new(0.45,3.5,0.45),Vector3.new(x,base+1.75,1690.3),ivory,Enum.Material.Concrete,true) end
		if floor > 1 then
			local z0 = if floor == 2 then 1590 else 1630
			for _,x in ipairs({5393,5403}) do part(folder,"StairGuard",Vector3.new(0.2,3,29),Vector3.new(x,base+1.5,z0+14.5),blue,Enum.Material.Metal,true) end
		end
		task.wait()
	end
	-- Remove only the former courtyard shell walls and their fake window panels.
	local remove = {}
	for _, p in ipairs(b1:GetChildren()) do
		if p:IsA("BasePart") then
			if p.Name == "CourtyardWestWall" or p.Name == "CourtyardEastWall" or p.Name == "CourtyardBackWall" then
				table.insert(remove,p)
			elseif p.Name == "Window" and (math.abs(p.Position.X-5420)<0.5 or math.abs(p.Position.X-5491.2)<0.5 or math.abs(p.Position.Z-1690.3)<0.5) then
				table.insert(remove,p)
			end
		end
	end
	assert(#remove > 9 and #remove < 250, "Unexpected courtyard shell")
	local floors = all:GetChildren()
	for _, folder in ipairs(floors) do folder.Parent = nil end
	all.Parent = b1
	for _, folder in ipairs(floors) do
		folder.Parent = all
		task.wait()
	end
	for _, p in ipairs(remove) do p:Destroy() end
	return string.format("Added 42 classrooms on three floors, open courtyard galleries and railings; removed %d former courtyard wall/window parts",#remove)
end
