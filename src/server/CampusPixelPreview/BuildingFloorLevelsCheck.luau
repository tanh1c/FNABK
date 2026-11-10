-- Count distinct named walkable-floor elevations, including the B1 and workshop structures.
local buildings = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local expected = {Canteen=2,B2=3,B3=2,B4=6,B6=3,A1=3,A2=3,A3=2,A4=5,A5=4,B8=3,B9=3,B11=2,B12=2,C1=2,C2=1,C3=1,C4=5,C5=5,C6=5,Facility7=3,KioskOISP=1,B1=3}
local count = 0
for _, building in ipairs(buildings:GetChildren()) do
 assert(expected[building.Name],"Unexpected building: "..building.Name)
 local levels = {}
 for _, part in ipairs(building:GetDescendants()) do
  if part:IsA("BasePart") and part.CanCollide and (part.Name:match("^WalkableFloor") or part.Name=="WorkshopWalkableFloor" or part.Name=="UpperWalkableServiceFloor" or (building.Name=="B1" and part.Parent==building and part.Name:match("Floor"))) then
   local y=part.Position.Y+part.Size.Y/2
   local exists=false
   for _, level in ipairs(levels) do if math.abs(level-y)<1 then exists=true;break end end
   if not exists then table.insert(levels,y) end
  end
 end
 assert(#levels==expected[building.Name],building.Name.." has "..#levels.." named floor elevations, expected "..expected[building.Name])
 count+=1
end
assert(count==23)
return "23 buildings retain the expected number of named walkable floor elevations"
