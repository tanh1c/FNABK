-- AI-assisted native landscape on traced grass polygons. No reference assets are uploaded.
return function()
	local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
	assert(not root:FindFirstChild("CampusGrass_v1"),"Grass pass already exists")
	local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
	local origin=assert(root:GetAttribute("PreviewOriginWorld"))
	assert(typeof(origin)=="Vector3","Expected preview origin")
	local buildings=root.Buildings
	local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={buildings}
	local rootFolder=Instance.new("Folder");rootFolder.Name="CampusGrass_v1";rootFolder.Parent=root
	local function inside(poly,x,z)
		local hit=false;local previous=poly[#poly]
		for _,v in ipairs(poly) do
			if (v[2]>z)~=(previous[2]>z) and x<(previous[1]-v[1])*(z-v[2])/(previous[2]-v[2])+v[1] then hit=not hit end
			previous=v
		end
		return hit
	end
	local function available(x,z,size)
		for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(origin.X+x,1.4,origin.Z+z),Vector3.new(size,2.6,size),overlap)) do
			if p.CanCollide then return false end
		end
		return true
	end
	local function part(parent,name,size,cf,color,material,collide)
		local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf
		p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,collide,false,collide
		p.Color,p.Material=color,material;p.CastShadow=collide;p.Parent=parent
		return p
	end
	local areas,patches,trees,seats=0,0,0,0
	for _,feature in ipairs(manifest.features) do if feature.id:match("^grass%d*$") and feature.category=="area" then
		local polygon=feature.polygonStuds
		local x0,x1,z0,z1=math.huge,-math.huge,math.huge,-math.huge
		for _,v in ipairs(polygon) do x0=math.min(x0,v[1]);x1=math.max(x1,v[1]);z0=math.min(z0,v[2]);z1=math.max(z1,v[2]) end
		local area=Instance.new("Model");area.Name=feature.id;area:SetAttribute("SourceFeatureID",feature.id)
		local cells={};local step=8
		for z=z0+step/2,z1-step/2,step do
			local runStart,runCount=nil,0
			local function flush()
				if runStart then
					part(area,"Grass",Vector3.new(runCount*step,0.15,step),CFrame.new(origin.X+runStart+(runCount-1)*step/2,0.075,origin.Z+z),Color3.fromRGB(79,122,73),Enum.Material.Grass,true)
					patches+=1;runStart=nil;runCount=0
				end
			end
			for x=x0+step/2,x1-step/2,step do
				local good=inside(polygon,x-4,z-4) and inside(polygon,x+4,z-4) and inside(polygon,x-4,z+4) and inside(polygon,x+4,z+4) and available(x,z,7.6)
				if good then if not runStart then runStart=x end;runCount+=1;table.insert(cells,{x,z}) else flush() end
			end
			flush()
		end
		-- ponytail: deterministic small native trees; add a richer species set after visual/performance review.
		local used={};local maxTrees=math.min(4,math.floor(#cells/12))
		for index,cell in ipairs(cells) do
			if #used>=maxTrees then break end
			if index%7==1 then
				local far=true;for _,q in ipairs(used) do if (cell[1]-q[1])^2+(cell[2]-q[2])^2<24^2 then far=false end end
				if far and available(cell[1],cell[2],6) then
					local x,z=origin.X+cell[1],origin.Z+cell[2]
					local variant=(trees%3)+1
					local model=Instance.new("Model");model.Name="CampusTree_"..variant
					part(model,"Trunk",Vector3.new(0.9,3.2,0.9),CFrame.new(x,1.7,z),Color3.fromRGB(98,75,53),Enum.Material.Wood,true)
					local colors={Color3.fromRGB(72,117,67),Color3.fromRGB(56,103,72),Color3.fromRGB(99,128,72)}
					local canopy=part(model,"Canopy",Vector3.new(if variant==3 then 4.4 else 5.5,if variant==2 then 4.6 else 4,if variant==3 then 4.4 else 5.5),CFrame.new(x,5.3,z),colors[variant],Enum.Material.Grass,false)
					canopy.Shape=if variant==2 then Enum.PartType.Block else Enum.PartType.Ball
					if variant==3 then part(model,"UpperCanopy",Vector3.new(3.3,2.8,3.3),CFrame.new(x,7.1,z),colors[variant],Enum.Material.Grass,false).Shape=Enum.PartType.Ball end
					model.Parent=area;table.insert(used,cell);trees+=1
				end
			end
		end
		if #cells>=5 then
			for i=#cells,1,-1 do
				local cell=cells[i];local far=true
				for _,q in ipairs(used) do if (cell[1]-q[1])^2+(cell[2]-q[2])^2<9^2 then far=false end end
				if far and available(cell[1],cell[2],6) then
					local x,z=origin.X+cell[1],origin.Z+cell[2]
					local bench=Instance.new("Model");bench.Name="StoneBench"
					local seat=Instance.new("Seat");seat.Name="Seat";seat.Size=Vector3.new(5,0.45,1.8);seat.CFrame=CFrame.new(x,1.65,z)
					seat.Color=Color3.fromRGB(171,172,161);seat.Material=Enum.Material.Concrete;seat.Anchored=true;seat.Parent=bench
					for _,dx in ipairs({-1.8,1.8}) do part(bench,"Support",Vector3.new(0.55,1.4,1.5),CFrame.new(x+dx,0.85,z),seat.Color,Enum.Material.Concrete,true) end
					part(bench,"Backrest",Vector3.new(5,1.45,0.35),CFrame.new(x,2.6,z+0.75),seat.Color,Enum.Material.Concrete,false)
					bench.Parent=area;seats+=1;break
				end
			end
		end
		area:SetAttribute("GrassCellCount",#cells);area.Parent=rootFolder;areas+=1
		task.wait()
	end end
	assert(areas==24,"Expected 24 traced grass areas")
	return string.format("Created %d grass areas (%d strips), %d small trees and %d usable seats",areas,patches,trees,seats)
end
