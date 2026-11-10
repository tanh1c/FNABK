--!strict
-- Editor-invoked migration for existing pre-mirror detached preview roots.
-- Future roots generated from the pixel manifest are mirrored already.

local PixelMapMirror = {}

local ROOT_NAMES = {
	"FNABK_Campus_PixelPreview_v1",
	"FNABK_Campus_PixelBuildings_PhaseC_v1",
}

type MirrorPlan = {
	root: Model,
	axisX: number,
	parts: { BasePart },
	attachments: { Attachment },
	faceInstances: { Instance },
	models: { { model: Model, pivot: CFrame } },
}

local function reflectVector(vector: Vector3): Vector3
	return Vector3.new(-vector.X, vector.Y, vector.Z)
end

local function reflectCFrame(frame: CFrame, axisX: number): CFrame
	local position = frame.Position
	local reflectedPosition = Vector3.new(2 * axisX - position.X, position.Y, position.Z)
	local right = frame.RightVector
	local up = frame.UpVector
	local back = -frame.LookVector

	-- F * R * F keeps a valid right-handed CFrame while reflecting a block's
	-- position and orientation across the world-X plane.
	local reflectedRight = -reflectVector(right)
	local reflectedUp = reflectVector(up)
	local reflectedBack = reflectVector(back)
	return CFrame.fromMatrix(reflectedPosition, reflectedRight, reflectedUp, reflectedBack)
end

local function mirroredFace(face: Enum.NormalId): Enum.NormalId
	if face == Enum.NormalId.Left then
		return Enum.NormalId.Right
	elseif face == Enum.NormalId.Right then
		return Enum.NormalId.Left
	end
	return face
end

local function prepare(root: Model, axisX: number): MirrorPlan
	assert(root:GetAttribute("PreviewOnly") == true, "Refusing to mirror a non-preview model")
	assert(root:GetAttribute("GameplayIntegrated") ~= true, "Refusing to mirror a gameplay-integrated model")
	assert(root:GetAttribute("HorizontalMirrorApplied") ~= true, "Horizontal mirror was already applied to " .. root.Name)

	local parts: { BasePart } = {}
	local attachments: { Attachment } = {}
	local faceInstances: { Instance } = {}
	local models: { { model: Model, pivot: CFrame } } = {}
	if root.PrimaryPart == nil then
		table.insert(models, { model = root, pivot = root:GetPivot() })
	end

	for _, item in ipairs(root:GetDescendants()) do
		if item:IsA("BasePart") then
			assert(item.Anchored, "Refusing to mirror unanchored part " .. item:GetFullName())
			assert(not item:IsA("MeshPart") and not item:IsA("UnionOperation"), "Refusing geometry that needs vertex-level mirroring: " .. item:GetFullName())
			table.insert(parts, item)
		elseif item:IsA("SpecialMesh") then
			assert(false, "Refusing SpecialMesh that needs vertex-level mirroring: " .. item:GetFullName())
		elseif item:IsA("Attachment") then
			table.insert(attachments, item)
		elseif item:IsA("SurfaceGui") or item:IsA("Decal") or item:IsA("Texture") or item:IsA("SurfaceLight") then
			table.insert(faceInstances, item)
		elseif item:IsA("Model") then
			if item.PrimaryPart == nil then
				table.insert(models, { model = item, pivot = item:GetPivot() })
			end
		elseif item:IsA("JointInstance") or item:IsA("Constraint") then
			assert(false, "Refusing a moving/jointed preview model: " .. item:GetFullName())
		elseif item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
			assert(false, "Refusing a preview root containing scripts: " .. item:GetFullName())
		end
	end
	assert(#parts > 0, "Preview root has no BaseParts: " .. root.Name)

	return {
		root = root,
		axisX = axisX,
		parts = parts,
		attachments = attachments,
		faceInstances = faceInstances,
		models = models,
	}
end

local function apply(plan: MirrorPlan): number
	for index, part in ipairs(plan.parts) do
		part.CFrame = reflectCFrame(part.CFrame, plan.axisX)
		if index % 500 == 0 then
			task.wait()
		end
	end

	for _, attachment in ipairs(plan.attachments) do
		local position = attachment.Position
		attachment.Position = Vector3.new(-position.X, position.Y, position.Z)
	end

	for _, item in ipairs(plan.faceInstances) do
		if item:IsA("SurfaceGui") or item:IsA("Decal") or item:IsA("Texture") or item:IsA("SurfaceLight") then
			item.Face = mirroredFace(item.Face)
		end
	end

	for _, entry in ipairs(plan.models) do
		entry.model.WorldPivot = reflectCFrame(entry.pivot, plan.axisX)
	end

	plan.root:SetAttribute("HorizontalMirrorApplied", true)
	plan.root:SetAttribute("HorizontalMirrorAxisWorldX", plan.axisX)
	plan.root:SetAttribute("HorizontalMirrorPartCount", #plan.parts)
	return #plan.parts
end

function PixelMapMirror.MirrorDetachedPixelMap(workspaceRoot: Instance, axisX: number): { [string]: number }
	assert(typeof(workspaceRoot) == "Instance", "Workspace root is required")
	assert(typeof(axisX) == "number" and axisX == axisX, "A finite world-X mirror plane is required")

	local plans: { MirrorPlan } = {}
	for _, name in ipairs(ROOT_NAMES) do
		local root = workspaceRoot:FindFirstChild(name)
		assert(root and root:IsA("Model"), "Missing detached mirror root " .. name)
		table.insert(plans, prepare(root, axisX))
	end

	local counts: { [string]: number } = {}
	for _, plan in ipairs(plans) do
		counts[plan.root.Name] = apply(plan)
	end
	return counts
end

return table.freeze(PixelMapMirror)
