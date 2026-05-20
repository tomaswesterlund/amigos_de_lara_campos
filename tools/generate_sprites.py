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


def draw_collectibles_icon():
    """Combined icon: Rhenné (left), Galleta (right), Corazón heart (front-centre)."""
    img = new_canvas()
    frog = draw_frog(crown=False, body_color=RHENNE_GREEN, body_dark=RHENNE_GREEN_DARK)
    frog = frog.resize((136, 136), Image.LANCZOS)
    img.paste(frog, (0, 16), frog)
    dog = draw_dog_white()
    dog = dog.resize((136, 136), Image.LANCZOS)
    img.paste(dog, (120, 16), dog)
    heart = draw_heart()
    heart = heart.resize((96, 96), Image.LANCZOS)
    img.paste(heart, (80, 160), heart)
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


def _algae_frond(d, base_x, base_y, sway):
    """Leaf-shaped 6-point polygon anchored at base, tip bends sway px horizontally."""
    ALGAE = ( 52, 152, 110, 220)
    ALDAR = ( 30, 102,  74, 220)
    tip_x = base_x + sway
    tip_y = base_y - 12
    pts = [
        (base_x,      base_y),
        (base_x - 5,  base_y - 4),
        (tip_x  - 3,  tip_y  + 3),
        (tip_x,       tip_y),
        (tip_x  + 3,  tip_y  + 3),
        (base_x + 5,  base_y - 4),
    ]
    d.polygon(pts, fill=ALGAE, outline=ALDAR, width=1)


def draw_water_rock(frame: int) -> Image.Image:
    """
    Irregular wet stone obstacle for Rhenné Nada. 78×78, 4-frame sprite sheet.
    UnderwaterRock combines this animation (stepTime=0.4s, 1.6s cycle) with a
    Flame ScaleEffect.by(1.02) breathing pulse at runtime.

    All 4 frames share identical rock body, lighting facets, barnacles, cracks,
    outline and specular. Per-frame differences:
      — Algae fronds sway: F1=+5px right, F2=neutral, F3=-5px left, F4=+2px
      — Rising bubble from main crack: F1=low, F2=mid, F3=high, F4=none
    """
    W = 78
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)

    MID   = ( 88,  98, 120, 255)   # slate blue-grey base
    DARK  = ( 52,  60,  78, 255)   # deep shadow / outline
    SHAD  = ( 60,  68,  88, 255)   # shadow facet (lower-right)
    LITE  = (118, 136, 168, 255)   # highlight facet (upper-left)
    ALGAE = ( 52, 152, 110, 220)   # teal algae
    ALDAR = ( 30, 102,  74, 220)   # algae dark edge
    BARN  = (158, 154, 142, 255)   # barnacle cream
    BDRK  = (108, 103,  92, 255)   # barnacle dark
    CRACK = ( 40,  46,  62, 195)   # crack line
    SHEEN = (215, 232, 255, 240)   # wet specular

    # ── 1. ROCK BODY — lumpy 11-point polygon ─────────────────────────────────
    rock = [
        (20, 14),   # top-left
        (36,  8),   # top peak
        (52, 12),   # top-right
        (66, 24),   # right upper
        (70, 40),   # right max
        (64, 56),   # right lower
        (48, 64),   # bottom-right
        (28, 62),   # bottom center
        (12, 52),   # left lower
        ( 8, 34),   # left max
        (12, 20),   # left upper
    ]
    d.polygon(rock, fill=MID)

    # ── 2. SHADOW FACET — lower-right third (light from upper-left) ───────────
    d.polygon([
        (38, 36),
        (66, 24), (70, 40), (64, 56), (48, 64), (28, 62), (12, 52),
        (20, 44),
    ], fill=SHAD)

    # ── 3. HIGHLIGHT FACET — upper-left third ─────────────────────────────────
    d.polygon([
        (38, 36), (20, 44), (12, 20),
        (20, 14), (36,  8), (52, 12), (60, 26), (46, 30),
    ], fill=LITE)

    # ── 4. ALGAE FRONDS — leaf polygons sway per frame ───────────────────────
    sway = {1: +5, 2: 0, 3: -5, 4: +2}[frame]
    for bx, by in [(22, 64), (38, 65), (54, 62)]:
        _algae_frond(d, bx, by, sway)

    # ── 5. BARNACLE CLUSTERS on the lit upper face ────────────────────────────
    for bx, by in [(30, 24), (42, 18), (54, 24), (38, 32), (50, 32), (26, 34)]:
        d.ellipse([bx-4, by-3, bx+4, by+3], fill=BARN, outline=BDRK, width=1)
        d.ellipse([bx-1, by-1, bx+1, by+1], fill=BDRK)   # central pore

    # ── 6. SURFACE CRACKS (Y-shaped + second fracture) ────────────────────────
    d.line([(30, 28), (46, 46)], fill=CRACK, width=2)   # main crack
    d.line([(46, 46), (58, 40)], fill=CRACK, width=1)   # branch right
    d.line([(46, 46), (44, 56)], fill=CRACK, width=1)   # branch down
    d.line([(52, 22), (62, 38)], fill=CRACK, width=2)   # second crack

    # ── 7. ROCK OUTLINE — drawn last to sharpen the silhouette ────────────────
    d.polygon(rock, fill=None, outline=DARK, width=3)

    # ── 7b. RISING BUBBLE — from main crack, present in frames 1-3 ───────────
    bubble_pos = {1: (43, 44), 2: (41, 38), 3: (39, 31), 4: None}[frame]
    if bubble_pos is not None:
        bx, by = bubble_pos
        BUBBLE = (210, 240, 255, 200)
        d.ellipse([bx-2, by-2, bx+2, by+2], fill=BUBBLE, outline=SHEEN, width=1)

    # ── 8. WET SPECULAR HIGHLIGHT ─────────────────────────────────────────────
    # Arc 195°→330° clockwise traces upper portion of oval = top-left glance.
    d.arc([10, 12, 38, 32], start=195, end=330, fill=SHEEN, width=5)
    d.arc([14, 16, 28, 26], start=210, end=320, fill=WHITE, width=3)   # hot spot

    return img


