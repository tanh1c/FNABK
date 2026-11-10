-- Run in Studio server command bar after syncing with Rojo.
local Needs = require(game.ServerScriptService.FNABKServer.Needs)
local state = Needs.new()
local damage = Needs.advance(state, 3600)
assert(math.abs(state.food - 40) < 0.001 and math.abs(state.water - 10) < 0.001 and damage == 0)
state.food, state.water = 0, 0
assert(Needs.advance(state, 4) == 0)
assert(Needs.advance(state, 1) == 1)
assert(Needs.advance(state, 10) == 2)
assert(Needs.consume(state, "Food") and state.food == 35)
assert(Needs.advance(state, 5) == 1, "water at zero must still cause damage")
assert(Needs.consume(state, "Water") and state.water == 40)
assert(Needs.advance(state, 5) == 0, "damage must stop when both needs are positive")
state.food, state.water, state.deprived = 0, 0, 0
assert(Needs.consume(state, "Water") and state.water == 40)
assert(Needs.advance(state, 5) == 1, "food at zero must still cause damage")
assert(Needs.consume(state, "Food") and state.food == 35)
assert(Needs.advance(state, 5) == 0, "damage must stop after the other need is restored")
state.food, state.water = 99, 99
assert(Needs.consume(state, "Food") and state.food == 100)
assert(Needs.consume(state, "Water") and state.water == 100)
assert(not Needs.consume(state, "Food"))
local boundary = Needs.new()
boundary.food, boundary.water = 0.05, 100
assert(Needs.advance(boundary, 7) == 0 and Needs.advance(boundary, 1) == 1)
print("Needs checks passed")
