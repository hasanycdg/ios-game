"""App Store screenshots for the United Kingdom (en-GB) and France (fr-FR).

Same layout as the US set (scripts/prepare_store_screenshots.py): kicker,
two-line headline (white / gold), subtitle and the framed app screen on a dark
background with the country's flag on the left and a landmark on the right.
Raw simulator captures (1206×2622, iPhone 6.9"/6.3" class) live in
release-preparation/1.7/screenshots/<locale>/raw.

Run with a Python that has Pillow:  python3 scripts/prepare_uk_fr_screenshots.py
"""
import math
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1] / "release-preparation/1.7/screenshots"
BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
REGULAR = "/System/Library/Fonts/Supplemental/Arial.ttf"
W, H = 1206, 2622

SETS = {
    "en-GB": ("POLITICAL STRATEGY", [
        ("01.png", "LEAD THE", "UNITED KINGDOM", "Your country. Your choices."),
        ("02.png", "FORM YOUR", "GOVERNMENT", "Win a majority or build a coalition."),
        ("03.png", "MAKE THE", "TOUGH CALLS", "Choose your response to events."),
        ("04.png", "EVERY DECISION", "HAS CONSEQUENCES", "See how your choices change the nation."),
        ("05.png", "THE WORLD", "RESPONDS", "Follow headlines as history unfolds."),
    ]),
    "fr-FR": ("STRATÉGIE POLITIQUE", [
        ("01.png", "GOUVERNE LA", "FRANCE", "Ton pays. Tes choix."),
        ("02.png", "FORME TON", "GOUVERNEMENT", "Négocie une majorité à l’Assemblée."),
        ("03.png", "PRENDS LES", "GRANDES DÉCISIONS", "Choisis ta réponse aux événements."),
        ("04.png", "CHAQUE DÉCISION", "A DES CONSÉQUENCES", "Vois comment tes choix changent le pays."),
        ("05.png", "LE MONDE", "RÉAGIT", "Suis l’actualité au fil de l’histoire."),
    ]),
}

NAVY = (4, 10, 23)
RED = (178, 34, 52)
BLUE = (16, 44, 110)
WHITE = (235, 235, 240)


def sky():
    """Night sky: deep navy with a soft warm glow near the horizon."""
    column = Image.new("RGB", (1, H))
    for y in range(H):
        t = y / H
        column.putpixel((0, y), (int(6 + 10 * t), int(12 + 8 * t), int(28 + 6 * t)))
    img = column.resize((W, H))
    glow = Image.new("RGB", (W, H), (0, 0, 0))
    ImageDraw.Draw(glow).ellipse((W * 0.2, H * 0.78, W * 1.25, H * 1.15), fill=(90, 60, 22))
    return ImageChops.add(img, glow.filter(ImageFilter.GaussianBlur(220)))


def wave(flag, amplitude=34, period=900):
    """Bend a flat flag into a gentle wave with light and shade."""
    w, h = flag.size
    out = Image.new("RGBA", (w, h + amplitude * 2), (0, 0, 0, 0))
    src = flag.load()
    dst = out.load()
    for x in range(w):
        offset = int(amplitude * math.sin(2 * math.pi * x / period))
        shade = 0.55 + 0.45 * (0.5 + 0.5 * math.cos(2 * math.pi * x / period))
        for y in range(h):
            r, g, b, a = src[x, y]
            dst[x, y + amplitude + offset] = (int(r * shade), int(g * shade), int(b * shade), a)
    return out


def union_flag(w, h):
    f = Image.new("RGBA", (w, h), BLUE + (255,))
    d = ImageDraw.Draw(f)
    d.line((0, 0, w, h), fill=WHITE, width=int(h * 0.2))
    d.line((0, h, w, 0), fill=WHITE, width=int(h * 0.2))
    d.line((0, 0, w, h), fill=RED, width=int(h * 0.07))
    d.line((0, h, w, 0), fill=RED, width=int(h * 0.07))
    d.rectangle((w * 0.42, 0, w * 0.58, h), fill=WHITE)
    d.rectangle((0, h * 0.37, w, h * 0.63), fill=WHITE)
    d.rectangle((w * 0.45, 0, w * 0.55, h), fill=RED)
    d.rectangle((0, h * 0.4, w, h * 0.6), fill=RED)
    return f


def tricolore(w, h):
    f = Image.new("RGBA", (w, h), WHITE + (255,))
    d = ImageDraw.Draw(f)
    d.rectangle((0, 0, w / 3, h), fill=(0, 35, 149))
    d.rectangle((2 * w / 3, 0, w, h), fill=(237, 41, 57))
    return f


