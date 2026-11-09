"""Score phone photos of the print pack: QR -> digitiser -> SNR vs truth + rules on image vs truth.

Usage (ml venv python, from ml/):
    python -m digitise.score_photos PHOTOS_DIR PACK_DIR WORK_DIR [--skip-digitise]

PHOTOS_DIR/<condition>/*.jpg  (condition = folder name: ideal, angle, shadow, curved, dim, ...)
PACK_DIR = output of make_print_pack.py (needs truth/ and pack.csv)
WORK_DIR gets: stage/ (+photos.csv), out/ (digitiser WFDB), results.csv, summary printed.
"""

from __future__ import annotations

import argparse
import csv
import os
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np
import wfdb

from digitise.image_to_rules import DEFAULT_PY, lead
from digitise.metrics import score_page
from ecg_rules.aggregate import assess

HERE = Path(__file__).resolve().parent
NORM = {"AVR": "aVR", "AVL": "aVL", "AVF": "aVF"}


def leads(rec: wfdb.Record) -> dict[str, np.ndarray]:
    return {NORM.get(n.upper(), n.upper()): rec.p_signal[:, i] for i, n in enumerate(rec.sig_name)}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("photos")
    ap.add_argument("pack")
    ap.add_argument("work")
    ap.add_argument("--skip-digitise", action="store_true", help="reuse WORK/out from a previous run")
    a = ap.parse_args(argv)
    photos, pack, work = (Path(p).resolve() for p in (a.photos, a.pack, a.work))
    py = os.environ.get("ECG_DIGITISER_PYTHON", str(DEFAULT_PY))
    stage, out = work / "stage", work / "out"

    if not a.skip_digitise:
        subprocess.run([py, str(HERE / "qr_index.py"), str(photos), str(stage)], check=True)
        subprocess.run([py, str(HERE / "run_digitiser.py"), str(stage), str(out)], check=True,
                       stdout=subprocess.DEVNULL)

    pack_rows = {r["record"]: r for r in csv.DictReader(open(pack / "pack.csv"))}
    classes = {k: r["class"] for k, r in pack_rows.items()}
    rows = []
    for p in csv.DictReader(open(stage / "photos.csv")):
        rec_id, name = p["record"], p["staged"]
        row = {"photo": Path(p["original"]).name, "condition": p["condition"], "record": rec_id,
               "class": classes.get(rec_id, ""), "digitised": False, "snr_median": "", "snr_II": "",
               "urgency_image": "GREY", "hr_image": "", "urgency_truth": "", "hr_truth": "", "match": "", "variant": pack_rows.get(rec_id, {}).get("variant", "")}
        pred_path = out / name
        info = pack_rows.get(rec_id, {})
        variant = info.get("variant", "")      # "", bw, cols2, norhythm
        truth_path = pack / "truth" / (info.get("base_record") or rec_id)
        if rec_id and truth_path.with_suffix(".hea").exists():
            t = wfdb.rdrecord(str(truth_path))
            at = assess(lead(t), t.fs)
            row["urgency_truth"] = at.urgency.name
            row["hr_truth"] = round(at.rhythm.hr_bpm) if at.rhythm.hr_bpm else ""
        if pred_path.with_suffix(".hea").exists():
            pr = wfdb.rdrecord(str(pred_path))
            row["digitised"] = True
            ai = assess(lead(pr), pr.fs)
            row["urgency_image"] = ai.urgency.name
            row["hr_image"] = round(ai.rhythm.hr_bpm) if ai.rhythm.hr_bpm else ""
            # cols2 / norhythm pages place the leads differently, so the 3x4 SNR comparison does not apply
            if rec_id and truth_path.with_suffix(".hea").exists() and variant not in ("cols2", "norhythm"):
                s = score_page(leads(t), leads(pr), fs=int(t.fs))
                snr = np.array([x.snr_db for x in s], dtype=float)
                row["snr_median"] = round(float(np.nanmedian(snr)), 1) if snr.size else ""
                ii = [x.snr_db for x in s if x.lead == "II" and x.n > 2500]
                row["snr_II"] = round(ii[0], 1) if ii else ""
        if row["urgency_truth"]:
            ui, ut = row["urgency_image"], row["urgency_truth"]
            order = {"GREEN": 0, "YELLOW": 1, "RED": 2}
            row["match"] = ("same" if ui == ut else "grey" if ui == "GREY"
                            else "UNDER" if order.get(ui, 0) < order.get(ut, 0) else "over")
        rows.append(row)

    if not rows:
        sys.exit("no photos found")
    with open(work / "results.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)

    by = defaultdict(list)
    for r in rows:
        by[r["condition"]].append(r)
    print(f"\n{'condition':<12} {'n':>3} {'digitised':>9} {'SNR med':>8} {'same':>5} {'grey':>5} {'UNDER':>6} {'over':>5}")
    for cond, rr in sorted(by.items()):
        snr = [float(r["snr_median"]) for r in rr if r["snr_median"] != ""]
        cnt = lambda k: sum(1 for r in rr if r["match"] == k)  # noqa: E731
        print(f"{cond:<12} {len(rr):>3} {sum(r['digitised'] for r in rr):>9} "
              f"{(f'{np.median(snr):.1f}' if snr else '-'):>8} {cnt('same'):>5} {cnt('grey'):>5} "
              f"{cnt('UNDER'):>6} {cnt('over'):>5}")
    print(f"\nPer-photo results: {work / 'results.csv'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
