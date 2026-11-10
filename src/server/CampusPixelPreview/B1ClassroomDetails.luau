-- AI-assisted finishing details; only native Parts are used.
return function()
	local b1 = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
	local classrooms = assert(b1:FindFirstChild("B1_OpenGalleryAndClassrooms_v1"))
	assert(not b1:FindFirstChild("B1_ClassroomDetails_v1"), "Details already exist")
	local root = Instance.new("Folder")
	root.Name = "B1_ClassroomDetails_v1"
	local wood, metal = Color3.fromRGB(142,104,72), Color3.fromRGB(45,67,79)
	local function part(parent,name,size,pos,color,material,collide)
		local p=Instance.new("Part")
		p.Name,p.Size,p.Position=name,size,pos
		p.Color,p.Material=color,material
		p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,collide,false,collide
		p.CastShadow=collide
		p.Parent=parent
		return p
	end
	local total=0
	for floor=1,3 do
		local source=assert(classrooms:FindFirstChild("Floor_"..floor))
		local folder=Instance.new("Folder")
		folder.Name="Floor_"..floor
		folder.Parent=root
		local base=0.8+(floor-1)*12.85714
		for _, v in ipairs(source:GetChildren()) do
			if v.Name=="Chalkboard" and v:IsA("BasePart") then
				local wing=v.Size.X < 1
				local tablePos
				if wing then
					local direction=if v.Position.X < 5450 then 1 else -1
					tablePos=Vector3.new(v.Position.X+direction*2.2,base+2.5,v.Position.Z)
					part(folder,"ChalkShelf",Vector3.new(0.5,0.15,8.4),Vector3.new(v.Position.X+direction*0.2,base+3.85,v.Position.Z),wood,Enum.Material.WoodPlanks,false)
				else
					tablePos=Vector3.new(v.Position.X,base+2.5,v.Position.Z-2.5)
					part(folder,"ChalkShelf",Vector3.new(8.4,0.15,0.5),Vector3.new(v.Position.X,base+3.85,v.Position.Z-0.2),wood,Enum.Material.WoodPlanks,false)
				end
				part(folder,"TeacherDesk",Vector3.new(3.4,0.25,1.8),tablePos,wood,Enum.Material.WoodPlanks,true)
				for _,dx in ipairs({-1.45,1.45}) do
					part(folder,"TeacherDeskLeg",Vector3.new(0.15,2.4,1.5),tablePos+Vector3.new(dx,-1.25,0),metal,Enum.Material.Metal,false)
				end
				part(folder,"CeilingLight",Vector3.new(3,0.12,0.5),Vector3.new(tablePos.X,base+11.55,tablePos.Z),Color3.fromRGB(238,232,198),Enum.Material.Neon,false)
				total+=1
			end
		end
		task.wait()
	end
	assert(total==42,"Unexpected classroom count")
	local floors=root:GetChildren()
	for _,f in ipairs(floors) do f.Parent=nil end
	root.Parent=b1
	for _,f in ipairs(floors) do f.Parent=root; task.wait() end
	return "Added teacher desks, chalk shelves and ceiling fixtures to 42 classrooms"
end
