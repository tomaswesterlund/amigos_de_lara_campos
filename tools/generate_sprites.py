"""Generate stand-in PNG sprites for the Lara Campos demo games.

Run with: python3 tools/generate_sprites.py
Outputs to: assets/images/
"""
from PIL import Image, ImageDraw
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets" / "images"
OUT.mkdir(parents=True, exist_ok=True)

SIZE = 256
TRANSPARENT = (0, 0, 0, 0)

PINK = (255, 92, 168, 255)
MAGENTA = (227, 50, 130, 255)
MINT = (114, 224, 196, 255)
YELLOW = (255, 214, 64, 255)
RHENNE_GREEN = (110, 200, 90, 255)
RHENNE_GREEN_DARK = (76, 156, 64, 255)
GALLETA_BROWN = (190, 130, 78, 255)
GALLETA_BROWN_DARK = (140, 90, 50, 255)
HEART_RED = (235, 64, 88, 255)
HEART_RED_DARK = (180, 30, 60, 255)
WHITE = (255, 255, 255, 255)
BLACK = (30, 30, 40, 255)
GOLD = (252, 200, 50, 255)
ROCK = (110, 100, 110, 255)
ROCK_DARK = (70, 64, 76, 255)
LILY = (90, 190, 130, 255)
LILY_DARK = (50, 140, 90, 255)
BONE = (250, 240, 210, 255)
BONE_DARK = (200, 180, 140, 255)

# Accessory palette
SUNGLASS_LENS  = (20, 20, 30, 228)
SUNGLASS_FRAME = (10, 10, 20, 255)
FEDORA_FELT    = (58, 38, 22, 255)
FEDORA_DARK    = (32, 20, 10, 255)
FEDORA_BAND    = (18, 18, 18, 255)
NERD_FRAME     = (62, 36, 14, 255)
NERD_LENS      = (200, 225, 255, 155)
BAVARIA_HAT    = (46, 108, 36, 255)
BAVARIA_DARK   = (26, 68, 20, 255)
BAVARIA_BAND   = (242, 242, 242, 255)
FEATHER        = (238, 232, 186, 255)
LEDER_BROWN    = (118, 70, 28, 255)
LEDER_DARK     = (76, 44, 16, 255)


def new_canvas():
    return Image.new("RGBA", (SIZE, SIZE), TRANSPARENT)


# ── Base characters ───────────────────────────────────────────────────────────

def draw_frog(crown: bool, body_color, body_dark):
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.ellipse([28, 90, 228, 240], fill=body_color, outline=body_dark, width=4)
    d.ellipse([40, 30, 216, 170], fill=body_color, outline=body_dark, width=4)
    d.ellipse([56, 8, 116, 70],   fill=body_color, outline=body_dark, width=4)
    d.ellipse([140, 8, 200, 70],  fill=body_color, outline=body_dark, width=4)
    d.ellipse([66, 18, 106, 58],  fill=WHITE, outline=BLACK, width=3)
    d.ellipse([150, 18, 190, 58], fill=WHITE, outline=BLACK, width=3)
    d.ellipse([80, 30, 96, 50],   fill=BLACK)
    d.ellipse([164, 30, 180, 50], fill=BLACK)
    d.ellipse([54, 110, 90, 140],   fill=PINK)
    d.ellipse([166, 110, 202, 140], fill=PINK)
    d.arc([96, 90, 160, 150], start=20, end=160, fill=BLACK, width=5)
    if crown:
        d.polygon(
            [(78, 8), (98, -18), (118, 8), (138, -18), (158, 8), (178, -18), (198, 8)],
            fill=GOLD, outline=BLACK,
        )
        d.ellipse([120, 0, 140, 18], fill=HEART_RED, outline=BLACK)
    return img


def draw_dog():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.ellipse([34, 110, 222, 240],  fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=4)
    d.rectangle([60, 210, 88, 250],  fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=4)
    d.rectangle([170, 210, 198, 250], fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=4)
    d.ellipse([56, 30, 200, 170],   fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=4)
    d.ellipse([28, 40, 90, 130],    fill=GALLETA_BROWN_DARK, outline=BLACK, width=3)
    d.ellipse([166, 40, 228, 130],  fill=GALLETA_BROWN_DARK, outline=BLACK, width=3)
    d.ellipse([92, 100, 164, 160],  fill=BONE, outline=GALLETA_BROWN_DARK, width=3)
    d.ellipse([116, 110, 140, 130], fill=BLACK)
    d.ellipse([76, 66, 102, 92],    fill=WHITE, outline=BLACK, width=2)
    d.ellipse([154, 66, 180, 92],   fill=WHITE, outline=BLACK, width=2)
    d.ellipse([84, 74, 96, 86],     fill=BLACK)
    d.ellipse([162, 74, 174, 86],   fill=BLACK)
    d.arc([110, 130, 146, 156], start=10, end=170, fill=BLACK, width=4)
    d.ellipse([118, 144, 138, 162], fill=PINK)
    return img


