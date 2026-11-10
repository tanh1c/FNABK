-- Run on attacker client in a two-player Studio Play test.
-- Equip baton, stand within 7 studs facing a living teammate with unobstructed sight.
local Players = game:GetService("Players")
local attacker = Players.LocalPlayer
local teammate
for _, player in ipairs(Players:GetPlayers()) do if player ~= attacker then teammate = player; break end end
assert(teammate and teammate.Character, "Two connected players are required")
assert(attacker.Character:FindFirstChild("Baton"), "Equip the baton")
local humanoid = teammate.Character:FindFirstChildOfClass("Humanoid")
assert(humanoid.Health > 5, "Teammate must be living above 5 HP")
local before = humanoid.Health
game.ReplicatedStorage.FNABKRemotes.AttackRequest:FireServer(teammate.Character)
task.wait(0.5)
assert(humanoid.Health == before - 5, "Expected exactly 5 friendly damage")
print("Baton friendly fire check passed")
