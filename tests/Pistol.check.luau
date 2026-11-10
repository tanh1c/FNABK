-- Studio client command bar: collect pistol ammo and pistol, equip pistol, face a test Mimic.
local p = game.Players.LocalPlayer
local tool = p.Character:FindFirstChild("Pistol")
assert(tool and tool:GetAttribute("Loaded") == 0, "Equip an empty pistol")
local target = workspace.FNABKGraybox:FindFirstChild("PistolTarget")
assert(target and target:GetAttribute("MimicHealth") == 75, "Place a 75-HP target ahead")
local request = game.ReplicatedStorage.FNABKRemotes.PistolRequest
request:FireServer("Reload")
task.wait(2.5)
assert(tool:GetAttribute("Loaded") == 12, "Reload should load 12 rounds")
request:FireServer("Fire", Vector3.new(0, 0, -1))
task.wait(0.5)
assert(tool:GetAttribute("Loaded") == 11 and target:GetAttribute("MimicHealth") == 50, "Shot should consume one round and deal 25 HP")
print("Pistol check passed")
