-- Studio Play server: isolated fallback-location rules.
local location = require(game.ServerScriptService.FNABKServer.BagLocation)
local spawn = Vector3.new(10, 20, 30)
local normal = Vector3.new(1, 5, 2)
assert(location.resolve(normal, -500, spawn) == normal)
assert(location.resolve(Vector3.new(0, -490, 0), -500, spawn) == spawn)
assert(location.resolve(Vector3.new(0, -501, 0), -500, nil) == nil)
assert(location.resolve(Vector3.new(0, -501, 0), -500, Vector3.new(0, -500, 0)) == nil)
assert(location.resolve(Vector3.new(0, -501, 0), -500, Vector3.new(0, -500, 0), spawn) == spawn)
assert(location.resolve(Vector3.new(0, -501, 0), -500, Vector3.new(0, -500, 0), Vector3.new(0, -490, 0)) == nil)
return "Recovery bag fallback checks passed"
