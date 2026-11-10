-- Two center-facing side entrances, selected to avoid desks and stair geometry.
return function(requested)
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local archive=assert(game.ServerStorage:FindFirstChild("CampusEntryOriginals_v1"))
	local specs={{id="A1",x=5095,z=1693.5,depth=26},{id="B8",x=4948,z=1869,depth=18},{id="A3",x=4760,z=1735.5,depth=59}}
	local plans={}
	for _,s in ipairs(specs) do
		if requested and requested~=s.id then continue end
		local b=buildings[s.id];assert(not b:FindFirstChild("CenterFacingEntrance_v1") and not archive:FindFirstChild(s.id))
		local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={b}
		local walls={};local outer
		for _,v in ipairs(workspace:GetPartBoundsInBox(CFrame.new(s.x,4.8,s.z),Vector3.new(3,7,s.depth),p)) do if v:IsA("BasePart") and v.CanCollide then
			assert(v.Name=="OuterWall_Floor_01_North" or v.Name:match("^CorridorWall_F01_Side_West_Wall_%d+"),"Unexpected side-entrance obstacle: "..v.Name)
			assert(#v:GetChildren()==0,"Wall has children")
			table.insert(walls,v);if v.Name=="OuterWall_Floor_01_North" then outer=v end
		end end
		assert(#walls==2 and outer,"Unexpected side-entrance wall layout")
		table.insert(plans,{spec=s,building=b,walls=walls,outer=outer})
	end
	for _,plan in ipairs(plans) do
		local b,outer,s=plan.building,plan.outer,plan.spec
		local localPoint=outer.CFrame:PointToObjectSpace(Vector3.new(s.x,outer.Position.Y,outer.Position.Z))
		local frame=outer.CFrame*CFrame.new(localPoint.X,-outer.Position.Y,0)
		local entry=Instance.new("Model");entry.Name="CenterFacingEntrance_v1";entry:SetAttribute("EntranceDirection","toward_central_road")
		local backup=Instance.new("Folder");backup.Name=s.id
		for _,wall in ipairs(plan.walls) do
			local axisX=wall.Size.X>wall.Size.Z;local length=if axisX then wall.Size.X else wall.Size.Z
			local p=wall.CFrame:PointToObjectSpace(Vector3.new(s.x,wall.Position.Y,wall.Position.Z));local c=if axisX then p.X else p.Z
			local min,max=-length/2,length/2;assert(c-1.7>min and c+1.7<max,"Entry does not fit wall")
			local function section(a,z,lo,hi)
				if z-a<0.05 or hi-lo<0.05 then return end
				local q=wall:Clone();q.Name=wall.Name.."_EntryTrim"
				q.Size=if axisX then Vector3.new(z-a,hi-lo,wall.Size.Z) else Vector3.new(wall.Size.X,hi-lo,z-a)
				q.CFrame=wall.CFrame*CFrame.new(if axisX then (a+z)/2 else 0,(lo+hi)/2,if axisX then 0 else (a+z)/2);q.Parent=entry
			end
			local lo,hi=-wall.Size.Y/2,wall.Size.Y/2
			section(min,c-1.7,lo,hi);section(c+1.7,max,lo,hi);section(c-1.7,c+1.7,math.min(hi,8.8-wall.Position.Y),hi)
		end
		local function part(name,size,cf,color,collide)
			local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf;p.Color,p.Material=color,Enum.Material.Concrete
			p.Anchored,p.CanCollide,p.CanTouch=true,collide,false;p.Parent=entry;return p
		end
		part("EntryCanopy",Vector3.new(7,0.55,4),frame*CFrame.new(0,10.1,2),Color3.fromRGB(42,79,100),true)
		for _,x in ipairs({-3,3}) do part("EntryColumn",Vector3.new(.65,9.8,.65),frame*CFrame.new(x,4.9,3.5),Color3.fromRGB(221,220,207),true) end
		local closed=frame*CFrame.new(0,4.8,0)
		local open=frame*CFrame.new(-1.6,4.8,0)*CFrame.Angles(0,-math.pi/2,0)*CFrame.new(1.6,0,0)
		local d=part("MainEntryDoor",Vector3.new(3.2,8,.2),open,Color3.fromRGB(120,86,59),false)
		d.Material=Enum.Material.WoodPlanks;d:SetAttribute("CampusDoor",true);d:SetAttribute("DoorClosed",closed);d:SetAttribute("DoorOpen",open);d:SetAttribute("StartsOpen",true)
		for _,wall in ipairs(plan.walls) do wall:SetAttribute("OriginalParentPath",wall.Parent:GetFullName());wall.Parent=backup end
		backup.Parent=archive;entry.Parent=b;task.wait()
	end
	return "Built "..#plans.." center-facing side entrances; original walls preserved"
end
