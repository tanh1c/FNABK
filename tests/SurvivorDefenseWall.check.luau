-- Run in a fresh solo Studio Play server (SURV-13).
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local original, anchored = character:GetPivot(), root.Anchored
local floor = Instance.new("Part")
floor.Size, floor.Position, floor.Anchored, floor.Parent = Vector3.new(40, 1, 40), Vector3.new(0, 999.5, 0), true, workspace
local student = Instance.new("Model")
local body = Instance.new("Part")
body.Size, body.Position, body.Anchored, body.Parent = Vector3.new(2, 4, 2), Vector3.new(0, 1003, 0), true, student
student.PrimaryPart, student.Parent = body, workspace
student:SetAttribute("NPCType", "Student")
character:PivotTo(CFrame.new(4, 1003, 0)); root.Anchored = true
local wall = Instance.new("Part")
wall.Size, wall.Position, wall.Anchored, wall.Parent = Vector3.new(.5, 8, 8), Vector3.new(2, 1003, 0), true, workspace
local hits = 0
require(game.ServerScriptService.FNABKServer.SurvivorDefense).attacked(student, player, function(_, damage) assert(damage == 5); hits += 1; return nil end)
task.wait(.5)
assert(hits == 0, "survivor attacked through wall")
wall:Destroy()
task.wait(.6)
assert(hits == 1, "survivor did not retaliate with clear sight")
student:Destroy(); floor:Destroy()
character:PivotTo(original); root.Anchored = anchored
return "Survivor defense wall check passed"
