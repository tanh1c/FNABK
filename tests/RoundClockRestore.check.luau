-- Controlled Studio Play server check; separate temporary round (SURV-02/10/11).
local service = require(game.ServerScriptService.FNABKServer.RoundService)
local config = require(game.ReplicatedStorage.FNABKShared.GameConfig)
local map = Instance.new("Folder")
map.Name, map.Parent = "TestRoundClockRestore", workspace
workspace.FNABKGraybox.Gate1:Clone().Parent = map
local events = Instance.new("BindableEvent")
events.Parent = map
assert(not pcall(function() service.Start(map, config, events, { version = 9 }) end))
assert(map:GetAttribute("RoundServiceStarted") == nil)
local signal, _, capture = service.Start(map, config, events, { version = 1, phase = "Day", day = 3, remaining = 450, signaled = false })
assert(signal and capture)
local state = game.ReplicatedStorage.FNABKRoundState
assert(state.SurvivalDay.Value == 3 and state.SurvivalPhase.Value == "Day")
assert(state.RoundTimeRemaining.Value <= 450 and state.RoundTimeRemaining.Value > 445)
local saved = assert(capture())
assert(saved.day == 3 and saved.phase == "Day" and saved.remaining <= 450 and saved.remaining > 445)
map:Destroy()
return "Round clock restore checks passed"
