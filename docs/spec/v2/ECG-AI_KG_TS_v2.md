# ECG-AI KG: Technical Specification v2

- **Status:** draft v2.0
- **Date:** 2026-11-04
- **Relation to the original:** supersedes nothing. The original remains the author's
  document (`docs/spec/original/`, English copy `docs/spec/en/`) and is never edited.
- **Review:** pending author and cardiologist review. Clinical content is a draft.
- **How to read:** each changed statement carries its change ID in brackets, for example
  [C-21]. Reasons and sources are in [CHANGELOG.md](CHANGELOG.md). "Open:" marks an
  unresolved point and gives its id in [OPEN_QUESTIONS](../../OPEN_QUESTIONS.md).

Related documents: [intended use](../../safety/INTENDED_USE.md) ·
[hazard list](../../safety/HAZARD_LIST.md) · [SOUP and licences](../../safety/SOUP_LICENCES.md) ·
[evaluation protocol](../../eval/PROTOCOL.md) ·
[data management plan](../../privacy/DATA_MANAGEMENT_PLAN.md) ·
[ADRs](../../adr/) · [research synthesis](../../research/00-synthesis.md).

---

## 1. Relevance of the Problem

Cardiovascular diseases (CVD) are the leading cause of death in Kyrgyzstan.

### Key data

| Indicator | Value | Source |
|---|---|---|
| Share of CVD in all deaths | 52.4 % (2023) [C-01] | National Statistical Committee (NSC) [C-06] |
| CVD deaths per year | about 17 thousand [C-02] | NSC, 2023-24 |
| CVD mortality per 100,000 | crude about 230; age-standardised about 429 [C-03] | World Heart Federation, 2024 |
| Adults with arterial hypertension | 42.9 % of ages 25-64 [C-04] | WHO STEPS, 2013 |
| Rural population | 65.1 % [C-11] | NSC, 2023 |
| Adults aged 40-64 with 10-year CVD risk above 30 % | one in five [C-11] | World Bank PHC report |
| Feldsher-midwife posts (FAPs) | about 1,060 (1,057-1,059, 2020-2023) [C-09] | Research 02 |

Ischaemic heart disease mortality in the KR is among the highest in the WHO European Region
[C-05].

Open: the original sources "MSS KR 2022-2026" and "IJMEDRI 2024" could not be traced
(A2, A3). They are not used. The original international ranking and the "untapped lever"
quote [C-08] are removed until the author supplies sources (A3).

### The problem: staff shortage and little ECG expertise at primary level

- **Few cardiologists.** Feldshers and general practitioners (GPs) record ECGs but have
  limited training to recognise life-threatening arrhythmias and acute coronary syndromes
  (ACS). Mountain regions (Naryn, Talas, Batken, Alay) are under-served.
- **Delay costs lives.** In ST-elevation myocardial infarction treated with primary PCI, each
  30 minutes of delay raises 1-year mortality by about 7.5 % (De Luca 2004) [C-07].
- **The equipment exists, the interpretation does not.** ECG machines were bought for rural
  facilities without decision support. Open: which machines are in use and what they print
  (A1).
- **Tele-ECG is not yet routine in most FAPs.** Open: whether the MoH "Digital FAP" kits and
  the NCCIM tele-ECG plan have reached FAPs (A4).

### The technological opportunity

Deep learning on clean digital 12-lead ECGs is well studied. Reading a phone photo of a paper
ECG is harder and is the main technical risk [C-20]. Open methods exist (Stenhede et al.,
npj Digital Medicine) and a closed commercial one reports fast processing (J Electrocardiol
2025, PMcardio) [C-10]. This makes the task feasible as a research project. It does not yet
show clinical fitness.

---

## 2. Project Concept

**ECG-AI KG** is an offline-first mobile application that reads a phone photo of a paper ECG
and shows a quality verdict, heart rate, cautious findings, an urgency level and next-step
text from official protocols. Target users are feldshers, nurses and GPs in FAPs and
Centres of Family Medicine (CFMs) of remote districts.

### 2.1 Positioning [C-60]

