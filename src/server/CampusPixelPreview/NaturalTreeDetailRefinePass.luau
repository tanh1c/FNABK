-- Refine the existing native trees without deleting their stored original parts.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusTreeDetailRefine_v1"))
local plans={}
for _,tree in ipairs(root:GetDescendants()) do
 if tree:IsA("Model") and tree:GetAttribute("PolishedTree_v1") then
  local trunk=assert(tree:FindFirstChild("Trunk"));local canopy=assert(tree:FindFirstChild("DetailedCanopy_v1"))
  assert(trunk:GetAttribute("BeforeBarkRefineTransparency_v1")==nil and not canopy:FindFirstChild("FoliageLayer") and not canopy:FindFirstChild("Leaflet"))
  local style=assert(tree:GetAttribute("TreeStyle_v1"));local pieces={}
  for _,part in ipairs(canopy:GetChildren()) do
   assert(part:IsA("BasePart") and not part.CanCollide and not part.CanQuery)
   table.insert(pieces,part)
  end
  assert(#pieces==(style==0 and 7 or 9))
  table.insert(plans,{tree=tree,trunk=trunk,canopy=canopy,style=style,pieces=pieces})
 end
end
assert(#plans==158,"Unexpected tree count; nothing changed")
local function part(parent,class,name,size,frame,color,material,shape)
 local p=Instance.new(class);p.Name=name;p.Size=size;p.CFrame=frame;p.Color=color;p.Material=material;p.Anchored=true
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;if shape then p.Shape=shape end;p.Parent=parent;return p
end
for index,plan in ipairs(plans) do
 local trunk=plan.trunk;local h=trunk.Size.Y;local base=trunk.Position-Vector3.new(0,h/2,0)
 trunk:SetAttribute("BeforeBarkRefineTransparency_v1",trunk.Transparency);trunk.Transparency=1
 local bark=Instance.new("Folder");bark.Name="BarkDetail_v1"
 local thickness=math.max(trunk.Size.X,trunk.Size.Z)
 for _,segment in ipairs({{0,.62,1},{.62,1,.74}}) do
  local length=h*(segment[2]-segment[1]);local center=h*(segment[1]+segment[2])/2
  part(bark,"Part","BarkSegment",Vector3.new(length,thickness*segment[3],thickness*segment[3]),CFrame.new(base+Vector3.new(0,center,0))*CFrame.Angles(0,0,math.pi/2),trunk.Color,Enum.Material.Wood,Enum.PartType.Cylinder)
 end
 bark.Parent=plan.tree
 local seed=math.abs(math.floor(base.X*17+base.Z*31));local random=Random.new(seed+9041)
 if plan.style==0 then
  for _,frond in ipairs(plan.pieces) do
   for _,side in ipairs({-1,1}) do
    local direction=(frond.CFrame.LookVector*.82+frond.CFrame.RightVector*side*.57).Unit
    local anchor=frond.Position+frond.CFrame.RightVector*(side*.3)
    local dest=anchor+direction*2.8+Vector3.new(0,-.55,0)
    part(plan.canopy,"WedgePart","Leaflet",Vector3.new(.8,.18,(dest-anchor).Magnitude),CFrame.lookAt((anchor+dest)/2,dest),frond.Color,Enum.Material.LeafyGrass)
   end
  end
 else
  local baseColor=Color3.fromRGB(55+seed%9,101+seed%12,62+seed%8)
  for _,leaf in ipairs(plan.pieces) do if leaf.Name=="Foliage" then
   leaf:SetAttribute("BeforeRefineColor_v1",leaf.Color)
   local amount=random:NextNumber(-.025,.025)
   leaf.Color=Color3.new(math.clamp(baseColor.R+amount,0,1),math.clamp(baseColor.G+amount,0,1),math.clamp(baseColor.B+amount,0,1))
  end end
  local phase=random:NextNumber(0,math.pi*2)
  for i=1,3 do
   local angle=phase+(i-1)*math.pi*2/3
   local center=base+Vector3.new(math.cos(angle)*1.35,h-1.2+(i-1)*.85,math.sin(angle)*1.35)
   part(plan.canopy,"Part","FoliageLayer",Vector3.new(3.6,4.0,3.6),CFrame.new(center)*CFrame.Angles(0,angle,0),baseColor,Enum.Material.LeafyGrass,Enum.PartType.Ball)
  end
 end
 plan.tree:SetAttribute("TreeDetailRefined_v1",true)
 if index%20==0 then task.wait() end
end
local marker=Instance.new("Folder");marker.Name="CampusTreeDetailRefine_v1";marker:SetAttribute("TreeCount",#plans);marker.Parent=root
return "Refined trunks and layered crowns on 158 native trees"


