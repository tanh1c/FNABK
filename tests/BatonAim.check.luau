-- In Studio Play's client command bar, equip the baton and face a live Mimic
-- within 7 studs with no wall between them. Do not point the mouse at it.
local player = game.Players.LocalPlayer
local mimic = workspace.FNABKGraybox.Mimic
local before = mimic:GetAttribute("MimicHealth")
assert(player.Character:FindFirstChild("Baton"), "Equip the baton first")
assert(typeof(before) == "number" and before > 0, "Mimic must be alive")
game.ReplicatedStorage.FNABKRemotes.AttackRequest:FireServer()
task.wait(0.5)
assert(mimic:GetAttribute("MimicHealth") == before - 25, "Expected one close-range hit")
print("Baton forward targeting passed")
