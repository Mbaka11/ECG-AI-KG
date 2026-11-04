# Intended-use statement (draft v0.1)

Status: **draft for the maintainer and the cardiologist** · Phase 2 · 2026-11-04.
Related: [HAZARD_LIST](HAZARD_LIST.md), [SOUP_LICENCES](SOUP_LICENCES.md),
[research 07](../research/07-regulatory-ethics.md), [ADR 0003](../adr/0003-positioning-complementary.md),
[spec v2 change log](../spec/v2/CHANGELOG.md) (C-28, C-30, C-31, C-33, C-35, C-50, C-56).

Evidence labels: statements about clinical facts cite a repo research note. Anything not backed
by a note is marked **pending cardiologist review**. This is not legal advice; regulatory
wording must be confirmed by a Kyrgyz lawyer or the regulator (research 07).

## 1. One-paragraph statement

ECG-AI KG is an offline, free decision-support tool that reads a phone photo of a paper ECG
printed by a machine already in use, digitises the trace, and shows (a) a quality verdict, (b) a
heart rate and a small set of cautious rhythm and pattern findings, (c) an urgency colour or a
"cannot interpret" state, and (d) next-step text taken from official protocols. It supports a
trained health worker. It does not diagnose, does not replace clinical judgement or a
cardiologist's reading, and a green or "normal-looking" result never excludes disease.

## 2. Users and setting

| Item | Statement | Source |
|---|---|---|
| Primary user | Feldsher or nurse at a feldsher-obstetric point (FAP) or similar first-contact site, in Kyrgyzstan | research 00 and 02 (FAPs are feldsher-run; ~1,059 sites) |
| Secondary users | Family doctors, cardiologists or a tele-ECG hub receiving a forwarded case; MoH staff seeing anonymised statistics (admin panel) | ADR 0003; spec v2 C-61, C-65 |
| Setting | Primary care, possibly without network; the phone is the only device | research 00 (offline-first) |
| Not for | Patients or the public using the app on themselves; hospital diagnosis; ambulance or ICU monitoring | Design decision; pending cardiologist review |
| Language | Russian, Kyrgyz, English UI; clinical wording in ru/ky needs a human medical reviewer | spec v2 C-64; research 08 |
| Platform | Android first | ADR 0002 |

The KR protocols read for this project name physicians as users, not feldshers; no feldsher
checklist was found (research 10). What a feldsher may do at first contact is an open question
(OPEN_QUESTIONS C7). Until answered, action text is **pending cardiologist review**.

## 3. Inputs

- A photo of a paper ECG from a machine already in use. First: 12-lead 3x4 prints; then 3- and
  6-channel thermal strips as first-class inputs ([01 s1.3](../research/01-clinical-domain.md),
  spec v2 C-30).
- The app must read or detect paper speed and gain (25/50 mm/s, 5/10/20 mm/mV) rather than
  assume defaults (research 01 s1.2; spec v2 C-34).
- 2 to 4 yes/no clinical context questions (chest pain, syncope, shortness of breath, low blood
  pressure if measured). The exact question set is **pending cardiologist review**
  (research 01 s3).
- No patient name or ID is needed for triage (research 07, implication 4).

## 4. Outputs

1. Image quality verdict, with a retake prompt when poor.
2. Digitised trace shown over the photo, so the user can check it against the paper.
3. Heart rate and rhythm findings. Wording is "suspected ..." and "pattern suggestive of ...",
   never "diagnosis" (research 01, implication 7).
4. Pattern findings that need 12 identified leads (possible acute ischaemia / occlusion, LBBB,
   RBBB) are shown only when 12 leads were found; with fewer leads claims are limited to rhythm
   (spec v2 C-30, C-31).
5. Urgency: red, yellow, green, or grey "cannot interpret". The result is the highest urgency
   among findings; low quality or low confidence is **never green** (research 00; spec v2 C-33).
   The thresholds are a first draft **pending cardiologist review** (research 01 s3).
6. Next-step text from a template engine only, no LLM (spec v2 C-28). Each step carries its
   source (KR MoH protocol, else ERC/ESC) or the tag "pending cardiologist review"
   (spec v2 C-29). Content known so far is in [research 10](../research/10-kr-protocols.md); no KR
   protocol was found for AV block or VT/VF (research 01 s4).
7. A "forward to an expert / tele-ECG centre" action (ADR 0003; spec v2 C-61).

## 5. What it is NOT

- Not a diagnosis. Troponin and clinical context are required to define MI (research 01 s2.1).
- Not a replacement for a cardiologist, for a 12-lead read by a physician, or for calling
  emergency help when the patient looks unwell.
- Not a rule-out tool. "Green" and "no finding" never mean healthy. STEMI criteria miss about
  half of acute coronary occlusions (research 01, summary and s5), and a model can miss the same.
