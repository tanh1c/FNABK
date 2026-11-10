local road=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.CampusAsphaltRoads_v1
local asphalt,marks=0,0
for _,part in ipairs(road:GetChildren()) do
 assert(part:IsA("BasePart") and part.Anchored and not part.CanCollide and not part.CanQuery)
 if part.Name=="Asphalt" then
  assert(part.Material==Enum.Material.Asphalt);asphalt+=1
 elseif part.Name=="LaneDash" then marks+=1
 else error("Unexpected road component") end
end
assert(asphalt>600 and road:GetAttribute("TriangleCount")==376 and marks==road:GetAttribute("MarkingCount") and marks==21)
return string.format("%d asphalt wedges and %d decorative markings checked",asphalt,marks)
