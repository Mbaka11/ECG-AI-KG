# Spec v2 — change log against the original

Status: **draft** · 2026-11-04 · Baseline: `docs/spec/original/` (English copy:
`docs/spec/en/ECG-AI_KG_TS_EN.md`; line numbers below refer to it). The original is never
edited. Every change lists its reason and source. IDs (C-xx) are referenced from spec v2.

Evidence: [synthesis](../../research/00-synthesis.md), [09](../../research/09-dataset-followup.md),
[10](../../research/10-kr-protocols.md); decisions: [ADR 0001–0003](../../adr/).

## A. Facts and citations (section "Relevance")

| ID | Original | v2 | Reason |
|---|---|---|---|
| C-01 | CVD 50–52 % of deaths (l.7, 13) | Keep; cite NSC (52.4 %, 2023) | Verified |
| C-02 | 17–20 k deaths/yr; ~19,000 (IJMEDRI) (l.7, 14) | "~17 thousand per year" (NSC 2023–24); drop IJMEDRI | 16.5–16.9 k found; IJMEDRI figure untraceable (open question A3) |
| C-03 | 234.5 per 100,000 (EHJ 2024) (l.15) | Replace by a sourced figure (WHF 2024: crude ≈230, age-standardised ≈429) or remove | Not traceable to EHJ |
| C-04 | Hypertension 34–37 % (NCCIM) (l.16) | WHO STEPS 2013: 42.9 % (25–64 y), or remove until the source is given | Not traceable |
| C-05 | IHD rank 3rd women / 5th men of 51 (l.7) | Reword ("among the highest in the WHO European Region") or remove | Not found; WHO: 3rd highest overall |
| C-06 | "MSS KR, 2022–2026" (l.13) | Cite NSC; keep the open question | Source undefined (A2) |
| C-07 | "Every 30 min delay → +7–8 % mortality" in AMI (l.23) | "In STEMI treated with primary PCI, each 30 min of delay raises 1-year mortality by ≈7.5 % (De Luca 2004)" | Statistic is specific to primary-PCI delay |
| C-08 | WHO/World Bank "untapped lever" quote (l.25) | Remove or re-source | Quote not found |
| C-09 | 980+ FAPs (l.262) | ≈1,060 FAPs (1,057–1,059, 2020–2023) | Updated figure |
| C-10 | "Nature 2025, < 7 s, robust to folds" (l.29, 31) | Cite the real papers: Stenhede et al. (npj Digit Med) for the open method; J Electrocardiol 2025 (PMcardio) for the speed claim | Wrong attribution |
| C-11 | Rural share 65.1 %; 1 in 5 adults aged 40–64 at >30 % risk | Keep | Verified / World Bank |
| C-12 | "No new equipment needed" (l.262) | Keep, qualified: assumes the existing machine prints a readable trace; machine model unknown (A1) | Unverified assumption |

## B. Technical content

| ID | Original | v2 | Reason |
|---|---|---|---|
| C-20 | "98–99.4 % accuracy on MIT-BIH" as basis (l.29, 101) | Remove. Targets are per-class sensitivity/specificity with 95 % CI, AUROC/AUPRC, calibration, abstention rate | Intra-patient splits; accuracy misleading on imbalanced data |
| C-21 | MIT-BIH as main training set (l.102, 114, 195, 203, 206) | PTB-XL (train) + PhysioNet/CinC 2021 sources (external test, extra training); MIT-BIH only to check beat detection | MIT-BIH: 48 two-lead Holter records, no ACS |
| C-22 | PTB-XL "21,837 ECGs" (l.103) | 21,799 records / 18,869 patients (v1.0.3) | Updated |
| C-23 | YOLOv11 segmentation (l.100, 112) | U-Net-family segmentation + classical geometry; permissive licences only | AGPL-3.0 (ADR 0001); challenge winners use U-Net |
| C-24 | CNN + BiLSTM (l.101) | 1D ResNet/Inception baseline first; CNN+BiLSTM kept as a comparison; lead-dropout and digitisation-noise augmentation | PTB-XL benchmark evidence |
| C-25 | TensorFlow Lite (l.106) | LiteRT / ONNX Runtime (decided in an ADR) | TFLite renamed LiteRT |
| C-26 | Admin panel: React + PostgreSQL (l.107) | Decided in an ADR; start with FastAPI + SQLAdmin | Solo maintainer, speed |
| C-27 | "Android/iOS" (l.65, 99) | Android first, iOS later | ADR 0002 |
| C-28 | Report: template engine + optional LLM (l.115) | Template engine only; no LLM in the report path | Offline use, hallucination risk, clinical safety |
| C-29 | Action algorithms (l.47, 79, 146) | Texts must cite an official protocol (KR MoH, else ERC/ESC) or cardiologist review, each tagged with its source | AGENTS.md clinical safety; research 10 |
| C-30 | Input "12-lead or abbreviated" (l.71, 137) | 3- and 6-channel strips are first-class inputs; with fewer than 12 identified leads the claims are limited to rhythm findings | Likely FAP machines; morphology needs 12 leads |
| C-31 | Pathology list incl. ACS ST elevation/depression (l.86) | Renamed "possible acute ischaemia / occlusion — refer"; transparent rule-based STEMI criteria as safety net; never reported as "normal" | STEMI criteria miss about half of occlusions; no STEMI labels in PTB-XL/CinC |
| C-32 | VT/VF and complete AV block as classified targets (l.88–89) | Rule-based detection plus cautious claims; mark as "limited evidence" | PTB-XL: 16 3AVB, no VT/VF; CinC 2021: 12 VT, 97 VF, 127 CHB |
| C-33 | Output: normal / suspect / urgency (l.76–77) | Add ⚪ "cannot interpret"; urgency = highest among findings; low quality or low confidence is never 🟢 | Safety (synthesis) |
| C-34 | Resolution ≥ 5 MP, 25 mm/s, 10 mm/mV fixed (l.113, 196) | Detect speed and gain from the paper; support 25/50 mm/s and 5/10/20 mm/mV | Tenders show several settings |
| C-35 | AF from an image | Output "suspected AF"; the KR protocol needs ≥ 30 s, a strip is about 10 s | Research 10 |

