local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusAsphaltRoads_v1"))
local data=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusRoadTriangles)
local origin=root:GetAttribute("PreviewOriginWorld")
local output=Instance.new("Folder");output.Name="CampusAsphaltRoads_v1"
local function wedge(a,b,c,parent)
 local ab,ac,bc=b-a,c-a,c-b
 if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c
 elseif ac:Dot(ac)>bc:Dot(bc) and ac:Dot(ac)>ab:Dot(ab) then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b
 local right=ac:Cross(ab).Unit;local up=bc:Cross(right).Unit;local back=bc.Unit
 local height=math.abs(ab:Dot(up))
 for _,item in ipairs({{a,b,right,back,math.abs(ab:Dot(back))},{a,c,-right,-back,math.abs(ac:Dot(back))}}) do
  if height>.05 and item[5]>.05 then
   local p=Instance.new("WedgePart");p.Name="Asphalt";p.Size=Vector3.new(.04,height,item[5])
   p.CFrame=CFrame.fromMatrix((item[1]+item[2])/2,item[3],up,item[4])
   p.Color=Color3.fromRGB(62,65,66);p.Material=Enum.Material.Asphalt;p.Anchored=true
   p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=parent
  end
 end
end
for i,t in ipairs(data.triangles) do
 local a=Vector3.new(origin.X+t[1][1],.015,origin.Z+t[1][2])
 local b=Vector3.new(origin.X+t[2][1],.015,origin.Z+t[2][2])
 local c=Vector3.new(origin.X+t[3][1],.015,origin.Z+t[3][2])
 wedge(a,b,c,output)
 if i%80==0 then task.wait() end
end
for _,point in ipairs(data.markings) do
 local p=Instance.new("Part");p.Name="LaneDash";p.Size=Vector3.new(6,.025,.28)
 p.CFrame=CFrame.new(origin.X+point[1],.0525,origin.Z+point[2])
 p.Color=Color3.fromRGB(221,210,168);p.Material=Enum.Material.SmoothPlastic;p.Anchored=true
 p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=output
end
output:SetAttribute("TriangleCount",#data.triangles);output:SetAttribute("MarkingCount",#data.markings)
output.Parent=root
return string.format("Added %d asphalt triangles and %d lane dashes",#data.triangles,#data.markings)
