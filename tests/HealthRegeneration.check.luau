-- Studio server command bar during Play; wait at least six seconds for regeneration.
local player = game.Players:GetPlayers()[1]
local character = player.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")
assert(humanoid.Health > 50, "Use a living test character")
humanoid.Health = 50
task.wait(6)
assert(humanoid.Health == 50, "Unexpected automatic health regeneration")
print("Health regeneration check passed")
