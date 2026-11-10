-- Fit the raised word to the short grounded viewing distance without distorting its glyphs.
local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
local sign = building.CanteenRearLetters_v1
assert(not sign:GetAttribute("PedestrianFit_v1"))
local wall = building.Canteen.WalkableStructure.OuterWall_Floor_02_North
local center = sign:GetBoundingBox()
local target = center + Vector3.new(0, -4, 0)
local sample = wall.Position - wall.CFrame.LookVector * 12.7
local eye = Vector3.new(sample.X, 3, sample.Z)
local floor = workspace:Raycast(eye, Vector3.new(0, -5, 0))
assert(floor and floor.Instance.CanCollide, "No ground at viewing point")
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Exclude
ray.FilterDescendantsInstances = {sign}
local plans = {}
for _, part in ipairs(sign:GetChildren()) do
 assert(part:IsA("BasePart") and part.Name == "RaisedLetterStroke" and not part:GetAttribute("BeforePedestrianFitFrame_v1"))
 local localPos = center:PointToObjectSpace(part.Position)
 local nextPos = target:PointToWorldSpace(Vector3.new(localPos.X * .65, localPos.Y * .65, localPos.Z))
 local hit = workspace:Raycast(eye, (nextPos - eye) * .98, ray)
 assert(not hit or hit.Instance.Transparency >= .9, "Pedestrian view blocked")
 table.insert(plans, {part = part, position = nextPos})
end
assert(#plans == 70)
for _, plan in ipairs(plans) do
 local part = plan.part
 part:SetAttribute("BeforePedestrianFitFrame_v1", part.CFrame)
 part:SetAttribute("BeforePedestrianFitSize_v1", part.Size)
 part.CFrame = part.CFrame + (plan.position - part.Position)
 part.Size = Vector3.new(part.Size.X * .65, part.Size.Y * .65, part.Size.Z)
end
sign:SetAttribute("PedestrianFit_v1", true)
return "Fitted Canteen rear letters to a grounded viewing point"
