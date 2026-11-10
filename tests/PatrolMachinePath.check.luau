-- Studio Play server: isolated obstacle and synthetic sound, SURV-07.
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local original = character:GetPivot()
character:PivotTo(CFrame.new(0, 1003, 100))
local map, shot, notice, status = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("RemoteEvent"), Instance.new("StringValue")
map.Parent, status.Value = workspace, "Running"
local floor = Instance.new("Part")
floor.Anchored, floor.Size, floor.Position, floor.Parent = true, Vector3.new(150, 1, 150), Vector3.new(0, 999.5, 0), map
local wall = Instance.new("Part")
wall.Anchored, wall.Size, wall.Position, wall.Parent = true, Vector3.new(1, 8, 12), Vector3.new(10, 1004, 0), map
task.wait(2)
local machine = require(game.ServerScriptService.FNABKServer.PatrolMachine).Start(map, Vector3.new(0, 1002, 0), function() return nil end, shot, notice, status)
shot:Fire(Vector3.new(25, 1002, 0), 60)
task.wait(5)
local final = machine.PrimaryPart.Position
machine:Destroy(); character:PivotTo(original); map:Destroy(); shot:Destroy(); notice:Destroy(); status:Destroy()
assert(final.X > 11, "machine did not navigate around wall: " .. tostring(final))
return "Patrol machine obstacle check passed"
