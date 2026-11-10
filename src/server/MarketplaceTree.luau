--!strict
-- AC-01/02/09: low-poly campus trees reconstructed from inspected Creator Store
-- asset 8556375773 (Cliosow). Leaves are decorative; a narrow trunk proxy collides.

type LeafPiece = {
	size: number,
	offset: Vector3,
	rotation: Vector3,
}

type TreeVariant = {
	height: number,
	trunkMeshId: string,
	trunkPartSize: Vector3,
	trunkMeshSize: Vector3,
	trunkOffset: Vector3,
	trunkRotation: Vector3,
	leaves: { LeafPiece },
}

local leafMeshId = "rbxassetid://7160076539"
local leafMeshSize = Vector3.new(2.033986, 1.945673, 1.992942)

local variants: { [string]: TreeVariant } = {
	Tree2 = {
		height = 35.184753,
		trunkMeshId = "rbxassetid://7160797608",
		trunkPartSize = Vector3.new(2.521633, 28.892761, 12.214144),
		trunkMeshSize = Vector3.new(2.521633, 28.892761, 12.214144),
		trunkOffset = Vector3.new(-2.106728, -4.590668, -2.077148),
		trunkRotation = Vector3.new(-0.925526, 3.004990, 0.459676),
		leaves = {
			{ size = 9, offset = Vector3.new(-2.049751, 6.936066, 2.237762), rotation = Vector3.new(0.118019, 2.224651, 1.012034) },
			{ size = 8, offset = Vector3.new(-2.226479, -2.788025, 8.475586), rotation = Vector3.new(-0.385759, 2.251800, 0.949935) },
			{ size = 8, offset = Vector3.new(3.513069, -3.190552, 6.207214), rotation = Vector3.new(-1.502707, -1.752660, -1.156379) },
			{ size = 8, offset = Vector3.new(-3.777496, 4.682983, 6.531738), rotation = Vector3.new(-1.001006, -2.673882, -0.041761) },
			{ size = 11, offset = Vector3.new(1.371155, 3.215454, 5.271637), rotation = Vector3.new(-0.991498, -2.514136, -0.175945) },
			{ size = 11, offset = Vector3.new(-0.462486, 8.432587, 6.980225), rotation = Vector3.new(0.652647, -2.536077, 2.699052) },
			{ size = 12, offset = Vector3.new(0.709579, 0.565582, 10.019318), rotation = Vector3.new(0, 0, 0) },
			{ size = 8.5, offset = Vector3.new(0.126228, -6.383057, 10.272278), rotation = Vector3.new(-0.385759, 2.251800, 0.949935) },
		},
	},
	Tree4 = {
		height = 37,
		trunkMeshId = "rbxassetid://7160799696",
		trunkPartSize = Vector3.new(11.516909, 28.351666, 11.582520),
		trunkMeshSize = Vector3.new(11.516909, 28.351666, 11.582520),
		trunkOffset = Vector3.new(0.711151, -4.324171, -0.929535),
		trunkRotation = Vector3.new(0, -1.832596, 0),
		leaves = {
			{ size = 12, offset = Vector3.new(-1.202637, 12.500004, 2.189880), rotation = Vector3.new(0, -1.832596, 0) },
			{ size = 9.5, offset = Vector3.new(-1.560883, 9.000002, 5.458542), rotation = Vector3.new(0, -1.832596, 0) },
			{ size = 9.5, offset = Vector3.new(2.441559, 9.500002, -1.751221), rotation = Vector3.new(0, -3.054326, 0) },
			{ size = 11.5, offset = Vector3.new(-5.907501, 8.500002, 4.293854), rotation = Vector3.new(0, 0, 0) },
			{ size = 7.5, offset = Vector3.new(6.762817, -1.500002, -6.287354), rotation = Vector3.new(1.483533, -1.832597, 0) },
			{ size = 9.5, offset = Vector3.new(3.088593, -0.5, -4.166046), rotation = Vector3.new(0, -1.832596, -1.221730) },
		},
	},
}

local MarketplaceTree = {}

local function createMeshPart(
	parent: Instance,
	name: string,
	meshId: string,
	partSize: Vector3,
	meshSize: Vector3,
	offset: Vector3,
	rotation: Vector3,
	pivot: CFrame,
	scale: number,
	color: Color3
)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Size = Vector3.one
	part.CFrame = pivot * CFrame.new(offset * scale) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
	part.Color = color
	part.Material = Enum.Material.Plastic
	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "CreatorStoreMesh"
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = meshId
	mesh.Scale = Vector3.new(partSize.X / meshSize.X, partSize.Y / meshSize.Y, partSize.Z / meshSize.Z) * scale
	mesh.Parent = part
	part.Parent = parent
end

function MarketplaceTree.Build(
	parent: Instance,
	name: string,
	position: Vector3,
	yaw: number,
	scale: number,
	variantName: string
)
	assert(scale > 0 and scale <= 1, "Tree scale must be greater than zero and no more than one")
	local variant = variants[variantName]
	assert(variant, "Unknown Creator Store tree variant: " .. variantName)

	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("SourceAssetId", 8556375773)
	model:SetAttribute("SourceCreator", "Cliosow")
	model:SetAttribute("SourceVariant", variantName)
	model:SetAttribute("SourceScale", scale)
	model:SetAttribute("CollisionIntent", "0.7-stud collidable trunk proxy; decorative foliage")
	local totalHeight = variant.height * scale
	-- The avatar's rigid collision body sits above the feet, so a visible tree
	-- shorter than that body needs a modestly taller hidden proxy to block it.
	local colliderHeight = math.max(totalHeight, 3.2)
	local pivot = CFrame.new(position + Vector3.new(0, totalHeight / 2, 0)) * CFrame.Angles(0, yaw, 0)

	createMeshPart(model, "OakTrunk", variant.trunkMeshId, variant.trunkPartSize, variant.trunkMeshSize, variant.trunkOffset, variant.trunkRotation, pivot, scale, Color3.fromRGB(124, 91, 67))
	local leavesColor = Color3.fromRGB(76, 126, 70)
	for index, leaf in ipairs(variant.leaves) do
		local leafSize = Vector3.new(leaf.size, leaf.size, leaf.size)
		createMeshPart(model, "OakLeafCluster" .. index, leafMeshId, leafSize, leafMeshSize, leaf.offset, leaf.rotation, pivot, scale, leavesColor)
	end

	local trunkCollider = Instance.new("Part")
	trunkCollider.Name = "OakTrunkCollider"
	trunkCollider.Anchored = true
	trunkCollider.CanCollide = true
	trunkCollider.CanTouch = false
	trunkCollider.CanQuery = false
	trunkCollider.CastShadow = false
	trunkCollider.Massless = true
	trunkCollider.Transparency = 1
	trunkCollider.Shape = Enum.PartType.Cylinder
	trunkCollider.Size = Vector3.new(colliderHeight, 0.7, 0.7)
	trunkCollider.CFrame = CFrame.new(position + Vector3.new(0, colliderHeight / 2, 0)) * CFrame.Angles(0, yaw, math.rad(90))
	trunkCollider.CollisionGroup = "Default"
	trunkCollider.Parent = model

	model.Parent = parent
	return model
end

return table.freeze(MarketplaceTree)
