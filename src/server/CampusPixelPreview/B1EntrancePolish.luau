-- AI-assisted visual pass; the original entrance and building remain untouched.
return function()
	local body = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1.B1_ContinuousBuilding
	local entrance = body.B1_MainEntrance
	assert(not body:FindFirstChild("B1_EntrancePolish_v1"), "B1 polish already exists; preserve it")
	local canopy = entrance.EntryCanopy
	local group = Instance.new("Model")
	group.Name = "B1_EntrancePolish_v1"
	local blue = Color3.fromRGB(26, 67, 91)
	local ivory = Color3.fromRGB(225, 229, 216)
	local amber = Color3.fromRGB(198, 149, 75)
	local function detail(name, size, offset, color)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.CFrame = canopy.CFrame * CFrame.new(offset)
		part.Color = color
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Parent = group
	end
	-- ponytail: decorative geometry only; add functional lighting after a performance review.
	detail("CanopyTopEdge", Vector3.new(24, 0.18, 0.22), Vector3.new(0, 0.49, 4.03), ivory)
	detail("CanopyLowerEdge", Vector3.new(24, 0.16, 0.22), Vector3.new(0, -0.49, 4.03), blue)
	detail("CanopyCenterAccent", Vector3.new(8, 0.16, 0.23), Vector3.new(0, 0, 4.05), amber)
	for _, side in ipairs({-1, 1}) do
		detail("CanopySideEdge", Vector3.new(0.18, 0.18, 8), Vector3.new(side * 12.03, 0.49, 0), ivory)
		detail("PortalVerticalAccent", Vector3.new(0.22, 7.5, 0.18), Vector3.new(side * 11.15, -5.1, 4.03), blue)
		detail("PortalCap", Vector3.new(2.2, 0.18, 0.2), Vector3.new(side * 10.9, -1.2, 4.03), amber)
		detail("SoffitStrip", Vector3.new(0.3, 0.12, 6), Vector3.new(side * 8.5, -0.47, 0), ivory)
	end
	assert(#group:GetChildren() == 11, "Unexpected polish part count")
	group.Parent = body
	return "B1 entrance polish: 11 non-colliding decorative parts added"
end
