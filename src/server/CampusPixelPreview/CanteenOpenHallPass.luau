-- Convert the classroom-derived canteen into two open dining halls; preserve removed parts.
return function()
	local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
	local storage=game:GetService("ServerStorage")
	assert(not b:FindFirstChild("CanteenOpenHall_v1") and not storage:FindFirstChild("CanteenBeforeOpenHall_v1"),"Canteen hall pass already exists")
	assert(b:FindFirstChild("CanteenDining_v1"),"Dining furniture is required")
	local interior=assert(b:FindFirstChild("CampusInteriorDoors_v1"))
	local walls={};local stairCount=0
	for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") then
		if v.Name:match("^RoomDivider_F%d%d_") or v.Name:match("^CorridorWall_F%d%d_") then
			assert(#v:GetChildren()==0,"Canteen wall has children");table.insert(walls,v)
		elseif v.Name:find("Stair",1,true) then stairCount+=1 end
	end end
	assert(#walls==84 and stairCount>=30,"Unexpected canteen structure")
	local doors=0;for _,v in ipairs(interior:GetDescendants()) do if v:IsA("BasePart") and v:GetAttribute("CampusDoor") then doors+=1 end end
	assert(doors==25,"Unexpected canteen interior door count")
	local backup=Instance.new("Folder");backup.Name="CanteenBeforeOpenHall_v1";backup.Parent=storage
	for _,wall in ipairs(walls) do wall:SetAttribute("OriginalParentPath",wall.Parent:GetFullName());wall.Parent=backup end
	interior:SetAttribute("OriginalParentPath",interior.Parent:GetFullName());interior.Parent=backup
	local marker=Instance.new("Folder");marker.Name="CanteenOpenHall_v1"
	marker:SetAttribute("ArchivedWallCount",#walls);marker:SetAttribute("ArchivedDoorCount",doors);marker:SetAttribute("PreservedStairParts",stairCount)
	marker.Parent=b
	return string.format("Opened both canteen floors; preserved %d wall pieces, %d classroom doors and %d stair parts",#walls,doors,stairCount)
end
