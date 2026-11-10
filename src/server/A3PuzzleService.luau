--!strict
-- AC-06 prototype: server owns FuseCrate bounds, plate activation, power, and Key 1.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

type A3Config = {
	fuseCrateResetSeconds: number,
}

local A3PuzzleService = {}

local function getOrCreateFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("Folder"), name .. " must be a Folder")
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function getOrCreateBoolValue(parent: Instance, name: string, initialValue: boolean): BoolValue
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("BoolValue"), name .. " must be a BoolValue")	
		return existing
	end

	local value = Instance.new("BoolValue")
	value.Name = name
	value.Value = initialValue
	value.Parent = parent
	return value
end

local function isWithinBounds(crate: BasePart, minimum: Vector3, maximum: Vector3): boolean
	local position = crate.Position
	return position.X >= minimum.X
		and position.X <= maximum.X
		and position.Y >= minimum.Y
		and position.Y <= maximum.Y
		and position.Z >= minimum.Z
		and position.Z <= maximum.Z
end

local function isCorrectlyPlaced(crate: BasePart, plate: BasePart): boolean
	local localPosition = plate.CFrame:PointToObjectSpace(crate.Position)
	local halfPlate = plate.Size / 2
	local halfCrate = crate.Size / 2
	local fitsOnPlate = math.abs(localPosition.X) + halfCrate.X <= halfPlate.X + 0.1
		and math.abs(localPosition.Z) + halfCrate.Z <= halfPlate.Z + 0.1
	local crateBottom = localPosition.Y - halfCrate.Y
	local plateTop = halfPlate.Y
	local restingOnPlate = crateBottom >= plateTop - 0.2 and crateBottom <= plateTop + 0.75
	return fitsOnPlate and restingOnPlate
end

function A3PuzzleService.Start(map: Folder, config: A3Config)
	if map:GetAttribute("A3PuzzleStarted") == true then
		return
	end
	map:SetAttribute("A3PuzzleStarted", true)

	local a3 = map:FindFirstChild("A3")
	assert(a3 and a3:IsA("Folder"), "Graybox is missing A3")
	local crateInstance = a3:FindFirstChild("FuseCrate")
	local plateInstance = a3:FindFirstChild("PressurePlate")
	assert(crateInstance and crateInstance:IsA("BasePart"), "A3 is missing its FuseCrate")
	assert(plateInstance and plateInstance:IsA("BasePart"), "A3 is missing its PressurePlate")
	local crate = crateInstance :: BasePart
	local plate = plateInstance :: BasePart

	local boundsMinimum = map:GetAttribute("CrateResetBoundsMin")
	local boundsMaximum = map:GetAttribute("CrateResetBoundsMax")
	assert(typeof(boundsMinimum) == "Vector3", "Graybox is missing CrateResetBoundsMin")
	assert(typeof(boundsMaximum) == "Vector3", "Graybox is missing CrateResetBoundsMax")
	local minimum = boundsMinimum :: Vector3
	local maximum = boundsMaximum :: Vector3

	local resetPositionAttribute = crate:GetAttribute("FNABKResetPosition")
	local resetPosition = if typeof(resetPositionAttribute) == "Vector3"
		then resetPositionAttribute :: Vector3
		else crate.Position
	local resetCFrame = CFrame.new(resetPosition)
	-- Let the physics engine assign the crate to a nearby player while it is being handled.
	crate.Anchored = false
	crate:SetNetworkOwnershipAuto()

	local roundState = ReplicatedStorage:WaitForChild("FNABKRoundState")
	assert(roundState:IsA("Folder"), "FNABKRoundState must be a Folder")
	local dataKeys = getOrCreateFolder(roundState, "DataKeys")
	local keyOne = getOrCreateBoolValue(dataKeys, "Key1", false)
	getOrCreateBoolValue(dataKeys, "Key2", false)
	getOrCreateBoolValue(dataKeys, "Key3", false)
	local powerRestored = getOrCreateBoolValue(roundState, "A3PowerRestored", false)

	local alreadyPowered = map:GetAttribute("A3PowerRestored") == true
	map:SetAttribute("A3PowerRestored", alreadyPowered)
	a3:SetAttribute("PowerRestored", alreadyPowered)
	powerRestored.Value = alreadyPowered
	keyOne.Value = alreadyPowered
	if alreadyPowered then
		plate.Color = Color3.fromRGB(29, 144, 127)
		plate.Material = Enum.Material.Neon
	end

	local function activateA3()
		if powerRestored.Value then
			return
		end

		powerRestored.Value = true
		keyOne.Value = true
		map:SetAttribute("A3PowerRestored", true)
		a3:SetAttribute("PowerRestored", true)
		plate.Color = Color3.fromRGB(29, 144, 127)
		plate.Material = Enum.Material.Neon
		print("[FNABK][A3] FuseCrate settled on PressurePlate; power restored; Data Key 1 collected")
	end

	local inaccessibleSince: number? = nil
	local placementStableSince: number? = nil
	task.spawn(function()
		while map.Parent do
			task.wait(0.25)
			if not map.Parent then
				break
			end

			local accessible = crate.Parent == a3 and isWithinBounds(crate, minimum, maximum)
			local now = os.clock()
			local settledOnPlate = crate.Parent == a3
				and crate:GetAttribute("IsCarried") ~= true
				and isCorrectlyPlaced(crate, plate)
				and crate.AssemblyLinearVelocity.Magnitude <= 1.5
				and crate.AssemblyAngularVelocity.Magnitude <= 0.5
			if not powerRestored.Value and settledOnPlate then
				if not placementStableSince then
					placementStableSince = now
				elseif now - placementStableSince >= 0.5 then
					activateA3()
					placementStableSince = nil
				end
			else
				placementStableSince = nil
			end

			if accessible then
				inaccessibleSince = nil
			elseif not inaccessibleSince then
				inaccessibleSince = now
				print(string.format(
					"[FNABK][A3] FuseCrate inaccessible; resetting in %.0f seconds",
					config.fuseCrateResetSeconds
				))
			elseif now - inaccessibleSince >= config.fuseCrateResetSeconds then
				crate.Parent = a3
				crate.Anchored = false
				crate.CFrame = resetCFrame
				crate.AssemblyLinearVelocity = Vector3.zero
				crate.AssemblyAngularVelocity = Vector3.zero
				crate:SetNetworkOwnershipAuto()
				inaccessibleSince = nil
				print("[FNABK][A3] FuseCrate reset to its A3 start position")
			end
		end
	end)

	print(string.format(
		"[FNABK][A3] AC-06 prototype ready; server resets inaccessible FuseCrate after %.0f seconds",
		config.fuseCrateResetSeconds
	))
end

return table.freeze(A3PuzzleService)
