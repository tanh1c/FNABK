-- Studio Play client: start this check, then trigger a test warning on the server.
local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("FNABKWaveNotice")
local sound, label = gui:WaitForChild("WarningSound"), gui:WaitForChild("Message")
assert(sound:IsA("Sound") and label:IsA("TextLabel"))
local played = false
local connection = sound:GetPropertyChangedSignal("Playing"):Connect(function() if sound.IsPlaying then played = true end end)
local deadline = os.clock() + 10
while not played and os.clock() < deadline do task.wait(.05) end
connection:Disconnect()
assert(played and sound.IsLoaded)
assert(label:IsA("TextLabel") and label.Visible and label.Text == "Attack incoming in 30 seconds")
return "Wave warning sound and text observed"
