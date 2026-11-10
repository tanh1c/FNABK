-- ponytail: one extra pair per remaining classroom; custom seating densities require room-specific plans.
local campus=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local marker=assert(campus:FindFirstChild("CampusClassroomFurniture_v1"))
assert(marker:GetAttribute("ClassroomCount")==96 and not campus:FindFirstChild("CampusClassroomFurnitureGrid_v1"))
local bs=campus.Buildings
local out={rooms=0,safe=0,by={},examples={}}
local planned={}
for _,b in ipairs(bs:GetChildren()) do
 local doors,walls,floors={},{},{}
 for _,v in ipairs(b:GetDescendants()) do
  if v:IsA("BasePart") then
   if v:GetAttribute("CampusDoor") then table.insert(doors,v) end
   if v.CanCollide and (v.Name:find("Wall") or v.Name:find("Divider") or v.Name:find("Partition")) then table.insert(walls,v) end
   if v.CanCollide and v.Name:match("^WalkableFloor_") then table.insert(floors,v) end
  end
 end
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={b}
 local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances=walls;rp.RespectCanCollide=true
 local fp=RaycastParams.new();fp.FilterType=Enum.RaycastFilterType.Include;fp.FilterDescendantsInstances=floors;fp.RespectCanCollide=true
 for _,room in ipairs(b:GetDescendants()) do
  if room:IsA("Model") and room:GetAttribute("CampusRoomId") and room.Name:find("Classroom") and not room:FindFirstChild("ExtraStudentFurniture_v1") then
   local d=room:FindFirstChild("StudentDesk_1");local seat=room:FindFirstChild("StudentBench_1")
   if d and seat and d:IsA("BasePart") and seat:IsA("BasePart") then
    out.rooms+=1
    local axis=seat.Position-d.Position;axis=Vector3.new(axis.X,0,axis.Z)
    if axis.Magnitude>.1 then
     axis=axis.Unit;local chosen
     local d2=room:FindFirstChild("StudentDesk_2")
     local along=d2 and (d2.Position-d.Position) or Vector3.zero
     along=Vector3.new(along.X,0,along.Z)
     local candidates={}
     if along.Magnitude>.1 then
      along=along.Unit
      for _,a in ipairs({-5,5,-10,10}) do for _,cross in ipairs({0,-5.5,5.5}) do table.insert(candidates,along*a+axis*cross) end end
     end
     for _,delta in ipairs(candidates) do
      local good=true
      for _,item in ipairs({d,seat}) do
       local cf=item.CFrame+delta;local size=item.Size+Vector3.new(.6,-.1,.6)
       for _,v in ipairs(workspace:GetPartBoundsInBox(cf,size,overlap)) do
        if v.CanCollide and not v:GetAttribute("CampusDoor") and not v.Name:match("^WalkableFloor") and not v.Name:match("^HallRunner") then good=false;break end
       end
       local pos=item.Position+delta
       local hit=workspace:Raycast(pos+Vector3.new(0,2,0),Vector3.new(0,-6,0),fp)
       if not hit or math.abs(hit.Position.Y-(item.Position.Y-item.Size.Y/2))>2 then good=false end
       if workspace:Raycast(item.Position+Vector3.new(0,3,0),delta,rp) then good=false end
       for _,door in ipairs(doors) do
        local c=door:GetAttribute("DoorClosed")
        if c and math.abs(c.Y-pos.Y)<6 and (Vector3.new(c.X-pos.X,0,c.Z-pos.Z)).Magnitude<5 then good=false;break end
       end
      end
      if good then
       for _,v in ipairs(planned) do
        if v.building==b and math.abs(v.desk.Position.Y-d.Position.Y)<4 then
         for _,source in ipairs({d,seat}) do for _,other in ipairs({v.desk,v.bench}) do
          local p1=source.Position+delta;local p2=other.Position+v.delta
          local r1=math.sqrt(source.Size.X^2+source.Size.Z^2)/2
          local r2=math.sqrt(other.Size.X^2+other.Size.Z^2)/2
          if (Vector3.new(p1.X,0,p1.Z)-Vector3.new(p2.X,0,p2.Z)).Magnitude<r1+r2+.3 then good=false end
         end end
        end
        if not good then break end
       end
      end
      if good then
       assert(not room:FindFirstChild("ExtraStudentFurniture_v1") and #d:GetChildren()==0 and #seat:GetChildren()==0)
       chosen=delta;table.insert(planned,{building=b,room=room,desk=d,bench=seat,delta=delta});break
      end
     end
     if chosen then
      out.safe+=1;out.by[b.Name]=(out.by[b.Name] or 0)+1
      if #out.examples<8 then table.insert(out.examples,{id=room:GetAttribute("CampusRoomId"),shift=tostring(chosen)}) end
     end
    end
   end
  end
 end
 task.wait()
end
assert(#planned==252,"Unexpected classroom plan count; nothing changed: "..#planned)
for _,plan in ipairs(planned) do
 local folder=Instance.new("Folder");folder.Name="ExtraStudentFurniture_v1"
 local desk=plan.desk:Clone();desk.Name="StudentDesk_Extra";desk.CFrame=desk.CFrame+plan.delta;desk.Parent=folder
 local bench=plan.bench:Clone();bench.Name="StudentBench_Extra";bench.CFrame=bench.CFrame+plan.delta;bench.Parent=folder
 folder.Parent=plan.room
end
marker:SetAttribute("BeforeGridCount_v1",marker:GetAttribute("ClassroomCount"))
marker:SetAttribute("ClassroomCount",348);marker:SetAttribute("IndividualLayoutRequired",0)
local grid=Instance.new("Folder");grid.Name="CampusClassroomFurnitureGrid_v1";grid:SetAttribute("ClassroomCount",#planned);grid.Parent=campus
return "Added an extra desk and bench to the remaining 252 classrooms"
