-- Studio client command bar near FNABKGraybox.Ammunition.PistolAmmo.
local player = game.Players.LocalPlayer
local box = workspace.FNABKGraybox.Ammunition.PistolAmmo
local found
local connection = game.ReplicatedStorage.FNABKRemotes.InventorySnapshot.OnClientEvent:Connect(function(slots)
	for _, slot in ipairs(slots) do if slot.kind == "PistolAmmo" then found = slot.count end end
end)
local prompt = box.ProximityPrompt
prompt:InputHoldBegin()
task.wait(0.3)
if prompt.Parent then prompt:InputHoldEnd() end
task.wait(0.5)
connection:Disconnect()
assert(found == 1 and not box.Parent, "Pistol ammo pickup failed")
print("Pistol ammo pickup passed")
