--!strict
-- SURV-05/10: validate all saved containers together before accepting any item.
local Inventory = require(script.Parent.Inventory)
local Snapshot = {}

local function denseArray(value: any, maximum: number): boolean
	if type(value) ~= "table" then return false end
	local count = 0
	for key in pairs(value) do
		if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > maximum then return false end
		count += 1
	end
	for i = 1, count do if value[i] == nil then return false end end
	return true
end

-- Limits are supplied by the trusted caller, not by the saved record.
function Snapshot.restore(containers: any, limits: { number }): { Inventory.Slots }?
	if not denseArray(limits, 256) or not denseArray(containers, #limits) or #containers ~= #limits then return nil end
	local seen: { [string]: boolean } = {}
	local result: { Inventory.Slots } = {}
	for i, limit in ipairs(limits) do
		if type(limit) ~= "number" or limit % 1 ~= 0 or limit < 1 or limit > 16 then return nil end
		local source = containers[i]
		if not denseArray(source, limit) then return nil end
		local slots: Inventory.Slots = {}
		for _, stack in ipairs(source) do
			if not denseArray(stack, 5) or #stack == 0 then return nil end
			local checked: Inventory.Slots = {}
			for _, item in ipairs(stack) do
				if type(item) ~= "table" or type(item.id) ~= "string" or #item.id > 128 or seen[item.id] then return nil end
				local ok = Inventory.add(checked, item, 1)
				if not ok then return nil end
				seen[item.id] = true
			end
			table.insert(slots, checked[1])
		end
		table.insert(result, slots)
	end
	return result
end

return table.freeze(Snapshot)
