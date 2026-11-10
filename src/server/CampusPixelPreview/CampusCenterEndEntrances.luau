-- Center-facing entrances on four verified corridor ends; original wall pieces are kept.
return function(requested)
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local specs={{"A2","OuterWall_Floor_01_North"},{"A4","OuterWall_Floor_01_East"},{"A5","OuterWall_Floor_01_East"},{"B6","OuterWall_Floor_01_West"},{"KioskOISP","OuterWall_Floor_01_East"}}
	local archive=assert(game.ServerStorage:FindFirstChild("CampusEntryOriginals_v1"))
	local plans={}
	for _,spec in ipairs(specs) do
		if requested and requested~=spec[1] then continue end
		local b=assert(buildings:FindFirstChild(spec[1]));assert(not b:FindFirstChild("CenterFacingEntrance_v1"));assert(not archive:FindFirstChild(spec[1]))
		local wall,hall
		for _,p in ipairs(b:GetDescendants()) do if p:IsA("BasePart") then
			if p.Name==spec[2] then assert(not wall);wall=p elseif p.Name=="HallRunner_Floor_01" then assert(not hall);hall=p end
		end end
		assert(wall and hall,"Missing wall or corridor: "..spec[1])
		local outward=if wall.Size.X<wall.Size.Z then wall.CFrame.RightVector else wall.CFrame.LookVector
		if outward:Dot(wall.Position-hall.Position)<0 then outward=-outward end
		local right=Vector3.yAxis:Cross(outward)
		local frame=CFrame.fromMatrix(Vector3.new(wall.Position.X,0,wall.Position.Z),right,Vector3.yAxis,outward)
		local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={b}
		local targets={wall}
		for _,p in ipairs(workspace:GetPartBoundsInBox(frame*CFrame.new(0,4.5,1),Vector3.new(3,6.5,16),params)) do
			if p:IsA("BasePart") and p.Name=="GalleryCornerRail_Floor_01" then table.insert(targets,p) end
		end
		assert(#targets==(if spec[1]=="A4" then 2 else 1),"Unexpected gallery rail")
		for _,p in ipairs(targets) do assert(#p:GetChildren()==0,"Target has children") end
		table.insert(plans,{b=b,frame=frame,targets=targets})
	end
	for _,plan in ipairs(plans) do
		local b,frame=plan.b,plan.frame
		local backup=Instance.new("Folder");backup.Name=b.Name
		local entry=Instance.new("Model");entry.Name="CenterFacingEntrance_v1"
		entry:SetAttribute("EntranceDirection","toward_central_road")
		for _,wall in ipairs(plan.targets) do
			local alongX=wall.Size.X>wall.Size.Z;local length=if alongX then wall.Size.X else wall.Size.Z
			local point=wall.CFrame:PointToObjectSpace(Vector3.new(frame.Position.X,wall.Position.Y,frame.Position.Z))
			local c=if alongX then point.X else point.Z
			local min,max=-length/2,length/2;assert(c-1.7>min and c+1.7<max,"Door does not fit")
			local function section(a,z,lo,hi)
				if z-a<0.05 or hi-lo<0.05 then return end
				local p=wall:Clone();p.Name=wall.Name.."_EntranceTrim"
				p.Size=if alongX then Vector3.new(z-a,hi-lo,wall.Size.Z) else Vector3.new(wall.Size.X,hi-lo,z-a)
				p.CFrame=wall.CFrame*CFrame.new(if alongX then (a+z)/2 else 0,(lo+hi)/2,if alongX then 0 else (a+z)/2);p.Parent=entry
			end
			local lo,hi=-wall.Size.Y/2,wall.Size.Y/2
			section(min,c-1.7,lo,hi);section(c+1.7,max,lo,hi)
			if wall.Name:match("^OuterWall") then section(c-1.7,c+1.7,math.min(hi,8.8-wall.Position.Y),hi) end
		end
		local function part(name,size,cf,color,collide)
			local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf;p.Color,p.Material=color,Enum.Material.Concrete
			p.Anchored,p.CanCollide,p.CanTouch=true,collide,false;p.Parent=entry;return p
		end
		local cream=Color3.fromRGB(221,220,207);local blue=Color3.fromRGB(42,79,100)
		part("EntryCanopy",Vector3.new(7,0.55,4),frame*CFrame.new(0,10.1,2),blue,true)
		for _,x in ipairs({-3,3}) do part("EntryColumn",Vector3.new(0.65,9.8,0.65),frame*CFrame.new(x,4.9,3.5),cream,true) end
		local closed=frame*CFrame.new(0,4.8,0)
		local open=frame*CFrame.new(-1.6,4.8,0)*CFrame.Angles(0,-math.pi/2,0)*CFrame.new(1.6,0,0)
		local door=part("MainEntryDoor",Vector3.new(3.2,8,0.2),open,Color3.fromRGB(120,86,59),false)
		door.Material=Enum.Material.WoodPlanks;door:SetAttribute("CampusDoor",true);door:SetAttribute("DoorClosed",closed);door:SetAttribute("DoorOpen",open);door:SetAttribute("StartsOpen",true)
		for _,wall in ipairs(plan.targets) do wall:SetAttribute("OriginalParentPath",wall.Parent:GetFullName());wall.Parent=backup end
		backup.Parent=archive;entry.Parent=b
		task.wait()
	end
	return "Built "..#plans.." center-facing corridor-end entrances; originals preserved"
end
