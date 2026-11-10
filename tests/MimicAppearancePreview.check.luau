-- Run in Studio server Play mode after syncing the project and opening the place
-- containing FNABK_Marketplace_Roster_Gallery_20261104.
local server = game:GetService("ServerScriptService"):WaitForChild("FNABKServer")
local preview = require(server:WaitForChild("MimicAppearancePreview"))
local source = assert(workspace:WaitForChild("FNABKGraybox"):FindFirstChild("Mimic"))
local copy = source:Clone()
local existing = copy:FindFirstChild("DisguiseVisualPreview")
if existing then existing:Destroy() end
copy.Parent = workspace

assert(preview.Attach(copy), "The gallery sample should attach")
assert(not preview.Attach(copy), "A second visual must not be attached")
local visual = assert(copy:FindFirstChild("DisguiseVisualPreview"))
for _, instance in ipairs(visual:GetDescendants()) do
	assert(not instance:IsA("LuaSourceContainer"), "Visual must not contain scripts")
end
copy:PivotTo(copy:GetPivot() * CFrame.new(8, 0, 0))
assert((visual:GetPivot().Position - copy:GetPivot().Position).Magnitude < 0.01, "Visual must follow the model")
copy:Destroy()
print("Mimic appearance preview checks passed")
