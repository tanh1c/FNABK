-- Edit-mode check: ground exterior is sealed; upper exterior openings remain clear.
return function()
	local b1=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
	local rooms=b1.B1_OpenGalleryAndClassrooms_v1
	local details=b1.B1_OuterGalleryAndDoors_v1
	local params=RaycastParams.new()
	params.FilterType=Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances={b1}
	params.RespectCanCollide=true
	local count,ground=0,0
	for _,s in ipairs(rooms:GetDescendants()) do
		if s:IsA("BasePart") and s.Name=="RoomSign" then
			local y=s.Position.Y-5.4
			local start,direction
			if s.Position.X>5490 then start,direction=Vector3.new(5530,y,s.Position.Z-3),Vector3.new(-8,0,0)
			elseif s.Position.X<5420 then start,direction=Vector3.new(5384,y,s.Position.Z-3),Vector3.new(8,0,0)
			else start,direction=Vector3.new(s.Position.X-3.2,y,1728),Vector3.new(0,0,-8) end
			local hit=workspace:Raycast(start,direction,params)
			if s.Position.Y<12 then
				assert(hit and hit.Instance.Name=="ClosedGroundOuterDoor","Ground exterior opening is not sealed")
				ground+=1
			else
				assert(not hit,"Upper exterior classroom doorway blocked")
			end
			count+=1
		end
	end
	local doors,signs=0,0
	for _,v in ipairs(details:GetDescendants()) do
		if v.Name=="OpenClassDoor" then doors+=1 elseif v.Name=="ClassNumber" then signs+=1 end
	end
	assert(count==42 and ground==14 and doors==70 and signs==70,"Unexpected classroom door or sign count")
	return "14 ground exterior openings sealed; 28 upper exterior openings and 70 doors/signs checked"
end
