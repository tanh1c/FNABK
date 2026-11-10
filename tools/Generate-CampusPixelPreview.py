#!/usr/bin/env python3
"""Build and validate the offline, pixel-scaled FNABK campus preview data."""

from __future__ import annotations

import argparse
import copy
import csv
import hashlib
import html
import json
import math
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any, Iterable


REPO_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = REPO_ROOT / "docs" / "campus-pixel-preview"
SOURCE_JSON = OUTPUT_DIR / "CampusPixelGeometry.json"
ADJUSTMENTS_JSON = OUTPUT_DIR / "GeometryAdjustments.json"
SOURCE_CSV = OUTPUT_DIR / "CampusCenters_PIXEL_ONLY.csv"
SOURCE_VECTOR_SVG = OUTPUT_DIR / "CampusTopDown_VECTOR_ONLY_source.svg"
OLD_MANIFEST = REPO_ROOT / "docs" / "campus-phase-a" / "CampusManifest.json"
OLD_MARKERS = REPO_ROOT / "docs" / "campus-phase-a" / "Markers.json"
LUA_DIR = REPO_ROOT / "src" / "server" / "CampusPixelPreview"
MAX_PART_LENGTH_STUDS = 1800.0
EPSILON = 1e-8
HORIZONTAL_MIRROR = True


def preview_pixel_x(pixel_x: float, image_width: int) -> float:
    return image_width - pixel_x if HORIZONTAL_MIRROR else pixel_x


def read_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8-sig") as handle:
        return json.load(handle)


def apply_geometry_adjustments(canonical: dict[str, Any], overlay: dict[str, Any]) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    """Apply only explicit, source-guarded user edits to a detached copy."""
    effective = copy.deepcopy(canonical)
    features = {feature["id"]: feature for feature in effective["features"]}
    markers = {marker["id"]: marker for marker in effective["markers"]}
    applied: list[dict[str, Any]] = []
    seen: set[str] = set()

    for adjustment in overlay.get("adjustments", []):
        adjustment_id = adjustment.get("id", "")
        if adjustment_id in seen:
            raise ValueError(f"duplicate geometry adjustment ID: {adjustment_id}")
        seen.add(adjustment_id)
        operation = adjustment.get("operation")

        if operation == "replacePolygonPixels":
            target = features.get(adjustment_id)
            if target is None:
                raise ValueError(f"geometry adjustment target feature is missing: {adjustment_id}")
            if target.get("polygonPixels") != adjustment.get("expectedSourcePolygonPixels"):
                raise ValueError(f"stale source polygon for {adjustment_id}; review the overlay before rebuilding")
            points = adjustment.get("polygonPixels")
            if not isinstance(points, list) or len(points) < 3:
                raise ValueError(f"replacement polygon for {adjustment_id} must contain at least three vertices")
            target["polygonPixels"] = copy.deepcopy(points)
            target.setdefault("geometryAdjustmentIds", []).append(adjustment_id)
        elif operation == "translateMarkerPixels":
            target = markers.get(adjustment_id)
            if target is None:
                raise ValueError(f"geometry adjustment target marker is missing: {adjustment_id}")
            if target.get("positionPixels") != adjustment.get("expectedSourcePositionPixels"):
                raise ValueError(f"stale source marker for {adjustment_id}; review the overlay before rebuilding")
            source_x, source_y = target["positionPixels"]
            delta_x, delta_y = adjustment["deltaPixels"]
            expected_position = [source_x + delta_x, source_y + delta_y]
            if adjustment.get("positionPixels") != expected_position:
                raise ValueError(f"{adjustment_id} replacement position does not match its delta")
            target["positionPixels"] = expected_position
            target.setdefault("geometryAdjustmentIds", []).append(adjustment_id)
        elif operation == "overrideCategory":
            target = features.get(adjustment_id)
            if target is None:
                raise ValueError(f"geometry adjustment target feature is missing: {adjustment_id}")
            if target.get("category") != adjustment.get("expectedSourceCategory"):
                raise ValueError(f"stale source category for {adjustment_id}; review the overlay before rebuilding")
            target["sourceCategory"] = target["category"]
            target["category"] = adjustment["category"]
            target.setdefault("geometryAdjustmentIds", []).append(adjustment_id)
        else:
            raise ValueError(f"unsupported geometry adjustment operation {operation!r} for {adjustment_id}")

        applied.append(adjustment)

    return effective, applied


def write_json(path: Path, data: Any) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def number(value: float | int) -> str:
    if isinstance(value, int):
        return str(value)
    return format(float(value), ".10g")


def polygon_area(points: list[list[float]]) -> float:
    return 0.5 * sum(
        points[i][0] * points[(i + 1) % len(points)][1]
        - points[(i + 1) % len(points)][0] * points[i][1]
        for i in range(len(points))
    )


def polygon_centroid(points: list[list[float]]) -> tuple[float, float]:
    area_twice = 0.0
    cx = 0.0
    cy = 0.0
    for i, point in enumerate(points):
        nxt = points[(i + 1) % len(points)]
        cross = point[0] * nxt[1] - nxt[0] * point[1]
        area_twice += cross
        cx += (point[0] + nxt[0]) * cross
        cy += (point[1] + nxt[1]) * cross
    if abs(area_twice) <= EPSILON:
        return (sum(p[0] for p in points) / len(points), sum(p[1] for p in points) / len(points))
    return (cx / (3.0 * area_twice), cy / (3.0 * area_twice))


def orient(a: list[float], b: list[float], c: list[float]) -> float:
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def on_segment(a: list[float], b: list[float], p: list[float]) -> bool:
    return (
        min(a[0], b[0]) - EPSILON <= p[0] <= max(a[0], b[0]) + EPSILON
        and min(a[1], b[1]) - EPSILON <= p[1] <= max(a[1], b[1]) + EPSILON
        and abs(orient(a, b, p)) <= EPSILON
    )


def proper_segments_cross(a: list[float], b: list[float], c: list[float], d: list[float]) -> bool:
    o1, o2, o3, o4 = orient(a, b, c), orient(a, b, d), orient(c, d, a), orient(c, d, b)
    return ((o1 > EPSILON and o2 < -EPSILON) or (o1 < -EPSILON and o2 > EPSILON)) and (
        (o3 > EPSILON and o4 < -EPSILON) or (o3 < -EPSILON and o4 > EPSILON)
    )


def point_location(point: list[float], polygon: list[list[float]]) -> int:
    """Return 0 outside, 1 inside, or 2 on the polygon boundary."""
    inside = False
    x, y = point
    for i, start in enumerate(polygon):
        end = polygon[(i + 1) % len(polygon)]
        if on_segment(start, end, point):
            return 2
        if (start[1] > y) != (end[1] > y):
            x_cross = (end[0] - start[0]) * (y - start[1]) / (end[1] - start[1]) + start[0]
            if x < x_cross:
                inside = not inside
    return 1 if inside else 0


