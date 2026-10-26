--!strict
-- State names aligned with docs/GDD.md and AC-03.
local NPCDefinitions = {
    MimicStates = table.freeze({
        Disguise = "Disguise",
        Suspicious = "Suspicious",
        Chase = "Chase",
        Attack = "Attack",
        Search = "Search",
        Stunned = "Stunned",
        Defeated = "Defeated",
    }),
}
return table.freeze(NPCDefinitions)
