-- AI-assisted boundary based on the local traced polygon and three entrance markers.
return function()
	local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
	assert(not root:FindFirstChild("CampusBoundaryAndGates_v1"),"Boundary pass already exists")
	local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
	local origin=assert(root:GetAttribute("PreviewOriginWorld"))
	local polygon
	for _,f in ipairs(manifest.features) do if f.id=="CampusBoundary" then polygon=f.polygonStuds end end
	assert(polygon and #polygon>=3 and #manifest.entrances==3,"Boundary or entrance data missing")
	local gates={}
	for index,e in ipairs(manifest.entrances) do
		local best
		for i,a in ipairs(polygon) do
			local b=polygon[i%#polygon+1];local dx,dz=b[1]-a[1],b[2]-a[2]
			local length=math.sqrt(dx*dx+dz*dz)
			local t=math.clamp(((e.positionStuds[1]-a[1])*dx+(e.positionStuds[2]-a[2])*dz)/(length*length),0,1)
			local x,z=a[1]+t*dx,a[2]+t*dz
			local distance=math.sqrt((x-e.positionStuds[1])^2+(z-e.positionStuds[2])^2)
			if not best or distance<best.distance then best={edge=i,along=t*length,distance=distance,index=index} end
		end
		assert(best.distance<20,"Entrance too far from traced border")
		table.insert(gates,best)
	end
	local output=Instance.new("Folder");output.Name="CampusBoundaryAndGates_v1";output.Parent=root
	local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={root.Buildings}
	local concrete=Color3.fromRGB(178,180,173);local dark=Color3.fromRGB(48,73,85)
	local function part(parent,name,size,cf,color,material,collision,transparency)
		local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf
		p.Color,p.Material,p.Transparency=color,material,transparency or 0
		p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,collision,false,collision
		p.CastShadow=collision and (transparency or 0)<1;p.Parent=parent;return p
	end
	local spans,skipped=0,0
	for i,a in ipairs(polygon) do
		local b=polygon[i%#polygon+1];local dx,dz=b[1]-a[1],b[2]-a[2];local length=math.sqrt(dx*dx+dz*dz)
		local right=Vector3.new(dx/length,0,dz/length)
		local frame=CFrame.fromMatrix(Vector3.new(origin.X+a[1],0,origin.Z+a[2]),right,Vector3.yAxis,right:Cross(Vector3.yAxis))
		local openings={}
		for _,g in ipairs(gates) do if g.edge==i then table.insert(openings,g) end end
		table.sort(openings,function(x,y) return x.along<y.along end)
		local edge=Instance.new("Model");edge.Name="BoundaryEdge_"..i
		local function wall(startPos,endPos)
			local count=math.ceil((endPos-startPos)/12)
			for n=1,count do
				local from=startPos+(endPos-startPos)*(n-1)/count
				local to=startPos+(endPos-startPos)*n/count
				local mid=(from+to)/2;local width=to-from
				local blocked=false
				for _,v in ipairs(workspace:GetPartBoundsInBox(frame*CFrame.new(mid,3.5,0),Vector3.new(width,7,1.2),overlap)) do if v.CanCollide then blocked=true;break end end
				if blocked then skipped+=1 else
					part(edge,"BoundaryBase",Vector3.new(width,2.2,0.8),frame*CFrame.new(mid,1.1,0),concrete,Enum.Material.Concrete,true)
					part(edge,"FenceBarrier",Vector3.new(width,4.8,0.3),frame*CFrame.new(mid,4.6,0),dark,Enum.Material.Metal,true,1)
					part(edge,"FenceUpperRail",Vector3.new(width,0.25,0.32),frame*CFrame.new(mid,6.8,0),dark,Enum.Material.Metal,false)
					part(edge,"FenceMiddleRail",Vector3.new(width,0.2,0.28),frame*CFrame.new(mid,4.5,0),dark,Enum.Material.Metal,false)
					part(edge,"FencePost",Vector3.new(0.5,5.2,0.5),frame*CFrame.new(from,4.4,0),dark,Enum.Material.Metal,false)
					spans+=1
				end
			end
		end
		local cursor=0
		for _,g in ipairs(openings) do
			local startPos=math.max(cursor,g.along-16);local endPos=math.min(length,g.along+16)
			if startPos>cursor then wall(cursor,startPos) end
			local gate=Instance.new("Model");gate.Name="CampusGate_"..g.index
			gate:SetAttribute("SourceMarker",manifest.entrances[g.index].id);gate:SetAttribute("BoundarySnapStuds",g.distance)
			for _,x in ipairs({startPos,endPos}) do
				part(gate,"GatePillar",Vector3.new(2,10,2),frame*CFrame.new(x,5,0),concrete,Enum.Material.Concrete,true)
				part(gate,"GatePillarCap",Vector3.new(2.5,0.5,2.5),frame*CFrame.new(x,10.25,0),dark,Enum.Material.Metal,false)
			end
			local beam=part(gate,"GateHeader",Vector3.new(endPos-startPos+2,1.6,1.2),frame*CFrame.new((startPos+endPos)/2,10.7,0),dark,Enum.Material.Metal,true)
			for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
				local gui=Instance.new("SurfaceGui");gui.Face,gui.LightInfluence,gui.Parent=face,0,beam
				local label=Instance.new("TextLabel");label.Size,label.BackgroundTransparency,label.Text=UDim2.fromScale(1,1),1,"CỔNG "..g.index
				label.TextColor3,label.TextScaled,label.Font,label.Parent=Color3.new(1,1,1),true,Enum.Font.GothamBold,gui
			end
			gate.Parent=edge;cursor=endPos
		end
		if cursor<length then wall(cursor,length) end
		edge.Parent=output;task.wait()
	end
	output:SetAttribute("SkippedIntersectingSpans",skipped)
	return string.format("Created 3 open gates and %d fence spans; skipped %d spans intersecting buildings",spans,skipped)
end
