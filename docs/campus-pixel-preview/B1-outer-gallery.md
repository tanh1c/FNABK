# B1 outer galleries and doors

AC-01 and AC-09: AI-assisted Studio edit. B1 has outer galleries on three sides of each floor as well as the courtyard galleries. Each of 42 classrooms has an inner and outer open doorway, a fixed open door leaf, and a number plaque visible from both faces. Boards and teacher desks were moved away from new outside doorways. The previous B1 is preserved in `ServerStorage.B1_BeforeOuterGallery_v1`.

Edit-mode smoke checks found 42 exterior door centerline rays clear, 84 door leaves, and 84 number plaques. The earlier inner-door check passed. Straight rays along each outer gallery on three floors were clear, including when checking collidable objects outside B1. A screenshot showed part of the facade, but it does not establish visual quality everywhere. Fixed open door leaves are decorative and non-collidable; they do not animate.

Manual Studio test: walk both galleries on all floors and enter every classroom from each side; expected: open routes, visible matching room numbers, no wall or furniture blocking doorways. Check the main entry, railings, stairs, NPC navigation and two-player movement; measure target-device performance separately. The student team should review the AI-assisted design.
