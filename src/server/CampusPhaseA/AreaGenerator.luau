--!strict
-- Flat, non-collidable open-area blocks for the Phase A plan view.
local AreaGenerator = {}

type AreaSpec = {
	id: string,
	label: string,
	category: string,
	centerMeters: { number },
	sizeMeters: { number },
	rotationDegrees: number,
	confidence: string,
}

local COLORS: { [string]: Color3 } = {
	sports = Color3.fromRGB(89, 139, 91),
	parking = Color3.fromRGB(89, 96, 102),
	green = Color3.fromRGB(74, 124, 84),
	transit = Color3.fromRGB(123, 130, 132),
}

function AreaGenerator.Build(
	parent: Instance,
	origin: CFrame,
	spec: AreaSpec,
	studsPerMeter: number
): Part
	local slab = Instance.new("Part")
	slab.Name = spec.id
	slab.Anchored = true
	slab.CanCollide = false
	slab.CanTouch = false
	slab.CanQuery = false
	slab.CastShadow = false
	slab.Material = Enum.Material.SmoothPlastic
	slab.Color = COLORS[spec.category] or Color3.fromRGB(115, 123, 124)
	slab.Size = Vector3.new(spec.sizeMeters[1] * studsPerMeter, 1, spec.sizeMeters[2] * studsPerMeter)
	slab.CFrame = origin
		* CFrame.new(spec.centerMeters[1] * studsPerMeter, 0.6, spec.centerMeters[2] * studsPerMeter)
		* CFrame.Angles(0, math.rad(spec.rotationDegrees), 0)
	slab:SetAttribute("MapLabel", spec.label)
	slab:SetAttribute("AreaConfidence", spec.confidence)
	slab.Parent = parent
	return slab
end

return table.freeze(AreaGenerator)
