--!strict
-- AC-09: this campus has no climbing mechanic; keep avatars from scaling window panes.
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function applyToCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	end
end

player.CharacterAdded:Connect(applyToCharacter)
if player.Character then
	task.defer(applyToCharacter, player.Character)
end
