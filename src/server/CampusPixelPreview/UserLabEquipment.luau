--!strict
-- Script-free laboratory equipment selected from the user's supplied models.
local Equipment={}

function Equipment.Build(campus: Model, library: Folder): Model
	assert(not campus:FindFirstChild("UserLabEquipment_20261104"), "Lab equipment already exists")
	local buildings=assert(campus:FindFirstChild("Buildings"))
	local plan={{"A3","Asset_30","LabEquipment"},{"B4","Asset_34","ResearchEquipment"}}
	local output=Instance.new("Model");output.Name="UserLabEquipment_20261104"
	local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={campus};ray.RespectCanCollide=true
	local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={campus};overlap.RespectCanCollide=true
	for _,entry in ipairs(plan) do
		local building=assert(buildings:FindFirstChild(entry[1]))
		local slot=assert(library:FindFirstChild(entry[2]))
		local source=slot:GetChildren()[1]
		assert(building:IsA("Model") and source and source:IsA("Model"), "Missing lab asset")
		local copy=source:Clone();copy.Name=entry[3]
		for _,v in ipairs(copy:GetDescendants()) do
			if v:IsA("LuaSourceContainer") or v:IsA("Tool") or v:IsA("GuiBase") or v:IsA("Decal") or v:IsA("Texture")
				or v:IsA("Sound") or v:IsA("ClickDetector") or v:IsA("ProximityPrompt") or v:IsA("ParticleEmitter") then v:Destroy()
			elseif v:IsA("BasePart") then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end
		end
		local bounds,size=copy:GetBoundingBox()
		assert(bounds.UpVector.Y>0.99,"Lab source must be upright")
		local center=building:GetBoundingBox().Position
		local target: Vector3?=nil
		for dx=-50,50,5 do
			for dz=-25,25,5 do
				local h=workspace:Raycast(Vector3.new(center.X+dx,6,center.Z+dz),Vector3.new(0,-8,0),ray)
				if h and h.Instance:IsDescendantOf(building) and h.Position.Y>0.6 and h.Position.Y<1
					and #workspace:GetPartBoundsInBox(CFrame.new(h.Position+Vector3.new(0,size.Y/2+.2,0)),Vector3.new(size.X+2,size.Y+0.3,size.Z+2),overlap)==0 then
					target=h.Position;break
				end
			end
			if target then break end
		end
		assert(target,"No clear floor for "..entry[3])
		copy:PivotTo(CFrame.new(target+Vector3.new(0,size.Y/2,0))*(bounds:Inverse()*copy:GetPivot()))
		copy:SetAttribute("VisualOnly",true);copy:SetAttribute("SourceSlot",entry[2]);copy.Parent=output
	end
	output.Parent=campus
	return output
end

return table.freeze(Equipment)
