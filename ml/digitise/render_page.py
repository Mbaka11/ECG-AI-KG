"""Render a 12-lead WFDB record as a synthetic paper ECG page (ground truth for digitiser tests).

Layout follows the assumptions of the pretrained ECG-Digitiser weights (PhysioNet 2024 /
ecg-image-kit style): three rows of four 2.5 s leads (I aVR V1 V4 / II aVL V2 V5 / III aVF V3 V6),
a 10 s lead II rhythm strip, lead names below the start of each trace, 25 mm/s, 10 mm/mV,
US-letter landscape at 200 dpi (2200 x 1700 px).

This is a simple renderer, not ecg-image-kit: no handwriting, wrinkles or headers. It is good
enough for a smoke test, not for measuring robustness.

Usage:
    python render_page.py RECORD_PATH OUT.png        # RECORD_PATH without extension
"""

from __future__ import annotations

import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
import wfdb  # noqa: E402

ROWS = [["I", "aVR", "V1", "V4"], ["II", "aVL", "V2", "V5"], ["III", "aVF", "V3", "V6"]]
RHYTHM = "II"
DPI = 200
PAGE_W_MM, PAGE_H_MM = 279.4, 215.9  # US letter, landscape
X0_MM = 15.0  # left margin of traces
ROW_GAP_MM = 42.0  # baseline-to-baseline
TOP_MM = 45.0  # first baseline from top


def _lead(record: wfdb.Record, name: str) -> np.ndarray:
    names = [n.upper() for n in record.sig_name]
    return record.p_signal[:, names.index(name.upper())]


def render(record_path: str, out_png: str) -> None:
    rec = wfdb.rdrecord(record_path)
    fs = rec.fs
    fig = plt.figure(figsize=(PAGE_W_MM / 25.4, PAGE_H_MM / 25.4), dpi=DPI)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, PAGE_W_MM)
    ax.set_ylim(PAGE_H_MM, 0)  # y grows downwards, in mm
    ax.axis("off")
    fig.patch.set_facecolor("white")

    # Grid: 1 mm minor, 5 mm major.
    for mm in np.arange(0, PAGE_W_MM, 1.0):
        ax.axvline(mm, color="#f4b6b6" if mm % 5 else "#e07070", lw=0.3 if mm % 5 else 0.7, zorder=0)
    for mm in np.arange(0, PAGE_H_MM, 1.0):
        ax.axhline(mm, color="#f4b6b6" if mm % 5 else "#e07070", lw=0.3 if mm % 5 else 0.7, zorder=0)

    def draw(sig: np.ndarray, t0: float, dur: float, x_mm: float, base_mm: float, label: str) -> None:
        a, b = int(t0 * fs), int((t0 + dur) * fs)
        seg = sig[a:b]
        x = x_mm + np.arange(len(seg)) / fs * 25.0
        y = base_mm - np.nan_to_num(seg) * 10.0
        ax.plot(x, y, color="black", lw=0.9, zorder=2)
        ax.text(x_mm + 1, base_mm + 6, label, fontsize=9, zorder=3)

    for r, leads in enumerate(ROWS):
        base = TOP_MM + r * ROW_GAP_MM
        for c, name in enumerate(leads):
            draw(_lead(rec, name), c * 2.5, 2.5, X0_MM + c * 62.5, base, name)
    draw(_lead(rec, RHYTHM), 0.0, 10.0, X0_MM, TOP_MM + 3 * ROW_GAP_MM, RHYTHM)

    fig.savefig(out_png, dpi=DPI, facecolor="white")
    plt.close(fig)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    render(sys.argv[1], sys.argv[2])
