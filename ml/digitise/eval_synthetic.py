"""Score digitiser output (WFDB records) against the ground-truth WFDB records it was drawn from.

Usage (any python with numpy + wfdb):
    python eval_synthetic.py TRUTH_DIR PRED_DIR [--csv OUT.csv]

TRUTH_DIR holds <name>.hea/.dat (the records that were rendered); PRED_DIR holds the digitiser's
<name>.hea/.dat with the same names.
"""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

import numpy as np
import wfdb

sys.path.insert(0, str(Path(__file__).resolve().parent))
from metrics import score_page  # noqa: E402


def _leads(rec: wfdb.Record) -> dict[str, np.ndarray]:
    norm = {"AVR": "aVR", "AVL": "aVL", "AVF": "aVF"}
    return {norm.get(n.upper(), n.upper()): rec.p_signal[:, i] for i, n in enumerate(rec.sig_name)}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("truth_dir")
    ap.add_argument("pred_dir")
    ap.add_argument("--csv")
    a = ap.parse_args(argv)

    rows = []
    for hea in sorted(Path(a.pred_dir).glob("*.hea")):
        name = hea.stem
        truth_path = Path(a.truth_dir) / name
        if not truth_path.with_suffix(".hea").exists():
            continue
        t = wfdb.rdrecord(str(truth_path))
        p = wfdb.rdrecord(str(Path(a.pred_dir) / name))
        if t.fs != p.fs:
            sys.exit(f"{name}: sampling rates differ ({t.fs} vs {p.fs})")
        for s in score_page(_leads(t), _leads(p), fs=int(t.fs)):
            rows.append({"record": name, "lead": s.lead, "snr_db": round(s.snr_db, 2),
                         "r": round(s.r, 3), "lag": s.lag, "n": s.n})

    if not rows:
        sys.exit("no matching records")
    for rec in sorted({r["record"] for r in rows}):
        rr = [r for r in rows if r["record"] == rec]
        snr = np.array([r["snr_db"] for r in rr], dtype=float)
        cor = np.array([r["r"] for r in rr], dtype=float)
        print(f"{rec}: leads={len(rr)}  SNR median {np.nanmedian(snr):.1f} dB "
              f"(min {np.nanmin(snr):.1f})  r median {np.nanmedian(cor):.3f}")
    snr = np.array([r["snr_db"] for r in rows], dtype=float)
    print(f"ALL: {len(rows)} leads  SNR median {np.nanmedian(snr):.1f} dB, "
          f"10th pct {np.nanpercentile(snr, 10):.1f} dB")
    if a.csv:
        with open(a.csv, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0]))
            w.writeheader()
            w.writerows(rows)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
