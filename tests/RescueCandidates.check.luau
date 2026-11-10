-- Studio Play server; local clearance only, not proof of a navigable route. SURV-01.
local campus = workspace:WaitForChild("FNABK_Campus_PixelBuildings_PhaseC_v6")
local anchors = workspace:WaitForChild("FNABKBaseClaimPoints")
local paths = game:GetService("PathfindingService")
for _, name in ipairs({ "B3", "B4", "B6", "A1", "A2", "A4", "C1", "C2", "C3" }) do
	local building = assert(campus.Buildings:FindFirstChild(name), "missing candidate " .. name)
	local floor
	for _, part in ipairs(building:GetDescendants()) do
		if part:IsA("BasePart") and (part.Name:find("WalkableFloor") or part.Name == "WestFloor")
			and (not floor or part.Position.Y < floor.Position.Y) then floor = part end
	end
	assert(floor, "missing candidate floor " .. name)
	local station = floor.CFrame * CFrame.new(4, floor.Size.Y / 2 + 1, 0)
	local overlap = OverlapParams.new()
	overlap.FilterType, overlap.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { floor }
	for _, part in ipairs(workspace:GetPartBoundsInBox(station, Vector3.new(2, 2, 2), overlap)) do
		assert(not part.CanCollide, name .. " station intersects " .. part:GetFullName())
	end
	local clear = 0
	for i = 0, 7 do
		local angle = i * math.pi / 4
		local origin = station.Position + Vector3.new(math.cos(angle) * 5, 1.5, math.sin(angle) * 5)
		local ray = RaycastParams.new()
		ray.RespectCanCollide = true
		if not workspace:Raycast(origin, station.Position - origin, ray) and workspace:Raycast(origin, Vector3.new(0, -8, 0), ray) then clear += 1 end
	end
	assert(clear > 0, name .. " has no sampled clear approach")
	local anchor = assert(anchors:FindFirstChild(name), "missing anchor " .. name)
	local path = paths:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
	path:ComputeAsync(anchor.Position + Vector3.new(0, 2, 0), station.Position + Vector3.new(0, 1, 0))
	print(string.format("%s: %d/8 local approaches, anchor path %s", name, clear, tostring(path.Status)))
end
return "Candidate clearance checks completed; inspect path statuses and test actual routes"
