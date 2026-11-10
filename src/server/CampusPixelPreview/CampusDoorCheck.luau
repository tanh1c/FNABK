-- Edit-mode structural check; run after CampusDoorSetup, before Studio Play.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local expected={Canteen=2,B2=3,B3=2,B4=6,B6=3,A1=3,A2=3,A3=2,A4=5,A5=4,B8=3,B9=3,B11=2,B12=2,C1=2,C2=1,C3=1,C4=5,C5=5,C6=5,Facility7=3,KioskOISP=1,B1=3}
	local doors,labels,inside,upper=0,0,0,0
	for _,b in ipairs(buildings:GetChildren()) do if b:IsA("Model") then
		assert(expected[b.Name],"Unexpected building: "..b.Name)
		assert((b:GetAttribute("ConfirmedStories") or b:GetAttribute("EstimatedStories") or b:GetAttribute("WalkableFloorCount"))==expected[b.Name],"Floor count changed: "..b.Name)
		for _,v in ipairs(b:GetDescendants()) do
			if v:IsA("BasePart") and v:GetAttribute("CampusDoor") then
				assert(typeof(v:GetAttribute("DoorOpen"))=="CFrame" and typeof(v:GetAttribute("DoorClosed"))=="CFrame")
				doors+=1
			elseif v:IsA("BasePart") and v.Name=="ClassroomNumber" then labels+=1
			elseif v:IsA("BasePart") and v.Name=="InteriorClassroomNumber" then inside+=1
			elseif v:IsA("BasePart") and v.Name=="C1UpperRoomNumber" then upper+=1 end
		end
	end end
	assert(doors==892 and labels==336 and inside==446 and upper==4,"Door or label count differs")
	for name,count in pairs({C1=7,C2=6,C3=6}) do
		assert(buildings[name].WorkshopArchitecture.WorkshopEquipmentDetail_v1:GetAttribute("StationsDetailed")==count)
	end
	return "892 configured doors, 786 room/access plates, 19 workshop stations and building floor counts checked"
end
