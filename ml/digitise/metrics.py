"""Digitiser metrics (docs/eval/PROTOCOL.md, stage S1): SNR in dB and Pearson r per lead.

A digitised lead is compared with the ground truth starting at its expected position on the
page (`start`, in samples) shifted by the best lag within +/- max_lag samples, after removing
each signal's mean (the paper baseline is arbitrary). This is close to, but not identical with,
the PhysioNet 2024 scoring; report it as "SNR (project definition)".
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

# Standard 3x4 page: which 2.5 s column each lead is printed in.
COLUMN_OF = {
    "I": 0, "II": 0, "III": 0,
    "aVR": 1, "aVL": 1, "aVF": 1,
    "V1": 2, "V2": 2, "V3": 2,
    "V4": 3, "V5": 3, "V6": 3,
}


@dataclass(frozen=True)
class LeadScore:
    lead: str
    snr_db: float
    r: float
    lag: int
    n: int


def plotted_part(x: np.ndarray) -> np.ndarray:
    """Digitised leads are zero/NaN-padded after the plotted part; keep the plotted prefix."""
    x = np.nan_to_num(np.asarray(x, dtype=float))
    nz = np.flatnonzero(x != 0)
    return x[: nz[-1] + 1] if nz.size else x[:0]


def score_at(truth: np.ndarray, pred: np.ndarray, start: int = 0, max_lag: int = 50,
             min_len: int = 10) -> tuple[float, float, int]:
    """Best (SNR dB, Pearson r, lag) comparing pred with truth[start+lag : start+lag+len]."""
    truth = np.asarray(truth, dtype=float)
    pred = np.asarray(pred, dtype=float)
    best = (-np.inf, float("nan"), 0)
    for lag in range(-max_lag, max_lag + 1):
        s = start + lag
        if s < 0:
            continue
        m = min(len(pred), len(truth) - s)
        if m < min_len:
            continue
        t = truth[s : s + m] - truth[s : s + m].mean()
        p = pred[:m] - pred[:m].mean()
        noise = float(np.sum((t - p) ** 2))
        snr = 10 * np.log10(float(np.sum(t**2)) / noise) if noise > 0 else np.inf
        if snr > best[0]:
            r = float(np.corrcoef(t, p)[0, 1]) if t.std() > 0 and p.std() > 0 else float("nan")
            best = (float(snr), r, lag)
    if best[0] == -np.inf:
        return float("nan"), float("nan"), 0
    return best


def score_page(truth: dict[str, np.ndarray], pred: dict[str, np.ndarray], fs: int,
               rhythm_lead: str = "II", max_lag: int = 50) -> list[LeadScore]:
    """Score each predicted lead of a 3x4 + rhythm page against the 10 s ground truth.

    A lead longer than 1.5 columns is treated as the rhythm strip (starts at 0 s); others are
    compared with the 2.5 s window of their column.
    """
    seg = int(2.5 * fs)
    out: list[LeadScore] = []
    for lead, raw in pred.items():
        if lead not in truth:
            continue
        p = plotted_part(raw)
        long_strip = lead == rhythm_lead and len(p) > 1.5 * seg
        start = 0 if long_strip else COLUMN_OF.get(lead, 0) * seg
        snr, r, lag = score_at(truth[lead], p, start=start, max_lag=max_lag)
        out.append(LeadScore(lead, snr, r, lag, len(p)))
    return out
