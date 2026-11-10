-- Visually distinguish the existing central workshop bays without changing shutters.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local total=0
	for _,id in ipairs({"C2","C3"}) do
		local workshop=buildings[id].WorkshopArchitecture
		assert(not workshop:FindFirstChild("PrimaryWorkshopEntry_v1"))
		local floor=assert(workshop:FindFirstChild("WorkshopWalkableFloor"));local best,dist
		for _,p in ipairs(workshop:GetChildren()) do if p:IsA("BasePart") and p.Name:match("^OpenBayShadow_") then
			local localPoint=floor.CFrame:PointToObjectSpace(p.Position);local d=math.abs(localPoint.X)
			if not dist or d<dist then best,dist=p,d end
		end end
		assert(best and best:GetAttribute("CampusDoor"),"Workshop shutter not configured")
		local group=Instance.new("Model");group.Name="PrimaryWorkshopEntry_v1";group:SetAttribute("ShutterName",best.Name)
		local function trim(size,offset)
			local p=Instance.new("Part");p.Name="PrimaryEntryTrim";p.Size=size;p.CFrame=best.CFrame*CFrame.new(offset)
			p.Color,p.Material=Color3.fromRGB(38,83,110),Enum.Material.Metal
			p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,false,false,false;p.Parent=group
		end
		trim(Vector3.new(best.Size.X+.8,.55,.35),Vector3.new(0,best.Size.Y/2+.3,.25))
		for _,side in ipairs({-1,1}) do trim(Vector3.new(.4,best.Size.Y,.35),Vector3.new(side*(best.Size.X/2+.2),0,.25)) end
		group.Parent=workshop;total+=1
	end
	return "Highlighted the existing center-facing C2 and C3 workshop entries"
end
