-- Studio Play client: after closing storage, have server send an Update for the old storage.
local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("FNABKInventory")
task.wait(.5)
assert(not gui.InventoryPanel.Visible and not gui.StoragePanel.Visible)
return "Late storage update did not reopen panels"
