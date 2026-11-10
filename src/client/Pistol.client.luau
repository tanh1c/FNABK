--!strict
-- Firearm input only; server owns ammunition and hit results.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("FNABKRemotes"):WaitForChild("PistolRequest") :: RemoteEvent
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "FNABKPistol", false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Size, label.Position = UDim2.fromOffset(190, 32), UDim2.new(1, -202, 1, -60)
label.BackgroundColor3, label.TextColor3 = Color3.fromRGB(24, 31, 40), Color3.new(1, 1, 1)
label.Font, label.TextSize, label.Visible, label.Parent = Enum.Font.GothamBold, 15, false, gui
local fireGeneration = 0
local function equipped(character: Model): Tool?
	local tool = character:FindFirstChild("Pistol") or character:FindFirstChild("Rifle") or character:FindFirstChild("Shotgun")
	return if tool and tool:IsA("Tool") then tool else nil
end
local function watch(character: Model)
	local function refresh()
		local tool = equipped(character)
		label.Visible = tool ~= nil
		if tool then label.Text = string.upper(tool.Name) .. " " .. tostring(tool:GetAttribute("Loaded") or 0) .. (if tool.Name == "Rifle" then "/30" elseif tool.Name == "Shotgun" then "/6" else "/12") .. (if tool:GetAttribute("Reloading") then "  |  RELOADING" else "  |  T RELOAD") end
	end
	character.ChildAdded:Connect(function(child)
		if child.Name == "Pistol" or child.Name == "Rifle" or child.Name == "Shotgun" then child:GetAttributeChangedSignal("Loaded"):Connect(refresh); child:GetAttributeChangedSignal("Reloading"):Connect(refresh); refresh() end
	end)
	character.ChildRemoved:Connect(refresh)
	refresh()
end
player.CharacterAdded:Connect(watch)
if player.Character then watch(player.Character) end
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	local character = player.Character
	local tool = character and equipped(character)
	if not tool then return end
	if input.KeyCode == Enum.KeyCode.T then remote:FireServer("Reload")
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		fireGeneration += 1
		local generation = fireGeneration
		repeat
			local camera = workspace.CurrentCamera
			if camera then
				local mouse = UserInputService:GetMouseLocation()
				remote:FireServer("Fire", camera:ViewportPointToRay(mouse.X, mouse.Y).Direction)
			end
			if tool.Name ~= "Rifle" then break end
			task.wait(0.15)
		until generation ~= fireGeneration or tool.Parent ~= player.Character
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then fireGeneration += 1 end
end)
UserInputService.WindowFocusReleased:Connect(function() fireGeneration += 1 end)