def distance_to_polygon(point: list[float], polygon: list[list[float]]) -> float:
    closest = math.inf
    for index, start in enumerate(polygon):
        end = polygon[(index + 1) % len(polygon)]
        dx, dy = end[0] - start[0], end[1] - start[1]
        length_squared = dx * dx + dy * dy
        alpha = 0.0 if length_squared <= EPSILON else max(
            0.0, min(1.0, ((point[0] - start[0]) * dx + (point[1] - start[1]) * dy) / length_squared)
        )
        projected = [start[0] + alpha * dx, start[1] + alpha * dy]
        closest = min(closest, math.hypot(point[0] - projected[0], point[1] - projected[1]))
    return closest


def polygon_boundary_distance(first: list[list[float]], second: list[list[float]]) -> float:
    """Minimum boundary distance for disjoint polygons in source pixel space."""
    if polygons_overlap_area(first, second):
        return 0.0
    for i, a in enumerate(first):
        b = first[(i + 1) % len(first)]
        for j, c in enumerate(second):
            d = second[(j + 1) % len(second)]
            if proper_segments_cross(a, b, c, d) or on_segment(a, b, c) or on_segment(a, b, d) or on_segment(c, d, a) or on_segment(c, d, b):
                return 0.0
    return min(
        min(distance_to_polygon(point, second) for point in first),
        min(distance_to_polygon(point, first) for point in second),
    )


def unoriented_edge_angle_difference_degrees(first: list[float], second: list[float]) -> float:
    first_angle = math.atan2(first[1], first[0])
    second_angle = math.atan2(second[1], second[0])
    difference = abs((first_angle - second_angle + math.pi / 2) % math.pi - math.pi / 2)
    return math.degrees(difference)


def polygon_self_intersections(points: list[list[float]]) -> list[tuple[int, int]]:
    result: list[tuple[int, int]] = []
    count = len(points)
    for i in range(count):
        a, b = points[i], points[(i + 1) % count]
        for j in range(i + 1, count):
            if j == i or j == (i + 1) % count or (j + 1) % count == i:
                continue
            c, d = points[j], points[(j + 1) % count]
            if proper_segments_cross(a, b, c, d):
                result.append((i, j))
            elif on_segment(a, b, c) or on_segment(a, b, d) or on_segment(c, d, a) or on_segment(c, d, b):
                # A non-adjacent touch or overlap makes the polygon non-simple too.
                result.append((i, j))
    return result


def polygons_overlap_area(first: list[list[float]], second: list[list[float]]) -> bool:
    for i, a in enumerate(first):
        b = first[(i + 1) % len(first)]
        for j, c in enumerate(second):
            d = second[(j + 1) % len(second)]
            if proper_segments_cross(a, b, c, d):
                return True
    if any(point_location(point, second) == 1 for point in first):
        return True
    if any(point_location(point, first) == 1 for point in second):
        return True
    if point_location(list(polygon_centroid(first)), second) == 1:
        return True
    if point_location(list(polygon_centroid(second)), first) == 1:
        return True
    return False


def edge_part_count(points: list[list[float]], scale: float) -> int:
    total = 0
    for i, a in enumerate(points):
        b = points[(i + 1) % len(points)]
        length = math.hypot((b[0] - a[0]) * scale, (b[1] - a[1]) * scale)
        total += max(1, math.ceil(length / MAX_PART_LENGTH_STUDS))
    return total


def svg_points(points: list[list[float]]) -> str:
    return " ".join(f"{number(point[0])},{number(point[1])}" for point in points)


def parse_svg_points(value: str) -> list[list[float]]:
    pairs = re.findall(r"(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?),(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)", value)
    if not pairs:
        return []
    return [[float(x), float(y)] for x, y in pairs]


def validate_input_svg(features: list[dict[str, Any]]) -> tuple[bool, str]:
    if not SOURCE_VECTOR_SVG.exists():
        return False, "local vector-only source SVG is missing"
    root = ET.parse(SOURCE_VECTOR_SVG).getroot()
    source_polygons = {
        element.attrib.get("id"): parse_svg_points(element.attrib.get("points", ""))
        for element in root.iter()
        if element.tag.rsplit("}", 1)[-1] == "polygon" and element.attrib.get("id")
    }
    mismatches: list[str] = []
    expected_ids = {feature["id"] for feature in features}
    if set(source_polygons) != expected_ids:
        missing = sorted(expected_ids - set(source_polygons))
        extra = sorted(set(source_polygons) - expected_ids)
        mismatches.append(f"ID set differs (missing={missing}, extra={extra})")
    by_id = {feature["id"]: feature for feature in features}
    for feature_id in sorted(expected_ids & set(source_polygons)):
        expected = by_id[feature_id]["polygonPixels"]
        actual = source_polygons[feature_id]
        if len(actual) != len(expected) or any(
            abs(a[0] - e[0]) > EPSILON or abs(a[1] - e[1]) > EPSILON
            for a, e in zip(actual, expected)
        ):
            mismatches.append(f"{feature_id}: pixel vertices differ")
    return not mismatches, "; ".join(mismatches) if mismatches else f"all {len(expected_ids)} source footprints match canonical JSON vertices"