## C. Targets and KPIs (l.206, 235–241, 247)

| ID | Original | v2 | Reason |
|---|---|---|---|
| C-40 | ≥ 95 % (roadmap) vs ≥ 97 % (KPI) accuracy | Single set of thresholds defined in the evaluation protocol before training | Inconsistent; accuracy is the wrong metric |
| C-41 | ACS sensitivity ≥ 95 %, specificity ≥ 93 % | Aspirations only; the protocol sets thresholds per class and per input type (photo vs digital) once the baseline is known | Best published OMI models are far lower in unselected cohorts |
| C-42 | Latency < 10 s server, < 20 s offline | Keep as a target; measure in Phase 3/4 | — |
| C-43 | Agreement ≥ 90 % on urgency | Keep; weighted by clinical cost (under-triage worse than over-triage) | Safety |

## D. Regulation, safety, data

| ID | Original | v2 | Reason |
|---|---|---|---|
| C-50 | "Registration as a medical device" (l.186) | Specify: SaMD under KR Law 216 / EAEU rules; research framing for POC and pilot; ethics approval before any pilot | Research 07 |
| C-51 | GDPR principles (l.179) | KR Digital Code No. 178 (in force Feb 2026) | Local law applies |
| C-52 | Cloud: Google Cloud / local server (l.105) | Decided in an ADR after the localisation question is clarified | Data localisation unclear |
| C-53 | Photos kept ≤ 30 days | Keep; add data-management plan (what, where, how long, who) | Phase 2 deliverable |
| C-54 | "Logging for fine-tuning" (l.55) | Only with consent and de-identification; no patient data in git | AGENTS.md |
| C-55 | Model limitations (l.195) | Update training data list; add: not validated on Kyrgyz paper; may miss emergencies | Honesty of claims |
| C-56 | — | Add hazard list, intended-use statement, SOUP/licence table | Clinical safety, Phase 2 |

## E. Positioning and scope

| ID | Original | v2 | Reason |
|---|---|---|---|
| C-60 | No mention of MoH/NCCIM digital programmes or competitors | Add positioning: complementary to Digital FAP and tele-ECG; PMcardio as a reference | ADR 0003, research 06 |
| C-61 | — | Add a "forward to an expert / tele-ECG centre" action | ADR 0003 |
| C-62 | Roadmap by months (l.199–229) | Indicative only; phases follow `docs/PLAN.md` | Personal project, no fixed timeline |
| C-63 | "Portfolio outcomes for university admission" (l.252) | Move out of the technical spec | Not a product requirement |
| C-64 | Interface: Kyrgyz + Russian (l.54, 191) | Kyrgyz + Russian + English | Maintainer decision |
| C-65 | Admin panel scope unclear | Part of the MVP (FR-6 kept) | Author answer |

## Open points (not yet decided)

- ECG machine model and strip format: answers to A1 may change C-30 and C-34.
- What a feldsher may do at first contact (C7): shapes C-29.
- Digitiser approach under the permissive rule (ADR 0001): train our own vs reuse BSD-2 entries.
