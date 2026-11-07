"""Run the PhysioNet 2024 winner digitiser (felixkrones/ECG-Digitiser) for inference only.

The third-party code and weights live outside git (see README.md for setup). This wrapper:
- runs from the digitiser repo folder (its pipeline uses relative temp paths),
- patches one incompatibility with torchvision >= 0.20 (rotation angle must be a Python float)
  without editing the third-party code,
- writes one WFDB record (500 Hz, 12 leads, 10 s) per input PNG into the output folder.

Env vars:
    ECG_DIGITISER_DIR   path to the cloned repo (default: <repo>/data/third_party/ECG-Digitiser)
    ECG_DIGITISER_MODEL model folder inside it (default: models/M3/)

Usage (with the digitiser venv's python):
    python run_digitiser.py IN_DIR OUT_DIR [--show-image]
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DIR = REPO_ROOT / "data" / "third_party" / "ECG-Digitiser"


IMAGE_EXT = {".png", ".jpg", ".jpeg"}


def _prepare_inputs(src: Path, dst: Path, min_width: int, max_width: int = 0) -> Path:
    """Copy images to dst as upright RGB PNG (the pipeline reads .png only), resized into range."""
    from PIL import Image, ImageOps  # noqa: PLC0415  (pillow ships with torchvision here)

    dst.mkdir(parents=True, exist_ok=True)
    for f in sorted(src.iterdir()):
        if f.suffix.lower() not in IMAGE_EXT:
            continue
        im = ImageOps.exif_transpose(Image.open(f)).convert("RGB")  # phone photos carry EXIF rotation
        target = min_width if (min_width and im.width < min_width) else (
            max_width if (max_width and im.width > max_width) else 0)
        if target:
            im = im.resize((target, round(im.height * target / im.width)), Image.LANCZOS)
        im.save(dst / f"{f.stem}.png")
    return dst


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("in_dir")
    p.add_argument("out_dir")
    p.add_argument("--show-image", action="store_true", help="also save mask/signal overlay PNGs")
    p.add_argument("--min-width", type=int, default=2200,
                   help="upscale narrower images to this width first (weights were trained on ~200 dpi "
                        "letter pages, 2200 px wide; small web images segment to nothing otherwise). 0 = off")
    p.add_argument("--max-width", type=int, default=3000,
                   help="downscale wider images (phone photos are ~4000 px) to this width first. 0 = off")
    a = p.parse_args(argv)

    dig_dir = Path(os.environ.get("ECG_DIGITISER_DIR", DEFAULT_DIR)).resolve()
    model = os.environ.get("ECG_DIGITISER_MODEL", "models/M3/")
    in_dir, out_dir = Path(a.in_dir).resolve(), Path(a.out_dir).resolve()
    if not (dig_dir / "src" / "run" / "digitize.py").exists():
        sys.exit(f"ECG-Digitiser not found at {dig_dir}; see ml/digitise/README.md")

    # nnU-Net warns when these are unset; inference only needs nnUNet_results (set by the pipeline).
    os.environ.setdefault("nnUNet_raw", str(out_dir))
    os.environ.setdefault("nnUNet_preprocessed", str(out_dir))
    # The pipeline shells out to `nnUNetv2_predict`; make sure this venv's scripts come first.
    os.environ["PATH"] = str(Path(sys.executable).parent) + os.pathsep + os.environ.get("PATH", "")

    in_dir = _prepare_inputs(in_dir, out_dir / "_input", a.min_width, a.max_width)

    os.chdir(dig_dir)
    sys.path.insert(0, str(dig_dir))
    import src.run.digitize as d  # noqa: PLC0415  (third-party, imported after chdir)

    _rotate = d.rotate
    d.rotate = lambda img, angle, *args, **kw: _rotate(img, float(angle), *args, **kw)

    args = d.get_parser().parse_args(
        ["-d", str(in_dir), "-o", str(out_dir), "-m", model, "-f"] + (["--show_image"] if a.show_image else [])
    )
    d.run(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
