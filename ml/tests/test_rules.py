import dataclasses

import numpy as np
import pytest

import synth as S
from ecg_rules import Urgency, aggregate, assess, rules, thresholds as T
from ecg_rules.quality import check_quality
from ecg_rules.signal import Rhythm, analyse


def names(a):
    return {f.rule for f in a.findings}


@pytest.mark.parametrize("hr", [60, 75, 90, 120, 150])
def test_heart_rate_estimate(hr):
    r = analyse(S.sinus(hr), S.FS)
    assert abs(r.hr_bpm - hr) <= 3
    assert r.rr_cv < 0.05


def test_normal_sinus_is_green():
    a = assess(S.sinus(75), S.FS)
    assert a.urgency == Urgency.GREEN and not a.findings


def test_tachycardia_flag_and_yellow_above_130():
    a = assess(S.sinus(115), S.FS)
    assert "tachycardia" in names(a) and a.urgency == Urgency.GREEN  # 100-130: flagged, green (draft)
    a = assess(S.sinus(150), S.FS)
    assert "tachycardia" in names(a) and a.urgency == Urgency.YELLOW


def test_bradycardia_flag_green_between_40_and_60():
    a = assess(S.sinus(48), S.FS)
    assert "bradycardia" in names(a) and a.urgency == Urgency.GREEN


def test_very_slow_regular_rate_is_red_avb_screen():
    a = assess(S.sinus(30), S.FS)
    assert "very_slow_avb" in names(a) and a.urgency == Urgency.RED
    assert "possible high-grade AV block" in a.findings[-1].finding


def test_irregular_rhythm_flags_af_yellow():
    a = assess(S.af_like(), S.FS)
    assert "irregular_af" in names(a)
    assert a.urgency == Urgency.YELLOW
    assert "irregular_af" not in names(assess(S.sinus(80), S.FS))


def test_fast_wide_regular_is_red_vt_screen():
    a = assess(S.wide_fast(170), S.FS)
    assert "fast_wide_vt" in names(a) and a.urgency == Urgency.RED


def test_vt_screen_requires_measurable_qrs():
    r = analyse(S.sinus(170), S.FS, with_qrs=False)
    assert r.qrs_ms is None
    res = rules.fast_wide_vt(r)
    assert not res.triggered and "could not be estimated" in res.finding


def test_vt_rule_does_not_fire_for_narrow_fast_or_wide_slow():
    base = analyse(S.sinus(150), S.FS)
    assert not rules.fast_wide_vt(dataclasses.replace(base, qrs_ms=80.0)).triggered
    assert rules.fast_wide_vt(dataclasses.replace(base, qrs_ms=140.0)).triggered
    slow = analyse(S.sinus(70), S.FS)
    assert not rules.fast_wide_vt(dataclasses.replace(slow, qrs_ms=140.0)).triggered


def test_af_wide_fast_escalates_to_red():
    r = analyse(S.af_like(mean_rr=0.45), S.FS)
    r = dataclasses.replace(r, hr_bpm=140.0, qrs_ms=140.0)
    assert rules.irregular_af(r).urgency == Urgency.RED


@pytest.mark.parametrize("make,reason", [
    (lambda: S.flatline(), "flatline"),
    (lambda: S.clipped(), "clipping"),
    (lambda: S.noisy(), "noise"),
    (lambda: S.sinus(75, duration=2), "short"),
    (lambda: np.zeros(0), "empty"),
    (lambda: np.full(3000, np.nan), "non-finite"),
])
def test_quality_failures_give_grey(make, reason):
    sig = make()
    a = assess(sig, S.FS)
    assert a.quality.triggered, reason
    assert a.urgency == Urgency.GREY
    assert a.findings == [a.quality]


def test_too_few_beats_is_grey():
    sig = S.from_rr(np.array([1.5, 1.5]), duration=12)
    a = assess(sig, S.FS)
    assert a.urgency == Urgency.GREY


def test_low_sampling_rate_is_grey():
    a = assess(S.sinus(75)[::5], S.FS / 5)
    assert a.urgency == Urgency.GREY


@pytest.mark.parametrize("bad", [S.flatline(), S.clipped(), S.noisy(), np.zeros(10)])
def test_aggregator_never_green_when_quality_fails(bad):
    a = assess(bad, S.FS)
    assert a.urgency != Urgency.GREEN


def test_aggregate_grey_overrides_even_if_all_rules_green():
    r = analyse(S.sinus(75), S.FS)
    ok = [rules.tachycardia(r), rules.bradycardia(r)]
    bad_q = dataclasses.replace(check_quality(S.sinus(75), S.FS, r), triggered=True, urgency=Urgency.GREY)
    assert aggregate(bad_q, ok) == Urgency.GREY
    good_q = check_quality(S.sinus(75), S.FS, r)
    assert aggregate(good_q, ok) == Urgency.GREEN


def test_highest_urgency_wins():
    r = analyse(S.sinus(75), S.FS)
    q = check_quality(S.sinus(75), S.FS, r)
    mk = lambda u: dataclasses.replace(rules.tachycardia(r), triggered=True, urgency=u)
    assert aggregate(q, [mk(Urgency.GREEN), mk(Urgency.RED), mk(Urgency.YELLOW)]) == Urgency.RED
    assert aggregate(q, [mk(Urgency.GREEN), mk(Urgency.YELLOW)]) == Urgency.YELLOW


def test_every_triggered_result_has_evidence_thresholds_and_source():
    for sig in (S.sinus(150), S.af_like(), S.sinus(30), S.wide_fast(170)):
        for f in assess(sig, S.FS).findings:
            assert f.evidence and f.thresholds and f.source
