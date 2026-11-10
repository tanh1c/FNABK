-- Studio client command bar: stand within six studs of a base point with a clear view.
local point = workspace.FNABKBaseClaimPoints:FindFirstChild("B4")
assert(point and point.ProximityPrompt, "B4 claim prompt missing")
point.ProximityPrompt:InputHoldBegin()
task.wait(0.25)
point.ProximityPrompt:InputHoldEnd()
task.wait(0.5)
assert(game.ReplicatedStorage.FNABKRoundState.ActiveBase.Value == "B4", "Base claim failed")
print("B4 base claim passed")
