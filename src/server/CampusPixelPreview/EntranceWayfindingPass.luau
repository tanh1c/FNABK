-- Put entrance wayfinding on canopy lips where the original plates are hidden from outside.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local plans={}
local ray=RaycastParams.new();ray.RespectCanCollide=true
for _,name in ipairs({"B3","B4","B9","C4","C5","Facility7","Canteen"}) do
 local entry=root.Buildings[name].CenterFacingEntrance_v1
 assert(not entry:FindFirstChild("EntranceWayfinding_v1"))
 local canopy=entry.EntryCanopy
 assert(canopy.Size.X>=7 and canopy.Size.Z>=4)
 local frame=canopy.CFrame*CFrame.new(0,-.8,canopy.Size.Z/2+.12)
 for _,distance in ipairs({3,5}) do
  local start=frame.Position-canopy.CFrame.LookVector*distance
  start=Vector3.new(start.X,3.8,start.Z)
  assert(workspace:Raycast(start,Vector3.new(0,-6,0),ray),"No ground near "..name)
  assert(not workspace:Raycast(start,(frame.Position-start)*.98,ray),"Entrance sign obscured at "..name)
 end
 table.insert(plans,{entry=entry,frame=frame})
end
for _,plan in ipairs(plans) do
 local sign=Instance.new("Part");sign.Name="EntranceWayfinding_v1";sign.Size=Vector3.new(6,1,.12);sign.CFrame=plan.frame
 sign.Anchored=true;sign.CanCollide=false;sign.CanTouch=false;sign.CanQuery=false;sign.CastShadow=false
 sign.Color=Color3.fromRGB(38,68,82);sign.Material=Enum.Material.SmoothPlastic
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Back;gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.Parent=sign
 local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text="LỐI VÀO";label.TextScaled=true;label.Font=Enum.Font.GothamBold;label.TextColor3=Color3.fromRGB(247,242,220);label.Parent=gui
 sign.Parent=plan.entry
end
return "Added seven wall-occluded entrance wayfinding labels at canopy edges"
