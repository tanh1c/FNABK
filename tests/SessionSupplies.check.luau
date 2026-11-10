-- Run in Studio server command bar after syncing source with Rojo.
local Sessions = require(game.ServerScriptService.FNABKServer.SessionSupplies)
local Inventory = require(game.ServerScriptService.FNABKServer.Inventory)
local sessions = Sessions.new()
assert(sessions:claimShared(101) == 1 and sessions:claimShared(101) == nil)
assert(sessions:claimShared(102) == 2 and sessions:claimShared(103) == 3 and sessions:claimShared(104) == 4)
assert(sessions:claimShared(105) == nil and sessions:claimShared(102) == nil)
local first = sessions:get(101)
assert(Inventory.count(first.items, "Food") == 1 and Inventory.count(first.items, "Water") == 1 and Inventory.count(first.items, "Medkit") == 1)
assert(Inventory.add(first.items, { id = "box", kind = "PistolAmmo", rounds = 8 }))
first.needs.food = 30
local resumed = sessions:get(101)
assert(resumed == first and resumed.needs.food == 30 and resumed.items[4][1].rounds == 8)
Inventory.removeFirst(first.items, "Food")
assert(Inventory.count(sessions:get(101).items, "Food") == 0)
local other = sessions:get(102)
assert(other ~= first and #other.items == 3 and other.needs.food == 100)
assert(not pcall(function() sessions:get(0) end))
local data = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):JSONEncode(sessions:snapshot()))
local restored = assert(Sessions.restore(data))
assert(restored:get(101).needs.food == 30 and restored:get(101).items[3][1].rounds == 8)
assert(Inventory.count(restored:get(101).items, "Food") == 0 and restored:claimShared(101) == nil and restored:claimShared(105) == nil)
restored:get(101).needs.food = 1
assert(data.players[1].needs.food == 30)
local bad = sessions:snapshot()
bad.players[2].items = bad.players[1].items
assert(Sessions.restore(bad) == nil) -- duplicate item IDs across players
bad = sessions:snapshot(); bad.players[1].needs.food = 101
assert(Sessions.restore(bad) == nil)
bad = sessions:snapshot(); bad.claims[2] = bad.claims[1]
assert(Sessions.restore(bad) == nil)
bad = sessions:snapshot(); bad.players[1].items = nil
assert(Sessions.restore(bad) == nil)
local storage = { { { id = "storage", kind = "Water" } } }
local together, loadedStorage = Sessions.restore(sessions:snapshot(), { storage }, { 16 })
assert(together and loadedStorage[1][1][1].id == "storage")
loadedStorage[1][1][1].id = "changed"
assert(storage[1][1].id == "storage")
storage[1][1].id = sessions:get(101).items[1][1].id
assert(Sessions.restore(sessions:snapshot(), { storage }, { 16 }) == nil)
assert(Sessions.restore(sessions:snapshot(), { storage }) == nil)
assert(Sessions.restore(sessions:snapshot(), { storage }, { 1, 8 }) == nil)
local world = { players = sessions:snapshot(), bags = {}, carried = {}, weaponPickups = {}, supplies = {}, processedDay = 1, buildings = {
	{ name = "B1", upgraded = true, items = { { { id = "b1", kind = "PistolAmmo", rounds = 3 } } } },
	{ name = "B4", upgraded = false, items = {} },
} }
local worldPlayers, buildings = Sessions.restoreBuildings(world, { B1 = true, B4 = true })
assert(worldPlayers and buildings.B1.upgraded and buildings.B1.items[1][1].rounds == 3 and not buildings.B4.upgraded)
world.buildings[1].items[1][1].id = world.players.players[1].items[1][1].id
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.buildings[1].items[1][1].id = "b1"
assert(Sessions.restoreBuildings(world, { B1 = true }) == nil)
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true, A3 = true }) == nil)
world.buildings[1].name = "B4"
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.buildings[1].name = "B1"
world.bags = { { owner = 101, position = { 1, 2, 3 }, items = { { { id = "bag", kind = "Water" } } }, weapons = {
	Pistol = { id = "gun1", kind = "Pistol", loaded = 7, cooldown = 0.2 },
} } }
local _, _, bags = Sessions.restoreBuildings(world, { B1 = true, B4 = true })
assert(bags and bags[1].items[1][1].id == "bag" and bags[1].weapons.Pistol.loaded == 7 and bags[1].weapons.Pistol.cooldown == 0.2)
bags[1].weapons.Pistol.loaded = 1
assert(world.bags[1].weapons.Pistol.loaded == 7)
world.bags[1].items[1][1].id = "b1"
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.bags[1].items[1][1].id = "bag"
world.bags[1].position[1] = math.huge
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.bags[1].position[1] = 1
world.bags[1].weapons.Pistol.loaded = 13
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.bags[1].weapons.Pistol.loaded = 7
world.carried = { { owner = 101, weapons = { Rifle = { id = "gun2", kind = "Rifle", loaded = 19, cooldown = 0.1 } } } }
local _, _, _, carried = Sessions.restoreBuildings(world, { B1 = true, B4 = true })
assert(carried and carried[101].Rifle.loaded == 19 and carried[101].Rifle.cooldown == 0.1)
carried[101].Rifle.loaded = 0
assert(world.carried[1].weapons.Rifle.loaded == 19)
world.carried[1].weapons.Rifle.id = "gun1"
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.carried[1].weapons.Rifle.id = "b1"
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.carried[1].weapons.Rifle.id = "gun2"
world.weaponPickups = { { id = "gun3", kind = "Shotgun", loaded = 0, cooldown = 0, position = { 1, 2, 3 } } }
local _, _, _, _, pickups = Sessions.restoreBuildings(world, { B1 = true, B4 = true })
assert(pickups and pickups[1].id == "gun3")
world.weaponPickups[1].id = "gun2"
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.weaponPickups[1].id = "gun3"
world.supplies = { { item = { id = "ground", kind = "PistolAmmo", rounds = 8 }, position = { 0, 4, 1 }, point = "B1", slot = 1, unmarked = true } }
local _, _, _, _, _, ground = Sessions.restoreBuildings(world, { B1 = true, B4 = true })
assert(ground and ground[1].item.rounds == 8)
world.supplies[1].item.id = "gun3"
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.supplies[1].item.id = "ground"
table.insert(world.supplies, { item = { id = "ground2", kind = "Water" }, position = { 0, 4, 1 }, point = "B1", slot = 1, unmarked = true })
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
table.remove(world.supplies, 2)
table.insert(world.supplies, { item = { id = "apple", kind = "Food" }, position = { 1, 4, 2 }, visual = "FoodApple", unmarked = false })
local _, _, _, _, _, visuals = Sessions.restoreBuildings(world, { B1 = true, B4 = true })
assert(visuals and visuals[2].visual == "FoodApple")
table.insert(world.supplies, { item = { id = "apple2", kind = "Food" }, position = { 1, 4, 2 }, visual = "FoodApple", unmarked = false })
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
table.remove(world.supplies, 3)
world.supplies[2].item.kind = "Water"
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
world.supplies[2].item.kind = "Food"
table.insert(world.carried, world.carried[1])
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
table.remove(world.carried, 2)
world.carried[1].owner = 999
assert(Sessions.restoreBuildings(world, { B1 = true, B4 = true }) == nil)
print("Session supplies checks passed")
