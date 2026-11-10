-- Adds two independently operated leaves to B1's existing main entrance.
return function()
	local b1=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
	assert(not b1:FindFirstChild("B1_MainEntryDoors_v1"),"Main doors already exist")
	local model=Instance.new("Model");model.Name="B1_MainEntryDoors_v1"
	for _,side in ipairs({-1,1}) do
		local hinge=Vector3.new(5457.125+side*5.9,4.9,1724)
		local closed=CFrame.new(5457.125+side*3,4.9,1724)
		local open=CFrame.new(hinge)*CFrame.Angles(0,side*math.pi/2,0)*CFrame.new(-hinge)*closed
		local p=Instance.new("Part")
		p.Name=if side<0 then "MainDoorLeft" else "MainDoorRight"
		p.Size,p.CFrame=Vector3.new(5.8,8.2,0.2),open
		p.Color,p.Material=Color3.fromRGB(104,77,55),Enum.Material.WoodPlanks
		p.Anchored,p.CanCollide,p.CanTouch=true,false,false
		p:SetAttribute("CampusDoor",true);p:SetAttribute("DoorClosed",closed);p:SetAttribute("DoorOpen",open);p:SetAttribute("StartsOpen",true)
		p.Parent=model
	end
	model.Parent=b1
	return "Added two operable main-entry leaves, initially open"
end
