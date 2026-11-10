-- Edit-mode smoke check; the traced map and player routes still need human review.
return function()
	local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
	local buildings=root.Buildings
	local areas,trees,seats=0,0,0
	for _,area in ipairs(root.CampusGrass_v1:GetChildren()) do
		assert(area:GetAttribute("GrassCellCount")>0);areas+=1
		for _,v in ipairs(area:GetChildren()) do
			if v.Name:match("^CampusTree_") then local _,size=v:GetBoundingBox();assert(size.Y<(v:GetAttribute("PolishedTree_v1") and 24 or 9));trees+=1
			elseif v.Name=="StoneBench" then assert(v:FindFirstChildWhichIsA("Seat"));seats+=1 end
		end
	end
	assert(areas==24 and trees==53 and seats==23)
	local signs,entries=0,0
	for _,building in ipairs(buildings:GetChildren()) do if building:IsA("Model") then
		assert(building:FindFirstChild("RaisedBuildingID_v1"));signs+=1
		for _,v in ipairs(building:GetDescendants()) do
			if v:IsA("BasePart") and (v.Name=="ProtrudingBuildingName" or v.Name=="WorkshopNameboard" or v.Name=="B1Sign") then
				assert(v.Transparency==1,"Old nameboard visible: "..building.Name)
				for _,gui in ipairs(v:GetDescendants()) do if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then assert(not gui.Enabled) end end
			end
		end
		local entry=building:FindFirstChild("CenterFacingEntrance_v1")
		if entry then
			local canopy=assert(entry:FindFirstChild("EntryCanopy"))
			local start=canopy.CFrame:PointToWorldSpace(Vector3.new(0,3-canopy.Position.Y,6))
			local params=RaycastParams.new();params.RespectCanCollide=true
			assert(not workspace:Raycast(start,canopy.CFrame.LookVector*14,params),"Entry blocked: "..building.Name)
			entries+=1
		end
	end end
	assert(signs==23 and entries==20)
	for _,id in ipairs({"C2","C3"}) do assert(buildings[id].WorkshopArchitecture:FindFirstChild("PrimaryWorkshopEntry_v1")) end
	assert(buildings.B1:FindFirstChild("B1_MainEntryDoors_v1"))
	local gates=0
	for _,edge in ipairs(root.CampusBoundaryAndGates_v1:GetChildren()) do
		for _,gate in ipairs(edge:GetChildren()) do if gate:IsA("Model") and gate.Name:match("^CampusGate_") then
			local header=gate.GateHeader
			local start=header.CFrame:PointToWorldSpace(Vector3.new(0,3-header.Position.Y,-8))
			local params=RaycastParams.new();params.RespectCanCollide=true
			assert(not workspace:Raycast(start,-header.CFrame.LookVector*16,params),"Gate blocked: "..gate.Name)
			gates+=1
		end end
	end
	assert(gates==3 and root.CampusBoundaryAndGates_v1:GetAttribute("SkippedIntersectingSpans")==0)
	return "24 grass zones, 53 trees, 23 seats, 23 raised IDs, 20 entry rays and 3 open gate rays checked"
end
