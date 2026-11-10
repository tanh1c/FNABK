-- Add a provisional walkable surface inside the existing traced campus boundary.
return function()
 local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
 assert(not root:FindFirstChild("CampusGround_v1"),"Ground already exists")
 local manifest=require(game.ServerScriptService.FNABKServer.CampusPixelPreview.CampusPreviewManifest)
 local origin=assert(root:GetAttribute("PreviewOriginWorld"))
 assert(root:GetAttribute("HorizontalMirrorApplied")==manifest.horizontalMirrorApplied and root:GetAttribute("PreviewStudsPerPixel")==manifest.previewStudsPerPixel, "Manifest and preview differ")
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
		assert(height>.05,"Degenerate ground triangle")
		local made=0
		for _,item in ipairs({{a,b,right,back,math.abs(ab:Dot(back))},{a,c,-right,-back,math.abs(ac:Dot(back))}}) do
			if item[5]>.05 then
				local p=Instance.new("WedgePart");p.Name="GroundTriangle"
				p.Size=Vector3.new(.25,height,item[5]);p.CFrame=CFrame.fromMatrix((item[1]+item[2])/2,item[3],up,item[4])
				p.Color,p.Material=Color3.fromRGB(115,119,116),Enum.Material.Concrete
				p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery,p.CastShadow=true,true,false,true,false;p.Parent=parent;made+=1
			end
		end
		return made
	end

 local polygon
 for _,f in ipairs(manifest.features) do if f.id=="CampusBoundary" then assert(not polygon);polygon=f.polygonStuds end end
 assert(polygon and #polygon>=3)
 local tris=triangles(polygon)
 local output=Instance.new("Model");output.Name="CampusGround_v1"
 output:SetAttribute("Provisional",true)
 output:SetAttribute("GeometrySource","CampusPreviewManifest.CampusBoundary")
 local count=0
 for _,t in ipairs(tris) do
  local a=Vector3.new(origin.X+t[1][1],-.125,origin.Z+t[1][2])
  local b=Vector3.new(origin.X+t[2][1],-.125,origin.Z+t[2][2])
  local c=Vector3.new(origin.X+t[3][1],-.125,origin.Z+t[3][2])
  count+=wedge(output,a,b,c)
 end
 assert(count>0)
 output.Parent=root
 return string.format("Added %d native ground wedges within the traced campus boundary",count)
end
