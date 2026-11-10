-- Set workshop shutters to roll into their existing opening instead of lifting through roofs.
local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local shutters={}
for _,id in ipairs({"C1","C2","C3"}) do
 for _,d in ipairs(buildings[id]:GetDescendants()) do
  if d:IsA("BasePart") and d:GetAttribute("CampusDoor") and (d.Name=="MainWorkshopShutter" or d.Name:match("^OpenBayShadow")) then
   assert(not d:GetAttribute("DoorClosedSize_v1"))
   assert(typeof(d:GetAttribute("DoorClosed"))=="CFrame" and d.Size.Y>1)
   table.insert(shutters,d)
  end
 end
end
assert(#shutters==20,"Unexpected shutter count; nothing changed: "..#shutters)
for _,d in ipairs(shutters) do
 local closed=d:GetAttribute("DoorClosed")
 d:SetAttribute("OriginalDoorOpen_v1",d:GetAttribute("DoorOpen"))
 d:SetAttribute("DoorClosedSize_v1",d.Size)
 local opened=closed*CFrame.new(0,(d.Size.Y-.2)/2,0)
 d:SetAttribute("DoorOpen",opened)
 if d:GetAttribute("StartsOpen") then d.Size=Vector3.new(d.Size.X,.2,d.Size.Z);d.CFrame=opened end
end
return "Configured 20 workshop shutters for roll-up animation"
