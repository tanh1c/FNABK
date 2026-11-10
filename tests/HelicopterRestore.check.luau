-- Controlled Studio Play server; separate helicopter service (SURV-10/11).
local service = require(game.ServerScriptService.FNABKServer.HelicopterService)
local player = assert(game.Players:GetPlayers()[1])
local character = assert(player.Character)
local original = character:GetPivot()
local phase = Instance.new("StringValue")
phase.Value, phase.Parent = "Boarding", workspace
local campus = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local bad = { version = 1, members = { { userId = player.UserId, name = "Test", aboard = true }, { userId = player.UserId, name = "Test", aboard = true } } }
assert(not pcall(function() service.Start(campus, phase, function() end, bad) end))
local saved = { version = 1, members = {
	{ userId = player.UserId, name = player.DisplayName, aboard = true },
	{ userId = -987654321, name = "Absent", aboard = true },
} }
local success
local depart, isAboard, snapshot, restore = service.Start(campus, phase, function(value) success = value end, saved)
local before = assert(snapshot())
assert(#before.members == 2)
assert(restore(player) and isAboard(player) and not restore(player))
depart()
assert(success == true and player:GetAttribute("FNABKRescueResult") == "Rescued")
local results = game.ReplicatedStorage.FNABKRoundState:FindFirstChild("RescueResults")
assert(results and results:FindFirstChild("-987654321").Value == "Disconnected")
character:PivotTo(original)
player:SetAttribute("FNABKRescueResult", nil)
results:Destroy(); phase:Destroy()
return "Helicopter restore checks passed"
