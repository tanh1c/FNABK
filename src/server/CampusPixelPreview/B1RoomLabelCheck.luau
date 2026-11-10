-- B1 has one numbered classroom per ID and corresponding door-side signs.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
local groups={RoomSign={},ClassNumber={}}
for _,v in ipairs(b:GetDescendants()) do
 local counts=groups[v.Name]
 if v:IsA("BasePart") and counts then
  local value,n=nil,0
  for _,text in ipairs(v:GetDescendants()) do
   if text:IsA("TextLabel") then
    assert(not value or value==text.Text,"B1 sign faces disagree")
    value=text.Text;n+=1
   end
  end
  assert(value and n==(v.Name=="RoomSign" and 1 or 2),"Missing B1 sign text")
  counts[value]=(counts[value] or 0)+1
 end
end
local total=0
for id,n in pairs(groups.RoomSign) do
 local floor=tonumber(id:match("^B1%-(%d)%d%d$"))
 assert(floor and floor>=1 and floor<=3 and n==1,"Invalid B1 room ID: "..id)
 assert(groups.ClassNumber[id]==(floor==1 and 1 or 2),"Missing door-side signs: "..id)
 total+=1
end
assert(total==42)
return "42 B1 room IDs and their matching door-side signs checked"

