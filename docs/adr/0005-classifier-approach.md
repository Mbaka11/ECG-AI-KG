# ADR 0005 — Classifier approach: small 1D CNN plus rule-based safety net

Status: proposed (2026-11-04; revisable after the Phase 3 baseline) · Phase 2

## Context
A plain 1D ResNet/Inception reaches PTB-XL macro-AUROC of about 0.93 (superdiagnostic) and
0.96 (rhythm); foundation models give modest gains in independent benchmarks
([research 05](../research/05-classification.md)). The spec's "98-99.4 % on MIT-BIH with
CNN+BiLSTM" is intra-patient and not meaningful (C-20, C-24). Critical classes have few
examples: PTB-XL has 16 complete AV block and no VT/VF; CinC 2021 has 12 VT, 97 VF and 127
complete heart block ([research 09](../research/09-dataset-followup.md)). STEMI criteria miss
about half of acute occlusions ([synthesis](../research/00-synthesis.md), from research 01).
Inputs will be digitised, noisy, short (about 2.5 s per lead) and sometimes only 1-6 leads.
ECGFounder and ECG-FM weights are MIT; HuBERT-ECG is CC BY-NC and ECG-JEPA weight licence is
unclear (research 05).

## Decision
- **Baseline:** XResNet1D-18 / Inception1D from the PTB-XL benchmark code, input at 100-250 Hz,
  3x4 layout segments plus an optional rhythm strip. Train on PTB-XL folds 1-8; test per the
  [evaluation protocol](../eval/PROTOCOL.md).
- **Comparison:** the spec's CNN+BiLSTM under the same protocol; keep it only if it beats the
  baseline on a patient-wise split.
- **Robustness training:** random lead dropout (matches 3/6-channel strips and unrecoverable
  leads) and augmentation mimicking digitiser errors (baseline wander, gridline residue, scale
  error, time jitter). Labels that need 12 leads are masked when fewer leads are present.
- **Uncertainty:** temperature scaling on a patient-wise validation set, a 3-5 seed ensemble
  or MC-dropout, and the digitiser quality gate in front. Low confidence maps to "cannot
  interpret" or at least yellow, never green (research 05 s7; C-33).
- **Rule-based safety net, independent of the network:** R-peak detection (NeuroKit2 or wfdb,
  both MIT) for rate, regularity and brady/tachycardia; irregularly-irregular rhythm checks
  for "suspected AF" (C-35); fast wide-complex rhythm for VT; dissociated P/QRS or a very slow
  regular ventricular rate for complete AV block; transparent ST criteria for "possible acute
  ischaemia - refer" only with 12 identified leads. Final urgency is the highest of network
  and rules. Rule thresholds are drafts pending cardiologist review (C1). Rules for VT and AV
  block are unverified on photo-derived data and must be evaluated, not assumed.
- **Foundation models:** not shipped in v1. ECGFounder or ECG-FM (MIT) may serve only as
  teachers for distillation or as linear-probe baselines, after checking the licence of each
  checkpoint and of its training data (not yet checked; track in the SOUP table). HuBERT-ECG
  is excluded.
- **Classes with too little data** (VT/VF, 3rd-degree AV block, STEMI) are reported as
  "limited evidence" and rely mainly on rules plus a conservative urgent path.
- **No LLM** in classification or in the report path (C-28).

## Consequences
Small model (1-5 MB int8 per research 05), easy to run on-device (ADR 0006), explainable
fallback for the dangerous cases. Rules add false positives (over-triage), which the protocol
accepts over under-triage. ACS-ECG (CC0, research 09) is the candidate for external
STEMI/OMI checks. Calibration may drift on Kyrgyz data; local validation is planned (Phase 5).
