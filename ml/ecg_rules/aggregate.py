"""Urgency aggregation and top-level entry point.

Rules (research 01 s3 design rule; HAZARD_LIST H-05; spec v2 C-33):
  - highest urgency among triggered findings wins (RED > YELLOW > GREEN);
  - failed signal quality -> GREY ("cannot interpret") whatever the other rules say, so a
    poor-quality signal can never produce GREEN (nor a red from untrustworthy data).
This is the rule-based result only; ADR 0005 takes the max with the network output elsewhere.
"""
from __future__ import annotations

from dataclasses import dataclass

from . import rules
from .quality import check_quality
from .signal import Rhythm, analyse
from .types import RuleResult, Urgency

DISCLAIMER = "Decision support only, not a diagnosis. Thresholds are drafts pending cardiologist review."


@dataclass(frozen=True)
class Assessment:
    urgency: Urgency
    findings: list      # triggered rules (or the quality failure)
    quality: RuleResult
    all_results: list
    rhythm: Rhythm
    disclaimer: str = DISCLAIMER


def aggregate(quality: RuleResult, results: list) -> Urgency:
    if quality.triggered:
        return Urgency.GREY
    return max((x.urgency for x in results if x.triggered), default=Urgency.GREEN)


def assess(sig_mv, fs: float) -> Assessment:
    rhythm = analyse(sig_mv, fs)
    quality = check_quality(sig_mv, fs, rhythm)
    results = [rules.tachycardia(rhythm), rules.bradycardia(rhythm), rules.irregular_af(rhythm),
               rules.fast_wide_vt(rhythm), rules.very_slow_avb(rhythm)]
    findings = [quality] if quality.triggered else [x for x in results if x.triggered]
    return Assessment(aggregate(quality, results), findings, quality, results, rhythm)
