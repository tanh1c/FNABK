--!strict
-- Keep avatar clothing and accessories while selecting the classic block body.
local Players = game:GetService("Players")

local function register(player: Player)
	local function apply(character: Model)
		task.wait(1) -- AppearanceLoaded can fire before Studio attaches the character to the DataModel.
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or player.Character ~= character then return end
		local description = humanoid:GetAppliedDescription()
		description.Head, description.Torso = 0, 0
		description.LeftArm, description.RightArm = 0, 0
		description.LeftLeg, description.RightLeg = 0, 0
		description.BodyTypeScale, description.ProportionScale = 0, 0
		description.WidthScale, description.HeightScale, description.DepthScale, description.HeadScale = 1, 1, 1, 1
		local ok, err = pcall(function() humanoid:ApplyDescription(description) end)
		if not ok then warn("[FNABK] Block body could not be applied: " .. tostring(err)) end
	end
	player.CharacterAppearanceLoaded:Connect(apply)
	if player.Character and player:HasAppearanceLoaded() then task.spawn(apply, player.Character) end
end

Players.PlayerAdded:Connect(register)
for _, player in ipairs(Players:GetPlayers()) do register(player) end