def draw_dog_white():
    """White Galleta with pink bow — matches the real dog's appearance."""
    W  = (248, 245, 240, 255)   # off-white body
    D  = (180, 170, 160, 255)   # soft grey outline
    E  = (220, 215, 208, 255)   # ear fill
    EO = (160, 150, 140, 255)   # ear outline
    M  = (235, 225, 210, 255)   # muzzle cream (contrast on white)
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.ellipse([34, 110, 222, 240],  fill=W, outline=D, width=4)
    d.rectangle([60, 210, 88, 250],  fill=W, outline=D, width=4)
    d.rectangle([170, 210, 198, 250], fill=W, outline=D, width=4)
    d.ellipse([56, 30, 200, 170],   fill=W, outline=D, width=4)
    d.ellipse([28, 40, 90, 130],    fill=E, outline=EO, width=3)
    d.ellipse([166, 40, 228, 130],  fill=E, outline=EO, width=3)
    d.ellipse([92, 100, 164, 160],  fill=M, outline=D, width=3)
    d.ellipse([116, 110, 140, 130], fill=BLACK)
    d.ellipse([76, 66, 102, 92],    fill=WHITE, outline=BLACK, width=2)
    d.ellipse([154, 66, 180, 92],   fill=WHITE, outline=BLACK, width=2)
    d.ellipse([84, 74, 96, 86],     fill=BLACK)
    d.ellipse([162, 74, 174, 86],   fill=BLACK)
    d.arc([110, 130, 146, 156], start=10, end=170, fill=BLACK, width=4)
    d.ellipse([118, 144, 138, 162], fill=PINK)
    # Pink bow on top of head (between ears)
    cx = 128
    d.polygon([(cx, 30), (cx - 36, 12), (cx - 26, 50)], fill=PINK)
    d.polygon([(cx, 30), (cx + 36, 12), (cx + 26, 50)], fill=PINK)
    d.ellipse([cx - 8, 22, cx + 8, 38], fill=MAGENTA)
    return img


def draw_heart(color=HEART_RED, dark=HEART_RED_DARK, sparkle=True):
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.ellipse([28, 48, 144, 164],  fill=color, outline=dark, width=5)
    d.ellipse([112, 48, 228, 164], fill=color, outline=dark, width=5)
    d.polygon([(36, 122), (128, 232), (220, 122)], fill=color, outline=dark)
    d.polygon([(42, 110), (128, 220), (214, 110)], fill=color)
    return img


def draw_lilypad():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.ellipse([12, 90, 244, 200], fill=LILY, outline=LILY_DARK, width=5)
    d.polygon([(128, 145), (200, 90), (245, 145)], fill=LILY_DARK)
    d.polygon([(128, 145), (208, 96), (240, 142)], fill=LILY)
    for ang_dx, ang_dy in [(0, -20), (18, -8), (12, 12), (-12, 12), (-18, -8)]:
        d.ellipse(
            [80 + ang_dx, 80 + ang_dy, 110 + ang_dx, 110 + ang_dy],
            fill=PINK, outline=MAGENTA, width=2,
        )
    d.ellipse([86, 86, 104, 104], fill=YELLOW, outline=MAGENTA, width=2)
    return img


def draw_rock():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.polygon(
        [(40, 200), (60, 120), (110, 80), (170, 90), (210, 140), (220, 200)],
        fill=ROCK, outline=ROCK_DARK,
    )
    d.polygon([(90, 130), (130, 100), (160, 120), (130, 140)], fill=(150, 140, 150, 255))
    return img


def draw_bone():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([60, 110, 196, 150], radius=18, fill=BONE, outline=BONE_DARK, width=4)
    for cx, cy in [(60, 100), (60, 160), (196, 100), (196, 160)]:
        d.ellipse([cx - 30, cy - 30, cx + 30, cy + 30], fill=BONE, outline=BONE_DARK, width=4)
    return img


