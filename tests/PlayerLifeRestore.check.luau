-- Controlled Studio Play server check; uses a separate life service (SURV-08/10).
local module = require(game.ServerScriptService.FNABKServer.PlayerLifeService)
local config = require(game.ReplicatedStorage.FNABKShared.GameConfig)
local player = assert(game.Players:GetPlayers()[1])
local saved = { version = 1, players = { { userId = player.UserId, health = 43, respawns = 2, eliminated = false } } }
assert(not pcall(function() module.Start(config, function() end, nil, { version = 2, players = {} }) end))
local service = module.Start(config, function() end, nil, saved)
local deadline = os.clock() + 3
repeat task.wait(.05) until player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	and player.Character.Humanoid.Health == 43 or os.clock() >= deadline
assert(player:GetAttribute("FNABKRespawns") == 2 and player.Character.Humanoid.Health == 43)
local snapshot = assert(service.Snapshot())
assert(snapshot.players[1].health == 43 and snapshot.players[1].respawns == 2)
return "Player life restoration checks passed"
