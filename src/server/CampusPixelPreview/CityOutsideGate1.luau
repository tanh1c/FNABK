--!strict
-- Lightweight city backdrop outside campus Gate 1 (SURV-12).
local City = {}

function City.Build(campus: Model): Model
	local name = "CityOutsideGate1_20261104"
	assert(not campus:FindFirstChild(name), name .. " already exists")
	local boundary = assert(campus:FindFirstChild("CampusBoundaryAndGates_v1"))
	local edge = assert(boundary:FindFirstChild("BoundaryEdge_1"))
	local gate = assert(edge:FindFirstChild("CampusGate_1"))
	local pillars: { BasePart } = {}
	for _, item in ipairs(gate:GetChildren()) do
		if item.Name == "GatePillar" and item:IsA("BasePart") then table.insert(pillars, item) end
	end
	assert(#pillars == 2, "Gate 1 must have two pillars")
	table.sort(pillars, function(a, b) return a.Position.Z < b.Position.Z end)
	local middle = (pillars[1].Position + pillars[2].Position) / 2
	local along = Vector3.new(pillars[2].Position.X - pillars[1].Position.X, 0, pillars[2].Position.Z - pillars[1].Position.Z).Unit
	local outward = Vector3.new(along.Z, 0, -along.X)
	local frame = CFrame.fromMatrix(Vector3.new(middle.X, 0, middle.Z), outward, Vector3.yAxis, along)
	local model = Instance.new("Model")
	model.Name = name
	local function block(label: string, pos: Vector3, size: Vector3, color: Color3, material: Enum.Material, solid: boolean)
		local p = Instance.new("Part")
		p.Name = label
		p.Size = size
		p.CFrame = frame * CFrame.new(pos)
		p.Color = color
		p.Material = material
		p.Anchored = true
		p.CanCollide = solid
		p.CanTouch = false
		p.CanQuery = solid
		p.CastShadow = solid
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = model
	end
	local asphalt = Color3.fromRGB(54, 58, 61)
	local concrete = Color3.fromRGB(146, 143, 133)
	local roadPaint = Color3.fromRGB(215, 205, 164)
	block("CityGround", Vector3.new(168, -0.35, 0), Vector3.new(300, 0.6, 130), Color3.fromRGB(108, 109, 101), Enum.Material.Concrete, true)
	block("Asphalt", Vector3.new(168, -0.12, 0), Vector3.new(300, 0.2, 28), asphalt, Enum.Material.Asphalt, true)
	for _, side in ipairs({-1, 1}) do
		block("Sidewalk", Vector3.new(168, 0.04, side * 17), Vector3.new(300, 0.28, 6), concrete, Enum.Material.Concrete, true)
		block("RoadEdge", Vector3.new(168, -0.005, side * 13), Vector3.new(300, 0.025, 0.3), roadPaint, Enum.Material.SmoothPlastic, false)
	end
	for i = 0, 11 do
		block("CenterDash", Vector3.new(30 + i * 24, -0.005, 0), Vector3.new(10, 0.025, 0.35), roadPaint, Enum.Material.SmoothPlastic, false)
	end
	local walls = { Color3.fromRGB(158, 145, 128), Color3.fromRGB(135, 142, 138), Color3.fromRGB(153, 133, 120), Color3.fromRGB(130, 139, 148) }
	local roof = Color3.fromRGB(74, 76, 77)
	local glass = Color3.fromRGB(66, 83, 88)
	-- ponytail: fixed low-detail shells; add interiors if this district becomes playable.
	for _, side in ipairs({-1, 1}) do
		for i = 1, 6 do
			local x = 42 + (i - 1) * 51
			local z = side * 42
			local height = ({22, 31, 26, 35, 23, 29})[i]
			local front = z - side * 13.08
			block("House", Vector3.new(x, height / 2, z), Vector3.new(34, height, 26), walls[(i + (if side == 1 then 1 else 0) - 1) % #walls + 1], Enum.Material.Concrete, true)
			block("Roof", Vector3.new(x, height + 0.6, z), Vector3.new(35.5, 1.2, 27.5), roof, Enum.Material.Concrete, false)
			block("Door", Vector3.new(x, 3, front), Vector3.new(4, 6, 0.18), roof, Enum.Material.SmoothPlastic, false)
			for _, offset in ipairs({-9, 9}) do
				block("Window", Vector3.new(x + offset, height * 0.56, front), Vector3.new(6, 6, 0.18), glass, Enum.Material.Glass, false)
			end
		end
	end
	model.Parent = campus
	return model
end

return table.freeze(City)
