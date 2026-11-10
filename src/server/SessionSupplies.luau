--!strict
-- SURV-10: retain supplies for reconnects while this server session exists.
local Inventory = require(script.Parent:WaitForChild("Inventory"))
local Needs = require(script.Parent:WaitForChild("Needs"))
local InventorySnapshot = require(script.Parent:WaitForChild("InventorySnapshot"))
local Firearm = require(script.Parent:WaitForChild("Firearm"))
local HttpService = game:GetService("HttpService")

local Sessions = {}
local function create(players, sharedClaims, participants)
	return {
		snapshot = function(_)
			local records, claims = {}, {}
			for userId, state in pairs(players) do
				table.insert(records, { userId = userId, items = Inventory.snapshot(state.items),
					needs = { food = state.needs.food, water = state.needs.water, deprived = state.needs.deprived } })
			end
			for userId in pairs(sharedClaims) do table.insert(claims, userId) end
			table.sort(records, function(a, b) return a.userId < b.userId end)
			table.sort(claims)
			return { version = 1, players = records, claims = claims }
		end,
		claimShared = function(_, userId: number): number?
			assert(type(userId) == "number" and userId ~= 0 and userId % 1 == 0 and math.abs(userId) < math.huge, "invalid user ID")
			if sharedClaims[userId] or participants >= 4 then return nil end
			sharedClaims[userId] = true
			participants += 1
			return participants
		end,
		get = function(_, userId: number)
			assert(type(userId) == "number" and userId ~= 0 and userId % 1 == 0 and math.abs(userId) < math.huge, "invalid user ID")
			if not players[userId] then
				local items = Inventory.new()
				for _, kind in ipairs({ "Food", "Water", "Medkit" }) do
					assert(Inventory.add(items, { id = HttpService:GenerateGUID(false), kind = kind }))
				end
				players[userId] = { items = items, needs = Needs.new() }
			end
			return players[userId]
		end,
	}
end

function Sessions.new()
	return create({}, {}, 0)
end

local function validId(id: any): boolean
	return type(id) == "number" and id ~= 0 and id % 1 == 0 and math.abs(id) < math.huge
end

local function dense(value: any, maximum: number): boolean
	if type(value) ~= "table" then return false end
	local count = 0
	for key in pairs(value) do
		if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > maximum then return false end
		count += 1
	end
	for i = 1, count do if value[i] == nil then return false end end
	return true
end

