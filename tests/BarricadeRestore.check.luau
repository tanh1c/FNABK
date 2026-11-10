-- Controlled Studio Play server; temporary service (SURV-04/10).
local map = Instance.new("Folder")
map.Name, map.Parent = "TestDefenseRestore", workspace
local events = Instance.new("BindableEvent")
events.Parent = map
local config = require(game.ReplicatedStorage.FNABKShared.GameConfig)
local _, _, _, snapshot, restore = require(game.ServerScriptService.FNABKServer.MedkitService).Start(map, config, function() return 100 end, events, events)
local barrier = assert(map:FindFirstChild("B1Barricade"))
assert(not restore({ B1 = { installed = false, health = 9 } }))
assert(restore({ B1 = { installed = true, health = 0 } }))
assert(not barrier.CanCollide and barrier:GetAttribute("Installed") == true and barrier:GetAttribute("Health") == 0)
for _, post in ipairs(barrier.DamagedFrame:GetChildren()) do assert(post.Transparency == 0) end
assert(snapshot().B1.health == 0 and not restore({ B1 = { installed = true, health = 50 } }))
map:Destroy()
return "Barricade restore checks passed"
