-- Add a native serving counter in the existing dining hall without changing the floor plan.
local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
assert(not building:FindFirstChild("CanteenServingCounter_v1"))
local wall = building.Canteen.WalkableStructure.OuterWall_Floor_02_North
local frame = CFrame.new(5276,2.25,1974) * wall.CFrame.Rotation
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={building}
for _, part in ipairs(workspace:GetPartBoundsInBox(frame,Vector3.new(6.4,3,2.4),overlap)) do
 assert(not part.CanCollide or part.Name:match("^WalkableFloor"),"Counter position obstructed: "..part:GetFullName())
end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={building.Canteen.WalkableStructure};ray.RespectCanCollide=true
for _,x in ipairs({-2.8,2.8}) do for _,z in ipairs({-.8,.8}) do
 local point=frame:PointToWorldSpace(Vector3.new(x,3,z));local hit=workspace:Raycast(point,Vector3.new(0,-7,0),ray)
 assert(hit and hit.Instance.Name:match("^WalkableFloor") and math.abs(hit.Position.Y-.8)<.1,"Counter lacks floor support")
end end
for _,x in ipairs({-2,0,2}) do
 local point=frame:PointToWorldSpace(Vector3.new(x,1,-3))
 for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(point),Vector3.new(1.8,4.5,1.8),overlap)) do
  assert(not part.CanCollide or part.Name:match("^WalkableFloor"),"Counter approach obstructed: "..part:GetFullName())
 end
end
local group=Instance.new("Model");group.Name="CanteenServingCounter_v1"
local function make(name,size,offset,color,material,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=frame*CFrame.new(offset);p.Color=color;p.Material=material
 p.Anchored=true;p.CanCollide=collide;p.CanTouch=false;p.CanQuery=collide;p.CastShadow=collide;p.Parent=group;return p
end
make("CounterBase",Vector3.new(6,2.9,2),Vector3.zero,Color3.fromRGB(215,210,192),Enum.Material.Concrete,true)
make("Countertop",Vector3.new(6.1,.18,2.1),Vector3.new(0,1.54,0),Color3.fromRGB(128,135,136),Enum.Material.Metal,false)
for _,x in ipairs({-2.4,2.4}) do make("SignSupport",Vector3.new(.12,1.05,.12),Vector3.new(x,2.15,.75),Color3.fromRGB(88,95,96),Enum.Material.Metal,false) end
local sign=make("ServiceSign",Vector3.new(5.5,.8,.12),Vector3.new(0,2.8,.75),Color3.fromRGB(34,70,85),Enum.Material.SmoothPlastic,false)
local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.Parent=sign
local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text="QUẦY PHỤC VỤ";label.TextScaled=true;label.Font=Enum.Font.GothamBold;label.TextColor3=Color3.fromRGB(247,242,220);label.Parent=gui
for _,x in ipairs({-1.8,0,1.8}) do make("FoodTray",Vector3.new(1.2,.1,.8),Vector3.new(x,1.68,-.25),Color3.fromRGB(89,101,101),Enum.Material.Metal,false) end
group.Parent=building
return "Added a supported Canteen serving counter with sampled approach clearance"
