"""Individual rhythm rules. Each returns a RuleResult; none looks at other rules."""
from __future__ import annotations

from . import thresholds as T
from .signal import Rhythm
from .types import RuleResult, Urgency

_R01 = "docs/research/01-clinical-domain.md"


def _none(rule: str, why: str) -> RuleResult:
    return RuleResult(rule, False, f"Not evaluated: {why}", Urgency.GREEN, {}, {}, "n/a")


def tachycardia(r: Rhythm) -> RuleResult:
    if r.hr_bpm is None:
        return _none("tachycardia", "no heart rate")
    hit = r.hr_bpm > T.TACHY_BPM
    urg = Urgency.YELLOW if r.hr_bpm > T.TACHY_YELLOW_BPM else Urgency.GREEN
    return RuleResult(
        "tachycardia", hit,
        "Fast heart rate (tachycardia; sinus origin not confirmed from one lead)" if hit else "Rate not fast",
        urg if hit else Urgency.GREEN, dict(hr_bpm=r.hr_bpm),
        dict(tachy_bpm=T.TACHY_BPM, yellow_above_bpm=T.TACHY_YELLOW_BPM),
        f"{_R01} s2.6, s3 (definitions Unverified; yellow cut-off draft, pending cardiologist review)")


def bradycardia(r: Rhythm) -> RuleResult:
    if r.hr_bpm is None:
        return _none("bradycardia", "no heart rate")
    hit = r.hr_bpm < T.BRADY_BPM
    urg = Urgency.YELLOW if r.hr_bpm < T.BRADY_YELLOW_BPM else Urgency.GREEN
    return RuleResult(
        "bradycardia", hit,
        "Slow heart rate (bradycardia; sinus origin not confirmed from one lead)" if hit else "Rate not slow",
        urg if hit else Urgency.GREEN, dict(hr_bpm=r.hr_bpm),
        dict(brady_bpm=T.BRADY_BPM, yellow_below_bpm=T.BRADY_YELLOW_BPM),
        f"{_R01} s2.6, s3 (definitions Unverified; yellow cut-off draft, pending cardiologist review)")


def irregular_af(r: Rhythm) -> RuleResult:
    th = dict(rr_cv=T.AF_RR_CV, rmssd_ratio=T.AF_RMSSD_RATIO, min_beats=T.AF_MIN_BEATS, rapid_bpm=T.AF_RAPID_BPM)
    src = f"PENDING_REVIEW (irregularity cut-offs uncited); urgency draft from {_R01} s2.2, s3"
    if r.rr_cv is None or r.rmssd_ratio is None or len(r.peaks) < T.AF_MIN_BEATS:
        return RuleResult("irregular_af", False, "Not evaluated: too few beats", Urgency.GREEN,
                          dict(n_beats=len(r.peaks)), th, src)
    hit = r.rr_cv > T.AF_RR_CV and r.rmssd_ratio > T.AF_RMSSD_RATIO
    urg = Urgency.GREEN
    if hit:
        wide_fast = (r.hr_bpm or 0) > T.AF_RAPID_BPM and r.qrs_ms is not None and r.qrs_ms >= T.WIDE_QRS_MS
        urg = Urgency.RED if wide_fast else Urgency.YELLOW
    return RuleResult(
        "irregular_af", hit,
        "Irregular rhythm - possible AF (suspected, needs clinician confirmation)" if hit else "RR intervals regular enough",
        urg, dict(rr_cv=r.rr_cv, rmssd_ratio=r.rmssd_ratio, hr_bpm=r.hr_bpm, qrs_ms=r.qrs_ms), th, src)


def fast_wide_vt(r: Rhythm) -> RuleResult:
    th = dict(min_bpm=T.VT_MIN_BPM, wide_qrs_ms=T.WIDE_QRS_MS, min_beats=T.VT_MIN_BEATS,
              regular_rr_cv=T.VT_REGULAR_RR_CV)
    src = (f"{_R01} s2.4 (rate >100, QRS >=120 ms, >=3 beats; PMC10541285); regularity cut-off "
           "PENDING_REVIEW. Unverified on photo-derived data")
    if r.qrs_ms is None or r.hr_bpm is None or r.rr_cv is None:
        return RuleResult("fast_wide_vt", False, "Not evaluated: QRS width could not be estimated",
                          Urgency.GREEN, dict(qrs_ms=r.qrs_ms, hr_bpm=r.hr_bpm), th, src)
    hit = (r.hr_bpm > T.VT_MIN_BPM and r.qrs_ms >= T.WIDE_QRS_MS
           and len(r.peaks) >= T.VT_MIN_BEATS and r.rr_cv < T.VT_REGULAR_RR_CV)
    return RuleResult(
        "fast_wide_vt", hit,
        "Very fast, regular, broad-complex rhythm - possible VT" if hit else "No fast wide-complex pattern",
        Urgency.RED if hit else Urgency.GREEN,
        dict(hr_bpm=r.hr_bpm, qrs_ms=r.qrs_ms, rr_cv=r.rr_cv), th, src)


def very_slow_avb(r: Rhythm) -> RuleResult:
    th = dict(max_bpm=T.AVB_MAX_BPM, regular_rr_cv=T.AVB_REGULAR_RR_CV)
    src = (f"{_R01} s2.5, s3 (slow regular escape rhythm; HR <40 cut-off draft); P waves not "
           "assessable from one lead; PENDING_REVIEW")
    if r.hr_bpm is None or r.rr_cv is None:
        return RuleResult("very_slow_avb", False, "Not evaluated: no heart rate", Urgency.GREEN, {}, th, src)
    hit = r.hr_bpm < T.AVB_MAX_BPM and r.rr_cv < T.AVB_REGULAR_RR_CV
    return RuleResult(
        "very_slow_avb", hit,
        "Very slow regular rate - possible high-grade AV block" if hit else "No very slow regular rhythm",
        Urgency.RED if hit else Urgency.GREEN, dict(hr_bpm=r.hr_bpm, rr_cv=r.rr_cv), th, src)
