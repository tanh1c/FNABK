-- Move existing raised identifiers to the newly selected center-facing entrances.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local count=0
	for _,name in ipairs({"B2","A2","A4","A5","B6","A1","B8","C1","A3","KioskOISP","B11"}) do
		local building=buildings[name]
		local group=assert(building:FindFirstChild("RaisedBuildingID_v1"))
		if group:GetAttribute("OriginalSignPivot") then continue end
		local canopy=assert(building.CenterFacingEntrance_v1:FindFirstChild("EntryCanopy"))
		local anchor
		for _,v in ipairs(building:GetDescendants()) do if v:IsA("BasePart") and (v.Name=="ProtrudingBuildingName" or v.Name=="WorkshopNameboard") then anchor=v;break end end
		local gui=assert(anchor and anchor:FindFirstChildWhichIsA("SurfaceGui"))
		local oldFrame=anchor.CFrame
		if gui.Face==Enum.NormalId.Front then oldFrame=oldFrame*CFrame.Angles(0,math.pi,0) end
		local setback=if name=="B2" then 2.8 else 2
		local newFrame=canopy.CFrame*CFrame.new(0,0,-setback)
		group:SetAttribute("OriginalSignPivot",group:GetPivot())
		group:PivotTo(newFrame*oldFrame:ToObjectSpace(group:GetPivot()))
		count+=1
	end
	return "Moved "..count.." raised building IDs over center-facing entrances"
end
