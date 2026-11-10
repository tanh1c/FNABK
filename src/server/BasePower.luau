--!strict
-- SURV-03/04: one building upgrade; caller owns validation and replication.
local Inventory = require(script.Parent:WaitForChild("Inventory"))
local Power = {}
-- Only building power is represented; a coordinator must validate the rest of the world first.
function Power.snapshot(states: Folder): { [string]: boolean }?
	local result = {}
	for _, value in ipairs(states:GetChildren()) do
		if not value:IsA("BoolValue") or result[value.Name] ~= nil then return nil end
		result[value.Name] = value.Value
	end
	return result
end

function Power.applySnapshot(states: Folder, saved: any): boolean
	if type(saved) ~= "table" then return false end
	local current = Power.snapshot(states)
	if not current then return false end
	for name in pairs(current) do if type(saved[name]) ~= "boolean" then return false end end
	for name in pairs(saved) do if type(name) ~= "string" or current[name] == nil then return false end end
	for _, value in ipairs(states:GetChildren()) do (value :: BoolValue).Value = saved[value.Name] end
	return true
end

function Power.bindLights(building: Instance, state: BoolValue)
	local lights: { Light } = {}
	for _, instance in ipairs(building:GetDescendants()) do
		if instance:IsA("Light") and instance.Enabled then
			table.insert(lights, instance)
			instance.Enabled = state.Value
		end
	end
	state.Changed:Connect(function()
		for _, light in ipairs(lights) do if light.Parent then light.Enabled = state.Value end end
	end)
end
function Power.restore(state: BoolValue, items: Inventory.Slots): boolean
	if state.Value or Inventory.count(items, "Electronics") < 2 or Inventory.count(items, "Scrap") < 2 then return false end
	for _ = 1, 2 do Inventory.removeFirst(items, "Electronics"); Inventory.removeFirst(items, "Scrap") end
	state.Value = true
	return true
end
return table.freeze(Power)
