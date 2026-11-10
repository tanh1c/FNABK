# Campus coordinate handoff

The SVG grid and coordinate table are generated from the current campus manifest. Coordinates are estimates for layout alignment, not surveyed measurements.

- Local origin (X=0 m, Z=0 m): estimated southwest campus parcel corner.
- +X: east. +Z: north. North is up in the current SVG.
- Estimated map envelope: 602.6 m east-west by 250.0 m north-south.
- Minor grid: 25 m. Labeled grid lines: 50 m.
- Current SVG projection: SVG_X = 133.7 + 1.82 × X_m; SVG_Y = 651.76 − 1.82 × Z_m.
- Inverse projection: X_m = (SVG_X − 133.7) / 1.82; Z_m = (651.76 − SVG_Y) / 1.82.
- Existing scale bar: 182 px = 100 m.

HCMUT_Campus_Coordinates_v6.csv lists each building, path, open area and estimated gameplay marker, including its meter coordinates and current SVG pixel center.

When supplying a replacement SVG, keep north up, retain the building IDs, and include a known scale or at least one known distance. If the SVG uses a different crop or orientation, include the full campus outline so it can be aligned before changing the building coordinates.