def big_ben(d, x, base, scale, color):
    """Elizabeth Tower and a stretch of the Palace of Westminster."""
    s = scale
    d.rectangle((x - 600 * s, base - 260 * s, x - 40 * s, base), fill=color)            # palace
    for i in range(14):
        px = x - 590 * s + i * 40 * s
        d.polygon([(px, base - 260 * s), (px + 12 * s, base - 300 * s), (px + 24 * s, base - 260 * s)], fill=color)
    d.rectangle((x - 60 * s, base - 1150 * s, x + 60 * s, base), fill=color)           # tower shaft
    d.rectangle((x - 78 * s, base - 1330 * s, x + 78 * s, base - 1150 * s), fill=color)  # clock stage
    d.polygon([(x - 78 * s, base - 1330 * s), (x, base - 1600 * s), (x + 78 * s, base - 1330 * s)], fill=color)
    d.line((x, base - 1600 * s, x, base - 1680 * s), fill=color, width=max(2, int(6 * s)))
    return (x, base - 1240 * s, 52 * s)  # clock face


def eiffel(d, x, base, scale, color):
    """Eiffel Tower silhouette."""
    s = scale
    d.polygon([(x - 330 * s, base), (x - 60 * s, base - 900 * s), (x + 60 * s, base - 900 * s), (x + 330 * s, base)], fill=color)
    d.ellipse((x - 190 * s, base - 260 * s, x + 190 * s, base + 140 * s), fill=(0, 0, 0, 0))
    d.rectangle((x - 250 * s, base - 330 * s, x + 250 * s, base - 300 * s), fill=color)   # first deck
    d.polygon([(x - 60 * s, base - 900 * s), (x - 18 * s, base - 1550 * s), (x + 18 * s, base - 1550 * s), (x + 60 * s, base - 900 * s)], fill=color)
    d.rectangle((x - 120 * s, base - 920 * s, x + 120 * s, base - 890 * s), fill=color)   # second deck
    d.line((x, base - 1550 * s, x, base - 1700 * s), fill=color, width=max(2, int(8 * s)))


def background(locale):
    img = sky().convert("RGBA")
    # Flag on the left, cropped by the edge like the US artwork.
    flag = union_flag(560, 360) if locale == "en-GB" else tricolore(560, 380)
    flag = wave(flag.rotate(-8, expand=True, resample=Image.Resampling.BICUBIC))
    flag = flag.resize((int(flag.width * 1.5), int(flag.height * 1.5)), Image.Resampling.LANCZOS)
    flag.putalpha(flag.getchannel("A").point(lambda a: int(a * 0.72)))
    # Keep the recognisable part of the flag in the visible left margin.
    img.alpha_composite(flag, (-330 if locale == "en-GB" else -90, 820))
    # Landmark on the right with warm lights.
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    silhouette = (44, 40, 52, 255)
    base = H - 260
    if locale == "en-GB":
        clock = big_ben(d, W - 64, base, 1.0, silhouette)
        cx, cy, r = clock
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(240, 196, 110, 255))
    else:
        tx = W - 40
        eiffel(d, tx, base, 1.0, silhouette)
        for i in range(30):  # evening lights along both edges of the tower
            y = base - 40 - i * 52
            half = 330 - (330 - 18) * min(1, i * 52 / 1550)
            for side in (-1, 1):
                d.ellipse((tx + side * half * 0.92 - 4, y - 4, tx + side * half * 0.92 + 4, y + 4), fill=(245, 200, 120, 230))
    glow = layer.filter(ImageFilter.GaussianBlur(10))
    img.alpha_composite(glow)
    img.alpha_composite(layer)
    # River with soft golden reflections along the bottom.
    river = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    rd = ImageDraw.Draw(river)
    rd.rectangle((0, base, W, H), fill=(8, 14, 28, 255))
    for cx in (W - 60, W - 260, 120):
        rd.ellipse((cx - 30, base + 10, cx + 30, H - 20), fill=(220, 170, 90, 110))
    img.alpha_composite(river.filter(ImageFilter.GaussianBlur(18)))
    # Darken like the US set so the text stays readable.
    return Image.blend(img.convert("RGB"), Image.new("RGB", (W, H), NAVY), 0.35).convert("RGBA")


