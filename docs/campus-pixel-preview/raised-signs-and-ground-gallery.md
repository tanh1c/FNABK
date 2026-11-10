# Raised building signs and B1 ground gallery

AC-01 and AC-09: AI-assisted Studio edit. The B1 ground-floor exterior gallery and its rails were removed, and 14 former outside classroom doors were sealed. Upper-floor exterior galleries remain; the centered main entrance stays open. A prior B1 copy is retained in `ServerStorage.B1_BeforeGroundGalleryRemoval_v1`.

The 23 models under the selected campus Buildings folder have large raised identifiers made from native Parts. Full descriptive nameboards remain for context; the small B1 label is hidden. Mounts offset the letters from the facade. `Canteen`, `KioskOISP`, and `Facility7` use `CANTEEN`, `OISP`, and `7` respectively.

Studio edit-mode checks: 23 sign models present, zero ground and three exterior gallery slabs on each upper floor, and 14 ground door closures. The B1 and B2 signs were inspected in screenshots. The accompanying `BuildingRaisedSignsCheck.luau` checks counts and the main entrance; it does not verify every building's appearance or movement.

Manual Studio test: walk the road along B1 and through its main entrance, then use both upper outdoor galleries and inner corridors. Expected: no ground exterior gallery obstructs the road and upper routes remain accessible. Inspect every identifier from its main approach in daylight and at night; expected: correct, readable lettering without overlap. Check NPC navigation, two-player traversal and performance on the target device separately. The student team should review the AI-assisted work.
