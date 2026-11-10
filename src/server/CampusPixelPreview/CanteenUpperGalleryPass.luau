-- Restore usable width to the compressed upper exterior gallery.
local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
local gallery = building.Canteen.WalkableStructure.ExteriorGalleries
local deck = gallery.GalleryDeck_East_Floor_02
assert(not deck:GetAttribute("BeforeWidthRepair_v1"))
local extension = 3
local railNames = {"GalleryRail_East_Floor_02_Parapet", "GalleryRail_East_Floor_02_Coping", "GalleryRail_East_Floor_02_EndPost_-1", "GalleryRail_East_Floor_02_EndPost_1"}
local endNames = {"GalleryRail_East_Floor_02_EndRail_-1", "GalleryRail_East_Floor_02_EndRail_1"}
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Exclude
overlap.FilterDescendantsInstances = {building}
local function clear(frame, size)
 for _, part in ipairs(workspace:GetPartBoundsInBox(frame, size, overlap)) do
  assert(not part.CanCollide, "Gallery would overlap " .. part:GetFullName())
 end
end
local direction = deck.CFrame.RightVector
clear(deck.CFrame + direction * extension / 2, deck.Size + Vector3.new(extension, 2, 0))
for _, name in ipairs(railNames) do
 local part = assert(gallery:FindFirstChild(name))
 assert(not part:GetAttribute("BeforeWidthRepair_v1"))
 clear(part.CFrame + direction * extension, part.Size)
end
for _, name in ipairs(endNames) do assert(gallery:FindFirstChild(name) and not gallery[name]:GetAttribute("BeforeWidthRepair_v1")) end
local function remember(part)
 part:SetAttribute("BeforeWidthRepair_v1", part.CFrame)
 part:SetAttribute("BeforeWidthRepairSize_v1", part.Size)
end
remember(deck)
deck.CFrame += direction * extension / 2
deck.Size += Vector3.new(extension, 0, 0)
for _, name in ipairs(railNames) do local part = gallery[name]; remember(part); part.CFrame += direction * extension end
for _, name in ipairs(endNames) do
 local part = gallery[name]; remember(part)
 part.CFrame += direction * extension / 2
 part.Size += Vector3.new(extension, 0, 0)
end
return "Widened Canteen upper gallery and moved its guard outward"
