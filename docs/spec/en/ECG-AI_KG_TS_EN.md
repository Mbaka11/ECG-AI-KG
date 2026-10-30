# ECG-AI: An App for ECG Interpretation in Remote Regions of the KR

> English translation of the original Russian document (`docs/spec/original/`). Content unchanged; see `docs/spec/TRANSLATION_NOTES.md`.

## Relevance of the Problem

Cardiovascular diseases (CVD) are the leading cause of death in Kyrgyzstan: they consistently account for **50–52% of all deaths**, which amounts to **17–20 thousand people every year** (~50 deaths per day). In mortality from ischaemic heart disease, the Kyrgyz Republic (KR) ranks **3rd among women** and **5th among men** out of the 51 countries of the WHO European Region. More than **65% of the population** lives in rural areas, where the shortage of staff and technology is felt most acutely.

### Key Data

| Indicator | Value | Source |
|---|---|---|
| Share of CVD in the structure of mortality | 50–52% | MSS KR, 2022–2026 |
| CVD deaths per year | ~19,000 | IJMEDRI, 2024 |
| Mortality per 100,000 population | 234.5 | European Heart Journal, 2024 |
| Share of population with arterial hypertension | 34–37% | NCCIM (National Center of Cardiology and Internal Medicine) |
| Share of rural population | 65.1% | NSC (National Statistical Committee), 2023 |
| Adults aged 40–64 with a 10-year CVD risk >30% | every 5th | World Bank PHC Report |

### The Problem: Staff Shortage and Lack of ECG Expertise at the Primary Care Level

- **Shortage of cardiologists.** Feldshers and general practitioners (GPs) record ECGs but lack sufficient training to recognise life-threatening arrhythmias and acute coronary syndromes (ACS). The mountain regions (Naryn, Talas, Batken, Alay) are critically under-served by specialists.
- **Diagnostic delay = death.** In acute myocardial infarction, every 30 minutes of delay increases mortality by 7–8%. Telemedicine transmission of ECGs is effectively unavailable in most FAPs (feldsher-midwife posts).
- **The equipment is there — the interpretation is not.** Under the primary health care (PHC) reforms, ECG machines were purchased for rural facilities without a decision-support system.
- **Digital medicine is under-used.** The WHO and the World Bank state explicitly: telemedicine remains an "untapped lever" in the remote communities of the KR.

### The Technological Opportunity Already Exists

Deep learning models based on the MIT-BIH Arrhythmia Database achieve **98–99.4% accuracy** in arrhythmia classification. Algorithms for digitising paper ECGs from a smartphone photo process an image in **less than 7 seconds** while being robust to image defects (folds, stains, perspective distortion). This makes the task technically feasible as a research project.

European Heart Journal, 2024 · IJMEDRI, 2024 · Nature — ECG digitization, 2025 · Nature — Deep learning ECG, 2024

## Project Concept

**ECG-AI KG** is a mobile application with an AI backend for the automatic interpretation of paper ECG strips from a phone photo. Target users: feldshers, nurses and GPs in the FAPs/CFMs (Centres of Family Medicine) of remote districts of the KR.

### Project Goal

To reduce the time from recording an ECG to a clinical decision on patient management **from several hours to 1–2 minutes** in facilities without a cardiologist, thereby increasing survival in ACS, life-threatening arrhythmias and other acute conditions.

### User Scenario

1. The feldsher records an ECG on the machine and takes a photo of the strip with a smartphone.
2. Uploads the photo to the ECG-AI KG app.
3. The AI model digitises the signal and classifies the pathology.
4. On screen — the interpretation: normal / suspected pathology + type + urgency level.
5. The app provides a brief algorithm of next steps (emergency evacuation / observation / consultation).

### Key Principles

- **Offline mode** — works without internet (critical for mountain FAPs).
- **Support, not replacement** — the result is presented as "interpretation assistance", not a diagnosis; the final decision rests with the physician.
- **Simple interface** — designed for a user with an average level of digital literacy.
- **Bilingual** — Kyrgyz and Russian interface.
- **Logging** — all cases are saved for subsequent audit and model fine-tuning.

## TS (Technical Specification): System Description

The system consists of three components: a mobile application (client), an AI processing server and an administrative panel.

### System Components

| Component | Description |
|---|---|
| Mobile application | Android/iOS, offline mode (lite model), ECG photo upload, result display |
| AI backend (cloud) | Image processing server: digitisation → classification → report generation |
| Administrative panel | Case monitoring, user management, data export for the MoH KR (Ministry of Health of the KR) |

### Input Data

