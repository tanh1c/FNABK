-- Place misplaced noncolliding hall runners on their named floor when supported.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local changes={}
for _,b in ipairs(bs:GetChildren()) do
 for _,v in ipairs(b:GetDescendants()) do
  if v:IsA("BasePart") then
   local f=tonumber(v.Name:match("^HallRunner_Floor_(%d%d)"))
   if f then
    local y=.825+(f-1)*12.85714
    if math.abs(y-v.Position.Y)>.2 then
     assert(not v.CanCollide and not v:GetAttribute("BeforeFloorAlignment_v1"))
     local floors={}
     for _,q in ipairs(b:GetDescendants()) do
      if q:IsA("BasePart") and q.CanCollide and q.Name:match("^WalkableFloor_"..string.format("%02d",f)) then table.insert(floors,q) end
     end
     local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances=floors;p.RespectCanCollide=true
     local supported=#floors>0;local frame=v.CFrame+Vector3.new(0,y-v.Position.Y,0);local x=v.Size.X>v.Size.Z
     for _,t in ipairs({-.4,-.2,0,.2,.4}) do
      local pt=frame:PointToWorldSpace(x and Vector3.new(v.Size.X*t,2,0) or Vector3.new(0,2,v.Size.Z*t))
      local hit=workspace:Raycast(pt,Vector3.new(0,-4,0),p)
      if not hit or math.abs(hit.Position.Y-(y-.025))>.15 then supported=false end
     end
     if supported then table.insert(changes,{v,frame}) end
    end
   end
  end
 end
 task.wait()
end
assert(#changes==42,"Unexpected runner count; no changes: "..#changes)
for _,item in ipairs(changes) do item[1]:SetAttribute("BeforeFloorAlignment_v1",item[1].CFrame);item[1].CFrame=item[2] end
-- B12 uses a shorter storey height than the standard template.
local structure=bs.B12.B12.WalkableStructure
local runner=assert(structure:FindFirstChild("HallRunner_Floor_02"))
local floor=assert(structure:FindFirstChild("WalkableFloor_02_East"))
assert(not runner.CanCollide and not runner:GetAttribute("BeforeFloorAlignment_v1"))
local top=floor.Position.Y+floor.Size.Y/2
assert(math.abs(top-12.22855)<.02)
runner:SetAttribute("BeforeFloorAlignment_v1",runner.CFrame)
runner.CFrame=runner.CFrame+Vector3.new(0,top+.025-runner.Position.Y,0)
return "Aligned 43 corridor runners to their supported floors"
