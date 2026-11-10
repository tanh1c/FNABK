--!strict
-- SURV-06: visual disguise from the existing local gallery; no asset import.
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local MimicAppearancePreview = {}

function MimicAppearancePreview.Attach(mimic: Model, character: Model?): boolean
	if not mimic.PrimaryPart or mimic:FindFirstChild("DisguiseVisualPreview") then
		return false
	end
	local gallery = Workspace:FindFirstChild("FNABK_Marketplace_Roster_Gallery_20261104")
		or ServerStorage:FindFirstChild("FNABK_Marketplace_Roster_Gallery_20261104")
	local source = if character then character else gallery and gallery:FindFirstChild("Student 1 / R6")
	if not source or not source:IsA("Model") then return false end
	local oldArchivable = source.Archivable
	source.Archivable = true
	local ok, visual = pcall(function() return source:Clone() end)
	source.Archivable = oldArchivable
	if not ok or not visual then return false end
	visual.Name = "DisguiseVisualPreview"
	for _, instance in ipairs(visual:GetDescendants()) do
		if instance:IsA("LuaSourceContainer") or instance:IsA("GuiBase") or instance:IsA("Tool") or instance:IsA("ForceField")
			or instance:IsA("Sound") or instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")
			or instance:IsA("BindableEvent") or instance:IsA("BindableFunction") or instance.Name == "Stand" then
			instance:Destroy()
		elseif instance:IsA("Humanoid") then
			instance.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			instance.BreakJointsOnDeath = false
			instance.EvaluateStateMachine = false
		elseif instance:IsA("BasePart") then
			instance.Anchored = true
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = true
		end
	end
	-- ponytail: color fallback remains legible if classic clothing cannot load; replace with approved outfit after visual review.
	if not character then
		local torso = visual:FindFirstChild("Torso")
		if torso and torso:IsA("BasePart") then torso.Color = Color3.fromRGB(58, 78, 98) end
		for _, name in ipairs({"Left Leg", "Right Leg"}) do
			local leg = visual:FindFirstChild(name)
			if leg and leg:IsA("BasePart") then leg.Color = Color3.fromRGB(38, 42, 54) end
		end
	end
	visual:PivotTo(mimic:GetPivot())
	local body: { [BasePart]: number } = {}
	for _, instance in ipairs(mimic:GetChildren()) do
		if instance:IsA("BasePart") and instance ~= mimic.PrimaryPart then
			body[instance] = instance.Transparency
			instance.Transparency = 1
		end
	end
	visual.Parent = mimic
	for _, instance in ipairs(visual:GetDescendants()) do if instance:IsA("BasePart") then instance.CanCollide = false end end
	local disguised: { [Instance]: { transparency: number, query: boolean? } } = {}
	for _, instance in ipairs(visual:GetDescendants()) do
		if instance:IsA("BasePart") then disguised[instance] = { transparency = instance.Transparency, query = instance.CanQuery }
		elseif instance:IsA("Decal") or instance:IsA("Texture") then disguised[instance] = { transparency = instance.Transparency } end
	end
	local function refreshReveal()
		local state = mimic:GetAttribute("MimicState")
		local revealed = state == "Chase" or state == "Attack" or state == "Stunned" or state == "Defeated"
		for part, transparency in pairs(body) do if part.Parent then part.Transparency = if revealed then transparency else 1 end end
		for item, saved in pairs(disguised) do
			if item.Parent and item:IsA("BasePart") then
				item.Transparency, item.CanQuery = if revealed then 1 else saved.transparency, not revealed and saved.query == true
			elseif item.Parent and (item:IsA("Decal") or item:IsA("Texture")) then item.Transparency = if revealed then 1 else saved.transparency end
		end
	end
	mimic:GetAttributeChangedSignal("MimicState"):Connect(refreshReveal)
	refreshReveal()
	local head = visual:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		task.spawn(function()
			while visual.Parent and head.Parent do
				task.wait(.5)
				local state = mimic:GetAttribute("MimicState")
				if state == "Disguise" or state == "Suspicious" then
					-- ponytail: short rigid head twitch; replace with a reviewed rig animation.
					local twitch = CFrame.Angles(0, 0, math.rad(12))
					head.CFrame *= twitch
					task.wait(.18)
					if head.Parent then head.CFrame *= twitch:Inverse() end
				end
				task.wait(2.5)
			end
		end)
	end
	return true
end

return MimicAppearancePreview
