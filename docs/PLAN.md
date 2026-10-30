# ECG-AI KG — Project Plan

Status: **draft v0.1** · Owner: project team · Last update: see git history

This plan describes how we go from the original specification
([`spec/en/ECG-AI_KG_TS_EN.md`](spec/en/ECG-AI_KG_TS_EN.md)) to a working, validated
prototype. It **does not replace** the specification: the spec says *what* the author
wants; this plan says *how and in what order* we get there, and where we first need to
check facts.

Each phase has a goal, tasks, deliverables and an exit criterion. We do not start a phase
before the previous phase's exit criterion is met, unless stated otherwise.

**Context.** This is a personal project first, to be scaled later. There is no fixed
timeline: the 12-month roadmap in the spec is indicative only. One maintainer builds
everything (research, ML, app, admin panel, docs); the author answers questions about the
spec, and a cardiologist in the author's family can advise us, **once a proof of concept
(POC) exists** (end of Phase 3). All work is in English; the app UI is in Russian, Kyrgyz
and English.

---

## Overview

| # | Phase | Main output | Maps to spec roadmap |
|---|---|---|---|
| 0 | Repository setup and translation | Organised repo, EN/FR spec, this plan | — |
| 1 | Research and state of the art | Research notes + synthesis + recommendations | Phase 1 (study) |
| 2 | Scope, requirements and design | Refined spec v2, architecture decisions, MVP scope | — |
| 3 | ML prototype = **POC** | Photo → signal → classification demo + evaluation | Phase 1 (prototype) |
| 4 | Application MVP | Backend API, mobile app, offline model | Phase 2 |
| 5 | Validation and pilot | Retrospective test on Kyrgyz ECGs, then pilot | Phase 3 |
| 6 | MoH presentation and handover | Document package, presentation, handover | Phase 4 |

Cross-cutting work (all phases): documentation, research paper, clinical safety, privacy
and licensing.

---

## Phase 0 — Repository setup and translation ✅

- [x] Create the repository structure, `README.md`, `.gitignore`, `temp/` scratch folder.
- [x] Translate the original Russian spec to English and French (same content, same layout)
      as `.docx`, `.pdf` and `.md`.
- [x] Write translation notes (abbreviations, choices) — `spec/TRANSLATION_NOTES.md`.
- [x] Write this plan and the list of open questions for the author — `OPEN_QUESTIONS.md`.
- [x] Publish the repository on GitHub (public, Apache-2.0).

**Exit:** the repo is on GitHub and the team agrees on the plan.

---

## Phase 1 — Research and state of the art 🟡 (first pass done 2026-10-29)

**Goal:** understand the real situation before writing code: the clinical problem, the
local context in Kyrgyzstan, the available data, the state of the art and the existing
products. Verify the claims and numbers in the spec, and identify what is missing.

All research notes go in `docs/research/` (one file per topic, sources linked).

**Status:** notes 01–08 and the [synthesis](research/00-synthesis.md) are written (first
pass, each claim labelled verified / partly verified / unverified). Remaining before exit:
answers to section A questions (above all the ECG machine model and sample strips) and the
three maintainer decisions listed in the synthesis.

**Main results** (details in the synthesis):
- Photo → signal digitisation is the main technical risk (phone-photo SNR −1 to 12 dB in
  the best published work); classification on clean signals is mature.
- FAP machines are likely 3/6-channel thermal printers → rhythm findings are feasible from
  few leads; ST/BBB claims need 12 identified leads.
- MIT-BIH and YOLOv11 should be replaced (PTB-XL + CinC; permissive U-Net segmentation).
- The MoH/NCCIM already plan AI-ECG and tele-ECG for FAPs; PMcardio is a regulated
  competitor → position ECG-AI KG as an offline, RU/KY, complementary assistant.
- The app is SaMD under KR Law 216 / EAEU rules; research framing for the POC.

### 1.1 Questions
- Send section A of [`OPEN_QUESTIONS.md`](OPEN_QUESTIONS.md) to the author (source links,
  "MSS KR", optional real ECG photos) and record the answers there.
- Section B questions are answered by research (1.2, 1.3); ask only what we cannot find.
- Section C questions wait for the cardiologist, after the POC.

### 1.2 Clinical domain (`research/01-clinical-domain.md`) ✅
- ECG basics needed by the team: leads, paper layouts (3×4, 6×2, 12×1, rhythm strip),
  calibration (25 mm/s, 10 mm/mV), intervals (PR, QRS, QT/QTc).
- For each MVP target pathology: ECG criteria, how urgent it is, what a feldsher should do.
- Obtain the **MoH KR clinical protocols** (ACS, arrhythmias) the action algorithms must follow.
- Define a first urgency mapping (🔴/🟡/🟢) to be reviewed by a cardiologist.