- Not an AF diagnosis. The KR AF protocol needs an episode over 30 s; a strip is about 10 s
  (research 10 s1; spec v2 C-35).
- Not a QT or QTc tool; QTc is not reported in the MVP (research 01 s1.4).
- Not validated on Kyrgyz paper, local machines or the target population (spec v2 C-55).
- Not for patients in cardiac arrest or for continuous monitoring (research 01 s2.4: VF will
  rarely be photographed).
- Not a competitor to, or replacement of, MoH/NCCIM Digital FAP and tele-ECG programmes
  (ADR 0003).
- Does not use an online LLM or send patient data or ECG photos to an online service
  (spec v2 C-28; AGENTS.md; research 07).

## 6. Research framing for the POC (Phase 3) and any pilot

- The POC is a notebook or simple web demo, not a mobile app. It uses public datasets and
  synthetic or CC-licensed images only; no patient data and no real ECG photos in git
  (AGENTS.md; research 07 POC checklist).
- Results are reported as research metrics: per-class sensitivity and specificity with 95 % CI,
  AUROC/AUPRC, calibration and abstention rate, on patient-wise splits and on real photos
  (spec v2 C-20). No accuracy claim from MIT-BIH.
- The software is described as a research prototype. It must not be used to make clinical
  decisions on real patients.
- The app is almost certainly software as a medical device under KR Law 216 / EAEU rules
  (research 07, Partly verified). Disclaimers do not change that status; the intended purpose
  and real function decide. A prospective pilot where a feldsher sees the output is a clinical
  investigation of an unregistered device and needs an ethics opinion and probably a regulator
  permit. The silent-mode (output hidden) framing is **Unverified** for KR (research 07 s1).
- Planned order: retrospective validation, then silent-mode pilot at one site, then assisted
  mode (research 07, implication 6). The risk class (2b or 3 expected) is not determined.
- Contact with NCCIM only through the cardiologist after the POC (ADR 0003).

## 7. Mandatory UI disclaimers and limitations

These texts must appear in ru, ky and en, with the Russian and Kyrgyz wording reviewed by a
medical translator or the cardiologist (research 01 open question 6). Suggested English
wording below; final text **pending cardiologist review**.

| ID | Where shown | Required content |
|---|---|---|
| D1 | First launch, with acknowledgement; also in "About" | "Research prototype. Decision support for a trained health worker. Not a diagnosis. Does not replace clinical judgement or a cardiologist." |
| D2 | Every result screen, fixed footer | "Not a diagnosis. A green result does not exclude disease. If the patient is unwell, act per protocol and call for help." (research 07 s6) |
| D3 | Red result | "Possible emergency. Act per protocol and call for help now." plus the step list with sources |
| D4 | Grey "cannot interpret" | "No result. Repeat the photo, record a 12-lead ECG, or send to an expert." Never shown as green or as "normal" |
| D5 | Strips with fewer than 12 identified leads | "Only rhythm was assessed. Heart attack signs and bundle branch blocks cannot be assessed from this strip." (research 01 s2; spec v2 C-30) |
| D6 | AF finding | "Suspected atrial fibrillation. Confirmation needs an ECG of more than 30 s and a clinician." (research 10 s1) |
| D7 | Any ischaemia-related finding or its absence | "ECG alone cannot exclude acute coronary syndrome; troponin and clinical assessment are needed." (research 01 s2.1) |
| D8 | Every result | Detected speed, gain, leads found and image quality score, so the user can check them; digitised trace overlaid on the photo |
| D9 | Every result | App version, model version and protocol-text version with date (hazards H-08, H-12) |
| D10 | Protocol-derived steps | Source name and date next to each step, or "pending cardiologist review" while unreviewed |
| D11 | About / data screen | What is stored, where, for how long; no identifiers by default; consent text if a case is forwarded (research 07 s3; spec v2 C-53) |
| D12 | Pilot builds only | Study-use notice stating whether output is hidden or shown per the approved protocol, and the ethics approval reference |

## 8. Limitations to state in documentation and papers

- Photo-to-signal is the weakest step: published digitisers drop to roughly 10-12 dB SNR on
  phone photos, and one 2024 Challenge winner to about -1 dB (research 00 and 04).
- Public training data have no Central Asian population and few VT/VF and complete AV block
  cases; no clean STEMI/OMI labels in PTB-XL or CinC (research 00, 03; spec v2 C-32).
- Best published AI OMI models reach only about 52 % sensitivity in unselected ED patients
  (research 00, Partly verified).
- Machine AF statements are often wrong: of 1057 AF-related ECGs 79.5 % were true AF
  (research 01 s5, Partly verified).
- All clinical thresholds, action steps and the urgency table are drafts until the cardiologist
  signs them off.

## 9. Change control

This statement is versioned with the spec. Any change to inputs, outputs or claims needs a new
entry in the spec change log and a review of the hazard list.
