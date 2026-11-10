-- Studio Play server only: swing the equipped Baton when prompted below.
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local character = player.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")
assert(humanoid and character:FindFirstChild("HumanoidRootPart"))
for _, child in ipairs(character:GetChildren()) do
	if child:IsA("ForceField") then child:Destroy() end
end
local life = require(game.ServerScriptService.FNABKServer.PlayerLifeService).Start(
	require(game.ReplicatedStorage.FNABKShared.GameConfig), function() end)
humanoid.Health = 5
life.ApplyDamage(player, 10)
assert(player:GetAttribute("FNABKRespawns") == 2 and humanoid.Health == 100)
life.ApplyDamage(player, 10)
assert(humanoid.Health == 100)
local baton = player.Backpack:FindFirstChild("Baton")
assert(baton and baton:IsA("Tool"))
humanoid:EquipTool(baton)
print("Swing the baton now")
local deadline = os.clock() + 4
while player:GetAttribute("FNABKImmuneUntil") and os.clock() < deadline do task.wait(.05) end
assert(player:GetAttribute("FNABKImmuneUntil") == nil, "No accepted attack before timeout")
life.ApplyDamage(player, 10)
assert(humanoid.Health == 90)
return "Respawn immunity and attack interruption passed"
