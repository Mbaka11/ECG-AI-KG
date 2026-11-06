import numpy as np
import pytest

from digitise.metrics import plotted_part, score_at, score_page

FS = 500


def _ecg_like(n: int, seed: int = 0) -> np.ndarray:
    rng = np.random.default_rng(seed)
    t = np.arange(n) / FS
    x = 0.1 * np.sin(2 * np.pi * 1.2 * t)
    x[(np.arange(n) % 400) == 50] += 1.0  # spikes every 0.8 s
    return np.convolve(x, np.hanning(15), mode="same") + 0.01 * rng.standard_normal(n)


def test_identical_signal_is_infinite_snr_and_r_one():
    x = _ecg_like(1250)
    snr, r, lag = score_at(x, x)
    assert snr == np.inf and r == pytest.approx(1.0) and lag == 0


def test_baseline_offset_is_ignored():
    x = _ecg_like(1250)
    snr, r, _ = score_at(x, x + 3.0)
    assert snr > 100 and r == pytest.approx(1.0)  # float residue only


def test_lag_is_found():
    x = _ecg_like(5000)
    pred = x[1270 : 1270 + 1250]  # printed 20 samples late in column 1
    snr, r, lag = score_at(x, pred, start=1250, max_lag=50)
    assert lag == 20 and snr == np.inf


def test_known_noise_level_gives_expected_snr():
    x = _ecg_like(5000)
    rng = np.random.default_rng(1)
    noise = rng.standard_normal(5000)
    noise *= np.sqrt(np.sum((x - x.mean()) ** 2) / np.sum(noise**2)) / np.sqrt(10)  # 10 dB
    snr, _, _ = score_at(x, x + noise, max_lag=0)
    assert snr == pytest.approx(10.0, abs=0.5)


def test_plotted_part_drops_padding():
    x = np.r_[np.ones(10), np.zeros(5), np.full(3, np.nan)]
    assert len(plotted_part(x)) == 10


def test_score_page_uses_columns_and_rhythm_strip():
    truth = {k: _ecg_like(5000, seed=i) for i, k in enumerate(["II", "aVF", "V6"])}
    pred = {
        "II": truth["II"],                                  # full 10 s rhythm strip
        "aVF": np.r_[truth["aVF"][1250:2500], np.zeros(3750)],  # column 1, zero-padded
        "V6": np.r_[truth["V6"][3750:5000], np.zeros(3750)],    # column 3
    }
    scores = {s.lead: s for s in score_page(truth, pred, fs=FS)}
    assert all(s.snr_db == np.inf and s.lag == 0 for s in scores.values())
    assert scores["II"].n == 5000 and scores["aVF"].n == 1250
