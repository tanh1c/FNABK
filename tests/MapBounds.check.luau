local bounds = require(game.ReplicatedStorage.FNABKShared.MapBounds)
local cf = CFrame.new(10, 4, -3) * CFrame.Angles(.3, .7, .2)
local size = Vector3.new(8, 6, 4)
local minX, maxX, minZ, maxZ = bounds.project(cf, size)
local actual = { math.huge, -math.huge, math.huge, -math.huge }
for _, x in ipairs({ -1, 1 }) do
	for _, y in ipairs({ -1, 1 }) do
		for _, z in ipairs({ -1, 1 }) do
			local p = cf:PointToWorldSpace(Vector3.new(x * size.X / 2, y * size.Y / 2, z * size.Z / 2))
			actual[1], actual[2] = math.min(actual[1], p.X), math.max(actual[2], p.X)
			actual[3], actual[4] = math.min(actual[3], p.Z), math.max(actual[4], p.Z)
		end
	end
end
for i, value in ipairs({ minX, maxX, minZ, maxZ }) do assert(math.abs(value - actual[i]) < 1e-4) end
print("Map bounds check passed")
