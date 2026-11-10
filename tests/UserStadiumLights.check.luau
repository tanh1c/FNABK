-- Run in Studio's command bar with campus v6 in Workspace.
local campus = assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6"))
local lights = assert(campus:FindFirstChild("UserStadiumLights_20261104"))
assert(#lights:GetChildren() == 2, "Expected two stadium light models")
for _, model in ipairs(lights:GetChildren()) do
	local pole, count = nil, 0
	for _, item in ipairs(model:GetDescendants()) do
		assert(not item:IsA("LuaSourceContainer"), "Imported scripts must not run")
		if item:IsA("BasePart") then
			assert(item.Anchored and not item.CanCollide, "Light geometry must be anchored and nonblocking")
			if item.Size.Y > 60 then pole = item end
		elseif item:IsA("Light") then count += 1 end
	end
	assert(pole and math.abs(pole.CFrame.UpVector.Y) > 0.99, "Pole must stand upright")
	assert(count == 1, "Each mast should have one light")
end
print("Stadium light placement checks passed")
