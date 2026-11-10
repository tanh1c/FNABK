-- ponytail: Native parts keep this preview asset-free; use reviewed authored models if higher fidelity is needed.
local root = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusTreeVarietyGrass_v1"))
local manifest = require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin = root:GetAttribute("PreviewOriginWorld")
local trees, obstacles, entries = {}, {}, {}
for _, obj in ipairs(root:GetDescendants()) do
 if obj:IsA("Model") and obj:GetAttribute("TreeDetailRefined_v1") then table.insert(trees, obj) end
 if obj:IsA("Seat") or (obj:IsA("BasePart") and obj.Name == "Trunk") then table.insert(obstacles, obj.Position) end
 if obj:IsA("BasePart") and obj:GetAttribute("CampusDoor") and (obj.Name:find("Main") or obj.Name:find("Entry")) then
  local closed = obj:GetAttribute("DoorClosed"); if closed then table.insert(entries, closed.Position) end
 end
end
assert(#trees == 158)
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances = {root.Buildings, root.CampusBoundaryAndGates_v1}
local function clear(pos, size)
 for _, p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos), size, overlap)) do if p.CanCollide then return false end end
 return true
end
local function far(pos, list, distance)
 for _, p in ipairs(list) do if Vector3.new(pos.X-p.X, 0, pos.Z-p.Z).Magnitude < distance then return false end end
 return true
end
local plans = {}
for _, tree in ipairs(trees) do
 local trunk = tree.Trunk
 local base = trunk.Position - Vector3.new(0, trunk.Size.Y/2, 0)
 local seed = math.abs(math.floor(base.X*17 + base.Z*31))
 local delta = ({-2.5, -1.25, 0, 1.8, 3.2})[seed%5+1]
 if delta > 0 and not clear(base + Vector3.new(0, 14, 0), Vector3.new(12, 28, 12)) then delta = 0 end
 table.insert(plans, {tree=tree, trunk=trunk, base=base, delta=delta, variant=seed%4})
end
local grassPlans = {}
for _, feature in ipairs(manifest.features) do
 if feature.category == "area" and feature.id:match("^grass%d*$") then
  local poly = feature.polygonStuds
  local x0,x1,z0,z1 = math.huge,-math.huge,math.huge,-math.huge
  for _, v in ipairs(poly) do x0=math.min(x0,v[1]); x1=math.max(x1,v[1]); z0=math.min(z0,v[2]); z1=math.max(z1,v[2]) end
  local ray = RaycastParams.new(); ray.FilterType=Enum.RaycastFilterType.Include; ray.RespectCanCollide=true
  ray.FilterDescendantsInstances={root.CampusExactGrass_v1[feature.id], root.CampusNaturalLandscape_v1[feature.id]}
  local random = Random.new(8101 + math.floor(x0*13+z0*3))
  local points = {}
  for z=z0+1,z1-1,4 do for x=x0+1,x1-1,4 do
   local pos = Vector3.new(origin.X+x+random:NextNumber(-.8,.8), 0, origin.Z+z+random:NextNumber(-.8,.8))
   if #points < 80 and random:NextNumber() < .16 and far(pos,obstacles,3) and far(pos,entries,8) and clear(pos+Vector3.new(0,1,0),Vector3.new(1.4,2,1.4)) then
    local hit=workspace:Raycast(pos+Vector3.new(0,5,0),Vector3.new(0,-10,0),ray)
    if hit then table.insert(points,hit.Position) end
   end
  end end
  table.insert(grassPlans,{id=feature.id,points=points,seed=math.floor(x0*13+z0*3)})
  task.wait()
 end
end
assert(#grassPlans == 24)
local output=Instance.new("Folder"); output.Name="CampusTreeVarietyGrass_v1"; output.Parent=root
local colors={Color3.fromRGB(58,105,62),Color3.fromRGB(76,121,68),Color3.fromRGB(48,94,65),Color3.fromRGB(99,132,70)}
for index, plan in ipairs(plans) do
 local trunk,tree,delta=plan.trunk,plan.tree,plan.delta
 trunk:SetAttribute("BeforeVarietySize_v1",trunk.Size); trunk:SetAttribute("BeforeVarietyFrame_v1",trunk.CFrame)
 trunk.Size += Vector3.new(0,delta,0); trunk.CFrame += Vector3.new(0,delta/2,0)
 for _, p in ipairs(tree.BarkDetail_v1:GetChildren()) do
  p:SetAttribute("BeforeVarietySize_v1",p.Size);p:SetAttribute("BeforeVarietyFrame_v1",p.CFrame)
  local fraction=p.Size.X/(trunk.Size.Y-delta)
  p.Size += Vector3.new(delta*fraction,0,0)
  local relative=(p.Position.Y-plan.base.Y)/(trunk.Size.Y-delta)
  p.CFrame += Vector3.new(0,delta*relative,0)
 end
 for _, p in ipairs(tree.DetailedCanopy_v1:GetChildren()) do
  p:SetAttribute("BeforeVarietyFrame_v1",p.CFrame);p:SetAttribute("BeforeVarietySize_v1",p.Size);p:SetAttribute("BeforeVarietyColor_v1",p.Color)
  p.CFrame += Vector3.new(0,delta,0)
  if p.Name=="Foliage" or p.Name=="FoliageLayer" then
   local shape=({Vector3.new(.78,.95,.78),Vector3.new(.88,.83,.88),Vector3.new(.86,1.05,.86),Vector3.new(.82,1.3,.82)})[plan.variant+1]
   p.Size *= shape
   p.Color=colors[plan.variant+1]:Lerp(p.Color,.45)
  end
 end
 tree:SetAttribute("TreeVariety_v1",plan.variant);tree:SetAttribute("TreeHeightDelta_v1",delta)
 if index%20==0 then task.wait() end
end
local count=0
for _, plan in ipairs(grassPlans) do
 local area=Instance.new("Folder");area.Name=plan.id
 local random=Random.new(plan.seed+8943)
 for _, pos in ipairs(plan.points) do
  local tuft=Instance.new("Model");tuft.Name="GrassTuft"
  local height=random:NextNumber(.55,1.25);local color=colors[random:NextInteger(1,#colors)]
  for blade=1,2 do
   local p=Instance.new("Part");p.Name="Blade";p.Size=Vector3.new(.18,height,random:NextNumber(.4,.7))
   p.CFrame=CFrame.new(pos+Vector3.new(0,height*.46,0))*CFrame.Angles(0,random:NextNumber(0,math.pi),random:NextNumber(-.16,.16))
   p.Color=color;p.Material=Enum.Material.Grass;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=tuft
  end
  tuft.Parent=area;count+=1
 end
 area.Parent=output;task.wait()
end
output:SetAttribute("TuftCount",count);output:SetAttribute("TreeCount",#plans)
return string.format("Varied %d trees and added %d grass tufts",#plans,count)



