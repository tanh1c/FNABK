-- Native preview facilities. No existing models are removed.
local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
assert(not root:FindFirstChild("CampusRemainingAreas_v1"))
local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
local origin=root:GetAttribute("PreviewOriginWorld")
local specs={
 FootballField={"Field",Color3.fromRGB(70,120,74),Enum.Material.Grass},
 EastPlaza={"Plaza",Color3.fromRGB(159,162,153),Enum.Material.Concrete},
 OpenField={"Garden",Color3.fromRGB(79,126,79),Enum.Material.Grass},
 SportArea={"Sport",Color3.fromRGB(112,122,107),Enum.Material.Concrete},
 Parking={"Parking",Color3.fromRGB(73,76,76),Enum.Material.Asphalt},
 Parking2={"Parking",Color3.fromRGB(73,76,76),Enum.Material.Asphalt},
 parking3={"Parking",Color3.fromRGB(73,76,76),Enum.Material.Asphalt},
 StudentSpace={"Student",Color3.fromRGB(157,160,151),Enum.Material.Concrete},
 basketballField={"Basketball",Color3.fromRGB(155,97,72),Enum.Material.Concrete},
}
local features={}
for _,f in ipairs(manifest.features) do if specs[f.id] then features[f.id]=f end end
local function cross(a,b,c) return (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1]) end
local function triangulate(poly)
 local vertices={};local area=0
 for i,v in ipairs(poly) do local n=poly[i%#poly+1];area+=v[1]*n[2]-n[1]*v[2] end
 if area<0 then for i=#poly,1,-1 do table.insert(vertices,poly[i]) end else for _,v in ipairs(poly) do table.insert(vertices,v) end end
 local out={}
 while #vertices>3 do
  local found=false
  for i=1,#vertices do
   local prev=(i-2)%#vertices+1;local next=(i%#vertices)+1
   local a,b,c=vertices[prev],vertices[i],vertices[next]
   if cross(a,b,c)>.0001 then
    local occupied=false
    for j,p in ipairs(vertices) do
     if j~=prev and j~=i and j~=next and cross(a,b,p)>=-.0001 and cross(b,c,p)>=-.0001 and cross(c,a,p)>=-.0001 then occupied=true;break end
    end
    if not occupied then table.insert(out,{a,b,c});table.remove(vertices,i);found=true;break end
   end
  end
  assert(found,"Cannot triangulate area")
 end
 table.insert(out,{vertices[1],vertices[2],vertices[3]})
 return out
end
local function inside(poly,x,z)
 local hit=false;local a=poly[#poly]
 for _,b in ipairs(poly) do if (a[2]>z)~=(b[2]>z) and x<(a[1]-b[1])*(z-b[2])/(a[2]-b[2])+b[1] then hit=not hit end;a=b end
 return hit
end
local output=Instance.new("Folder");output.Name="CampusRemainingAreas_v1"
local function piece(parent,name,x,y,z,sx,sy,sz,color,material,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=Vector3.new(sx,sy,sz)
 p.Position=origin+Vector3.new(x,y,z);p.Color=color;p.Material=material;p.Anchored=true
 p.CanCollide=collide or false;p.CanTouch=false;p.CanQuery=collide or false;p.CastShadow=collide or false;p.Parent=parent
 return p
end
local function wedge(parent,a,b,c,color,material)
 local ab,ac,bc=b-a,c-a,c-b
 if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c elseif ac:Dot(ac)>bc:Dot(bc) and ac:Dot(ac)>ab:Dot(ab) then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b
 local right=ac:Cross(ab).Unit;local up=bc:Cross(right).Unit;local back=bc.Unit;local height=math.abs(ab:Dot(up))
 for _,item in ipairs({{a,b,right,back,math.abs(ab:Dot(back))},{a,c,-right,-back,math.abs(ac:Dot(back))}}) do
  if height>.05 and item[5]>.05 then
   local p=Instance.new("WedgePart");p.Name="AreaSurface";p.Size=Vector3.new(.04,height,item[5])
   p.CFrame=CFrame.fromMatrix((item[1]+item[2])/2,item[3],up,item[4]);p.Color=color;p.Material=material
   p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
  end
 end
end
local white=Color3.fromRGB(232,229,211)
local steel=Color3.fromRGB(90,99,99)
local wood=Color3.fromRGB(123,91,62)
local function line(area,x,z,sx,sz) piece(area,"CourtMarking",x,.075,z,sx,.025,sz,white,Enum.Material.SmoothPlastic) end
local function bench(area,x,z)
 local s=Instance.new("Seat");s.Name="BenchSeat";s.Size=Vector3.new(6,.4,1.5);s.Position=origin+Vector3.new(x,1.6,z)
 s.Color=wood;s.Material=Enum.Material.WoodPlanks;s.Anchored=true;s.CanCollide=true;s.Parent=area
 for _,dx in ipairs({-2.3,2.3}) do piece(area,"BenchLeg",x+dx,.8,z,.35,1.6,.35,steel,Enum.Material.Metal) end
 piece(area,"BenchBack",x,2.45,z+.65,6,1.35,.25,wood,Enum.Material.WoodPlanks)
end
local function outline(area,cx,cz,w,h)
 line(area,cx,cz-h/2,w,.25);line(area,cx,cz+h/2,w,.25)
 line(area,cx-w/2,cz,.25,h);line(area,cx+w/2,cz,.25,h)
end
local function hoop(area,x,z,direction)
 piece(area,"HoopPost",x,4,z,.4,8,.4,steel,Enum.Material.Metal)
 piece(area,"Backboard",x+direction*1.6,7,z,.25,2.8,4.5,white,Enum.Material.SmoothPlastic)
 local rim=Color3.fromRGB(177,86,56)
 for _,dz in ipairs({-1,1}) do piece(area,"Rim",x+direction*2.5,6.1,z+dz,1.8,.18,.18,rim,Enum.Material.Metal) end
 for _,dx in ipairs({-1,1}) do piece(area,"Rim",x+direction*2.5+dx*.9,6.1,z,.18,.18,2,rim,Enum.Material.Metal) end
end
local function court(area,x,z,w,h)
 outline(area,x,z,w,h);line(area,x,z,.25,h)
 for _,side in ipairs({-1,1}) do
  line(area,x+side*(w/2-13),z,.25,20)
  line(area,x+side*(w/2-6.5),z-10,13,.25);line(area,x+side*(w/2-6.5),z+10,13,.25)
  hoop(area,x+side*(w/2+2),z,-side)
 end
end
local function badminton(area,x,z)
 outline(area,x,z,58,25);line(area,x-8,z,.25,25);line(area,x+8,z,.25,25)
 line(area,x-18.5,z,21,.25);line(area,x+18.5,z,21,.25)
 for _,side in ipairs({-1,1}) do piece(area,"NetPost",x,2,z+side*13,.3,4,.3,steel,Enum.Material.Metal) end
 piece(area,"NetBand",x,3.8,z,.15,.15,26,white,Enum.Material.SmoothPlastic)
end
for id,spec in pairs(specs) do
 local feature=assert(features[id]);local area=Instance.new("Model");area.Name=id;area:SetAttribute("AreaKind",spec[1])
 local triangles=triangulate(feature.polygonStuds)
 for _,t in ipairs(triangles) do
  local a=origin+Vector3.new(t[1][1],.025,t[1][2]);local b=origin+Vector3.new(t[2][1],.025,t[2][2]);local c=origin+Vector3.new(t[3][1],.025,t[3][2])
  wedge(area,a,b,c,spec[2],spec[3])
 end
 area:SetAttribute("SurfaceTriangles",#triangles)
 if id=="FootballField" then
  outline(area,976,559,164,86);line(area,976,559,.3,86)
  for i=0,15 do
   local angle=i*math.pi/8
   local p=piece(area,"CenterCircle",976+math.cos(angle)*9,.075,559+math.sin(angle)*9,3.5,.025,.22,white,Enum.Material.SmoothPlastic)
   p.CFrame*=CFrame.Angles(0,-angle-math.pi/2,0)
  end
  for _,side in ipairs({-1,1}) do
   line(area,976+side*63,559,.3,38)
   line(area,976+side*72.5,540,19,.3);line(area,976+side*72.5,578,19,.3)
   local x=976+side*84
   for _,dz in ipairs({-9,9}) do piece(area,"GoalPost",x,3.2,559+dz,.5,6.4,.5,white,Enum.Material.Metal) end
   piece(area,"GoalCrossbar",x,6.4,559,.5,.5,18,white,Enum.Material.Metal)
  end
 elseif id=="basketballField" then court(area,886,831,68,38)
 elseif id=="SportArea" then
  for _,x in ipairs({570,645}) do badminton(area,x,778) end
 elseif id=="Parking" or id=="Parking2" or id=="parking3" then
  local first,last,z
  if id=="Parking" then first,last,z=1114,1200,700
  elseif id=="Parking2" then first,last,z=1244,1286,380
  else first,last,z=170,645,375 end
  for x=first,last,9 do
   if inside(feature.polygonStuds,x,z-5) and inside(feature.polygonStuds,x,z+7) then
    line(area,x,z,.22,12)
   end
  end
  if id=="Parking2" then
   for z2=399,474,9 do if inside(feature.polygonStuds,1248,z2) and inside(feature.polygonStuds,1260,z2) then line(area,1254,z2,12,.22) end end
  end
  local shelters=if id=="parking3" then {210,310,410,510,610} elseif id=="Parking" then {1135,1180} else {1260}
  for _,x in ipairs(shelters) do
   local width=if id=="Parking2" then 20 else 36
   if inside(feature.polygonStuds,x-width/2,z+12) and inside(feature.polygonStuds,x+width/2,z+12) then
    piece(area,"ShelterRoof",x,9,z+12,width,.5,8,Color3.fromRGB(122,137,139),Enum.Material.Metal)
    for _,dx in ipairs({-width/2+1,width/2-1}) do piece(area,"ShelterPost",x+dx,4.4,z+14,.5,8.8,.5,steel,Enum.Material.Metal) end
   end
  end
 elseif id=="EastPlaza" then
  for _,x in ipairs({205,244,283}) do for _,z in ipairs({470,520}) do bench(area,x,z) end end
  piece(area,"PlazaPaving",244,.065,495,58,.03,58,Color3.fromRGB(189,188,174),Enum.Material.Concrete)
 elseif id=="StudentSpace" then
  for _,x in ipairs({435,455,475,495,515,535}) do bench(area,x,894) end
  for _,x in ipairs({444,480,516}) do
   piece(area,"StudyTable",x,2.4,881,8,.4,4,wood,Enum.Material.WoodPlanks)
   for _,dx in ipairs({-3,3}) do piece(area,"TableLeg",x+dx,1.2,881,.4,2.4,.4,steel,Enum.Material.Metal) end
   bench(area,x,876);bench(area,x,886)
   piece(area,"StudyCanopy",x,9,881,20,.4,16,Color3.fromRGB(127,145,140),Enum.Material.Metal)
   for _,dx in ipairs({-9,9}) do for _,dz in ipairs({-7,7}) do piece(area,"CanopyPost",x+dx,4.4,881+dz,.4,8.8,.4,steel,Enum.Material.Metal) end end
  end
 elseif id=="OpenField" then
  for _,x in ipairs({744,762,780}) do bench(area,x,795) end
  piece(area,"GardenWalk",762,.065,775,4,.03,55,Color3.fromRGB(170,169,153),Enum.Material.Concrete)
 end
 area.Parent=output;task.wait()
end
output.Parent=root
return "Built nine reserved campus areas with native surfaces, sports equipment, parking and seating"
