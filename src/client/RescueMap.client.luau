--!strict
-- Temporary objective map; positions are supplied by the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MapBounds = require(ReplicatedStorage:WaitForChild("FNABKShared"):WaitForChild("MapBounds"))
local objectives = ReplicatedStorage:WaitForChild("FNABKRoundState"):WaitForChild("RescueObjectives")
local buildings = workspace:WaitForChild("FNABK_Campus_PixelBuildings_PhaseC_v6"):WaitForChild("Buildings")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.Parent = "FNABKRescueMap", false, Players.LocalPlayer:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Size, panel.Position, panel.AnchorPoint = UDim2.fromOffset(600, 480), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)
panel.BackgroundColor3, panel.Visible, panel.Parent = Color3.fromRGB(30, 34, 36), false, gui
local title = Instance.new("TextLabel")
title.Size, title.BackgroundTransparency, title.TextColor3, title.Text = UDim2.new(1, 0, 0, 35), 1, Color3.new(1, 1, 1), "CAMPUS OBJECTIVES  |  M TO CLOSE"
title.Parent = panel
local map = Instance.new("Frame")
map.Position, map.Size, map.BackgroundColor3, map.Parent = UDim2.fromOffset(20, 40), UDim2.new(1, -40, 1, -60), Color3.fromRGB(64, 70, 67), panel
local records, minX, maxX, minZ, maxZ = {}, math.huge, -math.huge, math.huge, -math.huge
for _, building in ipairs(buildings:GetChildren()) do
	if building:IsA("Model") then
		local cf, size = building:GetBoundingBox()
		local left, right, front, back = MapBounds.project(cf, size)
		table.insert(records, { name = building.Name, pos = Vector3.new((left + right) / 2, 0, (front + back) / 2), size = Vector3.new(right - left, 0, back - front) })
		minX, maxX = math.min(minX, left), math.max(maxX, right)
		minZ, maxZ = math.min(minZ, front), math.max(maxZ, back)
	end
end
local width, depth = math.max(1, maxX - minX), math.max(1, maxZ - minZ)
local function position(p: Vector3): UDim2 return UDim2.fromScale((p.X - minX) / width, (p.Z - minZ) / depth) end
local playerMarker = Instance.new("TextLabel")
playerMarker.Name, playerMarker.AnchorPoint = "PlayerMarker", Vector2.new(.5, .5)
playerMarker.Size, playerMarker.BackgroundColor3 = UDim2.fromOffset(38, 20), Color3.fromRGB(35, 65, 95)
playerMarker.Text, playerMarker.TextColor3, playerMarker.TextSize = "YOU", Color3.new(1, 1, 1), 12
playerMarker.ZIndex, playerMarker.Visible, playerMarker.Parent = 3, false, map
RunService.RenderStepped:Connect(function()
	if not panel.Visible then return end
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then playerMarker.Visible = false; return end
	local projected = position(root.Position)
	playerMarker.Position = UDim2.fromScale(math.clamp(projected.X.Scale, 0, 1), math.clamp(projected.Y.Scale, 0, 1))
	playerMarker.Text = if projected.X.Scale < 0 or projected.X.Scale > 1 or projected.Y.Scale < 0 or projected.Y.Scale > 1 then "EDGE" else "YOU"
	playerMarker.Visible = true
end)
for _, b in ipairs(records) do
	local block = Instance.new("TextLabel")
	block.AnchorPoint, block.Position, block.Size = Vector2.new(.5, .5), position(b.pos), UDim2.fromScale(b.size.X / width, b.size.Z / depth)
	block.BackgroundColor3, block.TextColor3, block.TextScaled, block.Text, block.Parent = Color3.fromRGB(102, 108, 101), Color3.new(1, 1, 1), true, b.name, map
end
local flags: { [string]: BoolValue } = {
	Power = objectives:WaitForChild("Power") :: BoolValue,
	Frequency = objectives:WaitForChild("Frequency") :: BoolValue,
	Transmitter = objectives:WaitForChild("Transmitter") :: BoolValue,
}
local sent = objectives:WaitForChild("SignalSent") :: BoolValue
for _, name in ipairs({ "Power", "Frequency", "Transmitter" }) do
	local flag = flags[name]
	local marker = Instance.new("TextLabel")
	marker.Name = name .. "Marker"
	marker.AnchorPoint, marker.Size = Vector2.new(.5, .5), UDim2.fromOffset(120, 34)
	marker.TextColor3, marker.TextScaled, marker.ZIndex, marker.Parent = Color3.new(1, 1, 1), true, 2, map
	local function refresh()
		local point = flag:GetAttribute("Position")
		marker.Visible = typeof(point) == "Vector3"
		if typeof(point) == "Vector3" then marker.Position = position(point) end
		local signalReady = name == "Transmitter" and flags.Power.Value and flags.Frequency.Value and flags.Transmitter.Value and not sent.Value
		local status = if signalReady then "SEND SIGNAL [G]" elseif flag.Value then name .. " ✓" else name .. " !"
		marker.Text = status .. "\n" .. tostring(flag:GetAttribute("Building") or "...") .. " · " .. tostring(flag:GetAttribute("Floor") or "...")
		marker.BackgroundColor3 = if flag.Value and not signalReady then Color3.fromRGB(52, 106, 76) else Color3.fromRGB(162, 82, 43)
	end
	for _, value in pairs(flags) do value.Changed:Connect(refresh) end
	sent.Changed:Connect(refresh)
	for _, attribute in ipairs({ "Position", "Building", "Floor" }) do flag:GetAttributeChangedSignal(attribute):Connect(refresh) end
	refresh()
end
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.M then panel.Visible = not panel.Visible end
end)
