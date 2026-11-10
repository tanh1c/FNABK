-- Studio Play server; checks one direct route from A2's center-facing entrance. SURV-01.
local player = game.Players:GetPlayers()[1]
local character = assert(player and player.Character)
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")
assert(humanoid and humanoid.Health > 0)
local original = character:GetPivot()
local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.A2
local door = building.CenterFacingEntrance_v1.MainEntryDoor
local floor
for _, part in ipairs(building:GetDescendants()) do
	if part:IsA("BasePart") and part.Name == "WalkableFloor_01" then floor = part; break end
end
assert(floor)
local target = (floor.CFrame * CFrame.new(4, floor.Size.Y / 2 + 3, 0)).Position
local start = Vector3.new(door.Position.X + 6, target.Y, door.Position.Z - 2)
character:PivotTo(CFrame.new(start))
task.wait(.4)
humanoid:MoveTo(target)
task.wait(10)
local distance = (root.Position - target).Magnitude
character:PivotTo(original)
assert(distance < 6, "A2 entrance route failed; remaining distance " .. distance)
return "A2 center-facing entrance route passed; other routes remain untested"
