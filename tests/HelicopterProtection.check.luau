-- Studio Play server, fresh solo session. Uses separate temporary services and pad.
local player = game.Players:GetPlayers()[1]
assert(player and player.Character)
local character = player.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")
assert(humanoid and character:FindFirstChild("HumanoidRootPart"))
for _, child in ipairs(character:GetChildren()) do if child:IsA("ForceField") then child:Destroy() end end
player:SetAttribute("FNABKImmuneUntil", nil)
local phase = Instance.new("StringValue")
phase.Value, phase.Parent = "Boarding", workspace
local _, isAboard = require(game.ServerScriptService.FNABKServer.HelicopterService).Start(
	workspace.FNABK_Campus_PixelBuildings_PhaseC_v6, phase, function() end)
local life = require(game.ServerScriptService.FNABKServer.PlayerLifeService).Start(
	require(game.ReplicatedStorage.FNABKShared.GameConfig), function() end, isAboard)
local pad = workspace:FindFirstChild("FNABKHelicopterBoarding")
assert(pad and pad:IsA("BasePart"))
character:PivotTo(pad.CFrame * CFrame.new(0, 3, 0))
humanoid.Health = 80
life.ApplyDamage(player, 10, true)
life.ApplyDamage(player, 1, false)
assert(humanoid.Health == 80, "aboard player took damage")
assert(player:GetAttribute("FNABKAboard") == true)
character:PivotTo(pad.CFrame * CFrame.new(0, 3, 40))
life.ApplyDamage(player, 10, true)
assert(humanoid.Health == 70, "player remained protected after leaving")
assert(player:GetAttribute("FNABKAboard") == false)
phase:Destroy()
pad:Destroy()
return "Helicopter protection check passed"
