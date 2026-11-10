-- Studio Play server: isolated character/player state mismatch. SURV-08/11.
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local original = character:GetPivot()
local phase = Instance.new("StringValue")
phase.Value, phase.Parent = "Boarding", workspace
local success
local depart = require(game.ServerScriptService.FNABKServer.HelicopterService).Start(
	workspace.FNABK_Campus_PixelBuildings_PhaseC_v6, phase, function(value) success = value end)
local pad = assert(workspace:FindFirstChild("FNABKHelicopterBoarding"))
character:SetAttribute("FNABKDowned", true)
character:PivotTo(pad.CFrame * CFrame.new(0, 3, 0))
task.wait(.3)
assert(player:GetAttribute("FNABKAboard") == false, "downed character boarded")
character:SetAttribute("FNABKDowned", false)
task.wait(.3)
assert(player:GetAttribute("FNABKAboard") == true, "standing character failed to board")
character:SetAttribute("FNABKDowned", true)
task.wait(.3)
assert(player:GetAttribute("FNABKAboard") == true, "already-boarded downed character removed")
character:SetAttribute("FNABKDowned", false)
character:SetAttribute("FNABKEliminated", true)
depart()
assert(success == false and player:GetAttribute("FNABKRescueResult") == "Eliminated", "eliminated character was rescued")
character:SetAttribute("FNABKEliminated", false)
player:SetAttribute("FNABKRescueResult", nil)
character:PivotTo(original)
local results = game.ReplicatedStorage.FNABKRoundState:FindFirstChild("RescueResults")
if results then results:Destroy() end
phase:Destroy(); pad:Destroy()
return "Helicopter character state checks passed"
