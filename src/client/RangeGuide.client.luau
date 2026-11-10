--!strict
-- AC-04/AC-05 Studio-only range aid. It displays distances but sends no gameplay requests.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

if not RunService:IsStudio() then
	return
end

type RangeItem = {
	label: string,
	rangeStuds: number,
	color: Color3,
	previewOnly: boolean,
}

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("FNABKShared")
local config = require(shared:WaitForChild("GameConfig"))

local RANGE_ITEMS: { RangeItem } = {
	{
		label = "BATON",
		rangeStuds = config.batonRangeStuds,
		color = Color3.fromRGB(245, 194, 93),
		previewOnly = false,
	},
	{
		label = "UV DEVICE",
		rangeStuds = config.uvRangeStuds,
		color = Color3.fromRGB(116, 184, 255),
		previewOnly = false,
	},
	{
		label = "SCANNER",
		rangeStuds = config.scannerRangeStuds,
		color = Color3.fromRGB(105, 220, 185),
		previewOnly = true,
	},
}

local previousGui = playerGui:FindFirstChild("FNABKStudioRangeGuide")
if previousGui then
	previousGui:Destroy()
end
local previousAdornment = playerGui:FindFirstChild("FNABKStudioRangeSphere")
if previousAdornment then
	previousAdornment:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FNABKStudioRangeGuide"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 20
screenGui.Parent = playerGui

local panel = Instance.new("TextLabel")
panel.Name = "RangeReadout"
panel.AnchorPoint = Vector2.new(0, 0)
panel.Position = UDim2.fromOffset(18, 82)
panel.Size = UDim2.fromOffset(310, 106)
panel.BackgroundColor3 = Color3.fromRGB(19, 36, 55)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Font = Enum.Font.GothamBold
panel.Text = "STUDIO RANGE GUIDE [V]\nOFF\nPress V to cycle Baton > UV > Scanner > Off"
panel.TextColor3 = Color3.fromRGB(230, 238, 245)
panel.TextSize = 14
panel.TextWrapped = true
panel.TextXAlignment = Enum.TextXAlignment.Left
panel.TextYAlignment = Enum.TextYAlignment.Center
panel.Visible = true
panel.Parent = screenGui

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = panel

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(112, 143, 168)
stroke.Transparency = 0.35
stroke.Thickness = 1
stroke.Parent = panel

local rangeSphere = Instance.new("SphereHandleAdornment")
rangeSphere.Name = "FNABKStudioRangeSphere"
rangeSphere.Transparency = 0.91
rangeSphere.Shading = Enum.AdornShading.Default
rangeSphere.AlwaysOnTop = false
rangeSphere.Visible = false
rangeSphere.Parent = playerGui

local selectedIndex = 0
local selectedItem: RangeItem? = nil

local function updateSelection()
	if selectedIndex == 0 then
		selectedItem = nil
		rangeSphere.Visible = false
		panel.Text = "STUDIO RANGE GUIDE [V]\nOFF\nPress V to cycle Baton > UV > Scanner > Off"
		panel.TextColor3 = Color3.fromRGB(230, 238, 245)
		return
	end

	local item = RANGE_ITEMS[selectedIndex]
	selectedItem = item
	rangeSphere.Radius = item.rangeStuds
	rangeSphere.Color3 = item.color
	rangeSphere.Visible = true
	local previewNote = if item.previewOnly then " (preview only)" else ""
	panel.Text = string.format(
		"STUDIO RANGE GUIDE [V]\n%s%s | max %.1f studs\nAim at Mimic or Student to measure",
		item.label,
		previewNote,
		item.rangeStuds
	)
	panel.TextColor3 = item.color
end

local function getAimedNpc(): Model?
	local camera = Workspace.CurrentCamera
	if not camera then
		return nil
	end

	local mousePosition = UserInputService:GetMouseLocation()
	local unitRay = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = if localPlayer.Character then { localPlayer.Character } else {}
	raycastParams.IgnoreWater = true

	local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 250, raycastParams)
	if not result then
		return nil
	end

	local instance: Instance? = result.Instance
	while instance and instance ~= Workspace do
		if instance:IsA("Model") then
			local npcType = instance:GetAttribute("NPCType")
			if npcType == "Mimic" or npcType == "Student" then
				return instance
			end
		end
		instance = instance.Parent
	end
	return nil
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed or input.KeyCode ~= Enum.KeyCode.V then
		return
	end

	selectedIndex += 1
	if selectedIndex > #RANGE_ITEMS then
		selectedIndex = 0
	end
	updateSelection()
end)

task.spawn(function()
	while screenGui.Parent do
		local item = selectedItem
		if item then
			local character = localPlayer.Character
			local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
			if playerRoot and playerRoot:IsA("BasePart") then
				rangeSphere.Adornee = playerRoot
				rangeSphere.Visible = true

				local target = getAimedNpc()
				local targetRoot = target and target.PrimaryPart
				if target and targetRoot then
					local distance = (targetRoot.Position - playerRoot.Position).Magnitude
					local inRange = distance <= item.rangeStuds
					local status = if inRange then "IN RANGE" else "TOO FAR"
					local statusColor = if inRange then Color3.fromRGB(130, 230, 170) else Color3.fromRGB(255, 145, 125)
					local previewPrefix = if item.previewOnly then "PREVIEW ONLY | " else ""
					panel.Text = string.format(
						"STUDIO RANGE GUIDE [V]\n%s%s | max %.1f studs\n%s%s: %.1f / %.1f studs",
						item.label,
						if item.previewOnly then " (preview)" else "",
						item.rangeStuds,
						previewPrefix,
						status,
						distance,
						item.rangeStuds
					)
					panel.TextColor3 = statusColor
				else
					panel.Text = string.format(
						"STUDIO RANGE GUIDE [V]\n%s | max %.1f studs\nAim directly at an NPC (clear line of sight)",
						item.label,
						item.rangeStuds
					)
					panel.TextColor3 = item.color
				end
			else
				rangeSphere.Adornee = nil
				rangeSphere.Visible = false
				panel.Text = string.format("STUDIO RANGE GUIDE [V]\n%s | max %.1f studs\nWaiting for character...", item.label, item.rangeStuds)
				panel.TextColor3 = item.color
			end
		end

		task.wait(0.1)
	end
end)
