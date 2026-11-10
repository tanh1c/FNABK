-- Run in Studio against a temporary Student model; allow 60 seconds to finish.
local SurvivorHealth = require(game.ServerScriptService.FNABKServer.SurvivorHealth)
local student = Instance.new("Model")
student:SetAttribute("NPCType", "Student")
student.Parent = workspace
assert(not SurvivorHealth.Hit(student, 0))
for expected = 75, 0, -25 do
	assert(SurvivorHealth.Hit(student, 25))
	assert(student:GetAttribute("SurvivorHealth") == expected)
end
assert(student:GetAttribute("StudentState") == "Incapacitated")
assert(not SurvivorHealth.Hit(student, 25))
task.wait(61)
assert(student:GetAttribute("StudentState") == "Idle")
assert(student:GetAttribute("SurvivorHealth") == 50)
student:Destroy()
print("SurvivorHealth check passed")
