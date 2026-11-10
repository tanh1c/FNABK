-- Add a second raised ID where the narrow main-entry approach limits viewing distance.
local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
assert(not building:FindFirstChild("CanteenRearLetters_v1"))
local source = building.RaisedBuildingID_v1
local wall = building.Canteen.WalkableStructure.OuterWall_Floor_02_North
local oldPivot = source:GetPivot()
local position = wall.Position - wall.CFrame.LookVector * .7 + Vector3.new(0, 18 - wall.Position.Y, 0)
local target = CFrame.new(position) * wall.CFrame.Rotation
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Exclude
ray.FilterDescendantsInstances = {source}
local copies = {}
for _, part in ipairs(source:GetChildren()) do
 if part:IsA("BasePart") and part.Name == "RaisedLetterStroke" then
  local frame = target * oldPivot:ToObjectSpace(part.CFrame)
  for _, distance in ipairs({5, 10, 15}) do
   local hit = workspace:Raycast(frame.Position - frame.LookVector * distance, frame.LookVector * (distance - .3), ray)
   assert(not hit or hit.Instance.Transparency >= .9, "Rear letter view blocked: " .. (hit and hit.Instance:GetFullName() or "unknown"))
  end
  table.insert(copies, {part = part, frame = frame})
 end
end
assert(#copies == 70)
local output = Instance.new("Model")
output.Name = "CanteenRearLetters_v1"
for _, copy in ipairs(copies) do
 local letter = copy.part:Clone()
 letter.CFrame = copy.frame
 letter.Parent = output
end
output.Parent = building
return "Added 70 raised Canteen letter strokes on the rear wall"
