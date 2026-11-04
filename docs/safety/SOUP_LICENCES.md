# SOUP and licence table (draft v0.1)

Status: **draft**, Phase 2 · 2026-11-04. Policy: [ADR 0001](../adr/0001-permissive-licence-policy.md).
Companion to [HAZARD_LIST](HAZARD_LIST.md) (H-17) and [INTENDED_USE](INTENDED_USE.md).

Only licences stated in the research notes are used. Anything not stated there is "to check".
Licences marked "expected" or "per search summary" in the notes are repeated as such and still
need a check of the actual LICENSE file before release. This is not legal advice.

Rule from ADR 0001: code and model weights in the **product path** must be Apache-2.0, BSD or
MIT. No AGPL/GPL, no share-alike, no non-commercial. Non-permissive items may be used for
research baselines or evaluation (in `temp/` or private `data/`), never shipped. Datasets stay
out of git (AGENTS.md). Weights derived from non-permissive data need a case-by-case ADR.

Columns: **Product path?** = may ship in the app/admin/model bundle. "Research only" = baseline
or evaluation, not shipped. "Evaluate" = allowed for training or testing under the conditions
shown.

## 1. Code and libraries

| Component | Use | Licence (source note) | Product path? (ADR 0001) |
|---|---|---|---|
| Flutter / Dart SDK | App UI | BSD-3-Clause (07; 08) | Yes |
| flutter_localizations, intl | ru/ky/en strings | BSD-3 via Flutter (08) | Yes |
| flutter_litert | On-device inference | Apache-2.0 per README badge (08) | Yes, after licence file check |
| tflite_flutter | On-device inference | Apache-2.0 (05, 08); "work-in-progress" | Licence yes; avoid for maintenance reasons (08) |
| onnxruntime_v2 (community fork) | Alternative runtime | MIT (08) | Yes, if chosen; maintenance to weigh |
| google_mlkit_document_scanner / cunning_document_scanner | Capture / crop | Package licences not read (08) | To check (also check the ML Kit terms) |
| camera (flutter.dev) | Capture | Not researched; BSD-3 expected (08) | To check |
| drift | Offline storage | MIT, expected, not read (08) | Yes, after check |
| riverpod | State management | MIT (08) | Yes |
| fl_chart | Small plots | MIT, expected, not read (08) | Yes, after check |
| Syncfusion Flutter Charts | Charts | Community licence with revenue/team limits (08) | No (avoid per 08) |
| pdf, printing | PDF export | Apache-2.0 (`printing` verified; `pdf` not stated) (08) | Yes; `pdf` to check |
| Noto fonts (SIL OFL) | Cyrillic and Kyrgyz glyphs | SIL OFL (07) | Yes, if glyph coverage of U+04A2, U+04E8, U+04AE is confirmed |
| OpenCV | Image geometry | Apache-2.0 since 4.5.0 (07, unverified) | Yes, after check |
| FastAPI | Admin backend | Not stated in notes (08) | To check |
| SQLAdmin | Admin panel | BSD-3-Clause (08) | Yes |
| PostgreSQL | Admin database (spec) | Not stated in notes | To check |
| wfdb | Read PhysioNet data | MIT (08) | Yes (training tooling) |
| neurokit2 | Rule-based features, baselines | MIT (08) | Yes |
| torch_ecg | Training baselines | MIT (08) | Yes (training tooling) |
| ecglib | Pretrained models, tools | Apache-2.0 (08); weights' own licence and data provenance not checked | Code yes; weights to check |
| openecg | On-device delineation | Not read (08) | To check |
| PyTorch | Training | Not stated in notes | To check |
| ecg-image-kit | Synthetic ECG images | BSD-3-Clause (03, 04, 08) | Yes |
| felixkrones/ECG-Digitiser (Moody 2024 winner) | Digitiser reference or reuse | BSD-2-Clause badge; bundled nnU-Net has its own LICENSE (04) | Yes for own code; nnU-Net part to check |
| nnU-Net | Segmentation | Own LICENSE, not read (04) | To check |
| Open-ECG-Digitizer (Ahus-AIM) | Reference baseline | CC BY-SA 4.0 (04, 07) | No. Research baseline only (ADR 0001) |
| ECGtizer | Digitiser comparison | "Unlicense" per search summary; file not read (04) | To check (research only until checked) |
| ECGLight | Digitiser comparison | Not read; uses Ultralytics, so AGPL-3.0 obligations (04) | No. Research only |
| Ultralytics YOLO (code and weights) | Detection | AGPL-3.0 or paid Enterprise (04, 07) | No |
| MMDetection, YOLOX (MegEngine fork), D-FINE | Optional detector | Apache-2.0 per search results, not fetched (04) | Yes if needed, after check |
| Agent skills and MCP tools (flutter/agent-plugins, obra/superpowers, K-Dense skills, huggingface/skills, Maestro, Playwright MCP) | Dev tooling only, not shipped | BSD-3 / MIT / MIT / Apache-2.0 / Apache-2.0 / Apache-2.0 (08) | Not part of the product; pin to a commit and review per AGENTS.md |

