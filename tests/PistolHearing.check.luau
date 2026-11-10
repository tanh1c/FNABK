-- Studio client: equip a loaded pistol; place idle Mimic within 60 studs behind a wall.
local player = game.Players.LocalPlayer
local gun = player.Character:FindFirstChild("Pistol")
local mimic = workspace.FNABKGraybox.Mimic
assert(gun and (gun:GetAttribute("Loaded") or 0) > 0, "Equip a loaded pistol")
local origin = player.Character.HumanoidRootPart.Position
game.ReplicatedStorage.FNABKRemotes.PistolRequest:FireServer("Fire", Vector3.new(0, 1, 0))
task.wait(0.3)
local heard = mimic:GetAttribute("MimicLastKnownPosition")
assert(typeof(heard) == "Vector3" and (heard - origin).Magnitude < 2, "Mimic did not hear the shot")
print("Pistol hearing check passed")
