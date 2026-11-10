-- Studio server command bar after Rojo sync; SURV-05.
local Supply = require(game.ServerScriptService.FNABKServer.DailySupply)
local full = Supply.plan(2, 4, 100, 100)
assert(#full == 28)
local counts = {}
local base = 0
for _, item in ipairs(full) do counts[item.kind] = (counts[item.kind] or 0) + 1; if item.base then base += 1 end end
assert(counts.Water == 10 and counts.Food == 8 and counts.PistolAmmo == 5 and counts.ShotgunAmmo == 3 and counts.RifleAmmo == 2)
assert(base <= math.floor(#full / 4))
local limited = Supply.plan(2, 1, 8, 4)
assert(#limited == 10 and limited[1].kind == "Water" and limited[4].kind == "Water" and limited[5].kind == "Food")
assert(limited[8].kind == "PistolAmmo" and limited[9].kind == "ShotgunAmmo" and limited[10].kind == "RifleAmmo")
local rotated = Supply.plan(3, 1, 8, 4)
assert(rotated[8].kind == "ShotgunAmmo" and rotated[9].kind == "RifleAmmo" and rotated[10].kind == "PistolAmmo")
assert(#Supply.plan(1, 1, 20, 0) == 0)
assert(#Supply.plan(2, 1, 0, 100) == 0)
for players = 1, 4 do
	for outside = 0, 20 do
		for baseSpace = 0, 10 do
			local items = Supply.plan(4, players, outside, baseSpace)
			local inside, exterior = 0, 0
			for _, item in ipairs(items) do if item.base then inside += 1 else exterior += 1 end end
			assert(inside <= baseSpace and exterior <= outside and inside <= math.floor(#items / 4))
		end
	end
end
assert(not pcall(function() Supply.plan(2, 5, 10, 10) end))
local points = {
	{ id = "A", stock = 8, base = false },
	{ id = "B", stock = 4, base = false },
	{ id = "C", stock = 8, base = true },
}
local distribution = Supply.points(2, 1, points)
local additions = { A = 0, B = 0, C = 0 }
for _, item in ipairs(distribution) do additions[item.point] += 1 end
assert(#distribution == 10 and additions.A <= 2 and additions.B <= 6 and additions.C <= 2)
assert(additions.C <= math.floor(#distribution / 4) and points[1].stock == 8)
assert(not pcall(function() Supply.points(2, 1, { { id = "x", stock = 11, base = false } }) end))
assert(not pcall(function() Supply.points(2, 1, { { id = "x", stock = 1, base = false }, { id = "x", stock = 0, base = false } }) end))
local stock = { A = { "old" }, B = {} }
local selected = { { id = "A", base = false }, { id = "B", base = true } }
local updated, allocations = Supply.replenish(stock, 1, 2, 1, selected)
assert(updated and updated.lastDay == 2 and #allocations == 11)
assert(updated.stock.A[1] == "old" and stock.A[1] == "old" and #stock.A == 1)
assert(not Supply.replenish(updated.stock, updated.lastDay, 2, 4, selected))
assert(not Supply.replenish(updated.stock, updated.lastDay, 1, 4, selected))
local fullStock = { A = table.create(10, "full") }
local discarded, none = Supply.replenish(fullStock, 2, 3, 1, { { id = "A", base = false } })
assert(discarded and discarded.lastDay == 3 and #none == 0 and #discarded.stock.A == 10)
print("Daily supply checks passed")
