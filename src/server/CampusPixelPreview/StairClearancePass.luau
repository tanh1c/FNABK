-- Preserve tread tops while removing solid undersides that block the flight below.
-- Add flights missing from A4 and C6 when extra floors were copied.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local treads={}
for _,b in ipairs(bs:GetChildren()) do
 for _,v in ipairs(b:GetDescendants()) do
  if v:IsA("BasePart") and v.Name:match("_Stair_Floor_%d%d_Step_%d+") then
   local f=tonumber(v.Name:match("_Floor_(%d%d)_"))
   if f>=2 then
    assert(v.Anchored and v.CanCollide and v.CFrame.UpVector.Y>.999 and #v:GetChildren()==0 and v.Size.Y>.3)
    assert(not v:GetAttribute("BeforeStairClearanceSize_v1"))
    table.insert(treads,v)
   end
  end
 end
end
assert(#treads==496,"Unexpected existing upper tread count; no changes: "..#treads)
local plans={}
for _,spec in ipairs({{id="A4",from=3,targets={4}},{id="C6",from=2,targets={3,4}}}) do
 local b=bs[spec.id];local stairs=b[spec.id].StairsAndLandings
 assert(not b:FindFirstChild("StairClearanceExtensions_v1"))
 local marker="_Stair_Floor_"..string.format("%02d",spec.from).."_";local source={}
 for _,v in ipairs(stairs:GetChildren()) do if v:IsA("BasePart") and v.Name:find(marker,1,true) then table.insert(source,v) end end
 assert(#source==22,"Unexpected source flight: "..spec.id)
 for _,target in ipairs(spec.targets) do
  local prefix="_Stair_Floor_"..string.format("%02d",target).."_"
  for _,v in ipairs(stairs:GetChildren()) do assert(not v.Name:find(prefix,1,true),"Target flight exists") end
  local output=Instance.new("Folder");output.Name="Flight_"..string.format("%02d",target)
  for _,v in ipairs(source) do
   local c=v:Clone()
   c.Name=v.Name:gsub("_Floor_%d%d_","_Floor_"..string.format("%02d",target).."_")
   c.CFrame=c.CFrame+Vector3.new(0,(target-spec.from)*12.85714,0)
   if c.Name:match("_Step_%d+") then
    local shift=(c.Size.Y-.2)/2;c.Size=Vector3.new(c.Size.X,.2,c.Size.Z);c.CFrame=c.CFrame+Vector3.new(0,shift,0)
   end
   c:SetAttribute("GeneratedStairFlight_v1",target);c.Parent=output
  end
  table.insert(plans,{building=b,folder=output})
 end
end
for _,v in ipairs(treads) do
 v:SetAttribute("BeforeStairClearanceSize_v1",v.Size)
 v:SetAttribute("BeforeStairClearanceCFrame_v1",v.CFrame)
 local shift=(v.Size.Y-.2)/2;v.Size=Vector3.new(v.Size.X,.2,v.Size.Z);v.CFrame=v.CFrame+Vector3.new(0,shift,0)
end
for _,plan in ipairs(plans) do
 local root=plan.building:FindFirstChild("StairClearanceExtensions_v1")
 if not root then root=Instance.new("Folder");root.Name="StairClearanceExtensions_v1";root.Parent=plan.building end
 plan.folder.Parent=root
end
return "Cleared headroom under 496 upper treads; added three missing 16-step flights"
