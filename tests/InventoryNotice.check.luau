-- Studio Play client: start before the server sends ShareFeedback to this player.
local notice = game.Players.LocalPlayer.PlayerGui:WaitForChild("FNABKInventory"):WaitForChild("ActionNotice")
local deadline = os.clock() + 10
while not notice.Visible and os.clock() < deadline do task.wait(.05) end
assert(notice.Visible and notice.Text == "Need 1 scrap to trade")
task.wait(3.2)
assert(not notice.Visible)
return "Inventory action notice passed"