def place_iphone(canvas, screen, top):
    """Draw an iPhone (gold titanium frame, black bezel, side buttons) with the
    screen inside. Rendered at 2x and scaled down for smooth edges."""
    k = 2
    screen_w = 840
    screen_h = round(screen_w * screen.height / screen.width)
    bezel, frame = 26, 16
    body_w = screen_w + 2 * (bezel + frame)
    body_h = screen_h + 2 * (bezel + frame)
    margin = 40  # room for side buttons
    lw, lh = (body_w + 2 * margin) * k, (body_h + 2 * margin) * k
    layer = Image.new("RGBA", (lw, lh), (0, 0, 0, 0))
    ox, oy = margin * k, margin * k
    radius = 150 * k

    # Side buttons (left: action, volume up/down; right: power).
    buttons = Image.new("RGBA", (lw, lh), (0, 0, 0, 0))
    bd = ImageDraw.Draw(buttons)
    gold_dark = (150, 118, 62, 255)
    for y0, y1 in [(300, 380), (450, 590), (620, 760)]:
        bd.rounded_rectangle((ox - 9 * k, oy + y0 * k, ox + 4 * k, oy + y1 * k), radius=5 * k, fill=gold_dark)
    bd.rounded_rectangle((ox + body_w * k - 4 * k, oy + 500 * k, ox + body_w * k + 9 * k, oy + 720 * k), radius=5 * k, fill=gold_dark)
    layer.alpha_composite(buttons)

    # Titanium frame with a metallic horizontal gradient.
    gradient = Image.new("RGBA", (body_w * k, 1))
    stops = [(0.0, (120, 92, 48)), (0.04, (236, 205, 140)), (0.10, (176, 140, 80)), (0.5, (205, 172, 110)),
             (0.90, (176, 140, 80)), (0.96, (240, 212, 150)), (1.0, (116, 88, 44))]
    for x in range(body_w * k):
        t = x / (body_w * k - 1)
        for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
            if t0 <= t <= t1:
                f = (t - t0) / (t1 - t0)
                gradient.putpixel((x, 0), tuple(int(c0[i] + (c1[i] - c0[i]) * f) for i in range(3)) + (255,))
                break
    gradient = gradient.resize((body_w * k, body_h * k))
    body_mask = Image.new("L", (body_w * k, body_h * k), 0)
    ImageDraw.Draw(body_mask).rounded_rectangle((0, 0, body_w * k - 1, body_h * k - 1), radius=radius, fill=255)
    layer.paste(gradient, (ox, oy), body_mask)
    d = ImageDraw.Draw(layer)
    # Thin highlight and inner edge of the frame.
    d.rounded_rectangle((ox + 3 * k, oy + 3 * k, ox + body_w * k - 3 * k, oy + body_h * k - 3 * k),
                        radius=radius - 3 * k, outline=(250, 228, 175, 160), width=2 * k)
    # Black glass bezel.
    f = frame * k
    d.rounded_rectangle((ox + f, oy + f, ox + body_w * k - f, oy + body_h * k - f), radius=radius - f, fill=(8, 8, 10, 255))
    # Screen.
    sx, sy = ox + (frame + bezel) * k, oy + (frame + bezel) * k
    big = screen.resize((screen_w * k, screen_h * k), Image.Resampling.LANCZOS)
    screen_mask = Image.new("L", big.size, 0)
    ImageDraw.Draw(screen_mask).rounded_rectangle((0, 0, big.width - 1, big.height - 1), radius=radius - (frame + bezel) * k, fill=255)
    layer.paste(big, (sx, sy), screen_mask)
    phone = layer.resize((lw // k, lh // k), Image.Resampling.LANCZOS)
    x = (W - phone.width) // 2
    # Shadow and warm floor glow beneath the phone.
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((x + margin + 10, top + margin + 30, x + phone.width - margin - 10, top + phone.height - margin + 30),
                         radius=150, fill=(0, 0, 0, 200))
    sd.ellipse((x + 60, top + phone.height - margin - 40, x + phone.width - 60, top + phone.height - margin + 60), fill=(230, 180, 90, 70))
    canvas = Image.alpha_composite(canvas, shadow.filter(ImageFilter.GaussianBlur(30)))
    canvas.alpha_composite(phone, (x, top))
    return canvas


def compose(locale):
    kicker, items = SETS[locale]
    bg = background(locale)
    dest = ROOT / locale / "designed"
    dest.mkdir(parents=True, exist_ok=True)
    for index, (name, line1, line2, subtitle) in enumerate(items, 1):
        canvas = bg.copy()
        d = ImageDraw.Draw(canvas)
        d.text((W // 2, 72), kicker, font=ImageFont.truetype(BOLD, 31), fill="#DFC18B", anchor="mt")
        size = 102
        while max(d.textbbox((0, 0), line, font=ImageFont.truetype(BOLD, size))[2] for line in (line1, line2)) > 1090:
            size -= 2
        headline = ImageFont.truetype(BOLD, size)
        d.text((W // 2, 130), line1, font=headline, fill="#FFFFFF", anchor="mt", stroke_width=1, stroke_fill="#0a0d18")
        d.text((W // 2, 130 + size + 10), line2, font=headline, fill="#EFCB8D", anchor="mt", stroke_width=1, stroke_fill="#0a0d18")
        d.text((W // 2, 380), subtitle, font=ImageFont.truetype(REGULAR, 36), fill="#E8E8E8", anchor="mt")
        screen = Image.open(ROOT / locale / "raw" / name).convert("RGBA")
        canvas = place_iphone(canvas, screen, top=520)
        out = dest / f"{index:02}-{locale}.png"
        canvas.convert("RGB").save(out, optimize=True)
        print(out)


if __name__ == "__main__":
    for locale in SETS:
        compose(locale)
