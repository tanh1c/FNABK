--!strict
-- Visual-only curated props from the user's local asset library (SURV-12).
local Placement = {}

function Placement.Build(campus: Model, library: Folder): Model
	assert(not campus:FindFirstChild("CuratedUserProps_20261104"), "Curated props already exist")
	local buildings = assert(campus:FindFirstChild("Buildings"))
	local output = Instance.new("Model")
	output.Name = "CuratedUserProps_20261104"
	local plan = {
		{"B4", "Asset_07", "Microscope", "LabMicroscope", "LabBench_1"},
		{"B4", "Asset_07", "Vials", "LabVials", "LabBench_2"},
		{"A3", "Asset_37", "Scrap Metal", "ScrapMetal"},
		{"B4", "Asset_37", "Fuel", "FuelCan"},
		{"B4", "Asset_37", "Scrap Metal", "SpareMetal"},
		{"B4", "Asset_14", "Medkit", "MedicalKit"},
		{"A2", "Asset_14", "Gauze Wrap", "Gauze", "ReadingTable"},
		{"A2", "Asset_07", "water bottle", "WaterBottle", "ReadingTable"},
		{"Canteen", "Asset_07", "Apple", "FoodApple", "FoodTray"},
		{"Canteen", "Asset_07", "water bottle", "CanteenWater", "FoodTray"},
		{"A3", "Asset_07", "bunsen burner", "LabBurner", "LabBench_1"},
		{"A3", "Asset_07", "scale", "LabScale", "LabBench_2"},
		{"A3", "Asset_07", "Top Secret Folder", "LabRecords", "LabBench_1"},
		{"A2", "Asset_07", "Book Closed", "LibraryBook", "ReadingTable"},
		{"B4", "Asset_07", "Cardboard Box", "StorageBox"},
		{"B4", "Asset_37", "Tin can", "CannedFood", "LabBench_1"},
	}
	local ray = RaycastParams.new()
	ray.FilterType = Enum.RaycastFilterType.Include
	ray.FilterDescendantsInstances = {campus}
	ray.RespectCanCollide = true
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Include
	overlap.FilterDescendantsInstances = {campus}
	overlap.RespectCanCollide = true
	local placed: { Vector3 } = {}
	local usedSurfaces: { [BasePart]: boolean } = {}
	local function surface(building: Model, name: string): Vector3?
		for _, p in ipairs(building:GetDescendants()) do
			if p:IsA("BasePart") and p.Name == name and not usedSurfaces[p] and p.Position.Y > 1 and p.Position.Y < 5 then
				usedSurfaces[p] = true
				return p.Position + Vector3.new(0,p.Size.Y/2+0.03,0)
			end
		end
		return nil
	end
	local function position(building: Model): Vector3?
		local cf = building:GetBoundingBox()
		for dx=-25,25,5 do
			for dz=-20,20,5 do
				local hit = workspace:Raycast(Vector3.new(cf.X+dx,6,cf.Z+dz), Vector3.new(0,-8,0), ray)
				if hit and hit.Instance:IsDescendantOf(building) and hit.Position.Y > 0.6 and hit.Position.Y < 1 then
					local point = hit.Position
					local clear = #workspace:GetPartBoundsInBox(CFrame.new(point+Vector3.new(0,1.5,0)),Vector3.new(5,2.8,5),overlap)==0
					for _, prev in ipairs(placed) do if (point-prev).Magnitude < 9 then clear=false; break end end
					if clear then table.insert(placed,point); return point end
				end
			end
		end
		return nil
	end
	for _, entry in ipairs(plan) do
		local building = buildings:FindFirstChild(entry[1])
		local slot = library:FindFirstChild(entry[2])
		local top = slot and slot:GetChildren()[1]
		local source = top and top:FindFirstChild(entry[3])
		assert(building and building:IsA("Model") and source, "Missing source or building for " .. entry[4])
		local point = assert(if entry[5] then surface(building,entry[5]) else position(building), "No clear support found for " .. entry[4])
		local copy = source:Clone()
		copy.Name = entry[4]
		for _, v in ipairs(copy:GetDescendants()) do
			if v:IsA("LuaSourceContainer") or v:IsA("Tool") or v:IsA("GuiBase") or v:IsA("Decal") or v:IsA("Texture")
				or v:IsA("Sound") or v:IsA("ClickDetector") or v:IsA("ProximityPrompt") or v:IsA("ParticleEmitter") then v:Destroy()
			elseif v:IsA("BasePart") then v.Anchored=true; v.CanCollide=false; v.CanTouch=false; v.CanQuery=false end
		end
		local model: Model
		if copy:IsA("Model") then model=copy else
			assert(copy:IsA("BasePart"), "Unsupported asset type")
			copy.Anchored=true; copy.CanCollide=false; copy.CanTouch=false; copy.CanQuery=false
			model=Instance.new("Model"); copy.Parent=model; model.Name=entry[4]
		end
		local bounds,size=model:GetBoundingBox()
		if entry[4] == "LabVials" then
			model:ScaleTo(0.65)
			bounds,size=model:GetBoundingBox()
		end
		local pivot=model:GetPivot()
		-- Keep the existing local pivot while placing the visual's lowest point on the floor.
		model:PivotTo(CFrame.new(point+Vector3.new(0,size.Y/2,0))*(bounds:Inverse()*pivot))
		model:SetAttribute("SourceSlot",entry[2])
		model:SetAttribute("VisualOnly",true)
		model.Parent=output
	end
	output.Parent=campus
	return output
end

return table.freeze(Placement)
