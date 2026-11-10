-- Remove duplicate gallery leaves from seven main entrances; originals remain in ServerStorage.
local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local names = {B3="GalleryClassroomDoor_F01_Side_East_03",B4="GalleryClassroomDoor_F01_Side_East_06",B9="GalleryClassroomDoor_F01_Side_East_08",C4="GalleryClassroomDoor_F01_Side_East_03",C5="GalleryClassroomDoor_F01_Side_East_06",Facility7="GalleryClassroomDoor_F01_Side_East_08",Canteen="GalleryClassroomDoor_F01_Side_East_07"}
assert(not game.ServerStorage:FindFirstChild("EntranceDuplicateDoors_v1"))
local selected = {}
for id, name in pairs(names) do
 local b = buildings[id]
 local entry = assert(b:FindFirstChild("CenterFacingEntrance_v1"))
 local main = assert(entry:FindFirstChild("MainEntryDoor"))
 local gallery = assert(b[id].WalkableStructure.ExteriorGalleries)
 local door = assert(gallery:FindFirstChild(name))
 assert(door:GetAttribute("CampusDoor") and #door:GetChildren()==0)
 local delta = main:GetAttribute("DoorClosed").Position-door:GetAttribute("DoorClosed").Position
 assert(delta.Magnitude < 1.2, id.." doors do not overlap")
 table.insert(selected,{id,door})
end
local backup = Instance.new("Folder")
backup.Name = "EntranceDuplicateDoors_v1"
backup.Parent = game.ServerStorage
for _, pair in ipairs(selected) do
 local folder=Instance.new("Folder");folder.Name=pair[1];folder.Parent=backup
 pair[2]:SetAttribute("OriginalParentPath",pair[2].Parent:GetFullName())
 pair[2].Parent=folder
end
return "Preserved seven overlapping gallery doors; main entrance doors retained"
