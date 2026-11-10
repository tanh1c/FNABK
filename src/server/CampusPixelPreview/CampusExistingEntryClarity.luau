-- Make existing center-facing entrances readable and clear obstructing gallery rails.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local archive=assert(game.ServerStorage:FindFirstChild("CampusEntryOriginals_v1"))
	local ids={"B3","B4","B9","B11","B12","C4","C5","C6","Facility7","Canteen"}
	local plans={}
	for _,id in ipairs(ids) do
		local b=buildings[id];assert(not b:FindFirstChild("CenterFacingEntrance_v1") and not archive:FindFirstChild(id))
		local west,east,apron
		for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") then
			if v.Name=="EntryFrame_West" then west=v elseif v.Name=="EntryFrame_East" then east=v elseif v.Name=="EntryApron" then apron=v end
		end end
		assert(west and east and apron,"Entry frames missing: "..id)
		local middle=(west.Position+east.Position)/2
		local right=east.Position-west.Position;right=Vector3.new(right.X,0,right.Z).Unit
		local outward=right:Cross(Vector3.yAxis)
		if outward:Dot(apron.Position-middle)<0 then right=-right;outward=-outward end
		local frame=CFrame.fromMatrix(Vector3.new(middle.X,0,middle.Z),right,Vector3.yAxis,outward)
		local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={b}
		local blocked={}
		for _,p in ipairs(workspace:GetPartBoundsInBox(frame*CFrame.new(0,4.5,2.5),Vector3.new(3,6,9),params)) do
			if p:IsA("BasePart") and p.CanCollide then
				assert((p.Name:match("^GalleryRail_.*Floor_01_") or p.Name:match("^GallerySupport_.*Floor_01_")) and #p:GetChildren()==0,"Unexpected entry obstacle at "..id..": "..p.Name)
				table.insert(blocked,p)
			end
		end
		table.insert(plans,{b=b,frame=frame,blocked=blocked,width=(east.Position-west.Position).Magnitude})
	end
	local blockedCount=0
	for _,plan in ipairs(plans) do
		local b,frame=plan.b,plan.frame
		local result=Instance.new("Model");result.Name="CenterFacingEntrance_v1";result:SetAttribute("EntranceDirection","toward_central_road")
		local backup=Instance.new("Folder");backup.Name=b.Name
		for _,p in ipairs(plan.blocked) do
			local axisX=p.Size.X>p.Size.Z;local length=if axisX then p.Size.X else p.Size.Z
			if length>5 then
				local q=p.CFrame:PointToObjectSpace(Vector3.new(frame.Position.X,p.Position.Y,frame.Position.Z))
				local center=if axisX then q.X else q.Z;local half=length/2
				for _,interval in ipairs({{-half,math.min(half,center-1.9)},{math.max(-half,center+1.9),half}}) do
					local a,z=interval[1],interval[2]
					if z-a>.05 then
						local piece=p:Clone();piece.Name=p.Name.."_EntranceTrim"
						piece.Size=if axisX then Vector3.new(z-a,p.Size.Y,p.Size.Z) else Vector3.new(p.Size.X,p.Size.Y,z-a)
						piece.CFrame=p.CFrame*CFrame.new(if axisX then (a+z)/2 else 0,0,if axisX then 0 else (a+z)/2);piece.Parent=result
					end
				end
			end
		end
		local function part(name,size,cf,color,collide)
			local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf;p.Color,p.Material=color,Enum.Material.Concrete
			p.Anchored,p.CanCollide,p.CanTouch=true,collide,false;p.Parent=result;return p
		end
		local width=math.clamp(plan.width+3,7,12)
		part("EntryCanopy",Vector3.new(width,.55,4.5),frame*CFrame.new(0,10.2,2.25),Color3.fromRGB(42,79,100),true)
		for _,x in ipairs({-width/2+.5,width/2-.5}) do part("EntryColumn",Vector3.new(.6,10,.6),frame*CFrame.new(x,5,4),Color3.fromRGB(221,220,207),true) end
		local doorWidth=math.min(3.2,plan.width-.3);assert(doorWidth>2)
		local closed=frame*CFrame.new(0,4.8,0)
		local open=frame*CFrame.new(-doorWidth/2,4.8,0)*CFrame.Angles(0,-math.pi/2,0)*CFrame.new(doorWidth/2,0,0)
		local door=part("MainEntryDoor",Vector3.new(doorWidth,8,.2),open,Color3.fromRGB(120,86,59),false)
		door.Material=Enum.Material.WoodPlanks;door:SetAttribute("CampusDoor",true);door:SetAttribute("DoorClosed",closed);door:SetAttribute("DoorOpen",open);door:SetAttribute("StartsOpen",true)
		for _,p in ipairs(plan.blocked) do p:SetAttribute("OriginalParentPath",p.Parent:GetFullName());p.Parent=backup;blockedCount+=1 end
		backup.Parent=archive;result.Parent=b;task.wait()
	end
	return "Clarified "..#plans.." existing entrances and preserved "..blockedCount.." rail or support obstacles"
end
