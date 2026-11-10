--!strict
-- SURV-05: allocate a day's ordered supplies given selected-point free capacity.
local Supply = {}
local ammo = {
	{ 2, 1, 1 }, { 3, 2, 1 }, { 4, 2, 2 }, { 5, 3, 2 },
}
local ammoKinds = { "PistolAmmo", "ShotgunAmmo", "RifleAmmo" }

function Supply.plan(day: number, players: number, outsideCapacity: number, baseCapacity: number): { { kind: string, base: boolean } }
	assert(type(day) == "number" and day % 1 == 0 and day >= 1 and day < math.huge, "invalid day")
	assert(type(players) == "number" and players % 1 == 0 and players >= 1 and players <= 4, "invalid party")
	assert(type(outsideCapacity) == "number" and outsideCapacity % 1 == 0 and outsideCapacity >= 0 and outsideCapacity < math.huge, "invalid outside capacity")
	assert(type(baseCapacity) == "number" and baseCapacity % 1 == 0 and baseCapacity >= 0 and baseCapacity < math.huge, "invalid base capacity")
	local result = {}
	if day == 1 then return result end
	local factor = 1 + 0.5 * (players - 1)
	local quota = { ammo[players][1], ammo[players][2], ammo[players][3] }
	-- For every base item there must be at least three items outside the base.
	local maxTotal = outsideCapacity + math.min(baseCapacity, math.floor(outsideCapacity / 3))
	local function add(kind: string)
		if #result >= maxTotal then return end
		table.insert(result, { kind = kind, base = #result >= outsideCapacity })
	end
	for _ = 1, math.ceil(4 * factor) do add("Water") end
	for _ = 1, math.ceil(3 * factor) do add("Food") end
	local start = (day - 2) % 3 + 1
	while #result < maxTotal and quota[1] + quota[2] + quota[3] > 0 do
		for offset = 0, 2 do
			local index = (start + offset - 1) % 3 + 1
			if quota[index] > 0 and #result < maxTotal then
				add(ammoKinds[index])
				quota[index] -= 1
			end
		end
	end
	return result
end

export type Point = { id: string, stock: number, base: boolean }

function Supply.points(day: number, players: number, points: { Point }): { { kind: string, point: string } }
	local outsideCapacity, baseCapacity = 0, 0
	local free: { number } = {}
	local seen: { [string]: boolean } = {}
	for i, point in ipairs(points) do
		assert(type(point.id) == "string" and point.id ~= "" and not seen[point.id], "invalid or duplicate point")
		assert(type(point.stock) == "number" and point.stock % 1 == 0 and point.stock >= 0 and point.stock <= 10, "invalid stock")
		assert(type(point.base) == "boolean", "invalid base flag")
		seen[point.id] = true
		free[i] = 10 - point.stock
		if point.base then baseCapacity += free[i] else outsideCapacity += free[i] end
	end
	local plan = Supply.plan(day, players, outsideCapacity, baseCapacity)
	local result = {}
	local cursor = { [true] = 1, [false] = 1 }
	for _, item in ipairs(plan) do
		for offset = 0, #points - 1 do
			local index = (cursor[item.base] + offset - 1) % #points + 1
			local point = points[index]
			if point.base == item.base and free[index] > 0 then
				free[index] -= 1
				cursor[item.base] = index % #points + 1
				table.insert(result, { kind = item.kind, point = point.id })
				break
			end
		end
	end
	return result
end

-- Returns a new stock snapshot and allocation together; the caller commits both atomically.
function Supply.replenish(stock: { [string]: { string } }, lastDay: number, day: number, players: number, selected: { { id: string, base: boolean } })
	assert(type(lastDay) == "number" and lastDay % 1 == 0 and lastDay >= 1 and lastDay < math.huge, "invalid processed day")
	assert(type(day) == "number" and day % 1 == 0 and day >= 1 and day < math.huge, "invalid day")
	if day <= lastDay then return nil, {} end
	local nextStock = {}
	for id, items in pairs(stock) do
		assert(type(id) == "string" and type(items) == "table" and #items <= 10, "invalid stock")
		nextStock[id] = table.clone(items)
	end
	local points = {}
	for _, point in ipairs(selected) do
		assert(nextStock[point.id], "selected point has no stock record")
		table.insert(points, { id = point.id, base = point.base, stock = #nextStock[point.id] })
	end
	local allocations = Supply.points(day, players, points)
	for _, item in ipairs(allocations) do table.insert(nextStock[item.point], item.kind) end
	return { lastDay = day, stock = nextStock }, allocations
end

return table.freeze(Supply)
