-- Studio server: synthetic sound and round stop. Sight/acquisition needs separate real input tests. SURV-07.
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local original = character:GetPivot()
character:PivotTo(CFrame.new(0, 1003, 100))
local map, shot, notice, status = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("RemoteEvent"), Instance.new("StringValue")
map.Parent, status.Value = workspace, "Running"
local floor = Instance.new("Part")
floor.Anchored, floor.Size, floor.Position, floor.Parent = true, Vector3.new(150, 1, 150), Vector3.new(0, 999.5, 0), map
local hits = 0
local machine = require(game.ServerScriptService.FNABKServer.PatrolMachine).Start(map, Vector3.new(0, 1002, 0), function() hits += 1; return 100 end, shot, notice, status)
local lamp = machine.PrimaryPart:FindFirstChild("SensorLamp", true)
assert(lamp and lamp:IsA("SpotLight") and lamp.Angle == 60 and lamp.Range == 30)
local before = machine.PrimaryPart.Position
shot:Fire(before + Vector3.new(25, 0, 0), 60)
task.wait(1)
assert(machine:GetAttribute("EnemyState") == "Investigate" and machine.PrimaryPart.Position.X > before.X + 2)
status.Value = "Lost"
task.wait(.3)
assert(not machine.Parent and hits == 0)
character:PivotTo(original); map:Destroy(); shot:Destroy(); notice:Destroy(); status:Destroy()
return "Patrol machine checks passed"