def draw_coin() -> Image.Image:
    """78×78 yellow coin pickup with gold border and shine highlight."""
    import math
    W = 78
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy, r = W // 2, W // 2, 30
    d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=YELLOW, outline=GOLD, width=3)
    d.ellipse([cx-r+6, cy-r+6, cx+r-6, cy+r-6], outline=GOLD, width=2)
    d.arc([cx-r+4, cy-r+4, cx-2, cy-2], start=200, end=320, fill=WHITE, width=4)
    star_pts = []
    for i in range(8):
        angle = i * 45 - 90
        radius = 7 if i % 2 == 0 else 3
        star_pts.append((cx + radius * math.cos(math.radians(angle)),
                         cy + radius * math.sin(math.radians(angle))))
    d.polygon(star_pts, fill=WHITE)
    return img


def draw_reed() -> Image.Image:
    """Water cattail / totora for Rhenné Corre pond decoration."""
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # Brown vertical stem
    d.rectangle([118, 95, 138, 250], fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=2)
    # Dark cattail head (oval)
    d.ellipse([100, 28, 156, 120], fill=(72, 46, 18, 255), outline=(50, 30, 10, 255), width=3)
    d.ellipse([108, 22, 148, 52], fill=(56, 34, 12, 255))
    # Thin green leaves
    d.rectangle([84, 150, 98, 230], fill=LILY_DARK)
    d.rectangle([158, 160, 172, 235], fill=LILY_DARK)
    return img


