local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local plates,faces=0,0
for _,building in ipairs(buildings:GetChildren()) do
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={building};ray.RespectCanCollide=true
 for _,plate in ipairs(building:GetDescendants()) do
  if plate:IsA("BasePart") and (plate.Name=="ClassroomNumber" or plate.Name=="InteriorClassroomNumber" or plate.Name=="ClassNumber" or plate.Name=="RoomSign" or plate.Name=="C1UpperRoomNumber") then
   assert(not plate.CanCollide)
   if plate.Name=="C1UpperRoomNumber" then assert(plate:GetAttribute("BeforeWallClearanceFrame_v1")) else assert(plate:GetAttribute("BeforeWallClearanceSize_v1")) end
   for _,gui in ipairs(plate:GetChildren()) do if gui:IsA("SurfaceGui") and gui.Enabled then
    assert(not gui.AlwaysOnTop)
    local direction,half
    if gui.Face==Enum.NormalId.Front then direction,half=plate.CFrame.LookVector,plate.Size.Z/2
    elseif gui.Face==Enum.NormalId.Back then direction,half=-plate.CFrame.LookVector,plate.Size.Z/2
    elseif gui.Face==Enum.NormalId.Right then direction,half=plate.CFrame.RightVector,plate.Size.X/2
    elseif gui.Face==Enum.NormalId.Left then direction,half=-plate.CFrame.RightVector,plate.Size.X/2
    else error("Unexpected sign face: "..plate:GetFullName()) end
    local hit=workspace:Raycast(plate.Position+direction*(half+1),-direction*.98,ray)
    assert(not hit,"Sign surface blocked: "..plate:GetFullName())
    faces+=1
   end end
   plates+=1
  end
 end
 task.wait()
end
assert(plates==898 and faces==1754)
return "898 room/access plates have 1,754 sampled exposed faces without AlwaysOnTop"