def draw_card_back():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([16, 16, 240, 240], radius=28, fill=PINK, outline=MAGENTA, width=6)
    d.rounded_rectangle([36, 36, 220, 220], radius=18, outline=WHITE, width=4)
    h = draw_heart(WHITE, WHITE, sparkle=False).resize((120, 120))
    img.paste(h, (68, 68), h)
    return img


def draw_music_note():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.ellipse([40, 160, 120, 220],  fill=MAGENTA, outline=BLACK, width=4)
    d.ellipse([160, 130, 240, 190], fill=MAGENTA, outline=BLACK, width=4)
    d.rectangle([114, 60, 130, 196],  fill=BLACK)
    d.rectangle([234, 30, 250, 162],  fill=BLACK)
    d.polygon([(114, 50), (250, 20), (250, 50), (114, 80)], fill=BLACK)
    return img


def draw_lara(outfit_color=MINT):
    img = new_canvas()
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([62, 170, 194, 250], radius=20, fill=outfit_color, outline=MAGENTA, width=4)
    h = draw_heart().resize((60, 60))
    img.paste(h, (98, 180), h)
    d.ellipse([60, 30, 196, 180],   fill=(255, 220, 190, 255), outline=BLACK, width=3)
    d.ellipse([46, 16, 210, 130],   fill=(80, 50, 35, 255), outline=BLACK, width=3)
    d.ellipse([60, 60, 196, 160],   fill=(255, 220, 190, 255))
    d.ellipse([90, 100, 112, 122],  fill=BLACK)
    d.ellipse([144, 100, 166, 122], fill=BLACK)
    d.ellipse([78, 128, 104, 148],  fill=PINK)
    d.ellipse([152, 128, 178, 148], fill=PINK)
    d.arc([100, 132, 156, 168], start=10, end=170, fill=BLACK, width=4)
    return img


# ── Lara Campos doll collectibles ─────────────────────────────────────────────

def lara_d1():
    """Muñeca Lara Original — pink metallic outfit, Rhenné frog scrunchie."""
    img = draw_lara(outfit_color=PINK)
    d = ImageDraw.Draw(img)
    # Rhenné frog scrunchie in hair (top-right)
    d.ellipse([176, 14, 212, 50], fill=RHENNE_GREEN, outline=RHENNE_GREEN_DARK, width=3)
    d.ellipse([186, 22, 198, 34], fill=WHITE)
    d.ellipse([189, 24, 196, 32], fill=BLACK)
    return img


def lara_d2():
    """Lara Concierto — magenta outfit, ponytail bun, microphone."""
    img = draw_lara(outfit_color=MAGENTA)
    d = ImageDraw.Draw(img)
    # Ponytail bun at top-right
    d.ellipse([188, 4, 228, 44], fill=(80, 50, 35, 255), outline=BLACK, width=2)
    # Microphone handle + head (right side of body)
    d.rounded_rectangle([172, 190, 188, 244], radius=4,
                         fill=(180, 180, 180, 255), outline=BLACK, width=2)
    d.ellipse([162, 178, 198, 204], fill=(120, 120, 120, 255), outline=BLACK, width=2)
    return img


def lara_d3():
    """Lara Corazón — yellow outfit, heart crown, hearts on dress."""
    img = draw_lara(outfit_color=YELLOW)
    d = ImageDraw.Draw(img)
    # 3-heart crown at very top of head
    tiny = draw_heart(HEART_RED, HEART_RED_DARK).resize((26, 26), Image.LANCZOS)
    for off in (-26, 0, 26):
        img.paste(tiny, (128 + off - 13, 1), tiny)
    # Gold band below hearts
    d.rectangle([62, 26, 194, 34], fill=GOLD)
    # Small hearts scattered on the yellow outfit
    for hx, hy in [(83, 197), (156, 208), (120, 226)]:
        th = draw_heart(MAGENTA, HEART_RED_DARK).resize((20, 20), Image.LANCZOS)
        img.paste(th, (hx - 10, hy - 10), th)
    return img


# ── Accessory helpers ─────────────────────────────────────────────────────────

