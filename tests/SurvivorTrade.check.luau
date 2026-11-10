-- Studio server: trust tiers and stock accounting (SURV-13).
local trade = require(game.ServerScriptService.FNABKServer.SurvivorTrade)
assert(trade.available(100, 4, 0) == 4)
assert(trade.available(69, 4, 0) == 2)
assert(trade.available(30, 4, 1) == 1)
assert(trade.available(30, 2, 0) == 1) -- entering wary with two items left
assert(trade.available(30, 2, 1) == 0) -- do not repeatedly halve the stock
assert(trade.available(30, 1, 0) == 1)
assert(trade.available(29, 1, 0) == 0)
assert(trade.available(29, 4, 0) == 0)
assert(trade.available(30, 1, 0) == 1)
assert(trade.available(100, 4, 2) == 2)
assert(trade.available(100, 0, 0) == 0)
print("Survivor trade checks passed")
