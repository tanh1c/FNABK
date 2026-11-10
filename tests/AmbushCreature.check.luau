-- Studio server: controlled hearing, wind-up, interruption and defeat. SURV-07.
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local original = character:GetPivot()
character:PivotTo(CFrame.new(0, 1003, 70))
local map, shot, notice = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("RemoteEvent")
map.Parent = workspace
local floor = Instance.new("Part")
floor.Anchored, floor.Size, floor.Position, floor.Parent = true, Vector3.new(120, 1, 120), Vector3.new(0, 999.5, 0), map
local hits = 0
local status = Instance.new("StringValue")
status.Value = "Running"
local enemy = require(game.ServerScriptService.FNABKServer.AmbushCreature).Start(map, Vector3.new(0, 1001.5, 0), function() hits += 1; return 100 end, shot, notice, status)
for _, part in ipairs(enemy:GetDescendants()) do
	if part:IsA("BasePart") and part ~= enemy.PrimaryPart then assert(not part.CanCollide and not part.CanQuery) end
end
task.wait(.5)
assert(enemy:GetAttribute("EnemyState") == "Hidden")
shot:Fire(Vector3.new(61, 1001.5, 0), 60)
task.wait(.2)
assert(enemy:GetAttribute("EnemyState") == "Hidden")
shot:Fire(Vector3.new(20, 1001.5, 0), 60)
task.wait(1)
assert(enemy:GetAttribute("EnemyState") == "Investigate" and enemy.PrimaryPart.Position.X > 3)
character:PivotTo(CFrame.new(enemy.PrimaryPart.Position + Vector3.new(0, 1.5, 2)))
shot:Fire(root.Position, 60)
task.wait(.5)
assert(hits == 0, "attack before wind-up")
local wall = Instance.new("Part")
wall.Anchored, wall.Size, wall.Position = true, Vector3.new(8, 8, .5), (root.Position + enemy.PrimaryPart.Position) / 2
wall.Parent = map
task.wait(1)
assert(hits == 0, "attack through wall")
wall:Destroy()
character:PivotTo(CFrame.new(0, 1003, 70))
task.wait(1)
assert(hits == 0, "attack after target left")
character:PivotTo(CFrame.new(enemy.PrimaryPart.Position + Vector3.new(0, 1.5, 2)))
shot:Fire(root.Position, 60)
task.wait(1.4)
assert(hits == 1, "expected one attack after warning")
enemy:SetAttribute("EnemyState", "Defeated")
task.wait(.3)
assert(not enemy.Parent)
enemy = require(game.ServerScriptService.FNABKServer.AmbushCreature).Start(map, Vector3.new(0, 1001.5, 0), function() hits += 1; return 100 end, shot, notice, status)
character:PivotTo(CFrame.new(0, 1003, 2))
shot:Fire(root.Position, 60)
task.wait(.3)
status.Value = "Lost"
local before = hits
task.wait(1.3)
assert(hits == before and not enemy.Parent, "creature remained active after loss")
character:PivotTo(original); map:Destroy(); shot:Destroy(); notice:Destroy(); status:Destroy()
return "Ambush creature checks passed"
