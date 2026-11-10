--!strict
-- Reuse the user's vending-machine geometry without its marketplace controls.
local Vending={}

function Vending.Build(campus: Model, library: Folder): Model
	assert(not campus:FindFirstChild("UserVendingMachine_20261104"), "Vending machine already exists")
	local canteen=assert(assert(campus:FindFirstChild("Buildings")):FindFirstChild("Canteen"))
	assert(canteen:IsA("Model"), "Canteen missing")
	local source=assert(assert(library:FindFirstChild("Asset_10")):FindFirstChild("Vending Machine"))
	assert(source:IsA("Model"), "Vending model missing")
	local output=Instance.new("Model")
	output.Name="UserVendingMachine_20261104"
	for _,name in ipairs({"Body","Rows"}) do
		local section=source:FindFirstChild(name)
		if section then section:Clone().Parent=output end
	end
	for _,v in ipairs(output:GetDescendants()) do
		if v:IsA("Tool") or v:IsA("LuaSourceContainer") or v:IsA("GuiBase") or v:IsA("Decal") or v:IsA("Texture")
			or v:IsA("Sound") or v:IsA("ClickDetector") or v:IsA("ProximityPrompt") or v:IsA("ParticleEmitter") then v:Destroy()
		elseif v:IsA("BasePart") then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end
	end
	local ray=RaycastParams.new()
	ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={campus};ray.RespectCanCollide=true
	local overlap=OverlapParams.new()
	overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={campus};overlap.RespectCanCollide=true
	local center=canteen:GetBoundingBox().Position
	local point: Vector3?=nil
	for dx=-55,55,5 do
		for dz=-20,20,5 do
			local hit=workspace:Raycast(Vector3.new(center.X+dx,6,center.Z+dz),Vector3.new(0,-8,0),ray)
			if hit and hit.Instance:IsDescendantOf(canteen) and hit.Position.Y>0.6 and hit.Position.Y<1
				and #workspace:GetPartBoundsInBox(CFrame.new(hit.Position+Vector3.new(0,3.8,0)),Vector3.new(4.5,7,3.8),overlap)==0 then
				point=hit.Position;break
			end
		end
		if point then break end
	end
	assert(point, "No clear vending placement in canteen")
	local bounds,size=output:GetBoundingBox()
	output:PivotTo(CFrame.new(point+Vector3.new(0,size.Y/2,0))*(bounds:Inverse()*output:GetPivot()))
	output:SetAttribute("VisualOnly",true)
	output.Parent=campus
	return output
end

return table.freeze(Vending)
