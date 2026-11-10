-- Studio Play server: synthetic gunshots and static wave targets, no live gun firing.
local state = game.ReplicatedStorage:WaitForChild("FNABKRoundState")
assert(state:WaitForChild("RoundStatus", 20))
local map, events, gunshot = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent = workspace
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, gunshot)
local wall = Instance.new("Part")
wall.Size, wall.Position, wall.Anchored, wall.Parent = Vector3.new(1, 30, 30), Vector3.new(50, 1000, 0), true, workspace
local enemies = {}
for _, kind in ipairs({ "Creature", "Machine", "Mimic" }) do
	local enemy, root = Instance.new("Model"), Instance.new("Part")
	root.Anchored, root.Parent = true, enemy
	enemy.PrimaryPart = root
	enemy:SetAttribute("NPCType", kind)
	enemy:SetAttribute(if kind == "Mimic" then "MimicState" else "EnemyState", "Chase")
	enemy.Parent = map.WaveAttackers
	table.insert(enemies, enemy)
end
local origin = Vector3.new(0, 1000, 0)
for _, radius in ipairs({ 60, 100, 120 }) do
	for _, enemy in ipairs(enemies) do
		enemy.PrimaryPart.Position = origin + Vector3.new(radius, 0, 0)
		enemy:SetAttribute("HeardPosition", nil)
	end
	gunshot:Fire(origin, radius)
	task.wait()
	for _, enemy in ipairs(enemies) do assert(enemy:GetAttribute("HeardPosition") == origin, "within-radius shot missed") end
	for _, enemy in ipairs(enemies) do
		enemy.PrimaryPart.Position = origin + Vector3.new(radius + 1, 0, 0)
		enemy:SetAttribute("HeardPosition", nil)
	end
	gunshot:Fire(origin, radius)
	task.wait()
	for _, enemy in ipairs(enemies) do assert(enemy:GetAttribute("HeardPosition") == nil, "outside-radius shot heard") end
end
wall:Destroy(); map:Destroy(); events:Destroy(); gunshot:Destroy()
return "Wave hearing boundary checks passed"
