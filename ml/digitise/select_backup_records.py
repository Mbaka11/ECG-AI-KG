"""Pick extra PTB-XL records for the backup pages of the print pack (pages 25-48).

Rules (all deterministic, seed 11):
- only records of PTB-XL `strat_fold` 10 (the authors' test fold),
- validated by a human, no noise flags (baseline drift, static noise, burst noise, electrode
  problems), except for the PVC class where `extra_beats` is the point,
- the target SCP code has likelihood >= 80 (rhythm codes: present) and is the only code on the
  record (normal-ECG and sinus-rhythm tags are ignored for the rhythm targets),
- age 89 or less,
- records already in the first 24 pages are skipped.

Usage (any env with pandas):
    python select_backup_records.py PTBXL_DIR FIRST_SELECTION_CSV OUT_CSV
PTBXL_DIR needs ptbxl_database.csv. OUT_CSV has the same columns as FIRST_SELECTION_CSV
(cls,file,age,sex) plus a `variant` column. It holds the first selection, the new records and the
variant pages, in that order.
"""

from __future__ import annotations

import ast
import csv
import sys
from pathlib import Path

import pandas as pd

RHYTHM = {"STACH", "SVTAC", "SBRAD"}

# Variant pages 49-54 re-render a record of the first 24 pages in another look: "bw" = black-and-white
# page, "cols2" = 6 rows x 2 columns plus rhythm strip, "norhythm" = 3x4 without the rhythm strip.
VARIANTS = [("NORM", "bw"), ("AFIB", "bw"), ("AMI", "cols2"), ("AFIB", "cols2"), ("IMI", "norhythm"), ("CLBBB", "norhythm")]

# SCP code -> number of records. Weighted towards what the rules and the app must not miss.
QUOTA = {
    "NORM": 3, "AFIB": 3, "AFLT": 1, "AMI": 2, "ASMI": 2, "ALMI": 1, "IMI": 1,
    "CLBBB": 2, "CRBBB": 1, "STACH": 1, "SVTAC": 1, "SBRAD": 1, "1AVB": 1,
    "LVH": 1, "WPW": 1, "PVC": 1, "ISCAL": 1,
}


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        sys.exit(__doc__)
    ptbxl, first_csv, out_csv = Path(argv[0]), Path(argv[1]), Path(argv[2])
    first = list(csv.DictReader(open(first_csv, encoding="utf-8")))
    used = {Path(r["file"]).name for r in first}

    db = pd.read_csv(ptbxl / "ptbxl_database.csv")
    db = db[(db.strat_fold == 10) & (db.validated_by_human == True)]  # noqa: E712
    db = db.assign(rec=db.filename_hr.map(lambda f: Path(f).name))
    db = db[~db.rec.isin(used) & (db.age <= 89)]  # PTB-XL stores 300 for ages over 89
    db = db.assign(codes=db.scp_codes.map(ast.literal_eval))
    flagged = db[["baseline_drift", "static_noise", "burst_noise", "electrodes_problems"]].notna().any(axis=1)

    rows = []
    for code, n in QUOTA.items():
        ignore = {"SR", "NORM"} if code in RHYTHM else {"SR"}
        # rhythm statements carry likelihood 0 in PTB-XL (presence is what counts); anterolateral MI
        # records usually also carry other infarct codes, so they are allowed up to three.
        lo, cap = (0, 1) if code in RHYTHM else (80, 3 if code == "ALMI" else 1)
        only = db.codes.map(lambda c, k=code, ig=ignore: k in c and c[k] >= lo and sum(v >= 50 for kk, v in c.items() if kk not in ig) <= cap and (c[k] >= 50 or k in RHYTHM))
        pool = db[only & (db.extra_beats.notna() if code == "PVC" else ~flagged)]
        pool = pool[pool.pacemaker.isna()]
        if len(pool) < n:
            print(f"WARNING: only {len(pool)} candidates for {code}, wanted {n}")
        for _, r in pool.sample(min(n, len(pool)), random_state=11).iterrows():
            rows.append({"cls": code, "file": r.filename_hr, "age": r.age, "sex": r.sex})
    with open(out_csv, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=["cls", "file", "age", "sex", "variant"])
        w.writeheader()
        w.writerows([{**r, "variant": ""} for r in first + rows])
        for cls, variant in VARIANTS:
            src = next(r for r in first if r["cls"] == cls)
            first.remove(src)  # use a different record for each variant of the same class
            w.writerow({**src, "variant": variant})
    print(f"{len(rows)} new + {len(VARIANTS)} variant pages -> {out_csv}")
    for r in rows:
        print(f"  {r['cls']:6} {r['file']}  age {r['age']} sex {r['sex']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