def draw_water_flower() -> Image.Image:
    """Lotus-style water flower for Rhenné Corre pond decoration."""
    import math
    img = new_canvas()
    d = ImageDraw.Draw(img)
    cx, cy = 128, 150
    for i in range(8):
        angle = math.radians(i * 45)
        px = cx + int(46 * math.cos(angle))
        py = cy + int(46 * math.sin(angle))
        d.ellipse([px - 24, py - 24, px + 24, py + 24], fill=PINK, outline=MAGENTA, width=2)
    d.ellipse([72, 108, 184, 192], fill=LILY, outline=LILY_DARK, width=3)
    d.ellipse([108, 130, 148, 170], fill=YELLOW, outline=GOLD, width=2)
    return img


# ── Rhenné Nada swimming sprites ─────────────────────────────────────────────

FISH_ORANGE = (255, 140, 0, 255)
FISH_YELLOW = (255, 210, 60, 255)
FISH_STRIPE = (30, 30, 30, 200)
JELLY_PINK  = (255, 130, 200, 160)
JELLY_DARK  = (220, 80, 160, 220)
JELLY_TENT  = (200, 100, 170, 180)
_LIMB_OUTLINE = (40, 100, 30, 255)


def _webbed_appendage(d, cx, cy, ray, spread_deg, num_toes, dir_deg, color, outline):
    """Fan-shaped webbed hand or foot pointing in dir_deg direction."""
    import math
    dir_rad = math.radians(dir_deg)
    half    = math.radians(spread_deg / 2)
    step    = math.radians(spread_deg) / max(1, num_toes - 1)
    pts = [(cx, cy)]
    for i in range(num_toes):
        a = dir_rad - half + step * i
        pts.append((cx + ray * math.cos(a), cy + ray * math.sin(a)))
    pts.append((cx, cy))
    d.polygon(pts, fill=color, outline=outline)


def _limb(d, x0, y0, x1, y1, thickness, color, outline):
    """Tapered trapezoid limb (wide root → thin tip) + joint circle at root."""
    import math
    dx, dy = x1 - x0, y1 - y0
    length = math.hypot(dx, dy)
    if length < 1:
        return
    nx, ny = -dy / length, dx / length
    hw0, hw1 = thickness * 0.55, thickness * 0.25
    pts = [
        (x0 + nx * hw0, y0 + ny * hw0),
        (x1 + nx * hw1, y1 + ny * hw1),
        (x1 - nx * hw1, y1 - ny * hw1),
        (x0 - nx * hw0, y0 - ny * hw0),
    ]
    d.polygon(pts, fill=color, outline=outline)
    d.ellipse([x0 - hw0, y0 - hw0, x0 + hw0, y0 + hw0], fill=color, outline=outline)


