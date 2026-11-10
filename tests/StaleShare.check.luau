-- Studio client command bar, after collecting one medkit.
local remotes = game.ReplicatedStorage.FNABKRemotes
local player = game.Players.LocalPlayer
assert(player:GetAttribute("FNABKMedkitCount") == 1, "Collect one medkit first")
local revision, message
local snapshot = remotes.InventorySnapshot.OnClientEvent:Connect(function(_, value) revision = value end)
local feedback = remotes.ShareFeedback.OnClientEvent:Connect(function(value) message = value end)
remotes.InventorySync:FireServer()
task.wait(1.2)
assert(type(revision) == "number", "Snapshot revision missing")
remotes.ShareRequest:FireServer(1, "Medkit", revision - 1)
task.wait(0.5)
assert(message == "Inventory changed; select the item again", "Stale selection was not rejected")
assert(player:GetAttribute("FNABKMedkitCount") == 1, "Stale selection changed inventory")
snapshot:Disconnect()
feedback:Disconnect()
print("Stale share check passed")
