-- Studio Play client: exercise tier boundaries locally without changing server Trust.
local trust = game.ReplicatedStorage:WaitForChild("FNABKRoundState"):WaitForChild("Trust")
local label = game.Players.LocalPlayer.PlayerGui:WaitForChild("FNABKRoundHUD"):WaitForChild("Trust")
local original = trust.Value
for _, sample in ipairs({ {100, "NORMAL"}, {70, "NORMAL"}, {69, "WARY"}, {30, "WARY"}, {29, "NO TRADE"}, {0, "NO TRADE"} }) do
	trust.Value = sample[1]
	task.wait()
	assert(label.Text == string.format("TRUST %d | %s", sample[1], sample[2]))
end
trust.Value = original
return "Trust HUD boundaries passed"
