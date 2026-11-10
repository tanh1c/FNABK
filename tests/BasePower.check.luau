-- Studio Play server: isolated upgrade transaction.
local inventory = require(game.ServerScriptService.FNABKServer.Inventory)
local power = require(game.ServerScriptService.FNABKServer.BasePower)
local items, state = inventory.new(), Instance.new("BoolValue")
local building, holder = Instance.new("Model"), Instance.new("Part")
holder.Parent = building
local originallyOn, originallyOff = Instance.new("PointLight"), Instance.new("SpotLight")
originallyOn.Enabled, originallyOff.Enabled = true, false
originallyOn.Parent, originallyOff.Parent = holder, holder
power.bindLights(building, state)
assert(not originallyOn.Enabled and not originallyOff.Enabled)
for i = 1, 2 do assert(inventory.add(items, { id = "scrap" .. i, kind = "Scrap" })) end
assert(not power.restore(state, items) and inventory.count(items, "Scrap") == 2)
for i = 1, 2 do assert(inventory.add(items, { id = "electronic" .. i, kind = "Electronics" })) end
assert(power.restore(state, items) and state.Value and #items == 0)
task.wait()
assert(originallyOn.Enabled and not originallyOff.Enabled)
assert(not power.restore(state, items) and #items == 0)
local states = Instance.new("Folder")
local a, b = Instance.new("BoolValue"), Instance.new("BoolValue")
a.Name, a.Value, a.Parent = "A", true, states
b.Name, b.Value, b.Parent = "B", false, states
local http = game:GetService("HttpService")
local saved = http:JSONDecode(http:JSONEncode(assert(power.snapshot(states))))
a.Value, b.Value = false, true
assert(not power.applySnapshot(states, { A = true }) and not a.Value and b.Value)
assert(not power.applySnapshot(states, { A = true, B = false, Extra = true }) and not a.Value and b.Value)
assert(not power.applySnapshot(states, { A = true, B = "false" }) and not a.Value and b.Value)
assert(power.applySnapshot(states, saved) and a.Value and not b.Value)
local duplicate = Instance.new("BoolValue")
duplicate.Name, duplicate.Parent = "A", states
assert(power.snapshot(states) == nil and not power.applySnapshot(states, saved))
states:Destroy()
state:Destroy()
building:Destroy()
return "Base power transaction passed"
