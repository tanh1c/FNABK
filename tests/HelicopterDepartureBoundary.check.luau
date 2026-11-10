-- Studio Play server: moving off the pad immediately before departure must count.
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local original = player.Character:GetPivot()
local phase = Instance.new("StringValue")
phase.Value, phase.Parent = "Boarding", workspace
local result: boolean? = nil
local depart = require(game.ServerScriptService.FNABKServer.HelicopterService).Start(
	workspace.FNABK_Campus_PixelBuildings_PhaseC_v6, phase, function(value) result = value end)
local pads = {}
for _, part in ipairs(workspace:GetChildren()) do if part.Name == "FNABKHelicopterBoarding" and part:IsA("BasePart") then table.insert(pads, part) end end
local pad = pads[#pads]
assert(pad)
player.Character:PivotTo(pad.CFrame * CFrame.new(0, 3, 0))
task.wait(.3)
assert(player:GetAttribute("FNABKAboard") == true)
player.Character:PivotTo(pad.CFrame * CFrame.new(0, 3, 40))
depart()
assert(result == false and player:GetAttribute("FNABKRescueResult") == "LeftBehind")
local results = game.ReplicatedStorage.FNABKRoundState:FindFirstChild("RescueResults")
local entry = results and results:FindFirstChild(tostring(player.UserId))
assert(results and results:GetAttribute("GroupRescued") == false)
assert(entry and entry:IsA("StringValue") and entry.Value == "LeftBehind" and entry:GetAttribute("DisplayName") == player.DisplayName)
player.Character:PivotTo(original)
player:SetAttribute("FNABKRescueResult", nil)
phase:Destroy()
pad:Destroy()
return "Helicopter departure boundary check passed"
