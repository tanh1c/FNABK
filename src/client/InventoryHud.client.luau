--!strict
-- SURV-05: display only the server's private inventory summary.
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local remotes = ReplicatedStorage:WaitForChild("FNABKRemotes")
local snapshot = remotes:WaitForChild("InventorySnapshot") :: RemoteEvent
local sync = remotes:WaitForChild("InventorySync") :: RemoteEvent
local consume = remotes:WaitForChild("ConsumeRequest") :: RemoteEvent
local share = remotes:WaitForChild("ShareRequest") :: RemoteEvent
local shareFeedback = remotes:WaitForChild("ShareFeedback") :: RemoteEvent
local storageRemote = remotes:WaitForChild("BaseStorage") :: RemoteEvent
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "FNABKInventory"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Name = "InventoryPanel"
panel.Size = UDim2.fromOffset(400, 300)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(24, 31, 40)
panel.Visible = false
panel.Parent = gui
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(140, 32)
button.Position = UDim2.new(1, -152, 0, 52)
button.BackgroundColor3 = Color3.fromRGB(48, 58, 70)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.Text = "INVENTORY [B]"
button.Parent = gui
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundTransparency = 1
title.Text = "INVENTORY  |  B TO CLOSE"
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = panel
local cells = {}
local kinds = {}
local emptyAmmo = {}
local revision: number? = nil
local sharing = false
local storageName: string? = nil
local storageRev: number? = nil
local storing = false
local storagePanel = Instance.new("Frame")
storagePanel.Name = "StoragePanel"
storagePanel.Size, storagePanel.Position, storagePanel.AnchorPoint = UDim2.fromOffset(300, 430), UDim2.new(.5, 215, .5, 0), Vector2.new(0, .5)
storagePanel.BackgroundColor3, storagePanel.Visible, storagePanel.Parent = Color3.fromRGB(32, 36, 35), false, gui
local storageTitle = Instance.new("TextLabel")
storageTitle.Size, storageTitle.BackgroundTransparency, storageTitle.TextColor3, storageTitle.TextSize, storageTitle.Parent = UDim2.new(1, 0, 0, 40), 1, Color3.new(1, 1, 1), 15, storagePanel
local storageCells = {}
for i = 1, 16 do
	local cell = Instance.new("TextButton")
	cell.Size, cell.Position = UDim2.fromOffset(65, 65), UDim2.fromOffset(10 + ((i - 1) % 4) * 72, 48 + math.floor((i - 1) / 4) * 72)
	cell.BackgroundColor3, cell.TextColor3, cell.TextWrapped, cell.Parent = Color3.fromRGB(69, 73, 67), Color3.new(1, 1, 1), true, storagePanel
	cell.Activated:Connect(function() if storageName and storageRev then storageRemote:FireServer("Take", storageName, i, storageRev) end end)
	storageCells[i] = cell
end
local deposit = Instance.new("TextButton")
deposit.Name = "Deposit"
deposit.Size, deposit.Position, deposit.Text, deposit.Parent = UDim2.fromOffset(220, 35), UDim2.fromOffset(10, 342), "DEPOSIT: SELECT ITEM", storagePanel
local close = Instance.new("TextButton")
close.Size, close.Position, close.Text, close.Parent = UDim2.fromOffset(60, 35), UDim2.fromOffset(230, 342), "CLOSE", storagePanel
close.Activated:Connect(function() storagePanel.Visible = false; storageName = nil; storageRev = nil; storing = false; deposit.Text = "DEPOSIT: SELECT ITEM" end)
local upgrade = Instance.new("TextButton")
upgrade.Size, upgrade.Position, upgrade.Text, upgrade.Parent = UDim2.fromOffset(280, 35), UDim2.fromOffset(10, 385), "EXPAND STORAGE: 2 SCRAP", storagePanel
upgrade.Activated:Connect(function() if storageName and revision then storageRemote:FireServer("Upgrade", storageName, 0, revision) end end)
storageRemote.OnClientEvent:Connect(function(action, name, slots, newRevision, upgraded)
	if action ~= "Open" and (action ~= "Update" or not storagePanel.Visible or storageName ~= name) then return end
	storageName, storageRev, storagePanel.Visible, panel.Visible = name, newRevision, true, true
	storageTitle.Text = name .. " STORAGE"
	upgrade.Text = if upgraded then "STORAGE EXPANDED" else "EXPAND STORAGE: 2 SCRAP"
	for i, cell in ipairs(storageCells) do local slot = slots[i]; cell.Visible = i <= 8 or upgraded; cell.Text = if slot then slot.kind .. " x" .. slot.count else "EMPTY" end
end)
local shareButton = Instance.new("TextButton")
shareButton.Name = "Share"
shareButton.Size = UDim2.fromOffset(150, 34)
shareButton.Position = UDim2.fromOffset(12, 246)
shareButton.BackgroundColor3 = Color3.fromRGB(48, 58, 70)
shareButton.TextColor3 = Color3.new(1, 1, 1)
shareButton.Font = Enum.Font.GothamBold
shareButton.TextSize = 14
shareButton.Text = "GIVE ITEM"
shareButton.Parent = panel
local shareStatus = Instance.new("TextLabel")
shareStatus.Position = UDim2.fromOffset(170, 246)
shareStatus.Size = UDim2.fromOffset(218, 42)
shareStatus.BackgroundTransparency = 1
shareStatus.TextColor3 = Color3.new(1, 1, 1)
shareStatus.TextWrapped = true
shareStatus.TextSize = 13
shareStatus.Font = Enum.Font.Gotham
shareStatus.Text = ""
shareStatus.Parent = panel
local function resetModes()
	sharing, storing = false, false
	shareButton.Text, shareStatus.Text, deposit.Text = "GIVE ITEM", "", "DEPOSIT: SELECT ITEM"
