-- Run in a Studio Play server; SURV-09 selected recovery timing.
local config = require(game.ReplicatedStorage.FNABKShared.GameConfig)
assert(config.coOpDownedWindowSeconds == 30)
assert(config.reviveHoldSeconds == 5)
assert(config.reviveHealth == 40)
print("Revive settings check passed; multiplayer behavior still requires a playtest")
