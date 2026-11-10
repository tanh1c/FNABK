--!strict
-- Clones the script-free White Building 2 MeshPart inspected from Creator Store asset 7932859944.
-- If the local inspection asset is absent, CampusExpansion builds its source-owned fallback.
local ServerStorage = game:GetService("ServerStorage")

local PACK_NAME = "FNABKInspect_WhiteCampusBuilding_7932859944"
local ASSET_ID = 7932859944
local MarketplaceSchool = {}

local function findTemplate(): Model?
	local pack = ServerStorage:FindFirstChild(PACK_NAME)
	if not pack then
		return nil
	end

	for _, descendant in ipairs(pack:GetDescendants()) do
		if descendant:IsA("BaseScript") then
			warn("[FNABK] Marketplace school contains a script; skipping the imported model")
			return nil
		end
	end

	local template = pack:FindFirstChildWhichIsA("Model")
	if not template and pack:IsA("Model") then
		template = pack
	end
	if not template or not template:FindFirstChildWhichIsA("MeshPart", true) then
		return nil
	end
	return template
end

function MarketplaceSchool.Build(
	parent: Instance,
	name: string,
	position: Vector3,
	yaw: number,
	scale: number
): Model?
	assert(scale > 0 and scale <= 50, "School scale must be greater than zero and no more than fifty")
	local template = findTemplate()
	if not template then
		return nil
	end

	local building = template:Clone()
	building.Name = name
	building:SetAttribute("SourceAssetId", ASSET_ID)
	building:SetAttribute("SourceCreator", "Karcist")
	building:SetAttribute("SourceDescription", "White Building 2")
	building:SetAttribute("SourceScale", scale)
	building:ScaleTo(scale)

	local boxCFrame, boxSize = building:GetBoundingBox()
	local pivotFromBox = boxCFrame:ToObjectSpace(building:GetPivot())
	local targetBox = CFrame.new(position.X, boxSize.Y / 2, position.Z) * CFrame.Angles(0, yaw, 0)
	building:PivotTo(targetBox * pivotFromBox)

	for _, descendant in ipairs(building:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = true
			descendant.CanTouch = false
			descendant.CanQuery = true
			descendant.CollisionGroup = "Default"
		end
	end

	building.Parent = parent
	return building
end

return table.freeze(MarketplaceSchool)
