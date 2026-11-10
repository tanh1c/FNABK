-- Studio Play server: separate temporary wave and fixed test player.
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local character, state = player.Character, game.ReplicatedStorage.FNABKRoundState
local root = character:WaitForChild("HumanoidRootPart")
local base = workspace.FNABKBaseClaimPoints.A1
local previous, anchored, oldBase, oldPoint = character:GetPivot(), root.Anchored, state.ActiveBase.Value, base.CFrame
local floor = Instance.new("Part")
floor.Size, floor.CFrame, floor.Anchored, floor.Parent = Vector3.new(80, 1, 80), CFrame.new(0, 999.5, 0), true, workspace
base.CFrame = CFrame.new(0, 1001, 0)
character:PivotTo(CFrame.new(1000, 1003, 0)); root.Anchored = true
local map, events, shots = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent, state.ActiveBase.Value = workspace, "A1"
local damage = {}
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function(_, value) table.insert(damage, value); return nil end, shots)
events:Fire("Wave:1")
task.wait(5.5)
local selected = {}
for _, enemy in ipairs(map.WaveAttackers:GetChildren()) do
	local kind = enemy:GetAttribute("NPCType")
	if not selected[kind] then selected[kind] = enemy end
end
for _, enemy in ipairs(map.WaveAttackers:GetChildren()) do
	if selected[enemy:GetAttribute("NPCType")] == enemy then enemy:PivotTo(CFrame.new(1000, 1003, 1000)) else enemy:Destroy() end
end
map.WaveAttackers.ChildAdded:Connect(function(enemy) enemy:Destroy() end)
character:PivotTo(CFrame.new(0, 1003, 0))
for kind, expected in pairs({ Creature = 15, Machine = 18, Mimic = 20 }) do
	local enemy = selected[kind]
	assert(enemy and enemy.PrimaryPart, "missing " .. kind)
	local before = #damage
	enemy:PivotTo(CFrame.lookAt(Vector3.new(3, 1003, 0), Vector3.new(0, 1003, 0)))
	local deadline = os.clock() + 5
	while #damage == before and os.clock() < deadline do task.wait(.1) end
	assert(damage[before + 1] == expected, "incorrect " .. kind .. " damage")
	enemy:Destroy()
end
state.ActiveBase.Value, base.CFrame = oldBase, oldPoint
character:PivotTo(previous); root.Anchored = anchored
map:Destroy(); events:Destroy(); shots:Destroy(); floor:Destroy()
return "Wave enemy damage checks passed"
