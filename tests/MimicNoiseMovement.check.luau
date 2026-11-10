-- Studio server: synthetic shot and isolated flat floor, including the live Mimic's cloned rig.
local floor = Instance.new("Part")
floor.Anchored, floor.Size, floor.Position, floor.Parent = true, Vector3.new(150, 1, 150), Vector3.new(0, 999.5, 0), workspace
task.wait(3)
local model, root, shot = Instance.new("Model"), Instance.new("Part"), Instance.new("BindableEvent")
root.Anchored, root.Position, root.Parent = true, Vector3.new(0, 1003, 0), model
root.Size, root.CanCollide, root.CanQuery = Vector3.new(2, 5, 2), false, false
model.PrimaryPart, model.Parent = root, workspace
require(game.ServerScriptService.FNABKServer.MimicController).Start(model, require(game.ReplicatedStorage.FNABKShared.GameConfig), function() return nil end, shot)
local origin = root.Position
shot:Fire(origin + Vector3.new(40, 0, 0), 60)
task.wait(6)
local moved = (root.Position - origin).Magnitude
model:Destroy(); shot:Destroy()
assert(moved > 3, "Mimic did not move to investigate: " .. moved)
model = workspace.FNABKGraybox.Mimic:Clone()
model:SetAttribute("ControllerStarted", nil)
model:SetAttribute("MimicState", nil)
model.Parent = workspace
model:PivotTo(CFrame.new(0, 1003, 0))
shot = Instance.new("BindableEvent")
require(game.ServerScriptService.FNABKServer.MimicController).Start(model, require(game.ReplicatedStorage.FNABKShared.GameConfig), function() return nil end, shot)
root = model.PrimaryPart
origin = root.Position
shot:Fire(origin + Vector3.new(40, 0, 0), 60)
task.wait(6)
moved = (root.Position - origin).Magnitude
model:Destroy(); shot:Destroy(); floor:Destroy()
assert(moved > 3, "Live Mimic clone did not investigate: " .. moved)
return "Mimic noise movement check passed"
