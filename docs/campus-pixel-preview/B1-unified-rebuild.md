# B1 unified rebuild

AC-01 and AC-09: AI-assisted native-Part rebuild on the selected Studio recovery place. B1 now has one continuous U-shaped shell and roof, three open floors, two flights of stairs in the west wing, and one centered exterior entrance. The former B1 model, including its rooms and furnishings, is preserved in `ServerStorage.B1_BeforeUnifiedRebuild_v1`; the replacement interior is an open shell. Windows are decorative panels on solid walls. The student team should review and refine the design.

Studio edit-mode checks: the main entrance and six wing-joint centerline rays were clear; three sampled former exterior openings hit walls; 32 stair parts and the backup model were present. A top-down Studio capture showed the continuous U-shaped roof. No Play session, real player traversal, NPC navigation, or performance profiling was performed. The runnable `B1UnifiedCheck.luau` repeats a subset of these checks.

Manual test: in Play, enter through the centered door, walk both wings and their connections on each floor, use both stairs in both directions, and verify the outer walls have no unintended entrances. Expected: continuous accessible floors, clear stairs and one exterior entrance. Inspect the exterior from above and ground level; verify camera visibility, NPC navigation, and target-device performance separately.
