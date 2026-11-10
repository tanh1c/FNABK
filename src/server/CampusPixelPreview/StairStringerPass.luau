-- Decorative side stringers support the thin-tread representation without blocking movement.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local plans={}
for _,b in ipairs(bs:GetChildren()) do
 local flights={}
 for _,v in ipairs(b:GetDescendants()) do
  if v:IsA("BasePart") and (v:GetAttribute("BeforeStairClearanceSize_v1") or (v:GetAttribute("GeneratedStairFlight_v1") and v.Name:match("_Step_%d+"))) then
   local f=tonumber(v.Name:match("_Floor_(%d%d)_"));local step=tonumber(v.Name:match("_Step_(%d+)"))
   assert(f and step);flights[f]=flights[f] or {};assert(not flights[f][step]);flights[f][step]=v
  end
 end
 if next(flights) then
  assert(not b:FindFirstChild("StairStringers_v1"))
  local folder=Instance.new("Folder");folder.Name="StairStringers_v1"
  for floor,steps in pairs(flights) do
   assert(#steps==16)
   local a,z=steps[1],steps[16];assert(a.Size.X>0.5 and a.CFrame.UpVector.Y>.999 and z.CFrame.UpVector.Y>.999)
   for _,side in ipairs({-1,1}) do
    local edge=side*(a.Size.X/2-.12)
    local p=a.Position+a.CFrame.RightVector*edge-Vector3.new(0,.22,0)
    local q=z.Position+z.CFrame.RightVector*edge-Vector3.new(0,.22,0)
    local beam=Instance.new("Part");beam.Name=string.format("Flight_%02d_Stringer_%s",floor,side<0 and "Left" or "Right")
    beam.Size=Vector3.new(.2,.2,(q-p).Magnitude);beam.CFrame=CFrame.lookAt((p+q)/2,q)
    beam.Color=Color3.fromRGB(92,99,98);beam.Material=Enum.Material.Metal
    beam.Anchored=true;beam.CanCollide=false;beam.CanTouch=false;beam.CanQuery=false;beam.CastShadow=false
    beam.Parent=folder
   end
  end
  table.insert(plans,{building=b,folder=folder})
 end
end
local total=0
for _,plan in ipairs(plans) do total+=#plan.folder:GetChildren() end
assert(total==68,"Unexpected stringer count; no changes: "..total)
for _,plan in ipairs(plans) do plan.folder.Parent=plan.building end
return "Added 68 noncolliding side stringers to 34 upper flights"
