-- Run on the Studio Play server; no authored objects are modified.
local health = require(game.ServerScriptService.FNABKServer.EnemyHealth)
for _, kind in ipairs({"Mimic", "Creature", "Machine"}) do
	local enemy = Instance.new("Model")
	enemy:SetAttribute("NPCType", kind)
	local hp = if kind == "Mimic" then "MimicHealth" else "EnemyHealth"
	local state = if kind == "Mimic" then "MimicState" else "EnemyState"
	enemy:SetAttribute(hp, 60)
	assert(health.damage(enemy, 0) == nil and health.damage(enemy, 0/0) == nil)
	assert(health.damage(enemy, 25) == 35 and enemy:GetAttribute(hp) == 35)
	assert(health.damage(enemy, 50) == 0 and enemy:GetAttribute(state) == "Defeated")
	assert(health.damage(enemy, 1) == nil)
	enemy:Destroy()
end
local student = Instance.new("Model")
student:SetAttribute("NPCType", "Student")
student:SetAttribute("EnemyHealth", 100)
assert(health.damage(student, 20) == nil and student:GetAttribute("EnemyHealth") == 100)
student:Destroy()
print("Enemy health check passed")
