--!strict
-- SURV-09: eliminated players can cycle connected teammates until the round ends.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local index = 1
local watching = false
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.Parent = "FNABKSpectate", false, player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Size, label.Position, label.AnchorPoint = UDim2.fromOffset(360, 38), UDim2.new(.5, 0, 1, -55), Vector2.new(.5, 1)
label.BackgroundColor3, label.TextColor3, label.TextSize = Color3.fromRGB(29, 32, 30), Color3.new(1, 1, 1), 16
label.Visible, label.Parent = false, gui
local function update()
	local camera = workspace.CurrentCamera
	if not camera then return end
	if player:GetAttribute("FNABKEliminated") ~= true then
		label.Visible = false
		if watching then
			watching = false
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then camera.CameraSubject = humanoid end
		end
		return
	end
	watching = true
	local candidates = {}
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other:GetAttribute("FNABKEliminated") ~= true and other.Character and other.Character:FindFirstChildOfClass("Humanoid") then
			table.insert(candidates, other)
		end
	end
	table.sort(candidates, function(a, b) return a.UserId < b.UserId end)
	label.Visible = true
	if #candidates == 0 then label.Text = "SPECTATING | No teammate available"; return end
	index = (index - 1) % #candidates + 1
	local target = candidates[index]
	camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
	label.Text = "SPECTATING " .. target.DisplayName .. "  |  [ / ]"
end
player:GetAttributeChangedSignal("FNABKEliminated"):Connect(update)
Players.PlayerAdded:Connect(update)
Players.PlayerRemoving:Connect(function() task.defer(update) end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or player:GetAttribute("FNABKEliminated") ~= true then return end
	if input.KeyCode == Enum.KeyCode.LeftBracket then index -= 1; update()
	elseif input.KeyCode == Enum.KeyCode.RightBracket then index += 1; update() end
end)
-- ponytail: refresh handles teammate respawns; replace polling with roster subscriptions if profiling warrants.
task.spawn(function() while gui.Parent do task.wait(1); if player:GetAttribute("FNABKEliminated") == true then update() end end end)
update()
