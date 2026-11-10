--!strict
-- SURV-03/04: display the server's group announcement and host confirmation.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("FNABKRemotes")
local notice = remotes:WaitForChild("BaseNotice") :: RemoteEvent
local confirm = remotes:WaitForChild("BaseConfirm") :: RemoteEvent
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "FNABKBaseNotice", false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Size, label.Position = UDim2.fromOffset(400, 60), UDim2.new(0.5, -200, 0, 48)
label.BackgroundColor3, label.TextColor3 = Color3.fromRGB(24, 31, 40), Color3.new(1, 1, 1)
label.Font, label.TextSize, label.TextWrapped = Enum.Font.GothamBold, 16, true
label.Visible, label.Parent = false, gui
local button = Instance.new("TextButton")
button.Size, button.Position = UDim2.fromOffset(180, 35), UDim2.new(0.5, -90, 0, 112)
button.BackgroundColor3, button.TextColor3 = Color3.fromRGB(53, 76, 72), Color3.new(1, 1, 1)
button.Text, button.Font, button.TextSize = "CONFIRM BASE", Enum.Font.GothamBold, 15
button.Visible, button.Parent = false, gui
local current: number? = nil
local version = 0
button.Activated:Connect(function() if current then confirm:FireServer(current) end end)
notice.OnClientEvent:Connect(function(code: string, building: string?, id: number?, host: number?)
	if code == "Pending" then return end
	version += 1
	local thisVersion = version
	button.Visible = false
	if code == "Proposed" then
		current = id
		label.Text = "Proposed base: " .. (building or "") .. " — host confirmation in 10s"
	elseif code == "Ready" then
		current = id
		label.Text = "Proposed base: " .. (building or "") .. " — awaiting host"
		button.Visible = host == player.UserId
	elseif code == "Confirmed" then
		current = nil
		label.Text = "Active base: " .. (building or "")
	elseif code == "Canceled" then
		current = nil
		label.Text = "Base proposal canceled"
	elseif code == "Unavailable" then
		label.Text = "Host is unavailable"
	else return end
	label.Visible = true
	if code ~= "Proposed" and code ~= "Ready" then
		task.delay(4, function() if version == thisVersion then label.Visible = false end end)
	end
end)