- Complementary to the MoH "Digital FAP" kits and the NCCIM tele-ECG plan. It does not
  compete with or duplicate them (ADR 0003).
- Pitch: an offline, free, Russian/Kyrgyz/English assistant that reads the paper ECGs FAPs
  already print, gives an urgency level and protocol-based next steps, and can forward the
  case to a tele-ECG centre.
- Reference product: PMcardio (photo-based, regulated). Differences: offline use, local
  languages, urgency with protocol steps, no fee, MoH reporting, validation on Kyrgyz paper
  (to be done).
- NCCIM is contacted only through the cardiologist, after a proof of concept (POC).

### 2.2 Goal

Shorten the time from recording an ECG to a decision on patient management in facilities
without a cardiologist. The original target "from several hours to 1-2 minutes" is kept as
an aspiration only. It is measured in the pilot, not promised. [C-40]

### 2.3 User scenario

1. The feldsher records an ECG and photographs the strip.
2. The app checks photo quality and asks for a retake if needed.
3. The app digitises the trace, detects paper speed and gain, and finds the leads.
4. The app asks 2-4 yes/no clinical questions (set pending cardiologist review).
5. The screen shows: quality, heart rate, findings, urgency level, next steps.
6. The user can forward the case to an expert or tele-ECG centre [C-61], save it, or export a
   PDF.

### 2.4 Key principles

