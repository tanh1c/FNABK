-- Studio server: state remains isolated by user ID for the current server session.
local session = require(game.ServerScriptService.FNABKServer.SessionLife).new()
assert(session.get(123) == nil)
session.save(123, 1, 38, false)
session.save(456, 0, 1, true)
assert(session.get(123).respawns == 1 and session.get(123).health == 38 and not session.get(123).eliminated)
assert(session.get(456).eliminated and session.get(456).respawns == 0)
assert(not pcall(function() session.save(123, 4, 100, false) end))
local json = game:GetService("HttpService")
local data = json:JSONDecode(json:JSONEncode(session.snapshot()))
local restored = assert(require(game.ServerScriptService.FNABKServer.SessionLife).restore(data))
assert(restored.get(123).health == 38 and restored.get(456).eliminated)
local copy = restored.get(123); copy.health = 100
assert(restored.get(123).health == 38)
data.players[2].userId = data.players[1].userId
assert(require(game.ServerScriptService.FNABKServer.SessionLife).restore(data) == nil)
data.players[2].userId = 456; data.players[1].health = 0/0
assert(require(game.ServerScriptService.FNABKServer.SessionLife).restore(data) == nil)
data.players[1].health = 38; data.players[1].eliminated = "false"
assert(require(game.ServerScriptService.FNABKServer.SessionLife).restore(data) == nil)
data.players[1].eliminated = false; data.players[1].health = 0
assert(require(game.ServerScriptService.FNABKServer.SessionLife).restore(data) == nil)
print("Session life checks passed")
