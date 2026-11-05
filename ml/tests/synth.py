"""Synthetic single-lead signals for tests (NeuroKit2 only; no patient data)."""
import neurokit2 as nk
import numpy as np

FS = 250


def sinus(hr, duration=12, noise=0.0, seed=1):
    return nk.ecg_simulate(duration=duration, sampling_rate=FS, heart_rate=hr,
                           noise=noise, random_state=seed, heart_rate_std=0)


def _template(stretch=1.0):
    """One beat (0.3 s before R, 0.4 s after), from a 60 bpm simulation, optionally time-stretched."""
    s = nk.ecg_simulate(duration=8, sampling_rate=FS, heart_rate=60, noise=0, random_state=3, heart_rate_std=0)
    _, info = nk.ecg_peaks(s, sampling_rate=FS)
    r = int(info["ECG_R_Peaks"][3])
    b = s[r - int(0.3 * FS): r + int(0.4 * FS)]
    if stretch != 1.0:
        n = int(len(b) * stretch)
        b = np.interp(np.linspace(0, len(b) - 1, n), np.arange(len(b)), b)
        r0 = int(0.3 * FS * stretch)
    else:
        r0 = int(0.3 * FS)
    return b * np.hanning(len(b)) ** 0.2, r0


def from_rr(rr_s, stretch=1.0, duration=None):
    """Place template beats at the given RR intervals."""
    b, r0 = _template(stretch)
    t = np.concatenate([[0.5], 0.5 + np.cumsum(rr_s)])
    n = int((t[-1] + 1.0) * FS) if duration is None else int(duration * FS)
    sig = np.zeros(n)
    for ti in t:
        i = int(ti * FS) - r0
        lo, hi = max(i, 0), min(i + len(b), n)
        if hi > lo:
            sig[lo:hi] += b[lo - i: hi - i]
    return sig


def af_like(mean_rr=0.7, n=18, seed=0):
    rng = np.random.default_rng(seed)
    return from_rr(rng.uniform(0.45, 1.0, n) * (mean_rr / 0.725))


def wide_fast(hr=170, n=30, sigma_ms=40.0):
    """Regular train of broad Gaussian complexes (crude VT-like morphology)."""
    rr = 60.0 / hr
    t = np.arange(int((n * rr + 1.0) * FS)) / FS
    sig = np.zeros_like(t)
    for k in range(n):
        sig += 1.2 * np.exp(-0.5 * ((t - 0.5 - k * rr) / (sigma_ms / 1000.0)) ** 2)
    return sig - 0.1 * np.sin(2 * np.pi * 0.3 * t)


def flatline(duration=12, level=0.0):
    return np.full(int(duration * FS), level)


def clipped(hr=75, limit=0.4):
    return np.clip(sinus(hr), -limit, limit)


def noisy(hr=75, sd=1.5, seed=0):
    rng = np.random.default_rng(seed)
    s = sinus(hr)
    return s + rng.normal(0, sd, len(s))
