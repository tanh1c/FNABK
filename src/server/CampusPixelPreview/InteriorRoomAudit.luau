-- Audit modeled interior rooms, numbered plates and door floor heights.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local total=0
for _,b in ipairs(bs:GetChildren()) do
 local rooms,doors,plates,floors={},{},{},{}
 for _,v in ipairs(b:GetDescendants()) do
  if v:IsA("Model") and v:GetAttribute("CampusRoomId") then local id=v:GetAttribute("CampusRoomId");assert(not rooms[id],id);rooms[id]=true end
  if v:IsA("BasePart") and v.Name=="InteriorClassDoor" then local id=v:GetAttribute("ClassroomID");assert(id and not doors[id]);doors[id]=v end
  if v:IsA("BasePart") and v.Name=="InteriorClassroomNumber" then
   local texts={};for _,l in ipairs(v:GetDescendants()) do if l:IsA("TextLabel") then table.insert(texts,l.Text) end end
   assert(#texts==2 and texts[1]==texts[2] and not plates[texts[1]]);plates[texts[1]]=true
  end
  if v:IsA("BasePart") and v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floors,v) end
 end
 local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances=floors;p.RespectCanCollide=true
 for id in pairs(rooms) do
  local d=assert(doors[id],"Missing door: "..id);assert(plates[id],"Missing plate: "..id)
  local c=d:GetAttribute("DoorClosed");local base=c.Position.Y-d.Size.Y/2
  local hit=workspace:Raycast(Vector3.new(c.X,base+2,c.Z),Vector3.new(0,-5,0),p)
  assert(hit and math.abs(hit.Position.Y-base)<.2,"Door floor mismatch: "..id)
  total+=1
 end
 for id in pairs(doors) do assert(rooms[id] and plates[id],"Unmatched door: "..id) end
 for id in pairs(plates) do assert(rooms[id] and doors[id],"Unmatched plate: "..id) end
 task.wait()
end
assert(total==446,"Unexpected room count: "..total)
return "446 furnished interior groups have matching door, plate and sampled floor height"
