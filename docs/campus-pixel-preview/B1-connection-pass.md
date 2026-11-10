# B1 connection pass

AC-01 and AC-09: AI-assisted edit of the Studio recovery place; human visual and gameplay review remains pending. A copy of B1 before this pass is in `ServerStorage.B1_BeforeConnectionPass_v1`. The original .rbxl saved by the user is a separate backup.

The pass seals three former ground-floor openings, cuts passages through intersecting walls and rails at the two wing joints on three floors, bridges two roof seams, and removes repeated rooftop pavilion details. The original B1 was assembled from three templates; this targeted repair does not recreate the entire interior or prove there are no other exterior openings. Source: `src/server/CampusPixelPreview/B1ConnectionPass.luau`. Run its `check` phase for a bounded raycast self-check.

Studio edit-mode check: six joint centerline rays were clear and rays hit each of the three filled openings. Additional rays across three points per joint and floor were clear. One longer ray on the west joint hit a desk farther inside the crossbar. The viewport capture was black, so appearance is not verified. No player traversal, NPC pathfinding, or performance test was run.

Manual Studio test: inspect B1 from above and at each exterior side; expect a coherent U and one centered main entrance. Enter the main entrance and walk through both joints on all three floors; expect uninterrupted floors and a clear route around furnishings, including the desk near the west joint. Test the former end openings for collision and check stairs and NPC navigation. Repeat with two clients and verify the map's mission routes. Record failures and target-device FPS separately.
