-- Run on a fresh Studio Play server (SURV-11).
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local original = character:GetPivot()
local round = game.ReplicatedStorage.FNABKRoundState
local phase = Instance.new("StringValue")
phase.Value, phase.Parent = "Boarding", workspace
local success
local depart, isAboard = require(game.ServerScriptService.FNABKServer.HelicopterService).Start(
	workspace.FNABK_Campus_PixelBuildings_PhaseC_v6, phase, function(value) success = value end)
local pad = assert(workspace:FindFirstChild("FNABKHelicopterBoarding"))
character:PivotTo(pad.CFrame * CFrame.new(0, 3, 0))
local root = character:FindFirstChild("HumanoidRootPart")
-- Query this service's roster: another running service can write FNABKAboard.
assert(isAboard(player), "player failed to board; offset=" .. tostring(root and pad.CFrame:PointToObjectSpace(root.Position)))
player:SetAttribute("FNABKDowned", true)
depart()
assert(success == true and player:GetAttribute("FNABKRescueResult") == "Rescued",
	"already-boarded downed player not rescued; result=" .. tostring(player:GetAttribute("FNABKRescueResult"))
	.. " offset=" .. tostring(root and pad.CFrame:PointToObjectSpace(root.Position)))
local first = assert(round:FindFirstChild("RescueResults"))
first:Destroy()
phase:Destroy(); pad:Destroy()
player:SetAttribute("FNABKDowned", false)
local phase2 = Instance.new("StringValue")
phase2.Value, phase2.Parent = "Boarding", workspace
local success2
local depart2 = require(game.ServerScriptService.FNABKServer.HelicopterService).Start(
	workspace.FNABK_Campus_PixelBuildings_PhaseC_v6, phase2, function(value) success2 = value end)
local pad2 = assert(workspace:FindFirstChild("FNABKHelicopterBoarding"))
character:PivotTo(pad2.CFrame * CFrame.new(0, 3, 0))
player:SetAttribute("FNABKEliminated", true)
depart2()
assert(success2 == false and player:GetAttribute("FNABKRescueResult") == "Eliminated", "eliminated player rescued")
local results = assert(round:FindFirstChild("RescueResults"))
assert(results:FindFirstChild(tostring(player.UserId)).Value == "Eliminated")
player:SetAttribute("FNABKEliminated", false)
player:SetAttribute("FNABKRescueResult", nil)
character:PivotTo(original)
results:Destroy(); phase2:Destroy(); pad2:Destroy()
return "Helicopter life result checks passed"
