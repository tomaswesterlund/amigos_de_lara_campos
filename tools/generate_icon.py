"""
Generate the app icon for Amigos de Lara Campos.
Outputs: assets/icon/app_icon.png  (1024×1024)

Run from the project root:
    python3 tools/generate_icon.py

Layout
------
• Magenta → pink gradient background (unchanged from v1).
• Large cream heart centred on the canvas (unchanged — user liked this).
• Lara Campos figure drawn at ~3.7× the sprite scale, centred horizontally,
  spanning roughly 70 % of icon height so she clearly dominates the icon.
  Based on draw_lara() / lara_d1() in tools/generate_sprites.py.
• Gold sparkles in the corners.
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw

SIZE = 1024
OUT = Path(__file__).parent.parent / "assets" / "icon" / "app_icon.png"

# Scale factor and offsets to map sprite coordinates (256×256 canvas) to icon.
# Lara's hair top lands near y=68, body bottom near y=935.
_S  = 3.7    # scale
_OX = 38     # x offset so figure is centred at x=512
_OY = 10     # y offset

# Brand colours
_SKIN    = (255, 220, 190)
_HAIR    = (80,  50,  35)
_PINK    = (255, 92,  168)
_MAGENTA = (200, 40,  100)
_RGREEN  = (110, 200, 90)
_RDARK   = (76,  156, 64)
_BLACK   = (30,  30,  40)
_WHITE   = (255, 255, 255)
_GOLD    = (255, 214, 64)
_CREAM   = (255, 245, 235)


def _s(coords):
    """Scale + offset a flat list of sprite coords → icon coords (ints)."""
    out = []
    for i, v in enumerate(coords):
        out.append(int(v * _S + (_OX if i % 2 == 0 else _OY)))
    return out


def _gradient_bg(draw: ImageDraw.ImageDraw) -> None:
    top = (227, 50, 130)
    bot = (255, 100, 170)
    for y in range(SIZE):
        t = y / SIZE
        r = int(top[0] + (bot[0] - top[0]) * t)
        g = int(top[1] + (bot[1] - top[1]) * t)
        b = int(top[2] + (bot[2] - top[2]) * t)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b))


def _heart_pts(cx: float, cy: float, scale: float):
    pts = []
    for i in range(300):
        t = 2 * math.pi * i / 300
        x = scale * 16 * math.sin(t) ** 3
        y = -scale * (13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t))
        pts.append((cx + x, cy + y))
    return pts


def _draw_heart(draw, cx, cy, scale, fill, outline, width) -> None:
    pts = _heart_pts(cx, cy, scale)
    draw.polygon(pts, fill=fill)
    draw.line(pts + [pts[0]], fill=outline, width=width)


def _draw_sparkle(draw, cx, cy, size, color) -> None:
    for angle in range(0, 360, 90):
        rad = math.radians(angle)
        x1 = cx + math.cos(rad) * size
        y1 = cy + math.sin(rad) * size
        x2 = cx + math.cos(rad + math.pi / 2) * size * 0.25
        y2 = cy + math.sin(rad + math.pi / 2) * size * 0.25
        x3 = cx + math.cos(rad + math.pi) * size
        y3 = cy + math.sin(rad + math.pi) * size
        draw.polygon([(cx, cy), (x2, y2), (x1, y1)], fill=color)
        draw.polygon([(cx, cy), (x2, y2), (x3, y3)], fill=color)


def _draw_lara(draw: ImageDraw.ImageDraw) -> None:
    """
    Draw the Lara Campos character at icon scale.
    Coordinates mirror draw_lara() / lara_d1() from generate_sprites.py,
    scaled by _S and offset by (_OX, _OY).
    """

    # ── Outfit (body) — pink, drawn first so it sits behind face/hair ────────
    bx1, by1, bx2, by2 = _s([62, 170, 194, 250])
    draw.rounded_rectangle([bx1, by1, bx2, by2],
                           radius=int(20 * _S),
                           fill=_PINK,
                           outline=_MAGENTA,
                           width=6)

    # Small heart on outfit (centred on the body rectangle)
    outfit_cx = (bx1 + bx2) // 2
    outfit_cy = by1 + int((by2 - by1) * 0.34)
    _draw_heart(draw, outfit_cx, outfit_cy,
                scale=int(60 * _S / 32),   # ~7
                fill=_CREAM,
                outline=_MAGENTA,
                width=4)

    # ── Hair (big brown ellipse — behind face ellipse) ────────────────────────
    draw.ellipse(_s([46, 16, 210, 130]),  fill=_HAIR,  outline=_BLACK, width=5)

    # ── Face — two overlapping ellipses for a rounder face ───────────────────
    draw.ellipse(_s([60, 30, 196, 180]), fill=_SKIN, outline=_BLACK, width=5)
    draw.ellipse(_s([60, 60, 196, 160]), fill=_SKIN)

    # ── Eyes ─────────────────────────────────────────────────────────────────
    draw.ellipse(_s([90, 100, 112, 122]),  fill=_BLACK)
    draw.ellipse(_s([144, 100, 166, 122]), fill=_BLACK)

    # Eye highlights (tiny white dot in each eye)
    for ex, ey in [_s([94, 104]), _s([148, 104])]:
        hw = int(4 * _S)
        draw.ellipse([ex, ey, ex + hw, ey + hw], fill=_WHITE)

    # ── Cheeks ───────────────────────────────────────────────────────────────
    draw.ellipse(_s([78,  128, 104, 148]), fill=(*_PINK[:3], 160))
    draw.ellipse(_s([152, 128, 178, 148]), fill=(*_PINK[:3], 160))

    # ── Smile ────────────────────────────────────────────────────────────────
    sx1, sy1, sx2, sy2 = _s([100, 132, 156, 168])
    draw.arc([sx1, sy1, sx2, sy2], start=10, end=170, fill=_BLACK, width=int(4 * _S))

    # ── Rhenné frog scrunchie in hair (top-right, as in lara_d1) ─────────────
    draw.ellipse(_s([176, 14, 212, 50]), fill=_RGREEN, outline=_RDARK, width=int(3 * _S))
    draw.ellipse(_s([186, 22, 198, 34]), fill=_WHITE)
    draw.ellipse(_s([189, 24, 196, 32]), fill=_BLACK)


def main() -> None:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background gradient
    _gradient_bg(draw)

    # 2. Large cream heart (kept exactly as user liked)
    _draw_heart(draw,
                cx=SIZE * 0.50, cy=SIZE * 0.52, scale=SIZE * 0.022,
                fill=_CREAM, outline=(200, 40, 100), width=14)

    # 3. Lara Campos figure (dominant — covers most of the icon)
    _draw_lara(draw)

    # 4. Gold sparkles in background corners (behind Lara, drawn early enough
    #    that they don't compete with her, but visible around her edges)
    for sx, sy, sr in [
        (SIZE * 0.10, SIZE * 0.15, SIZE * 0.038),
        (SIZE * 0.88, SIZE * 0.10, SIZE * 0.030),
        (SIZE * 0.92, SIZE * 0.80, SIZE * 0.034),
        (SIZE * 0.08, SIZE * 0.78, SIZE * 0.028),
    ]:
        _draw_sparkle(draw, sx, sy, sr, _GOLD)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, "PNG")
    print(f"Icon saved → {OUT}  ({SIZE}×{SIZE})")


if __name__ == "__main__":
    main()
