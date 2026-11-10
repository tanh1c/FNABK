local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.A2
local counts = {ReadingTable = 0, ReadingTableLeg = 0, ReadingBook = 0, ReadingSeat = 0}
for _, item in ipairs(building:GetDescendants()) do
 if counts[item.Name] and item:IsA("BasePart") then counts[item.Name] += 1 end
end
assert(counts.ReadingTable == 27 and counts.ReadingTableLeg == 108 and counts.ReadingBook == 54 and counts.ReadingSeat == 54)
assert(#game.ServerStorage.A2ReadingChairsBefore_v1:GetChildren() == 54)
return "A2 reading furniture counts and chair backup verified"
