# B1 open galleries and classrooms

AC-01 and AC-09: AI-assisted Studio edit. B1 has three open galleries facing the U-shaped courtyard, 42 classroom bays, signs, chalkboards, four student desks per room, teacher desks, ceiling fixtures and railings. The west wing leaves a circulation zone for the existing stairs. The classroom doors are open passages; ceiling fixtures are visual only, not light sources. The former B1 shell is retained in `ServerStorage.B1_BeforeClassroomPass_v1`.

Edit-mode checks: straight rays along all three gallery runs on each floor and through the main entrance were clear; a sample of room doorways was clear. Part counts confirmed 42 signs, 168 student desks, and 42 boards. Run `B1ClassroomCheck.luau` for the full entrance and teacher-desk smoke check. These checks do not prove usable traversal, visual quality from every angle, NPC navigation, or device performance.

Manual Studio test: enter B1, walk the complete gallery on each floor and traverse both stairs; expected: continuous paths and no falls through stair openings. Enter every classroom and approach its desks and board; expected: a clear doorway and usable room. Inspect railings and classroom signs from the courtyard and in the dark. Repeat with an NPC and two clients; record navigation failures and target-device FPS separately. The student team should review and refine the AI-assisted design.
