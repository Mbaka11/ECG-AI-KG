"""Build a printable test pack: PTB-XL records as ECG-Image-Kit pages with a QR code per page.

Each page gets, in the empty top margin:
- a QR code `ECGAIKG:ptbxl:<record>` (lets score_photos.py match a photo to its true signal),
- a line "Test page NN - PTB-XL <record> (CC BY 4.0) - synthetic test, not a patient".
The diagnosis is deliberately not printed.

Outputs in OUT_DIR: page_NN_<record>.png, print_pack_A4.pdf (pages fitted to A4 landscape,
about 97 % of true size), truth/<record>.hea/.dat (copies of the ground truth) and pack.csv.

Run with the image-kit venv's python (needs qrcode; see README.md):
    python make_print_pack.py SELECTION_CSV PTBXL_DIR OUT_DIR
SELECTION_CSV columns: cls,file,age,sex[,variant]  (file = PTB-XL path without extension).
variant: "" (3x4 + rhythm strip), "bw" (black and white), "cols2" (6x2 + rhythm strip) or "norhythm".
A variant page uses the record id "<record>_<variant>" in its QR code and file name; its true signal
is the base record's.
"""

from __future__ import annotations

import csv
import shutil
import sys
from pathlib import Path

import qrcode
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from imagekit_page import render_pages  # noqa: E402

A4_W, A4_H = 2339, 1654  # A4 landscape at 200 dpi
QR_PREFIX = "ECGAIKG:ptbxl:"


def stamp(page: Path, n: int, record: str) -> Image.Image:
    im = Image.open(page).convert("RGB")
    qr = qrcode.make(QR_PREFIX + record, box_size=8, border=2).convert("RGB")
    qr = qr.resize((230, 230), Image.NEAREST)
    im.paste(qr, (im.width - qr.width - 60, 60))
    d = ImageDraw.Draw(im)
    try:
        font = ImageFont.truetype("arial.ttf", 34)
    except OSError:
        font = ImageFont.load_default()
    d.rectangle((50, 60, 1350, 120), fill="white")
    d.text((60, 70), f"Test page {n:02d} - PTB-XL {record} (CC BY 4.0) - synthetic test, not a patient",
           fill="black", font=font)
    return im


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        sys.exit(__doc__)
    sel_csv, ptbxl, out = Path(argv[0]), Path(argv[1]).resolve(), Path(argv[2]).resolve()
    rows = list(csv.DictReader(open(sel_csv, encoding="utf-8")))
    (out / "truth").mkdir(parents=True, exist_ok=True)
    kw = {"": {}, "bw": {"bw": True}, "cols2": {"columns": 2}, "norhythm": {"full_mode": "None"}}
    raw = []
    for r in rows:
        v = r.get("variant", "")
        raw += render_pages(out / "_raw", [ptbxl / r["file"]], suffix=f"_{v}" if v else "", **kw[v])

    a4_pages, index = [], []
    for n, (r, page) in enumerate(zip(rows, raw), start=1):
        base = Path(r["file"]).name
        variant = r.get("variant", "")
        record = f"{base}_{variant}" if variant else base
        for ext in (".hea", ".dat"):
            shutil.copy(ptbxl / (r["file"] + ext), out / "truth" / (base + ext))
        im = stamp(page, n, record)
        im.save(out / f"page_{n:02d}_{record}.png")
        s = min(A4_W / im.width, A4_H / im.height)
        fitted = im.resize((round(im.width * s), round(im.height * s)), Image.LANCZOS)
        sheet = Image.new("RGB", (A4_W, A4_H), "white")
        sheet.paste(fitted, ((A4_W - fitted.width) // 2, (A4_H - fitted.height) // 2))
        a4_pages.append(sheet)
        index.append({"page": n, "record": record, "base_record": base, "variant": variant, "class": r["cls"], "age": r["age"], "sex": r["sex"]})

    a4_pages[0].save(out / "print_pack_A4.pdf", save_all=True, append_images=a4_pages[1:], resolution=200)
    with open(out / "pack.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(index[0]))
        w.writeheader()
        w.writerows(index)
    shutil.rmtree(out / "_raw")
    print(f"{len(index)} pages -> {out / 'print_pack_A4.pdf'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
