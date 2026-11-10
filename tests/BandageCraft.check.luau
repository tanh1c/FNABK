local Inventory = require(game.ServerScriptService.FNABKServer.Inventory)
local slots = Inventory.new()
assert(not Inventory.craftBandage(slots, "bandage"))
assert(Inventory.add(slots, { id = "cloth", kind = "Cloth" }))
assert(Inventory.craftBandage(slots, "bandage"))
assert(Inventory.count(slots, "Cloth") == 0 and Inventory.count(slots, "Bandage") == 1)
local full = Inventory.new()
for _, kind in ipairs({ "Food", "Water", "Medkit", "Scrap", "Electronics", "Cloth", "PistolAmmo", "RifleAmmo" }) do
	for i = 1, 5 do
		local rounds = if kind == "PistolAmmo" then 20 elseif kind == "RifleAmmo" then 30 else nil
		assert(Inventory.add(full, { id = kind .. i, kind = kind, rounds = rounds }))
	end
end
assert(not Inventory.craftBandage(full, "new"))
assert(Inventory.count(full, "Cloth") == 5 and Inventory.count(full, "Bandage") == 0)
print("Bandage crafting inventory checks passed")
