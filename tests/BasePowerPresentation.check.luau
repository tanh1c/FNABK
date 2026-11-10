-- Studio Play server. Check server-owned power presentation without spending inventory (SURV-03/04).
local power = game.ReplicatedStorage.FNABKRoundState.BuildingPower:FindFirstChild("B4")
local point = workspace.FNABKGraybox:FindFirstChild("Power_B4")
assert(power and power:IsA("BoolValue") and point)
local light, prompt = point:FindFirstChild("RestoredLight"), point:FindFirstChild("RestorePower")
assert(light and light:IsA("PointLight") and prompt and prompt:IsA("ProximityPrompt"))
assert(not power.Value and not light.Enabled and prompt.Enabled)
power.Value = true
task.wait()
assert(light.Enabled and not prompt.Enabled)
power.Value = false
task.wait()
assert(not light.Enabled and prompt.Enabled)
return "Base power presentation checks passed"
