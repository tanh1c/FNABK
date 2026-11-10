-- Run in the Studio client command bar in Play mode after the Baton appears.
local player = game.Players.LocalPlayer
local tool = player.Backpack:FindFirstChild("Baton") or player.Character:FindFirstChild("Baton")
assert(tool and tool:IsA("Tool") and tool:GetAttribute("FNABKServerGranted"), "Server baton missing")
assert(tool:FindFirstChild("Handle") and #tool:GetChildren() > 4, "Expected the detailed user baton")
for _, item in ipairs(tool:GetDescendants()) do
	assert(not item:IsA("LuaSourceContainer") and not item:IsA("Sound"), "Imported behavior is present")
end
print("User baton visual and script isolation passed")
