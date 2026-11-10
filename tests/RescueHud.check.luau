-- Run in a solo Studio Play client. These changes are local to this client.
local state = game.ReplicatedStorage:WaitForChild("FNABKRoundState")
local objectives = state:WaitForChild("RescueObjectives")
local label = game.Players.LocalPlayer.PlayerGui:WaitForChild("FNABKRoundHUD"):WaitForChild("Objective")
local values = { objectives.Power, objectives.Frequency, objectives.Transmitter, objectives.SignalSent, state.SurvivalPhase }
local previous = {}
for i, value in ipairs(values) do previous[i] = value.Value end
for i = 1, 4 do values[i].Value = false end
state.SurvivalPhase.Value = "Day"
task.wait()
assert(label.Text:find("0/3"))
for i = 1, 3 do values[i].Value = true end
task.wait()
assert(label.Text:find("SEND THE SIGNAL"))
values[4].Value = true
task.wait()
assert(label.Text:find("NIGHT 5"))
state.SurvivalPhase.Value = "RescueWait"
task.wait()
assert(label.Text:find("HELICOPTER APPROACHING"))
state.SurvivalPhase.Value = "Boarding"
task.wait()
assert(label.Text:find("BOARD THE HELICOPTER"))
local player = game.Players.LocalPlayer
local originalResult, originalStatus = player:GetAttribute("FNABKRescueResult"), state.RoundStatus.Value
state.RoundStatus.Value = "Won"
for result, expected in pairs({ Rescued = "YOU WERE RESCUED", LeftBehind = "YOU WERE LEFT BEHIND", Eliminated = "YOU WERE ELIMINATED" }) do
	player:SetAttribute("FNABKRescueResult", result)
	task.wait()
	assert(label.Text == expected)
end
state.RoundStatus.Value = "Lost"
player:SetAttribute("FNABKRescueResult", "LeftBehind")
task.wait()
assert(label.Text == "YOU WERE LEFT BEHIND")
player:SetAttribute("FNABKRescueResult", originalResult)
state.RoundStatus.Value = originalStatus
for i, value in ipairs(values) do value.Value = previous[i] end
return "Rescue HUD checks passed"
