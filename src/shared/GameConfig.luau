--!strict
-- A01 design baseline constants. Proposed values only; no gameplay implementation.
local GameConfig = {
    roundDurationSeconds = 900,
    maxPlayers = 2,
    dataKeysRequired = 3,
    playerMaxHealth = 100,
    playerMaxStamina = 100,
    walkSpeed = 12,
    sprintSpeed = 19,
    crouchSpeed = 7,
    batonDamage = 25,
    batonRangeStuds = 4.5,
    batonCooldownSeconds = 0.85,
    uvStunSeconds = 2.2,
    uvRangeStuds = 13,
    uvCooldownSeconds = 14,
    scannerRangeStuds = 12,
    scannerCooldownSeconds = 8,
    scannerDurationSeconds = 1,
    mimicHealth = 75,
    mimicSpeed = 14,
    mimicDamage = 20,
    mimicAttackCooldownSeconds = 1.6,
    trustInitial = 100,
    wrongfulHitTrustPenalty = 20,
    gateHoldSeconds = 5,
}
return table.freeze(GameConfig)
