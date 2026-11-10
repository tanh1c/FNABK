local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local boundary=root.CampusBoundaryAndGates_v1
assert(not root:FindFirstChild("CampusGateArchitecture_v1"))
local gates={}
for _,g in ipairs(boundary:GetDescendants()) do
 if g:IsA("Model") and g.Name:match("^CampusGate_%d+$") then
  local h=assert(g:FindFirstChild("GateHeader"));local pillars,caps,labels={},{},{}
  for _,v in ipairs(g:GetChildren()) do
   if v.Name=="GatePillar" then table.insert(pillars,v) elseif v.Name=="GatePillarCap" then table.insert(caps,v) end
  end
  for _,v in ipairs(h:GetChildren()) do if v:IsA("SurfaceGui") then table.insert(labels,v) end end
  assert(#pillars==2 and #caps==2 and #labels==2 and h:GetAttribute("BeforeGateRebuildTransparency_v1")==nil)
  table.insert(gates,{gate=g,header=h,pillars=pillars,caps=caps,labels=labels})
 end
end
assert(#gates==3)
local preview=workspace:FindFirstChild("FNABK_Campus_PixelPreview_v1_B1Review_v6")
local markers={}
if preview and preview:FindFirstChild("DigitizedEntrances") then
 for _,v in ipairs(preview.DigitizedEntrances:GetDescendants()) do if v:IsA("BasePart") and v.Name=="EntrancePoint" then table.insert(markers,v) end end
end
assert(#markers==3)
local output=Instance.new("Folder");output.Name="CampusGateArchitecture_v1"
local pale=Color3.fromRGB(218,220,210)
local navy=Color3.fromRGB(37,66,84)
local trim=Color3.fromRGB(100,133,143)
local metal=Color3.fromRGB(193,179,133)
local function part(parent,name,size,cf,color,material,collision,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material;p.Anchored=true
 p.CanCollide=collision;p.CanTouch=false;p.CanQuery=collision;p.CastShadow=collision;if shape then p.Shape=shape end;p.Parent=parent
end
for _,plan in ipairs(gates) do
 local h=plan.header;local frame=h.CFrame*CFrame.new(0,-h.Position.Y,0)
 local model=Instance.new("Model");model.Name=plan.gate.Name
 for _,x in ipairs({-16,16}) do
  part(model,"PillarBody",Vector3.new(3.6,18,3.8),frame*CFrame.new(x,9,0),pale,Enum.Material.Concrete,true)
  part(model,"PillarPlinth",Vector3.new(4.2,1.3,4.4),frame*CFrame.new(x,.65,0),navy,Enum.Material.Concrete,false)
  part(model,"PillarCapital",Vector3.new(4.3,.7,4.5),frame*CFrame.new(x,18.1,0),trim,Enum.Material.Metal,false)
  for _,z in ipairs({-1.93,1.93}) do
   part(model,"PillarAccent",Vector3.new(.3,12,.08),frame*CFrame.new(x,9,z),trim,Enum.Material.Metal,false)
  end
 end
 part(model,"HighLintel",Vector3.new(36,2.5,3.2),frame*CFrame.new(0,19.35,0),navy,Enum.Material.Concrete,true)
 part(model,"LowerTrim",Vector3.new(37,.35,3.8),frame*CFrame.new(0,18.05,0),trim,Enum.Material.Metal,false)
 part(model,"TopCoping",Vector3.new(37.5,.55,4.2),frame*CFrame.new(0,20.9,0),pale,Enum.Material.Concrete,false)
 part(model,"Crown",Vector3.new(12,1,3.1),frame*CFrame.new(0,21.65,0),navy,Enum.Material.Concrete,false)
 for _,z in ipairs({-1.65,1.65}) do
  part(model,"GateAccent",Vector3.new(9,.2,.08),frame*CFrame.new(0,19.45,z),metal,Enum.Material.Metal,false)
 end
 model.Parent=output
end
for _,plan in ipairs(gates) do
 local h=plan.header
 h:SetAttribute("BeforeGateRebuildTransparency_v1",h.Transparency);h:SetAttribute("BeforeGateRebuildCanCollide_v1",h.CanCollide);h:SetAttribute("BeforeGateRebuildCanQuery_v1",h.CanQuery)
 h.Transparency=1;h.CanCollide=false;h.CanQuery=false
 for _,gui in ipairs(plan.labels) do gui:SetAttribute("BeforeGateRebuildEnabled_v1",gui.Enabled);gui.Enabled=false end
 for _,cap in ipairs(plan.caps) do cap:SetAttribute("BeforeGateRebuildTransparency_v1",cap.Transparency);cap.Transparency=1 end
end
for _,marker in ipairs(markers) do marker:SetAttribute("BeforeGateRebuildTransparency_v1",marker.Transparency);marker.Transparency=1 end
output.Parent=root
return "Rebuilt three taller gate portals and hid six gate name labels"
