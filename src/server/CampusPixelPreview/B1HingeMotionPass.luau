-- Solve the local hinge pivot from the existing closed and open CFrames.
local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
local overlaps = OverlapParams.new(); overlaps.FilterType = Enum.RaycastFilterType.Include; overlaps.FilterDescendantsInstances = {building}
local plans = {}
for _, door in ipairs(building:GetDescendants()) do
 if door:IsA("BasePart") and door:GetAttribute("CampusDoor") and not door:GetAttribute("SwingHingeOffset_v1") and not door:GetAttribute("DoorClosedSize_v1") then
  local closed, opened = door:GetAttribute("DoorClosed"), door:GetAttribute("DoorOpen")
  local relative = closed:ToObjectSpace(opened)
  local p = relative.Position
  local _, _, _, r00, _, r02, _, _, _, r20, _, r22 = relative:GetComponents()
  local a, b, c, d = 1-r00, -r02, -r20, 1-r22
  local determinant = a*d-b*c
  local axis, angle = relative.Rotation:ToAxisAngle()
  assert(math.abs(determinant) > .00001 and math.abs(axis.Y) > .99)
  local offset = Vector3.new((p.X*d-b*p.Z)/determinant, 0, (a*p.Z-p.X*c)/determinant)
  angle *= math.sign(axis.Y)
  assert(offset.Magnitude < math.max(door.Size.X, door.Size.Z)/2 + .4)
  local shape = Vector3.new(math.max(.01,door.Size.X-.12),math.max(.01,door.Size.Y-.35),math.max(.01,door.Size.Z-.12))
  for i = 1, 6 do
   local pose = closed * CFrame.new(offset) * CFrame.Angles(0, angle*i/6, 0) * CFrame.new(-offset)
   if i == 6 then assert((pose.Position-opened.Position).Magnitude < .05) end
   for _, part in ipairs(workspace:GetPartBoundsInBox(pose, shape, overlaps)) do
    assert(part == door or not part.CanCollide or part:GetAttribute("CampusDoor") or part.Name:match("^WalkableFloor") or part.Name:match("^HallRunner"), "B1 hinge path blocked: " .. door:GetFullName())
   end
  end
  table.insert(plans, {door, offset, angle})
 end
end
assert(#plans == 70, "Unexpected B1 door count; no changes: " .. #plans)
for _, plan in ipairs(plans) do
 plan[1]:SetAttribute("SwingHingeOffset_v1", plan[2])
 plan[1]:SetAttribute("SwingAngle_v1", plan[3])
 plan[1]:SetAttribute("FixedHingeMotion_v1", true)
end
return "Configured hinge motion for 70 B1 doors without changing endpoints"
