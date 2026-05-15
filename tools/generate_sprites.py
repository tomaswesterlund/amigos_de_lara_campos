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


def new_canvas():
    return Image.new("RGBA", (SIZE, SIZE), TRANSPARENT)


def draw_frog(crown: bool, body_color, body_dark):
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # body (rounded blob)
    d.ellipse([28, 90, 228, 240], fill=body_color, outline=body_dark, width=4)
    # head
    d.ellipse([40, 30, 216, 170], fill=body_color, outline=body_dark, width=4)
    # eye sockets (bumps on top of head)
    d.ellipse([56, 8, 116, 70], fill=body_color, outline=body_dark, width=4)
    d.ellipse([140, 8, 200, 70], fill=body_color, outline=body_dark, width=4)
    # whites of eyes
    d.ellipse([66, 18, 106, 58], fill=WHITE, outline=BLACK, width=3)
    d.ellipse([150, 18, 190, 58], fill=WHITE, outline=BLACK, width=3)
    # pupils
    d.ellipse([80, 30, 96, 50], fill=BLACK)
    d.ellipse([164, 30, 180, 50], fill=BLACK)
    # cheeks
    d.ellipse([54, 110, 90, 140], fill=PINK)
    d.ellipse([166, 110, 202, 140], fill=PINK)
    # smile
    d.arc([96, 90, 160, 150], start=20, end=160, fill=BLACK, width=5)
    # crown for Reina
    if crown:
        d.polygon(
            [(78, 8), (98, -18), (118, 8), (138, -18), (158, 8), (178, -18), (198, 8)],
            fill=GOLD,
            outline=BLACK,
        )
        # gem
        d.ellipse([120, 0, 140, 18], fill=HEART_RED, outline=BLACK)
    return img


def draw_dog():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # body
    d.ellipse([34, 110, 222, 240], fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=4)
    # legs
    d.rectangle([60, 210, 88, 250], fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=4)
    d.rectangle([170, 210, 198, 250], fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=4)
    # head
    d.ellipse([56, 30, 200, 170], fill=GALLETA_BROWN, outline=GALLETA_BROWN_DARK, width=4)
    # ears (floppy)
    d.ellipse([28, 40, 90, 130], fill=GALLETA_BROWN_DARK, outline=BLACK, width=3)
    d.ellipse([166, 40, 228, 130], fill=GALLETA_BROWN_DARK, outline=BLACK, width=3)
    # snout
    d.ellipse([92, 100, 164, 160], fill=BONE, outline=GALLETA_BROWN_DARK, width=3)
    # nose
    d.ellipse([116, 110, 140, 130], fill=BLACK)
    # eyes
    d.ellipse([76, 66, 102, 92], fill=WHITE, outline=BLACK, width=2)
    d.ellipse([154, 66, 180, 92], fill=WHITE, outline=BLACK, width=2)
    d.ellipse([84, 74, 96, 86], fill=BLACK)
    d.ellipse([162, 74, 174, 86], fill=BLACK)
    # smile
    d.arc([110, 130, 146, 156], start=10, end=170, fill=BLACK, width=4)
    # tongue
    d.ellipse([118, 144, 138, 162], fill=PINK)
    return img


def draw_heart(color=HEART_RED, dark=HEART_RED_DARK, sparkle=True):
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # two lobes + triangle
    d.ellipse([28, 48, 144, 164], fill=color, outline=dark, width=5)
    d.ellipse([112, 48, 228, 164], fill=color, outline=dark, width=5)
    d.polygon([(36, 122), (128, 232), (220, 122)], fill=color, outline=dark)
    # cover the seam
    d.polygon([(42, 110), (128, 220), (214, 110)], fill=color)
    # sparkle highlight
    if sparkle:
        d.ellipse([66, 72, 96, 102], fill=WHITE)
        d.ellipse([74, 80, 86, 92], fill=color)
    return img


