# Evaluation protocol

Status: **draft v0.1** · 2026-11-04 · Phase 2 deliverable. Replaces the accuracy targets of
the original spec (changes C-20, C-40, C-41 in [`spec/v2/CHANGELOG.md`](../spec/v2/CHANGELOG.md)).

**Rule:** this protocol is frozen *before* any model is trained. Changes after that are
allowed only as dated amendments at the end, with the reason. Thresholds marked
*(set after baseline)* are fixed once, from the baseline results on the validation data,
and never tuned on the test data.

## 1. What is evaluated

| Stage | Question | Input → output |
|---|---|---|
| S1 Digitiser | Does the recovered signal match the true one? | image → signal per lead |
| S2 Quality gate | Are bad photos rejected or flagged? | image → accept / retake |
| S3 Classifier | Are findings correct on clean digital signals? | signal → findings |
| S4 Measurements | Are rate and intervals right? | signal → HR, PR, QRS, QT/QTc |
| S5 End-to-end | Does photo → urgency work? | photo → findings + urgency colour |
| S6 Urgency | Is the final colour safe? | findings → 🔴/🟡/🟢/⚪ |

Each stage is evaluated alone (with ground-truth inputs) and end to end, so errors can be
attributed to the right stage.

## 2. Targets and labels

Findings, from the synthesis POC scope: atrial fibrillation/flutter, sinus tachycardia,
sinus bradycardia, complete AV block, ventricular tachycardia/fibrillation, LBBB, RBBB,
"possible acute ischaemia/occlusion", normal. Label mapping from SCP codes (PTB-XL) and
SNOMED codes (CinC 2021) is kept in `ml/labels/` as a versioned file, written once and
reviewed. Classes with too few positives (see [research 09](../research/09-dataset-followup.md):
VT 12, VF 97, 3rd-degree AV block 16 in PTB-XL) are reported as **"limited evidence"**: only
sensitivity with its confidence interval and the count, no claim of performance.

## 3. Data and splits

Rule: **split by patient, never by record or beat.**

| Use | Data | Notes |
|---|---|---|
| Train / val / internal test | PTB-XL, official 10 folds: 1–8 train, 9 val, 10 test | Fold 10 is touched only for final reporting |
| External test (digital) | CinC 2021 sources not used in training (e.g. hold out entire sources such as Georgia, CPSC) | Different hospitals and devices; source-level hold-out |
| Digitiser, synthetic | Images generated with ECG-Image-Kit from held-out signals | Several paper styles, noise, rotation, folds |
| Digitiser, real photos | Public photo sets (ECG-Image-Database, PM-ECG-ID: licence check, evaluation only) | Never used for training if used for testing |
| Own photos | Held-out signals printed and photographed by us on a 3-channel-style and a 12-lead layout, varied phones, light, angles | Minimum 100 photos, stratified; fixed before training |
| Local validation | Kyrgyz ECGs with cardiologist reading (Phase 5) | Separate, never used for tuning |

No test sample is used for threshold choice, model selection or augmentation design. A
single final run on each test set is reported; reruns are logged.

## 4. Metrics

**Classifier (S3), per class:** sensitivity, specificity, PPV, F1, AUROC, AUPRC, each with a
95 % confidence interval (patient-level bootstrap, 1000 resamples). Report prevalence and
counts next to every number. **Calibration:** reliability diagram and expected calibration
error. **Abstention:** fraction of cases returned as ⚪ "cannot interpret" and the
sensitivity/specificity on the rest. Overall accuracy is *not* a headline metric.

**Digitiser (S1):** SNR (dB) and Pearson correlation against the ground-truth signal per
lead after resampling and time alignment, plus error in amplitude (mV) and in R-peak
timing (ms). Report the median and the 10th percentile per condition (synthetic, real
photos, own photos), and the fraction of images where a lead could not be recovered.

**Measurements (S4):** mean error and 95 % limits of agreement (Bland-Altman) for heart rate,
PR, QRS, QT, QTc against reference annotations.

**Quality gate (S2):** on photos labelled good/bad by us: rate of bad photos accepted
(must be minimised) and of good photos rejected.

**End-to-end and urgency (S5, S6):** confusion matrix over urgency colours against the
reference urgency; **under-triage rate** (reference 🔴 predicted lower) reported separately
from over-triage. Reference urgency comes from labels via a fixed mapping until a
cardiologist reviews it (Phase 3 exit).

## 5. Comparison conditions

Every classifier and digitiser result is reported under:
1. clean digital signal (upper bound),
2. synthetic image → digitiser → classifier,
3. real public photos,
4. own photos,
5. reduced leads (3 and 6 channel layouts built from the 12-lead data, with lead dropout),
6. noise and robustness set: lighting, rotation, perspective, folds, resolution
   (≥ 5 MP and lower), JPEG compression.

Baselines: (a) 1D ResNet/Inception on PTB-XL, (b) the spec's CNN + BiLSTM, (c) a trivial
rule-based rate/regularity detector. The new method must beat (c) on the rhythm classes to
be worth keeping. Optionally a direct image classifier as an alternative to digitising.

## 6. Acceptance rules

Numbers are *(set after baseline)*. The structure is fixed now:

| Rule | Form |
|---|---|
| Safety first | For 🔴 classes (VT/VF, complete AV block, possible acute ischaemia; the exact 🔴 list follows the urgency mapping pending cardiologist review), sensitivity lower 95 % CI bound ≥ threshold T1 on digital data and ≥ T2 on photos; T2 ≤ T1 allowed only with an explicit abstention rule |
| Never green | Any case with quality below the gate, missing leads, or confidence below T3 is ⚪ or at least 🟡, never 🟢 |
| Under-triage | Under-triage rate on 🔴 cases ≤ T4 on every test condition |
| Digitiser | Median SNR ≥ T5 dB and 10th percentile ≥ T6 dB on the own-photo set, otherwise photo input is limited to rhythm claims or not released |
| Calibration | ECE ≤ T7 |
| Subgroups | Report by age band, sex, source and lead count; no subgroup with sensitivity far below the mean may be hidden |
| Reference points | Published results to compare, not to copy as targets: PTB-XL benchmark AUROC (≈ 0.93 superdiagnostic, ≈ 0.96 rhythm; [research 05](../research/05-classification.md)); Open-ECG-Digitizer photo SNR ≈ 10–12 dB; PhysioNet 2024 winners ≈ −1 dB on phone photos ([research 04](../research/04-digitisation.md)) |

If the digitiser rule fails, the product claim shrinks (rhythm only, or digital input
only); the claim never stretches to fit the result.

## 7. Reporting and reproducibility

- Fixed random seeds; library versions, dataset versions (PTB-XL v1.0.3) and commit hash of
  code recorded with each run in `ml/runs/` (git-ignored artifacts, committed summaries).
- A model card per released model: data, licences ([ADR 0001](../adr/0001-permissive-licence-policy.md)),
  metrics from this protocol, limitations, intended use ([safety](../safety/INTENDED_USE.md)).
- No patient data, real ECG photos or weights in git. Own-photo sets contain only
  public-dataset signals, not patient data.
- Negative results and failed conditions are reported, not dropped.

## 8. Clinical review

Before Phase 3 exit the urgency mapping and the reference urgency per label are reviewed by
a cardiologist (open question C1). Until then every urgency result is labelled
*research output*.

## Amendments

(none yet)
