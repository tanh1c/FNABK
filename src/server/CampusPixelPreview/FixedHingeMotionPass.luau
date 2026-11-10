-- Preserve existing endpoints while replacing linear CFrame interpolation with hinge motion.
local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local plans = {}
for _, building in ipairs(buildings:GetChildren()) do
 local overlap = OverlapParams.new(); overlap.FilterType = Enum.RaycastFilterType.Include; overlap.FilterDescendantsInstances = {building}
 for _, door in ipairs(building:GetDescendants()) do
  if door:IsA("BasePart") and door:GetAttribute("CampusDoor") and not door:GetAttribute("SwingHingeOffset_v1") and not door:GetAttribute("DoorClosedSize_v1") then
   local closed, opened = door:GetAttribute("DoorClosed"), door:GetAttribute("DoorOpen")
   local size = door.Size
   local xAxis = size.X > size.Z
   local half = (xAxis and size.X or size.Z) / 2
   local found
   for _, side in ipairs({-1, 1}) do for _, angle in ipairs({-math.pi/2, math.pi/2}) do
    local offset = xAxis and Vector3.new(side*half, 0, 0) or Vector3.new(0, 0, side*half)
    local endpoint = closed * CFrame.new(offset) * CFrame.Angles(0, angle, 0) * CFrame.new(-offset)
    local _, rotationError = endpoint.Rotation:ToObjectSpace(opened.Rotation):ToAxisAngle()
    if (endpoint.Position - opened.Position).Magnitude < .1 and math.abs(rotationError) < .02 then found = {offset, angle} end
   end end
   if found then
    local shape = Vector3.new(math.max(.01, size.X-.12), math.max(.01, size.Y-.35), math.max(.01, size.Z-.12))
    for i = 1, 6 do
     local pose = closed * CFrame.new(found[1]) * CFrame.Angles(0, found[2]*i/6, 0) * CFrame.new(-found[1])
     for _, part in ipairs(workspace:GetPartBoundsInBox(pose, shape, overlap)) do
      assert(part == door or not part.CanCollide or part:GetAttribute("CampusDoor") or part.Name:match("^WalkableFloor") or part.Name:match("^HallRunner"), "Hinge path blocked: " .. door:GetFullName())
     end
    end
    table.insert(plans, {door, found[1], found[2]})
   end
  end
 end
 task.wait()
end
assert(#plans == 585, "Unexpected matching doors; no changes: " .. #plans)
for _, plan in ipairs(plans) do
 plan[1]:SetAttribute("SwingHingeOffset_v1", plan[2])
 plan[1]:SetAttribute("SwingAngle_v1", plan[3])
 plan[1]:SetAttribute("FixedHingeMotion_v1", true)
end
return "Configured hinge motion for 585 doors without changing endpoints"
