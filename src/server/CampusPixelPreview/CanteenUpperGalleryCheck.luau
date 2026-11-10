local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
local gallery = building.Canteen.WalkableStructure.ExteriorGalleries
local deck = gallery.GalleryDeck_East_Floor_02
assert(deck:GetAttribute("BeforeWidthRepair_v1") and deck.Size.X > 4)
for _, name in ipairs({"GalleryRail_East_Floor_02_Parapet", "GalleryRail_East_Floor_02_Coping", "GalleryRail_East_Floor_02_EndPost_-1", "GalleryRail_East_Floor_02_EndPost_1", "GalleryRail_East_Floor_02_EndRail_-1", "GalleryRail_East_Floor_02_EndRail_1"}) do
 assert(gallery[name]:GetAttribute("BeforeWidthRepair_v1"))
end
local count = 0
for _, door in ipairs(gallery:GetChildren()) do
 if door:IsA("BasePart") and door.Name:match("^GalleryClassroomDoor_F02_Side_East") then
  local closed = door:GetAttribute("DoorClosed")
  local ray = RaycastParams.new()
  ray.FilterType = Enum.RaycastFilterType.Exclude
  ray.FilterDescendantsInstances = {door}
  ray.RespectCanCollide = true
  for _, distance in ipairs({1, 2, 3}) do
   local hit = workspace:Raycast(closed.Position + closed.RightVector * distance, Vector3.new(0, -10, 0), ray)
   assert(hit and hit.Instance == deck, "Missing gallery floor at " .. door.Name)
  end
  assert(not workspace:Raycast(closed.Position - closed.RightVector * 1.5, closed.RightVector * 4, ray), "Blocked gallery doorway: " .. door.Name)
  count += 1
 end
end
assert(count == 7)
return "Seven upper Canteen doors have sampled floor and clear crossings"
