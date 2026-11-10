-- Repair floor-aware, one-to-one room signs; preserve the preceding text on each label.
return function()
	local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local plans,usedPlates={},{}
	local matched,access,dining=0,0,0
	for _,b in ipairs(root:GetChildren()) do if b:IsA("Model") and b.Name~="B1" then
		local hall,rooms,doors=nil,{},{}
		for _,v in ipairs(b:GetDescendants()) do
			if v:IsA("BasePart") and v.Name=="HallRunner_Floor_01" then hall=v
			elseif v:IsA("BasePart") and v.Name:match("^GalleryClassroomDoor_F%d%d_Side_") then table.insert(doors,v)
			elseif v:IsA("Model") and v:GetAttribute("CampusRoomId") then
				local cf=v:GetBoundingBox();table.insert(rooms,{pos=cf.Position,floor=v:GetAttribute("FloorIndex"),id=v:GetAttribute("CampusRoomId")})
			end
		end
		if #doors>0 then
			assert(hall,"Missing corridor for "..b.Name)
			table.sort(doors,function(a,c) return a.Name<c.Name end)
			local candidates,areaNumbers={},{}
			for _,door in ipairs(doors) do
				local floor=tonumber(door.Name:match("_F(%d%d)_"));local expectedY=door.Position.Y+door.Size.Y/2+.8
				local plate,distance=nil,math.huge
				for _,p in ipairs(door.Parent:GetChildren()) do if p:IsA("BasePart") and p.Name=="ClassroomNumber" then
					local d=p.Position-door.Position;local flat=Vector3.new(d.X,0,d.Z).Magnitude
					if math.abs(p.Position.Y-expectedY)<.2 and flat<distance then plate,distance=p,flat end
				end end
				assert(plate and distance<.2 and not usedPlates[plate],"Room plate matching failed for "..b.Name)
				usedPlates[plate]=true
				local labels={};for _,v in ipairs(plate:GetDescendants()) do if v:IsA("TextLabel") then table.insert(labels,v) end end
				assert(#labels==2,"Room plate must have two faces")
				if b.Name=="Canteen" then
					areaNumbers[floor]=(areaNumbers[floor] or 0)+1
					table.insert(plans,{plate=plate,labels=labels,value=string.format("KHU %d-%02d",floor,areaNumbers[floor])});dining+=1
				else
					local side=hall.CFrame:PointToObjectSpace(door.Position).X;local room,dist=nil,math.huge
					for _,r in ipairs(rooms) do if r.floor==floor and side*hall.CFrame:PointToObjectSpace(r.pos).X>0 then
						local delta=door.Position-r.pos;local d=Vector3.new(delta.X,0,delta.Z).Magnitude
						if d<dist then room,dist=r,d end
					end end
					table.insert(candidates,{room=room,distance=dist,plate=plate,labels=labels})
				end
			end
			table.sort(candidates,function(a,c) return a.distance<c.distance end)
			local assigned={}
			for _,candidate in ipairs(candidates) do
				local value
				if candidate.room and candidate.distance<35 and not assigned[candidate.room] then
					value=candidate.room.id;assigned[candidate.room]=true;matched+=1
				else value="LỐI ĐI";access+=1 end
				table.insert(plans,{plate=candidate.plate,labels=candidate.labels,value=value})
			end
		end
	end end
	assert(#plans==336 and dining==14,"Unexpected number of exterior room plates")
	for _,plan in ipairs(plans) do
		plan.plate:SetAttribute("RoomLabel",plan.value)
		for _,label in ipairs(plan.labels) do
			if label:GetAttribute("BeforeRoomLabelRepair")==nil then label:SetAttribute("BeforeRoomLabelRepair",label.Text) end
			label.Text=plan.value
		end
	end
	return string.format("Repaired %d exterior room labels, %d access labels and %d canteen-area labels",matched,access,dining)
end
