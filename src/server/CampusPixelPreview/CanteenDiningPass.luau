-- AI-assisted food-court furnishing pass; the original canteen is kept in ServerStorage.
return function()
	local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.Canteen
	local storage=game:GetService("ServerStorage")
	assert(not b:FindFirstChild("CanteenDining_v1") and not storage:FindFirstChild("Canteen_BeforeDining_v1"),"Canteen pass already exists")
	local rooms={}
	for _,v in ipairs(b:GetDescendants()) do
		if v:IsA("Model") and v.Parent and v.Parent.Name=="Furnishings" and v.Name:find("Classroom") then table.insert(rooms,v) end
	end
	assert(#rooms==25,"Unexpected canteen room layout")
	local backup=b:Clone();backup.Name="Canteen_BeforeDining_v1";backup.Parent=storage
	local marker=Instance.new("Folder");marker.Name="CanteenDining_v1";marker.Parent=b
	local seats,menus,trays=0,0,0
	for _,room in ipairs(rooms) do
		local decor=Instance.new("Folder");decor.Name="DiningDetails_v1"
		for _,p in ipairs(room:GetChildren()) do if p:IsA("BasePart") then
			if p.Name:match("^StudentBench_") then
				local seat=Instance.new("Seat");seat.Name="DiningSeat";seat.Size,seat.CFrame=p.Size,p.CFrame
				seat.Color,seat.Material=p.Color,p.Material;seat.Anchored,seat.CanCollide=true,true;seat.Parent=decor
				p:SetAttribute("OriginalDiningTransparency",p.Transparency);p:SetAttribute("OriginalDiningCanCollide",p.CanCollide)
				p.Transparency,p.CanCollide,p.CanTouch,p.CanQuery=1,false,false,false;seats+=1
			elseif p.Name:match("^StudentDesk_") or p.Name=="TeacherDesk" then
				local tray=Instance.new("Part");tray.Name=if p.Name=="TeacherDesk" then "ServiceTray" else "DiningTray"
				tray.Size=Vector3.new(math.min(p.Size.X*.8,.6),.08,math.min(p.Size.Z*.75,1))
				tray.CFrame=p.CFrame*CFrame.new(0,p.Size.Y/2+.06,0);tray.Color=Color3.fromRGB(188,190,179);tray.Material=Enum.Material.Metal
				tray.Anchored,tray.CanCollide,tray.CanTouch,tray.CanQuery,tray.CastShadow=true,false,false,false,false;tray.Parent=decor
				local food=Instance.new("Part");food.Name="FoodBowl";food.Shape=Enum.PartType.Ball;food.Size=Vector3.new(.36,.24,.36)
				food.CFrame=tray.CFrame*CFrame.new(0,.14,0);food.Color=if p.Name=="TeacherDesk" then Color3.fromRGB(160,88,54) else Color3.fromRGB(226,201,147)
				food.Material=Enum.Material.SmoothPlastic;food.Anchored,food.CanCollide,food.CanTouch,food.CanQuery,food.CastShadow=true,false,false,false,false;food.Parent=decor;trays+=1
			elseif p.Name=="Whiteboard" then
				p:SetAttribute("OriginalDiningBoardColor",p.Color);p.Color=Color3.fromRGB(41,69,61)
				for _,face in ipairs({Enum.NormalId.Left,Enum.NormalId.Right}) do
					local gui=Instance.new("SurfaceGui");gui.Name="DiningMenu";gui.Face,gui.LightInfluence,gui.Parent=face,0,p
					local label=Instance.new("TextLabel");label.Size,label.BackgroundTransparency,label.Text=UDim2.fromScale(1,1),1,"THỰC ĐƠN\nCƠM  •  NƯỚC"
					label.TextColor3,label.TextScaled,label.TextWrapped,label.Font,label.Parent=Color3.fromRGB(241,237,211),true,true,Enum.Font.GothamBold,gui
				end
				menus+=1
			end
		end end
		decor.Parent=room
	end
	assert(seats==50 and menus==25 and trays==75,"Unexpected canteen furniture count")
	return "Added 25 canteen menus, 75 food trays and 50 usable dining seats; original canteen preserved"
end
