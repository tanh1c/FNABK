-- Add table legs and small books to A2 reading tables using native parts.
local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.A2
assert(not b:FindFirstChild("A2ReadingTableDetails_v1"))
local floors={}
for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floors,v) end end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=floors;ray.RespectCanCollide=true
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
local plans={}
for _,room in ipairs(b:GetDescendants()) do
 if room:IsA("Model") and room:GetAttribute("CampusRoomId") then
  local t=room:FindFirstChild("ReadingTable")
  if t then
   assert(t:IsA("BasePart") and t.CFrame.UpVector.Y>.999)
   local bottom=t.Position.Y-t.Size.Y/2;local legs={}
   for _,x in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
    local pt=t.CFrame:PointToWorldSpace(Vector3.new(x*(t.Size.X/2-.22),0,z*(t.Size.Z/2-.22)))
    local hit=workspace:Raycast(Vector3.new(pt.X,bottom+.1,pt.Z),Vector3.new(0,-5,0),ray)
    assert(hit,"Reading table leg has no floor: "..room:GetAttribute("CampusRoomId"))
    local height=bottom-hit.Position.Y;assert(height>.2 and height<5)
    local frame=CFrame.new(pt.X,(bottom+hit.Position.Y)/2,pt.Z)*t.CFrame.Rotation
    for _,v in ipairs(workspace:GetPartBoundsInBox(frame,Vector3.new(.25,height-.1,.25),overlap)) do
     assert(v==t or not v.CanCollide or v:GetAttribute("CampusDoor") or v.Name:match("^WalkableFloor"),"Reading table leg overlaps "..v:GetFullName())
    end
    table.insert(legs,{frame=frame,height=height})
   end end
   table.insert(plans,{room=room,tablePart=t,legs=legs})
  end
 end
end
assert(#plans==27)
local group=Instance.new("Folder");group.Name="A2ReadingTableDetails_v1"
for _,plan in ipairs(plans) do
 local detail=Instance.new("Folder");detail.Name=plan.room:GetAttribute("CampusRoomId")
 for _,leg in ipairs(plan.legs) do
  local p=Instance.new("Part");p.Name="ReadingTableLeg";p.Size=Vector3.new(.25,leg.height,.25);p.CFrame=leg.frame
  p.Color=Color3.fromRGB(87,75,61);p.Material=Enum.Material.Wood
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=detail
 end
 for i=1,2 do
  local book=Instance.new("Part");book.Name="ReadingBook";book.Size=Vector3.new(math.min(plan.tablePart.Size.X*.24,.85),.1,math.min(plan.tablePart.Size.Z*.28,.65))
  book.CFrame=plan.tablePart.CFrame*CFrame.new(.15,plan.tablePart.Size.Y/2+.06+(i-1)*.11,0)
  book.Color=if i==1 then Color3.fromRGB(61,101,107) else Color3.fromRGB(158,110,68)
  book.Material=Enum.Material.SmoothPlastic;book.Anchored=true;book.CanCollide=false;book.CanTouch=false;book.CanQuery=false;book.CastShadow=false;book.Parent=detail
 end
 detail.Parent=group
end
group.Parent=b
return "Added legs and books to 27 A2 reading tables"
