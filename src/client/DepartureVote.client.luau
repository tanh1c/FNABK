--!strict
-- Temporary departure controls; the server decides eligibility and results.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("FNABKRemotes"):WaitForChild("DepartureVote") :: RemoteEvent
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.Parent = "FNABKDepartureVote", false, player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size, frame.Position, frame.AnchorPoint = UDim2.fromOffset(380, 180), UDim2.new(.5, 0, 1, -100), Vector2.new(.5, 1)
frame.BackgroundColor3, frame.Visible, frame.Parent = Color3.fromRGB(30, 34, 36), false, gui
local text = Instance.new("TextLabel")
text.Size, text.BackgroundTransparency, text.TextColor3, text.TextWrapped, text.TextSize, text.Parent = UDim2.new(1, -20, 0, 90), 1, Color3.new(1, 1, 1), true, 16, frame
local function button(label: string, x: number, callback: () -> ())
	local b = Instance.new("TextButton")
	b.Size, b.Position, b.Text = UDim2.fromOffset(110, 36), UDim2.new(0, x, 1, -45), label
	b.BackgroundColor3, b.TextColor3, b.Parent = Color3.fromRGB(82, 87, 78), Color3.new(1, 1, 1), frame
	b.Activated:Connect(callback)
	return b
end
local mode = ""
local open = button("Depart", 10, function() if mode == "idle" then remote:FireServer("Warning") elseif mode == "warning" then remote:FireServer("Start") elseif mode == "vote" then remote:FireServer("Vote", true) end end)
local no: TextButton
no = button("No", 135, function() if mode == "vote" then remote:FireServer("Vote", false) else remote:FireServer("CancelWarning"); mode = "idle"; text.Text = "Ready to depart?"; open.Text = "Depart"; no.Visible = false end end)
local withdraw = button("Withdraw", 260, function() if mode == "vote" then remote:FireServer("Vote", "withdraw") end end)
local function refresh()
	frame.Visible = player:GetAttribute("FNABKAboard") == true
	if not frame.Visible then mode = "" else mode = "idle"; text.Text = "Ready to depart?"; open.Text = "Depart" end
	no.Visible, withdraw.Visible = false, false
end
player:GetAttributeChangedSignal("FNABKAboard"):Connect(refresh)
refresh()
remote.OnClientEvent:Connect(function(event, payload)
	if event == "Warning" and frame.Visible then mode = "warning"; text.Text = "LEFT BEHIND:\n" .. (if #payload == 0 then "Nobody" else table.concat(payload, "\n")); open.Text = "Confirm"; no.Text = "Cancel"; no.Visible = true
	elseif event == "Roster" and mode == "warning" then text.Text = "LEFT BEHIND:\n" .. (if #payload == 0 then "Nobody" else table.concat(payload, "\n"))
	elseif event == "Started" and frame.Visible then mode = "vote"; text.Text = "Depart now? Vote closes in 10 seconds."; open.Text = "Yes"; no.Text = "No"; no.Visible, withdraw.Visible = true, true
	elseif event == "Canceled" and frame.Visible then mode = "idle"; text.Text = "Vote ended or canceled."; open.Text = "Depart"; no.Visible, withdraw.Visible = false, false end
end)
