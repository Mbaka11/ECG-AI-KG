"""Find the print-pack QR code in each photo and stage the photos for the digitiser.

PHOTOS_DIR/<condition>/<any name>.jpg|jpeg|png  ->  STAGE_DIR/<condition>__<stem>.jpg + photos.csv
photos.csv: staged, condition, original, record ('' if no QR found; fill it in by hand).
A record id in the file name (e.g. 00318_hr) is used when the QR cannot be read.

Run with the digitiser venv's python (needs opencv):
    python qr_index.py PHOTOS_DIR STAGE_DIR
"""

from __future__ import annotations

import csv
import re
import shutil
import sys
from pathlib import Path

import cv2
import numpy as np

PREFIX = "ECGAIKG:ptbxl:"
EXT = {".jpg", ".jpeg", ".png"}


def read_qr(path: Path) -> str:
    img = cv2.imdecode(np.fromfile(str(path), dtype=np.uint8), cv2.IMREAD_COLOR)
    if img is None:
        return ""
    detectors = [cv2.QRCodeDetector()]
    if hasattr(cv2, "QRCodeDetectorAruco"):
        detectors.append(cv2.QRCodeDetectorAruco())
    for width in (None, 2000, 1400, 1000):
        im = img if width is None or img.shape[1] <= width else cv2.resize(
            img, (width, round(img.shape[0] * width / img.shape[1])), interpolation=cv2.INTER_AREA)
        for det in detectors:
            try:
                text, *_ = det.detectAndDecode(im)
            except cv2.error:
                continue
            if text.startswith(PREFIX):
                return text[len(PREFIX):]
    return ""


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        sys.exit(__doc__)
    photos, stage = Path(argv[0]), Path(argv[1])
    stage.mkdir(parents=True, exist_ok=True)
    rows = []
    for f in sorted(photos.rglob("*")):
        if f.suffix.lower() not in EXT or not f.is_file():
            continue
        cond = f.parent.name if f.parent != photos else "unsorted"
        staged = f"{cond}__{f.stem}{f.suffix.lower()}"
        shutil.copy(f, stage / staged)
        rec = read_qr(f)
        if not rec:
            m = re.search(r"(\d{5}_hr(?:_(?:bw|cols2|norhythm))?)", f.name)
            rec = m.group(1) if m else ""
        rows.append({"staged": Path(staged).stem, "condition": cond, "original": str(f), "record": rec})
        print(f"{'OK ' if rec else '?? '} {cond:<12} {f.name:<30} {rec}")
    with open(stage / "photos.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["staged", "condition", "original", "record"])
        w.writeheader()
        w.writerows(rows)
    missing = sum(1 for r in rows if not r["record"])
    print(f"{len(rows)} photos, {missing} without record id -> {stage / 'photos.csv'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
