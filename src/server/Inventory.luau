--!strict
-- SURV-05/08: server-only inventory value object. World ownership and persistence are separate.
local Inventory = {}
local SLOT_LIMIT, STACK_LIMIT = 8, 5
local kinds = {
	Food = true, Water = true, Medkit = true, Bandage = true, Scrap = true, Electronics = true, Cloth = true,
	PistolAmmo = true, ShotgunAmmo = true, RifleAmmo = true,
}
local ammoCapacity = { PistolAmmo = 20, ShotgunAmmo = 10, RifleAmmo = 30 }

export type Item = { id: string, kind: string, rounds: number? }
export type Slots = { { Item } }

local function copy(item: Item): Item
	return { id = item.id, kind = item.kind, rounds = item.rounds }
end

function Inventory.new(): Slots
	return {}
end

function Inventory.add(slots: Slots, item: Item, slotLimit: number?): (boolean, string?)
	if type(item) ~= "table" or type(item.id) ~= "string" or #item.id == 0
		or type(item.kind) ~= "string" or not kinds[item.kind] then
		return false, "InvalidItem"
	end
	local capacity = ammoCapacity[item.kind]
	if capacity then
		if type(item.rounds) ~= "number" or item.rounds % 1 ~= 0 or item.rounds < 0 or item.rounds > capacity then
			return false, "InvalidRounds"
		end
	elseif item.rounds ~= nil then
		return false, "InvalidRounds"
	end
	local available = nil
	for _, stack in ipairs(slots) do
		for _, existing in ipairs(stack) do
			if existing.id == item.id then return false, "DuplicateItem" end
		end
		if not available and stack[1].kind == item.kind and #stack < STACK_LIMIT then available = stack end
	end
	if not available then
		if #slots >= (slotLimit or SLOT_LIMIT) then return false, "Full" end
		available = {}
		table.insert(slots, available)
	end
	table.insert(available, copy(item))
	return true
end

function Inventory.remove(slots: Slots, slot: number, index: number): Item?
	if type(slot) ~= "number" or slot % 1 ~= 0 or type(index) ~= "number" or index % 1 ~= 0 then return nil end
	local stack = slots[slot]
	if not stack or index < 1 or index > #stack then return nil end
	local item = table.remove(stack, index)
	if #stack == 0 then table.remove(slots, slot) end
	return item
end

function Inventory.count(slots: Slots, kind: string): number
	local total = 0
	for _, stack in ipairs(slots) do
		if stack[1].kind == kind then total += #stack end
	end
	return total
end

function Inventory.removeFirst(slots: Slots, kind: string): Item?
	for index, stack in ipairs(slots) do
		if stack[1].kind == kind then return Inventory.remove(slots, index, 1) end
	end
	return nil
end

function Inventory.transfer(source: Slots, destination: Slots, slot: number, index: number, destinationLimit: number?): boolean
	if source == destination or type(slot) ~= "number" or slot % 1 ~= 0
		or type(index) ~= "number" or index % 1 ~= 0 then return false end
	local stack = source[slot]
	local item = stack and stack[index]
	if not item then return false end
	-- No yield between insertion and removal: a rejected transfer leaves the source intact.
	local accepted = Inventory.add(destination, item, destinationLimit)
	if not accepted then return false end
	Inventory.remove(source, slot, index)
	return true
end

function Inventory.transferFirstFitting(source: Slots, destination: Slots): boolean
	for slot = 1, #source do
		if Inventory.transfer(source, destination, slot, 1) then return true end
	end
	return false
end

function Inventory.snapshot(slots: Slots): Slots
	local result: Slots = {}
	for _, stack in ipairs(slots) do
		local output: { Item } = {}
		for _, item in ipairs(stack) do table.insert(output, copy(item)) end
		table.insert(result, output)
	end
	return result
end

-- SURV-05: validate against a copy before consuming a crafting ingredient.
function Inventory.craftBandage(slots: Slots, id: string): boolean
	local preview = Inventory.snapshot(slots)
	if not Inventory.removeFirst(preview, "Cloth") or not Inventory.add(preview, { id = id, kind = "Bandage" }) then return false end
	Inventory.removeFirst(slots, "Cloth")
	assert(Inventory.add(slots, { id = id, kind = "Bandage" }))
	return true
end

function Inventory.summary(slots: Slots): { { kind: string, count: number, empty: number? } }
	local result = {}
	for _, stack in ipairs(slots) do
		local empty: number? = nil
		if ammoCapacity[stack[1].kind] then
			empty = 0
			for _, item in ipairs(stack) do if item.rounds == 0 then empty += 1 end end
		end
		table.insert(result, { kind = stack[1].kind, count = #stack, empty = empty })
	end
	return result
end

return table.freeze(Inventory)
