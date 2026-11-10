-- Studio Play client: open a storage panel, then press B before running this check.
local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("FNABKInventory")
assert(not gui.InventoryPanel.Visible and not gui.StoragePanel.Visible)
assert(gui.InventoryPanel.Share.Text == "GIVE ITEM")
assert(gui.StoragePanel.Deposit.Text == "DEPOSIT: SELECT ITEM")
return "Inventory and storage closed with modes reset"
