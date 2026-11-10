--!strict
-- Project an oriented bounding box to world X/Z for the campus map.
local MapBounds = {}
function MapBounds.project(cf: CFrame, size: Vector3): (number, number, number, number)
	local half = size * 0.5
	local x = math.abs(cf.RightVector.X) * half.X + math.abs(cf.UpVector.X) * half.Y + math.abs(cf.LookVector.X) * half.Z
	local z = math.abs(cf.RightVector.Z) * half.X + math.abs(cf.UpVector.Z) * half.Y + math.abs(cf.LookVector.Z) * half.Z
	return cf.Position.X - x, cf.Position.X + x, cf.Position.Z - z, cf.Position.Z + z
end
return table.freeze(MapBounds)
