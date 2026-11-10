-- Studio Play server; creates and removes a temporary wave folder.
local map = Instance.new("Folder")
map.Name, map.Parent = "WaveTest", workspace
local events = Instance.new("BindableEvent")
local gunshot = Instance.new("BindableEvent")
local state = game.ReplicatedStorage.FNABKRoundState
local oldBase = state.ActiveBase.Value
state.ActiveBase.Value = "A1"
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, gunshot)
events:Fire("NightWave:2:1")
task.wait(3)
assert(#map.WaveAttackers:GetChildren() == 10)
local enemy = map.WaveAttackers:GetChildren()[1]
local shot = enemy.PrimaryPart.Position + Vector3.new(59, 0, 0)
gunshot:Fire(shot, 60)
task.wait()
assert(enemy:GetAttribute("HeardPosition") == shot)
local defeated = Instance.new("Model")
defeated:SetAttribute("NPCType", "Creature")
defeated:SetAttribute("EnemyState", "Defeated")
defeated.Parent = map.WaveAttackers
local visible = Instance.new("Part")
visible.Transparency = 0
visible.Anchored = true
visible.Parent = enemy
enemy:PivotTo(CFrame.new(0, 1000, 0))
enemy:SetAttribute("RetreatDestination", Vector3.new(10, 1000, 0))
local blocked = map.WaveAttackers:GetChildren()[2]
blocked:PivotTo(CFrame.new(0, 1002, 30))
blocked:SetAttribute("RetreatDestination", Vector3.new(20, 1002, 30))
local floor = Instance.new("Part")
floor.Size, floor.CFrame, floor.Anchored = Vector3.new(80, 1, 80), CFrame.new(10, 999.5, 30), true
floor.Parent = workspace
local wall = Instance.new("Part")
wall.Size, wall.CFrame, wall.Anchored = Vector3.new(1, 10, 8), CFrame.new(5, 1002, 30), true
wall.Parent = workspace
events:Fire("Retreat:1")
task.wait(0.6)
assert(defeated:GetAttribute("EnemyState") == "Defeated")
assert(enemy:GetAttribute("EnemyState") == "Retreat" or enemy:GetAttribute("MimicState") == "Retreat")
assert(enemy.PrimaryPart.Position.X > 0)
assert(blocked.PrimaryPart.Position.X < 5)
task.wait(1)
assert(visible.Transparency > 0 and visible.Transparency < 1)
defeated:Destroy()
task.wait(3)
assert(blocked.Parent and blocked.PrimaryPart.Position.X > 5, "attacker did not route around wall")
wall:Destroy()
floor:Destroy()
task.wait(4)
assert(enemy.Parent == nil)
state.ActiveBase.Value = oldBase
events:Destroy()
gunshot:Destroy()
map:Destroy()
print("Prototype wave spawn/retreat check passed")
