local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
local sign = building.CanteenRearLetters_v1
local source = building.RaisedBuildingID_v1
local wall = building.Canteen.WalkableStructure.OuterWall_Floor_02_North
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = {sign, source}
local count = 0
assert(sign:GetAttribute("PedestrianFit_v1"))
local view = wall.Position - wall.CFrame.LookVector * 12.7
local eye = Vector3.new(view.X, 3, view.Z)
assert(workspace:Raycast(eye, Vector3.new(0, -5, 0)), "Viewing point lacks ground")
for _, letter in ipairs(sign:GetChildren()) do
 assert(letter:IsA("BasePart") and letter.Name == "RaisedLetterStroke" and not letter.CanCollide)
 assert(letter.Color == Color3.fromRGB(28, 58, 78))
 assert(letter:GetAttribute("BeforePedestrianFitFrame_v1") and letter:GetAttribute("BeforePedestrianFitSize_v1"))
 local localPosition = wall.CFrame:PointToObjectSpace(letter.Position)
 assert(localPosition.Z > wall.Size.Z / 2 and localPosition.Z < 2)
 for _, distance in ipairs({5, 10, 15}) do
  local hit = workspace:Raycast(letter.Position - letter.CFrame.LookVector * distance, letter.CFrame.LookVector * (distance - .3), params)
  assert(not hit or hit.Instance.Transparency >= .9)
 end
 local viewHit = workspace:Raycast(eye, (letter.Position - eye) * .98, params)
 assert(not viewHit or viewHit.Instance.Transparency >= .9, "Pedestrian sightline blocked")
 count += 1
end
assert(count == 70)
return "Canteen rear lettering is outside its wall and clear at 5, 10 and 15 studs"
