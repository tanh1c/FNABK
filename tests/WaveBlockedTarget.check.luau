-- Studio Play server: isolated platform and wall; player and enemy are teleported for this check.
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local character = player.Character
local playerRoot = character:WaitForChild("HumanoidRootPart")
local original = character:GetPivot()
local wasAnchored = playerRoot.Anchored
local state = game.ReplicatedStorage.FNABKRoundState
local oldBase = state.ActiveBase.Value
local map, events, gunshot = Instance.new("Folder"), Instance.new("BindableEvent"), Instance.new("BindableEvent")
map.Parent = workspace
state.ActiveBase.Value = "A1"
local hits = 0
local enemy: Model? = nil
local wall: Part? = nil
local floor = Instance.new("Part")
floor.Size, floor.CFrame, floor.Anchored, floor.Parent = Vector3.new(80, 1, 80), CFrame.new(0, 999.5, 0), true, workspace
character:PivotTo(CFrame.new(1.8, 1003, 0))
playerRoot.Anchored = true
task.wait(1)
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function()
	if not enemy or not enemy.PrimaryPart or not wall then return nil end
	local params = RaycastParams.new()
	params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { enemy, character }
	local hit = workspace:Raycast(enemy.PrimaryPart.Position, character.HumanoidRootPart.Position - enemy.PrimaryPart.Position, params)
	if hit and hit.Instance == wall then hits += 1 end
	return nil
end, gunshot)
events:Fire("NightWave:2:1")
task.wait(.7)
for _, candidate in ipairs(map.WaveAttackers:GetChildren()) do if candidate:GetAttribute("NPCType") == "Creature" then enemy = candidate; break end end
assert(enemy and enemy:IsA("Model") and enemy.PrimaryPart)
enemy:PivotTo(CFrame.new(-1.8, 1002.5, 0))
task.wait(.3)
assert(enemy:GetAttribute("WaveTargetUserId") == player.UserId, "visible player was not acquired")
wall = Instance.new("Part")
wall.Size, wall.CFrame, wall.Anchored, wall.Parent = Vector3.new(.5, 10, 4), CFrame.new(0, 1003, 0), true, workspace
hits = 0
local start = enemy.PrimaryPart.Position
task.wait(.2)
assert(hits == 0, "attacked through wall")
task.wait(8)
assert((enemy.PrimaryPart.Position - start).Magnitude > .1, "enemy failed to attempt a path around nearby wall")
local params = RaycastParams.new()
params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, { enemy, character }
local hit = workspace:Raycast(enemy.PrimaryPart.Position, playerRoot.Position - enemy.PrimaryPart.Position, params)
assert(not hit, "enemy did not reach a clear route to target")
assert(hits == 0, "attack was recorded with the test wall blocking sight")
state.ActiveBase.Value = oldBase
character:PivotTo(original)
playerRoot.Anchored = wasAnchored
map:Destroy(); events:Destroy(); gunshot:Destroy(); wall:Destroy(); floor:Destroy()
return "Blocked close target path check passed"
