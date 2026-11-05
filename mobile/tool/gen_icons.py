"""Draw the app icon (one heartbeat on the brand square) for Android and the web.

Same shape as AppMark in lib/widgets/common.dart. Run from mobile/:
    python tool/gen_icons.py
Needs Pillow (dev-only tool, not shipped in the app).
"""
import pathlib

from PIL import Image, ImageDraw

BRAND = (0x1D, 0x4E, 0x89, 255)
WHITE = (255, 255, 255, 255)
# Keep in sync with appMarkBeat in lib/widgets/common.dart (unit coordinates).
BEAT = [(0.14, 0.56), (0.31, 0.56), (0.36, 0.48), (0.41, 0.56), (0.45, 0.56), (0.50, 0.22),
        (0.56, 0.76), (0.60, 0.56), (0.66, 0.56), (0.72, 0.44), (0.78, 0.56), (0.86, 0.56)]
SS = 4  # supersampling for smooth edges


def draw(size, rounded=True, safe=1.0):
    """safe < 1 shrinks the heartbeat into the centre (maskable / adaptive icons)."""
    n = size * SS
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if rounded:
        d.rounded_rectangle([0, 0, n - 1, n - 1], radius=int(n * 0.28), fill=BRAND)
    else:
        d.rectangle([0, 0, n - 1, n - 1], fill=BRAND)
    off = n * (1 - safe) / 2
    pts = [(off + x * n * safe, off + y * n * safe) for x, y in BEAT]
    w = max(1, int(n * safe * 0.075))
    d.line(pts, fill=WHITE, width=w, joint="curve")
    for p in (pts[0], pts[-1]):  # round caps
        d.ellipse([p[0] - w / 2, p[1] - w / 2, p[0] + w / 2, p[1] + w / 2], fill=WHITE)
    return img.resize((size, size), Image.Resampling.LANCZOS)


root = pathlib.Path(__file__).resolve().parent.parent
for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    draw(px).save(root / f"android/app/src/main/res/mipmap-{folder}/ic_launcher.png")
draw(32).save(root / "web/favicon.png")
for px in (192, 512):
    draw(px).save(root / f"web/icons/Icon-{px}.png")
    draw(px, rounded=False, safe=0.8).save(root / f"web/icons/Icon-maskable-{px}.png")
print("icons written")
