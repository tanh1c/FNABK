--!strict
-- A01 balance values plus explicitly marked prototype defaults. Playtest values are not measured yet.
local GameConfig = {
    roundDurationSeconds = 900,
    maxPlayers = 4,
    dataKeysRequired = 3,
    objectiveHintDelaySeconds = 90,
    playerMaxHealth = 100,
    playerMaxStamina = 100,
    staminaDrainPerSecond = 22,
    staminaRegenPerSecond = 18,
    staminaRegenDelaySeconds = 1,
    walkSpeed = 12,
    coOpDownedWindowSeconds = 30,
    reviveHoldSeconds = 5,
    reviveRangeStuds = 6,
    reviveHealth = 40,
    medkitHealAmount = 40,
    medkitPickupRangeStuds = 6,
    sprintSpeed = 19,
    crouchSpeed = 7,
    batonDamage = 25,
    batonRangeStuds = 7,
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
    -- A01 sets Mimic damage and cooldown but leaves the melee range unspecified.
    mimicAttackRangeStuds = 3.5,
    -- A01 specifies approximate FOV and LOS detection but leaves the distance unspecified.
    mimicDetectionRangeStuds = 60,
    -- Provisional hearing distances (A01 specifies noise but not numeric ranges).
    mimicCrouchNoiseRangeStuds = 4,
    mimicWalkNoiseRangeStuds = 12,
    mimicSprintNoiseRangeStuds = 20,
    mimicNoiseIntervalSeconds = 0.8,
    mimicFieldOfViewDegrees = 90,
    -- Prototype timing to make Suspicious traceable; A01 does not set this duration.
    mimicSuspiciousSeconds = 1,
    mimicLostSightSeconds = 2,
    mimicSearchSeconds = 6,
    trustInitial = 100,
    wrongfulHitTrustPenalty = 10,
    -- A01 requires wrongful hits to raise Alert but does not quantify the increment.
    wrongfulHitAlertIncrease = 1,
    gateHoldSeconds = 5,
    -- A01 requires inaccessible objective props to recover after 10 seconds.
    fuseCrateResetSeconds = 10,
    -- AC-06 movement feel for physical body-pushing and carrying.
    cratePushRangeStuds = 7,
    cratePushWalkSpeed = 5.5,
    crateCarryWalkSpeed = 7,
    -- E interaction range for A01's Library investigation objective.
    libraryInteractionRangeStuds = 6,
    -- E interaction range for the B4 fuse and generator objectives.
    b4InteractionRangeStuds = 6,
    -- E interaction range for opening Gate 1 after all three Data Keys are collected.
    gateInteractionRangeStuds = 6,
}
return table.freeze(GameConfig)
