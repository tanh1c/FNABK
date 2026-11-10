-- Studio Play server: synthetic shots; stationary isolated Mimics, not actual firearm input. SURV-07.
local controller = require(game.ServerScriptService.FNABKServer.MimicController)
local config = require(game.ReplicatedStorage.FNABKShared.GameConfig)
local function create()
	local model, root, shot = Instance.new("Model"), Instance.new("Part"), Instance.new("BindableEvent")
	root.Anchored, root.Position, root.Parent = true, Vector3.new(0, 1003, 0), model
	model.PrimaryPart, model.Parent = root, workspace
	controller.Start(model, config, function() return nil end, shot)
	return model, root, shot
end
local wall = Instance.new("Part")
wall.Anchored, wall.Size, wall.Position, wall.Parent = true, Vector3.new(1, 20, 20), Vector3.new(30, 1003, 0), workspace
for _, radius in ipairs({ 60, 100, 120 }) do
	local model, root, shot = create()
	local outside, boundary = root.Position + Vector3.new(radius + 1, 0, 0), root.Position + Vector3.new(radius, 0, 0)
	shot:Fire(outside, radius)
	task.wait(.05)
	assert(model:GetAttribute("MimicLastKnownPosition") == nil, "heard outside radius")
	shot:Fire(boundary, radius)
	task.wait(.05)
	assert(model:GetAttribute("MimicLastKnownPosition") == boundary and model:GetAttribute("MimicState") == "Suspicious", "missed shot at boundary")
	model:Destroy(); shot:Destroy()
end
local model, root, shot = create()
model:SetAttribute("MimicState", "Stunned")
model:SetAttribute("MimicStunnedUntil", os.clock() + 10)
shot:Fire(root.Position + Vector3.new(10, 0, 0), 60)
task.wait(.2)
assert(model:GetAttribute("MimicState") == "Stunned" and model:GetAttribute("MimicLastKnownPosition") == nil, "shot canceled stun")
model:Destroy(); shot:Destroy(); wall:Destroy()
return "Mimic hearing checks passed"
