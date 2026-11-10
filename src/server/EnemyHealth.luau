--!strict
-- SURV-07/08: shared server-owned enemy damage.
local EnemyHealth = {}
function EnemyHealth.damage(target: Model, damage: number): number?
	local kind = target:GetAttribute("NPCType")
	if kind ~= "Mimic" and kind ~= "Creature" and kind ~= "Machine" then return nil end
	if damage ~= damage or damage <= 0 or damage >= math.huge or target:GetAttribute("EnemyState") == "Defeated" or target:GetAttribute("MimicState") == "Defeated" then return nil end
	local healthKey = if kind == "Mimic" then "MimicHealth" else "EnemyHealth"
	local stateKey = if kind == "Mimic" then "MimicState" else "EnemyState"
	local health = target:GetAttribute(healthKey)
	if typeof(health) ~= "number" or health <= 0 then return nil end
	health = math.max(0, health - damage)
	target:SetAttribute(healthKey, health)
	if health == 0 then target:SetAttribute(stateKey, "Defeated") end
	return health
end
return table.freeze(EnemyHealth)
