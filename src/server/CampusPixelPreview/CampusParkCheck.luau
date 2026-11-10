-- Edit-mode checks of polygon coverage, planting, A2 details and canteen seats.
return function()
	local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
	local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
	local origin=root:GetAttribute("PreviewOriginWorld")
	local function inside(poly,x,z)
		local hit=false;local a=poly[#poly]
		for _,b in ipairs(poly) do if (a[2]>z)~=(b[2]>z) and x<(b[1]-a[1])*(z-a[2])/(b[2]-a[2])+a[1] then hit=not hit end;a=b end
		return hit
	end
	local points,edges,areas=0,0,0
	for _,f in ipairs(manifest.features) do if f.category=="area" and f.id:match("^grass%d*$") then
		local model=assert(root.CampusExactGrass_v1:FindFirstChild(f.id));local poly=f.polygonStuds
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={model};params.RespectCanCollide=true
		local x0,x1,z0,z1=math.huge,-math.huge,math.huge,-math.huge
		for _,v in ipairs(poly) do x0=math.min(x0,v[1]);x1=math.max(x1,v[1]);z0=math.min(z0,v[2]);z1=math.max(z1,v[2]) end
		local function grassAt(x,z) return workspace:Raycast(Vector3.new(origin.X+x,5,origin.Z+z),Vector3.new(0,-10,0),params)~=nil end
		for z=z0+3,z1-3,13 do for x=x0+3,x1-3,13 do if inside(poly,x,z) then assert(grassAt(x,z),"Gap in "..f.id);points+=1 end end end
		for i,a in ipairs(poly) do local b=poly[i%#poly+1];local dx,dz=b[1]-a[1],b[2]-a[2];local length=math.sqrt(dx*dx+dz*dz)
			for _,side in ipairs({-.4,.4}) do
				local x=(a[1]+b[1])/2-dz/length*side;local z=(a[2]+b[2])/2+dx/length*side
				assert(grassAt(x,z)==inside(poly,x,z),"Incorrect grass edge in "..f.id);edges+=1
			end
		end
		areas+=1
	end end
	local newTrees,shrubs,parkSeats=0,0,0;local kinds={}
	for _,v in ipairs(root.CampusParkDetails_v1:GetDescendants()) do
		if v:IsA("Model") and v.Name:match("^ParkTree_") then local _,size=v:GetBoundingBox();assert(size.Y<(v:GetAttribute("PolishedTree_v1") and 24 or 12));newTrees+=1;kinds[v.Name]=true
		elseif v:IsA("Model") and v.Name=="ShrubCluster" then shrubs+=1
		elseif v:IsA("Seat") then assert(not v.Disabled);parkSeats+=1 end
	end
	local kindCount=0;for _ in pairs(kinds) do kindCount+=1 end
	assert(areas==24 and points>700 and edges>200 and newTrees==76 and kindCount==5 and shrubs==38 and parkSeats==17)
	local library=root.Buildings.A2.A2_LibraryIdentity_v1
	assert(#library.LibraryBooks:GetChildren()==324)
	local canteen=root.Buildings.Canteen;local seats,menus=0,0
	for _,v in ipairs(canteen:GetDescendants()) do
		if v:IsA("Seat") and v.Name=="DiningSeat" then assert(not v.Disabled);seats+=1
		elseif v:IsA("SurfaceGui") and v.Name=="DiningMenu" then assert(not v.AlwaysOnTop);menus+=1 end
	end
	assert(seats==50 and menus==50)
	return string.format("%d grass samples, %d edge samples, %d added trees, A2 books and canteen seats checked",points,edges,newTrees)
end
