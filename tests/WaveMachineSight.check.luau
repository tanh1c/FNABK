-- Studio Play server, isolated machine sensing; SURV-07.
local player = game.Players:GetPlayers()[1]
local character = assert(player and player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local original, anchored = character:GetPivot(), root.Anchored
local round = game.ReplicatedStorage.FNABKRoundState
local oldBase = round.ActiveBase.Value
local point = workspace.FNABKBaseClaimPoints.A1
local oldPoint = point.CFrame
point.CFrame = CFrame.new(0, 1002, 0)
round.ActiveBase.Value = "A1"
local map, events, shots = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent = workspace
local floor = Instance.new("Part")
floor.Anchored, floor.Size, floor.Position, floor.Parent = true, Vector3.new(100, 1, 100), Vector3.new(0, 999.5, 0), workspace
character:PivotTo(CFrame.new(0, 1002, -20)); root.Anchored = true
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, shots)
task.wait(.2)
events:Fire("NightWave:2:1")
task.wait(.3)
local machine = map.WaveAttackers:GetChildren()[1]
assert(machine and machine:GetAttribute("NPCType") == "Machine" and machine.PrimaryPart)
local sensor = machine.PrimaryPart:FindFirstChild("SensorMount")
assert(sensor and sensor:IsA("Attachment") and sensor.Position.Z < -1)
local lamp = sensor:FindFirstChild("SensorLamp")
assert(lamp and lamp:IsA("SpotLight") and lamp.Enabled and lamp.Face == Enum.NormalId.Front and lamp.Angle == 60 and lamp.Range == 30)
machine:PivotTo(CFrame.lookAt(Vector3.new(0, 1002, 0), Vector3.new(0, 1002, -20)))
task.wait(.4)
assert(machine:GetAttribute("WaveTargetUserId") == 0, "machine acquired sight before one second")
task.wait(.9)
assert(machine:GetAttribute("WaveTargetUserId") == player.UserId, "machine failed to acquire sustained sight")
local wall = Instance.new("Part")
wall.Anchored, wall.Size, wall.Position, wall.Parent = true, Vector3.new(30, 15, 1), Vector3.new(0, 1002, -10), workspace
task.wait(.3)
assert(machine:GetAttribute("WaveTargetUserId") == 0, "machine tracked stationary player through wall")
shots:Fire(root.Position, 60)
task.wait()
assert(machine:GetAttribute("HeardPosition") == root.Position, "machine did not hear gunshot through wall")
round.ActiveBase.Value, point.CFrame = oldBase, oldPoint
character:PivotTo(original); root.Anchored = anchored
map:Destroy(); events:Destroy(); shots:Destroy(); floor:Destroy(); wall:Destroy()
return "Machine sight checks passed"
