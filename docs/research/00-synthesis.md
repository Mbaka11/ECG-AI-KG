# 00 — Phase 1 research synthesis

Date: 2026-10-29 · Status: **draft v1** · Inputs: research notes 01–08 in this folder
(each note has its own sources and verification labels; this synthesis does not add new
sources except where marked).

## Bottom line

The project is **feasible as a research POC and worth building**, but the specification
needs several corrections, and the hardest part is not the one the spec focuses on.

1. **The hard part is photo → signal, not classification.** Classifying a clean digital
   12-lead ECG is a largely solved research problem (PTB-XL macro-AUROC ≈ 0.93–0.96 with a
   plain 1D CNN). Digitising a *phone photo* of a paper ECG is not: in the PhysioNet 2024
   Challenge the winner fell from 12 dB SNR on scans to about −1 dB on phone photos; the
   best open tool reaches 10–12 dB on photos in its own study and 1–2 dB on another
   dataset. ([04](04-digitisation.md))
2. **Real FAP machines are probably 3- or 6-channel thermal printers**, not 12-lead A4
   printouts (public tenders: 3-channel portable units, ~48–80 mm paper). Rhythm problems
   (AF, VT, AV block, brady/tachy) can be read from 1–3 leads; ST-elevation MI and bundle
   branch blocks need 12 properly identified leads. ([02](02-kyrgyz-context.md), [01](01-clinical-domain.md))
3. **The Kyrgyz MoH is already moving on AI-ECG in FAPs**: 200 "Digital FAP" kits with an
   AI-interpreting ECG agreed with SberMedAI (Russia, Jan 2025, procurement status unknown);
   an NCCIM plan (Mar 2026) for tele-ECG from FAPs to an expert centre; World Bank funding for
   ECG machines in PHC until 2027. ECG-AI KG must be positioned as **complementary**: an
   offline assistant for the paper ECG machines that already exist, able to hand cases to a
   tele-ECG hub. ([02](02-kyrgyz-context.md), [06](06-existing-solutions.md))
4. **A strong commercial competitor exists**: PMcardio reads phone photos of 12-lead paper
   ECGs, has CE MDR class IIb / FDA De Novo (STEMI-equivalent module) and peer-reviewed
   evidence. Our differentiators are offline use, Russian/Kyrgyz UI, urgency + protocol-based
   action steps, no fee, MoH reporting, and validation on Kyrgyz paper. ([06](06-existing-solutions.md))
5. **The app is a medical device** in the KR/EAEU sense (AI interpretation of an ECG that
   affects clinical decisions). That is fine for research and a POC, but any pilot needs
   ethics approval (and possibly a regulator permit), and any deployment needs registration
   under Law No. 216 (2023) / EAEU rules. ([07](07-regulatory-ethics.md))

## Verification of the specification's claims

| Spec claim | Finding | Action for spec v2 |
|---|---|---|
| CVD = 50–52 % of deaths | ✅ 52.4 % (2023, NSC) | Keep, cite NSC |
| 17–20 k CVD deaths/yr | ⚠️ 16.5–16.9 k (2023–2024) | Use "~17 k" |
| 234.5 per 100 k (EHJ 2024) | ❌ not traceable (crude 230, age-standardised 429, WHF 2024) | Replace |
| Hypertension 34–37 % (NCCIM) | ❌ WHO STEPS 2013: 42.9 % (25–64 y) | Replace or ask source |
| Rural 65.1 % | ✅ NSC 2023 | Keep |
| IHD rank 3rd women / 5th men of 51 | ❌ not found; WHO: 3rd highest overall | Ask source or reword |
| "Every 30 min delay → +7–8 % mortality" | ⚠️ applies to **primary PCI delay in STEMI** (1-year mortality, De Luca 2004) | Reword precisely |
| "Telemedicine is an untapped lever" (WHO/WB) | ❌ quote not found | Drop or re-source |
| 980+ FAPs | ⚠️ 1,057–1,059 (2020–2023) | Update |
| 98–99.4 % accuracy on MIT-BIH | ⚠️ intra-patient splits; not meaningful for new patients | Replace by own per-class metrics |
| MIT-BIH as main training set | ❌ 2-lead Holter beats from the 1970s, no ACS | Use PTB-XL + CinC 2020/21 |
| PTB-XL = 21,837 ECGs | ⚠️ 21,799 records / 18,869 patients (v1.0.3) | Update |
| YOLOv11 = SOTA for digitisation | ⚠️ minority choice; winners use U-Net-type segmentation; Ultralytics is AGPL-3.0 | Replace |
| "Nature 2025, < 7 s, robust to folds" | ⚠️ the < 7 s result is a closed-source PMcardio paper (J Electrocardiol 2025); the open study is Stenhede et al., npj Digit Med | Correct citations |
| MoH protocols to follow | ✅ KR protocols exist: STEMI (order 1342, 2024), NSTE-ACS (2022), AF (order 626, 2024); none found for AV block / VT | Cite in action steps |