def draw_rhenne_swim(frame: int) -> Image.Image:
    """
    4-frame breaststroke cycle.
    Layer order: hind legs → fore arms → body → belly highlight → eye bumps → face.
    This puts joint roots behind the body so limbs look naturally attached.
    """
    import math

    BODY  = RHENNE_GREEN
    DARK  = RHENNE_GREEN_DARK
    BELLY = (148, 220, 128, 200)   # lighter tint for volume

    img = new_canvas()
    d   = ImageDraw.Draw(img)

    # Shoulder and hip roots (at the edges of the body ellipses)
    SHL = (42,  132)   # left shoulder
    SHR = (214, 132)   # right shoulder
    HIL = (72,  218)   # left hip
    HIR = (184, 218)   # right hip

    # Per-frame limb tip positions — 4-phase breaststroke
    poses = {
        1: dict(larm=(8,  108), rarm=(248, 108), lleg=(72,  255), rleg=(184, 255)),  # Glide
        2: dict(larm=(5,  155), rarm=(251, 155), lleg=(28,  248), rleg=(228, 248)),  # Pull
        3: dict(larm=(25, 180), rarm=(231, 180), lleg=(8,   226), rleg=(248, 226)),  # Kick
        4: dict(larm=(10, 120), rarm=(246, 120), lleg=(55,  255), rleg=(201, 255)),  # Snap
    }
    p = poses[frame]

    def _dir(root, tip):
        return math.degrees(math.atan2(tip[1] - root[1], tip[0] - root[0]))

    # ── 1. HIND LEGS — drawn first (behind body) ─────────────────────────────
    _limb(d, *SHL, *p['larm'], 24, DARK, _LIMB_OUTLINE)
    _limb(d, *SHR, *p['rarm'], 24, DARK, _LIMB_OUTLINE)
    _webbed_appendage(d, *p['larm'], ray=22, spread_deg=55, num_toes=3,
                      dir_deg=_dir(SHL, p['larm']), color=DARK, outline=_LIMB_OUTLINE)
    _webbed_appendage(d, *p['rarm'], ray=22, spread_deg=55, num_toes=3,
                      dir_deg=_dir(SHR, p['rarm']), color=DARK, outline=_LIMB_OUTLINE)

    # ── 2. FORE ARMS — drawn before body (joint roots covered by body) ────────
    _limb(d, *HIL, *p['lleg'], 30, DARK, _LIMB_OUTLINE)
    _limb(d, *HIR, *p['rleg'], 30, DARK, _LIMB_OUTLINE)
    _webbed_appendage(d, *p['lleg'], ray=28, spread_deg=70, num_toes=4,
                      dir_deg=_dir(HIL, p['lleg']), color=DARK, outline=_LIMB_OUTLINE)
    _webbed_appendage(d, *p['rleg'], ray=28, spread_deg=70, num_toes=4,
                      dir_deg=_dir(HIR, p['rleg']), color=DARK, outline=_LIMB_OUTLINE)

    # ── 3. BODY ON TOP — covers joint roots naturally ─────────────────────────
    d.ellipse([28, 90, 228, 240],  fill=BODY, outline=DARK, width=4)   # belly
    d.ellipse([40, 30, 216, 170],  fill=BODY, outline=DARK, width=4)   # torso
    d.ellipse([70, 128, 186, 218], fill=BELLY)                          # belly highlight

    # ── 4. EYE BUMPS ─────────────────────────────────────────────────────────
    d.ellipse([56,  8, 116, 70], fill=BODY, outline=DARK, width=4)
    d.ellipse([140, 8, 200, 70], fill=BODY, outline=DARK, width=4)

    # ── 5. FACE DETAILS ───────────────────────────────────────────────────────
    d.ellipse([66,  18, 106, 58], fill=WHITE, outline=BLACK, width=3)
    d.ellipse([150, 18, 190, 58], fill=WHITE, outline=BLACK, width=3)
    d.ellipse([80,  30,  96, 50], fill=BLACK)
    d.ellipse([164, 30, 180, 50], fill=BLACK)
    # Eye shine
    d.ellipse([ 82, 32,  90, 40], fill=WHITE)
    d.ellipse([166, 32, 174, 40], fill=WHITE)
    # Cheeks
    d.ellipse([ 54, 110,  90, 140], fill=PINK)
    d.ellipse([166, 110, 202, 140], fill=PINK)
    # Mouth — wider grin on the power/kick frame
    if frame == 3:
        d.arc([88, 88, 168, 156], start=25, end=155, fill=BLACK, width=6)
    else:
        d.arc([96, 90, 160, 150], start=20, end=160, fill=BLACK, width=5)

    return img