def add_sunglasses(d, lcx, lcy, rcx, rcy, lw=23, lh=18):
    """Cool dark tinted sunglasses."""
    d.ellipse([lcx-lw, lcy-lh, lcx+lw, lcy+lh], fill=SUNGLASS_LENS, outline=SUNGLASS_FRAME, width=3)
    d.ellipse([rcx-lw, rcy-lh, rcx+lw, rcy+lh], fill=SUNGLASS_LENS, outline=SUNGLASS_FRAME, width=3)
    d.line([(lcx+lw, lcy), (rcx-lw, rcy)], fill=SUNGLASS_FRAME, width=3)
    d.line([(lcx-lw, lcy), (lcx-lw-28, lcy+8)], fill=SUNGLASS_FRAME, width=2)
    d.line([(rcx+lw, rcy), (rcx+lw+28, rcy+8)], fill=SUNGLASS_FRAME, width=2)


def add_fedora(d, cx, base_y, brim_hw=108, crown_hw=48, crown_h=44):
    """Wide-brimmed felt fedora."""
    d.ellipse([cx-brim_hw, base_y-14, cx+brim_hw, base_y+8],
              fill=FEDORA_FELT, outline=FEDORA_DARK, width=3)
    d.rounded_rectangle([cx-crown_hw, base_y-crown_h-14, cx+crown_hw, base_y+2],
                         radius=12, fill=FEDORA_FELT, outline=FEDORA_DARK, width=3)
    d.rectangle([cx-crown_hw, base_y-18, cx+crown_hw, base_y-8], fill=FEDORA_BAND)
    d.arc([cx-28, base_y-crown_h-8, cx+28, base_y-crown_h+10],
          start=0, end=180, fill=FEDORA_DARK, width=3)


def add_nerd_glasses(d, lcx, lcy, rcx, rcy, r=24):
    """Round thick-framed nerd glasses with tape on the bridge."""
    d.ellipse([lcx-r, lcy-r, lcx+r, lcy+r], fill=NERD_LENS, outline=NERD_FRAME, width=5)
    d.ellipse([rcx-r, rcy-r, rcx+r, rcy+r], fill=NERD_LENS, outline=NERD_FRAME, width=5)
    d.line([(lcx+r, lcy), (rcx-r, rcy)], fill=NERD_FRAME, width=4)
    mid = (lcx + rcx) // 2
    d.rectangle([mid-7, lcy-5, mid+7, lcy+5], fill=WHITE, outline=(180, 180, 180, 255), width=1)
    d.line([(lcx-r, lcy), (lcx-r-30, lcy+5)], fill=NERD_FRAME, width=3)
    d.line([(rcx+r, rcy), (rcx+r+30, rcy+5)], fill=NERD_FRAME, width=3)