- A photo of a paper ECG strip (12-lead or abbreviated format) taken with a standard smartphone camera.
- Metadata: patient age and sex, facility, date/time.

### Output Data

- **Interpretation**: normal / suspected pathology (with the type indicated).
- **Urgency category**: 🔴 emergency / 🟡 observation / 🟢 scheduled consultation.
- **List of detected patterns**: e.g. "Sinus tachycardia", "Signs of ACS with ST elevation", "Atrial fibrillation".
- **Brief action algorithm**: 3–5 steps for medical staff.
- **Visualisation**: highlighting of abnormal segments on the digitised ECG.

### Target Pathologies (MVP)

In the first phase, the system recognises priority life-threatening conditions:

1. Acute coronary syndrome (ST elevation / ST depression)
2. Atrial fibrillation and flutter
3. Ventricular tachycardias / ventricular fibrillation
4. Complete AV block (3rd degree)
5. Sinus tachy- and bradyarrhythmias
6. Bundle branch blocks (LBBB / RBBB)

## TS: Architecture and Technology Stack

### Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| Mobile application | Flutter (Android + iOS) | Single codebase, offline support |
| ECG image digitisation | YOLOv11 (segmentation) + OpenCV | SOTA for paper ECG digitisation, open-source |
| Arrhythmia classification | CNN + BiLSTM (1D signal) | 98–99.4% accuracy on MIT-BIH; combines spatial and temporal patterns |
| Training dataset | MIT-BIH Arrhythmia Database (PhysioNet) | Gold standard, 48 recordings, annotated by two cardiologists |
| Additional dataset | PTB-XL (21,837 ECGs) | Extension to 12-lead and ACS |
| Backend API | Python (FastAPI) | Fast development, native DL stack |
| Cloud | Google Cloud / local MoH server | Flexibility; on-premise deployment option for data sovereignty |
| Offline lite model | TensorFlow Lite | Basic classification without internet |
| Administrative panel | React + PostgreSQL | Standard web stack |

### ECG Image Processing Pipeline

1. **Image preprocessing** — perspective correction, shadow removal, alignment to the paper grid (OpenCV).
2. **Curve segmentation** — extracting the ECG signal from the background (YOLOv11 instance segmentation).
3. **Digitisation** — converting pixels into a numerical time series calibrated against the standard grid (25 mm/s, 10 mm/mV).
4. **Classification** — CNN + BiLSTM on the 1D signal, trained on MIT-BIH + PTB-XL.
5. **Report generation** — a template engine with clinical logic + LLM augmentation for the text (optional).
6. **Logging** — saving the case to a secure DB for audit and fine-tuning.

### Data Model (Simplified)

| Entity | Key fields |
|---|---|
| Patient | ID, age, sex |
| ECG record | ID, photo (hash), facility, date |
| Result | Record ID, patterns[], urgency, report text |
| User | ID, role (feldsher/physician/admin), facility |

## TS: Functional Requirements

### FR-1: Image Upload and Preprocessing

- The user uploads a photo of the ECG strip via the camera or the gallery.
- The app automatically detects the strip borders and corrects perspective distortion.
- If the image quality is poor — a notification with instructions for retaking the photo.
- Supported formats: JPG, PNG, HEIC.

### FR-2: ECG Digitisation and Analysis

- Signal extraction from 12 leads (or from the available leads if the image is partial).
- Automatic determination of heart rate, P-Q-R-S-T intervals, QRS duration, QTc.
- Pattern classification with the model's confidence indicated (confidence score).

### FR-3: Results Display

- Result screen: urgency category (colour-coded), list of patterns, text report.
- Visualisation: digitised signal with abnormal segments highlighted.
- Action algorithm: 3–5 concrete steps (in Kyrgyz and Russian).
- Disclaimer: "The result is an auxiliary tool. The final decision rests with the physician."

### FR-4: History and Logging

- Local storage of the last 50 cases on the device.
- Synchronisation with the server when internet is available.
- Export of the record to PDF for sending for consultation.

### FR-5: User Management

- User registration linked to a facility (FAP/CFM).
- Roles: feldsher, GP, MoH administrator.
- Two-factor authentication for administrators.

### FR-6: Administrative Panel (for the MoH KR)

- Dashboard: number of requests by region, pathology types, monthly trends.
- Management of facilities and users.
- Export of de-identified data for epidemiological analysis.
- Flags for manual verification by a cardiologist (model fine-tuning).

## TS: Non-Functional Requirements, Security and Regulation

### Performance

