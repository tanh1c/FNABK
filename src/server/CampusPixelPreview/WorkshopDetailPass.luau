-- AI-assisted, non-colliding workshop equipment details; existing floors remain unchanged.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local specs={C1="MechanicalLathe_",C2="MechatronicsTestCell_",C3="MechanicalWorkbench_"}
	local total=0
	for name,prefix in pairs(specs) do
		local building=buildings:FindFirstChild(name)
		local workshop=assert(building and building:FindFirstChild("WorkshopArchitecture"))
		assert(not workshop:FindFirstChild("WorkshopEquipmentDetail_v1"),"Workshop details already exist")
		local detail=Instance.new("Folder");detail.Name="WorkshopEquipmentDetail_v1"
		local count=0
		local function piece(surface,label,size,offset,color,material)
			local p=Instance.new("Part");p.Name,p.Size=label,size
			p.CFrame=surface.CFrame*CFrame.new(offset);p.Color,p.Material=color,material
			p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery,p.CastShadow=true,false,false,false,false;p.Parent=detail
		end
		for _,surface in ipairs(workshop:GetChildren()) do
			if surface:IsA("BasePart") and surface.Name:find(prefix,1,true)==1 and surface.Name:match("WorkSurface$") then
				local metal=Color3.fromRGB(91,102,104)
				if name=="C1" then
					piece(surface,"LatheBed",Vector3.new(3,0.3,1),Vector3.new(0,0.3,0),metal,Enum.Material.Metal)
					piece(surface,"LatheChuck",Vector3.new(0.6,1.2,1.2),Vector3.new(-1.1,1,0),Color3.fromRGB(55,61,65),Enum.Material.Metal)
					piece(surface,"LatheToolPost",Vector3.new(0.6,0.9,0.6),Vector3.new(0.7,0.75,0.35),Color3.fromRGB(183,151,84),Enum.Material.Metal)
				elseif name=="C2" then
					piece(surface,"ControlBoard",Vector3.new(2.5,0.18,1.5),Vector3.new(0,0.25,0),Color3.fromRGB(42,93,76),Enum.Material.SmoothPlastic)
					for _,x in ipairs({-0.8,0,0.8}) do piece(surface,"ControlModule",Vector3.new(0.45,0.35,0.45),Vector3.new(x,0.5,0),Color3.fromRGB(50,68,75),Enum.Material.SmoothPlastic) end
					piece(surface,"EmergencyStop",Vector3.new(0.35,0.25,0.35),Vector3.new(1.3,0.35,0.7),Color3.fromRGB(194,52,43),Enum.Material.SmoothPlastic)
				else
					piece(surface,"BenchViceBase",Vector3.new(1.2,0.25,0.9),Vector3.new(0.8,0.27,0),metal,Enum.Material.Metal)
					piece(surface,"BenchViceJaw",Vector3.new(0.5,0.65,0.85),Vector3.new(0.8,0.7,0),Color3.fromRGB(63,74,79),Enum.Material.Metal)
					piece(surface,"ToolTray",Vector3.new(1.4,0.18,0.7),Vector3.new(-0.8,0.25,0.5),Color3.fromRGB(191,161,85),Enum.Material.Metal)
				end
				count+=1
			end
		end
		assert(count>=6 and count<=7,"Unexpected workbench count for "..name)
		detail:SetAttribute("StationsDetailed",count);detail.Parent=workshop;total+=count
		task.wait()
	end
	return "Added specialized equipment detail to "..total.." stations in C1-C3"
end
