"""Generate native road triangles from a local Studio manifest export."""
import json
import sys
from pathlib import Path

from shapely import constrained_delaunay_triangles, make_valid
from shapely.geometry import LineString, Polygon
from shapely.ops import unary_union

features = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8-sig"))
boundary = next(Polygon(f["polygonStuds"]) for f in features if f["id"] == "CampusBoundary")
reserved = [make_valid(Polygon(f["polygonStuds"])) for f in features
            if f["category"] in ("area", "building")]
roads = make_valid(boundary).difference(unary_union(reserved))
triangles = constrained_delaunay_triangles(roads)
vertices = []
for triangle in triangles.geoms:
    if triangle.area < 0.02:
        continue
    points = list(triangle.exterior.coords)[:3]
    vertices.append(points)
assert abs(sum(Polygon(t).area for t in vertices) - roads.area) < 1
lines = ["-- Generated from the traced local campus manifest; no Roblox assets.", "return { triangles = {"]
for tri in vertices:
    lines.append(" {" + ",".join("{%.5f,%.5f}" % p for p in tri) + "},")
lines.append("}, markings = {")
safe = roads.buffer(-5)
for z in (425, 600, 725, 800):
    segments = safe.intersection(LineString([(36, z), (1339, z)]))
    for segment in getattr(segments, "geoms", [segments]):
        if segment.geom_type != "LineString" or segment.length < 55:
            continue
        start, end = sorted((segment.coords[0][0], segment.coords[-1][0]))
        x = start + 10
        while x + 6 < end - 4:
            lines.append(" {%.5f,%.5f}," % (x + 3, z))
            x += 18
lines.append("}}")
Path(sys.argv[2]).write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"{len(vertices)} triangles, {roads.area:.1f} square studs")