def draw_fish(frame: int) -> Image.Image:
    """
    4-frame swim cycle. Chunky cute tropical fish, 78×78.
    Head on LEFT (eye/mouth at x≈4-22). Tail fan on RIGHT (x=62→76).
    SwimmingFish.onLoad applies scale.x=-1 so the fish faces LEFT in-game.

    Animation cycle — 4 truly distinct poses:
      F1 — tail MAX UP   (peduncle y=27, tip y=6)
      F2 — center→DOWN   (peduncle y=40, tip y=22)
      F3 — tail MAX DOWN (peduncle y=53, tip y=71)
      F4 — center→UP     (peduncle y=34, tip y=14)
    Tail sweeps ≈65px vertically vs the prior ≈14px.
    Rear-body taper polygon bends toward peduncle for genuine body flex.
    Big anime eye (18×22px) with two-tone shine, gill arc, fin rays, scale dots.
    """
    import math
    W = 78
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)

    BODY   = (255, 138,  20, 255)   # warm orange
    DARK   = (195,  68,   0, 255)   # shadow / outline
    SHADE  = (220,  90,   8, 135)   # darker dorsal tint (semi-transparent)
    BELLY  = (255, 215, 140, 255)   # belly highlight
    FIN    = (255, 218,  55, 255)   # yellow fins / tail
    FOUT   = (190, 125,   0, 200)   # fin outline
    STRIPE = ( 28,  12,   4, 225)   # dark body stripe
    EW     = (255, 255, 255, 255)   # eye white
    ED     = ( 22,  18,  30, 255)   # eye dark

    # Per-frame: py=peduncle_y, tu=tail-upper-tip-y, tl=tail-lower-tip-y,
    #            pec=pectoral-fin-tip, dp=dorsal-peak-(x,y)
    poses = {
        1: dict(py=27, tu= 6, tl=42, pec=(13, 62), dp=(36,  6)),  # tail UP
        2: dict(py=40, tu=22, tl=56, pec=(11, 60), dp=(38, 10)),  # center→DOWN
        3: dict(py=53, tu=37, tl=71, pec=(13, 60), dp=(40,  8)),  # tail DOWN
        4: dict(py=34, tu=14, tl=50, pec=(14, 63), dp=(35,  7)),  # center→UP
    }
    p  = poses[frame]
    py = p['py']
    px = 62   # peduncle x (fixed)

    # ── TAIL (drawn first — farthest back in scene) ───────────────────────────
    d.polygon([(px-3, py-5), (W-2, p['tu']), (px+3, py+4)],
              fill=FIN, outline=FOUT)                               # upper lobe
    d.polygon([(px-3, py+5), (W-2, p['tl']), (px+3, py-4)],
              fill=FIN, outline=FOUT)                               # lower lobe
    ctail = (p['tu'] + p['tl']) // 2
    d.line([(px+2, py),   (W-5, ctail)],      fill=FOUT, width=1)  # center ray
    d.line([(px,   py-3), (W-6, p['tu']+5)],  fill=FOUT, width=1)  # upper ray
    d.line([(px,   py+3), (W-6, p['tl']-5)],  fill=FOUT, width=1)  # lower ray

    # ── REAR BODY TAPER (bends toward peduncle — shows body flexing) ──────────
    # Connects the fixed body oval's right edge (x≈50) to the moving peduncle.
    d.polygon([(50, 26), (px, py-7), (px, py+7), (50, 52)], fill=BODY)
    d.line([(50, 26), (px, py-7)], fill=DARK, width=2)             # top taper edge
    d.line([(50, 52), (px, py+7)], fill=DARK, width=2)             # bot taper edge
    d.ellipse([px-7, py-7, px+7, py+7], fill=BODY)                 # smooth peduncle

    # ── PECTORAL FIN (behind body, protrudes below-left) ─────────────────────
    d.polygon([(26, 46), p['pec'], (34, 56)], fill=FIN, outline=FOUT)

    # ── MAIN BODY — teardrop: large head circle + oval body ──────────────────
    d.ellipse([ 4, 22, 54, 56], fill=BODY, outline=DARK, width=2)  # body oval
    d.ellipse([ 2, 20, 38, 58], fill=BODY, outline=DARK, width=2)  # head circle

    # ── DORSAL SHADING — darker top half gives volume ─────────────────────────
    d.ellipse([ 8, 22, 50, 36], fill=SHADE)

    # ── BELLY HIGHLIGHT ───────────────────────────────────────────────────────
    d.ellipse([ 6, 44, 42, 60], fill=BELLY)

    # ── DORSAL FIN (tilts with animation) ────────────────────────────────────
    dpx, dpy = p['dp']
    d.polygon([(24, 22), (dpx, dpy), (52, 22)], fill=FIN, outline=FOUT)
    d.line([(29, 22), (dpx-4, dpy+4)], fill=FOUT, width=1)
    d.line([(38, 22), (dpx,   dpy+2)], fill=FOUT, width=1)
    d.line([(47, 22), (dpx+4, dpy+4)], fill=FOUT, width=1)

    # ── STRIPES ───────────────────────────────────────────────────────────────
    d.rounded_rectangle([27, 24, 33, 55], radius=3, fill=STRIPE)
    d.rounded_rectangle([39, 24, 45, 55], radius=3, fill=STRIPE)

    # ── GILL ARC ──────────────────────────────────────────────────────────────
    # Clockwise 90°→270° traces the LEFT semicircle — C-shape opening right.
    d.arc([26, 30, 38, 52], start=90, end=270, fill=DARK, width=2)

    # ── SCALE TEXTURE (subtle arc dots) ──────────────────────────────────────
    for sx, sy in [(22, 37), (30, 32), (38, 35), (30, 44), (38, 46)]:
        d.ellipse([sx-3, sy-2, sx+3, sy+2], outline=(195, 68, 0, 55), width=1)

    # ── EYE (large, anime-style — big sclera, chunky pupil, two shines) ──────
    d.ellipse([ 4, 24, 22, 46], fill=EW, outline=DARK, width=2)    # sclera
    d.ellipse([ 7, 27, 19, 43], fill=ED)                            # pupil
    d.ellipse([ 7, 27, 14, 34], fill=EW)                            # main shine
    d.ellipse([15, 39, 18, 42], fill=EW)                            # accent shine

    # ── MOUTH ─────────────────────────────────────────────────────────────────
    d.arc([ 3, 44, 15, 54], start=20, end=160, fill=DARK, width=2)

    return img


