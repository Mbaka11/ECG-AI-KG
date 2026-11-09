"""Render WFDB records as ECG-Image-Kit pages (the style the pretrained digitiser was trained on).

Calls `extract_leads.get_paper_ecg` from the ecg-image-generator bundled in ECG-Digitiser
(ECG-Image-Kit, BSD-3) directly. This skips the handwriting module, which imports TensorFlow and
spaCy and fetches web text. Settings follow the generator's defaults: 200 dpi, standard grid
colour, calibration pulse, 3x4 layout plus a lead II rhythm strip, no wrinkles or augmentation.

Run with the image-kit venv's python (numpy 1.26, imgaug 0.4; see README.md):
    python imagekit_page.py OUT_DIR RECORD [RECORD ...]     # RECORD = path without extension
"""

from __future__ import annotations

import os
import shutil
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DIR = REPO_ROOT / "data" / "third_party" / "ECG-Digitiser"


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        sys.exit(__doc__)
    render_pages(Path(argv[0]), [Path(r) for r in argv[1:]])
    return 0


def render_pages(out_dir: Path, records: list[Path], *, columns: int = -1, full_mode: str = "II",
                 bw: bool = False, suffix: str = "") -> list[Path]:
    """Render each WFDB record (path without extension) to OUT_DIR/<record name><suffix>.png.

    Variants: `columns` = 1 (one lead per row), 2 (6 rows x 2 columns) or -1 (the default 3x4 grid);
    `full_mode` = "II" (rhythm strip, default) or "None"; `bw` = black-and-white page.
    """
    out_dir = out_dir.resolve()
    records = [r.resolve() for r in records]
    gen_dir = Path(os.environ.get("ECG_DIGITISER_DIR", DEFAULT_DIR)).resolve() / "ecg-image-generator"
    out_dir.mkdir(parents=True, exist_ok=True)

    cwd = os.getcwd()
    os.chdir(gen_dir)  # the generator loads fonts and templates from relative paths
    sys.path.insert(0, str(gen_dir))
    from scipy.stats import bernoulli  # noqa: PLC0415

    from extract_leads import get_paper_ecg  # noqa: PLC0415  (third-party)
    from helper_functions import read_config_file  # noqa: PLC0415

    configs = read_config_file(str(gen_dir / "config.yaml"))
    pages: list[Path] = []
    for rec in records:
        files = get_paper_ecg(
            input_file=str(rec) + ".dat",
            header_file=str(rec) + ".hea",
            output_directory=str(out_dir),
            seed=7,
            add_dc_pulse=bernoulli(1),
            add_bw=bernoulli(1 if bw else 0),
            show_grid=bernoulli(1),
            add_print=bernoulli(0),
            configs=configs,
            resolution=200,
            pad_inches=0,
            font_type=os.path.join("Fonts", "Times_New_Roman.ttf"),
            standard_colours=5,
            full_mode=full_mode,
            columns=columns,
        )
        for f in files:
            # Name the page after the record so the digitiser output matches the ground truth.
            dst = out_dir / f"{rec.name}{suffix}.png"
            shutil.move(f, dst)
            pages.append(dst)
            print("page", dst)
    os.chdir(cwd)
    return pages


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
