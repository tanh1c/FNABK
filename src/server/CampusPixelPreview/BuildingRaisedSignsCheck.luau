-- Edit-mode smoke check; visual inspection and playtesting remain necessary.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local b1=buildings.B1
	local galleries=b1.B1_OuterGalleryAndDoors_v1
	local function slabs(folder)
		local n=0
		for _,p in ipairs(folder:GetChildren()) do
			if p.Name=="WestOuterGallery" or p.Name=="EastOuterGallery" or p.Name=="FrontOuterGallery" then n+=1 end
		end
		return n
	end
	assert(slabs(galleries.Floor_1)==0 and slabs(galleries.Floor_2)==3 and slabs(galleries.Floor_3)==3)
	assert(#galleries.Floor_1.GroundOuterDoorClosures:GetChildren()==14)
	local signs=0
	for _,building in ipairs(buildings:GetChildren()) do if building:IsA("Model") then
		local sign=assert(building:FindFirstChild("RaisedBuildingID_v1"))
		assert(sign:GetAttribute("OffsetApplied") and #sign:GetChildren()>2)
		signs+=1
	end end
	assert(signs==23)
	local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances={b1};params.RespectCanCollide=true
	assert(not workspace:Raycast(Vector3.new(5457.125,3,1737),Vector3.new(0,0,-15),params),"B1 main entrance blocked")
	return "23 raised signs, B1 gallery floors and main entrance checked"
end
