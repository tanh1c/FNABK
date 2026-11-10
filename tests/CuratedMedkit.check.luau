-- Run in the Studio client command bar in Play mode while near the B4 kit
-- and after setting the player's Humanoid.Health to 50 on the server.
local player = game.Players.LocalPlayer
local kit = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.CuratedUserProps_20261104.MedicalKit
local prompt = kit.MedkitPickupAnchor.ProximityPrompt
prompt:InputHoldBegin()
task.wait(0.25)
prompt:InputHoldEnd()
task.wait(0.5)
assert(player:GetAttribute("FNABKHasMedkit") == true, "Pickup failed")
assert(not kit.Parent, "Pickup did not remove its visual")
game.ReplicatedStorage.FNABKRemotes.MedkitRequest:FireServer()
task.wait(0.5)
assert(player:GetAttribute("FNABKHasMedkit") == false, "Medkit was not consumed")
assert(player.Character.Humanoid.Health >= 90, "Expected at least 40 HP healing")
print("Curated medkit pickup and healing passed")