def make_manifest(
    source: dict[str, Any],
    canonical: dict[str, Any],
    old_markers: dict[str, Any],
    adjustments: list[dict[str, Any]],
    scale: float,
) -> dict[str, Any]:
    width = source["source"]["widthPx"]
    height = source["source"]["heightPx"]
    canonical_features = {feature["id"]: feature for feature in canonical["features"]}
    canonical_markers = {marker["id"]: marker for marker in canonical["markers"]}
    features = []
    for original in source["features"]:
        feature = dict(original)
        source_feature = canonical_features[original["id"]]
        feature["sourcePolygonPixels"] = copy.deepcopy(source_feature["polygonPixels"])
        if source_feature["category"] != original["category"]:
            feature["sourceCategory"] = source_feature["category"]
        if original["id"] == "B4":
            if original.get("notes"):
                feature["sourceNotes"] = original["notes"]
            feature["notes"] = "User confirmed B4 and Canteen are distinct neighboring buildings; their source polygons remain separate."
        feature["polygonStuds"] = [
            [round(preview_pixel_x(point[0], width) * scale, 6), round((height - point[1]) * scale, 6)]
            for point in original["polygonPixels"]
        ]
        feature["estimatedOutlinePartCount"] = edge_part_count(original["polygonPixels"], scale)
        features.append(feature)
    entrances = []
    for original in source["markers"]:
        x, y = original["positionPixels"]
        source_marker = canonical_markers[original["id"]]
        entrances.append({
            **original,
            "sourcePixelPosition": copy.deepcopy(source_marker["positionPixels"]),
            "pixelPosition": original["positionPixels"],
            "positionStuds": [round(preview_pixel_x(x, width) * scale, 6), round((height - y) * scale, 6)],
            "generatedInPreview": True,
        })
    existing_gameplay_markers = []
    for marker in old_markers["markers"]:
        existing_gameplay_markers.append({
            "id": marker["id"],
            "group": marker["group"],
            "markerType": marker["markerType"],
            "positionStuds": None,
            "generatedInPreview": False,
            "coordinateSource": "legacy ID inventory only; legacy metric coordinates excluded from this pixel preview",
        })
    return {
        "schemaVersion": 1,
        "project": "FNABK detached campus pixel preview",
        "previewName": "FNABK_Campus_PixelPreview_v1",
        "status": "PROVISIONAL_PIXEL_SPACE_VISUALIZATION",
        "previewStudsPerPixel": scale,
        "metersPerPixel": None,
        "geographicNorthAlignment": None,
        "oneToOneRealWorldAccuracy": False,
        "source": source["source"],
        "coordinateSystem": {
            "sourceUnits": "pixels",
            "sourceOrigin": "image top-left",
            "localOriginPixel": [width if HORIZONTAL_MIRROR else 0, height],
            "localOriginMeaning": "bottom-right corner of source image maps to local Roblox (X=0, Z=0)" if HORIZONTAL_MIRROR else "bottom-left corner of source image maps to local Roblox (X=0, Z=0)",
            "horizontalMirrorApplied": HORIZONTAL_MIRROR,
            "localXAxis": "+X points to image left after horizontal mirror" if HORIZONTAL_MIRROR else "+X points to image right",
            "localZAxis": "+Z points to image up",
            "transform": "xStuds = (imageWidthPx - pixelX) * previewStudsPerPixel; zStuds = (imageHeightPx - pixelY) * previewStudsPerPixel" if HORIZONTAL_MIRROR else "xStuds = pixelX * previewStudsPerPixel; zStuds = (imageHeightPx - pixelY) * previewStudsPerPixel",
            "rounding": "transformed coordinates rounded to 1e-6 studs; original pixel vertices remain unchanged",
        },
        "geometryMode": "outline_ribbons",
        "geometryModeDescription": "Each polygon edge becomes a thin horizontal Part ribbon. Interiors remain empty; concavities and courtyards are not filled.",
        "geometryAdjustments": {
            "sourceFile": "GeometryAdjustments.json",
            "applied": adjustments,
        },
        "features": features,
        "entranceMarkers": entrances,
        "existingGameplayMarkers": existing_gameplay_markers,
    }


def make_transform(source: dict[str, Any], scale: float, adjustments_path: Path) -> dict[str, Any]:
    width = source["source"]["widthPx"]
    height = source["source"]["heightPx"]
    return {
        "schemaVersion": 1,
        "previewStudsPerPixel": scale,
        "metersPerPixel": None,
        "geographicNorthAlignment": None,
        "realWorldMetricCalibration": None,
        "sourceImage": {"widthPx": width, "heightPx": height},
        "origin": {
            "sourcePixel": [width if HORIZONTAL_MIRROR else 0, height],
            "localRobloxStuds": [0, 0],
            "meaning": "image bottom-right maps to local Roblox origin" if HORIZONTAL_MIRROR else "image bottom-left maps to local Roblox origin",
        },
        "axes": {
            "horizontalMirrorApplied": HORIZONTAL_MIRROR,
            "localPlusX": "image left after horizontal mirror" if HORIZONTAL_MIRROR else "image right",
            "localPlusZ": "image up (pixel Y is inverted)",
            "noNorthClaim": True,
        },
        "formula": {
            "xStuds": "(imageWidthPx - pixelX) * previewStudsPerPixel" if HORIZONTAL_MIRROR else "pixelX * previewStudsPerPixel",
            "zStuds": "(imageHeightPx - pixelY) * previewStudsPerPixel",
        },
        "rounding": "transformed coordinates rounded to 1e-6 studs; canonical pixel vertices are unchanged",
        "scaleSource": "user-approved provisional visualization scale; independent of prior v6/v7 coordinates",
        "sourceGeometrySHA256": sha256(SOURCE_JSON),
        "adjustmentOverlay": {
            "file": adjustments_path.name,
            "sha256": sha256(adjustments_path),
        },
    }


def make_svg(source: dict[str, Any]) -> str:
    width = source["source"]["widthPx"]
    height = source["source"]["heightPx"]
    colors = {
        "boundary": ("#215b9b", 0.10),
        "building": ("#d98a36", 0.24),
        "area": ("#61a66f", 0.20),
        "entrance": ("#e74444", 1.0),
    }
    rows = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<title>FNABK campus provisional pixel-to-studs preview</title>',
        '<desc>Uncalibrated AI-generated reference geometry. Canonical pixel vertices are preserved; this preview is mirrored left-to-right. Local +X points to image left and local +Z is image up after Y inversion. No north or 1:1 accuracy claim.</desc>',
        '<rect width="100%" height="100%" fill="#f4f5f7"/>',
        '<g id="CampusGeometry" stroke-linejoin="round" stroke-linecap="round">',
    ]
    for feature in source["features"]:
        category = feature["category"]
        color, opacity = colors.get(category, ("#777777", 0.2))
        feature_id = html.escape(str(feature["id"]), quote=True)
        preview_points = [[preview_pixel_x(point[0], width), point[1]] for point in feature["polygonPixels"]]
        rows.append(
            f'<polygon id="{feature_id}" data-category="{html.escape(category, quote=True)}" '
            f'data-source-category="{html.escape(str(feature.get("sourceCategory", category)), quote=True)}" '
            f'data-adjustments="{html.escape(",".join(feature.get("geometryAdjustmentIds", [])), quote=True)}" '
            f'data-confidence="{html.escape(str(feature.get("confidence", "")), quote=True)}" '
            f'points="{svg_points(preview_points)}" fill="{color}" fill-opacity="{opacity}" '
            f'stroke="{color}" stroke-width="2" vector-effect="non-scaling-stroke"/>'
        )
    rows.append("</g>")
    rows.append('<g id="BuildingLabels" font-family="Arial, sans-serif" font-size="13" font-weight="bold" text-anchor="middle" dominant-baseline="middle" fill="#20242a" stroke="#ffffff" stroke-width="3" paint-order="stroke">')
    for feature in source["features"]:
        if feature["category"] != "building":
            continue
        preview_points = [[preview_pixel_x(point[0], width), point[1]] for point in feature["polygonPixels"]]
        label_x, label_y = polygon_centroid(preview_points)
        feature_id = html.escape(str(feature["id"]), quote=True)
        rows.append(f'<text data-label-for="{feature_id}" x="{number(label_x)}" y="{number(label_y)}">{feature_id}</text>')
    rows.append("</g>")
    rows.append('<g id="DigitizedEntrances" fill="#e74444" stroke="#ffffff" stroke-width="2">')
    for marker in source["markers"]:
        x, y = marker["positionPixels"]
        x = preview_pixel_x(x, width)
        marker_id = html.escape(str(marker["id"]), quote=True)
        rows.append(
            f'<circle id="{marker_id}" data-category="entrance" cx="{number(x)}" cy="{number(y)}" r="7"/>'
        )
        rows.append(
            f'<text x="{number(x + 9)}" y="{number(y - 9)}" fill="#20242a" stroke="none" '
            f'font-family="Arial, sans-serif" font-size="14">{marker_id}</text>'
        )
    rows.extend([
        "</g>",
        '<g id="PreviewDisclaimer" font-family="Arial, sans-serif" fill="#20242a">',
        '<text x="8" y="20" font-size="14" stroke="#ffffff" stroke-width="3" paint-order="stroke">PIXEL PREVIEW · NOT SURVEYED · NO NORTH ALIGNMENT</text>',
        "</g>",
        "</svg>",
        "",
    ])
    return "\n".join(rows)