def add_bavarian_hat(d, cx, base_y, brim_hw=64, crown_hw=42, crown_h=34):
    """Green Bavarian/Oktoberfest alpine hat with feather."""
    d.ellipse([cx-brim_hw, base_y-12, cx+brim_hw, base_y+6],
              fill=BAVARIA_HAT, outline=BAVARIA_DARK, width=3)
    d.rounded_rectangle([cx-crown_hw, base_y-crown_h-12, cx+crown_hw, base_y+2],
                         radius=8, fill=BAVARIA_HAT, outline=BAVARIA_DARK, width=3)
    d.rectangle([cx-crown_hw, base_y-16, cx+crown_hw, base_y-8], fill=BAVARIA_BAND)
    fx0, fy0 = cx + crown_hw - 8, base_y - 14
    for i in range(7):
        d.line([(fx0 + i*3, fy0 - i*7), (fx0 + i*3 - 5, fy0 - i*7 - 14)],
               fill=FEATHER, width=max(1, 3 - i // 2))


def add_lederhosen(d, cx=128, strap_top=120, strap_bot=210):
    """Leather suspender straps (Lederhosen) over the body."""
    for sx, ex in [(cx-40, cx-14), (cx+40, cx+14)]:
        d.line([(sx, strap_top), (ex, strap_bot)], fill=LEDER_BROWN, width=10)
        d.line([(sx, strap_top), (ex, strap_bot)], fill=LEDER_DARK,  width=2)
    mid_y = strap_top + 36
    d.rectangle([cx-32, mid_y, cx+32, mid_y+14], fill=LEDER_BROWN, outline=LEDER_DARK, width=2)
    d.ellipse([cx-7, mid_y-1, cx+7, mid_y+15], fill=GOLD, outline=LEDER_DARK, width=2)


# ── Collectible level sprites ─────────────────────────────────────────────────
# Rhenné — eye centres: left (86, 38), right (170, 38); hat sits at base_y≈16

def rhenne_l1():
    return draw_frog(crown=False, body_color=RHENNE_GREEN, body_dark=RHENNE_GREEN_DARK)

def rhenne_l2():
    img = draw_frog(crown=False, body_color=RHENNE_GREEN, body_dark=RHENNE_GREEN_DARK)
    add_sunglasses(ImageDraw.Draw(img), 86, 38, 170, 38, lw=24, lh=19)
    return img

def _rhenne_hat_canvas():
    """Frog scaled to 82% and pasted at bottom-centre, leaving ~47 px at top for hat crown."""
    frog = draw_frog(crown=False, body_color=RHENNE_GREEN, body_dark=RHENNE_GREEN_DARK)
    scale = 0.82
    sz = int(SIZE * scale)               # 209
    frog_sc = frog.resize((sz, sz), Image.LANCZOS)
    img = new_canvas()
    xo = (SIZE - sz) // 2               # 23
    yo = SIZE - sz                       # 47
    img.paste(frog_sc, (xo, yo), frog_sc)
    return img, yo, scale


def rhenne_l3():
    img, yo, scale = _rhenne_hat_canvas()
    # Hat brim sits at top of scaled eye bumps (canvas y ≈ yo + 8*scale = 53).
    add_fedora(ImageDraw.Draw(img), cx=128, base_y=53, brim_hw=94, crown_hw=44, crown_h=44)
    return img

def rhenne_l4():
    img = draw_frog(crown=False, body_color=RHENNE_GREEN, body_dark=RHENNE_GREEN_DARK)
    add_nerd_glasses(ImageDraw.Draw(img), 86, 38, 170, 38, r=24)
    return img

def rhenne_l5():
    img, yo, scale = _rhenne_hat_canvas()
    d = ImageDraw.Draw(img)
    add_bavarian_hat(d, cx=128, base_y=53, brim_hw=56, crown_hw=36, crown_h=40)
    add_lederhosen(d, cx=128,
                   strap_top=yo + int(124 * scale),  # ≈ 149
                   strap_bot=yo + int(212 * scale))   # ≈ 221
    return img


# Galleta — eye centres: left (89, 79), right (167, 79); hat sits at base_y≈38

def galleta_l1():
    return draw_dog_white()

def galleta_l2():
    img = draw_dog_white()
    add_sunglasses(ImageDraw.Draw(img), 89, 79, 167, 79, lw=19, lh=15)
    return img

def galleta_l3():
    img = draw_dog_white()
    add_fedora(ImageDraw.Draw(img), cx=128, base_y=38, brim_hw=102, crown_hw=46, crown_h=44)
    return img

def galleta_l4():
    img = draw_dog_white()
    add_nerd_glasses(ImageDraw.Draw(img), 89, 79, 167, 79, r=18)
    return img

def galleta_l5():
    img = draw_dog_white()
    d = ImageDraw.Draw(img)
    add_bavarian_hat(d, cx=128, base_y=38, brim_hw=64, crown_hw=42, crown_h=34)
    add_lederhosen(d, cx=128, strap_top=128, strap_bot=220)
    return img


# Corazón — accessories float just above/on the upper lobes (base_y≈44, glasses at y≈82)

def corazon_l1():
    return draw_heart()

def corazon_l2():
    img = draw_heart()
    add_sunglasses(ImageDraw.Draw(img), 90, 82, 166, 82, lw=22, lh=16)
    return img

def corazon_l3():
    img = draw_heart()
    add_fedora(ImageDraw.Draw(img), cx=128, base_y=44, brim_hw=100, crown_hw=44, crown_h=40)
    return img

def corazon_l4():
    img = draw_heart()
    add_nerd_glasses(ImageDraw.Draw(img), 90, 82, 166, 82, r=22)
    return img

def corazon_l5():
    img = draw_heart()
    d = ImageDraw.Draw(img)
    add_bavarian_hat(d, cx=128, base_y=44, brim_hw=64, crown_hw=42, crown_h=36)
    add_lederhosen(d, cx=128, strap_top=110, strap_bot=210)
    return img


def bird_enemy() -> Image.Image:
    """Vivid red+yellow diving bird with beak pointing downward (toward the player)."""
    W = 78
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = W // 2, W // 2

    BODY   = (235, 64, 88, 255)   # corazonRed
    BODY_D = (180, 30, 60, 255)
    WING   = (255, 214, 64, 255)  # yellow
    WING_E = (190, 130, 40, 200)  # wing edge shadow
    BEAK   = (255, 214, 64, 255)  # yellow
    EYE    = (255, 255, 255, 255)
    PUPIL  = (20, 20, 30, 255)

    # Wings spread wide (left and right, drawn behind body)
    d.polygon([(cx, cy - 6), (2, cy - 24), (cx - 6, cy + 12)], fill=WING)
    d.polygon([(cx, cy - 6), (W - 2, cy - 24), (cx + 6, cy + 12)], fill=WING)
    d.line([(cx, cy - 6), (2, cy - 24)], fill=WING_E, width=2)
    d.line([(cx, cy - 6), (W - 2, cy - 24)], fill=WING_E, width=2)

    # Body (oval, slightly taller than wide)
    d.ellipse([cx - 15, cy - 18, cx + 15, cy + 18], fill=BODY, outline=BODY_D, width=2)

    # Chest highlight
    d.ellipse([cx - 4, cy - 8, cx + 6, cy + 2], fill=(255, 92, 168, 140))

    # Beak pointing straight down
    d.polygon([
        (cx - 5, cy + 16),
        (cx + 5, cy + 16),
        (cx,     cy + 30),
    ], fill=BEAK)

    # Eye (right of centre for perspective)
    ex = cx + 3
    d.ellipse([ex - 5, cy - 16, ex + 5, cy - 8], fill=EYE)
    d.ellipse([ex - 3, cy - 14, ex + 3, cy - 10], fill=PUPIL)

    # Angry eyebrow
    d.line([(ex - 6, cy - 20), (ex + 5, cy - 17)], fill=PUPIL, width=2)

    return img


def draw_water_rock() -> Image.Image:
    """Rounded blue-grey wet stone for water-based levels (Rhenné Corre)."""
    W = 78
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    BODY   = (110, 130, 160, 255)  # blue-grey
    BORDER = (70, 90, 115, 255)    # darker border
    MID    = (140, 160, 185, 255)  # lighter mid-tone for volume

    # Main rounded body
    d.ellipse([8, 16, 70, 66], fill=BODY, outline=BORDER, width=3)
    # Mid-tone area for 3D depth
    d.ellipse([18, 24, 58, 56], fill=MID)
    # White wet-sheen highlight at top-left
    d.arc([14, 20, 36, 38], start=200, end=320, fill=(240, 245, 255, 200), width=4)

    return img


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    artworks = {
        # Game sprites (unchanged)
        "bird_enemy.png":   bird_enemy(),
        "rhenne.png":       draw_frog(crown=False, body_color=RHENNE_GREEN, body_dark=RHENNE_GREEN_DARK),
        "reina.png":        draw_frog(crown=True,  body_color=PINK,         body_dark=MAGENTA),
        "galleta.png":      draw_dog_white(),
        "corazon.png":      draw_heart(),
        "corazon_pink.png": draw_heart(PINK, MAGENTA),
        "corazon_yellow.png": draw_heart(YELLOW, (210, 160, 30, 255)),
        "lilypad.png":      draw_lilypad(),
        "obstacle_rock.png": draw_rock(),
        "obstacle_water_rock.png": draw_water_rock(),
        "treat_bone.png":   draw_bone(),
        "card_back.png":    draw_card_back(),
        "music_note.png":   draw_music_note(),
        "lara.png":         draw_lara(),
        # Rhenné collectible levels
        "rhenne_l1.png": rhenne_l1(),
        "rhenne_l2.png": rhenne_l2(),
        "rhenne_l3.png": rhenne_l3(),
        "rhenne_l4.png": rhenne_l4(),
        "rhenne_l5.png": rhenne_l5(),
        # Galleta collectible levels
        "galleta_l1.png": galleta_l1(),
        "galleta_l2.png": galleta_l2(),
        "galleta_l3.png": galleta_l3(),
        "galleta_l4.png": galleta_l4(),
        "galleta_l5.png": galleta_l5(),
        # Corazón collectible levels
        "corazon_l1.png": corazon_l1(),
        "corazon_l2.png": corazon_l2(),
        "corazon_l3.png": corazon_l3(),
        "corazon_l4.png": corazon_l4(),
        "corazon_l5.png": corazon_l5(),
        # Lara Campos doll collectibles
        "lara_d1.png": lara_d1(),
        "lara_d2.png": lara_d2(),
        "lara_d3.png": lara_d3(),
    }
    for name, im in artworks.items():
        path = OUT / name
        im.save(path)
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
