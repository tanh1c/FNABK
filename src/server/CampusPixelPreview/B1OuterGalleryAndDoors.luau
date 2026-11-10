-- AI-assisted exterior gallery and classroom doorway pass; original B1 is preserved.
return function()
	local b1=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
	local rooms=assert(b1:FindFirstChild("B1_OpenGalleryAndClassrooms_v1"))
	local storage=game:GetService("ServerStorage")
	assert(not b1:FindFirstChild("B1_OuterGalleryAndDoors_v1"),"Pass already present")
	assert(not storage:FindFirstChild("B1_BeforeOuterGallery_v1"),"Backup already exists")
	local records={}
	for _, sign in ipairs(rooms:GetDescendants()) do
		if sign:IsA("BasePart") and sign.Name=="RoomSign" then
			local label=sign:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("TextLabel")
			assert(label and label.Text~="","Room sign has no number")
			local floor=math.floor((sign.Position.Y-9.2)/12.85714+1.5)
			local side,center
			if sign.Position.X>5490 then side,center="East",sign.Position.Z-3
			elseif sign.Position.X<5420 then side,center="West",sign.Position.Z-3
			else side,center="Front",sign.Position.X-3.2 end
			table.insert(records,{floor=floor,side=side,center=center,id=label.Text})
		end
	end
	assert(#records==42,"Expected 42 numbered classrooms")
	local oldWalls={}
	for _,p in ipairs(b1:GetChildren()) do
		if p:IsA("BasePart") and (p.Name=="WestOuterWall" or p.Name=="EastOuterWall" or p.Name=="FrontWall" or p.Name=="FrontWallLeft" or p.Name=="FrontWallRight") then
			table.insert(oldWalls,p)
		end
	end
	assert(#oldWalls==10,"Unexpected outer wall layout")
	local backup=b1:Clone()
	backup.Name="B1_BeforeOuterGallery_v1"
	backup.Parent=storage
	local result=Instance.new("Folder")
	result.Name="B1_OuterGalleryAndDoors_v1"
	local ivory=Color3.fromRGB(221,220,207)
	local blue=Color3.fromRGB(42,79,100)
	local wood=Color3.fromRGB(130,93,64)
	local function part(parent,name,size,pos,color,material,collide)
		local p=Instance.new("Part")
		p.Name,p.Size,p.Position=name,size,pos
		p.Color,p.Material=color,material
		p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,collide,false,collide
		p.CastShadow=collide
		p.Parent=parent
		return p
	end
	local floors={}
	for f=1,3 do local d=Instance.new("Folder");d.Name="Floor_"..f;d.Parent=result;floors[f]=d end
	local function plaque(parent,id,pos,orientation)
		local p=part(parent,"ClassNumber",Vector3.new(2.7,1.2,0.16),pos,blue,Enum.Material.SmoothPlastic,false)
		p.Orientation=Vector3.new(0,orientation,0)
		for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
			local g=Instance.new("SurfaceGui");g.Face,g.LightInfluence,g.Parent=face,0,p
			local t=Instance.new("TextLabel");t.Size,t.BackgroundTransparency,t.Text=UDim2.fromScale(1,1),1,id
			t.TextColor3,t.TextScaled,t.Font,t.Parent=Color3.new(1,1,1),true,Enum.Font.GothamBold,g
		end
	end
	local function doorway(parent,axis,plane,center,base,id,insideDirection)
		local jambY=base+4.1
		for _,offset in ipairs({-2.25,2.25}) do
			if axis=="Z" then part(parent,"DoorFrame",Vector3.new(0.25,8.2,0.25),Vector3.new(plane,jambY,center+offset),wood,Enum.Material.WoodPlanks,false)
			else part(parent,"DoorFrame",Vector3.new(0.25,8.2,0.25),Vector3.new(center+offset,jambY,plane),wood,Enum.Material.WoodPlanks,false) end
		end
		if axis=="Z" then
			part(parent,"DoorFrameHeader",Vector3.new(0.25,0.25,4.75),Vector3.new(plane,base+8.2,center),wood,Enum.Material.WoodPlanks,false)
			part(parent,"OpenClassDoor",Vector3.new(3.8,7.8,0.16),Vector3.new(plane+insideDirection*1.9,base+3.9,center+2.1),wood,Enum.Material.WoodPlanks,false)
			plaque(parent,id,Vector3.new(plane,base+9.3,center+3.5),90)
		else
			part(parent,"DoorFrameHeader",Vector3.new(4.75,0.25,0.25),Vector3.new(center,base+8.2,plane),wood,Enum.Material.WoodPlanks,false)
			part(parent,"OpenClassDoor",Vector3.new(0.16,7.8,3.8),Vector3.new(center+2.1,base+3.9,plane+insideDirection*1.9),wood,Enum.Material.WoodPlanks,false)
			plaque(parent,id,Vector3.new(center+3.5,base+9.3,plane),0)
		end
	end
	-- Use the original wall dimensions and split each wall at its classroom doors.
	for _,wall in ipairs(oldWalls) do
		local base=wall.Position.Y-wall.Size.Y/2
		local f=math.floor((base-0.8)/12.85714+1.5)
		local side=if wall.Name=="WestOuterWall" then "West" elseif wall.Name=="EastOuterWall" then "East" else "Front"
		local axis=if side=="Front" then "X" else "Z"
		local min=if axis=="X" then wall.Position.X-wall.Size.X/2 else wall.Position.Z-wall.Size.Z/2
		local max=if axis=="X" then wall.Position.X+wall.Size.X/2 else wall.Position.Z+wall.Size.Z/2
		local doors={}
		for _,r in ipairs(records) do if r.floor==f and r.side==side and r.center>min+2.5 and r.center<max-2.5 then table.insert(doors,r) end end
		table.sort(doors,function(a,b) return a.center<b.center end)
		local cursor=min
		local function segment(a,b,y,height,name)
			if b-a<=0.05 then return end
			local size=if axis=="X" then Vector3.new(b-a,height,wall.Size.Z) else Vector3.new(wall.Size.X,height,b-a)
			local pos=if axis=="X" then Vector3.new((a+b)/2,y,wall.Position.Z) else Vector3.new(wall.Position.X,y,(a+b)/2)
			part(floors[f],name,size,pos,wall.Color,wall.Material,true)
		end
		for _,r in ipairs(doors) do
			local a,b=r.center-2.2,r.center+2.2
			assert(a>=cursor-0.01 and b<max,"Overlapping classroom openings")
			segment(cursor,a,wall.Position.Y,wall.Size.Y,"OuterWallSegment")
			segment(a,b,base+10,3.6,"OuterDoorHeader")
			cursor=b
		end
		segment(cursor,max,wall.Position.Y,wall.Size.Y,"OuterWallSegment")
	end
	for _,r in ipairs(records) do
		local base=0.8+(r.floor-1)*12.85714
		if r.side=="East" then
			doorway(floors[r.floor],"Z",5498.2,r.center,base,r.id,1)
			doorway(floors[r.floor],"Z",5526.8,r.center,base,r.id,-1)
		elseif r.side=="West" then
			doorway(floors[r.floor],"Z",5413,r.center,base,r.id,-1)
			doorway(floors[r.floor],"Z",5387.3,r.center,base,r.id,1)
		else
			doorway(floors[r.floor],"X",1698,r.center,base,r.id,1)
			doorway(floors[r.floor],"X",1724,r.center,base,r.id,-1)
		end
	end
	local function slab(parent,name,x0,x1,z0,z1,y)
		part(parent,name,Vector3.new(x1-x0,0.8,z1-z0),Vector3.new((x0+x1)/2,y-0.4,(z0+z1)/2),Color3.fromRGB(179,180,169),Enum.Material.Concrete,true)
	end
	local function rail(parent,axis,plane,a,b,base)
		local size=if axis=="X" then Vector3.new(b-a,3,0.2) else Vector3.new(0.2,3,b-a)
		local pos=if axis=="X" then Vector3.new((a+b)/2,base+1.6,plane) else Vector3.new(plane,base+1.6,(a+b)/2)
		local guard=part(parent,"OuterGalleryGuard",size,pos,blue,Enum.Material.Metal,true);guard.Transparency=0.6
		local top=if axis=="X" then Vector3.new(b-a,0.25,0.25) else Vector3.new(0.25,0.25,b-a)
		part(parent,"OuterGalleryRail",top,pos+Vector3.new(0,1.7,0),blue,Enum.Material.Metal,true)
		for v=a,b,12 do
			local q=if axis=="X" then Vector3.new(v,base+1.75,plane) else Vector3.new(plane,base+1.75,v)
			part(parent,"OuterGalleryPost",Vector3.new(0.45,3.5,0.45),q,ivory,Enum.Material.Concrete,true)
		end
	end
	for f=1,3 do
		local base=0.8+(f-1)*12.85714
		local folder=floors[f]
		slab(folder,"WestOuterGallery",5380.3,5387.35,1574.3,1731,base)
		slab(folder,"EastOuterGallery",5526.75,5533.8,1574.3,1731,base)
		slab(folder,"FrontOuterGallery",5387.3,5526.8,1723.95,1731,base)
		rail(folder,"Z",5380.3,1574.3,1731,base)
		rail(folder,"Z",5533.8,1574.3,1731,base)
		rail(folder,"X",1574.3,5380.3,5387.3,base)
		rail(folder,"X",1574.3,5526.8,5533.8,base)
		if f==1 then
			rail(folder,"X",1731,5380.3,5451.125,base)
			rail(folder,"X",1731,5463.125,5533.8,base)
		else rail(folder,"X",1731,5380.3,5533.8,base) end
		task.wait()
	end
	-- Decorative window panels that overlap a new exterior doorway must not cover it.
	local windows={}
	for _,p in ipairs(b1:GetChildren()) do
		if p:IsA("BasePart") and p.Name=="Window" then
			local f=math.floor((p.Position.Y-6.8)/12.85714+1.5)
			for _,r in ipairs(records) do
				local along=if r.side=="Front" then p.Position.X else p.Position.Z
				local plane=if r.side=="West" then math.abs(p.Position.X-5387.3) elseif r.side=="East" then math.abs(p.Position.X-5526.8) else math.abs(p.Position.Z-1724)
				if r.floor==f and plane<0.5 and math.abs(along-r.center)<4.25 then table.insert(windows,p);break end
			end
		end
	end
	-- Move boards and teacher furniture away from the new exterior doorways.
	local detailRoot=assert(b1:FindFirstChild("B1_ClassroomDetails_v1"))
	for _,r in ipairs(records) do
		local roomFloor=rooms:FindFirstChild("Floor_"..r.floor)
		local detailFloor=detailRoot:FindFirstChild("Floor_"..r.floor)
		local base=0.8+(r.floor-1)*12.85714
		local oldPlane=if r.side=="West" then 5387.95 elseif r.side=="East" then 5526.05 else 1723.36
		local newBoard,newTable
		if r.side=="Front" then
			local half=if r.center<5451 then 7.5 else 7
			newBoard=Vector3.new(r.center-half+0.45,base+6,1710)
			newTable=Vector3.new(r.center-half+2.5,base+2.5,1710)
		else
			newBoard=Vector3.new(if r.side=="West" then 5401 else 5513,base+6,r.center-5.8)
			newTable=Vector3.new(newBoard.X,base+2.5,r.center-4.2)
		end
		local function nearOld(v)
			if r.side=="Front" then return math.abs(v.Position.X-r.center)<0.5 and math.abs(v.Position.Z-oldPlane)<1 end
			return math.abs(v.Position.Z-r.center)<0.5 and math.abs(v.Position.X-oldPlane)<1
		end
		for _,p in ipairs(roomFloor:GetChildren()) do
			if p:IsA("BasePart") and (p.Name=="Chalkboard" or p.Name=="ChalkboardFrame") and nearOld(p) then
				local border=if p.Name=="Chalkboard" then 0 else 0.4
				p.Size=if r.side=="Front" then Vector3.new(0.2,4+border,8+border) else Vector3.new(8+border,4+border,0.2)
				p.Position=newBoard
			end
		end
		local oldTable
		for _,p in ipairs(detailFloor:GetChildren()) do
			if p:IsA("BasePart") and p.Name=="TeacherDesk" then
				local match=if r.side=="Front" then math.abs(p.Position.X-r.center)<0.5 and math.abs(p.Position.Z-1720.86)<0.5
					else math.abs(p.Position.Z-r.center)<0.5 and math.abs(p.Position.X-(oldPlane+(if r.side=="West" then 2.2 else -2.2)))<0.5
				if match then oldTable=p.Position;p.Position=newTable;break end
			end
		end
		assert(oldTable,"Teacher desk not found for "..r.id)
		for _,p in ipairs(detailFloor:GetChildren()) do
			if p:IsA("BasePart") and p.Name=="TeacherDeskLeg" and math.abs(p.Position.Z-oldTable.Z)<0.2 and math.abs(math.abs(p.Position.X-oldTable.X)-1.45)<0.2 then
				p.Position=newTable+Vector3.new(p.Position.X-oldTable.X,-1.25,0)
			elseif p:IsA("BasePart") and p.Name=="CeilingLight" and math.abs(p.Position.X-oldTable.X)<0.2 and math.abs(p.Position.Z-oldTable.Z)<0.2 then
				p.Position=Vector3.new(newTable.X,p.Position.Y,newTable.Z)
			elseif p:IsA("BasePart") and p.Name=="ChalkShelf" and nearOld(p) then
				p.Size=if r.side=="Front" then Vector3.new(0.5,0.15,8.4) else Vector3.new(8.4,0.15,0.5)
				p.Position=Vector3.new(newBoard.X,base+3.85,newBoard.Z)
			end
		end
	end
	local children=result:GetChildren();for _,f in ipairs(children) do f.Parent=nil end
	result.Parent=b1
	for _,f in ipairs(children) do f.Parent=result;task.wait() end
	for _,p in ipairs(oldWalls) do p:Destroy() end
	for _,p in ipairs(windows) do p:Destroy() end
	return string.format("Added 3 exterior galleries and 84 numbered classroom doorways; replaced %d walls and removed %d overlapping window panels",#oldWalls,#windows)
end