def lua_quote(value: str) -> str:
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r") + '"'


def lua_value(value: Any, depth: int = 0) -> str:
    indent = "    " * depth
    child_indent = "    " * (depth + 1)
    if value is None:
        return "nil"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return number(value)
    if isinstance(value, str):
        return lua_quote(value)
    if isinstance(value, list):
        if not value:
            return "{}"
        values = [child_indent + lua_value(item, depth + 1) for item in value]
        return "{\n" + ",\n".join(values) + "\n" + indent + "}"
    if isinstance(value, dict):
        if not value:
            return "{}"
        values = [child_indent + "[" + lua_quote(str(key)) + "] = " + lua_value(item, depth + 1) for key, item in value.items()]
        return "{\n" + ",\n".join(values) + "\n" + indent + "}"
    raise TypeError(f"unsupported Lua manifest value: {type(value)}")


def make_lua_module(manifest: dict[str, Any]) -> str:
    features = [
        {
            "id": feature["id"],
            "category": feature["category"],
            "confidence": feature.get("confidence", ""),
            "polygonStuds": feature["polygonStuds"],
        }
        for feature in manifest["features"]
    ]
    entrances = [
        {"id": marker["id"], "positionStuds": marker["positionStuds"], "pixelPosition": marker["pixelPosition"]}
        for marker in manifest["entranceMarkers"]
    ]
    payload = {
        "previewName": manifest["previewName"],
        "previewStudsPerPixel": manifest["previewStudsPerPixel"],
        "sourceImage": {
            "widthPx": manifest["source"]["widthPx"],
            "heightPx": manifest["source"]["heightPx"],
        },
        "horizontalMirrorApplied": manifest["coordinateSystem"]["horizontalMirrorApplied"],
        "localOriginPixel": manifest["coordinateSystem"]["localOriginPixel"],
        "features": features,
        "entrances": entrances,
        "existingGameplayMarkerIds": [marker["id"] for marker in manifest["existingGameplayMarkers"]],
    }
    return "-- Generated by tools/Generate-CampusPixelPreview.py; edit the canonical JSON, then regenerate.\nreturn " + lua_value(payload) + "\n"


def mapping_markdown(pixel_manifest: dict[str, Any], old_manifest: dict[str, Any], old_markers: dict[str, Any]) -> str:
    pixel_ids = {item["id"] for item in pixel_manifest["features"] if item["category"] == "building"}
    old_ids = {item["id"] for item in old_manifest["buildingFootprints"]}
    shared = sorted(pixel_ids & old_ids)
    new = sorted(pixel_ids - old_ids)
    unresolved = sorted(old_ids - pixel_ids)
    lines = [
        "# Building ID mapping — pixel preview",
        "",
        "This mapping separates the new uncalibrated pixel preview from the existing v6 Phase A coordinate manifest. It is an identity crosswalk only; it does not transfer old metric positions into the preview.",
        "",
        "## Pixel building IDs",
        "",
        "| Pixel geometry ID | Existing CampusManifest ID | Status | Notes |",
        "|---|---|---|---|",
    ]
    for building_id in sorted(pixel_ids):
        if building_id == "B1":
            lines.append("| B1 | B1 | Exact ID; complex parent footprint | Pixel geometry keeps the U-shaped B1 complex as one polygon. B1A/B1B are treated as wings by the user's rule; this source does not provide separately traced wing polygons, and B1B is absent from the current CampusManifest. No wing geometry is inferred. |")
        elif building_id == "B4":
            lines.append("| B4 | B4 | Exact ID; distinct from Canteen | The user confirmed B4 and Canteen are separate neighboring buildings. B4 retains its own source polygon and label. |")
        elif building_id == "Canteen":
            lines.append("| Canteen | — | New pixel building identity; retained | The canonical source categorizes this polygon as an area. A separate preview-only category override renders it as a building; the user confirmed it is a distinct building beside B4. Its polygon is not merged with B4. |")
        elif building_id in shared:
            lines.append(f"| {building_id} | {building_id} | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |")
        else:
            lines.append(f"| {building_id} | — | New pixel identity; retained | Do not alias to another existing ID. |")
    lines.extend([
        "",
        "## Existing CampusManifest IDs without an exact pixel building ID",
        "",
        "| Existing ID | Mapping status | Handling |",
        "|---|---|---|",
    ])
    for building_id in unresolved:
        if building_id == "B1A":
            handling = "Unresolved independent footprint; retained as a possible B1 wing identity, with no separate pixel polygon."
        elif building_id == "B7":
            handling = "Unresolved; Facility7 is not treated as B7."
        elif building_id == "Kiosk8":
            handling = "Unresolved; KioskOISP is not treated as Kiosk8."
        else:
            handling = "Unresolved; kept in the existing manifest and not deleted or positioned in this preview."
        lines.append(f"| {building_id} | Unresolved | {handling} |")
    lines.extend([
        "| B1B | User-mentioned wing identity; absent from both current ID sets | No standalone polygon is created; its relationship within B1 needs source evidence. |",
        "",
        "## Canteen, facilities, and kiosk ambiguities",
        "",
        "- `B4` and `Canteen` are distinct neighboring buildings, confirmed by the user. `Canteen` keeps its canonical area category in the source JSON but is rendered as a building in this preview by an explicit category override.",
        "- `Facility7` remains `Facility7`; it is not an alias for legacy `B7`.",
        "- `KioskOISP` remains `KioskOISP`; it is not an alias for legacy `Kiosk8`.",
        "- New `B3`, `B11`, and `B12` identities are retained unchanged.",
        "",
        "## Gameplay markers are separate from entrances",
        "",
        "The existing 16 gameplay marker IDs are preserved in `CampusPreviewManifest.json` as inventory-only entries with null preview coordinates. Their v6 metric coordinates are deliberately excluded from this transformation. `Entrance1`, `Entrance2`, and `Entrance3` are a separate set of three pixel-digitized entrance markers and are the only markers positioned by this pixel preview.",
        "",
        "Existing gameplay marker IDs: " + ", ".join(f"`{marker['id']}`" for marker in old_markers["markers"]) + ".",
        "",
        "## Summary",
        "",
        f"- Exact ID matches: {len(shared)} ({', '.join(shared)}).",
        f"- New pixel building IDs retained: {len(new)} ({', '.join(new)}).",
        f"- Existing IDs unresolved: {len(unresolved)} ({', '.join(unresolved)}).",
        "- No old metric coordinate is used to set pixel scale, building location, or entrance position.",
        "",
        "## Phase C model templates used for the detached port",
        "",
        "These are visual templates only; each left-hand ID remains its own identity, and the legacy source ID remains in v6.",
        "",
        "| Pixel identity | Visual template |",
        "|---|---|",
        "| B3 | B6 |",
        "| B11 | B7 |",
        "| B12 | Facility1 |",
        "| Canteen | B10 |",
        "| Facility7 | B8 |",
        "| KioskOISP | Kiosk8 |",
        "",
        "The U-shaped B1 polygon is decomposed into three touching wings under one B1 parent, with its courtyard left open. No wing is renamed B1A or B1B without source evidence.",
        "",
    ])
    return "\n".join(lines)


