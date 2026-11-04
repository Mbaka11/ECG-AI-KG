"""R-peak detection and rhythm metrics for a single lead (mV)."""
from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from . import thresholds as T


@dataclass(frozen=True)
class Rhythm:
    fs: float
    peaks: np.ndarray          # sample indices of R peaks
    rr_s: np.ndarray           # RR intervals, seconds
    hr_bpm: float | None       # from median RR (robust)
    rr_cv: float | None        # SD/mean of RR
    rmssd_ratio: float | None  # RMSSD/mean RR
    qrs_ms: float | None       # median QRS width, None if not measurable


def _clean(sig: np.ndarray, fs: float) -> np.ndarray:
    import neurokit2 as nk
    return nk.ecg_clean(sig, sampling_rate=int(fs), method="neurokit")


def detect_r_peaks(sig: np.ndarray, fs: float) -> np.ndarray:
    import neurokit2 as nk
    try:
        _, info = nk.ecg_peaks(_clean(sig, fs), sampling_rate=int(fs), method="neurokit")
        return np.asarray(info["ECG_R_Peaks"], dtype=int)
    except Exception:
        return np.array([], dtype=int)


def estimate_qrs_ms(sig: np.ndarray, fs: float, peaks: np.ndarray) -> float | None:
    """Median width of the main R deflection at QRS_AMP_FRACTION of its height.

    Crude and NOT calibrated against annotated QRS durations (see README): it measures the
    width of the dominant deflection around each R peak after removing the local median.
    Returns None when fewer than 2 beats are measurable or the value is implausible.
    """
    if len(peaks) < 3:
        return None
    half = int(0.25 * fs)
    widths = []
    for r in peaks[1:-1]:
        seg = sig[max(r - half, 0): r + half]
        k = min(int(r), half)
        a = np.abs(seg - np.median(seg))
        thr = T.QRS_AMP_FRACTION * a[max(k - 3, 0): k + 4].max()
        if thr <= 0:
            continue
        i = k
        while i > 0 and a[i - 1] > thr:
            i -= 1
        j = k
        while j < len(a) - 1 and a[j + 1] > thr:
            j += 1
        widths.append((j - i + 1) / fs * 1000.0)
    if len(widths) < 2:
        return None
    q = float(np.median(widths))
    lo, hi = T.QRS_PLAUSIBLE_MS
    return q if lo <= q <= hi else None


def analyse(sig_mv, fs: float, with_qrs: bool = True) -> Rhythm:
    sig = np.asarray(sig_mv, dtype=float)
    ok = len(sig) > 0 and np.all(np.isfinite(sig)) and np.ptp(sig) > 0
    peaks = detect_r_peaks(sig, fs) if ok else np.array([], dtype=int)
    rr = np.diff(peaks) / fs
    if len(rr) == 0:
        return Rhythm(fs, peaks, rr, None, None, None, None)
    mean = float(np.mean(rr))
    hr = 60.0 / float(np.median(rr))
    cv = float(np.std(rr) / mean)
    rmssd = float(np.sqrt(np.mean(np.diff(rr) ** 2))) / mean if len(rr) > 1 else None
    qrs = estimate_qrs_ms(sig, fs, peaks) if with_qrs else None
    return Rhythm(fs, peaks, rr, hr, cv, rmssd, qrs)