def draw_lilypad():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # flat oval pad
    d.ellipse([12, 90, 244, 200], fill=LILY, outline=LILY_DARK, width=5)
    # wedge cut
    d.polygon([(128, 145), (200, 90), (245, 145)], fill=LILY_DARK)
    d.polygon([(128, 145), (208, 96), (240, 142)], fill=LILY)
    # tiny pink flower
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
    # highlight
    d.polygon([(90, 130), (130, 100), (160, 120), (130, 140)], fill=(150, 140, 150, 255))
    return img


def draw_bone():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # main shaft
    d.rounded_rectangle([60, 110, 196, 150], radius=18, fill=BONE, outline=BONE_DARK, width=4)
    # knobs
    for cx, cy in [(60, 100), (60, 160), (196, 100), (196, 160)]:
        d.ellipse([cx - 30, cy - 30, cx + 30, cy + 30], fill=BONE, outline=BONE_DARK, width=4)
    return img


def draw_card_back():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # rounded card body
    d.rounded_rectangle([16, 16, 240, 240], radius=28, fill=PINK, outline=MAGENTA, width=6)
    # inner border
    d.rounded_rectangle([36, 36, 220, 220], radius=18, outline=WHITE, width=4)
    # center heart
    h = draw_heart(WHITE, WHITE, sparkle=False).resize((120, 120))
    img.paste(h, (68, 68), h)
    return img


def draw_music_note():
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # note head
    d.ellipse([40, 160, 120, 220], fill=MAGENTA, outline=BLACK, width=4)
    d.ellipse([160, 130, 240, 190], fill=MAGENTA, outline=BLACK, width=4)
    # stems
    d.rectangle([114, 60, 130, 196], fill=BLACK)
    d.rectangle([234, 30, 250, 162], fill=BLACK)
    # beam
    d.polygon([(114, 50), (250, 20), (250, 50), (114, 80)], fill=BLACK)
    return img


def draw_lara():
    """Stylised Lara avatar — bubble hair, big smile."""
    img = new_canvas()
    d = ImageDraw.Draw(img)
    # body / shirt
    d.rounded_rectangle([62, 170, 194, 250], radius=20, fill=MINT, outline=MAGENTA, width=4)
    # heart on shirt
    h = draw_heart().resize((60, 60))
    img.paste(h, (98, 180), h)
    # head
    d.ellipse([60, 30, 196, 180], fill=(255, 220, 190, 255), outline=BLACK, width=3)
    # hair
    d.ellipse([46, 16, 210, 130], fill=(80, 50, 35, 255), outline=BLACK, width=3)
    d.ellipse([60, 60, 196, 160], fill=(255, 220, 190, 255))
    # eyes
    d.ellipse([90, 100, 112, 122], fill=BLACK)
    d.ellipse([144, 100, 166, 122], fill=BLACK)
    # blush
    d.ellipse([78, 128, 104, 148], fill=PINK)
    d.ellipse([152, 128, 178, 148], fill=PINK)
    # smile
    d.arc([100, 132, 156, 168], start=10, end=170, fill=BLACK, width=4)
    return img


def main():
    artworks = {
        "rhenne.png": draw_frog(crown=False, body_color=RHENNE_GREEN, body_dark=RHENNE_GREEN_DARK),
        "reina.png": draw_frog(crown=True, body_color=PINK, body_dark=MAGENTA),
        "galleta.png": draw_dog(),
        "corazon.png": draw_heart(),
        "corazon_pink.png": draw_heart(PINK, MAGENTA),
        "corazon_yellow.png": draw_heart(YELLOW, (210, 160, 30, 255)),
        "lilypad.png": draw_lilypad(),
        "obstacle_rock.png": draw_rock(),
        "treat_bone.png": draw_bone(),
        "card_back.png": draw_card_back(),
        "music_note.png": draw_music_note(),
        "lara.png": draw_lara(),
    }
    for name, im in artworks.items():
        path = OUT / name
        im.save(path)
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