-- ponytail: caller supplies every non-player container; add weapons and world pickup ownership to the complete save.
function Sessions.restore(data: any, otherContainers: any?, otherLimits: any?)
	if type(data) ~= "table" or data.version ~= 1 or not dense(data.players, 256) or not dense(data.claims, 4) then return nil end
	if (otherContainers == nil) ~= (otherLimits == nil) then return nil end
	if otherContainers ~= nil and (not dense(otherLimits, 256) or not dense(otherContainers, 256)
		or #otherContainers ~= #otherLimits or #data.players + #otherContainers > 256) then return nil end
	local players, claims, containers, limits = {}, {}, {}, {}
	for _, entry in ipairs(data.players) do
		if type(entry) ~= "table" or not validId(entry.userId) or players[entry.userId]
			or type(entry.needs) ~= "table" or type(entry.items) ~= "table" then return nil end
		local n = entry.needs
		for _, field in ipairs({ "food", "water", "deprived" }) do
			local v = n[field]
			if type(v) ~= "number" or v ~= v or v < 0 or v >= math.huge
				or (field == "deprived" and v >= 5) or (field ~= "deprived" and v > 100) then return nil end
		end
		if n.food > 0 and n.water > 0 and n.deprived ~= 0 then return nil end
		players[entry.userId] = { needs = { food = n.food, water = n.water, deprived = n.deprived } }
		table.insert(containers, entry.items); table.insert(limits, 8)
	end
	for i, container in ipairs(otherContainers or {}) do
		table.insert(containers, container); table.insert(limits, otherLimits[i])
	end
	local restored = InventorySnapshot.restore(containers, limits)
	if not restored then return nil end
	for i, entry in ipairs(data.players) do players[entry.userId].items = restored[i] end
	for _, id in ipairs(data.claims) do
		if not validId(id) or claims[id] then return nil end
		claims[id] = true
	end
	local other = {}
	for i = #data.players + 1, #restored do table.insert(other, restored[i]) end
	return create(players, claims, #data.claims), other
end

-- Partial state only: world pickups require a complete coordinator.
function Sessions.restoreBuildings(data: any, expected: { [string]: boolean })
	if type(data) ~= "table" or type(expected) ~= "table" or not dense(data.buildings, 256)
		or not dense(data.bags, 128) or not dense(data.carried, 256) or not dense(data.weaponPickups, 128)
		or not dense(data.supplies, 1024) or type(data.processedDay) ~= "number" or data.processedDay % 1 ~= 0
		or data.processedDay < 1 or data.processedDay > 5 then return nil end
	local seen, containers, limits = {}, {}, {}
	for _, building in ipairs(data.buildings) do
		if type(building) ~= "table" or type(building.name) ~= "string" or expected[building.name] ~= true
			or seen[building.name] or type(building.upgraded) ~= "boolean" or type(building.items) ~= "table" then return nil end
		seen[building.name] = true
		table.insert(containers, building.items)
		table.insert(limits, if building.upgraded then 16 else 8)
	end
	for name, included in pairs(expected) do
		if type(name) ~= "string" or included ~= true or not seen[name] then return nil end
	end
	for _, bag in ipairs(data.bags) do
		if type(bag) ~= "table" or not validId(bag.owner) or not dense(bag.position, 3) or #bag.position ~= 3
			or type(bag.items) ~= "table" or type(bag.weapons) ~= "table" then return nil end
		for _, value in ipairs(bag.position) do
			if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return nil end
		end
		table.insert(containers, bag.items); table.insert(limits, 8)
	end
	local session, checked = Sessions.restore(data.players, containers, limits)
	if not session then return nil end
	local ids = {}
	for _, player in ipairs(data.players.players) do
		for _, stack in ipairs(player.items) do for _, item in ipairs(stack) do ids[item.id] = true end end
	end
	for _, container in ipairs(containers) do
		for _, stack in ipairs(container) do for _, item in ipairs(stack) do ids[item.id] = true end end
	end
	local supplies, pointSlots, visuals = {}, {}, {}
	local visualKinds = { MedicalKit = "Medkit", FoodApple = "Food", CannedFood = "Food", WaterBottle = "Water", CanteenWater = "Water" }
	for _, entry in ipairs(data.supplies) do
		if type(entry) ~= "table" or type(entry.item) ~= "table" or type(entry.item.id) ~= "string"
			or ids[entry.item.id] or #entry.item.id > 128 or type(entry.unmarked) ~= "boolean"
			or not dense(entry.position, 3) or #entry.position ~= 3 then return nil end
		for _, value in ipairs(entry.position) do
			if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return nil end
		end
		local slots = Inventory.new()
		if not Inventory.add(slots, entry.item) then return nil end
		if entry.visual ~= nil then
			if type(entry.visual) ~= "string" or visualKinds[entry.visual] ~= entry.item.kind or visuals[entry.visual]
				or entry.point ~= nil or entry.unmarked then return nil end
			visuals[entry.visual] = true
		end
		if entry.point ~= nil then
			if type(entry.point) ~= "string" or expected[entry.point] ~= true or type(entry.slot) ~= "number"
				or entry.slot % 1 ~= 0 or entry.slot < 0 or entry.slot > 9 or not entry.unmarked then return nil end
			local key = entry.point .. ":" .. entry.slot
			if pointSlots[key] then return nil end
			pointSlots[key] = true
		elseif entry.slot ~= nil then return nil end
		ids[entry.item.id] = true
		table.insert(supplies, { item = slots[1][1], position = table.clone(entry.position), point = entry.point,
			slot = entry.slot, unmarked = entry.unmarked, visual = entry.visual })
	end
	local function validWeapon(kind, weapon)
		if type(kind) ~= "string" or type(weapon) ~= "table" or kind ~= weapon.kind or type(weapon.id) ~= "string"
			or #weapon.id == 0 or #weapon.id > 128 or ids[weapon.id] or not Firearm.restore(weapon, 0) then return false end
		ids[weapon.id] = true
		return true
	end
	for _, bag in ipairs(data.bags) do
		for kind, weapon in pairs(bag.weapons) do if not validWeapon(kind, weapon) then return nil end end
	end
	local pickups = {}
	for _, weapon in ipairs(data.weaponPickups) do
		if type(weapon) ~= "table" or not validWeapon(weapon.kind, weapon) or weapon.loaded ~= 0 or weapon.cooldown ~= 0
			or not dense(weapon.position, 3) or #weapon.position ~= 3 then return nil end
		for _, value in ipairs(weapon.position) do
			if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return nil end
		end
		table.insert(pickups, { id = weapon.id, kind = weapon.kind, position = table.clone(weapon.position) })
	end
	local knownPlayers = {}
	for _, player in ipairs(data.players.players) do knownPlayers[player.userId] = true end
	local carried = {}
	for _, entry in ipairs(data.carried) do
		if type(entry) ~= "table" or not validId(entry.owner) or not knownPlayers[entry.owner]
			or carried[entry.owner] or type(entry.weapons) ~= "table" then return nil end
		local weapons = {}
		for kind, weapon in pairs(entry.weapons) do
			if not validWeapon(kind, weapon) then return nil end
			weapons[kind] = { id = weapon.id, kind = weapon.kind, loaded = weapon.loaded, cooldown = weapon.cooldown }
		end
		carried[entry.owner] = weapons
	end
	local storage = {}
	for i, building in ipairs(data.buildings) do
		storage[building.name] = { upgraded = building.upgraded, items = checked[i] }
	end
	local bags = {}
	for i, bag in ipairs(data.bags) do
		local weapons = {}
		for kind, weapon in pairs(bag.weapons) do
			weapons[kind] = { id = weapon.id, kind = weapon.kind, loaded = weapon.loaded, cooldown = weapon.cooldown }
		end
		bags[i] = { owner = bag.owner, position = table.clone(bag.position), items = checked[#data.buildings + i], weapons = weapons }
	end
	return session, storage, bags, carried, pickups, supplies
end
return table.freeze(Sessions)
