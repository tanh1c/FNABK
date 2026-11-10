-- Replace B11's blocked approach with an unobstructed center-facing side entrance.
return function()
	local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B11
	local prior=assert(b:FindFirstChild("CenterFacingEntrance_v1"))
	local archive=assert(game.ServerStorage.CampusEntryOriginals_v1:FindFirstChild("B11"))
	assert(not archive:FindFirstChild("SupersededEntryClarity_v1"))
	local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={b}
	local walls={};local outer
	for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(4785.5,4.8,1940),Vector3.new(20,7,3),params)) do if p:IsA("BasePart") and p.CanCollide then
		assert(p.Name=="OuterWall_Floor_01_West" or p.Name=="CorridorWall_F01_Side_West_Wall_02","Unexpected B11 entry obstacle: "..p.Name)
		assert(#p:GetChildren()==0);table.insert(walls,p);if p.Name=="OuterWall_Floor_01_West" then outer=p end
	end end
	assert(#walls==2 and outer,"B11 wall layout changed")
	local outward=-outer.CFrame.RightVector
	local right=Vector3.yAxis:Cross(outward)
	local frame=CFrame.fromMatrix(Vector3.new(outer.Position.X,0,1940),right,Vector3.yAxis,outward)
	local entry=Instance.new("Model");entry.Name="CenterFacingEntrance_v1";entry:SetAttribute("EntranceDirection","toward_central_road")
	for _,wall in ipairs(walls) do
		local axisX=wall.Size.X>wall.Size.Z;local length=if axisX then wall.Size.X else wall.Size.Z
		local point=wall.CFrame:PointToObjectSpace(Vector3.new(wall.Position.X,wall.Position.Y,1940));local c=if axisX then point.X else point.Z
		local lo,hi=-wall.Size.Y/2,wall.Size.Y/2;local half=length/2
		assert(c-1.7> -half and c+1.7<half)
		local function slice(a,z,bottom,top)
			if z-a<.05 or top-bottom<.05 then return end
			local q=wall:Clone();q.Name=wall.Name.."_EntryTrim"
			q.Size=if axisX then Vector3.new(z-a,top-bottom,wall.Size.Z) else Vector3.new(wall.Size.X,top-bottom,z-a)
			q.CFrame=wall.CFrame*CFrame.new(if axisX then (a+z)/2 else 0,(bottom+top)/2,if axisX then 0 else (a+z)/2);q.Parent=entry
		end
		slice(-half,c-1.7,lo,hi);slice(c+1.7,half,lo,hi);slice(c-1.7,c+1.7,math.min(hi,8.8-wall.Position.Y),hi)
	end
	local function part(name,size,cf,color,collide)
		local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf;p.Color,p.Material=color,Enum.Material.Concrete
		p.Anchored,p.CanCollide,p.CanTouch=true,collide,false;p.Parent=entry;return p
	end
	part("EntryCanopy",Vector3.new(7,.55,4),frame*CFrame.new(0,10.1,2),Color3.fromRGB(42,79,100),true)
	for _,x in ipairs({-3,3}) do part("EntryColumn",Vector3.new(.65,9.8,.65),frame*CFrame.new(x,4.9,3.5),Color3.fromRGB(221,220,207),true) end
	local closed=frame*CFrame.new(0,4.8,0)
	local open=frame*CFrame.new(-1.6,4.8,0)*CFrame.Angles(0,-math.pi/2,0)*CFrame.new(1.6,0,0)
	local door=part("MainEntryDoor",Vector3.new(3.2,8,.2),open,Color3.fromRGB(120,86,59),false)
	door.Material=Enum.Material.WoodPlanks;door:SetAttribute("CampusDoor",true);door:SetAttribute("DoorClosed",closed);door:SetAttribute("DoorOpen",open);door:SetAttribute("StartsOpen",true)
	for _,wall in ipairs(walls) do wall:SetAttribute("OriginalParentPath",wall.Parent:GetFullName());wall.Parent=archive end
	prior.Name="SupersededEntryClarity_v1";prior.Parent=archive;entry.Parent=b
	return "Created B11 center-facing side entry away from B12; previous parts preserved"
end
