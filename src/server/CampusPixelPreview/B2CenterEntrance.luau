-- AI-assisted B2 primary entry on the center-facing facade; originals are preserved.
return function()
	local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B2
	assert(not b:FindFirstChild("CenterFacingEntrance_v1"),"B2 entrance already exists")
	local storage=game:GetService("ServerStorage")
	local archive=storage:FindFirstChild("CampusEntryOriginals_v1")
	if not archive then archive=Instance.new("Folder");archive.Name="CampusEntryOriginals_v1";archive.Parent=storage end
	assert(not archive:FindFirstChild("B2"),"B2 entrance backup already exists")
	local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={b}
	local walls={}
	for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(5335,4.8,1675),Vector3.new(6,7,25),params)) do
		if p:IsA("BasePart") and p.CanCollide then
			assert((p.Name=="CorridorWall_F01_Side_West_Wall_04" or p.Name=="GalleryClassroomWall_F01_Side_West_Wall_07") and #p:GetChildren()==0,"Unexpected obstacle in B2 entry")
			table.insert(walls,p)
		end
	end
	assert(#walls==2,"B2 entry walls changed")
	local result=Instance.new("Model");result.Name="CenterFacingEntrance_v1"
	local backup=Instance.new("Folder");backup.Name="B2"
	for _,wall in ipairs(walls) do
		local localPoint=wall.CFrame:PointToObjectSpace(Vector3.new(5335,wall.Position.Y,wall.Position.Z))
		local alongX=wall.Size.X>wall.Size.Z
		local center=if alongX then localPoint.X else localPoint.Z
		local length=if alongX then wall.Size.X else wall.Size.Z
		local min,max=-length/2,length/2
		assert(center-3>min and center+3<max,"Entry does not fit wall")
		local function section(a,c,loY,hiY,name)
			if c-a<=0.05 or hiY-loY<=0.05 then return end
			local q=wall:Clone();q.Name=name
			q.Size=if alongX then Vector3.new(c-a,hiY-loY,wall.Size.Z) else Vector3.new(wall.Size.X,hiY-loY,c-a)
			q.CFrame=wall.CFrame*CFrame.new(if alongX then (a+c)/2 else 0,(loY+hiY)/2,if alongX then 0 else (a+c)/2)
			q.Parent=result
		end
		local bottom=-wall.Size.Y/2;local top=wall.Size.Y/2
		local cutTop=math.min(top,8.8-wall.Position.Y)
		section(min,center-3,bottom,top,"EntryWallLeft")
		section(center+3,max,bottom,top,"EntryWallRight")
		section(center-3,center+3,cutTop,top,"EntryWallHeader")
	end
	local function part(name,size,cf,color,collide)
		local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf
		p.Color,p.Material=color,Enum.Material.Concrete;p.Anchored,p.CanCollide,p.CanTouch=true,collide,false;p.Parent=result;return p
	end
	local cream=Color3.fromRGB(221,220,207);local blue=Color3.fromRGB(42,79,100)
	part("EntryCanopy",Vector3.new(10,0.65,5),CFrame.new(5335,10.2,1688.7),blue,true)
	for _,x in ipairs({5330.7,5339.3}) do part("EntryColumn",Vector3.new(0.8,10,0.8),CFrame.new(x,5,1690.5),cream,true) end
	for _,side in ipairs({-1,1}) do
		local hinge=Vector3.new(5335+side*3,4.8,1685.9)
		local closed=CFrame.new(5335+side*1.5,4.8,1685.9)
		local open=CFrame.new(hinge)*CFrame.Angles(0,side*math.pi/2,0)*CFrame.new(-hinge)*closed
		local door=part(if side<0 then "MainDoorLeft" else "MainDoorRight",Vector3.new(2.9,8,0.2),open,Color3.fromRGB(120,86,59),false)
		door.Material=Enum.Material.WoodPlanks
		door:SetAttribute("CampusDoor",true);door:SetAttribute("DoorClosed",closed);door:SetAttribute("DoorOpen",open);door:SetAttribute("StartsOpen",true)
	end
	for _,wall in ipairs(walls) do wall:SetAttribute("OriginalParentPath",wall.Parent:GetFullName());wall.Parent=backup end
	backup.Parent=archive;result.Parent=b
	return "B2 center-facing main entrance created; two original walls preserved in ServerStorage"
end
