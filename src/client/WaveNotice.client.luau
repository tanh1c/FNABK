--!strict
local remote = game:GetService("ReplicatedStorage"):WaitForChild("FNABKRemotes"):WaitForChild("WaveNotice") :: RemoteEvent
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.Parent = "FNABKWaveNotice", false, game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local text = Instance.new("TextLabel")
text.Name = "Message"
text.AnchorPoint, text.Position, text.Size = Vector2.new(.5, 0), UDim2.new(.5, 0, 0, 82), UDim2.fromOffset(360, 36)
text.BackgroundColor3, text.TextColor3, text.Visible, text.Parent = Color3.fromRGB(62, 36, 30), Color3.new(1, 1, 1), false, gui
local sound = Instance.new("Sound")
sound.Name, sound.SoundId, sound.Volume = "WarningSound", "rbxasset://sounds//metal2.mp3", .4
-- ponytail: built-in metal strike is a temporary warning cue; replace after audio review.
sound.Parent = gui
local generation = 0
remote.OnClientEvent:Connect(function(message: string, kind: string?)
	generation += 1
	local current = generation
	text.Text, text.Visible = message, true
	if kind == "Warning" or kind == "MachineAlert" or kind == "CreatureAlert" then
		sound.PlaybackSpeed = if kind == "MachineAlert" then 1.5 elseif kind == "CreatureAlert" then .7 else 1
		sound:Play()
	end
	task.delay(5, function() if generation == current then text.Visible = false end end)
end)
