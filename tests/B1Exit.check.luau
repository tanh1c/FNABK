-- Studio Play server: run after opening B1's right main door. SURV-03/04.
local player = game.Players:GetPlayers()[1]
local character = assert(player.Character)
local humanoid, root = character:FindFirstChildOfClass("Humanoid"), character:WaitForChild("HumanoidRootPart")
assert(humanoid and root:IsA("BasePart"))
local door = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1.B1_MainEntryDoors_v1.MainDoorRight
assert(not door.CanCollide, "open the right door first")
local closed = door:GetAttribute("DoorClosed")
assert(typeof(closed) == "CFrame")
local barrier = workspace.FNABKGraybox.B1Barricade
local wasCollidable, transparency, original = barrier.CanCollide, barrier.Transparency, character:GetPivot()
barrier.CanCollide, barrier.Transparency = true, .15 -- temporary route probe
local a = closed.Position + Vector3.new(0, -1.9, 8)
local b = closed.Position + Vector3.new(0, -1.9, -8)
character:PivotTo(CFrame.new(a)); task.wait(.3); humanoid:MoveTo(b); task.wait(5)
local outward = (root.Position - b).Magnitude
character:PivotTo(CFrame.new(b)); task.wait(.3); humanoid:MoveTo(a); task.wait(5)
local inward = (root.Position - a).Magnitude
barrier.CanCollide, barrier.Transparency = wasCollidable, transparency
character:PivotTo(original)
assert(outward < 3 and inward < 3, "B1 route blocked: " .. outward .. ", " .. inward)
return "B1 exit route passed"