def draw_jellyfish(frame: int) -> Image.Image:
    """4-frame pulse cycle. Pink translucent dome with 5 curved tentacles, 78×78."""
    W  = 78
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)

    r       = {1: 26, 2: 32, 3: 28, 4: 30}[frame]
    cx, cy  = 39, 26   # moved up to give tentacles more room

    # Per-frame tentacle lengths and mid-point bend offsets (5 tentacles)
    x_positions = [cx-18, cx-9, cx, cx+9, cx+18]
    lengths = {1: [28, 32, 26, 32, 28], 2: [34, 38, 30, 38, 34],
               3: [30, 34, 28, 34, 30], 4: [32, 36, 29, 36, 32]}[frame]
    bends   = {1: [-4, +2, 0, -2, +4], 2: [+5, -3, +1, +3, -5],
               3: [-3, +4, -1, -4, +3], 4: [+3, -2, +2, +2, -3]}[frame]

    # ── TENTACLES (drawn first, behind dome) ─────────────────────────────────
    for tx, tlen, tbend in zip(x_positions, lengths, bends):
        top_y = cy + r
        mid_y = int(top_y + tlen * 0.5)
        bot_y = int(top_y + tlen)
        mid_x = int(tx + tbend)
        d.line([(tx, top_y), (mid_x, mid_y)], fill=JELLY_TENT, width=3)
        d.line([(mid_x, mid_y), (tx, bot_y)],
               fill=(*JELLY_TENT[:3], 140), width=2)

    # ── OUTER GLOW ────────────────────────────────────────────────────────────
    gr = r + 4
    d.pieslice([cx-gr, cy-gr, cx+gr, cy+gr],
               start=180, end=360, fill=(255, 160, 220, 45))

    # ── DOME ──────────────────────────────────────────────────────────────────
    d.pieslice([cx-r, cy-r, cx+r, cy+r],
               start=180, end=360, fill=JELLY_PINK, outline=JELLY_DARK, width=2)

    # Inner highlight (translucent volume)
    hr = max(8, r - 8)
    d.pieslice([cx-hr, cy-hr, cx+hr, cy+hr],
               start=190, end=340, fill=(255, 180, 230, 80))

    # Bioluminescent spots
    d.ellipse([cx-12, cy-4, cx-5, cy+3], fill=(255, 160, 220, 130))
    d.ellipse([cx+4,  cy-6, cx+11, cy+1], fill=(255, 160, 220, 130))

    return img


