-- Studio Play server; moves one test player to a temporary landing pad.
local service = require(game.ServerScriptService.FNABKServer.HelicopterService)
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local previous = player.Character:GetPivot()
local phase = Instance.new("StringValue")
phase.Value, phase.Parent = "Boarding", workspace
local outcome: boolean? = nil
local depart = service.Start(workspace.FNABK_Campus_PixelBuildings_PhaseC_v6, phase, function(success) outcome = success end)
local pad = workspace:FindFirstChild("FNABKHelicopterBoarding")
assert(pad and pad:IsA("BasePart"))
local craft = workspace:FindFirstChild("FNABKRescueHelicopter")
assert(craft and craft:IsA("Model") and craft:FindFirstChild("RotorA") and craft:FindFirstChild("Cockpit"))
player.Character:PivotTo(pad.CFrame * CFrame.new(0, 3, 0))
task.wait(0.5)
assert(player:GetAttribute("FNABKAboard") == true)
depart()
assert(outcome == true and player:GetAttribute("FNABKRescueResult") == "Rescued")
assert(not craft.Parent)
player.Character:PivotTo(previous)
player:SetAttribute("FNABKAboard", false)
player:SetAttribute("FNABKRescueResult", nil)
phase:Destroy()
pad:Destroy()
return "Helicopter boarding and model check passed"
