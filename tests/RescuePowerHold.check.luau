-- Studio Play client: stand at Power, run this check, then press G for 1 second and release,
-- followed by holding G until completion (SURV-01/11).
local flag = game.ReplicatedStorage.FNABKRoundState.RescueObjectives.Power
assert(not flag.Value, "start with an incomplete Power objective")
task.wait(2)
assert(not flag.Value, "short hold completed Power")
task.wait(5)
assert(flag.Value, "full hold did not complete Power")
return "Rescue power hold check passed"
