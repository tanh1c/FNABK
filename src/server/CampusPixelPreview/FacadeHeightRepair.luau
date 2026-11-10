-- Correct decorative template features extending well above their destination roofs.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local plans={}
for _,b in ipairs(bs:GetChildren()) do
 local main=b:FindFirstChild(b.Name)
 local structure=main and main:FindFirstChild("WalkableStructure")
 local roof=structure and structure:FindFirstChild("WalkableRoofCap")
 if roof then
  local top=roof.Position.Y+roof.Size.Y/2
  for _,v in ipairs(b:GetDescendants()) do
   if v:IsA("BasePart") and not v.CanCollide and
    (v.Name:match("^CornerPier_") or v.Name:match("^FacadePier_") or v.Name:match("^VerticalSunScreen_") or v.Name:match("^FacadeVentBlade_") or v.Name:match("^DistinctEndScreenFin_")) and
    v.Position.Y+v.Size.Y/2>top+5 and v.Position.Y-v.Size.Y/2<top-2 and v.CFrame.UpVector.Y>.999 then
    assert(not v:GetAttribute("BeforeFacadeSize_v1") and #v:GetChildren()==0)
    local bottom=v.Position.Y-v.Size.Y/2
    local height=top+1-bottom
    assert(height>1)
    table.insert(plans,{v,Vector3.new(v.Size.X,height,v.Size.Z),v.CFrame+Vector3.new(0,(height-v.Size.Y)/2,0)})
   end
  end
 end
end
assert(#plans==88,"Unexpected facade count; no changes: "..#plans)
local b3=bs.B3.B3
local roof=b3.WalkableStructure.WalkableRoofCap
local core={}
for _,v in ipairs(b3.MassingFeatures:GetChildren()) do
 if v:IsA("BasePart") and v.Name:match("^ProjectingStairCore_") then
  assert(not v.CanCollide and #v:GetChildren()==0 and v.CFrame.UpVector.Y>.999 and not v:GetAttribute("BeforeFacadeSize_v1"))
  table.insert(core,v)
 end
end
assert(#core==11)
local cap=assert(b3.MassingFeatures:FindFirstChild("ProjectingStairCore_Cap"))
local factor=(roof.Position.Y+roof.Size.Y/2+10)/(cap.Position.Y+cap.Size.Y/2)
assert(factor>.5 and factor<.8)
for _,item in ipairs(plans) do
 local v,size,frame=table.unpack(item)
 v:SetAttribute("BeforeFacadeSize_v1",v.Size);v:SetAttribute("BeforeFacadeCFrame_v1",v.CFrame)
 v.Size=size;v.CFrame=frame
end
for _,v in ipairs(core) do
 v:SetAttribute("BeforeFacadeSize_v1",v.Size);v:SetAttribute("BeforeFacadeCFrame_v1",v.CFrame)
 v.Size=Vector3.new(v.Size.X,v.Size.Y*factor,v.Size.Z)
 v.CFrame=CFrame.new(v.Position.X,v.Position.Y*factor,v.Position.Z)*v.CFrame.Rotation
end
return "Adjusted 88 overheight facade parts and B3's 11-part stair core"
