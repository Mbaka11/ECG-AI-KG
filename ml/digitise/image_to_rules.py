"""End to end: ECG page image(s) -> digitiser -> lead II rhythm strip -> rule-based safety net.

Runs the digitiser (run_digitiser.py) with its own Python environment, then applies
`ecg_rules.assess` to the digitised 10 s lead II. With --truth-dir, the same rules also run
on the true lead II, so digitiser errors can be told apart from rule errors.

Research prototype: decision support only, thresholds pending cardiologist review.

Usage (ml venv python):
    python -m digitise.image_to_rules IMG_DIR [--truth-dir DIR] [--work DIR]
Env:
    ECG_DIGITISER_PYTHON  python of the digitiser venv
                          (default <repo>/data/third_party/venv-digitiser/Scripts/python.exe)
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
import wfdb

from ecg_rules.aggregate import assess

HERE = Path(__file__).resolve().parent
DATA_ROOT = HERE.parents[2] / "data"
DEFAULT_PY = DATA_ROOT / "third_party" / "venv-digitiser" / "Scripts" / "python.exe"


def lead(rec: wfdb.Record, name: str = "II") -> np.ndarray:
    names = [n.upper() for n in rec.sig_name]
    return np.nan_to_num(rec.p_signal[:, names.index(name.upper())])


def describe(sig: np.ndarray, fs: float) -> str:
    a = assess(sig, fs)
    hr = a.rhythm.hr_bpm
    found = "; ".join(f.finding for f in a.findings) or "no rule triggered"
    hr_txt = f"{hr:.0f}/min" if hr is not None and np.isfinite(hr) else "HR n/a"
    return f"{a.urgency.name:<6} {hr_txt:<9} {found}"


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("img_dir")
    ap.add_argument("--truth-dir")
    ap.add_argument("--work", help="where to keep digitiser output (default: temp dir)")
    a = ap.parse_args(argv)

    work = Path(a.work) if a.work else Path(tempfile.mkdtemp(prefix="ecg_dig_"))
    py = os.environ.get("ECG_DIGITISER_PYTHON", str(DEFAULT_PY))
    subprocess.run([py, str(HERE / "run_digitiser.py"), str(Path(a.img_dir).resolve()), str(work.resolve())],
                   check=True, stdout=subprocess.DEVNULL)

    for hea in sorted(work.glob("*.hea")):
        rec = wfdb.rdrecord(str(hea.with_suffix("")))
        print(f"{hea.stem}")
        print(f"  from image : {describe(lead(rec), rec.fs)}")
        if a.truth_dir and (Path(a.truth_dir) / hea.name).exists():
            t = wfdb.rdrecord(str(Path(a.truth_dir) / hea.stem))
            print(f"  from truth : {describe(lead(t), t.fs)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
