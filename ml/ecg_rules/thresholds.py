"""Every numeric threshold used by the rules, in one place.

Each entry has a source comment. Status:
  CITED           - value comes from a cited document (research note / guideline).
  PENDING_REVIEW  - draft value chosen by the developer; NOT cited; needs cardiologist
                    review (OPEN_QUESTIONS C1 / item 5) and evaluation on PTB-XL per
                    docs/eval/PROTOCOL.md.
Do not add numbers elsewhere in the package.
"""

CITED = "CITED"
PENDING_REVIEW = "PENDING_REVIEW"

# --- Rate -------------------------------------------------------------------
# docs/research/01-clinical-domain.md s1 table / s2.6: <60 bradycardia, >100 tachycardia
# (textbook definitions; the note itself marks them Unverified).
TACHY_BPM = 100.0
BRADY_BPM = 60.0
# research 01 s3 table: sinus tachycardia yellow if >130 (draft, for cardiologist review).
TACHY_YELLOW_BPM = 130.0
# research 01 s3 table: bradycardia escalates if HR <40 (draft, for cardiologist review).
BRADY_YELLOW_BPM = 40.0

# --- AF screen (irregularly irregular) --------------------------------------
# PENDING_REVIEW: no cited value. RR coefficient of variation (SD/mean) and RMSSD/mean RR
# must both exceed these to flag "irregular rhythm - possible AF".
AF_RR_CV = 0.12                 # PENDING_REVIEW
AF_RMSSD_RATIO = 0.15           # PENDING_REVIEW
AF_MIN_BEATS = 8                # PENDING_REVIEW (a strip is about 10 s)
# research 01 s3 table (draft): "rapid" AF is >110-120 bpm; red if rapid AND wide QRS (s2.2).
AF_RAPID_BPM = 110.0

# --- VT screen --------------------------------------------------------------
# research 01 s2.4: VT = >=3 consecutive beats, rate >100, QRS >120 ms (PMC10541285,
# PMC8804484); regular wide-complex tachycardia treated as VT. QRS >=120 ms = wide (s1).
VT_MIN_BPM = 100.0
WIDE_QRS_MS = 120.0
VT_MIN_BEATS = 3
VT_REGULAR_RR_CV = 0.10         # PENDING_REVIEW: "regular" means RR CV below this
QRS_AMP_FRACTION = 0.15         # PENDING_REVIEW: width measured at this fraction of R height (uncalibrated)
QRS_PLAUSIBLE_MS = (15.0, 300.0)  # PENDING_REVIEW: estimates outside are treated as unmeasurable

# --- Very slow rate: possible high-grade AV block ---------------------------
# research 01 s2.5: slow regular escape rhythm. Numeric cut-off: s3 table uses HR <40 as the
# bradycardia escalation point (draft). One lead cannot show P waves: screen only.
AVB_MAX_BPM = 40.0
AVB_REGULAR_RR_CV = 0.10        # PENDING_REVIEW

# --- Signal quality ---------------------------------------------------------
MIN_DURATION_S = 4.0            # PENDING_REVIEW
MIN_BEATS = 4                   # PENDING_REVIEW
FLATLINE_PTP_MV = 0.05          # PENDING_REVIEW: peak-to-peak below this = no signal
CLIP_FRACTION = 0.02            # PENDING_REVIEW: >2 % of samples flat (repeated identical value) at the min or max
HF_NOISE_RATIO = 0.35           # PENDING_REVIEW: power above HF_CUTOFF_HZ / total power
HF_CUTOFF_HZ = 40.0             # PENDING_REVIEW
RATE_PLAUSIBLE_BPM = (20.0, 300.0)  # PENDING_REVIEW: outside = detector failure
MIN_SAMPLING_HZ = 100.0         # PENDING_REVIEW (ADR 0005 plans 100-250 Hz input)