## 2. Model weights

| Component | Licence (source note) | Product path? |
|---|---|---|
| Own classifier and digitiser weights | Inherit data terms below; Apache-2.0 for our code | Yes, only if trained on data allowed below |
| ECGFounder | MIT (repo) (05); training-data terms not checked | Teacher or baseline only in v1 (05); check data terms before shipping |
| ECG-FM | MIT (05); loading needs extra dependencies per 05 | Teacher or baseline only in v1; check |
| HuBERT-ECG | CC BY-NC 4.0 (05) | No |
| ECG-JEPA | Code MIT; weights licence not stated (05) | To check; not before authors answer |
| ecglib pretrained models | Weights licence not checked (08) | To check |
| nnU-Net / Ahus U-Net pretrained weights | Not checked (04); Ahus weights follow CC BY-SA 4.0 repo (04) | To check; Ahus weights No |

## 3. Datasets (training and evaluation; never in git)

| Dataset | Licence (source note) | Use under ADR 0001 |
|---|---|---|
| PTB-XL v1.0.3 | CC BY 4.0 (03, 07) | Evaluate/train; attribution needed |
| PTB-XL+ v1.0.1 | Not read (03) | To check |
| Chapman-Shaoxing + Ningbo | CC BY 4.0 (03) | Evaluate/train; attribution |
| PhysioNet/CinC 2020-2021 | CC BY 4.0 (03) | Evaluate/train; attribution |
| CODE-15% | CC BY 4.0 (03) | Evaluate/train (weak labels); attribution |
| MIT-BIH Arrhythmia | ODC-By 1.0 (03) | Beat-detector checks only (03) |
| MIT-BIH Malignant Ventricular Ectopy, CU DB | "Open", licence not read (03) | To check; rule tests only |
| INCART, Long-Term AF DB, PTB Diagnostic, SaMi-Trop | "Open", licence not read (03) | To check |
| Shandong (SPH) | Not read (03) | To check; external test only |
| ACS-ECG (2026) | CC0 1.0 on figshare record (09) | Evaluate/train for OMI labels |
| ECG Images dataset of Cardiac Patients (Mendeley) | CC BY 4.0 (03) | Evaluate/train; attribution |
| PhysioNet Challenge 2024 images | Treated as CC BY 4.0 plus BSD-3 kit; inference, not a quote (03) | Evaluate/train; confirm |
| PM-ECG-ID | GPL-3.0-or-later (09) | Evaluation only, no redistribution; whether GPL reaches weights is untested (09) |
| ECG-Image-Database | No dataset licence found (09) | Evaluation only; not redistributed; no release weights from Emory/Ahus parts (09) |
| MIMIC-IV-ECG | ODbL 1.0, share-alike on derivative databases (03); credentialed terms apply (07) | Evaluation only; never in git, never via online LLM services; weights case-by-case ADR |
| Icentia11k | CC BY-NC-SA 4.0 shown on licence page, conflicting snippet (03) | No (treat as non-commercial) |
| HEEDB (BDSP) | Credentialed, BDSP Credentialed Health Data License 1.5.0 (03) | No unless an ADR approves; never in git or online services |
| Emory Paper ECG Database | Not checked (03) | To check |

## 4. Open items

- Read the actual LICENSE file for every "to check" and "expected" row before the MVP; add an
  SBOM with licences to the handover pack (research 07).
- Record dataset attributions in a `DATA_LICENSES.md` (03 recommendation) when the training
  pipeline exists.
- Training on non-permissive data (ODbL, GPL, NC, credentialed) needs an ADR before any
  resulting weights are shipped (ADR 0001).
- Add a CI licence check when the app and Python code exist (Phase 4).
