-- One-time Edit-mode repair. Retains each original open pose as an attribute.
local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local changes = {}
for _, building in ipairs(buildings:GetChildren()) do
 local params = OverlapParams.new()
 params.FilterType = Enum.RaycastFilterType.Include
 params.FilterDescendantsInstances = {building}
 local function blocked(door, pose)
  local s = door.Size
  s = Vector3.new(math.max(.01, s.X-.12), math.max(.01, s.Y-.35), math.max(.01, s.Z-.12))
  for _, part in ipairs(workspace:GetPartBoundsInBox(pose, s, params)) do
   if part ~= door and part.CanCollide and not part:GetAttribute('CampusDoor') and not part.Name:match('^WalkableFloor') and not part.Name:match('^HallRunner') then return true end
  end
  return false
 end
 for _, door in ipairs(building:GetDescendants()) do
  if door:IsA('BasePart') and door:GetAttribute('CampusDoor') and not door:GetAttribute('OriginalDoorOpen_v1') then
   local closed, opened = door:GetAttribute('DoorClosed'), door:GetAttribute('DoorOpen')
   if blocked(door, opened) then
    local xAxis = door.Size.X > door.Size.Z
    local half = (xAxis and door.Size.X or door.Size.Z)/2
    local closest, alternate, hinge, swing = math.huge, nil, nil, nil
    for _, side in ipairs({-1, 1}) do
     local offset = xAxis and Vector3.new(side*half, 0, 0) or Vector3.new(0, 0, side*half)
     for _, angle in ipairs({-math.pi/2, math.pi/2}) do
      local candidate = closed*CFrame.new(offset)*CFrame.Angles(0, angle, 0)*CFrame.new(-offset)
      local distance = (candidate.Position-opened.Position).Magnitude
      if distance < closest then
       closest = distance
       alternate = closed*CFrame.new(offset)*CFrame.Angles(0, -angle, 0)*CFrame.new(-offset)
       hinge, swing = offset, -angle
      end
     end
    end
    if closest < .1 and not blocked(door, alternate) then table.insert(changes, {door, opened, alternate, hinge, swing}) end
   end
  end
 end
 task.wait()
end
assert(#changes == 149, 'Unexpected repair count; nothing changed: '..#changes)
for _, change in ipairs(changes) do
 local door, old, new, hinge, swing = table.unpack(change)
 door:SetAttribute('OriginalDoorOpen_v1', old)
 door:SetAttribute('DoorOpen', new)
 door:SetAttribute('SwingHingeOffset_v1', hinge)
 door:SetAttribute('SwingAngle_v1', swing)
 if door:GetAttribute('StartsOpen') then door.CFrame = new end
end
return 'Reoriented '..#changes..' doors; original poses retained'
