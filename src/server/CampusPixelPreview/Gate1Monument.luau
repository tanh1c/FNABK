--!strict
-- Native Gate 1 monument inspired by the supplied campus photo (SURV-12).
local Gate = {}

function Gate.Build(campus: Model): Model
	local name = "Gate1Monument_20261104"
	assert(not campus:FindFirstChild(name), name .. " already exists")
	local boundary = assert(campus:FindFirstChild("CampusBoundaryAndGates_v1"))
	local edge = assert(boundary:FindFirstChild("BoundaryEdge_1"))
	local oldGate = assert(edge:FindFirstChild("CampusGate_1"))
	local header = assert(oldGate:FindFirstChild("GateHeader"))
	assert(header:IsA("BasePart"), "Gate 1 header must be a BasePart")
	local frame = CFrame.new(header.Position.X,0,header.Position.Z) * header.CFrame.Rotation
	local model = Instance.new("Model")
	model.Name = name
	local blue = Color3.fromRGB(26,64,142)
	local deepBlue = Color3.fromRGB(18,43,106)
	local brightBlue = Color3.fromRGB(50,99,190)
	local stone = Color3.fromRGB(53,58,62)
	local white = Color3.fromRGB(227,231,228)
	local function part(label: string, pos: Vector3, size: Vector3, color: Color3, material: Enum.Material): Part
		local p = Instance.new("Part")
		p.Name, p.CFrame, p.Size = label, frame * CFrame.new(pos), size
		p.Color, p.Material, p.Anchored = color, material, true
		local solid = label == "BlueTower" or label == "TowerFoundation" or label == "UniversityNameWall"
			or label == "AddressStone" or label == "OppositePillar" or label == "Guardhouse"
		p.CanCollide, p.CanTouch, p.CanQuery = solid, false, solid
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = model
		return p
	end
	local function sign(p: BasePart, text: string, size: number)
		local gui = Instance.new("SurfaceGui")
		gui.Name, gui.Face, gui.CanvasSize = "Lettering", Enum.NormalId.Front, Vector2.new(1000, 400)
		gui.LightInfluence = 0.25
		gui.Parent = p
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = white
		label.TextScaled, label.TextWrapped = true, true
		label.Text = text
		label.TextStrokeTransparency = 0.8
		label.Parent = gui
		local constraint = Instance.new("UITextSizeConstraint")
		constraint.MaxTextSize = size
		constraint.Parent = label
	end
	-- The pedestrian/vehicle opening stays clear; the original gate door is unchanged.
	part("MonumentPlaza",Vector3.new(39,0.2,0),Vector3.new(44,0.4,9),stone,Enum.Material.Concrete)
	part("TowerFoundation",Vector3.new(26,0.85,0),Vector3.new(10,1.7,8),stone,Enum.Material.Concrete)
	part("BlueTower",Vector3.new(26,22.5,0),Vector3.new(8,43,5.5),blue,Enum.Material.Metal)
	part("TowerFrontInset",Vector3.new(26,23,-2.79),Vector3.new(6.8,40,0.12),deepBlue,Enum.Material.Metal)
	part("TowerLeftFacet",Vector3.new(23.05,23,-2.87),Vector3.new(1.05,40,0.12),brightBlue,Enum.Material.Metal)
	part("TowerRightFacet",Vector3.new(28.95,23,-2.87),Vector3.new(1.05,40,0.12),blue,Enum.Material.Metal)
	for _,y in ipairs({7,15,23,31,39}) do
		part("TowerPanelJoint",Vector3.new(26,y,-2.95),Vector3.new(6.8,0.12,0.1),brightBlue,Enum.Material.Metal)
		for _,x in ipairs({23.4,28.6}) do part("TowerRivet",Vector3.new(x,y+0.3,-3.02),Vector3.new(0.24,0.24,0.1),white,Enum.Material.Metal) end
	end
	part("TowerCrownBase",Vector3.new(26,45,0),Vector3.new(8.6,2,6),deepBlue,Enum.Material.Metal)
	part("TowerCrownUpright",Vector3.new(26,48.5,0),Vector3.new(3.4,5,4),brightBlue,Enum.Material.Metal)
	part("TowerCrownWings",Vector3.new(26,47.7,0),Vector3.new(7,3.2,4.2),blue,Enum.Material.Metal)
	local emblem = part("BKMonogram",Vector3.new(26,48,-2.17),Vector3.new(4.4,3.5,0.15),white,Enum.Material.SmoothPlastic)
	local emblemGui = Instance.new("SurfaceGui")
	emblemGui.Name, emblemGui.Face, emblemGui.CanvasSize = "BKLettering", Enum.NormalId.Front, Vector2.new(400,300)
	emblemGui.LightInfluence = 0.25
	emblemGui.Parent = emblem
	local emblemText = Instance.new("TextLabel")
	emblemText.Size, emblemText.BackgroundTransparency = UDim2.fromScale(1,1), 1
	emblemText.Font, emblemText.Text, emblemText.TextColor3 = Enum.Font.GothamBold, "BK", deepBlue
	emblemText.TextScaled = true
	emblemText.Parent = emblemGui
	part("UniversityNameWall",Vector3.new(45,4.3,0),Vector3.new(23,8.6,2.3),stone,Enum.Material.Slate)
	part("UniversityNameCap",Vector3.new(45,8.8,0),Vector3.new(23.6,0.45,2.8),white,Enum.Material.Concrete)
	local plaque = part("UniversityNamePlaque",Vector3.new(45,4.5,-1.19),Vector3.new(21.2,6.8,0.12),stone,Enum.Material.SmoothPlastic)
	sign(plaque,"TRƯỜNG ĐẠI HỌC BÁCH KHOA\nHO CHI MINH CITY UNIVERSITY OF TECHNOLOGY",64)
	part("AddressStone",Vector3.new(19.5,4.4,0),Vector3.new(4.5,8.8,4.2),stone,Enum.Material.Slate)
	local address = part("AddressPlaque",Vector3.new(19.5,4.7,-2.15),Vector3.new(3.8,5.6,0.12),stone,Enum.Material.SmoothPlastic)
	sign(address,"268\nLÝ THƯỜNG KIỆT",78)
	part("OppositePillar",Vector3.new(-16,6.4,0),Vector3.new(3.8,12.8,4.1),stone,Enum.Material.Slate)
	part("OppositePillarCap",Vector3.new(-16,13.1,0),Vector3.new(4.2,0.6,4.5),white,Enum.Material.Concrete)
	part("Guardhouse",Vector3.new(-24,4,4),Vector3.new(7,8,7),white,Enum.Material.Concrete)
	part("GuardhouseRoof",Vector3.new(-24,8.25,4),Vector3.new(7.8,0.5,7.8),stone,Enum.Material.Metal)
	part("GuardhouseWindow",Vector3.new(-24,5.1,0.44),Vector3.new(4.8,2.7,0.12),deepBlue,Enum.Material.Glass)
	for _,x in ipairs({33,38,51,56}) do
		part("Flagpole",Vector3.new(x,10,1.5),Vector3.new(0.18,20,0.18),white,Enum.Material.Metal)
		part("RedFlag",Vector3.new(x+1,17.6,1.5),Vector3.new(2,3,0.12),Color3.fromRGB(162,31,33),Enum.Material.Fabric)
	end
	local light = Instance.new("PointLight")
	light.Name, light.Color, light.Brightness, light.Range = "TowerLight", Color3.fromRGB(142,184,255), 1.2, 22
	light.Parent = emblem
	model.Parent = campus
	return model
end

return table.freeze(Gate)