def load_centers() -> tuple[dict[str, dict[str, str]], list[str]]:
    if not SOURCE_CSV.exists():
        return {}, ["pixel centers CSV is missing"]
    rows: dict[str, dict[str, str]] = {}
    issues: list[str] = []
    with SOURCE_CSV.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            key = row.get("id", "")
            if key in rows:
                issues.append(f"duplicate CSV row for {key}")
            rows[key] = row
    return rows, issues


def make_report(
    canonical_source: dict[str, Any],
    source: dict[str, Any],
    manifest: dict[str, Any],
    old_manifest: dict[str, Any],
    old_markers: dict[str, Any],
    adjustments: list[dict[str, Any]],
) -> tuple[str, list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    width = source["source"]["widthPx"]
    height = source["source"]["heightPx"]
    features = source["features"]
    canonical_by_id = {feature["id"]: feature for feature in canonical_source["features"]}
    canonical_markers_by_id = {marker["id"]: marker for marker in canonical_source["markers"]}
    buildings = [feature for feature in features if feature["category"] == "building"]
    boundary_features = [feature for feature in features if feature["category"] == "boundary"]
    if len(boundary_features) != 1:
        errors.append(f"expected exactly one boundary feature; found {len(boundary_features)}")
    seen_ids: set[str] = set()
    total_vertices = 0
    outside: list[str] = []
    degenerate: list[str] = []
    self_crossing: list[str] = []
    for feature in features:
        feature_id = feature["id"]
        if feature_id in seen_ids:
            errors.append(f"duplicate feature ID: {feature_id}")
        seen_ids.add(feature_id)
        points = feature.get("polygonPixels", [])
        total_vertices += len(points)
        if len(points) < 3:
            errors.append(f"{feature_id}: fewer than three polygon vertices")
            continue
        if len({(point[0], point[1]) for point in points}) < 3:
            errors.append(f"{feature_id}: fewer than three distinct vertices")
        if abs(polygon_area(points)) <= EPSILON:
            degenerate.append(feature_id)
        if polygon_self_intersections(points):
            self_crossing.append(feature_id)
        if any(
            not (-EPSILON <= point[0] <= width + EPSILON and -EPSILON <= point[1] <= height + EPSILON)
            for point in points
        ):
            outside.append(feature_id)
    if degenerate:
        errors.append("zero-area polygons: " + ", ".join(degenerate))
    if self_crossing:
        errors.append("self-intersecting/non-simple polygons: " + ", ".join(self_crossing))
    if outside:
        warnings.append("features with vertices outside source image: " + ", ".join(outside))

    overlap_pairs = []
    for i, first in enumerate(buildings):
        for second in buildings[i + 1:]:
            if polygons_overlap_area(first["polygonPixels"], second["polygonPixels"]):
                overlap_pairs.append((first["id"], second["id"]))
    if overlap_pairs:
        warnings.append(f"{len(overlap_pairs)} building-polygon overlap candidate(s) remain after the requested adjustments")

    boundary = boundary_features[0]["polygonPixels"] if boundary_features else []
    buildings_outside_boundary = []
    if boundary:
        for feature in buildings:
            if any(point_location(point, boundary) == 0 for point in feature["polygonPixels"]):
                buildings_outside_boundary.append(feature["id"])
    if buildings_outside_boundary:
        warnings.append("building vertices outside campus boundary: " + ", ".join(buildings_outside_boundary))
    entrances_outside_boundary: list[tuple[str, float]] = []
    for marker in source["markers"]:
        if boundary and point_location(marker["positionPixels"], boundary) == 0:
            entrances_outside_boundary.append((marker["id"], distance_to_polygon(marker["positionPixels"], boundary)))
    if entrances_outside_boundary:
        warnings.append("digitized entrance marker(s) outside campus boundary: " + ", ".join(f"{marker_id} ({distance:.2f}px from outline)" for marker_id, distance in entrances_outside_boundary))

    # B1's center recess is intentionally tested as an empty point in pixel space.
    b1 = next((feature for feature in buildings if feature["id"] == "B1"), None)
    courtyard_point = [291.0, 650.0]
    b1_courtyard_open = bool(b1 and point_location(courtyard_point, b1["polygonPixels"]) == 0)
    courtyard_intruders = [
        feature["id"] for feature in buildings
        if feature["id"] != "B1" and point_location(courtyard_point, feature["polygonPixels"]) == 1
    ]
    if not b1_courtyard_open:
        errors.append("B1 courtyard sample is not open at pixel point (291, 650)")
    if courtyard_intruders:
        warnings.append("other building polygon contains B1 courtyard sample: " + ", ".join(courtyard_intruders))

    csv_rows, csv_issues = load_centers()
    warnings.extend(csv_issues)
    expected_csv_ids = {feature["id"] for feature in features} | {marker["id"] for marker in source["markers"]}
    missing_csv = sorted(expected_csv_ids - set(csv_rows))
    extra_csv = sorted(set(csv_rows) - expected_csv_ids)
    if missing_csv or extra_csv:
        warnings.append(f"pixel center CSV ID coverage differs (missing={missing_csv}, extra={extra_csv})")
    center_issues = []
    by_id = {feature["id"]: feature for feature in features}
    for feature_id in expected_csv_ids & set(csv_rows):
        row = csv_rows[feature_id]
        if feature_id in canonical_by_id:
            expected_category = canonical_by_id[feature_id]["category"]
            expected_vertices = len(canonical_by_id[feature_id]["polygonPixels"])
        else:
            marker = canonical_markers_by_id[feature_id]
            expected_category = marker["category"]
            expected_vertices = 1
        if row.get("category") != expected_category:
            center_issues.append(f"{feature_id}: CSV category {row.get('category')} differs from JSON category {expected_category}")
        try:
            csv_vertices = int(row.get("n_vertices", ""))
            if csv_vertices != expected_vertices:
                center_issues.append(f"{feature_id}: CSV n_vertices={csv_vertices}, JSON vertices={expected_vertices}")
        except ValueError:
            center_issues.append(f"{feature_id}: invalid CSV n_vertices")
        try:
            actual_x, actual_y = float(row["center_x_px"]), float(row["center_y_px"])
        except (ValueError, KeyError):
            center_issues.append(f"{feature_id}: missing or invalid center values")
            continue
        if not (0 <= actual_x <= width and 0 <= actual_y <= height):
            center_issues.append(f"{feature_id}: CSV center lies outside image bounds")
    if center_issues:
        warnings.extend(center_issues)

    input_svg_ok, input_svg_message = validate_input_svg(canonical_source["features"])
    if not input_svg_ok:
        warnings.append("supplied vector-only SVG check: " + input_svg_message)

    original_by_id = {feature["id"]: feature["polygonPixels"] for feature in canonical_source["features"]}
    manifest_source_by_id = {feature["id"]: feature["sourcePolygonPixels"] for feature in manifest["features"]}
    manifest_by_id = {feature["id"]: feature["polygonPixels"] for feature in manifest["features"]}
    effective_by_id = {feature["id"]: feature["polygonPixels"] for feature in features}
    pixel_vertices_preserved = original_by_id == manifest_source_by_id
    if not pixel_vertices_preserved:
        errors.append("preview manifest did not retain canonical source polygon vertices")
    effective_geometry_matches = effective_by_id == manifest_by_id
    if not effective_geometry_matches:
        errors.append("preview manifest geometry does not match the source plus explicit adjustment overlay")
    transform_matches_formula = True
    for feature in manifest["features"]:
        expected_studs = [
            [round(preview_pixel_x(point[0], width) * manifest["previewStudsPerPixel"], 6), round((height - point[1]) * manifest["previewStudsPerPixel"], 6)]
            for point in feature["polygonPixels"]
        ]
        if expected_studs != feature["polygonStuds"]:
            transform_matches_formula = False
            break
    if not transform_matches_formula:
        errors.append("one or more transformed polygon coordinates do not match the documented formula")

    # Check the generated SVG against effective preview pixels using XML parsing.
    generated_svg_path = OUTPUT_DIR / "CampusPreviewTopDown.svg"
    generated_svg_ok = False
    if generated_svg_path.exists():
        root = ET.parse(generated_svg_path).getroot()
        generated_polygons = {
            element.attrib.get("id"): parse_svg_points(element.attrib.get("points", ""))
            for element in root.iter()
            if element.tag.rsplit("}", 1)[-1] == "polygon" and element.attrib.get("id")
        }
        generated_svg_ok = set(generated_polygons) == {feature["id"] for feature in features}
        if generated_svg_ok:
            for feature in features:
                actual = generated_polygons[feature["id"]]
                expected = [[preview_pixel_x(point[0], width), point[1]] for point in feature["polygonPixels"]]
                if len(actual) != len(expected) or any(
                    abs(a[0] - e[0]) > EPSILON or abs(a[1] - e[1]) > EPSILON
                    for a, e in zip(actual, expected)
                ):
                    generated_svg_ok = False
                    break
    if not generated_svg_ok:
        errors.append("generated SVG footprint geometry does not exactly match adjusted preview manifest vertices")

    # Verify transformed limits and estimate edge Part counts after splitting long edges.
    max_source_edge_dimension = 0.0
    total_edge_parts = 0
    category_counts: dict[str, int] = {}
    nearest = []
    centers = {}
    for feature in buildings:
        row = csv_rows.get(feature["id"])
        try:
            centers[feature["id"]] = (float(row["center_x_px"]), float(row["center_y_px"])) if row else polygon_centroid(feature["polygonPixels"])
        except (ValueError, KeyError):
            centers[feature["id"]] = polygon_centroid(feature["polygonPixels"])
    for feature in features:
        category_counts[feature["category"]] = category_counts.get(feature["category"], 0) + 1
        stud_points = [[preview_pixel_x(x, width) * manifest["previewStudsPerPixel"], (height - y) * manifest["previewStudsPerPixel"]] for x, y in feature["polygonPixels"]]
        total_edge_parts += edge_part_count(feature["polygonPixels"], manifest["previewStudsPerPixel"])
        for i, point in enumerate(stud_points):
            nxt = stud_points[(i + 1) % len(stud_points)]
            max_source_edge_dimension = max(max_source_edge_dimension, math.hypot(nxt[0] - point[0], nxt[1] - point[1]))
    for building_id, center in centers.items():
        neighbors = sorted(
            (math.hypot(center[0] - other[0], center[1] - other[1]), other_id)
            for other_id, other in centers.items() if other_id != building_id
        )
        nearest.append((building_id, neighbors[0][1], neighbors[0][0] * manifest["previewStudsPerPixel"]))
    nearest.sort(key=lambda item: item[0])

    pixel_building_ids = {feature["id"] for feature in buildings}
    old_ids = {feature["id"] for feature in old_manifest["buildingFootprints"]}
    exact_ids = sorted(pixel_building_ids & old_ids)
    new_ids = sorted(pixel_building_ids - old_ids)
    unresolved_ids = sorted(old_ids - pixel_building_ids)
    old_marker_ids = [marker["id"] for marker in old_markers["markers"]]
    if len(old_marker_ids) != 16:
        warnings.append(f"expected 16 legacy gameplay marker IDs; found {len(old_marker_ids)}")

    b4 = next((item for item in buildings if item["id"] == "B4"), None)
    canteen = next((item for item in features if item["id"] == "Canteen"), None)
    b4_canteen_overlap = bool(b4 and canteen and polygons_overlap_area(b4["polygonPixels"], canteen["polygonPixels"]))
    b4_canteen_gap = polygon_boundary_distance(b4["polygonPixels"], canteen["polygonPixels"]) if b4 and canteen else math.inf
    b4_canteen_adjacent = bool(b4 and canteen and not b4_canteen_overlap and b4_canteen_gap <= 15.0)
    if b4 and canteen and (b4_canteen_overlap or not b4_canteen_adjacent):
        errors.append("B4 and Canteen must remain distinct, non-overlapping neighboring building footprints")

    b8 = next((item for item in buildings if item["id"] == "B8"), None)
    b9 = next((item for item in buildings if item["id"] == "B9"), None)
    b8_b9_overlap = bool(b8 and b9 and polygons_overlap_area(b8["polygonPixels"], b9["polygonPixels"]))
    b8_b9_gap = polygon_boundary_distance(b8["polygonPixels"], b9["polygonPixels"]) if b8 and b9 else math.inf
    b8_angle_difference = math.inf
    b8_b9_separated_parallel = False
    if b8 and b9:
        b8_axis = [b8["polygonPixels"][1][0] - b8["polygonPixels"][0][0], b8["polygonPixels"][1][1] - b8["polygonPixels"][0][1]]
        b9_axis = [b9["polygonPixels"][1][0] - b9["polygonPixels"][0][0], b9["polygonPixels"][1][1] - b9["polygonPixels"][0][1]]
        b8_angle_difference = unoriented_edge_angle_difference_degrees(b8_axis, b9_axis)
        b8_b9_separated_parallel = not b8_b9_overlap and 5.0 <= b8_b9_gap <= 8.0 and b8_angle_difference <= 0.01
    if not b8_b9_separated_parallel:
        errors.append("B8 and B9 must be non-overlapping, 5–8px apart, and parallel within 0.01 degrees")

    source_entrance1 = canonical_markers_by_id.get("Entrance1")
    effective_entrance1 = next((item for item in source["markers"] if item["id"] == "Entrance1"), None)
    entrance1_adjustment = next((item for item in adjustments if item["id"] == "Entrance1"), None)
    entrance1_shifted_right = bool(
        source_entrance1 and effective_entrance1 and entrance1_adjustment
        and effective_entrance1["positionPixels"] == [
            source_entrance1["positionPixels"][0] + entrance1_adjustment["deltaPixels"][0],
            source_entrance1["positionPixels"][1] + entrance1_adjustment["deltaPixels"][1],
        ]
        and entrance1_adjustment["deltaPixels"][0] > 0
    )
    if not entrance1_shifted_right:
        errors.append("Entrance1 must keep its source pixel position and apply the documented rightward adjustment")

    lines = [
        "# Pixel geometry validation report",
        "",
        f"Status: **{'FAIL' if errors else ('PASS WITH WARNINGS' if warnings else 'PASS')}**",
        "",
        "## Scope and provenance",
        "",
        "The geometry checks in this report run offline. No gameplay map/runtime scripts, asset uploads, cloud generation, or publishing were part of this operation. The separately approved Studio Edit build and structural audit are recorded in `StudioBuildRecord.md`. The source diagram is marked AI-generated and unverified; this is a relative pixel visualization, not surveyed geometry.",
        "",
        f"- Canonical JSON SHA-256: `{sha256(SOURCE_JSON)}`.",
        f"- Adjustment overlay SHA-256: `{sha256(ADJUSTMENTS_JSON)}`.",
        f"- Source image canvas: {width} × {height}px.",
        f"- Preview scale: {manifest['previewStudsPerPixel']} stud/px; metersPerPixel = null.",
        f"- Input vector-only SVG: {'PASS' if input_svg_ok else 'WARN'} — {input_svg_message}.",
        f"- Generated top-down SVG vs adjusted preview geometry: {'PASS' if generated_svg_ok else 'FAIL'}.",
        f"- Canonical pixel vertices retained unchanged in `sourcePolygonPixels`: {'PASS' if pixel_vertices_preserved else 'FAIL'}.",
        f"- Effective preview polygons match canonical source plus adjustment overlay: {'PASS' if effective_geometry_matches else 'FAIL'}.",
        f"- Pixel-to-stud formula, horizontal mirror and Y inversion: {'PASS' if transform_matches_formula else 'FAIL'}.",
        "- Preview orientation: left/right mirrored around the source-image vertical center; canonical pixel vertices remain unchanged.",
        "- Applied explicit user adjustments: B9 separated and aligned parallel to B8; Entrance1 shifted right in source-pixel space before the mirror; Canteen rendered as a distinct building beside B4.",
        "",
        "## Geometry checks",
        "",
        f"- Features: {len(features)} total; buildings {category_counts.get('building', 0)}, areas {category_counts.get('area', 0)}, boundary {category_counts.get('boundary', 0)}.",
        f"- Pixel polygon vertices: {total_vertices}; all polygons have ≥3 distinct points: {'PASS' if not any(len(set((p[0], p[1]) for p in f.get('polygonPixels', []))) < 3 for f in features) else 'FAIL'}.",
        f"- Non-zero area: {'PASS' if not degenerate else 'FAIL' + ' (' + ', '.join(degenerate) + ')'}.",
        f"- Simple/non-self-intersecting polygons: {'PASS' if not self_crossing else 'FAIL' + ' (' + ', '.join(self_crossing) + ')'}.",
        f"- All vertices inside source image bounds: {'PASS' if not outside else 'WARN' + ' (' + ', '.join(outside) + ')'}.",
        f"- Building overlap candidates: {len(overlap_pairs)}.",
    ]
    if overlap_pairs:
        lines.extend(["", "Remaining overlap candidates (no additional geometry was moved):", ""])
        lines.extend(f"- `{first}` / `{second}`" for first, second in overlap_pairs)
    lines.extend([
        "",
        f"- B1 U-courtyard sample at pixel (291, 650) is outside the B1 polygon: {'PASS' if b1_courtyard_open else 'FAIL'}.",
        f"- Other building polygons containing that sample point: {', '.join(courtyard_intruders) if courtyard_intruders else 'none'}.",
        f"- Building polygon vertices outside CampusBoundary: {', '.join(buildings_outside_boundary) if buildings_outside_boundary else 'none'}.",
        f"- Entrance markers outside CampusBoundary: {', '.join(f'{marker_id} ({distance:.2f}px)' for marker_id, distance in entrances_outside_boundary) if entrances_outside_boundary else 'none'}.",
        f"- Entrance1 moved right by {entrance1_adjustment['deltaPixels'][0]:g}px per request; adjusted point is {'inside' if boundary and point_location(effective_entrance1['positionPixels'], boundary) != 0 else 'outside'} CampusBoundary.",
        f"- B8/B9 spacing and orientation: {'PASS' if b8_b9_separated_parallel else 'FAIL'}; overlap={'yes' if b8_b9_overlap else 'no'}, edge gap={b8_b9_gap:.2f}px, long-edge angle difference={b8_angle_difference:.4f}°.",
        f"- B4/Canteen: {'PASS' if b4_canteen_adjacent else 'FAIL'} as distinct neighboring building polygons; overlap={'yes' if b4_canteen_overlap else 'no'}, boundary gap={b4_canteen_gap:.2f}px. Canteen source category is `area`; preview category is `building`.",
        "",
        "## IDs and source cross-checks",
        "",
        f"- Pixel building IDs: {len(pixel_building_ids)}; exact shared IDs with existing CampusManifest: {len(exact_ids)} ({', '.join(exact_ids)}).",
        f"- New pixel building identities retained: {len(new_ids)} ({', '.join(new_ids)}).",
        f"- Existing unmatched building IDs retained as unresolved: {len(unresolved_ids)} ({', '.join(unresolved_ids)}).",
        "- `Facility7` was not aliased to `B7`; `KioskOISP` was not aliased to `Kiosk8`.",
        f"- Existing gameplay marker IDs preserved separately: {len(old_marker_ids)} ({', '.join(old_marker_ids)}); none receive pixel-preview coordinates.",
        f"- New digitized entrance IDs: {', '.join(marker['id'] for marker in source['markers'])}.",
        f"- Pixel center CSV IDs: expected {len(expected_csv_ids)}, present {len(csv_rows)}; categories and vertex counts checked; centers checked against source-image bounds.",
        "",
        "## Preview geometry and Part estimate",
        "",
        "- Generation mode is polygon-edge ribbons. It preserves each polygon edge while leaving its interior empty, so it cannot fill B1's courtyard. It is an outline visualization, not walkable floors or solid building masses.",
        f"- Estimated edge Parts at this scale, including the campus boundary: {total_edge_parts}; three entrance marker Parts and {math.ceil(width * manifest['previewStudsPerPixel'] / MAX_PART_LENGTH_STUDS) * math.ceil(height * manifest['previewStudsPerPixel'] / MAX_PART_LENGTH_STUDS)} canvas tile(s) bring the total estimate to {total_edge_parts + 3 + math.ceil(width * manifest['previewStudsPerPixel'] / MAX_PART_LENGTH_STUDS) * math.ceil(height * manifest['previewStudsPerPixel'] / MAX_PART_LENGTH_STUDS)}.",
        f"- Longest source edge at this scale: {max_source_edge_dimension:.3f} studs; generator subdivides edges at {MAX_PART_LENGTH_STUDS:.0f} studs, below Roblox's 2048-stud BasePart axis limit. Canvas tiles also stay within that limit.",
        "- Every generated BasePart is configured Anchored=true, CanCollide=false, CanTouch=false, CanQuery=false. Builder creates no scripts and is not called by gameplay bootstrap.",
        "",
        "## Spatial relationships (nearest building centers)",
        "",
        "Distances use the supplied pixel-only CSV centers (with polygon-centroid fallback for a missing/invalid row), multiplied by the configured visualization scale. They are not real-world distances.",
        "",
    ])
    lines.extend(f"- `{building}` nearest to `{neighbor}`: {distance:.2f} preview studs." for building, neighbor, distance in nearest)
    lines.extend(["", "## Findings requiring human review", "", "- The generated source is not a verified campus plan; confidence for building footprints is rough/manual and requires tracing.", "- B1's U-shape and the relationship of legacy B1A/B1B wing IDs still need source evidence.", "- Review any remaining overlap candidates and estimated boundaries; no additional geometry has been moved.", "- The 16 existing gameplay marker IDs have no pixel coordinates and remain unplaced.", ""])
    if errors:
        lines.extend(["## Errors", ""] + [f"- {item}" for item in errors] + [""])
    if warnings:
        lines.extend(["## Warnings", ""] + [f"- {item}" for item in warnings] + [""])
    return "\n".join(lines), errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scale", type=float, default=1.0, help="preview visualization studs per source pixel (default: 1.0)")
    args = parser.parse_args()
    if args.scale <= 0:
        parser.error("--scale must be greater than zero")
    for path in (SOURCE_JSON, ADJUSTMENTS_JSON, SOURCE_CSV, SOURCE_VECTOR_SVG, OLD_MANIFEST, OLD_MARKERS):
        if not path.exists():
            print(f"ERROR: required input is missing: {path}", file=sys.stderr)
            return 2

    canonical_source = read_json(SOURCE_JSON)
    overlay = read_json(ADJUSTMENTS_JSON)
    old_manifest = read_json(OLD_MANIFEST)
    old_markers = read_json(OLD_MARKERS)
    if canonical_source.get("coordinateSystem", {}).get("metersPerPixel") is not None:
        print("ERROR: canonical source metersPerPixel must remain null", file=sys.stderr)
        return 2
    try:
        source, applied_adjustments = apply_geometry_adjustments(canonical_source, overlay)
    except (KeyError, TypeError, ValueError) as error:
        print(f"ERROR: could not apply geometry adjustment overlay: {error}", file=sys.stderr)
        return 2
    manifest = make_manifest(source, canonical_source, old_markers, applied_adjustments, args.scale)
    preview_path = OUTPUT_DIR / "CampusPreviewManifest.json"
    transform_path = OUTPUT_DIR / "PixelToStudsTransform.json"
    svg_path = OUTPUT_DIR / "CampusPreviewTopDown.svg"
    mapping_path = OUTPUT_DIR / "BuildingIDMapping.md"
    lua_path = LUA_DIR / "CampusPreviewManifest.luau"
    write_json(preview_path, manifest)
    write_json(transform_path, make_transform(source, args.scale, ADJUSTMENTS_JSON))
    svg_path.write_text(make_svg(source), encoding="utf-8", newline="\n")
    mapping_path.write_text(mapping_markdown(manifest, old_manifest, old_markers), encoding="utf-8", newline="\n")
    lua_path.write_text(make_lua_module(manifest), encoding="utf-8", newline="\n")
    report, errors = make_report(canonical_source, source, manifest, old_manifest, old_markers, applied_adjustments)
    (OUTPUT_DIR / "GeometryValidationReport.md").write_text(report, encoding="utf-8", newline="\n")
    print(f"Generated preview outputs at scale {args.scale} stud/px.")
    print(f"Canonical JSON SHA-256: {sha256(SOURCE_JSON)}")
    print(f"Validation report: {OUTPUT_DIR / 'GeometryValidationReport.md'}")
    if errors:
        print(f"Validation found {len(errors)} error(s).", file=sys.stderr)
        return 1
    print("Offline geometry validation completed without structural errors.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
