--!strict
-- Provisional group result display (SURV-11); the server supplies the roster.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local state = ReplicatedStorage:WaitForChild("FNABKRoundState")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "FNABKRescueResults", false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name, label.AnchorPoint = "Results", Vector2.new(.5, .5)
label.Position, label.Size = UDim2.fromScale(.5, .5), UDim2.new(.8, 0, 0, 180)
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(440, 180)
constraint.Parent = label
label.BackgroundColor3, label.TextColor3 = Color3.fromRGB(30, 34, 36), Color3.fromRGB(240, 238, 226)
label.Font, label.TextSize, label.TextWrapped = Enum.Font.Gotham, 18, true
label.Visible, label.Parent = false, gui
local function show(folder: Instance)
	if folder.Name ~= "RescueResults" or not folder:IsA("Folder") then return end
	local function refresh()
		local rows = {}
		for _, entry in ipairs(folder:GetChildren()) do
			if entry:IsA("StringValue") then
				local name = entry:GetAttribute("DisplayName")
				if typeof(name) == "string" then
					local outcome = if entry.Value == "LeftBehind" then "Left behind" else entry.Value
					table.insert(rows, name .. " — " .. outcome)
				end
			end
		end
		table.sort(rows)
		label.Text = (if folder:GetAttribute("GroupRescued") == true then "GROUP RESCUE" else "NO ONE RESCUED") .. "\n\n" .. table.concat(rows, "\n")
		label.Visible = true
	end
	local function watch(entry: Instance)
		entry:GetAttributeChangedSignal("DisplayName"):Connect(refresh)
		if entry:IsA("StringValue") then entry.Changed:Connect(refresh) end
		refresh()
	end
	folder.ChildAdded:Connect(watch)
	folder.ChildRemoved:Connect(refresh)
	folder:GetAttributeChangedSignal("GroupRescued"):Connect(refresh)
	for _, entry in ipairs(folder:GetChildren()) do watch(entry) end
	refresh()
end
state.ChildAdded:Connect(show)
local existing = state:FindFirstChild("RescueResults")
if existing then show(existing) end
