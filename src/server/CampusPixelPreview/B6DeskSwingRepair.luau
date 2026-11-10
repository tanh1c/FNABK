-- Move only the extra desk/bench pairs that overlap sampled B6 door swings.
local b = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B6
assert(not b:FindFirstChild("B6DeskSwingRepair_v1"))
local doors, floors, walls = {}, {}, {}
for _, part in ipairs(b:GetDescendants()) do
 if part:IsA("BasePart") then
  if part:GetAttribute("SwingHingeOffset_v1") then table.insert(doors, part) end
  if part.CanCollide and part.Name:match("^WalkableFloor_") then table.insert(floors, part) end
  if part.CanCollide and (part.Name:find("Wall") or part.Name:find("Divider") or part.Name:find("Partition")) then table.insert(walls, part) end
 end
end
local proxy = Instance.new("Folder")
proxy.Name = "B6DoorSweepProbes"
local ok, result = xpcall(function()
 for _, door in ipairs(doors) do
  local closed, offset, angle = door:GetAttribute("DoorClosed"), door:GetAttribute("SwingHingeOffset_v1"), door:GetAttribute("SwingAngle_v1")
  for i = 1, 6 do
   local part = Instance.new("Part")
   part.Name = "Probe"
   part.Size = Vector3.new(math.max(.01, door.Size.X-.12), math.max(.01, door.Size.Y-.35), math.max(.01, door.Size.Z-.12))
   part.CFrame = closed * CFrame.new(offset) * CFrame.Angles(0, angle*i/6, 0) * CFrame.new(-offset)
   part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery, part.Transparency = true, false, false, true, 1
   part.Parent = proxy
  end
 end
 proxy.Parent = workspace
 local sweep = OverlapParams.new(); sweep.FilterType = Enum.RaycastFilterType.Include; sweep.FilterDescendantsInstances = {proxy}
 local overlaps = OverlapParams.new(); overlaps.FilterType = Enum.RaycastFilterType.Include; overlaps.FilterDescendantsInstances = {b}
 local floorRay = RaycastParams.new(); floorRay.FilterType = Enum.RaycastFilterType.Include; floorRay.FilterDescendantsInstances = floors; floorRay.RespectCanCollide = true
 local wallRay = RaycastParams.new(); wallRay.FilterType = Enum.RaycastFilterType.Include; wallRay.FilterDescendantsInstances = walls; wallRay.RespectCanCollide = true
 local plans = {}
 for _, folder in ipairs(b:GetDescendants()) do
  if folder.Name == "ExtraStudentFurniture_v1" then
   local desk, bench = folder:FindFirstChild("StudentDesk_Extra"), folder:FindFirstChild("StudentBench_Extra")
   if desk and bench and #workspace:GetPartBoundsInBox(desk.CFrame, desk.Size, sweep) > 0 then
    local found
    for radius = 1, 12 do
     for x = -radius, radius do for z = -radius, radius do
      if math.max(math.abs(x), math.abs(z)) == radius and not found then
       local delta = desk.CFrame.RightVector * (x*.5) + desk.CFrame.LookVector * (z*.5)
       local valid = true
       for _, item in ipairs({desk, bench}) do
        local frame = item.CFrame + delta
        if #workspace:GetPartBoundsInBox(frame, item.Size + Vector3.new(.15, -.1, .15), sweep) > 0 then valid = false end
        for _, other in ipairs(workspace:GetPartBoundsInBox(frame, item.Size + Vector3.new(.15, -.1, .15), overlaps)) do
         if other.CanCollide and not other:IsDescendantOf(folder) and not other:GetAttribute("CampusDoor") and not other.Name:match("^WalkableFloor") and not other.Name:match("^HallRunner") then valid = false end
        end
        for _, sx in ipairs({-.4, .4}) do for _, sz in ipairs({-.4, .4}) do
         local pt = frame:PointToWorldSpace(Vector3.new(sx*item.Size.X, 0, sz*item.Size.Z))
         local hit = workspace:Raycast(pt + Vector3.new(0, 2, 0), Vector3.new(0, -6, 0), floorRay)
         if not hit or math.abs(hit.Position.Y - (item.Position.Y-item.Size.Y/2)) > 1 then valid = false end
        end end
        local hit = workspace:Raycast(item.Position + Vector3.new(0, 2, 0), delta, wallRay)
        if hit and hit.Instance ~= desk and hit.Instance ~= bench and (hit.Instance.Name:find("Wall") or hit.Instance.Name:find("Divider") or hit.Instance.Name:find("Partition")) then valid = false end
       end
       if valid then found = delta end
      end
     end end
     if found then break end
     task.wait()
    end
    assert(found, "No safe position for " .. folder:GetFullName())
    table.insert(plans, {folder = folder, desk = desk, bench = bench, delta = found})
   end
  end
 end
 assert(#plans == 8, "Unexpected affected furniture count: " .. #plans)
 for _, plan in ipairs(plans) do
  for _, item in ipairs({plan.desk, plan.bench}) do
   item:SetAttribute("BeforeSwingRepair_v1", item.CFrame)
   item.CFrame += plan.delta
  end
 end
 local marker = Instance.new("Folder"); marker.Name = "B6DeskSwingRepair_v1"; marker.Parent = b
 return "Relocated " .. #plans .. " B6 desk/bench pairs away from door sweeps"
end, debug.traceback)
proxy:Destroy()
if not ok then error(result) end
return result
