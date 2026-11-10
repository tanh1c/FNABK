-- AI-assisted Studio pass. Ground B1 is backed up before its exterior gallery is removed.
return function(phase)
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local storage=game:GetService("ServerStorage")
	if phase=="ground" then
		local b1=buildings.B1
		local floor=assert(b1.B1_OuterGalleryAndDoors_v1:FindFirstChild("Floor_1"))
		assert(not storage:FindFirstChild("B1_BeforeGroundGalleryRemoval_v1"),"Backup exists")
		assert(not floor:GetAttribute("GroundGalleryRemoved"),"Ground gallery already removed")
		local backup=b1:Clone();backup.Name="B1_BeforeGroundGalleryRemoval_v1";backup.Parent=storage
		local fills=Instance.new("Folder");fills.Name="GroundOuterDoorClosures";fills.Parent=floor
		local count=0
		for _,sign in ipairs(b1.B1_OpenGalleryAndClassrooms_v1.Floor_1:GetChildren()) do
			if sign:IsA("BasePart") and sign.Name=="RoomSign" then
				local center,size,pos
				if sign.Position.X>5490 then
					center=sign.Position.Z-3;size=Vector3.new(0.65,8.2,4.4);pos=Vector3.new(5526.8,4.9,center)
				elseif sign.Position.X<5420 then
					center=sign.Position.Z-3;size=Vector3.new(0.65,8.2,4.4);pos=Vector3.new(5387.3,4.9,center)
				else
					center=sign.Position.X-3.2;size=Vector3.new(4.4,8.2,0.65);pos=Vector3.new(center,4.9,1724)
				end
				local p=Instance.new("Part");p.Name="ClosedGroundOuterDoor";p.Size,p.Position=size,pos
				p.Color,p.Material=Color3.fromRGB(216,216,201),Enum.Material.Concrete
				p.Anchored,p.CanCollide,p.CanTouch=true,true,false;p.Parent=fills;count+=1
			end
		end
		assert(count==14,"Unexpected ground-floor classroom count")
		local remove={}
		for _,p in ipairs(floor:GetChildren()) do if p:IsA("BasePart") then
			local n=p.Name
			local gallery=n=="WestOuterGallery" or n=="EastOuterGallery" or n=="FrontOuterGallery" or n=="OuterGalleryGuard" or n=="OuterGalleryRail" or n=="OuterGalleryPost"
			local door=n=="DoorFrame" or n=="DoorFrameHeader" or n=="OpenClassDoor" or n=="ClassNumber"
			local outer=math.abs(p.Position.X-5387.3)<2.2 or math.abs(p.Position.X-5526.8)<2.2 or math.abs(p.Position.Z-1724)<2.2
			if gallery or (door and outer) then table.insert(remove,p) end
		end end
		for _,p in ipairs(remove) do p:Destroy() end
		floor:SetAttribute("GroundGalleryRemoved",true)
		return string.format("Removed %d gallery and outer-door parts; sealed %d ground-floor openings",#remove,count)
	end
	if phase=="position" then
		local count=0
		for _,b in ipairs(buildings:GetChildren()) do if b:IsA("Model") then
			local group=assert(b:FindFirstChild("RaisedBuildingID_v1"))
			assert(not group:GetAttribute("OffsetApplied"),"Sign already positioned")
			local anchor
			for _,p in ipairs(b:GetDescendants()) do if p:IsA("BasePart") and (p.Name=="B1Sign" or p.Name=="ProtrudingBuildingName" or p.Name=="WorkshopNameboard") then anchor=p;break end end
			local gui=assert(anchor:FindFirstChildWhichIsA("SurfaceGui"))
			local frame=anchor.CFrame
			if gui.Face==Enum.NormalId.Front then frame=frame*CFrame.Angles(0,math.pi,0) end
			local distance=if b.Name=="B1" then 2 else 5.5
			group:PivotTo(group:GetPivot()+frame.LookVector*(-distance))
			local width=#group:GetAttribute("BuildingID")*6*0.85-0.85
			for _,x in ipairs({-width/2+0.5,width/2-0.5}) do
				local support=Instance.new("Part");support.Name="SignMount"
				support.Size=Vector3.new(0.18,0.18,distance)
				support.CFrame=frame*CFrame.new(x,5.7,anchor.Size.Z/2+0.35+distance/2)
				support.Color=Color3.fromRGB(90,100,101);support.Material=Enum.Material.Metal
				support.Anchored,support.CanCollide,support.CanTouch,support.CanQuery=true,false,false,false;support.Parent=group
			end
			group:SetAttribute("OffsetApplied",distance);count+=1
		end end
		return "Moved "..count.." raised signs forward and added mounts"
	end
	assert(phase=="signs","Invalid phase")
	local font={
		A={"11111","10001","10001","11111","10001","10001","10001"},B={"11111","10001","10001","11111","10001","10001","11111"},
		C={"11111","10000","10000","10000","10000","10000","11111"},E={"11111","10000","10000","11111","10000","10000","11111"},
		I={"11111","00100","00100","00100","00100","00100","11111"},K={"10001","10010","10100","11000","10100","10010","10001"},
		N={"10001","11001","10101","10011","10001","10001","10001"},O={"11111","10001","10001","10001","10001","10001","11111"},
		P={"11111","10001","10001","11111","10000","10000","10000"},S={"11111","10000","10000","11111","00001","00001","11111"},
		T={"11111","00100","00100","00100","00100","00100","00100"},
		["0"]={"11111","10001","10011","10101","11001","10001","11111"},["1"]={"00100","01100","00100","00100","00100","00100","01110"},
		["2"]={"11111","00001","00001","11111","10000","10000","11111"},["3"]={"11111","00001","00001","11111","00001","00001","11111"},
		["4"]={"10010","10010","10010","11111","00010","00010","00010"},["5"]={"11111","10000","10000","11110","00001","00001","11110"},
		["6"]={"11111","10000","10000","11111","10001","10001","11111"},["7"]={"11111","00001","00010","00100","01000","01000","01000"},
		["8"]={"11111","10001","10001","11111","10001","10001","11111"},["9"]={"11111","10001","10001","11111","00001","00001","11111"},
	}
	local labels={Canteen="CANTEEN",KioskOISP="OISP",Facility7="7"}
	local todo={}
	for _,b in ipairs(buildings:GetChildren()) do if b:IsA("Model") then
		local anchor
		for _,p in ipairs(b:GetDescendants()) do if p:IsA("BasePart") and (p.Name=="B1Sign" or p.Name=="ProtrudingBuildingName" or p.Name=="WorkshopNameboard") then anchor=p;break end end
		assert(anchor and not b:FindFirstChild("RaisedBuildingID_v1"),"Missing or existing sign: "..b.Name)
		local value=labels[b.Name] or b.Name
		for i=1,#value do assert(font[value:sub(i,i)],"Unsupported sign character") end
		table.insert(todo,{building=b,anchor=anchor,value=value})
	end end
	assert(#todo==23,"Unexpected number of buildings")
	for _,item in ipairs(todo) do
		local anchor,value=item.anchor,item.value
		local gui=anchor:FindFirstChildWhichIsA("SurfaceGui")
		assert(gui and (gui.Face==Enum.NormalId.Front or gui.Face==Enum.NormalId.Back),"Unknown sign orientation")
		local frame=anchor.CFrame
		if gui.Face==Enum.NormalId.Front then frame=frame*CFrame.Angles(0,math.pi,0) end
		local group=Instance.new("Model");group.Name="RaisedBuildingID_v1"
		group:SetAttribute("BuildingID",value)
		local cell=0.85
		local width=#value*6*cell-cell
		for index=1,#value do
			local glyph=font[value:sub(index,index)]
			for row=1,7 do
				local column=1
				while column<=5 do
					if glyph[row]:sub(column,column)=="1" then
						local first=column
						while column<=5 and glyph[row]:sub(column,column)=="1" do column+=1 end
						local run=column-first
						local x=-width/2+(index-1)*6*cell+(first-1+run/2)*cell
						local p=Instance.new("Part");p.Name="RaisedLetterStroke";p.Size=Vector3.new(run*cell,cell,0.4)
						p.CFrame=frame*CFrame.new(x,5.7+(4-row)*cell,anchor.Size.Z/2+0.35)
						p.Color=Color3.fromRGB(243,242,228);p.Material=Enum.Material.SmoothPlastic
						p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery,p.CastShadow=true,false,false,false,false;p.Parent=group
					else column+=1 end
				end
			end
		end
		group.Parent=item.building
		if item.building.Name=="B1" then anchor.Transparency=1;gui.Enabled=false end
		task.wait()
	end
	return "Added large raised building identifiers to "..#todo.." buildings"
end
