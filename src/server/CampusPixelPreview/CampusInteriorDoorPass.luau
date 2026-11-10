-- Match corridor headers to furnished rooms, leaving stair and lobby openings alone.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local plans={}
	for _,building in ipairs(buildings:GetChildren()) do if building:IsA("Model") and building.Name~="B1" then
		local headers,rooms={},{}
		for _,v in ipairs(building:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:match("^CorridorWall_F%d%d_Side_.+_Header_%d+") then table.insert(headers,v) end
			if v:IsA("Model") and v.Parent and v.Parent.Name=="Furnishings" and v:GetAttribute("FloorIndex") then
				local cf,size=v:GetBoundingBox()
				if size.Magnitude>0 then table.insert(rooms,{instance=v,position=cf.Position,floor=v:GetAttribute("FloorIndex")}) end
			end
		end
		if #headers>0 then
			assert(not building:FindFirstChild("CampusInteriorDoors_v1"),"Interior pass already applied")
			table.sort(rooms,function(a,b) if a.floor~=b.floor then return a.floor<b.floor end return a.instance.Name<b.instance.Name end)
			local used,numbers={},{}
			for _,room in ipairs(rooms) do
				local best,distance=nil,math.huge
				for _,header in ipairs(headers) do if tonumber(header.Name:match("_F(%d%d)_"))==room.floor then
					local delta=header.Position-room.position
					local d=Vector3.new(delta.X,0,delta.Z).Magnitude
					if d<distance then best,distance=header,d end
				end end
				assert(best and not used[best] and distance<45,"Room/header mapping is ambiguous in "..building.Name)
				used[best]=true
				numbers[room.floor]=(numbers[room.floor] or 0)+1
				room.header=best
				room.id=string.format("%s-%d%02d",building.Name,room.floor,numbers[room.floor])
			end
			table.insert(plans,{building=building,rooms=rooms})
		end
	end end
	local total=0
	for _,plan in ipairs(plans) do
		local folder=Instance.new("Folder");folder.Name="CampusInteriorDoors_v1"
		for _,room in ipairs(plan.rooms) do
			local h=room.header
			local alongX=h.Size.X>h.Size.Z
			local width=math.min((if alongX then h.Size.X else h.Size.Z)-0.1,4.2)
			local base=0.8+(room.floor-1)*12.85714
			local height=h.Position.Y-h.Size.Y/2-base
			assert(width>0.5 and height>3 and height<12,"Invalid opening: "..h:GetFullName())
			local size=if alongX then Vector3.new(width,height,0.16) else Vector3.new(0.16,height,width)
			local closed=h.CFrame*CFrame.new(0,-h.Size.Y/2-height/2,0)
			local direction=if alongX then closed.RightVector else -closed.LookVector
			local hinge=closed.Position-direction*width/2
			local function rotated(angle) return CFrame.new(hinge)*CFrame.Angles(0,angle,0)*CFrame.new(-hinge)*closed end
			local a,b=rotated(math.pi/2),rotated(-math.pi/2)
			local toward=room.position-closed.Position
			local open=if (a.Position-closed.Position):Dot(toward)>(b.Position-closed.Position):Dot(toward) then a else b
			local leaf=Instance.new("Part");leaf.Name="InteriorClassDoor";leaf.Size,leaf.CFrame=size,open
			leaf.Color,leaf.Material=Color3.fromRGB(130,93,64),Enum.Material.WoodPlanks
			leaf.Anchored,leaf.CanCollide,leaf.CanTouch=true,false,false
			leaf:SetAttribute("CampusDoor",true);leaf:SetAttribute("DoorOpen",open);leaf:SetAttribute("DoorClosed",closed);leaf:SetAttribute("StartsOpen",true)
			leaf:SetAttribute("ClassroomID",room.id);leaf.Parent=folder
			local plate=Instance.new("Part");plate.Name="InteriorClassroomNumber";plate.Size=Vector3.new(2.8,1.2,0.15)
			plate.CFrame=h.CFrame*CFrame.new(0,-h.Size.Y/2+0.8,0)*(if alongX then CFrame.new() else CFrame.Angles(0,math.pi/2,0))
			plate.Color,plate.Material=Color3.fromRGB(40,78,99),Enum.Material.SmoothPlastic
			plate.Anchored,plate.CanCollide,plate.CanTouch,plate.CanQuery=true,false,false,false;plate.Parent=folder
			for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
				local gui=Instance.new("SurfaceGui");gui.Face,gui.LightInfluence,gui.Parent=face,0,plate
				local text=Instance.new("TextLabel");text.Size,text.BackgroundTransparency,text.Text=UDim2.fromScale(1,1),1,room.id
				text.TextColor3,text.TextScaled,text.Font,text.Parent=Color3.new(1,1,1),true,Enum.Font.GothamBold,gui
			end
			room.instance:SetAttribute("CampusRoomId",room.id)
			total+=1
		end
		folder.Parent=plan.building
		task.wait()
	end
	assert(total==471,"Unexpected total interior rooms")
	return "Added "..total.." interior classroom/room doors and matching room numbers; stair halls were not selected"
end