end
local function toggle()
	panel.Visible = not panel.Visible
	if panel.Visible then sync:FireServer() else
		storagePanel.Visible, storageName, storageRev = false, nil, nil
		resetModes()
	end
end
button.Activated:Connect(toggle)
deposit.Activated:Connect(function()
	storing = not storing
	if storing then sharing = false; shareButton.Text, shareStatus.Text = "GIVE ITEM", "" end
	deposit.Text = if storing then "SELECT INVENTORY ITEM" else "DEPOSIT: SELECT ITEM"
end)
local notice = Instance.new("TextLabel")
notice.Name, notice.AnchorPoint = "ActionNotice", Vector2.new(.5, 1)
notice.Position, notice.Size = UDim2.new(.5, 0, .82, 0), UDim2.new(.8, 0, 0, 36)
notice.BackgroundColor3, notice.TextColor3 = Color3.fromRGB(24, 31, 40), Color3.new(1, 1, 1)
notice.Font, notice.TextSize, notice.TextWrapped = Enum.Font.GothamBold, 15, true
notice.Visible, notice.Parent = false, gui
local limit = Instance.new("UISizeConstraint")
limit.MaxSize, limit.Parent = Vector2.new(450, 36), notice
local noticeVersion = 0
shareButton.Activated:Connect(function()
	sharing = not sharing
	if sharing then storing = false; deposit.Text = "DEPOSIT: SELECT ITEM" end
	shareButton.Text = if sharing then "CANCEL GIVE" else "GIVE ITEM"
	shareStatus.Text = if sharing then "Select an item; nearest teammate receives one." else ""
end)
shareFeedback.OnClientEvent:Connect(function(message: string)
	shareStatus.Text = message
	noticeVersion += 1
	local version = noticeVersion
	notice.Text, notice.Visible = message, true
	task.delay(3, function() if noticeVersion == version then notice.Visible = false end end)
end)
for i = 1, 8 do
	local cell = Instance.new("TextButton")
	cell.Position = UDim2.fromOffset(12 + ((i - 1) % 4) * 96, 48 + math.floor((i - 1) / 4) * 96)
	cell.Size = UDim2.fromOffset(88, 88)
	cell.BackgroundColor3 = Color3.fromRGB(48, 58, 70)
	cell.TextColor3 = Color3.new(1, 1, 1)
	cell.Font = Enum.Font.Gotham
	cell.TextSize = 14
	cell.TextWrapped = true
	cell.Text = "EMPTY"
	cell.Parent = panel
	cell.Activated:Connect(function()
		local kind = kinds[i]
		if not kind then return end
		if storing and storageName and revision then
			storageRemote:FireServer("Deposit", storageName, i, revision)
			storing = false
			deposit.Text = "DEPOSIT: SELECT ITEM"
		elseif sharing then
			if revision then share:FireServer(i, kind, revision) end
			sharing = false
			shareButton.Text = "GIVE ITEM"
		elseif emptyAmmo[i] and revision then consume:FireServer("DiscardEmptyAmmo", i, revision)
		elseif kind == "Food" or kind == "Water" or kind == "Cloth" or kind == "Bandage" then consume:FireServer(kind) end
	end)
	cells[i] = cell
end
snapshot.OnClientEvent:Connect(function(slots, newRevision: number)
	revision = newRevision
	for i, cell in ipairs(cells) do
		local slot = slots[i]
		kinds[i] = if slot then slot.kind else nil
		emptyAmmo[i] = slot ~= nil and type(slot.empty) == "number" and slot.empty > 0
		cell.Text = if slot then string.format("%s\n× %d%s", slot.kind, slot.count, if emptyAmmo[i] then "\nDISCARD EMPTY" elseif slot.kind == "Cloth" then "\nCRAFT" elseif slot.kind == "Bandage" then "\nUSE" else "") else "EMPTY"
	end
end)
local needsLabel = Instance.new("TextLabel")
needsLabel.Size = UDim2.fromOffset(220, 32)
needsLabel.Position = UDim2.new(0, 12, 1, -110)
needsLabel.BackgroundColor3 = Color3.fromRGB(24, 31, 40)
needsLabel.TextColor3 = Color3.new(1, 1, 1)
needsLabel.Font = Enum.Font.GothamBold
needsLabel.TextSize = 15
needsLabel.Parent = gui
local function refreshNeeds()
	local food = player:GetAttribute("FNABKFood") or 100
	local water = player:GetAttribute("FNABKWater") or 100
	-- ponytail: fixed 20-point warning threshold; tune after survival playtesting.
	needsLabel.Text = string.format("FOOD %d%s  |  WATER %d%s", math.floor(food), if food <= 20 then " LOW" else "", math.floor(water), if water <= 20 then " LOW" else "")
	needsLabel.TextColor3 = if food <= 20 or water <= 20 then Color3.fromRGB(255, 205, 120) else Color3.new(1, 1, 1)
end
player:GetAttributeChangedSignal("FNABKFood"):Connect(refreshNeeds)
player:GetAttributeChangedSignal("FNABKWater"):Connect(refreshNeeds)
refreshNeeds()
ContextActionService:BindActionAtPriority("FNABKInventoryToggle", function(_, state)
	if UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if state == Enum.UserInputState.Begin then
		toggle()
	end
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.B)
sync:FireServer()
