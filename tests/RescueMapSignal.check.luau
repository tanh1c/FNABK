-- Studio Play client: changes only local replicated values for this check.
local objectives = game.ReplicatedStorage.FNABKRoundState:WaitForChild("RescueObjectives")
local marker = game.Players.LocalPlayer.PlayerGui:WaitForChild("FNABKRescueMap"):FindFirstChild("TransmitterMarker", true)
assert(marker and marker:IsA("TextLabel"))
local values = { objectives.Power, objectives.Frequency, objectives.Transmitter, objectives.SignalSent }
local previous = {}
for i, value in ipairs(values) do previous[i] = value.Value; value.Value = false end
task.wait()
assert(not marker.Text:find("SEND SIGNAL"))
for i = 1, 3 do values[i].Value = true end
task.wait()
assert(marker.Text:find("SEND SIGNAL"))
values[4].Value = true
task.wait()
assert(not marker.Text:find("SEND SIGNAL"))
for i, value in ipairs(values) do value.Value = previous[i] end
return "Rescue map signal marker passed"
