-- Studio Play server in a fresh session; ends this test round. SURV-08/09.
local player = game.Players:GetPlayers()[1]
local status = game.ReplicatedStorage.FNABKRoundState.RoundStatus
assert(player and player.Character and status.Value == "Running")
player:SetAttribute("FNABKRespawns", 1)
player:SetAttribute("FNABKDowned", true)
task.wait(.2)
assert(status.Value == "Running", "downed player with a respawn should keep the run alive")
-- Automatic respawn consumes the last life and clears downed in the same server task.
player:SetAttribute("FNABKRespawns", 0)
player:SetAttribute("FNABKDowned", false)
task.wait(.2)
assert(status.Value == "Running", "last respawn incorrectly ended the round")
player:SetAttribute("FNABKRespawns", 1)
player:SetAttribute("FNABKDowned", true)
task.wait(.2)
player:SetAttribute("FNABKRespawns", 0)
task.wait(.2)
assert(status.Value == "Lost", "all downed without respawns should lose")
return "Downed respawn boundary passed"
