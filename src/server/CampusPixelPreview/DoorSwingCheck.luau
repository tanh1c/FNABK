-- Edit-mode check of repaired swing poses and five intermediate hinge positions.
local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local checked = 0
for _, building in ipairs(buildings:GetChildren()) do
 local params = OverlapParams.new()
 params.FilterType = Enum.RaycastFilterType.Include
 params.FilterDescendantsInstances = {building}
 for _, door in ipairs(building:GetDescendants()) do
  if door:IsA("BasePart") and door:GetAttribute("SwingHingeOffset_v1") then
   local closed, opened = door:GetAttribute("DoorClosed"), door:GetAttribute("DoorOpen")
   local offset, angle = door:GetAttribute("SwingHingeOffset_v1"), door:GetAttribute("SwingAngle_v1")
   assert(typeof(offset) == "Vector3" and typeof(angle) == "number")
   local size = door.Size
   size = Vector3.new(math.max(.01,size.X-.12),math.max(.01,size.Y-.35),math.max(.01,size.Z-.12))
   for i = 1, 6 do
    local pose = closed*CFrame.new(offset)*CFrame.Angles(0,angle*i/6,0)*CFrame.new(-offset)
    if i == 6 then assert((pose.Position-opened.Position).Magnitude < .1) end
    for _, part in ipairs(workspace:GetPartBoundsInBox(pose,size,params)) do
     assert(part == door or not part.CanCollide or part:GetAttribute("CampusDoor") or part.Name:match("^WalkableFloor") or part.Name:match("^HallRunner"),door:GetFullName().." intersects "..part:GetFullName())
    end
   end
   checked += 1
  end
 end
 task.wait()
end
assert(checked == 857)
return "857 hinge doors: endpoint and five intermediate positions checked"
