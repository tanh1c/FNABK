-- Ear-clipped native wedges follow each traced grass polygon without grid stair-steps.
return function()
	local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
	local old=assert(root:FindFirstChild("CampusGrass_v1"))
	local storage=game:GetService("ServerStorage")
	assert(not root:FindFirstChild("CampusExactGrass_v1") and not storage:FindFirstChild("CampusGrassGridBackup_v1"),"Grass pass already exists")
	local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
	local origin=root:GetAttribute("PreviewOriginWorld")
	local function cross(a,b,c) return (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1]) end
	local function area(poly)
		local sum=0;for i,a in ipairs(poly) do local b=poly[i%#poly+1];sum+=a[1]*b[2]-b[1]*a[2] end;return sum/2
	end
	local function triangles(polygon)
		local vertices={};for _,v in ipairs(polygon) do table.insert(vertices,{v[1],v[2]}) end
		if area(vertices)<0 then local reverse={};for i=#vertices,1,-1 do table.insert(reverse,vertices[i]) end;vertices=reverse end
		local expected=area(vertices);assert(expected>0.01,"Invalid grass polygon")
		local result={}
		while #vertices>3 do
			local found=false
			for i=1,#vertices do
				local previous=(i-2)%#vertices+1;local nextIndex=i%#vertices+1
				local a,b,c=vertices[previous],vertices[i],vertices[nextIndex]
				if cross(a,b,c)>0.0001 then
					local contains=false
					for j,p in ipairs(vertices) do if j~=previous and j~=i and j~=nextIndex then
						if cross(a,b,p)>=-0.0001 and cross(b,c,p)>=-0.0001 and cross(c,a,p)>=-0.0001 then contains=true;break end
					end end
					if not contains then table.insert(result,{a,b,c});table.remove(vertices,i);found=true;break end
				end
			end
			assert(found,"Could not triangulate traced grass polygon")
		end
		table.insert(result,{vertices[1],vertices[2],vertices[3]})
		local sum=0;for _,t in ipairs(result) do sum+=cross(t[1],t[2],t[3])/2 end
		assert(math.abs(sum-expected)<math.max(.01,expected*.00001),"Grass polygon area mismatch")
		return result
	end
	local function wedge(parent,a,b,c)
		local ab,ac,bc=b-a,c-a,c-b
		local ab2,ac2,bc2=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
		if ab2>ac2 and ab2>bc2 then c,a=a,c elseif ac2>bc2 and ac2>ab2 then a,b=b,a end
		ab,ac,bc=b-a,c-a,c-b
		local right=ac:Cross(ab).Unit
		local up=bc:Cross(right).Unit
		local back=bc.Unit
		local height=math.abs(ab:Dot(up))
		assert(height>.05,"Degenerate grass triangle")
		local made=0
		for _,item in ipairs({{a,b,right,back,math.abs(ab:Dot(back))},{a,c,-right,-back,math.abs(ac:Dot(back))}}) do
			if item[5]>.05 then
				local p=Instance.new("WedgePart");p.Name="GrassTriangle"
				p.Size=Vector3.new(.15,height,item[5]);p.CFrame=CFrame.fromMatrix((item[1]+item[2])/2,item[3],up,item[4])
				p.Color,p.Material=Color3.fromRGB(79,122,73),Enum.Material.Grass
				p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery,p.CastShadow=true,true,false,true,false;p.Parent=parent;made+=1
			end
		end
		return made
	end
	local plans={};for _,f in ipairs(manifest.features) do if f.category=="area" and f.id:match("^grass%d*$") then table.insert(plans,{id=f.id,triangles=triangles(f.polygonStuds)}) end end
	assert(#plans==24,"Expected 24 grass areas")
	local output=Instance.new("Folder");output.Name="CampusExactGrass_v1"
	local count=0
	for _,plan in ipairs(plans) do
		local areaModel=Instance.new("Model");areaModel.Name=plan.id;areaModel:SetAttribute("TriangleCount",#plan.triangles)
		for _,t in ipairs(plan.triangles) do
			local a=Vector3.new(origin.X+t[1][1],.075,origin.Z+t[1][2])
			local b=Vector3.new(origin.X+t[2][1],.075,origin.Z+t[2][2])
			local c=Vector3.new(origin.X+t[3][1],.075,origin.Z+t[3][2])
			count+=wedge(areaModel,a,b,c)
		end
		areaModel.Parent=output
	end
	local backup=Instance.new("Folder");backup.Name="CampusGrassGridBackup_v1";backup.Parent=storage
	for _,areaModel in ipairs(old:GetChildren()) do
		local saved=Instance.new("Folder");saved.Name=areaModel.Name;saved.Parent=backup
		for _,p in ipairs(areaModel:GetChildren()) do if p:IsA("BasePart") and p.Name=="Grass" then p.Parent=saved end end
	end
	output.Parent=root
	return string.format("Replaced grid strips with %d wedges across %d exact traced polygons; old strips preserved",count,#plans)
end
