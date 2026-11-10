--!strict
-- Geometry from Creator Store asset 2871491493, Park Bench by Atarki.
-- The original model contains only parts and seats; seats are omitted for a
-- decorative, non-interactive prop. No executable content is copied.
local pieces = {
	{ {9.2258, 0.1677, 0.8387}, {0, -0.1677, -0.5031, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.6392, 0.6353, 0.6471}, "Plastic" },
	{ {0.3355, 2.0129, 0.3355}, {-4.2774, -1.258, -0.9225, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {8.2194, 0.3355, 0.3355}, {0, -2.4323, 0.9226, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {0.3355, 2.1806, 0.3355}, {4.2774, -1.1742, -1.0903, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {0.3355, 0.3355, 4.1935}, {-4.2774, -2.4323, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {9.2258, 0.1677, 0.8387}, {0, -0.1677, 0.5033, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.6392, 0.6353, 0.6471}, "Plastic" },
	{ {8.2194, 0.3355, 0.3355}, {0, -2.4322, -0.5871, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {9.2258, 0.1677, 0.8387}, {0, -0.1677, 1.5097, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.6392, 0.6353, 0.6471}, "Plastic" },
	{ {0.3355, 2.0129, 0.3355}, {-4.2774, -1.2581, 1.2581, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {0.3355, 2.0129, 0.3355}, {4.2775, -1.258, 1.2581, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {0.3355, 0.3355, 4.1935}, {4.2774, -2.4322, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {9.2258, 0.1677, 0.8387}, {0, 0.291, -1.2948, 1, 0, 0, 0, 0.6428, -0.766, 0, 0.766, 0.6428}, {0.6392, 0.6353, 0.6471}, "Plastic" },
	{ {0.3355, 4.8645, 0.3355}, {4.2774, 0.1677, -1.929, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {0.3355, 4.8645, 0.3355}, {-4.2774, 0.1677, -1.929, 1, 0, 0, 0, 1, 0, 0, 0, 1}, {0.3882, 0.3725, 0.3843}, "Metal" },
	{ {9.2258, 0.1677, 0.8387}, {0, 1.1552, -1.6063, 1, 0, 0, 0, 0, -1, 0, 1, 0}, {0.6392, 0.6353, 0.6471}, "Plastic" },
	{ {9.2258, 0.1677, 0.8387}, {0, 2.1617, -1.6063, 1, 0, 0, 0, 0, -1, 0, 1, 0}, {0.6392, 0.6353, 0.6471}, "Plastic" },
}

local Bench = {}
function Bench.Build(parent: Instance, position: Vector3)
	local model = Instance.new("Model")
	model.Name = "MarketplaceParkBench"
	for _, piece in ipairs(pieces) do
		local p = Instance.new("Part")
		p.Name = "BenchPiece"
		p.Anchored = true
		p.CanCollide = true
		p.CanTouch = false
		p.CanQuery = true
		p.CastShadow = false
		p.Size = Vector3.new(table.unpack(piece[1] :: {number}))
		p.CFrame = CFrame.new(position) * CFrame.new(table.unpack(piece[2] :: {number}))
		p.Color = Color3.new(table.unpack(piece[3] :: {number}))
		p.Material = Enum.Material[piece[4] :: string]
		p.Parent = model
	end
	model.Parent = parent
end
return table.freeze(Bench)
