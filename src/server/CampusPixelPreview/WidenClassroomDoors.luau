-- Widen the underscaled A3/B2 interior door gaps; preserve all original wall pieces.
return function()
	local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local storage=game:GetService("ServerStorage")
	assert(not storage:FindFirstChild("ClassroomWidthBackup_v1"),"Width pass already exists")
	local plans={}
	for _,id in ipairs({"A3","B2"}) do
		local b=root[id];assert(not b:FindFirstChild("WidenedClassroomWalls_v1"))
		local headers={}
		for _,h in ipairs(b:GetDescendants()) do if h:IsA("BasePart") and h.Name:match("^CorridorWall_F%d%d_Side_.+_Header_%d+") then table.insert(headers,h) end end
		local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={b}
		local doors,cuts,used={}, {}, {}
		for _,door in ipairs(b.CampusInteriorDoors_v1:GetChildren()) do
			if door:IsA("BasePart") and door.Name=="InteriorClassDoor" and math.max(door.Size.X,door.Size.Z)<2 then
				local closed=door:GetAttribute("DoorClosed");local best,distance=nil,math.huge
				for _,h in ipairs(headers) do
					local delta=h.Position-closed.Position;local d=Vector3.new(delta.X,0,delta.Z).Magnitude
					if math.abs((h.Position.Y-h.Size.Y/2)-(closed.Position.Y+door.Size.Y/2))<.2 and d<distance then best,distance=h,d end
				end
				assert(best and distance<.2 and not used[best],"Ambiguous classroom header")
				used[best]=true;table.insert(doors,{door=door,header=best})
				local axisX=best.Size.X>best.Size.Z
				local box=if axisX then Vector3.new(3.2,door.Size.Y-.1,.9) else Vector3.new(.9,door.Size.Y-.1,3.2)
				local cf=best.CFrame*CFrame.new(0,closed.Position.Y-best.Position.Y+.05,0)
				for _,part in ipairs(workspace:GetPartBoundsInBox(cf,box,params)) do if part:IsA("BasePart") and part.CanCollide then
					local canCut=part.Name:match("^CorridorWall_F%d%d_Side_.*_Wall") or part.Name=="EntryWallLeft" or part.Name=="EntryWallRight"
					if canCut then
						assert(#part:GetChildren()==0,"Wall has children")
						local localPoint=part.CFrame:PointToObjectSpace(closed.Position)
						local longX=part.Size.X>part.Size.Z;local center=if longX then localPoint.X else localPoint.Z
						cuts[part]=cuts[part] or {};table.insert(cuts[part],{center-1.6,center+1.6})
					elseif not part.Name:match("^WalkableFloor_") and not part.Name:match("^CorridorWall_F%d%d_Side_.*_Header_") then
						error("Unexpected obstruction in "..id..": "..part.Name)
					end
				end end
			end
		end
		assert(#doors==(if id=="A3" then 33 else 26),"Unexpected narrow-door count")
		table.insert(plans,{building=b,doors=doors,cuts=cuts})
	end
	local backup=Instance.new("Folder");backup.Name="ClassroomWidthBackup_v1";backup.Parent=storage
	local total,wallCount=0,0
	for _,plan in ipairs(plans) do
		local saved=Instance.new("Folder");saved.Name=plan.building.Name;saved.Parent=backup
		local segments=Instance.new("Folder");segments.Name="WidenedClassroomWalls_v1"
		for wall,intervals in pairs(plan.cuts) do
			local longX=wall.Size.X>wall.Size.Z;local length=if longX then wall.Size.X else wall.Size.Z
			local half=length/2;table.sort(intervals,function(a,b) return a[1]<b[1] end)
			local cursor=-half
			local function keep(a,z)
				if z-a<=.05 then return end
				local copy=wall:Clone();copy.Name=wall.Name.."_Wide"
				copy.Size=if longX then Vector3.new(z-a,wall.Size.Y,wall.Size.Z) else Vector3.new(wall.Size.X,wall.Size.Y,z-a)
				copy.CFrame=wall.CFrame*CFrame.new(if longX then (a+z)/2 else 0,0,if longX then 0 else (a+z)/2);copy.Parent=segments
			end
			for _,gap in ipairs(intervals) do local a,z=math.max(-half,gap[1]),math.min(half,gap[2]);if a>cursor then keep(cursor,a) end;cursor=math.max(cursor,z) end
			if cursor<half then keep(cursor,half) end
			wall:SetAttribute("OriginalParentPath",wall.Parent:GetFullName());wall.Parent=saved;wallCount+=1
		end
		for _,item in ipairs(plan.doors) do
			local door,header=item.door,item.header
			local old=header:Clone();old:SetAttribute("OriginalParentPath",header.Parent:GetFullName());old.Parent=saved
			local headerX=header.Size.X>header.Size.Z
			header.Size=if headerX then Vector3.new(3.2,header.Size.Y,header.Size.Z) else Vector3.new(header.Size.X,header.Size.Y,3.2)
			local closed,previous=door:GetAttribute("DoorClosed"),door:GetAttribute("DoorOpen")
			local alongX=door.Size.X>door.Size.Z
			door:SetAttribute("OriginalWidthSize",door.Size);door:SetAttribute("OriginalDoorOpen",previous)
			door.Size=if alongX then Vector3.new(3,door.Size.Y,door.Size.Z) else Vector3.new(door.Size.X,door.Size.Y,3)
			local long=if alongX then closed.RightVector else -closed.LookVector
			local hinge=closed.Position-long*1.5
			local a=CFrame.new(hinge)*CFrame.Angles(0,math.pi/2,0)*CFrame.new(-hinge)*closed
			local b=CFrame.new(hinge)*CFrame.Angles(0,-math.pi/2,0)*CFrame.new(-hinge)*closed
			local oldDirection=previous.Position-closed.Position
			local open=if (a.Position-closed.Position):Dot(oldDirection)>(b.Position-closed.Position):Dot(oldDirection) then a else b
			door:SetAttribute("DoorOpen",open);door.CFrame=open;total+=1
		end
		segments.Parent=plan.building;task.wait()
	end
	return string.format("Widened %d classroom openings; preserved %d original wall segments",total,wallCount)
end