Unresolved: "МСС КР 2022–2026", "IJMEDRI 2024 ~19 000" → asked to the author
([OPEN_QUESTIONS](../OPEN_QUESTIONS.md)).

## Key findings by area

**Clinical** ([01](01-clinical-domain.md))
- Two kinds of findings: *rhythm* (single lead enough: AF/flutter, VT/VF, complete AV block,
  sinus tachy/brady) and *morphology* (12 leads needed: STEMI/equivalents, LBBB/RBBB).
- STEMI criteria miss about half of acute coronary occlusions (sensitivity ~41–44 %); even the
  best commercial OMI model shows ~52 % sensitivity in unselected ED patients. ACS from a
  photo must be a cautious "possible ischaemia — refer", never "normal".
- A draft urgency table (🔴/🟡/🟢 + ⚪ "cannot interpret") is in note 01, for cardiologist
  review. Core rule: the output is the highest urgency among findings, and low
  quality/low confidence is **never green**.
- Primary PCI is limited to a few cities (regional cath labs being added), so thrombolysis
  and referral pathways shape the action steps.

**Local context** ([02](02-kyrgyz-context.md))
- 1,059 FAPs (feldsher-run, ~90 % of villages). Phones: Android majority (70–84 %), Xiaomi
  and Samsung lead. 4G covers ~99 % of the population, but buildings/valleys may still lack
  signal → offline-first stays justified.
- Kyrgyz (`ky`) is supported by Flutter's Material localisations; an official 2024
  Russian–Kyrgyz medical dictionary exists (licence unchecked).

**Data** ([03](03-datasets.md))
- Classifier: PTB-XL (CC BY 4.0) + PhysioNet/CinC 2021 sources + Chapman/Ningbo (CC BY 4.0);
  external tests on other sources. Patient-wise splits only.
- Digitiser: synthetic images from ECG-Image-Kit (BSD-3), tested on ECG-Image-Database and
  PM-ECG-ID real photos. No public set of real smartphone photos with labels at scale.
- Gaps: no Central Asian data; few VT/VF/AV-block-III and no clean STEMI/OMI labels
  (ACS-ECG 2026 dataset is a candidate; licence to confirm).

**Digitisation** ([04](04-digitisation.md))
- Start from existing open work instead of from scratch: Open-ECG-Digitizer (best photo
  results; **CC BY-SA 4.0** — share-alike) and the BSD-2 PhysioNet 2024 entries.
- Pipeline: guided capture → perspective correction → U-Net segmentation → grid/calibration
  estimation → lead layout → vectorisation → signal quality gate.

**Classification** ([05](05-classification.md))
- Small 1D CNN/ResNet (1–5 MB int8) on 2.5 s × 12 segments + rhythm strip, trained with
  lead dropout and digitisation-noise augmentation. Rule-based rate/regularity checks as an
  independent safety net. Foundation models (ECGFounder, ECG-FM — MIT) only as teachers or
  baselines in v1.
- On-device inference is not the bottleneck (tens of ms).

**Existing solutions** ([06](06-existing-solutions.md)) — PMcardio (photo, regulated),
ECG Buddy (photo, Korea), SberMedAI Digital FAP (device, Russia, MoH deal), Russian
cloud AI-ECG for digital signals, tele-ECG with human over-read (Tricog). None found that is
offline, photo-based and in Russian/Kyrgyz with action steps.

**Regulation and licensing** ([07](07-regulatory-ethics.md)) — SaMD under Law 216 / EAEU;
personal data under the Digital Code No. 178 (in force Feb 2026; health data allowed for
care and for anonymised research); data localisation unclear. No AGPL (Ultralytics) or
non-commercial code/weights in the product path.

