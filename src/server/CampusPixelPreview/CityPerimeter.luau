--!strict
-- Low-detail streets and buildings outside the campus perimeter (SURV-12).
local City = {}

function City.Build(campus: Model): Model
	local name = "CityPerimeter_20261104"
	assert(not campus:FindFirstChild(name), name .. " already exists")
	local boundary = assert(campus:FindFirstChild("CampusBoundaryAndGates_v1"))
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	for _, edge in ipairs(boundary:GetChildren()) do
		if edge.Name:match("^BoundaryEdge_%d+$") then
			for _, p in ipairs(edge:GetChildren()) do
				if p.Name == "BoundaryBase" and p:IsA("BasePart") then
					local d = p.CFrame.RightVector * p.Size.X / 2
					for _, v in ipairs({p.Position - d, p.Position + d}) do
						minX, maxX = math.min(minX, v.X), math.max(maxX, v.X)
						minZ, maxZ = math.min(minZ, v.Z), math.max(maxZ, v.Z)
					end
				end
			end
		end
	end
	assert(minX < maxX and minZ < maxZ, "Campus fence bounds are missing")
	local west, east, north, south = minX - 35, maxX + 35, minZ - 35, maxZ + 35
	local edge1 = assert(boundary:FindFirstChild("BoundaryEdge_1"))
	local edge10 = assert(boundary:FindFirstChild("BoundaryEdge_10"))
	local gate1 = assert(edge1:FindFirstChild("CampusGate_1"))
	local gate2 = assert(edge10:FindFirstChild("CampusGate_2"))
	local gate3 = assert(edge10:FindFirstChild("CampusGate_3"))
	assert(gate1:IsA("Model") and gate2:IsA("Model") and gate3:IsA("Model"), "Campus gates must be models")
	local pillars: { BasePart } = {}
	for _, p in ipairs(gate1:GetChildren()) do if p:IsA("BasePart") and p.Name == "GatePillar" then table.insert(pillars, p) end end
	assert(#pillars == 2, "Gate 1 needs two pillars")
	table.sort(pillars, function(a, b) return a.Position.Z < b.Position.Z end)
	local midpoint = (pillars[1].Position + pillars[2].Position) / 2
	local along = Vector3.new(pillars[2].Position.X-pillars[1].Position.X, 0, pillars[2].Position.Z-pillars[1].Position.Z).Unit
	local outward = Vector3.new(along.Z, 0, -along.X)
	local gateFrame = CFrame.fromMatrix(Vector3.new(midpoint.X, 0, midpoint.Z), outward, Vector3.yAxis, along)
	local gate2Pos, gate3Pos = gate2:GetPivot().Position, gate3:GetPivot().Position
	local model = Instance.new("Model")
	model.Name = name
	local asphalt, sidewalk = Color3.fromRGB(54, 58, 61), Color3.fromRGB(146, 143, 133)
	local paint, ground = Color3.fromRGB(215, 205, 164), Color3.fromRGB(108, 109, 101)
	local walls = { Color3.fromRGB(158,145,128), Color3.fromRGB(135,142,138), Color3.fromRGB(153,133,120), Color3.fromRGB(130,139,148) }
	local roof, glass = Color3.fromRGB(74,76,77), Color3.fromRGB(66,83,88)
	local function block(label: string, cf: CFrame, size: Vector3, color: Color3, material: Enum.Material, solid: boolean)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = label, size, cf
		p.Color, p.Material, p.Anchored = color, material, true
		p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = solid, solid, false, solid
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = model
	end
	local function groundStrip(x1: number, x2: number, z1: number, z2: number)
		block("CityGround", CFrame.new((x1+x2)/2,-0.35,(z1+z2)/2), Vector3.new(x2-x1,0.6,z2-z1), ground, Enum.Material.Concrete, true)
	end
	groundStrip(west-75,minX-5,north-75,south+75)
	groundStrip(maxX+5,east+75,north-75,south+75)
	groundStrip(west-75,east+75,north-75,minZ-5)
	groundStrip(west-75,east+75,maxZ+5,south+75)
	local function road(label: string, x1: number, x2: number, z1: number, z2: number)
		block(label,CFrame.new((x1+x2)/2,-0.11,(z1+z2)/2),Vector3.new(x2-x1,0.2,z2-z1),asphalt,Enum.Material.Asphalt,true)
	end
	road("WestRoad",west-14,west+14,north-14,south+14)
	road("EastRoad",east-14,east+14,north-14,south+14)
	road("NorthRoad",west+14,east-14,north-14,north+14)
	road("SouthRoad",west+14,east-14,south-14,south+14)
	-- Sidewalks stop at crossings so all gate approaches remain open.
	local function sidewalkSections(axis: string, fixed: number, first: number, last: number, gaps: { number })
		table.sort(gaps)
		local from = first
		for _, gap in ipairs(gaps) do
			local finish = math.clamp(gap - 17, first, last)
			if finish > from then
				local mid, length = (from + finish)/2, finish-from
				block("Sidewalk",if axis == "x" then CFrame.new(mid,0.04,fixed) else CFrame.new(fixed,0.04,mid),if axis == "x" then Vector3.new(length,0.28,6) else Vector3.new(6,0.28,length),sidewalk,Enum.Material.Concrete,true)
			end
			from = math.max(from, math.clamp(gap + 17, first, last))
		end
		if last > from then
			local mid, length = (from + last)/2, last-from
			block("Sidewalk",if axis == "x" then CFrame.new(mid,0.04,fixed) else CFrame.new(fixed,0.04,mid),if axis == "x" then Vector3.new(length,0.28,6) else Vector3.new(6,0.28,length),sidewalk,Enum.Material.Concrete,true)
		end
	end
	local gate1Z = midpoint.Z + outward.Z * ((east - 17 - midpoint.X) / outward.X)
	for _, x in ipairs({west-17,west+17}) do sidewalkSections("z",x,north+20,south-20,{}) end
	sidewalkSections("z",east-17,north+20,south-20,{gate1Z})
	sidewalkSections("z",east+17,north+20,south-20,{})
	sidewalkSections("x",north+17,west+20,east-20,{gate2Pos.X,gate3Pos.X})
	sidewalkSections("x",north-17,west+20,east-20,{})
	for _, z in ipairs({south-17,south+17}) do sidewalkSections("x",z,west+20,east-20,{}) end
	for z = north + 22, south - 22, 32 do
		for _, x in ipairs({west,east}) do block("CenterDash",CFrame.new(x,0.005,z),Vector3.new(0.35,0.025,12),paint,Enum.Material.SmoothPlastic,false) end
	end
	for x = west + 30, east - 30, 32 do
		for _, z in ipairs({north,south}) do block("CenterDash",CFrame.new(x,0.005,z),Vector3.new(12,0.025,0.35),paint,Enum.Material.SmoothPlastic,false) end
	end
	-- Gate 1 points diagonally outward; Gates 2 and 3 face the north road.
	local length = (east - midpoint.X) / outward.X + 14
	assert(length > 18, "Gate 1 connector is too short")
	block("Gate1Approach",gateFrame*CFrame.new((18+length)/2,-0.12,0),Vector3.new(length-18,0.2,28),asphalt,Enum.Material.Asphalt,true)
	block("Gate1Ground",gateFrame*CFrame.new((18+length)/2,-0.35,0),Vector3.new(length-18,0.6,40),ground,Enum.Material.Concrete,true)
	for _, gate in ipairs({gate2Pos,gate3Pos}) do
		road("NorthGateApproach",gate.X-12,gate.X+12,north,gate.Z-10)
	end
	-- ponytail: one row of simple shells; add interiors only if this district becomes playable.
	local function houses(first: Vector3, tangent: Vector3, outer: Vector3, length: number)
		local count = math.floor(length / 58)
		for i = 1, count do
			local at = first + tangent * ((i-0.5) * length / count) + outer * 44
			local h = ({22,31,26,35,23,29})[(i-1)%6+1]
			local f = CFrame.fromMatrix(Vector3.new(at.X,0,at.Z),Vector3.yAxis:Cross(outer),Vector3.yAxis,outer)
			block("House",f*CFrame.new(0,h/2,0),Vector3.new(34,h,26),walls[(i-1)%#walls+1],Enum.Material.Concrete,true)
			block("Roof",f*CFrame.new(0,h+0.6,0),Vector3.new(35.5,1.2,27.5),roof,Enum.Material.Concrete,false)
			block("Door",f*CFrame.new(0,3,-13.08),Vector3.new(4,6,0.18),roof,Enum.Material.SmoothPlastic,false)
			for _, x in ipairs({-9,9}) do block("Window",f*CFrame.new(x,h*0.56,-13.08),Vector3.new(6,6,0.18),glass,Enum.Material.Glass,false) end
		end
	end
	houses(Vector3.new(west,0,north+24),Vector3.zAxis,Vector3.new(-1,0,0),south-north-48)
	houses(Vector3.new(east,0,north+24),Vector3.zAxis,Vector3.xAxis,south-north-48)
	houses(Vector3.new(west+24,0,north),Vector3.xAxis,Vector3.new(0,0,-1),east-west-48)
	houses(Vector3.new(west+24,0,south),Vector3.xAxis,Vector3.zAxis,east-west-48)
	model.Parent = campus
	return model
end

return table.freeze(City)
