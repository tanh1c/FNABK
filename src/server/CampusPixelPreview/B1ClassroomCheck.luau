-- Edit-mode geometry smoke check; player traversal still needs a Studio playtest.
return function()
	local b1=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
	local rooms=assert(b1:FindFirstChild("B1_OpenGalleryAndClassrooms_v1"))
	local details=assert(b1:FindFirstChild("B1_ClassroomDetails_v1"))
	local p=RaycastParams.new()
	p.FilterType=Enum.RaycastFilterType.Include
	p.FilterDescendantsInstances={b1}
	p.RespectCanCollide=true
	local count=0
	for _,sign in ipairs(rooms:GetDescendants()) do
		if sign:IsA("BasePart") and sign.Name=="RoomSign" then
			local y=sign.Position.Y-5.4
			local start, direction
			if sign.Position.X > 5490 then
				start,direction=Vector3.new(5494.5,y,sign.Position.Z-3),Vector3.new(7,0,0)
			elseif sign.Position.X < 5420 then
				start,direction=Vector3.new(5416.5,y,sign.Position.Z-3),Vector3.new(-7,0,0)
			else
				start,direction=Vector3.new(sign.Position.X-3.2,y,1694),Vector3.new(0,0,7)
			end
			assert(not workspace:Raycast(start,direction,p), "Room entrance blocked: "..sign:GetFullName())
			count+=1
		end
	end
	assert(count==42,"Unexpected room count")
	local teacherDesks=0
	for _,v in ipairs(details:GetDescendants()) do if v.Name=="TeacherDesk" then teacherDesks+=1 end end
	assert(teacherDesks==42,"Missing teacher desks")
	return "42 classroom entrances and teacher desks checked"
end
