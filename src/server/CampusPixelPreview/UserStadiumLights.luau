--!strict
-- Two visual-only copies of the user's stadium lights (SURV-12).
local Lights = {}

function Lights.Build(campus: Model, library: Folder): Model
	assert(not campus:FindFirstChild("UserStadiumLights_20261104"), "Stadium lights already placed")
	local output = Instance.new("Model")
	output.Name = "UserStadiumLights_20261104"
	local ray = RaycastParams.new()
	ray.FilterType = Enum.RaycastFilterType.Include
	ray.FilterDescendantsInstances = {campus}
	ray.RespectCanCollide = true
	for _, entry in ipairs({{"Asset_26", Vector3.new(4825,0,1948)}, {"Asset_27", Vector3.new(4990,0,2008)}}) do
		local slot = assert(library:FindFirstChild(entry[1] :: string))
		local source = slot:GetChildren()[1]
		assert(source and source:IsA("Model"), "Stadium light model missing")
		local model = source:Clone()
		model.Name = entry[1] :: string
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("LuaSourceContainer") or p:IsA("GuiBase") or p:IsA("Decal") or p:IsA("Texture") or p:IsA("Sound") or p:IsA("Light") then
				p:Destroy()
			elseif p:IsA("BasePart") then
				p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
			end
		end
		-- Align the long pole vertically; the source was supplied on its side.
		local desired = entry[2] :: Vector3
		local hit = workspace:Raycast(desired+Vector3.new(0,30,0),Vector3.new(0,-40,0),ray)
		assert(hit, "No ground below stadium light")
		model:PivotTo(CFrame.identity)
		local pole: BasePart? = nil
		for _, p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") and p.Size.Y > 60 then pole=p; break end end
		assert(pole, "Stadium light pole missing")
		local rotation = CFrame.Angles(0,0,math.pi/2)
		local center = Vector3.new(desired.X,hit.Position.Y+pole.Size.Y/2,desired.Z)
		model:PivotTo(CFrame.new(center)*rotation*CFrame.new(-pole.Position))
		local bulb = model:FindFirstChild("LightPart",true)
		if bulb and bulb:IsA("BasePart") then
			-- ponytail: one light per mast; profile before enabling additional lamps.
			local light=Instance.new("PointLight")
			light.Brightness=1.2; light.Range=50; light.Shadows=false; light.Parent=bulb
		end
		model:SetAttribute("VisualOnly",true)
		model.Parent=output
	end
	output.Parent=campus
	return output
end

return table.freeze(Lights)
