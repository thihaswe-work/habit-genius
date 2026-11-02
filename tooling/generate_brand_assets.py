"""Generate the Habit Genius mark for Flutter, Android and iOS assets."""

from __future__ import annotations

import json
import math
import struct
import zlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def _segment_distance(px: float, py: float, ax: float, ay: float,
                      bx: float, by: float) -> float:
    dx, dy = bx - ax, by - ay
    length = dx * dx + dy * dy
    if length == 0:
        return math.hypot(px - ax, py - ay)
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / length))
    return math.hypot(px - (ax + t * dx), py - (ay + t * dy))


def _blend(a: tuple[int, int, int], b: tuple[int, int, int], t: float):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def _png(path: Path, width: int, height: int, rows: bytes) -> None:
    def chunk(kind: bytes, data: bytes) -> bytes:
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(rows, 9))
        + chunk(b"IEND", b"")
    )


def render(path: Path, width: int, height: int, *, transparent: bool = False,
           tile_ratio: float = 1.0) -> None:
    samples = ((0.25, 0.25), (0.75, 0.25), (0.25, 0.75), (0.75, 0.75))
    size = min(width, height)
    tile_size = size * tile_ratio
    left = (width - tile_size) / 2
    top = (height - tile_size) / 2
    corner = tile_size * 0.24
    center_x, center_y = width / 2, height / 2
    ring_radius, ring_width = tile_size * 0.255, tile_size * 0.047
    check_width = tile_size * 0.058
    ax, ay = center_x - tile_size * 0.115, center_y + tile_size * 0.015
    bx, by = center_x - tile_size * 0.015, center_y + tile_size * 0.115
    cx, cy = center_x + tile_size * 0.17, center_y - tile_size * 0.13
    sparkle_x, sparkle_y = center_x + tile_size * 0.26, center_y - tile_size * 0.28
    sparkle_size = tile_size * 0.035
    start, end = (78, 54, 222), (139, 112, 255)

    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            totals = [0, 0, 0, 0]
            for ox, oy in samples:
                px, py = x + ox, y + oy
                local_x, local_y = px - left, py - top
                qx = abs(local_x - tile_size / 2) - (tile_size / 2 - corner)
                qy = abs(local_y - tile_size / 2) - (tile_size / 2 - corner)
                outside = math.hypot(max(qx, 0), max(qy, 0))
                inside = min(max(qx, qy), 0)
                in_tile = outside + inside <= 0
                if transparent and not in_tile:
                    color = (0, 0, 0, 0)
                else:
                    mix = max(0.0, min(1.0, (px / width + py / height) / 2))
                    base = _blend(start, end, mix)
                    color = (*base, 255)

                dist = abs(math.hypot(px - center_x, py - center_y) - ring_radius)
                in_ring = dist <= ring_width / 2
                first_leg = _segment_distance(px, py, ax, ay, bx, by) <= check_width / 2
                second_leg = _segment_distance(px, py, bx, by, cx, cy) <= check_width / 2
                star_dist = abs(px - sparkle_x) + abs(py - sparkle_y)
                star = star_dist <= sparkle_size and (
                    abs(px - sparkle_x) <= sparkle_size * 0.22
                    or abs(py - sparkle_y) <= sparkle_size * 0.22
                )
                if in_tile and (in_ring or first_leg or second_leg or star):
                    color = (255, 255, 255, 255)
                for i, value in enumerate(color):
                    totals[i] += value
            raw.extend(round(v / len(samples)) for v in totals)
    _png(path, width, height, bytes(raw))


def main() -> None:
    asset = ROOT / "assets" / "brand"
    render(asset / "brand_logo.png", 512, 512)

    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, size in android_sizes.items():
        render(ROOT / "android/app/src/main/res" / folder / "ic_launcher.png", size, size)

    icon_folder = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    icon_json = json.loads((icon_folder / "Contents.json").read_text())
    for image in icon_json["images"]:
        if "filename" not in image:
            continue
        side = round(float(image["size"].split("x")[0]) * float(image["scale"].removesuffix("x")))
        render(icon_folder / image["filename"], side, side)

    launch_folder = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    for scale, filename in ((1, "LaunchImage.png"), (2, "LaunchImage@2x.png"),
                            (3, "LaunchImage@3x.png")):
        render(launch_folder / filename, 168 * scale, 185 * scale,
               transparent=True, tile_ratio=0.76)

    render(ROOT / "android/app/src/main/res/drawable-nodpi/brand_logo.png", 108, 108)


if __name__ == "__main__":
    main()
