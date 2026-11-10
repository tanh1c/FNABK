-- Hide old building nameboards while preserving raised letters and original values.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local count=0
	for _,building in ipairs(buildings:GetChildren()) do if building:IsA("Model") then
		for _,v in ipairs(building:GetDescendants()) do
			if v:IsA("BasePart") and (v.Name=="ProtrudingBuildingName" or v.Name=="BuildingNameSignHousing" or v.Name=="WorkshopNameboard" or v.Name=="NameboardAccent" or v.Name=="B1Sign" or v.Name:match("^SignStandOff_")) then
				if v:GetAttribute("OriginalNameboardTransparency")==nil then v:SetAttribute("OriginalNameboardTransparency",v.Transparency) end
				if v:GetAttribute("OriginalNameboardCanCollide")==nil then v:SetAttribute("OriginalNameboardCanCollide",v.CanCollide) end
				v.Transparency=1;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false
				for _,gui in ipairs(v:GetDescendants()) do if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
					if gui:GetAttribute("OriginalNameboardEnabled")==nil then gui:SetAttribute("OriginalNameboardEnabled",gui.Enabled) end
					gui.Enabled=false
				end end
				count+=1
			end
		end
	end end
	return "Hidden "..count.." old nameboard parts; raised IDs preserved"
end
