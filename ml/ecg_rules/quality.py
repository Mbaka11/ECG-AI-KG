"""Signal-quality gate. Failure means 'cannot interpret' (grey), never green."""
from __future__ import annotations

import numpy as np
from scipy.signal import welch

from . import thresholds as T
from .signal import Rhythm
from .types import RuleResult, Urgency


def check_quality(sig_mv, fs: float, rhythm: Rhythm) -> RuleResult:
    sig = np.asarray(sig_mv, dtype=float)
    reasons: list[str] = []
    ev: dict = {}
    if len(sig) == 0 or not np.all(np.isfinite(sig)):
        reasons.append("empty or non-finite samples")
    else:
        dur = len(sig) / fs
        ptp = float(np.ptp(sig))
        ev.update(duration_s=dur, peak_to_peak_mv=ptp, n_beats=len(rhythm.peaks))
        if fs < T.MIN_SAMPLING_HZ:
            reasons.append("sampling rate too low")
        if dur < T.MIN_DURATION_S:
            reasons.append("recording too short")
        if ptp < T.FLATLINE_PTP_MV:
            reasons.append("flatline / no signal")
        else:
            tol = 1e-3 * ptp
            at_ext = (sig >= sig.max() - tol) | (sig <= sig.min() + tol)
            flat = np.r_[False, np.abs(np.diff(sig)) < 1e-9 * max(ptp, 1e-12)]
            clip = float(np.mean(at_ext & flat))
            ev["clip_fraction"] = clip
            if clip > T.CLIP_FRACTION:
                reasons.append("clipping / saturation")
            f, p = welch(sig - sig.mean(), fs=fs, nperseg=min(len(sig), int(2 * fs)))
            total = float(p.sum())
            hf = float(p[f >= T.HF_CUTOFF_HZ].sum() / total) if total > 0 else 1.0
            ev["hf_power_ratio"] = hf
            if hf > T.HF_NOISE_RATIO:
                reasons.append("high-frequency noise")
        if len(rhythm.peaks) < T.MIN_BEATS:
            reasons.append("too few beats detected")
        elif rhythm.hr_bpm is not None:
            lo, hi = T.RATE_PLAUSIBLE_BPM
            if not lo <= rhythm.hr_bpm <= hi:
                reasons.append("implausible heart rate (detector failure)")
    ev["failures"] = reasons
    bad = bool(reasons)
    return RuleResult(
        rule="signal_quality", triggered=bad,
        finding="Signal quality too low - cannot interpret" if bad else "Signal quality acceptable",
        urgency=Urgency.GREY if bad else Urgency.GREEN, evidence=ev,
        thresholds=dict(min_duration_s=T.MIN_DURATION_S, min_beats=T.MIN_BEATS,
                        flatline_ptp_mv=T.FLATLINE_PTP_MV, clip_fraction=T.CLIP_FRACTION,
                        hf_noise_ratio=T.HF_NOISE_RATIO, hf_cutoff_hz=T.HF_CUTOFF_HZ,
                        rate_plausible_bpm=T.RATE_PLAUSIBLE_BPM),
        source="PENDING_REVIEW (all quality thresholds are developer drafts); gate rule: ADR 0005, spec v2 C-33",
    )
