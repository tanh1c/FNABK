--!strict
-- Additional low-detail city blocks around the campus (SURV-12).
local City = {}

function City.Build(campus: Model): Model
	local name = "CityDistrictExpansion_v2_20261104"
	assert(not campus:FindFirstChild(name), name .. " already exists")
	local previous = assert(campus:FindFirstChild("CityPerimeter_20261104"))
	local boundary = assert(campus:FindFirstChild("CampusBoundaryAndGates_v1"))
	local buildings = assert(campus:FindFirstChild("Buildings"))
	local westRoad = assert(previous:FindFirstChild("WestRoad")) :: BasePart
	local eastRoad = assert(previous:FindFirstChild("EastRoad")) :: BasePart
	local northRoad = assert(previous:FindFirstChild("NorthRoad")) :: BasePart
	local southRoad = assert(previous:FindFirstChild("SouthRoad")) :: BasePart
	local west, east, north, south = westRoad.Position.X, eastRoad.Position.X, northRoad.Position.Z, southRoad.Position.Z
	local outerW, outerE, outerN, outerS = west-140, east+140, north-140, south+140
	local polygon: { Vector3 } = {}
	for i = 1, 10 do
		local edge = assert(boundary:FindFirstChild("BoundaryEdge_" .. i))
		local first: BasePart? = nil
		local pieces: { BasePart } = {}
		for _, p in ipairs(edge:GetChildren()) do
			if p:IsA("BasePart") and p.Name == "BoundaryBase" then table.insert(pieces, p); first = first or p end
		end
		assert(first and #pieces > 0, "Campus boundary edge is empty")
		local origin, direction = first.Position, first.CFrame.RightVector
		local low = math.huge
		for _, p in ipairs(pieces) do low = math.min(low, (p.Position-origin):Dot(direction)-p.Size.X/2) end
		table.insert(polygon, origin + direction*low)
	end
	local function outside(point: Vector3): boolean
		local inside = false
		for i, a in ipairs(polygon) do
			local b = polygon[i % #polygon + 1]
			if (a.Z > point.Z) ~= (b.Z > point.Z) and point.X < (b.X-a.X)*(point.Z-a.Z)/(b.Z-a.Z)+a.X then inside = not inside end
			local ab = Vector3.new(b.X-a.X,0,b.Z-a.Z)
			local ap = Vector3.new(point.X-a.X,0,point.Z-a.Z)
			local t = math.clamp(ap:Dot(ab)/ab:Dot(ab),0,1)
			if (ap-ab*t).Magnitude < 34 then return false end
		end
		return not inside
	end
	local model = Instance.new("Model")
	model.Name = name
	local ground = Color3.fromRGB(105, 108, 103)
	local asphalt = Color3.fromRGB(54, 58, 61)
	local concrete = Color3.fromRGB(146, 143, 133)
	local paint = Color3.fromRGB(215, 205, 164)
	local colors = {Color3.fromRGB(162,148,127),Color3.fromRGB(130,143,144),Color3.fromRGB(152,130,121),Color3.fromRGB(147,149,137),Color3.fromRGB(126,134,147),Color3.fromRGB(172,157,139)}
	local roof, glass = Color3.fromRGB(72,75,75), Color3.fromRGB(62,82,87)
	local blocked: { BasePart } = {}
	local function block(label: string, cf: CFrame, size: Vector3, color: Color3, material: Enum.Material, solid: boolean): Part
		local p = Instance.new("Part")
		p.Name,p.CFrame,p.Size,p.Color,p.Material = label,cf,size,color,material
		p.Anchored,p.CanCollide,p.CanQuery,p.CanTouch,p.CastShadow = true,solid,solid,false,solid
		p.TopSurface,p.BottomSurface = Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
		p.Parent = model
		return p
	end
	-- Visual underlay closes sky gaps without changing collision inside the campus.
	block("CityUnderlay",CFrame.new((west+east)/2,-1,(north+south)/2),Vector3.new(east-west+480,0.2,south-north+480),ground,Enum.Material.Concrete,false)
	local function slab(label: string, x1: number, x2: number, z1: number, z2: number, y: number, height: number, color: Color3, material: Enum.Material): Part
		return block(label,CFrame.new((x1+x2)/2,y,(z1+z2)/2),Vector3.new(x2-x1,height,z2-z1),color,material,true)
	end
	slab("DistrictGround",west-220,west-20,north-220,south+220,-0.42,0.6,ground,Enum.Material.Concrete)
	slab("DistrictGround",east+20,east+220,north-220,south+220,-0.42,0.6,ground,Enum.Material.Concrete)
	slab("DistrictGround",west-20,east+20,north-220,north-20,-0.42,0.6,ground,Enum.Material.Concrete)
	slab("DistrictGround",west-20,east+20,south+20,south+220,-0.42,0.6,ground,Enum.Material.Concrete)
	local function road(x1: number,x2: number,z1: number,z2: number,outer: boolean)
		local p = slab(if outer then "DistrictRoad" else "DistrictConnector",x1,x2,z1,z2,if outer then -0.11 else -0.125,0.2,asphalt,Enum.Material.Asphalt)
		table.insert(blocked,p)
	end
	road(outerW-12,outerW+12,outerN-12,outerS+12,true)
	road(outerE-12,outerE+12,outerN-12,outerS+12,true)
	road(outerW+12,outerE-12,outerN-12,outerN+12,true)
	road(outerW+12,outerE-12,outerS-12,outerS+12,true)
	for _,x in ipairs({west,east}) do road(x-12,x+12,outerN,north,false); road(x-12,x+12,south,outerS,false) end
	for _,z in ipairs({north,south}) do road(outerW,west,z-12,z+12,false); road(east,outerE,z-12,z+12,false) end
	for _,x in ipairs({outerW,outerE}) do
		for z=outerN+24,outerS-24,36 do block("DistrictMarking",CFrame.new(x,0.01,z),Vector3.new(0.35,0.02,12),paint,Enum.Material.SmoothPlastic,false) end
	end
	for _,z in ipairs({outerN,outerS}) do
		for x=outerW+24,outerE-24,36 do block("DistrictMarking",CFrame.new(x,0.01,z),Vector3.new(12,0.02,0.35),paint,Enum.Material.SmoothPlastic,false) end
	end
	for _,x in ipairs({outerW-15,outerW+15,outerE-15,outerE+15}) do
		local p=slab("DistrictSidewalk",x-3,x+3,outerN+20,outerS-20,0.04,0.28,concrete,Enum.Material.Concrete);table.insert(blocked,p)
	end
	for _,z in ipairs({outerN-15,outerN+15,outerS-15,outerS+15}) do
		local p=slab("DistrictSidewalk",outerW+20,outerE-20,z-3,z+3,0.04,0.28,concrete,Enum.Material.Concrete);table.insert(blocked,p)
	end
	for _,p in ipairs(previous:GetChildren()) do
		if p:IsA("BasePart") and (p.Name:find("Road") or p.Name:find("Approach") or p.Name=="Sidewalk") then table.insert(blocked,p) end
	end
	local function roadClear(point: Vector3): boolean
		for _,p in ipairs(blocked) do
			local rel=p.CFrame:PointToObjectSpace(point)
			if math.abs(rel.X)<p.Size.X/2+31 and math.abs(rel.Z)<p.Size.Z/2+31 then return false end
		end
		return true
	end
	local params=OverlapParams.new()
	params.FilterType=Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances={buildings,boundary,previous}
	params.RespectCanCollide=true
	params.MaxParts=25
	local candidates: { Vector3 }={}
	for x=west-205,east+205,68 do
		for z=north-205,south+205,68 do
			local p=Vector3.new(x,3,z)
			if outside(p) and roadClear(p) and #workspace:GetPartBoundsInBox(CFrame.new(p),Vector3.new(54,5,54),params)==0 then table.insert(candidates,p) end
		end
		task.wait()
	end
	-- Offset the southern row so it falls between the two streets and existing houses.
	for x=west,east,68 do
		for z=north-188,south+205,68 do
			if z > south then
				local p=Vector3.new(x,3,z)
				if outside(p) and roadClear(p) and #workspace:GetPartBoundsInBox(CFrame.new(p),Vector3.new(54,5,54),params)==0 then table.insert(candidates,p) end
			end
		end
		task.wait()
	end
	-- ponytail: cap static shells to limit geometry; profile before increasing density.
	local count=math.min(#candidates,150)
	local random=Random.new(20261104)
	for i=1,count do
		local p=candidates[math.floor((i-0.5)*#candidates/count)+1]
		local kind=(i-1)%4+1
		local width=({27,36,31,42})[kind]
		local depth=({25,29,32,27})[kind]
		local height=({18,35,51,25})[kind]+random:NextInteger(-3,4)
		local color=colors[(i-1)%#colors+1]
		local f=CFrame.new(p.X,0,p.Z)*CFrame.Angles(0,math.rad(random:NextInteger(0,3)*90),0)
		block("CityLot",f*CFrame.new(0,-0.42,0),Vector3.new(width+8,0.6,depth+8),concrete,Enum.Material.Concrete,true)
		block(({"Shop","Apartment","Office","Townhouse"})[kind],f*CFrame.new(0,height/2,0),Vector3.new(width,height,depth),color,Enum.Material.Concrete,true)
		block("DistrictRoof",f*CFrame.new(0,height+0.6,0),Vector3.new(width+1.5,1.2,depth+1.5),roof,Enum.Material.Concrete,false)
		local front=-depth/2-0.08
		block("DistrictDoor",f*CFrame.new(0,3,front),Vector3.new(4,6,0.18),roof,Enum.Material.SmoothPlastic,false)
		for _,dx in ipairs({-width*0.26,width*0.26}) do
			block("DistrictWindow",f*CFrame.new(dx,math.min(height-5,9),front),Vector3.new(6,5,0.18),glass,Enum.Material.Glass,false)
			if height>30 then block("DistrictWindow",f*CFrame.new(dx,height-7,front),Vector3.new(6,5,0.18),glass,Enum.Material.Glass,false) end
		end
		if kind==1 then block("ShopAwning",f*CFrame.new(0,7,front-1.1),Vector3.new(width*0.65,0.45,2.2),roof,Enum.Material.Metal,false) end
		if i%25==0 then task.wait() end
	end
	model:SetAttribute("CandidateCount",#candidates)
	model.Parent=campus
	return model
end

return table.freeze(City)