### 1.3 Local context (`research/02-kyrgyz-context.md`) ✅
- Verify the statistics in the spec and find the original sources (links).
- ECG machines actually used in FAPs/CFMs: models, number of channels, paper format,
  thermal paper quality, whether they can export digital files (which would avoid photos).
- Smartphones used by staff (Android versions, RAM, camera), connectivity in mountain areas.
- Existing digital health systems (MoH information systems, e-health strategy, telemedicine
  projects) we should integrate with or not duplicate.
- Languages: Kyrgyz and Russian medical terminology; who can translate clinical text.

### 1.4 Data (`research/03-datasets.md`) ✅
- Review public ECG datasets, their task fit and licence:
  - MIT-BIH Arrhythmia (2-lead Holter, 48 records, beat-level labels),
  - PTB-XL (12-lead, ~21.8k records, diagnostic statements incl. MI / ST changes),
  - PhysioNet/CinC Challenge 2020/2021 12-lead collections, CODE-15%, MIMIC-IV-ECG,
    Chapman-Shaoxing, and others,
  - ECG **image** data: PhysioNet/CinC Challenge 2024 (ECG image digitisation and
    classification), synthetic images from ECG-Image-Kit.
- Plan for Kyrgyz data: who could provide anonymised paper ECGs with cardiologist reports,
  under which consent/ethics framework.

### 1.5 State of the art — digitisation (`research/04-digitisation.md`) ✅
- ECGtizer (named in the spec) and other open-source digitisers; the top methods of the
  PhysioNet Challenge 2024; robustness to real phone photos (folds, shadows, perspective).
- Metrics used to evaluate digitisation (e.g. SNR, correlation against the true signal).
- Alternative: classify **directly from the image** without full digitisation — compare.

### 1.6 State of the art — classification (`research/05-classification.md`) ✅
- 12-lead classification models and benchmarks (PTB-XL benchmarks, large-cohort models,
  recent ECG foundation models), CNN + BiLSTM as proposed in the spec.
- How the 98–99.4% MIT-BIH accuracy figures were obtained (intra- vs inter-patient split;
  class imbalance) and what realistic numbers are.
- Models small enough for on-device inference (TFLite/LiteRT, ONNX), quantisation.

### 1.7 Existing products and projects (`research/06-existing-solutions.md`) ✅
- Commercial and research tools that already interpret ECG photos or 12-lead ECGs (for
  example PMcardio, Cardiologs and others — to verify), their regulatory status, what
  they do well and what they do not cover (offline use, Kyrgyz/Russian language, price).
- What makes ECG-AI KG different and worth building.

### 1.8 Regulation, ethics, privacy and licensing (`research/07-regulatory-ethics.md`) ✅
- Medical device rules in the KR (including Eurasian Economic Union rules, as the KR is a
  member), whether a CDSS for triage is a medical device, what a pilot requires.
- Research ethics approval for a pilot; informed consent; KR personal-data law.
- Licences of planned components (e.g. Ultralytics YOLO is AGPL-3.0, which matters for a
  handover to a government partner), datasets and models.

### 1.9 Synthesis (`research/00-synthesis.md`) ✅
- Summary of findings, verified/unverified claims of the spec, risks, gaps.
- Recommendations: what to keep, change or postpone in the spec; proposed MVP scope.

**Preliminary points to check** (from a first reading of the spec) — all six were confirmed by
the research; see the synthesis:
1. MIT-BIH contains 2-lead Holter beats, not 12-lead paper ECGs, and almost no ACS/ST
   examples; ACS detection probably needs PTB-XL or larger 12-lead datasets.
2. The accuracy target differs between the roadmap (≥ 95%) and the KPIs (≥ 97%), and plain
   accuracy is misleading on imbalanced data; per-class sensitivity/specificity, F1 and
   AUROC on a patient-wise split are more meaningful.
3. Photo → signal is likely the hardest and least mature step; it needs its own metrics
   and real-photo test set.
4. An LLM for report text conflicts with offline use and adds hallucination risk;
   template-based reports may be enough for the MVP.
5. The action algorithms are clinical content: they must come from official protocols and
   be validated by a cardiologist, not generated.
6. Licensing of YOLOv11 (AGPL-3.0) and dataset licences must be compatible with the
   intended open-source/government use.

**Exit:** synthesis written, open questions answered (or explicitly parked), team agrees on
the recommendations.

---

## Phase 2 — Scope, requirements and design

**Goal:** turn the research into concrete, realistic decisions.

