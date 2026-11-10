-- Opens a central-map-facing workshop bay between existing C1 machines.
return function()
	local b=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.C1
	local workshop=b.WorkshopArchitecture;local wall=assert(workshop:FindFirstChild("RearWorkshopWall"))
	assert(not b:FindFirstChild("CenterFacingEntrance_v1"))
	local archive=assert(game.ServerStorage:FindFirstChild("CampusEntryOriginals_v1"));assert(not archive:FindFirstChild("C1"))
	local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={b}
	local obstacles=workspace:GetPartBoundsInBox(CFrame.new(4929,4.8,2035),Vector3.new(8,7,24),params)
	local count=0;for _,v in ipairs(obstacles) do if v.CanCollide then assert(v==wall,"Workshop entrance blocked by "..v.Name);count+=1 end end
	assert(count==1 and #wall:GetChildren()==0,"Unexpected workshop wall")
	local c=wall.CFrame:PointToObjectSpace(Vector3.new(4929,wall.Position.Y,wall.Position.Z)).X
	local half=wall.Size.X/2;assert(c-4> -half and c+4<half)
	local entry=Instance.new("Model");entry.Name="CenterFacingEntrance_v1"
	local backup=Instance.new("Folder");backup.Name="C1"
	local function slice(a,z,lo,hi)
		if z-a<.05 or hi-lo<.05 then return end
		local q=wall:Clone();q.Name="WorkshopEntryWall"
		q.Size=Vector3.new(z-a,hi-lo,wall.Size.Z);q.CFrame=wall.CFrame*CFrame.new((a+z)/2,(lo+hi)/2,0);q.Parent=entry
	end
	local low,high=-wall.Size.Y/2,wall.Size.Y/2
	slice(-half,c-4,low,high);slice(c+4,half,low,high);slice(c-4,c+4,math.min(high,9.5-wall.Position.Y),high)
	local frame=wall.CFrame*CFrame.new(c,-wall.Position.Y,0)*CFrame.Angles(0,math.pi,0)
	local function part(name,size,cf,color,collide)
		local p=Instance.new("Part");p.Name,p.Size,p.CFrame=name,size,cf;p.Color,p.Material=color,Enum.Material.Metal
		p.Anchored,p.CanCollide,p.CanTouch=true,collide,false;p.Parent=entry;return p
	end
	local blue=Color3.fromRGB(42,79,100);local cream=Color3.fromRGB(210,210,195)
	part("EntryCanopy",Vector3.new(12,0.6,4),frame*CFrame.new(0,11,2),blue,true)
	for _,x in ipairs({-5,5}) do part("EntryColumn",Vector3.new(.8,10.5,.8),frame*CFrame.new(x,5.25,3.5),cream,true) end
	local closed=frame*CFrame.new(0,5.1,0)
	local open=closed+Vector3.new(0,9.3,0)
	local shutter=part("MainWorkshopShutter",Vector3.new(7.8,8.8,.2),open,Color3.fromRGB(100,113,114),false)
	shutter:SetAttribute("CampusDoor",true);shutter:SetAttribute("DoorClosed",closed);shutter:SetAttribute("DoorOpen",open);shutter:SetAttribute("StartsOpen",true)
	wall:SetAttribute("OriginalParentPath",wall.Parent:GetFullName());wall.Parent=backup;backup.Parent=archive;entry.Parent=b
	return "Created C1 workshop entrance between existing machines; rear wall preserved"
end