def draw_seashell() -> Image.Image:
    """78×78 golden seashell collectible."""
    import math
    W = 78
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    SHELL = (255, 200, 100, 255)
    SHELL_D = (200, 140, 50, 255)
    # Base oval
    d.ellipse([10, 20, 68, 68], fill=SHELL, outline=SHELL_D, width=2)
    # Spiral ridges
    for i, (start, end, rr) in enumerate(
        [(200, 340, 22), (200, 340, 15), (200, 340, 9)]
    ):
        d.arc([39 - rr, 44 - rr, 39 + rr, 44 + rr],
              start=start, end=end, fill=SHELL_D, width=2)
    # Shine
    d.arc([14, 24, 36, 40], start=200, end=320, fill=WHITE, width=3)
    # Tip at top
    d.ellipse([33, 10, 45, 24], fill=SHELL, outline=SHELL_D, width=2)
    return img


def draw_starfish() -> Image.Image:
    """78×78 orange starfish for background decoration."""
    import math
    W = 78
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    STAR   = (255, 120, 40, 255)
    STAR_D = (200, 70, 20, 255)
    cx, cy = 39, 39
    pts = []
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        r = 28 if i % 2 == 0 else 12
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    d.polygon(pts, fill=STAR, outline=STAR_D)
    # Central disc
    d.ellipse([cx - 9, cy - 9, cx + 9, cy + 9], fill=STAR_D)
    # Texture dots on arms
    for i in range(5):
        angle = math.radians(i * 72 - 90)
        ax = cx + 18 * math.cos(angle)
        ay = cy + 18 * math.sin(angle)
        d.ellipse([ax - 3, ay - 3, ax + 3, ay + 3], fill=STAR_D)
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
        "obstacle_water_rock_1.png": draw_water_rock(1),
        "obstacle_water_rock_2.png": draw_water_rock(2),
        "obstacle_water_rock_3.png": draw_water_rock(3),
        "obstacle_water_rock_4.png": draw_water_rock(4),
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
        "collectibles_icon.png": draw_collectibles_icon(),
        "coin_pickup.png": draw_coin(),
        "reed.png": draw_reed(),
        "water_flower.png": draw_water_flower(),
        # Rhenné Nada swimming game sprites
        "rhenne_swim_1.png": draw_rhenne_swim(1),
        "rhenne_swim_2.png": draw_rhenne_swim(2),
        "rhenne_swim_3.png": draw_rhenne_swim(3),
        "rhenne_swim_4.png": draw_rhenne_swim(4),
        "fish_swim_1.png":   draw_fish(1),
        "fish_swim_2.png":   draw_fish(2),
        "fish_swim_3.png":   draw_fish(3),
        "fish_swim_4.png":   draw_fish(4),
        "jellyfish_1.png":   draw_jellyfish(1),
        "jellyfish_2.png":   draw_jellyfish(2),
        "jellyfish_3.png":   draw_jellyfish(3),
        "jellyfish_4.png":   draw_jellyfish(4),
        "seashell.png":      draw_seashell(),
        "starfish.png":      draw_starfish(),
    }
    for name, im in artworks.items():
        path = OUT / name
        im.save(path)
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
