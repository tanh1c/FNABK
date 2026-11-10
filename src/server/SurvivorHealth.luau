--!strict
-- Server-owned health for the current anchored survivor prototypes (SURV-13).
local SurvivorHealth = {}

function SurvivorHealth.Incapacitate(student: Model, remaining: number)
	assert(type(remaining) == "number" and remaining == remaining and remaining >= 0 and remaining <= 60, "invalid recovery time")
	local upright = student:GetPivot()
	local deadline = os.clock() + remaining
	student:SetAttribute("SurvivorHealth", 0)
	student:SetAttribute("SurvivorRecoveryAt", deadline)
	student:SetAttribute("StudentState", "Incapacitated")
	-- ponytail: anchored graybox models only; replace this pose with a rig animation.
	student:PivotTo(upright * CFrame.new(0, -1.5, 0) * CFrame.Angles(0, 0, math.rad(90)))
	task.delay(remaining, function()
		if student.Parent and student:GetAttribute("StudentState") == "Incapacitated" and student:GetAttribute("SurvivorRecoveryAt") == deadline then
			student:PivotTo(upright)
			student:SetAttribute("SurvivorRecoveryAt", nil)
			student:SetAttribute("SurvivorHealth", 50)
			student:SetAttribute("FleeingStarted", false)
			student:SetAttribute("StudentState", "Idle")
		end
	end)
end

function SurvivorHealth.Hit(student: Model, damage: number): boolean
	if student:GetAttribute("NPCType") ~= "Student" or damage ~= damage or damage <= 0 or damage == math.huge then
		return false
	end
	local health = student:GetAttribute("SurvivorHealth")
	if typeof(health) ~= "number" then health = 100 end
	if health <= 0 then return false end
	student:SetAttribute("SurvivorMaxHealth", 100)
	health = math.max(0, health - damage)
	student:SetAttribute("SurvivorHealth", health)
	if health == 0 then
		SurvivorHealth.Incapacitate(student, 60)
	else
		student:SetAttribute("StudentState", "Fleeing")
	end
	return true
end

return SurvivorHealth
