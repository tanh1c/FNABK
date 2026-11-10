--!strict
-- SURV-13: temporary stationary self-defense against a directly attacking player.
local Workspace = game:GetService("Workspace")
local Defense = {}
local records: { [Model]: { target: Player, lastHit: number } } = {}

function Defense.attacked(student: Model, attacker: Player, applyDamage: (Player, number) -> number?)
	if student:GetAttribute("StudentState") == "Incapacitated" or not student.PrimaryPart then return end
	local record = records[student]
	if record then record.target, record.lastHit = attacker, os.clock(); student:SetAttribute("StudentState", "Defending"); return end
	record = { target = attacker, lastHit = os.clock() }
	records[student] = record
	student:SetAttribute("StudentState", "Defending")
	task.spawn(function()
		local farSince: number? = nil
		local nextAttack = 0
		while student.Parent and student.PrimaryPart and student:GetAttribute("StudentState") == "Defending" do
			local target = record.target
			local character = target.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not target.Parent or not character or not root or not root:IsA("BasePart") then break end
			local distance = (root.Position - student.PrimaryPart.Position).Magnitude
			if distance > 20 then
				farSince = math.max(farSince or os.clock(), record.lastHit)
				if os.clock() - farSince >= 10 then break end
			else farSince = nil end
			if distance <= 5 and os.clock() >= nextAttack then
				local params = RaycastParams.new()
				params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { student }
				local hit = Workspace:Raycast(student.PrimaryPart.Position, root.Position - student.PrimaryPart.Position, params)
				if hit and hit.Instance:IsDescendantOf(character) then applyDamage(target, 5); nextAttack = os.clock() + 2 end
			end
			task.wait(.1)
		end
		if records[student] == record then records[student] = nil end
		if student.Parent and student:GetAttribute("StudentState") == "Defending" then student:SetAttribute("StudentState", "Idle") end
	end)
end
return table.freeze(Defense)
