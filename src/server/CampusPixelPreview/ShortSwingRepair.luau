-- Open obstructed gallery doors 75 degrees where sampled hinge sweep is clear.
local bs = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local changes = {}
for _, b in ipairs(bs:GetChildren()) do
 local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={b}
 local function clear(d,cf)
  local s=d.Size
  s=Vector3.new(math.max(.01,s.X-.12),math.max(.01,s.Y-.35),math.max(.01,s.Z-.12))
  for _,v in ipairs(workspace:GetPartBoundsInBox(cf,s,p)) do
   if v~=d and v.CanCollide and not v:GetAttribute("CampusDoor") and not v.Name:match("^WalkableFloor") and not v.Name:match("^HallRunner") then return false end
  end
  return true
 end
 for _,d in ipairs(b:GetDescendants()) do
  if d:IsA("BasePart") and d.Name:match("^GalleryClassroomDoor") and d:GetAttribute("CampusDoor") and not d:GetAttribute("OriginalDoorOpen_v1") then
   local c,o=d:GetAttribute("DoorClosed"),d:GetAttribute("DoorOpen")
   if not clear(d,o) then
    local x=d.Size.X>d.Size.Z;local half=(x and d.Size.X or d.Size.Z)/2
    local best,off,sign=math.huge,nil,nil
    for _,side in ipairs({-1,1}) do
     local a=x and Vector3.new(side*half,0,0) or Vector3.new(0,0,side*half)
     for _,theta in ipairs({-math.pi/2,math.pi/2}) do
      local pose=c*CFrame.new(a)*CFrame.Angles(0,theta,0)*CFrame.new(-a)
      local dist=(pose.Position-o.Position).Magnitude
      if dist<best then best,off,sign=dist,a,math.sign(theta) end
     end
    end
    if best<.1 then
     for _,direction in ipairs({-sign,sign}) do
      local angle=direction*math.rad(75);local good=true
      for i=1,6 do
       if not clear(d,c*CFrame.new(off)*CFrame.Angles(0,angle*i/6,0)*CFrame.new(-off)) then good=false;break end
      end
      if good then table.insert(changes,{d,o,c*CFrame.new(off)*CFrame.Angles(0,angle,0)*CFrame.new(-off),off,angle});break end
     end
    end
   end
  end
 end
 task.wait()
end
assert(#changes==53,"Unexpected candidate count; nothing changed: "..#changes)
for _,v in ipairs(changes) do
 local d,old,new,off,angle=table.unpack(v)
 d:SetAttribute("OriginalDoorOpen_v1",old);d:SetAttribute("DoorOpen",new)
 d:SetAttribute("SwingHingeOffset_v1",off);d:SetAttribute("SwingAngle_v1",angle)
 if d:GetAttribute("StartsOpen") then d.CFrame=new end
end
return "53 doors adjusted to sampled clear 75-degree swings"
