--!strict
-- Static visual copies of user-supplied Tools; originals and scripts stay in ServerStorage.
local Placement = {}

function Placement.Build(campus: Model, tools: Folder, library: Folder): Model
	assert(not campus:FindFirstChild("UserItemDisplays_v3_20261104"), "Item displays already exist")
	local buildings = assert(campus:FindFirstChild("Buildings"))
	local pack = assert(library:FindFirstChild("Asset_13")):GetChildren()[1]
	local occupied: {Vector3} = {}
	local existing = campus:FindFirstChild("CuratedUserProps_20261104")
	if existing then
		for _, m in ipairs(existing:GetChildren()) do
			if m:IsA("Model") then local cf=m:GetBoundingBox(); table.insert(occupied,cf.Position) end
		end
	end
	local output=Instance.new("Model")
	output.Name="UserItemDisplays_v3_20261104"
	local plan={
		{"A3","LabBench_1","NATMFlashlight","Flashlight","gear"},
		{"A3","LabBench_2","Blair UV Flashlight","UVFlashlight","gear"},
		{"A3","LabBench_2","Stick","MeleeStick","gear"},
		{"A2","ReadingTable","Radio","Radio","gear"},
		{"B4","LabBench_1","Handgun","Pistol","gear"},
		{"B4","LabBench_2","TrenchGun","Shotgun","gear"},
		{"B4","LabBench_1","Ak","Rifle","gear"},
		{"A2","ReadingTable","Banana","Banana","food"},
		{"A2","ReadingTable","Apple","Apple","food"},
		{"A2","ReadingTable","Grape","Grapes","food"},
		{"A2","ReadingTable","Chocolate bar","Chocolate","food"},
		{"A2","ReadingTable","Bloxy","Drink","food"},
	}
	for _, entry in ipairs(plan) do
		local building=buildings:FindFirstChild(entry[1])
		local source=if entry[5]=="gear" then tools:FindFirstChild(entry[3]) else pack:FindFirstChild(entry[3])
		assert(building and source and source:IsA("Tool"), "Missing item or building: "..entry[4])
		local point: Vector3? = nil
		for _, p in ipairs(building:GetDescendants()) do
			if p:IsA("BasePart") and p.Name==entry[2] and p.Position.Y>1 and p.Position.Y<5 then
				local good=true
				for _, at in ipairs(occupied) do if (Vector3.new(p.Position.X,0,p.Position.Z)-Vector3.new(at.X,0,at.Z)).Magnitude < 4 then good=false; break end end
				if good then point=p.Position+Vector3.new(0,p.Size.Y/2+0.03,0);table.insert(occupied,point);break end
			end
		end
		assert(point, "No unoccupied surface for "..entry[4])
		local copy=source:Clone()
		for _, p in ipairs(copy:GetDescendants()) do
			if p:IsA("LuaSourceContainer") or p:IsA("GuiBase") or p:IsA("Decal") or p:IsA("Texture")
				or p:IsA("Sound") or p:IsA("ClickDetector") or p:IsA("ProximityPrompt") or p:IsA("ParticleEmitter")
				or p:IsA("RemoteEvent") or p:IsA("RemoteFunction") or p:IsA("BindableEvent") or p:IsA("BindableFunction") then p:Destroy()
			elseif p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false end
		end
		local model=Instance.new("Model")
		model.Name=entry[4]
		for _, p in ipairs(copy:GetChildren()) do if p:IsA("BasePart") or p:IsA("Model") then p.Parent=model end end
		copy:Destroy()
		if entry[4]=="Shotgun" then
			local handle=model:FindFirstChild("Handle",true)
			if handle and handle:IsA("BasePart") then
				local barrel=handle.CFrame.LookVector
				if math.abs(barrel.Y)>0.05 then
					local pivot=model:GetPivot()
					local rotation=CFrame.fromAxisAngle(barrel:Cross(Vector3.xAxis).Unit,math.acos(math.clamp(barrel:Dot(Vector3.xAxis),-1,1)))
					model:PivotTo(CFrame.new(pivot.Position)*rotation*pivot.Rotation)
				end
			end
		end
		local minX,maxX,minZ,maxZ,minY=math.huge,-math.huge,math.huge,-math.huge,math.huge
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				local c,s=p.CFrame,p.Size
				local hx=(math.abs(c.RightVector.X)*s.X+math.abs(c.UpVector.X)*s.Y+math.abs(c.LookVector.X)*s.Z)/2
				local hy=(math.abs(c.RightVector.Y)*s.X+math.abs(c.UpVector.Y)*s.Y+math.abs(c.LookVector.Y)*s.Z)/2
				local hz=(math.abs(c.RightVector.Z)*s.X+math.abs(c.UpVector.Z)*s.Y+math.abs(c.LookVector.Z)*s.Z)/2
				minX,maxX=math.min(minX,c.X-hx),math.max(maxX,c.X+hx)
				minZ,maxZ=math.min(minZ,c.Z-hz),math.max(maxZ,c.Z+hz)
				minY=math.min(minY,c.Y-hy)
			end
		end
		assert(minY<math.huge, "Item has no visible parts: "..entry[4])
		model:PivotTo(model:GetPivot()+Vector3.new(point.X-(minX+maxX)/2,point.Y-minY,point.Z-(minZ+maxZ)/2))
		model:SetAttribute("VisualOnly",true)
		model:SetAttribute("SourceTool",entry[3])
		model.Parent=output
	end
	output.Parent=campus
	return output
end

return table.freeze(Placement)
