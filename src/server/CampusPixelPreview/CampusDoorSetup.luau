-- AI-assisted edit-time setup; runtime movement is controlled by CampusDoors.server.luau.
return function()
	local buildings=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
	local entries={}
	local function flat(a,b) local d=a-b;return Vector3.new(d.X,0,d.Z).Magnitude end
	for _,building in ipairs(buildings:GetChildren()) do
		if building:IsA("Model") then
			for _,p in ipairs(building:GetDescendants()) do
				if p:IsA("BasePart") and p.Name=="OpenClassDoor" then
					local along=if p.Size.X>p.Size.Z then p.CFrame.RightVector else -p.CFrame.LookVector
					local length=math.max(p.Size.X,p.Size.Z)
					local ends={p.Position-along*length/2,p.Position+along*length/2}
					local frames={}
					for _,f in ipairs(p.Parent:GetChildren()) do
						if f:IsA("BasePart") and f.Name=="DoorFrame" and math.abs(f.Position.Y-p.Position.Y-0.2)<1 then table.insert(frames,f) end
					end
					local hinge,nearest,hingeEnd=nil,math.huge,nil
					for i,endpoint in ipairs(ends) do for _,f in ipairs(frames) do
						local distance=flat(endpoint,f.Position)
						if distance<nearest then hinge,nearest,hingeEnd=f,distance,i end
					end end
					assert(hinge and nearest<0.5,"Cannot find B1 door hinge")
					local other,span=nil,math.huge
					for _,f in ipairs(frames) do if f~=hinge then
						local d=flat(hinge.Position,f.Position)
						if d>3.5 and d<5 and d<span then other,span=f,d end
					end end
					assert(other,"Cannot find B1 opposite jamb")
					local center=Vector3.new(hinge.Position.X,p.Position.Y,hinge.Position.Z)
					local function rotate(angle) return CFrame.new(center)*CFrame.Angles(0,angle,0)*CFrame.new(-center)*p.CFrame end
					local function score(cf)
						local dir=if p.Size.X>p.Size.Z then cf.RightVector else -cf.LookVector
						local endPoint=cf.Position+dir*(if hingeEnd==1 then length/2 else -length/2)
						return flat(endPoint,other.Position)
					end
					local a,b=rotate(math.pi/2),rotate(-math.pi/2)
					local closed=if score(a)<score(b) then a else b
					assert(math.min(score(a),score(b))<1,"B1 door does not align with frame")
					table.insert(entries,{part=p,open=p.CFrame,closed=closed,building=building.Name})
				elseif p:IsA("BasePart") and p.Name:match("^GalleryClassroomDoor_F%d%d_Side_") then
					local long=if p.Size.X>p.Size.Z then p.CFrame.RightVector else -p.CFrame.LookVector
					local length=math.max(p.Size.X,p.Size.Z)
					local hinge=p.Position-long*length/2
					local open=CFrame.new(hinge)*CFrame.Angles(0,math.pi/2,0)*CFrame.new(-hinge)*p.CFrame
					table.insert(entries,{part=p,closed=p.CFrame,open=open,building=building.Name,sign=true})
				elseif p:IsA("BasePart") and p.Name:match("^OpenBayShadow_") and (building.Name=="C1" or building.Name=="C2" or building.Name=="C3") then
					table.insert(entries,{part=p,closed=p.CFrame,open=p.CFrame+Vector3.new(0,p.Size.Y+0.5,0),building=building.Name,shutter=true})
				end
			end
		end
	end
	assert(#entries>350 and #entries<500,"Unexpected door count")
	local numbers={}
	for _,item in ipairs(entries) do
		local p=item.part
		assert(not p:GetAttribute("CampusDoor"),"Door setup already applied")
		p:SetAttribute("CampusDoor",true)
		p:SetAttribute("DoorClosed",item.closed)
		p:SetAttribute("DoorOpen",item.open)
		p:SetAttribute("StartsOpen",not item.sign and not item.shutter)
		if item.sign then
			local floor=tonumber(p.Name:match("_F(%d%d)_")) or 1
			local key=item.building..":"..floor
			numbers[key]=(numbers[key] or 0)+1
			local number=string.format("%s-%d%02d",item.building,floor,numbers[key])
			local plate=Instance.new("Part");plate.Name="ClassroomNumber"
			plate.Size=Vector3.new(2.8,1.2,0.15)
			local direction=if p.Size.X<p.Size.Z then CFrame.Angles(0,math.pi/2,0) else CFrame.new()
			plate.CFrame=p.CFrame*CFrame.new(0,p.Size.Y/2+0.8,0)*direction
			plate.Anchored,plate.CanCollide,plate.CanTouch,plate.CanQuery=true,false,false,false
			plate.Color=Color3.fromRGB(40,78,99);plate.Material=Enum.Material.SmoothPlastic;plate.Parent=p.Parent
			for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
				local gui=Instance.new("SurfaceGui");gui.Face,gui.LightInfluence,gui.Parent=face,0,plate
				local text=Instance.new("TextLabel");text.Size,text.BackgroundTransparency,text.Text=UDim2.fromScale(1,1),1,number
				text.TextColor3,text.TextScaled,text.Font,text.Parent=Color3.new(1,1,1),true,Enum.Font.GothamBold,gui
			end
		end
	end
	return "Configured "..#entries.." classroom doors and workshop shutters"
end
