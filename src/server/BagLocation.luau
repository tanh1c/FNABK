--!strict
-- SURV-08: protect bags created below Roblox's destruction plane.
local BagLocation = {}
function BagLocation.resolve(position: Vector3, destroyHeight: number, fallback: Vector3?, spawn: Vector3?): Vector3?
	if position.Y <= destroyHeight + 10 then
		if fallback and fallback.Y > destroyHeight + 10 then return fallback end
		if spawn and spawn.Y > destroyHeight + 10 then return spawn end
		return nil
	end
	return position
end
return table.freeze(BagLocation)