**Tooling** ([08](08-dev-tooling-and-agent-skills.md)) — official Flutter skills + Dart MCP
server; Flutter stack: Riverpod, Drift, flutter_localizations (ru/ky/en), flutter_litert,
ML Kit / cunning document scanner, CustomPainter ECG view, pdf/printing; avoid isar, hive,
Syncfusion. Admin: FastAPI + SQLAdmin first. ECG Python: wfdb, neurokit2, ecg-image-kit,
torch_ecg (all permissive).

## Recommendations

### For spec v2 (Phase 2)
1. Correct the statistics and citations above.
2. Replace "98–99.4 % on MIT-BIH" by our own metrics: per-class sensitivity/specificity
   with 95 % CIs, AUROC/AUPRC, calibration, abstention rate — on patient-wise splits **and on
   real photos**.
3. Replace MIT-BIH by PTB-XL + CinC as the training base; MIT-BIH only for beat-detector checks.
4. Replace YOLOv11 by a permissive segmentation approach (U-Net family) + classical geometry.
5. Rename the ACS target "possible acute ischaemia / occlusion — refer", rule-based STEMI
   criteria as a transparent safety net.
6. Add an explicit "cannot interpret" output and the never-green-on-low-quality rule.
7. Drop the LLM from the report path; template-based text from official protocols.
8. Support short-format strips (3/6-channel thermal paper) as a first-class input, with
   reduced claims (rhythm only) when fewer than 12 leads are found.

### Proposed POC scope (Phase 3)
- Input: phone photo of a paper ECG (12-lead 3×4 first, then 3/6-channel strips).
- Output: digitised trace over the photo, heart rate, rhythm findings (AF/flutter, VT,
  complete AV block, sinus tachy/brady), conduction (LBBB/RBBB) and "possible ischaemia"
  when 12 leads are present, urgency colour, "cannot interpret" state.
- Evaluation: digitiser SNR on public photo sets; classifier per-class metrics on PTB-XL
  fold 10 + external sources; end-to-end on photos we print and photograph ourselves.
- Demo: a simple web page or notebook to show the cardiologist (then her questions).

### Positioning
"An offline, free, Russian/Kyrgyz assistant that reads the paper ECGs FAPs already print,
gives an urgency level and protocol-based next steps, and can forward the case to a tele-ECG
centre." Complementary to the MoH/NCCIM tele-ECG and Digital FAP initiatives.

## Main risks

| Risk | Likelihood / impact | Mitigation |
|---|---|---|
| Phone-photo digitisation too poor for ST analysis | High / high | Quality gate, rhythm-only claims on poor/short strips, reuse best open digitisers, collect real local photos |
| Local paper format differs from training data | High / high | Ask for sample strips; synthetic data with local layouts; detect speed/gain |
| Missed emergencies (false negatives) | Medium / critical | Sensitivity-first thresholds, never-green rule, symptom questions, clear disclaimers |
| Duplication with MoH programmes | Medium / high | Position as complementary; contact NCCIM via the cardiologist after the POC |
| Licence contamination (AGPL, CC BY-SA, NC data) | Medium / medium | Licence table; ADR before reusing any component |
| Regulatory path for a pilot | Medium / medium | Research-use framing; ethics approval; silent-mode pilot first |

## Decisions needed from the maintainer

1. **CC BY-SA 4.0 code**: OK to build on Open-ECG-Digitizer (share-alike for the derived
   digitiser) or keep the whole stack permissive (Apache/BSD/MIT only)?
2. **Android first** for the MVP (iOS later)? Research suggests yes.
3. **Positioning** as complementary to the MoH/NCCIM programmes (see above)?

## Next steps

1. Send the updated section A questions (sample strips and machine models are now the most
   important question).
2. Phase 2: write spec v2 with the change log above, ADRs (stack, digitiser, licences), the
   evaluation protocol, a hazard list and the intended-use statement.
3. Small follow-up research during Phase 2: per-class counts in PTB-XL/CinC, licences of
   ACS-ECG / PM-ECG-ID / ECG-Image-Database, full text of the KR AF and NSTE-ACS protocols.