- Define the **MVP scope** (which pathologies, which ECG formats, online vs offline first).
  Starting proposal: [synthesis — POC scope](research/00-synthesis.md#proposed-poc-scope-phase-3).
- Apply the spec corrections listed in the synthesis (statistics, citations, MIT-BIH,
  YOLOv11, accuracy claim, ACS wording, "cannot interpret" state, no LLM in the report path,
  support for 3/6-channel strips).
- Write **spec v2** in English (`docs/spec/v2/`), keeping the original untouched; list every
  change and its reason.
- Architecture decision records (`docs/adr/`): stack, model approach, hosting, on-device vs
  server inference.
- Define labels, urgency logic and the evaluation protocol (datasets, splits, metrics,
  acceptance thresholds) **before** training.
- Clinical safety: hazard list (e.g. a missed STEMI, a bad photo accepted), mitigations,
  mandatory disclaimers and limitations in the UI; intended-use statement; licence/SOUP
  table (see the phase checklist in [research 07](research/07-regulatory-ethics.md#checklist-per-phase)).
- Small follow-up research: per-class counts in PTB-XL/CinC, licences of ACS-ECG /
  PM-ECG-ID / ECG-Image-Database, full text of the KR AF and NSTE-ACS protocols.
- Data management and privacy plan (what is stored, where, how long, who can access).
- Planned repo structure for code (to be created when needed):
  `ml/` (data, training, evaluation), `backend/`, `mobile/`, `admin/`, `docs/`.

**Exit:** spec v2 + ADRs + evaluation protocol written and reviewed.

---

## Phase 3 — ML prototype

**Goal:** prove that photo → signal → classification works, with honest metrics.

- 3.1 Data pipeline: download and version public datasets (not committed to git), patient-wise
  splits, preprocessing.
- 3.2 Classification baseline on digital 12-lead signals (PTB-XL official folds, external
  test on CinC 2021 sources): XResNet1D/Inception1D baseline, the CNN + BiLSTM from the spec
  for comparison, lead dropout and digitisation-noise augmentation; rule-based rate and
  regularity checks as a safety net. MIT-BIH only for beat-detector checks.
- 3.3 Digitisation: generate synthetic paper-ECG images (ECG-Image-Kit) from known signals,
  including short 3/6-channel strips; start from existing open digitisers (Open-ECG-Digitizer,
  PhysioNet 2024 entries — licence decision first); measure SNR on public photo sets; then
  test on photos we print and photograph ourselves. Compare with a direct-image classifier.
- 3.4 End-to-end evaluation: photo → digitiser → classifier, robustness tests (lighting,
  angle, folds, resolution), image-quality check that asks for a retake.
- 3.5 Measurements: heart rate, intervals (PR, QRS, QTc) and their error.
- 3.6 Report generation: rule/template engine producing urgency + patterns + action steps.
- 3.7 Model card and methodology write-up (basis for the research paper).

- 3.8 **POC demo** for the cardiologist: a simple way (notebook, small web page or CLI) to
  upload a photo and see the digitised signal, detected patterns and urgency; short
  summary of results and limitations. Then ask the section C questions.

**Exit:** evaluation protocol from Phase 2 run end to end, results documented, POC shown to
the cardiologist, decision on whether quality is sufficient to build the app.

---

## Phase 4 — Application MVP

- 4.1 Backend API (FastAPI): upload, processing, results, history, auth, logging.
- 4.2 Mobile app (Flutter): camera/gallery capture with guidance, result screen, history
  (last 50 cases), PDF export, Russian / Kyrgyz / English UI.
- 4.3 Offline mode: on-device model, sync when online.
- 4.4 Admin panel (in MVP scope): dashboard, facilities/users, de-identified export,
  cardiologist review flags.
- 4.5 Security: TLS, RBAC, 2FA for admins, retention rules.
- 4.6 Internal testing on 20–30 real ECG strips; usability review.

**Exit:** MVP installable on a mid-range Android phone and meeting the performance targets.

---

## Phase 5 — Validation and pilot

- Partner with NCCIM or KSMA; ethics approval and consent protocol.
- Retrospective validation on Kyrgyz ECGs with cardiologist reference (≥ 100 cases).
- Fine-tune/adapt on local data if needed (with a separate held-out test set).
- Prospective pilot in ≥ 3 FAPs/CFMs; usability feedback; clinical and social KPIs.
- Write up results (confusion matrix, ROC, feedback) — paper / conference.

**Exit:** pilot report with KPIs measured against the targets.

---

## Phase 6 — MoH presentation and handover

- Document package for the MoH: spec, pilot results, implementation and maintenance plan,
  regulatory path.
- Presentation to the MoH digital health working group.
- Handover of code and documentation; grant applications (UNDP, WHO KR, AKF).

---

## Cross-cutting

- **Documentation:** every phase ends with its documents in `docs/`.
- **Research paper:** methodology and results written progressively (Phases 1, 3, 5).
- **Clinical safety:** the app is decision support, never a diagnosis; limitations always
  shown.
- **Data:** no patient data or credentials in git, ever. Public datasets are downloaded by
  scripts, not committed.
- **Translation:** repo in English; UI in Russian, Kyrgyz and English; messages for the
  author in Russian when needed.

## Immediate next steps

1. Send section A of the open questions to the author (Russian version ready).
2. Maintainer decisions from the synthesis: CC BY-SA reuse, Android first, positioning.
3. Start Phase 2: spec v2 + ADRs + evaluation protocol.
