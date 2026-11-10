-- Studio Play server: moves the sole player, then checks the ten-second disengage.
local player = game.Players:GetPlayers()[1]
local student = workspace.FNABKGraybox.Student
assert(player and player.Character and student.PrimaryPart)
local original = player.Character:GetPivot()
player.Character:PivotTo(student:GetPivot() * CFrame.new(0, 0, 30))
require(game.ServerScriptService.FNABKServer.SurvivorDefense).attacked(student, player, function() return nil end)
assert(student:GetAttribute("StudentState") == "Defending")
task.wait(10.5)
assert(student:GetAttribute("StudentState") == "Idle")
player.Character:PivotTo(original)
print("Survivor defense disengage check passed")
