-- AI-assisted native park planting. Plants and benches stay inside traced grass polygons.
return function()
	local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
	assert(not root:FindFirstChild("CampusParkDetails_v1"),"Park details already exist")
	local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
	local origin=root:GetAttribute("PreviewOriginWorld")
	local output=Instance.new("Folder");output.Name="CampusParkDetails_v1";output.Parent=root
	local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
	overlap.FilterDescendantsInstances={root.Buildings,root.CampusGrass_v1,root.CampusBoundaryAndGates_v1}
	local occupied={}
	for _,v in ipairs(root.CampusGrass_v1:GetDescendants()) do
		if v:IsA("BasePart") and (v.Name=="Trunk" or v:IsA("Seat")) then table.insert(occupied,v.Position) end
	end
	local function inside(poly,x,z)
		local hit=false;local previous=poly[#poly]
		for _,v in ipairs(poly) do
			if (v[2]>z)~=(previous[2]>z) and x<(previous[1]-v[1])*(z-v[2])/(previous[2]-v[2])+v[1] then hit=not hit end
			previous=v
		end
		return hit
	end
	local function clear(x,z,size)
		local pos=Vector3.new(origin.X+x,6,origin.Z+z)
		for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos),Vector3.new(size,11,size),overlap)) do if p.CanCollide then return false end end
		return true
	end
	local function far(pos,distance)
		for _,q in ipairs(occupied) do if Vector3.new(pos.X-q.X,0,pos.Z-q.Z).Magnitude<distance then return false end end
		return true
	end
	local function part(parent,name,size,pos,color,material,collide,shape)
		local p=Instance.new("Part");p.Name,p.Size,p.Position=name,size,pos
		p.Color,p.Material=color,material;p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,collide,false,collide
		p.CastShadow=collide;if shape then p.Shape=shape end;p.Parent=parent;return p
	end
	local treeColors={Color3.fromRGB(55,103,61),Color3.fromRGB(67,119,72),Color3.fromRGB(92,129,67),Color3.fromRGB(47,91,75),Color3.fromRGB(136,113,76)}
	local trees,shrubs,flowerbeds,benches=0,0,0,0
	for _,f in ipairs(manifest.features) do if f.category=="area" and f.id:match("^grass%d*$") then
		local poly=f.polygonStuds;local x0,x1,z0,z1=math.huge,-math.huge,math.huge,-math.huge;local sum=0
		for i,v in ipairs(poly) do local nextv=poly[i%#poly+1];sum+=v[1]*nextv[2]-nextv[1]*v[2];x0=math.min(x0,v[1]);x1=math.max(x1,v[1]);z0=math.min(z0,v[2]);z1=math.max(z1,v[2]) end
		local target=math.clamp(math.floor(math.abs(sum)/2/750),1,12)
		local random=Random.new(20261102+#f.id*101+math.floor(x0*3+z0))
		local candidates={}
		for z=z0+7,z1-7,16 do for x=x0+7,x1-7,16 do
			local a,b=x+random:NextNumber(-2,2),z+random:NextNumber(-2,2)
			if inside(poly,a-5,b-5) and inside(poly,a+5,b-5) and inside(poly,a-5,b+5) and inside(poly,a+5,b+5) then table.insert(candidates,{a,b}) end
		end end
		for i=#candidates,2,-1 do local j=random:NextInteger(1,i);candidates[i],candidates[j]=candidates[j],candidates[i] end
		local area=Instance.new("Model");area.Name=f.id;local made=0
		for _,cell in ipairs(candidates) do
			if made>=target then break end
			local pos=Vector3.new(origin.X+cell[1],0,origin.Z+cell[2])
			if far(pos,15) and clear(cell[1],cell[2],11) then
				local kind=(trees%5)+1;local trunk=if kind==3 then 4.8 else 4.1
				local tree=Instance.new("Model");tree.Name="ParkTree_"..kind
				part(tree,"Trunk",Vector3.new(1.05,trunk,1.05),pos+Vector3.new(0,trunk/2+.15,0),Color3.fromRGB(98,72,49),Enum.Material.Wood,true)
				local leaf=treeColors[kind]
				if kind==1 then
					part(tree,"Crown",Vector3.new(7,4.8,7),pos+Vector3.new(0,6.5,0),leaf,Enum.Material.Grass,false,Enum.PartType.Ball)
				elseif kind==2 then
					for _,dx in ipairs({-2,2}) do part(tree,"Crown",Vector3.new(5,4.2,5),pos+Vector3.new(dx,6.4,0),leaf,Enum.Material.Grass,false,Enum.PartType.Ball) end
					part(tree,"Crown",Vector3.new(5,4.5,5),pos+Vector3.new(0,7.8,0),leaf,Enum.Material.Grass,false,Enum.PartType.Ball)
				elseif kind==3 then
					part(tree,"Crown",Vector3.new(4.2,7,4.2),pos+Vector3.new(0,8,0),leaf,Enum.Material.Grass,false,Enum.PartType.Ball)
				elseif kind==4 then
					part(tree,"Crown",Vector3.new(8,2.8,7),pos+Vector3.new(0,6.4,0),leaf,Enum.Material.Grass,false,Enum.PartType.Ball)
					part(tree,"Crown",Vector3.new(5.2,3,5.2),pos+Vector3.new(0,8,0),leaf,Enum.Material.Grass,false,Enum.PartType.Ball)
				else
					part(tree,"Crown",Vector3.new(6,4.5,6),pos+Vector3.new(0,6.6,0),leaf,Enum.Material.Grass,false,Enum.PartType.Ball)
					part(tree,"Crown",Vector3.new(3.2,2.8,3.2),pos+Vector3.new(1.5,8,0),treeColors[3],Enum.Material.Grass,false,Enum.PartType.Ball)
				end
				tree.Parent=area;table.insert(occupied,pos);trees+=1;made+=1
			end
		end
		-- Low shrubs and flowers fill gaps without blocking movement or future roads.
		local low=0
		for _,cell in ipairs(candidates) do
			if low>=math.min(5,math.max(1,math.floor(#candidates/5))) then break end
			local pos=Vector3.new(origin.X+cell[1],0,origin.Z+cell[2])
			if far(pos,8) and clear(cell[1],cell[2],5) then
				local bush=Instance.new("Model");bush.Name="ShrubCluster"
				for _,dx in ipairs({-1.1,1.1}) do part(bush,"Shrub",Vector3.new(2.6,1.8,2.6),pos+Vector3.new(dx,1.05,0),treeColors[(low%3)+1],Enum.Material.Grass,false,Enum.PartType.Ball) end
				bush.Parent=area;table.insert(occupied,pos);low+=1;shrubs+=1
				if low%2==1 then
					for _,dx in ipairs({-.8,0,.8}) do part(area,"Flower",Vector3.new(.35,.35,.35),pos+Vector3.new(dx,1.95,0),if low%4==1 then Color3.fromRGB(224,184,79) else Color3.fromRGB(185,125,162),Enum.Material.Neon,false,Enum.PartType.Ball) end
					flowerbeds+=1
				end
			end
		end
		if #candidates>=6 then
			for _,cell in ipairs(candidates) do local pos=Vector3.new(origin.X+cell[1],0,origin.Z+cell[2])
				if far(pos,8) and clear(cell[1],cell[2],6) then
					local bench=Instance.new("Model");bench.Name="ParkBench"
					local seat=Instance.new("Seat");seat.Name="Seat";seat.Size=Vector3.new(5,.45,1.8);seat.Position=pos+Vector3.new(0,1.65,0)
					seat.Color,seat.Material,seat.Anchored=Color3.fromRGB(174,174,162),Enum.Material.Concrete,true;seat.Parent=bench
					for _,dx in ipairs({-1.8,1.8}) do part(bench,"Support",Vector3.new(.55,1.4,1.5),pos+Vector3.new(dx,.85,0),seat.Color,Enum.Material.Concrete,true) end
					part(bench,"Backrest",Vector3.new(5,1.45,.35),pos+Vector3.new(0,2.6,.75),seat.Color,Enum.Material.Concrete,false)
					bench.Parent=area;table.insert(occupied,pos);benches+=1;break
				end
			end
		end
		area.Parent=output;task.wait()
	end end
	return string.format("Added %d trees, %d shrub groups, %d flower beds and %d usable benches",trees,shrubs,flowerbeds,benches)
end
