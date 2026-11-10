-- Studio Play server in a fresh solo session; uses a separate life service.
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local character = player.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")
assert(humanoid)
for _, child in ipairs(character:GetChildren()) do if child:IsA("ForceField") then child:Destroy() end end
player:SetAttribute("FNABKImmuneUntil", nil)
local life = require(game.ServerScriptService.FNABKServer.PlayerLifeService).Start(
	require(game.ReplicatedStorage.FNABKShared.GameConfig), function() end)
humanoid.Health = 100
for _, amount in ipairs({ 0/0, math.huge, -math.huge, 0, -5 }) do
	assert(life.ApplyDamage(player, amount) == nil)
	assert(humanoid.Health == 100 and player:GetAttribute("FNABKRespawns") == 3)
end
life.ApplyDamage(player, 5)
assert(humanoid.Health == 95)
return "Player damage validation passed"
