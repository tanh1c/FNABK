-- Studio Play server: cloned live Mimic, synthetic gunshot and B1 stair route. SURV-07.
local building = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
local low, high = building.Stair_1_2, building.Stair_1_15
local bottom = low.Position + Vector3.new(0, low.Size.Y / 2 + 3, 0)
local top = high.Position + Vector3.new(0, high.Size.Y / 2 + 3, 0)
local clone = workspace.FNABKGraybox.Mimic:Clone()
clone:SetAttribute("ControllerStarted", nil)
clone:SetAttribute("MimicState", nil)
clone.Parent = workspace
clone:PivotTo(CFrame.lookAt(top, Vector3.new(bottom.X, top.Y, bottom.Z)))
local shot = Instance.new("BindableEvent")
require(game.ServerScriptService.FNABKServer.MimicController).Start(clone, require(game.ReplicatedStorage.FNABKShared.GameConfig), function() return nil end, shot)
local start = clone.PrimaryPart.Position
shot:Fire(bottom, 60)
task.wait(.2)
local heard = clone:GetAttribute("MimicLastKnownPosition")
task.wait(6)
local final = clone.PrimaryPart.Position
clone:Destroy(); shot:Destroy()
assert(heard == bottom, "shot location not retained")
assert((final - bottom).Magnitude < (start - bottom).Magnitude - 3, "Mimic did not approach the noise")
return "Campus Mimic noise approach passed"
