-- Run on the Studio server; SURV-05/10.
local Snapshot = require(game.ServerScriptService.FNABKServer.InventorySnapshot)
local http = game:GetService("HttpService")
local input = {
	{ { { id = "a", kind = "PistolAmmo", rounds = 8 }, { id = "b", kind = "PistolAmmo", rounds = 20 } }, { { id = "c", kind = "Food" } } },
	{ { { id = "d", kind = "Water" } } },
}
local loaded = assert(Snapshot.restore(http:JSONDecode(http:JSONEncode(input)), { 8, 16 }))
assert(loaded[1][1][1].rounds == 8 and loaded[1][1][2].id == "b" and loaded[2][1][1].id == "d")
loaded[1][1][1].rounds = 1
assert(input[1][1][1].rounds == 8)
assert(Snapshot.restore({ input[1], input[1] }, { 8, 8 }) == nil) -- duplicate across containers
assert(Snapshot.restore({ { { { id = "x", kind = "Food" }, { id = "y", kind = "Water" } } } }, { 8 }) == nil)
assert(Snapshot.restore({ { { { id = "x", kind = "PistolAmmo", rounds = 21 } } } }, { 8 }) == nil)
assert(Snapshot.restore({ { {} } }, { 8 }) == nil)
assert(Snapshot.restore({ { [2] = { { id = "x", kind = "Food" } } } }, { 8 }) == nil)
assert(Snapshot.restore(input, { 1, 16 }) == nil)
assert(Snapshot.restore(input, { 8 }) == nil)
print("Inventory snapshot checks passed")
