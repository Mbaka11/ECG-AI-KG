# Research 01 — Clinical domain for ECG-AI KG

Date accessed for all sources: 2026-10-29. Status: **draft for the developer; every clinical rule below needs cardiologist review before it goes into the app.**

Verification labels: **Verified** = I read the source page/text itself; **Partly verified** = only a search-result excerpt/summary of the source was read, or the source confirms only part of the claim; **Unverified** = general textbook knowledge or tool-generated summary I did not check against a source (do not rely on it without a check).

## Summary

- A standard 12-lead ECG is a 10-second recording at 25 mm/s and 10 mm/mV; at those settings 1 mm = 40 ms and 1 mm = 0.1 mV (AHA/ACCF/HRS standardisation statement). Partly verified.
- Printed layouts vary (3x4 + rhythm strip, 6x2, 12x1, single channel), so the digitiser must detect the layout, lead labels, calibration pulse and grid scale itself. Layout conventions are Unverified in detail (textbook knowledge); the ESC/AHA sources do not define them.
- **Single-lead is enough for rhythm questions** (AF, flutter, sinus tachy/brady, probably complete AV block, VF). **12 leads are needed for** STEMI/ischaemia, bundle branch blocks, and reliable VT vs SVT-with-aberrancy. STEMI needs ≥2 *contiguous* leads (ESC 2023). Partly verified.
- The ESC 2023 ACS guideline still uses STEMI thresholds (ST elevation ≥1 mm, V2–V3 sex/age-specific thresholds), but names equivalents that need reperfusion triage: posterior MI, diffuse ST depression with aVR elevation, BBB/paced rhythm with a suggestive clinical picture. Partly verified (via secondary hosts of the guideline text).
- **STEMI criteria miss many occlusion MIs.** A 2021 study reports sensitivity 41% for STEMI criteria vs 86% for expert OMI reading (808 patients); a 2024 JACC: Advances review reports pooled STEMI-criteria sensitivity of only 43.6% for acute coronary occlusion. Partly verified. A STEMI-only classifier will therefore miss roughly half of the emergencies.
- Commercial machine interpretation is imperfect: in one cohort, the vendor algorithm had 62.9% sensitivity / 95.6% specificity for confirmed STEMI; for AF, 20.5% of "AF" statements were not true AF in a 10,279-ECG study. Partly verified.
- **Kyrgyz MoH protocols exist and are online** on MedElement: STEMI revascularisation (order No. 1342, 25.12.2024), NSTE-ACS (2022), AF (order No. 626, 11.06.2024). I found **no separate KR protocol for AV block or VT**. Verified for STEMI; Partly verified for the others.
- In Kyrgyzstan primary PCI is limited (cath labs in only three cities, per a 2022 editorial by NCCT physicians), so thrombolysis is the main STEMI reperfusion; this makes a rural "STEMI = red, refer now" output clinically meaningful but the *action steps* depend on local drug availability. Verified (single source).
- Urgency mapping in section 3 is my draft only; the ordering "VT/VF/complete block/STEMI = red" is standard, but the thresholds are not validated.

## 1. ECG fundamentals for engineers

### 1.1 Leads
Standard 12 leads: limb leads I, II, III, aVR, aVL, aVF (frontal plane) and chest leads V1–V6 (horizontal plane). "Contiguous" groups used for STEMI: inferior (II, III, aVF), lateral (I, aVL, V5–V6), anterior/septal (V1–V4). Unverified (textbook), but consistent with ESC wording "≥2 contiguous leads".

