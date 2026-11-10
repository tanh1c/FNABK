# B1 entrance polish

AC-01, AC-09 (environment readability; not yet tested). An AI-assisted visual pass adds 11 non-colliding native Parts around the existing entrance canopy; human review is pending. The source module positions them relative to the canopy, preserving the existing B1 geometry. It refuses to replace an existing polish group.

Studio checks performed: the script created 11 parts; an edit-mode visual capture showed the added trim. A centerline ray at heights 1.5 and 3 studs hit `Furnishings.F01_Classroom_08.StudentDesk_1` approximately 5.4 studs behind the entrance plane; this does not prove whether normal movement is blocked. No playtest was performed.

Manual test: in Studio, inspect the B1 facade and verify the centered entrance remains visually clear. Enter through it, walk past the desk, traverse both wings and return; expected: the opening and corridors are navigable. Check in solo and two-client play that the entrance and nearby routes remain accessible. Record any obstruction and verify target-device performance separately.
