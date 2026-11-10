-- Studio Play server; isolated synthetic events, not a full timed wave. SURV-02/11.
local state = game.ReplicatedStorage.FNABKRoundState
local map = Instance.new("Folder")
map.Parent = workspace
local events, gunshot = Instance.new("BindableEvent"), Instance.new("BindableEvent")
require(game.ServerScriptService.FNABKServer.WaveService).Start(map, events, function() return nil end, gunshot)
local beacon = map:WaitForChild("WaveWarningBeacon")
local light = beacon:WaitForChild("WarningLight")
state.ActiveBase.Value = "A1"
local power = state.BuildingPower.A1
power.Value = false
events:Fire("WaveWarning:1")
task.wait(.25)
assert(not light.Enabled, "unpowered base displayed warning light")
power.Value = true
task.wait(.2)
local sawOn, sawOff = false, false
for _ = 1, 15 do
	sawOn = sawOn or light.Enabled
	sawOff = sawOff or not light.Enabled
	task.wait(.1)
end
assert(sawOn and sawOff, "powered beacon did not flicker")
events:Fire("WaveCanceled:1")
task.wait(.2)
assert(not light.Enabled)
events:Fire("WaveWarning:2")
task.wait(.2)
power.Value = false
task.wait(.2)
assert(not light.Enabled, "warning remained on after power loss")
events:Destroy(); gunshot:Destroy(); map:Destroy()
return "Wave beacon checks passed"
