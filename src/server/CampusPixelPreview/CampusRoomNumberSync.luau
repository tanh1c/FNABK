-- Match outside room plates to the same furnished-room identifiers used inside.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local matched,access=0,0
	for _,building in ipairs(buildings:GetChildren()) do if building:IsA("Model") and building.Name~="B1" then
		local rooms,doors={},{}
		for _,v in ipairs(building:GetDescendants()) do
			if v:IsA("Model") and v:GetAttribute("CampusRoomId") then
				local cf=v:GetBoundingBox();table.insert(rooms,{id=v:GetAttribute("CampusRoomId"),floor=v:GetAttribute("FloorIndex"),pos=cf.Position})
			elseif v:IsA("BasePart") and v.Name:match("^GalleryClassroomDoor_F%d%d_Side_") then table.insert(doors,v) end
		end
		local candidates={}
		for _,door in ipairs(doors) do
			local floor=tonumber(door.Name:match("_F(%d%d)_"));local best,distance=nil,math.huge
			for _,room in ipairs(rooms) do if room.floor==floor then
				local d=door.Position-room.pos;local n=Vector3.new(d.X,0,d.Z).Magnitude
				if n<distance then best,distance=room,n end
			end end
			local plate,plateDistance=nil,math.huge
			for _,v in ipairs(door.Parent:GetChildren()) do if v:IsA("BasePart") and v.Name=="ClassroomNumber" then
				local d=v.Position-door.Position;local n=Vector3.new(d.X,0,d.Z).Magnitude
				if n<plateDistance and math.abs(d.Y)<8 then plate,plateDistance=v,n end
			end end
			assert(best and plate and plateDistance<0.5,"Unable to match outer room plate")
			table.insert(candidates,{room=best,plate=plate,distance=distance})
		end
		table.sort(candidates,function(a,b) return a.distance<b.distance end)
		local used={}
		for _,c in ipairs(candidates) do
			local value
			if not used[c.room] and c.distance<35 then value=c.room.id;used[c.room]=true;matched+=1
			else value="ACCESS";access+=1 end
			for _,v in ipairs(c.plate:GetDescendants()) do if v:IsA("TextLabel") then
				v:SetAttribute("OriginalGeneratedText",v.Text);v.Text=value
			end end
		end
	end end
	assert(matched+access==336,"Unexpected outer plate count")
	return string.format("Synchronized %d exterior room plates; marked %d ambiguous lobby or stair accesses",matched,access)
end