- **Offline first.** The full path runs on the phone (ADR 0006).
- **Support, not replacement.** The output is "interpretation assistance", not a diagnosis.
- **Safety first.** Unknown or low-quality input is never reported as normal ([section 5](#5-urgency-levels)).
- **Simple interface** for average digital literacy.
- **Trilingual:** Kyrgyz, Russian and English [C-64]. Clinical wording in ru/ky needs a human
  medical reviewer.
- **Android first,** iOS later [C-27] (ADR 0002).
- **Logging** of cases for audit only with consent and de-identification; no patient data in
  git [C-54].

### 2.5 Regulatory framing

The app is probably software as a medical device. Until regulatory steps are done it is
framed as a research prototype. See [section 11](#11-regulation-and-ethics).

---

## 3. Intended Use and Disclaimers [C-56]

The full statement is in [INTENDED_USE.md](../../safety/INTENDED_USE.md). Summary:

- **Users:** trained health workers (feldsher, nurse, GP) in first-contact primary care in
  the KR. Not for patients or the public, hospital diagnosis, ambulance or ICU monitoring.
- **Function:** decision support. Not a diagnosis. Not a rule-out tool. A green or "no
  finding" result never means healthy.
- **Not validated** on Kyrgyz paper, local machines or the target population [C-55].
- **No online LLM** and no sending of patient data or ECG photos to an online service [C-28].

Mandatory UI texts D1-D12 (research-prototype notice, fixed footer "Not a diagnosis. A green
result does not exclude disease", grey-state text, limited-lead notice, AF notice, ischaemia
notice, detected speed/gain/leads/quality, version stamps, source of each step, data
statement) are defined in INTENDED_USE section 7. They must appear in ru, ky and en.
Final wording is pending cardiologist review. Hazards are in the
[hazard list](../../safety/HAZARD_LIST.md); licences in [SOUP_LICENCES](../../safety/SOUP_LICENCES.md).

---

## 4. System Description

Three components: a mobile app, an optional server and an administrative panel. The phone
works alone; the server is never needed to see a result (ADR 0006).

| Component | Description |
|---|---|
| Mobile app | Android first [C-27]. Capture, quality gate, digitiser, classifier, rules, report templates, local history, PDF export. Works offline. |
| Backend (optional) | FastAPI. Authentication and roles, case sync, model and protocol update manifest, forwarding to an expert, anonymised statistics, audit log, optional heavy-path inference with consent. |
| Administrative panel | Part of the MVP [C-65]. SQLAdmin inside the FastAPI app first [C-26]; moved to React only if the MoH needs dashboards beyond CRUD (ADR 0007). |

### 4.1 Input data [C-30, C-34]

- A photo of a paper ECG from a machine already in use. JPG, PNG, HEIC.
- Layouts, in order of work: 12-lead 3x4 prints first; then **3- and 6-channel strips as
  first-class inputs** [C-30]. Open: real machine models and strip formats (A1). The answer may
  change this section.
- Paper speed and gain are **detected from the paper**, not assumed. Supported: 25 and 50 mm/s;
  5, 10 and 20 mm/mV [C-34]. The original fixed 25 mm/s, 10 mm/mV and "at least 5 MP" are
  dropped as hard rules; the quality gate decides.
- Metadata: age and sex; facility and date. 2-4 yes/no symptom questions.
- No patient name or ID is needed or collected by default.

### 4.2 Output data

- Image quality verdict, with a retake prompt.
- Digitised trace overlaid on the photo, so the user can check it against the paper.
- Heart rate and findings, worded "suspected ..." or "pattern suggestive of ...".
- Urgency level: red, yellow, green or grey "cannot interpret" [C-33] ([section 5](#5-urgency-levels)).
- Next-step text from a template engine only [C-28]. Each step shows its source [C-29].
- Detected speed, gain, leads found, and app, model and protocol-text versions.
- Action "forward to an expert / tele-ECG centre" [C-61].

### 4.3 Findings

Rhythm findings need one to three leads. Morphology findings need 12 identified leads.

| Finding | Needs | Evidence and wording |
|---|---|---|
| Sinus tachycardia / bradycardia | Rhythm strip | Rate and regularity rules |
| "Suspected atrial fibrillation" or flutter [C-35] | Rhythm strip | The KR protocol needs at least 30 s; a strip is about 10 s. Never "AF" as a diagnosis. |
| Ventricular tachycardia / fibrillation [C-32] | Rhythm strip | Rule-based plus cautious claim. Marked **limited evidence**: PTB-XL has no VT/VF; CinC 2021 has 12 VT and 97 VF. |
| Complete (3rd-degree) AV block [C-32] | Rhythm strip | Rule-based plus cautious claim. Marked **limited evidence**: PTB-XL has 16; CinC 2021 has 127. |
| LBBB / RBBB | 12 leads | Only when 12 leads were found |
| "Possible acute ischaemia / occlusion - refer" [C-31] | 12 leads | Replaces "ACS ST elevation / depression". Transparent rule-based STEMI criteria are a safety net. Never reported as "normal". |

Why [C-31]: STEMI criteria miss about half of acute coronary occlusions, and PTB-XL and CinC
have no STEMI labels. A missing finding is therefore never reassurance.

QTc is not reported in the MVP. Open: the target pathology list and MVP scope are pending
cardiologist input (C1, C2).

---

## 5. Urgency Levels

[C-33]

| Level | Meaning |
|---|---|
| Red | Possible emergency. Act per protocol and call for help now. |
| Yellow | Refer or check soon. |
| Green | No urgent finding on this strip. Not "ECG normal". |
| Grey | **Cannot interpret.** Repeat the photo, record a 12-lead ECG, or send to an expert. |

Rules:

1. Urgency is the **highest** among all findings. [C-33]
2. **Never green:** low image quality, missing leads, an uncertain digitisation, or confidence
   below the threshold gives grey or at least yellow, never green. Green also carries the
   fixed footer "A green result does not exclude disease". [C-33]
3. With fewer than 12 identified leads, claims are limited to rhythm and the screen says so
   [C-30].
4. Colour is never the only cue: each level has an icon and a word.
5. Under-triage is worse than over-triage [C-43].

Open: the mapping of findings to levels is a first draft in
[research 01 s3](../../research/01-clinical-domain.md) and needs cardiologist review (C1).
Until then every urgency result is labelled "research output".

---

## 6. Architecture and Technology Stack

### 6.1 Stack

| Layer | v2 choice | Change |
|---|---|---|
| Mobile app | Flutter; Riverpod, Drift, flutter_localizations (ru, ky, en) | Android first [C-27, C-64] |
| Image digitisation | U-Net-family segmentation plus classical geometry (OpenCV); permissive licences only | Replaces YOLOv11 (AGPL-3.0) [C-23]; ADR 0001, ADR 0004 |
| Signal classification | 1D ResNet/Inception baseline first; CNN+BiLSTM kept as a comparison; lead-dropout and digitisation-noise augmentation | [C-24]; ADR 0005 |
| Rules | Rate and regularity checks as an independent safety net; transparent STEMI criteria | [C-31] |
| Training data | PTB-XL v1.0.3 (21,799 records, 18,869 patients) [C-22] for training; PhysioNet/CinC 2021 sources for external test and extra training; MIT-BIH only to check beat detection | Replaces MIT-BIH as main set [C-21] |
| On-device runtime | LiteRT or ONNX Runtime behind a Dart interface | Replaces the TensorFlow Lite name [C-25]; ADR 0006 |
| Backend | Python, FastAPI, PostgreSQL | ADR 0007 |
| Admin panel | FastAPI + SQLAdmin first | [C-26] |
| Report text | Template engine with protocol-sourced text. **No LLM** in the report path. | Replaces optional LLM [C-28] |
| Hosting | Not decided | [C-52]; ADR 0007 |

Open: hosting depends on whether health data must stay in the KR (see
[data management plan](../../privacy/DATA_MANAGEMENT_PLAN.md) section 12).
Open: Open-ECG-Digitizer (CC BY-SA 4.0) is a baseline only under ADR 0001; the digitiser
approach is staged and decided on measured SNR (ADR 0004).

### 6.2 Processing pipeline

1. **Guided capture and quality gate.** Perspective correction, glare and blur checks,
   retake prompt.
2. **Segmentation.** Trace extraction from the background [C-23].
3. **Calibration.** Grid detection; paper speed and gain read from the paper [C-34].
4. **Lead layout and digitisation.** Identify leads; convert pixels to a time series.
5. **Signal quality gate.** Poor signal leads to grey [C-33].
6. **Classification and rules.** Findings with a confidence word; urgency by the rules in
   section 5.
7. **Report.** Template text with sources [C-28, C-29].
8. **Storage.** Local history; optional sync with consent [C-54].

### 6.3 Inference location

On-device first. A server "heavy path" is optional, needs consent, and must give the same
output and safety rules. Models and protocol texts are versioned, hashed and updated through
a manifest; every result stores the versions used (ADR 0006).

### 6.4 Data model (simplified)

| Entity | Key fields |
|---|---|
| Patient | Local case reference (optional), age band, sex |
| ECG record | ID, photo hash, quality score, detected speed/gain, leads found, facility, date |
| Result | Record ID, findings[], urgency, report text, model/rules/protocol versions |
| User | ID, role (feldsher, GP, MoH administrator), facility |

---

## 7. Functional Requirements

### FR-1: Image upload and preprocessing

- Capture by camera or choose from the gallery. Formats JPG, PNG, HEIC.
- Detect strip borders and correct perspective.
- Quality verdict with a specific reason ("too dark", "cut off", "blurry") and a retake
  button. "Use anyway" is allowed only as a secondary action and forces grey or a limits
  notice [C-33].
- Detect and show paper speed, gain and leads; the user can correct them [C-34].
- 3- and 6-channel strips are accepted [C-30].

### FR-2: Digitisation and analysis

- Extract the signal from the leads present; report which leads were found [C-30].
- Heart rate and rhythm findings. Intervals (PR, QRS) are shown only when quality allows;
  QTc is not reported in the MVP.
- Findings carry a confidence word (high, medium, low), not a bare percentage.
- Findings follow [section 4.3](#43-findings) [C-31, C-32, C-35].

### FR-3: Results display

- Urgency banner (icon, word, colour) [C-33], heart rate, findings list, trace overlay,
  next steps, limits notice, fixed footer disclaimer (D2).
- Action steps: 3-5 steps in ru, ky and en [C-64]. Each step cites an official protocol (KR
  MoH, else ERC/ESC) or is tagged "pending cardiologist review" [C-29].
- Buttons: "Forward to expert" (red/yellow) or "Retake / record 12-lead" (grey) [C-61].
- UX details are in [research 11](../../research/11-ux-market.md).
  Open: what a feldsher may do at first contact (C7) and which drugs and equipment FAPs have
  (C5). Action text depends on both.

### FR-4: History and logging

- Local storage of the last 50 cases on the device.
- Sync with the server when online, only what consent allows [C-54]; a result never needs sync.
- PDF export for consultation, with an embedded font covering Kyrgyz letters.
- Retention and consent follow [section 10](#10-data-management).

### FR-5: User management

- Registration linked to a facility (FAP or CFM). Roles: feldsher, GP, MoH administrator.
- Two-factor authentication for administrators.
- The app works offline with no login.

### FR-6: Administrative panel (for the MoH KR) [C-65]

- Part of the MVP [C-65].
- Dashboard: requests by region, finding types, monthly trends.
- Management of facilities and users.
- Export of de-identified data for epidemiological analysis.
- Flags for manual verification by a cardiologist.

---

## 8. Non-Functional Requirements

### Performance

- Server processing under 10 s over 3G; offline run under 20 s on an average Android phone.
  These are targets, measured in later phases on real mid-range phones [C-42].
- Server availability 99.5 % (target, kept from the original).

### Security and privacy

- TLS 1.3 for all transfers; role-based access control (RBAC).
- Pseudonymisation under the KR Digital Code No. 178 (in force Feb 2026), not GDPR [C-51].
- Photos on the server at most 30 days without the facility's explicit consent [C-53].
- Logs contain no patient data [C-54].

### Language and accessibility

- Kyrgyz, Russian and English [C-64]. Colour is never the only cue.

### Model limitations (shown in the interface) [C-55]

- Trained on public data (PTB-XL, CinC) with no Central Asian population. **Not validated on
  Kyrgyz paper** or local machines.
- Quality depends on the photo (light, angle, resolution, paper type).
- The system may miss emergencies. It does not replace the physician. It is a clinical
  decision support system (CDSS).

---

## 9. Evaluation

Full protocol: [PROTOCOL.md](../../eval/PROTOCOL.md). It is frozen before any training.

- The original accuracy numbers (98-99.4 % on MIT-BIH; at least 95 % in the roadmap and at
  least 97 % in the KPI table) are **removed** [C-20, C-40]. Overall accuracy is not a
  headline metric.
- Metrics: per-class sensitivity, specificity, PPV, AUROC and AUPRC with 95 % confidence
  intervals; calibration; abstention rate; digitiser SNR; measurement agreement; under-triage
  rate [C-20].
- Splits are by patient. PTB-XL folds 1-8 train, 9 validate, 10 test. External test on held-out
  CinC sources [C-21]. The digitiser is tested on synthetic images, public photo sets and our
  own printed photos.
- Classes with very few positives are reported as "limited evidence" [C-32].
- Thresholds are set once, after the baseline, on validation data, per class and per input
  type (photo vs digital) [C-41]. No fixed numbers are promised here.
- The urgency mapping and reference labels need cardiologist review (C1).

---

## 10. Data Management

Full plan: [DATA_MANAGEMENT_PLAN.md](../../privacy/DATA_MANAGEMENT_PLAN.md) [C-53].

- On-device first; minimal data; no patient name or ID by default.
- No patient data, real ECG photos, secrets, datasets or weights in git [C-54].
- Logging for fine-tuning only with consent and de-identification [C-54].
- Photo on server: at most 30 days without explicit facility consent [C-53]. Last 50 cases on
  the device. Other retention periods in the plan are proposals.
  Open: server retention (12 months proposed), localisation of health data and the consent
  form for patients in a FAP (C6; data plan section 12).

---

## 11. Regulation and Ethics

| Topic | v2 position |
|---|---|
| Medical device [C-50] | Software as a medical device under KR Law 216 and EAEU rules. Registration is needed for deployment. Risk class not determined. |
| POC and pilot [C-50] | Research framing. Ethics approval before any pilot; a regulator permit is probably needed. Order: retrospective validation, silent-mode pilot at one site, then assisted mode. Open: which ethics committee (C6). |
| Personal data [C-51] | KR Digital Code No. 178. Health data allowed for care and for anonymised research. |
| Clinical validation | Cardiologist comparison on Kyrgyz ECGs. The original count of at least 100 cases is a minimum, not a sample-size calculation. Open: access to data (C3). |
| Algorithm audit | Periodic accuracy report to the MoH, using the metrics in section 9. |
| Informed consent | Protocol for stored or forwarded data (data plan section 7). |
| Licences | Permissive only in the product path (ADR 0001); see SOUP table [C-56]. |
| Interface languages | Kyrgyz, Russian and English [C-64]. |

This is not legal advice. Wording needs a Kyrgyz lawyer or the regulator.

---

## 12. Roadmap [C-62]

Indicative only. This is a personal project with no fixed timeline. Phases follow
[`docs/PLAN.md`](../../PLAN.md); the original month ranges are dropped.

1. **Research and state of the art.** First pass done.
2. **Scope, requirements and design.** This spec, ADRs, evaluation protocol, safety documents,
   data plan. Remaining: author and cardiologist review, MVP scope decision, hosting decision.
3. **Proof of concept.** Notebook or web demo on public data and synthetic or CC-licensed
   images. Digitiser bake-off (ADR 0004), baseline classifier (ADR 0005). Show to the
   cardiologist.
4. **Application MVP.** Flutter app, backend, admin panel, on-device models, ru/ky/en UI.
5. **Validation and pilot.** Retrospective test on Kyrgyz ECGs, then a pilot after ethics
   approval.
6. **MoH presentation and handover.** Document package, handover, grant applications.

---

## 13. Expected Results and KPIs

### Technical

| Metric | v2 target |
|---|---|
| Classification quality | Per-class sensitivity/specificity with 95 % CI, AUROC/AUPRC, calibration, abstention rate; thresholds set once after the baseline [C-40, C-41] |
| Sensitivity for possible acute ischaemia | Aspiration only. The protocol sets the threshold per class and input type [C-41]. False negatives are the main hazard. |
| Digitiser | SNR thresholds set after the baseline (protocol T5, T6) [C-40] |
| Server processing time | Under 10 s (target, to be measured) [C-42] |
| Offline run time | Under 20 s (target, to be measured) [C-42] |

### Clinical and social (pilot)

| Metric | Target |
|---|---|
| Agreement with an expert on urgency level | At least 90 %, weighted by clinical cost; under-triage counts worse than over-triage [C-43] |
| Under-triage on red cases | Below a threshold set in the protocol (T4) [C-41] |
| Feldsher satisfaction (survey) | At least 4 of 5 (original, kept) |
| Facilities in the pilot | At least 3 FAPs or CFMs (original, kept) |
| ECGs processed in the pilot | At least 100 cases (original, kept as a minimum) |

### Value for the MoH KR

The project addresses a priority of the MoH: better CVD diagnosis at primary level in remote
districts. It aims to use ECG machines and smartphones that already exist, so no new
equipment should be needed [C-12]. This assumes the machine prints a readable trace.
Open: machine model unknown (A1). Costs in the first phase are mainly hosting and
maintenance. It could in principle cover all FAPs (about 1,060) [C-09], subject to
validation and registration.

---

## Appendix A: Portfolio outcomes (not a product requirement)

[C-63] The original listed outcomes for the author's university admission: an open-source
prototype, a conference presentation, a cooperation letter from NCCIM or the MoH, pilot data
and a presentation. They are personal goals. They are kept here only as a note and are not
requirements of the product.

## Appendix B: Open items

| Item | Id |
|---|---|
| ECG machine model, paper width, sample strips | A1 (may change C-30, C-34) |
| Source of "MSS KR" | A2 |
| Missing source links | A3 |
| Digital FAP and tele-ECG status | A4 |
| AF protocol version | A5 |
| Urgency mapping and action steps review | C1 |
| Priority pathologies | C2 |
| Kyrgyz ECG data and consent | C3 |
| Introduction to NCCIM or KSMA | C4 |
| Drugs, equipment and referral routes in FAPs | C5 |
| Ethics committee | C6 |
| What a feldsher may do at first contact | C7 |
| Hosting and data localisation | ADR 0007; data plan section 12 |
