-- Clear the existing ground-floor gallery rail at B2's new entrance.
return function()
	local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B2
	local entry=assert(b:FindFirstChild("CenterFacingEntrance_v1"))
	assert(not entry:FindFirstChild("GalleryOpening"),"Gallery opening already exists")
	local backup=assert(game.ServerStorage.CampusEntryOriginals_v1:FindFirstChild("B2"))
	local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={b}
	local parts={}
	for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(5335,4.8,1689),Vector3.new(6,7,6),params)) do
		if p:IsA("BasePart") and not p:IsDescendantOf(entry) and p.CanCollide then
			assert(p.Name=="GallerySupport_West_Floor_01_Column_11" or p.Name=="GalleryRail_West_Floor_01_Coping" or p.Name=="GalleryRail_West_Floor_01_Parapet","Unexpected B2 gallery obstacle")
			table.insert(parts,p)
		end
	end
	assert(#parts==3,"Expected one column and two rail parts")
	local result=Instance.new("Folder");result.Name="GalleryOpening"
	for _,p in ipairs(parts) do
		if p.Name:find("GalleryRail",1,true)==1 then
			local point=p.CFrame:PointToObjectSpace(Vector3.new(5335,p.Position.Y,p.Position.Z))
			local xAxis=p.Size.X>p.Size.Z;local c=if xAxis then point.X else point.Z
			local half=(if xAxis then p.Size.X else p.Size.Z)/2
			for _,bounds in ipairs({{-half,c-3},{c+3,half}}) do
				local a,z=bounds[1],bounds[2];assert(z>a,"Invalid gallery cut")
				local q=p:Clone();q.Name=p.Name.."_Trim"
				q.Size=if xAxis then Vector3.new(z-a,p.Size.Y,p.Size.Z) else Vector3.new(p.Size.X,p.Size.Y,z-a)
				q.CFrame=p.CFrame*CFrame.new(if xAxis then (a+z)/2 else 0,0,if xAxis then 0 else (a+z)/2);q.Parent=result
			end
		end
	end
	for _,p in ipairs(parts) do p:SetAttribute("OriginalParentPath",p.Parent:GetFullName());p.Parent=backup end
	result.Parent=entry
	return "B2 gallery entry cleared; original rail and column preserved"
end
