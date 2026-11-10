-- AI-assisted native architectural detail for A2; no external assets or floor changes.
return function()
	local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.A2
	assert(not b:FindFirstChild("A2_LibraryIdentity_v1"),"Library pass already exists")
	local canopy=assert(b.CenterFacingEntrance_v1:FindFirstChild("EntryCanopy"))
	local frame=canopy.CFrame*CFrame.new(0,-canopy.Position.Y,-2)
	local output=Instance.new("Model");output.Name="A2_LibraryIdentity_v1"
	local stone=Color3.fromRGB(215,213,196);local blue=Color3.fromRGB(49,87,103)
	local function part(parent,name,size,cf,color,material)
		local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf
		p.Color,p.Material=color,material;p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery,p.CastShadow=true,false,false,false,false;p.Parent=parent
		return p
	end
	for _,x in ipairs({-15,-8,8,15}) do
		part(output,"LibraryFacadePier",Vector3.new(.65,36,.45),frame*CFrame.new(x,19,.45),stone,Enum.Material.Concrete)
	end
	for _,x in ipairs({-11.5,11.5}) do
		local glass=part(output,"LibraryVerticalGlazing",Vector3.new(5.5,21,.18),frame*CFrame.new(x,22,.5),blue,Enum.Material.Glass)
		glass.Transparency=.22
		for _,y in ipairs({15,22,29}) do part(output,"LibraryWindowMullion",Vector3.new(5.5,.22,.25),frame*CFrame.new(x,y,.65),stone,Enum.Material.SmoothPlastic) end
	end
	part(output,"LibraryCornice",Vector3.new(33,.7,.65),frame*CFrame.new(0,37,.5),stone,Enum.Material.Concrete)
	local font={
		T={"11111","00100","00100","00100","00100","00100","00100"},H={"10001","10001","10001","11111","10001","10001","10001"},
		U={"10001","10001","10001","10001","10001","10001","11111"},V={"10001","10001","10001","10001","01010","01010","00100"},
		I={"11111","00100","00100","00100","00100","00100","11111"},E={"11111","10000","10000","11111","10000","10000","11111"},
		N={"10001","11001","10101","10011","10001","10001","10001"},[" "]={"00000","00000","00000","00000","00000","00000","00000"},
	}
	local word="THU VIEN";local cell=.5;local width=#word*6*cell-cell
	for index=1,#word do
		local glyph=font[word:sub(index,index)]
		for row=1,7 do local col=1
			while col<=5 do
				if glyph[row]:sub(col,col)=="1" then local first=col;while col<=5 and glyph[row]:sub(col,col)=="1" do col+=1 end
					local run=col-first;local x=-width/2+(index-1)*6*cell+(first-1+run/2)*cell
					part(output,"RaisedLibraryLetter",Vector3.new(run*cell,cell,.28),frame*CFrame.new(x,24+(4-row)*cell,6),stone,Enum.Material.SmoothPlastic)
				else col+=1 end
			end
		end
	end
	-- Small raised marks render the horn on Ư and the circumflex and dot on Ệ.
	local u=-width/2+(3-1)*6*cell+4.9*cell
	local e=-width/2+(7-1)*6*cell+2.5*cell
	part(output,"VietnameseMark",Vector3.new(.55,.35,.28),frame*CFrame.new(u,26.1,6),stone,Enum.Material.SmoothPlastic)
	part(output,"VietnameseMark",Vector3.new(1,.3,.28),frame*CFrame.new(e,26.15,6),stone,Enum.Material.SmoothPlastic)
	part(output,"VietnameseMark",Vector3.new(.35,.35,.28),frame*CFrame.new(e,21.9,6),stone,Enum.Material.SmoothPlastic)
	local shelves={}
	for _,p in ipairs(b:GetDescendants()) do if p:IsA("BasePart") and p.Name:match("^Bookcase_%d+_Shelf_%d+$") then table.insert(shelves,p) end end
	assert(#shelves==162,"Unexpected A2 library shelf count")
	local colors={Color3.fromRGB(119,66,54),Color3.fromRGB(54,91,100),Color3.fromRGB(137,117,72),Color3.fromRGB(69,104,76)}
	local books=Instance.new("Folder");books.Name="LibraryBooks"
	for i,shelf in ipairs(shelves) do
		for _,z in ipairs({-1,1}) do part(books,"Books",Vector3.new(.7,.8,1.15),shelf.CFrame*CFrame.new(0,.55,z),colors[(i%#colors)+1],Enum.Material.SmoothPlastic) end
	end
	books.Parent=output;output.Parent=b
	return "Added distinctive A2 library facade, raised library lettering and books on 162 shelves"
end
