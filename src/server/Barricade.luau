--!strict
-- SURV-03/04: one entrance's server-owned defense state.
local Inventory = require(script.Parent:WaitForChild("Inventory"))
local Barricade = {}
export type State = { installed: boolean, health: number }

function Barricade.new(): State
	return { installed = false, health = 0 }
end

function Barricade.restore(data: any): State?
	if type(data) ~= "table" or type(data.installed) ~= "boolean" or type(data.health) ~= "number"
		or data.health ~= data.health or data.health < 0 or data.health > 100
		or (not data.installed and data.health ~= 0) then return nil end
	return { installed = data.installed, health = data.health }
end

function Barricade.install(state: State, items: Inventory.Slots): boolean
	if state.installed or Inventory.count(items, "Scrap") < 3 or Inventory.count(items, "Cloth") < 1 then return false end
	for _ = 1, 3 do Inventory.removeFirst(items, "Scrap") end
	Inventory.removeFirst(items, "Cloth")
	state.installed, state.health = true, 100
	return true
end

function Barricade.damage(state: State, amount: number): boolean
	if not state.installed or state.health <= 0 or type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount >= math.huge then return false end
	state.health = math.max(0, state.health - amount)
	return true
end

function Barricade.repair(state: State, items: Inventory.Slots): boolean
	if not state.installed or state.health >= 100 or Inventory.count(items, "Scrap") < 2 then return false end
	Inventory.removeFirst(items, "Scrap")
	Inventory.removeFirst(items, "Scrap")
	state.health = math.min(100, state.health + 50)
	return true
end

return table.freeze(Barricade)