- Image processing time on the server: **< 10 seconds** (over a standard 3G internet connection).
- Offline lite model run time: **< 20 seconds** on an average Android device.
- Server availability: **99.5%** uptime.

### Security and Confidentiality

- All patient data is transmitted over **TLS 1.3**.
- Medical data is stored in de-identified form (pseudonymisation in line with GDPR principles and the legislation of the KR).
- ECG photos are not stored on the server for longer than 30 days without the facility's explicit consent.
- Role-based access control (RBAC).

### Regulatory Requirements for Implementation via the MoH KR

| Requirement | Action |
|---|---|
| Medical software | Registration as a medical device with the MoH KR |
| Clinical validation | Pilot at the NCCIM: comparison of AI interpretations with expert ones — ≥100 cases |
| Informed consent | Patient consent protocol when data is stored |
| Algorithm audit | Quarterly report on model accuracy for the MoH |
| Interface languages | Kyrgyz + Russian (mandatory) |

### Model Limitations (Must Be Shown in the Interface)

- The model is trained on MIT-BIH + PTB-XL: data predominantly from a Western population. Fine-tuning on Kyrgyz data is required during the pilot phase.
- The quality of the result depends on the quality of the photo: lighting, shooting angle, resolution ≥ 5 MP.
- The system does not replace the physician — it is a **clinical decision support system (CDSS)**.

## Implementation Roadmap

### Phase 1 — Research and Prototype (Months 1–3)

- [ ] Study the MIT-BIH Arrhythmia Database (PhysioNet): data structure, annotations.
- [ ] Implement a basic pipeline: record loading → preprocessing → classification (CNN / BiLSTM).
- [ ] Implement a module for digitising paper ECGs from a photo (based on the open-source ECGtizer or an equivalent).
- [ ] Achieve ≥ 95% accuracy on the MIT-BIH test set across the 5 main classes.
- [ ] Document the methodology for inclusion in a school research paper.

### Phase 2 — App MVP (Months 4–6)

- [ ] Develop the mobile interface (Flutter): photo upload, result screen, history.
- [ ] Deploy the backend API (FastAPI) on a cloud server.
- [ ] Integrate TensorFlow Lite for the offline mode.
- [ ] Translate the interface into Kyrgyz and Russian.
- [ ] Carry out internal testing on 20–30 ECG strips (collected from medical acquaintances).

### Phase 3 — Pilot and Validation (Months 7–9)

- [ ] Approach the NCCIM or KSMA (Kyrgyz State Medical Academy) with a proposal for cooperation.
- [ ] Conduct pilot testing: 100+ cases, comparison with a cardiologist's expert interpretation.
- [ ] Collect feedback from feldshers at 2–3 FAPs (usability).
- [ ] Publish the research results (school conference / journal).

### Phase 4 — Presentation to the MoH KR and Scaling (Months 10–12)

- [ ] Prepare a document package for the MoH: TS, pilot results, implementation plan.
- [ ] Present the project at a meeting of the MoH KR working group on digital health.
- [ ] Hand over the source code and documentation to the government partner.
- [ ] Apply for a grant (UNDP, WHO KR, AKF Health Program).

## Expected Results and KPIs

### Technical KPIs

| Metric | Target value |
|---|---|
| Classification accuracy | ≥ 97% on the MIT-BIH test set |
| Sensitivity (recall) for ACS | ≥ 95% (critical: false negatives are unacceptable) |
| Specificity | ≥ 93% |
| Photo processing time (server) | < 10 s |
| Offline model run time | < 20 s |

### Clinical and Social KPIs (Pilot)

| Metric | Target value |
|---|---|
| Agreement with an expert cardiologist | ≥ 90% on urgency category |
| Feldsher satisfaction (survey) | ≥ 4/5 points |
| Number of facilities in the pilot | ≥ 3 FAPs/CFMs |
| Number of ECGs processed during the pilot | ≥ 100 cases |

### Portfolio Outcomes (for University Admission)

- A working prototype of the ECG-AI KG app with open source code on GitHub.
- A scientific publication or conference presentation (school / regional level).
- An official letter/MoU from the NCCIM or the MoH KR on cooperation.
- Pilot data: confusion matrix, ROC curve, feedback from medical staff.
- A project presentation for the MoH KR (this document is the basis).

### Value for the MoH KR

The project addresses a problem that the MoH KR officially recognises as a priority: improving the quality of CVD diagnosis at the primary care level in remote districts. It does not require the purchase of new equipment — it uses the ECG machines and medical staff's smartphones that already exist. The cost of implementation in the first phase is minimal (cloud server + maintenance), while it can potentially cover all 980+ FAPs in the country.