### 1.2 Calibration and grid (Partly verified)
- Standard: **25 mm/s** and **10 mm/mV**. At 25 mm/s: 1 mm (small square) = 40 ms, 5 mm (large square) = 200 ms; at 10 mm/mV: 1 mm = 0.1 mV. Source: [AHA/ACC competence statement summary via JACC](https://www.jacc.org/doi/10.1016/S0735-1097%2801%2901680-1) (search-tool summary, not read in full).
- A standard 12-lead is a continuous 10 s acquisition; at 25 mm/s four 2.5 s columns fit standard paper ([Kligfield et al. 2007, Part I](https://www.jacc.org/doi/10.1016/j.jacc.2007.01.024)). Partly verified.
- Calibration pulse: normally a 1 mV square pulse (10 mm tall at default gain). Many machines allow 5 or 20 mm/mV and 50 mm/s. Unverified; **the app must read the printed speed/gain annotations or detect the pulse rather than assume defaults.** (Engineering inference.)

### 1.3 Paper layouts (Unverified — textbook/engineering knowledge; to be confirmed against real FAP machines in research 02)

| Layout | Description | Implication for the digitiser |
|---|---|---|
| 3x4 (+ rhythm strip) | 4 columns × 2.5 s: I/aVR/V1/V4, II/aVL/V2/V5, III/aVF/V3/V6, plus a 10 s lead II strip | Leads are *not simultaneous across columns*; each lead is only 2.5 s. Rhythm strip gives the 10 s window. |
| 6x2 | 2 columns × 5 s (limb leads left, chest leads right) | Typical of Russian/Chinese machines. Check if used in KR. |
| 12x1 | Each lead 10 s, stacked (or sequential single-channel print on small thermal roll) | Longest lead windows; page often needs several photos. |
| Single/3-channel strip | One or three channels printed one after another on a narrow roll | Lead identity only from printed label or from user selection. |

### 1.4 Key intervals and normal values (Unverified as numeric ranges — standard textbook values; confirm with cardiologist)

| Parameter | Typical adult normal | Notes |
|---|---|---|
| Heart rate | 60–100 bpm | <60 bradycardia, >100 tachycardia (definitions) |
| PR | 120–200 ms | >200 ms = 1st-degree AV block |
| QRS | <120 ms (≥120 ms = wide; BBB "complete") | |
| QT/QTc | QTc roughly <450 ms men, <460 ms women | Bazett overcorrects at high rates. |

QT correction: AHA/ACCF/HRS Part IV recommends linear-regression rate correction rather than Bazett and says the method must be stated ([JACC 2009](https://www.jacc.org/doi/10.1016/j.jacc.2008.12.014)). Partly verified. Fridericia and Framingham are common alternatives (Unverified). QTc is not an MVP class; recommend not reporting it in the MVP.

## 2. MVP target pathologies

Lead requirement = my engineering/clinical judgement unless a source is cited. Treat as Unverified inference.

### 2.1 STEMI / ACS / STEMI equivalents
- **ECG criteria (ESC 2023, Partly verified):** new J-point ST elevation in ≥2 contiguous leads: ≥1 mm in all leads except V2–V3; in V2–V3 ≥2.5 mm (men <40 y), ≥2 mm (men ≥40), ≥1.5 mm (women); absent LVH/LBBB. 12-lead ECG interpreted within 10 min of first medical contact. Source: [ESC 2023 ACS (OUP)](https://academic.oup.com/ehjacc/article/13/1/55/7280662) and [full PDF mirror](https://ecgweekly.com/wp-content/uploads/2023/12/ehad191.pdf) — read only via search-tool summaries.
- **Equivalents named by ESC 2023 (Partly verified):** posterior MI (ST depression V1–V3 with positive terminal T; confirm with V7–V9 ≥0.5 mm); right-sided leads V3R–V4R for RV infarct; ST depression ≥1 mm in ≥6 leads plus STE in aVR and/or V1 (possible left main/multivessel) especially with haemodynamic compromise; LBBB/paced/RBBB with highly suspicious symptoms treated like STEMI. de Winter and Wellens patterns described under NSTE-ACS. Source: [ESC 2023 supplementary text (mirror)](https://studylib.net/doc/28614336/ehad191-supplementary-data). Unofficial mirror; check against the official supplement.
- **4th Universal Definition of MI:** MI = myocardial necrosis + ischaemia evidence (troponin rise/fall above 99th percentile plus symptoms, new ischaemic ECG changes, Q waves, imaging, or thrombus). Verified as *quoted* in the KR STEMI protocol ([KR 2024 protocol](https://diseases.medelement.com/disease/%D1%80%D0%B5%D0%B2%D0%B0%D1%81%D0%BA%D1%83%D0%BB%D1%8F%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D0%BC%D0%B8%D0%BE%D0%BA%D0%B0%D1%80%D0%B4%D0%B0-%D0%BF%D1%80%D0%B8-%D0%BE%D1%81%D1%82%D1%80%D0%BE%D0%BC-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D0%BE%D0%BC-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC%D0%B5-%D1%81-%D0%BF%D0%BE%D0%B4%D1%8A%D0%B5%D0%BC%D0%BE%D0%BC-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BA%D0%BF-%D0%BA%D1%80-2024/18614)); the original document was not opened. An ECG alone cannot diagnose MI, which matters for wording ("ECG pattern suggestive of…").
- **Leads needed:** 12 (≥2 contiguous leads; plus aVR/V1 and posterior/right leads for equivalents). A single lead cannot reliably detect STEMI. A photo of a 3x4 print gives 2.5 s per lead, which is enough for ST analysis if the baseline and calibration are read correctly.
- **Urgency:** red. **KR targets (Verified, [KR 2024 protocol](https://diseases.medelement.com/disease/%D1%80%D0%B5%D0%B2%D0%B0%D1%81%D0%BA%D1%83%D0%BB%D1%8F%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D0%BC%D0%B8%D0%BE%D0%BA%D0%B0%D1%80%D0%B4%D0%B0-%D0%BF%D1%80%D0%B8-%D0%BE%D1%81%D1%82%D1%80%D0%BE%D0%BC-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D0%BE%D0%BC-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC%D0%B5-%D1%81-%D0%BF%D0%BE%D0%B4%D1%8A%D0%B5%D0%BC%D0%BE%D0%BC-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BA%D0%BF-%D0%BA%D1%80-2024/18614)):** first medical contact → ECG/diagnosis ≤10 min; diagnosis → primary PCI wire ≤120 min, otherwise thrombolysis; thrombolysis start ≤10 min after the decision; transfer from non-PCI centre ≤30 min after diagnosis; fibrin-specific agents (alteplase, tenecteplase, prourokinase, staphylokinase) preferred.
- **Feldsher first steps:** the KR protocol read covers hospital/revascularisation; no feldsher-level checklist was found in it. Russian federal guidance (a different country; use only as a reference) lists aspirin chewed 150–300 mg, IV access, nitrate/analgesia, heparin, early thrombolytic where PCI >120 min ([Russian MoH 2024 pre-hospital algorithm, Garant](https://base.garant.ru/410995878/f62c3b6c2c0ea0367ed000160e1a00cc/)). Partly verified (search excerpt). **App action steps must come from the KR protocol/cardiologist, not from this.**
- **ST depression without elevation / NSTE-ACS:** yellow→red depending on symptoms; KR protocol 2022 exists ([nccim.kg PDF](https://nccim.kg/wp-content/uploads/2023/06/%D0%9F%D1%80%D0%BE%D1%82%D0%BE%D0%BA%D0%BE%D0%BB-%D0%9E%D0%9A%D0%A1%D0%91%D0%9F%D0%A1%D0%A2-2022.pdf), Partly verified, not opened). ECG alone cannot exclude NSTE-ACS; troponin is needed.

### 2.2 Atrial fibrillation (AF)
- **Criteria:** ESC 2024: ECG confirmation (12-lead, multiple, or single-lead) is required for clinical AF; the 2020 guideline text defined it as a 12-lead or single-lead tracing ≥30 s with no discernible repeating P waves and irregular RR intervals ([ESC 2024](https://doi.org/10.1093/eurheartj/ehae176), [ESC 2020](https://doi.org/10.1093/eurheartj/ehaa612)). Partly verified (search excerpts). The 2024 text says ≥30 s "may indicate clinical concern" in ambulatory ECG ([ESC 2024 OUP](https://academic.oup.com/eurheartj/article/45/36/3314/7738779)).
- **Leads:** single lead is sufficient; a 10 s rhythm strip is shorter than 30 s, so the app should say "suspected AF" and not "diagnosis".
- **Urgency:** green/yellow if haemodynamically stable and rate controlled; red if unstable (shock, syncope, acute heart failure, ischaemia) or very fast with wide QRS (Unverified; draft).
- **Feldsher steps:** Unverified; the KR AF protocol ([MedElement 2024](https://diseases.medelement.com/disease/%D1%84%D0%B8%D0%B1%D1%80%D0%B8%D0%BB%D0%BB%D1%8F%D1%86%D0%B8%D1%8F-%D0%BF%D1%80%D0%B5%D0%B4%D1%81%D0%B5%D1%80%D0%B4%D0%B8%D0%B9-%D0%B4%D0%B8%D0%B0%D0%B3%D0%BD%D0%BE%D1%81%D1%82%D0%B8%D0%BA%D0%B0-%D0%B8-%D0%BB%D0%B5%D1%87%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BF-%D0%BA%D1%8B%D1%80%D0%B3%D1%8B%D0%B7%D1%81%D1%82%D0%B0%D0%BD-2024/18064)) should be mined in Phase 2.

### 2.3 Atrial flutter
Regular atrial activity ("sawtooth", ~300/min) with a fixed AV ratio (often 2:1, ventricular ~150/min). Unverified (textbook). Same KR protocol (ICD I48 covers AF and flutter). Leads: II, III, aVF, V1 best; single lead can suggest it but flutter 2:1 is easily confused with SVT/sinus tachycardia. Urgency like AF; red if unstable.

### 2.4 Ventricular tachycardia (VT) and ventricular fibrillation (VF)
- **VT:** ≥3 consecutive beats, rate >100 and QRS >120 ms; most regular wide-complex tachycardias are VT, especially with structural heart disease ([PMC review](https://pmc.ncbi.nlm.nih.gov/articles/PMC10541285/); [Singapore ACLS 2021](https://pmc.ncbi.nlm.nih.gov/articles/PMC8804484/)). Partly verified. VT vs SVT with aberrancy is best judged on 12 leads; a safe rule is "regular wide-complex tachycardia = treat as VT".
- **VF:** chaotic undulation, no identifiable QRS. Unverified (textbook). Patient is pulseless/unconscious — nobody photographs a strip first; in practice the app will meet VF only on monitor/defibrillator printouts or in post-event review.
- **Unstable features (ERC 2021):** shock (e.g. SBP <90), syncope, myocardial ischaemia, severe heart failure ([ERC 2021 ALS](https://www.resuscitationjournal.com/article/S0300-9572(21)00063-0/fulltext)). Partly verified. Unstable → synchronised cardioversion; VF/pulseless → CPR + defibrillation (standard; Unverified here).
- **Urgency:** red. **Leads:** single lead detects wide fast rhythm/VF; 12-lead for VT vs SVT. **Feldsher:** call emergency help, check pulse/consciousness, start CPR + defibrillator if pulseless (AED if available). The KR protocols found do not cover this.

### 2.5 Complete (third-degree) AV block
- **Criteria:** no relationship between P waves and QRS (AV dissociation), atrial rate > ventricular rate, slow regular escape rhythm (narrow = junctional, wide = ventricular). Unverified (textbook).
- **Management:** ESC 2021 pacing guideline gives a Class I indication for permanent pacing in third-degree AV block regardless of symptoms unless a reversible cause exists ([ESC 2021, via search summary](https://academic.oup.com/europace/article/24/1/71/6358627)). ERC 2021: atropine 500 µg IV (repeat to 3 mg) for bradycardia with adverse features, but atropine may fail in complete block (wide-QRS, infranodal); transcutaneous pacing is the bridge ([ERC 2021 ALS PDF](https://www.resuscitation.eu/assets/guidelines/European-Resuscitation-Council-Guidelines-2021-Ad.pdf)). Partly verified.
- **Leads:** single lead with visible P waves is enough; 12-lead helps to exclude inferior MI as cause.
- **Urgency:** red (needs hospital pacing). **Feldsher:** monitor, IV access, oxygen if hypoxic, transport with ECG monitoring; atropine as per protocol; pacing if available — these details Unverified for KR.

### 2.6 Sinus tachycardia / bradycardia
- Definitions: >100 bpm / <60 bpm with normal sinus P waves (textbook, Unverified). They are *signs*, not diagnoses; the work-up is the cause (fever, hypovolaemia, hypoxia, anaemia, drugs, hypothyroidism, athlete). ERC lists "identify and treat reversible causes e.g. electrolyte abnormalities, hypovolaemia causing sinus tachycardia" ([Resus Council UK tachycardia algorithm 2021](https://www.resus.org.uk/sites/default/files/2021-04/Tachycardia%20Algorithm%202021.pdf)). Partly verified.
- Leads: single lead. Urgency: green if asymptomatic and <130/ >40; yellow if symptomatic or extreme; red if unstable (draft).
- Pitfall: sinus tachycardia ~150 bpm vs atrial flutter 2:1 vs SVT; sinus bradycardia vs 2:1 AV block or blocked atrial bigeminy.

### 2.7 LBBB / RBBB
- **Criteria (Unverified, textbook):** QRS ≥120 ms; LBBB: broad notched/slurred R in I, aVL, V5–V6, QS/rS in V1; RBBB: rSR' in V1 and wide S in I, V6.
- **Clinical significance:** new LBBB with symptoms of ACS is handled as a STEMI equivalent in ESC 2023 (suspicious clinical picture, whether or not the BBB is new) — Partly verified; Sgarbossa criteria may help, LBBB alone is not an occlusion diagnosis ([ESC 2023 supplement mirror](https://studylib.net/doc/28614336/ehad191-supplementary-data)). Chronic BBB in an asymptomatic patient is mostly green/yellow (outpatient work-up).
- **Leads:** 12 (V1 and V6/I necessary); single lead cannot classify. Urgency depends on clinical context, which the app cannot know unless it asks symptom questions (see below).

## 3. FIRST DRAFT urgency mapping — **for cardiologist review, not clinical guidance**

Assumptions: the app asks 2–4 yes/no questions (chest pain, syncope, shortness of breath, SBP <90 if measured). Without clinical context "red" must be assigned conservatively.

| Pattern | Default | Escalate to red if | Downgrade/notes | Min. leads |
|---|---|---|---|---|
| STEMI / STEMI equivalent (STE criteria, posterior, aVR+diffuse STD) | 🔴 | — | Time-critical; refer/transport + reperfusion per KR protocol | 12 (≥2 contiguous) |
| ST depression / T inversion without STE | 🟡 | chest pain ongoing, haemodynamic instability, ST-depression pattern ≥6 leads + aVR elevation | Needs troponin; not "ruled out" | 12 |
| VT (sustained) | 🔴 | always | | 1–12 |
| VF / asystole / chaotic rhythm | 🔴 | always (cardiac arrest) | Outside normal use case | 1 |
| Complete AV block | 🔴 | always | Pacing required | 1 |
| AF/flutter, rapid (>110–120) or symptomatic | 🟡 | syncope, shock, acute HF, chest pain, wide QRS | | 1 |
| AF/flutter, rate-controlled, asymptomatic, new finding | 🟡 (new) / 🟢 (known) | any red flag | Anticoagulation decision is out of feldsher scope | 1 |
| Sinus tachycardia | 🟡 (>130, or symptoms) / 🟢 | shock, chest pain | Treat the cause | 1 |
| Sinus bradycardia | 🟢 (asymptomatic) / 🟡 | syncope, SBP <90, HR <40 | Check drugs | 1 |
| LBBB | 🟡 | any ACS-like symptoms → treat as possible OMI (🔴) | Old vs new unknown without prior ECG | 12 |
| RBBB | 🟢 | ACS-like symptoms → 🟡/🔴 | | 12 |
| Low quality / not interpretable / unsupported layout | ⚪ "No result — repeat or get 12-lead/telemedicine" | — | Never output green on a poor image | — |

Design rule (recommendation): the output is "highest urgency among findings", and unknown/low-confidence → never green.

## 4. Kyrgyz MoH clinical protocols and pre-hospital context

| Topic | Document | Status |
|---|---|---|
| STEMI reperfusion | "Реваскуляризация миокарда при ОКС с подъемом сегмента ST", Annex 7 to MoH KR order No. 1342, 25.12.2024, NCCT named after M. Mirrakhimov — [MedElement](https://diseases.medelement.com/disease/%D1%80%D0%B5%D0%B2%D0%B0%D1%81%D0%BA%D1%83%D0%BB%D1%8F%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D0%BC%D0%B8%D0%BE%D0%BA%D0%B0%D1%80%D0%B4%D0%B0-%D0%BF%D1%80%D0%B8-%D0%BE%D1%81%D1%82%D1%80%D0%BE%D0%BC-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D0%BE%D0%BC-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC%D0%B5-%D1%81-%D0%BF%D0%BE%D0%B4%D1%8A%D0%B5%D0%BC%D0%BE%D0%BC-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BA%D0%BF-%D0%BA%D1%80-2024/18614) | Verified (opened; long document; read parts only) |
| NSTE-ACS | "ОКС без подъема ST", 2022, NCCT — [nccim.kg PDF](https://nccim.kg/wp-content/uploads/2023/06/%D0%9F%D1%80%D0%BE%D1%82%D0%BE%D0%BA%D0%BE%D0%BB-%D0%9E%D0%9A%D0%A1%D0%91%D0%9F%D0%A1%D0%A2-2022.pdf); [MedElement](https://diseases.medelement.com/disease/%D0%BE%D1%81%D1%82%D1%80%D1%8B%D0%B9-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D1%8B%D0%B9-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC-%D0%B1%D0%B5%D0%B7-%D1%8D%D0%BB%D0%B5%D0%B2%D0%B0%D1%86%D0%B8%D0%B8-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BD%D0%B0-%D1%8D%D0%BA%D0%B3-%D0%BA%D0%BF-%D0%BA%D0%B8%D1%80%D0%B3%D0%B8%D0%B7%D0%B8%D1%8F-2023/17749) | Partly verified (search result only) |
| Order No. 927, 23.12.2016 (CVD guidelines, older) | [prg.kz](https://prg.kz/Document/?doc_id=38784265) | Partly verified; may be superseded |
| AF/flutter (I48) | "Диагностика и лечение фибрилляции предсердий", order No. 626, 11.06.2024 (review 2029) — [MedElement](https://diseases.medelement.com/disease/%D1%84%D0%B8%D0%B1%D1%80%D0%B8%D0%BB%D0%BB%D1%8F%D1%86%D0%B8%D1%8F-%D0%BF%D1%80%D0%B5%D0%B4%D1%81%D0%B5%D1%80%D0%B4%D0%B8%D0%B9-%D0%B4%D0%B8%D0%B0%D0%B3%D0%BD%D0%BE%D1%81%D1%82%D0%B8%D0%BA%D0%B0-%D0%B8-%D0%BB%D0%B5%D1%87%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BF-%D0%BA%D1%8B%D1%80%D0%B3%D1%8B%D0%B7%D1%81%D1%82%D0%B0%D0%BD-2024/18064) | Partly verified (search result only; the order number/date come from a tool summary) |
| AV block (I44), VT (I47.2) | No dedicated protocol found; ICD-10 codes only ([cez.med.kg ICD](https://cez.med.kg/wp-content/uploads/mkb/mkb10_3_1.pdf)) | Not found — to be checked in the MoH registry |
| Other portals | [cez.med.kg](https://cez.med.kg/) (Republican Centre of e-Health, MoH orders and guidelines); [nccim.kg](https://nccim.kg/) | Entry points to check |

**Pre-hospital/rural context**
- Editorial by NCCT physicians (2022): cath lab only in three cities, no angiography in four of seven regions, so thrombolysis is the main STEMI approach; pharmaco-invasive strategy occasionally; patients from regions referred to PCI centre ([Heart, Vessels and Transplantation 2022](https://www.hvt-journal.com/articles/art317)). Verified, but a single editorial and 4 years old.
- WHO/UN service framework and roadmap (2018) for heart attack/stroke in Kyrgyzstan: identifies feldshers as the only provider in remote areas, calls for training and telemedicine support for ECG interpretation, and notes limited access to thrombolytics at rayon level ([UN roadmap PDF (RU)](https://kyrgyzstan.un.org/sites/default/files/2019-12/A%20service%20framework%20and%20roadmap%20for%20the%20development%20of%20care%20systems%20for%20heart%20attack%20and%20stroke%20in%20Kyrgyzstan%20%282018%29_RUS.pdf); [WHO IRIS](https://iris.who.int/server/api/core/bitstreams/fb934304-5308-4436-b5d6-6dbc8eb52a8d/content)). Partly verified (excerpts). Possibly outdated (2018).
- NCCT "Emergency cardiology" programme: planned cath labs (Talas, Balykchy, Naryn) and a district-level digital CVD detection system with remote consultation by NCCT ([Kaktus.media](https://kaktus.media/doc/510355_v_nckit_rasskazali_o_pervyh_rezyltatah_realizacii_programmy_ekstrennaia_kardiologiia.html); [24.kg](https://24.kg/en/article/341298)). Partly verified (search excerpts; news). **This is a potential integration/competition point** for the app.
- Whether FAPs hold thrombolytics or aspirin/heparin kits: **not found.**

## 5. Pitfalls of automated ECG interpretation

| Finding | Number / claim | Source | Label |
|---|---|---|---|
| STEMI criteria vs OMI reading (808 pts) | sensitivity 41% vs 86%; specificity 94% vs 91% | [PMC8065286](https://pmc.ncbi.nlm.nih.gov/articles/PMC8065286/) | Partly verified |
| STEMI criteria sensitivity for acute coronary occlusion | pooled 43.6% (3 studies) per cited review | [JACC: Advances 2024](https://www.jacc.org/doi/10.1016/j.jacadv.2024.101314) | Partly verified |
| ESC STEMI criteria met in initial ECG | 36.9% of initial ECGs; 46.6% of OMI patients; OMI 30-day mortality 23.6% vs 19.4% in STEMI | [ESC ACVC abstract 2025/26](https://academic.oup.com/ehjacc/article-pdf/doi/10.1093/ehjacc/zuag046.139/68275708/zuag046.139.pdf) | Partly verified (conference abstract, preliminary) |
| Machine "acute MI" statement vs confirmed STEMI (2400 pts) | 62.9% sens / 95.6% spec; any ACS 30.7% sens | [PMC8664995](https://pmc.ncbi.nlm.nih.gov/articles/PMC8664995/) | Partly verified |
| Prehospital computer-assisted STEMI interpretation (meta-analysis) | pooled 85.4% sens / 95.4% spec (paramedics 95.5% / 95.8%) | [Circ Rep 2022](https://doi.org/10.1253/circrep.cr-22-0002) | Partly verified |
| AF over-reading of machine output | of 1057 AF-related ECGs, 79.5% true AF (rest over- or mis-interpreted) | [Clin Cardiol 2019, PMC6652532](https://pmc.ncbi.nlm.nih.gov/articles/PMC6652532/) | Partly verified |
| Over-reliance on machine AF label | 2298 machine-AF ECGs re-read; misdiagnosis led to inappropriate treatment | [Bogun, Am J Med 2004](https://www.amjmed.com/article/S0002-9343(04)00478-4/fulltext) | Partly verified; **old (2004)** |
| AI OMI model vs physicians for cath-lab decisions | Queen of Hearts (PMcardio) compared with physicians on STEMI-equivalent/mimic ECGs | [PubMed 40763602](https://pubmed.ncbi.nlm.nih.gov/40763602/) | Partly verified (abstract only, numbers not read) |
| Photo digitisation | PhysioNet Challenge 2024 teams report generalisation failures on unseen layouts/real images; channel identity wrongly assigned on unsupported layouts | [CinC 2024-262](https://www.cinc.org/archives/2024/pdf/CinC2024-262.pdf), [Challenge paper](https://moody-challenge.physionet.org/2024/papers/cinc_paper.pdf) | Partly verified |

Interpretation (researcher inference): (a) the "no false negative paradox" of the STEMI paradigm (JACC: Advances) means published STEMI-label accuracy overstates safety; (b) a model trained on STEMI labels inherits the blind spot for OMI; (c) users tend to follow machine output, so a green result is more dangerous than a missing result; (d) imaging pipeline errors (wrong lead assignment, wrong scale) compound classifier errors.

## Implications for ECG-AI KG

1. **Do not define the MVP target as "STEMI"; define it as "possible acute coronary occlusion / ischaemia"**, labelled by OMI-style ground truth if data permit (e.g. angiography-linked datasets, to be found in research 03). Keep STEMI criteria as a transparent, rule-based safety net.
2. **Two output tiers:** rhythm findings (single lead is enough: AF/flutter, VT/VF, complete AV block, sinus tachy/brady) and morphology findings (need ≥8–12 properly identified leads: STEMI/equivalents, BBB). If the photo yields only one lead, the app must say so and not output ST/ BBB claims.
3. **Digitiser must output metadata and refuse gracefully:** layout, detected paper speed/gain/calibration pulse, per-lead quality, pixel-to-mm scale. Reject unsupported layouts instead of guessing.
4. **Never output green on low confidence.** Add an explicit "cannot interpret" state; combine model output with 2–4 symptom/vital questions to push borderline cases up.
5. **Prioritise sensitivity for red classes** and report per-class sensitivity/false-negative rates, not accuracy; evaluate against cardiologist labels with OMI endpoints.
6. **Action steps:** build a content table keyed to the KR STEMI (order 1342/2024), NSTE-ACS (2022) and AF (order 626/2024) protocols, with a citation next to each step; for VT/VF/AV block use ERC 2021 / ESC 2021 until a KR source is found, flagged "pending cardiologist review".
7. **Wording:** "ECG pattern suggestive of…", never "diagnosis"; the 4th UDMI requires troponin/clinical context.
8. **Check the NCCT telemedicine programme** as a partner/competitor and as the natural destination for the "send to specialist" action.
9. Do not report QTc or QT-related risk in MVP.

## Open questions

| # | Question | Who |
|---|---|---|
| 1 | Which ECG machines/layouts/paper speed/gain are in FAPs/CFMs (feeds layout support) | Author / research 02 |
| 2 | Do FAPs/CFMs stock thrombolytics, aspirin, heparin, atropine, defibrillator/AED? What is the formal referral route and transport time? | Author (local knowledge), then cardiologist |
| 3 | Is there a KR protocol (or Ministry order on emergency care) for AV block, VT/VF, supraventricular tachycardia, and prehospital emergency care by feldshers? I found none; check MoH order registry/cez.med.kg | Author |
| 4 | Contents of the KR AF and NSTE-ACS protocols in detail (not opened, only search summaries) | Me, Phase 2 |
| 5 | Final urgency thresholds (HR cut-offs, which findings default to red, BBB handling) | Cardiologist after POC |
| 6 | Clinical wording of action steps in Russian and Kyrgyz (terminology) | Cardiologist / Kyrgyz medical translator |
| 7 | Verify ESC 2023 thresholds and equivalents against the official ESC text (I used secondary mirrors/summaries) | Me, Phase 2 |
| 8 | Which AI-OMI products/regulation exist (Queen of Hearts/PMcardio) and their numbers | Me (research 03/04) |

## Sources (accessed 2026-10-29)

- Kept (primary/official):
  - KR STEMI reperfusion protocol, order 1342/2024 (MedElement): https://diseases.medelement.com/disease/%D1%80%D0%B5%D0%B2%D0%B0%D1%81%D0%BA%D1%83%D0%BB%D1%8F%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D0%BC%D0%B8%D0%BE%D0%BA%D0%B0%D1%80%D0%B4%D0%B0-%D0%BF%D1%80%D0%B8-%D0%BE%D1%81%D1%82%D1%80%D0%BE%D0%BC-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D0%BE%D0%BC-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC%D0%B5-%D1%81-%D0%BF%D0%BE%D0%B4%D1%8A%D0%B5%D0%BC%D0%BE%D0%BC-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BA%D0%BF-%D0%BA%D1%80-2024/18614
  - KR NSTE-ACS protocol 2022 (nccim.kg PDF): https://nccim.kg/wp-content/uploads/2023/06/%D0%9F%D1%80%D0%BE%D1%82%D0%BE%D0%BA%D0%BE%D0%BB-%D0%9E%D0%9A%D0%A1%D0%91%D0%9F%D0%A1%D0%A2-2022.pdf
  - KR AF guideline 2024 (MedElement): see table above
  - 2023 ESC ACS: https://academic.oup.com/ehjacc/article/13/1/55/7280662 ; 2024 ESC AF: https://doi.org/10.1093/eurheartj/ehae176 ; 2021 ESC pacing: https://academic.oup.com/europace/article/24/1/71/6358627 ; ERC 2021 ALS: https://www.resuscitation.eu/assets/guidelines/European-Resuscitation-Council-Guidelines-2021-Ad.pdf
  - AHA/ACCF/HRS ECG standardisation Part I (https://www.jacc.org/doi/10.1016/j.jacc.2007.01.024) and Part IV (https://www.jacc.org/doi/10.1016/j.jacc.2008.12.014)
  - Heart, Vessels and Transplantation editorial on KR revascularisation: https://www.hvt-journal.com/articles/art317
  - UN/WHO KR roadmap: https://kyrgyzstan.un.org/sites/default/files/2019-12/A%20service%20framework%20and%20roadmap%20for%20the%20development%20of%20care%20systems%20for%20heart%20attack%20and%20stroke%20in%20Kyrgyzstan%20%282018%29_RUS.pdf
  - OMI/automation studies: PMC8065286, PMC8664995, PMC6652532, JACC Adv 2024 (links in section 5); PhysioNet 2024 digitisation papers
- Deprioritised: studylib.net and ecgweekly.com mirrors of ESC text (unofficial copies; use only until the official PDF is checked); Russian federal/regional pre-hospital documents (other country; reference only); Bogun 2004 (old); news items (Kaktus, 24.kg: weak evidence, context only).
- Method note: the search tool returned AI-generated summaries for several queries; items taken from such summaries are marked Partly verified at best. Numbers in section 5 come from search excerpts of the cited papers and must be re-checked against the full papers before they are quoted in any publication.
