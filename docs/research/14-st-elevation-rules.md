# Research 14 - Rule-based ST-elevation / ischaemia check on 12 digitised leads, and open pretrained MI classifiers

Date accessed for all sources: 2026-11-04. Status: draft for the developer. **Nothing here is clinical guidance until a cardiologist reviews it** (AGENTS.md). The app is decision support, not a diagnosis.

Labels used below:
- **Verified** = I read the quoted text on the cited page in this session (via a page fetch).
- **Partly verified** = the value comes from a search-result summary or a secondary page; the primary text was not read.
- **Unverified** = from memory/textbook, or the source could not be opened.
- **Researcher inference** = my own reasoning, not a source claim.
- **PENDING_REVIEW** = a proposed value that needs the cardiologist (same meaning as in `ml/ecg_rules/thresholds.py`).

## Summary

1. **Feasible, but only as a conservative red/amber escalator.** The official STEMI criterion is a J-point measurement against a 1 mm (0.1 mV) step in two contiguous leads. A 1 mm step is the same size as our digitiser's likely amplitude error on a clean synthetic page (about 0.5 mm RMS) and well below its error on a bad photo (more than 2 mm RMS at about -1 dB SNR). So the rule must (a) verify the calibration pulse, (b) estimate its own measurement error per lead, (c) demand agreement across beats and across both contiguous leads, and (d) abstain (never go green) when the error is too large.
2. **A STEMI rule is a safety net, not an OMI detector.** STEMI criteria detect only about 41 % of occlusion MI (Verified, PMC8065286). A rule that fires is informative; a rule that does not fire is not reassurance. The result must never be called "normal" (spec v2 C-31).
3. **The Kyrgyz protocols give no millimetre thresholds** (research 10: only "persistent ST elevation >20 min" and "ST depression >=0.05 mV in two or more contiguous leads" for NSTE-ACS). The numeric thresholds therefore come from the Fourth Universal Definition (2018) and ESC 2023, with the cardiologist to confirm.
4. **Bundle branch block (LBBB), paced rhythm, LVH, posterior and right-ventricular MI, de Winter and Wellens patterns cannot be called reliably from our digitised data.** For these the proposal is to flag "ST analysis not valid" and escalate (AMBER, RED with symptoms) rather than interpret.
5. **No open permissive pretrained classifier was found that is verified for MI/ischaemia on digitised photos.** The best candidates (ECGFounder, ECG-FM; both MIT code and, per their pages, MIT weights) have open licence questions on training data and have never been tested on photos (section 6).

---

## 1. Official criteria and what a digitised 10 s trace can measure

### 1.1 Fourth Universal Definition of MI (Thygesen et al., Eur Heart J 2019;40:237-269, ESC/ACC/AHA/WHF)

Source: [doi 10.1093/eurheartj/ehy462](https://academic.oup.com/eurheartj/article/40/3/237/5079081) (full text fetched, ECG section read; Table 2 itself is an image, so the table cells were reconstructed from the surrounding text plus secondary copies).

Quoted text (Verified):
- "New, or presumed new, J-point elevation >= 1 mm (1 mm = 0.1 mV) is required in all leads other than V2 and V3." (the page text writes the symbol as ">=").
- "The criteria in Table 2 require that the ST shift be present in two or more contiguous leads."
- "In healthy men under age 40, J-point elevation can be as much as 2.5 mm in leads V2 or V3." "Sex differences require different cut-off points for women."
- Worked example: ">= 2 mm of ST-elevation in lead V2 and >= 1 mm in lead V1 would meet the criteria" (man >= 40 years): each lead is judged against its own threshold.
- ST elevation of 1 to <2 mm "seen only in leads V2-V3 in men (or < 1.5 mm in women), may represent a normal finding".
- Posterior leads: "A cut-off point of 0.5 mm ST-elevation is recommended in leads V7-V9" (men <40 years: a higher cut-off is used).
- "Isolated ST-segment depression >= 0.5 mm in leads V1-V3 may indicate left circumflex occlusion."
- "ST-elevation in lead aVR > 1 mm may accompany anterior or inferior STEMI."
- "ST-segment depression >= 1 mm in six leads, which may be associated with ST-segment elevation in leads aVR or lead V1 and haemodynamic compromise, is suggestive evidence of multivessel disease or left main disease."
- LBBB: "ST-segment elevation >= 1 mm concordant with the QRS complex in any lead may be an indicator of acute myocardial ischaemia."

Values for Table 2 (V2-V3 thresholds): the 2018 text above confirms the structure, but the numeric cells (>=2.5 mm men <40 y, >=2 mm men >=40 y, >=1.5 mm women) were verified in the ESC 2023 guideline (next section), which quotes the same values. Partly verified for the 2018 table itself.

ST depression / T inversion criterion (Partly verified; secondary copies of Table 2 such as a clinical-trial protocol and a conference slide deck): "New horizontal or downsloping ST-depression >= 0.5 mm in two contiguous leads and/or T inversion > 1 mm in two contiguous leads with prominent R wave or R/S ratio > 1."

Measurement note (Verified): the Universal Definition specifies **J-point** elevation. Measurement is "as compared with the earlier electrocardiogram" where available; the criteria are for "new" findings, which the app cannot establish without a prior ECG. Absence of LVH and LBBB is a precondition.

### 1.2 ESC 2023 ACS guideline (Byrne et al., Eur Heart J 2023;44:3720-3826)

Source: [doi 10.1093/eurheartj/ehad191](https://academic.oup.com/eurheartj/article/44/38/3720/7243210) (full text fetched; section 3.2 read; recommendation tables are images, so class/level labels were not read).

Quoted text (Verified):
- "New ST elevation at the J-point in at least two contiguous leads", with V2-V3 "≥2.5 mm in men <40 years, ≥2 mm in men ≥40 years, or ≥1.5 mm in women regardless of age in leads V2-V3" and/or "≥1 mm in the other leads" (in the absence of LV hypertrophy; LBBB also excluded).
- Right-sided leads: record V3R and V4R in suspected inferior STEMI; "ST-segment elevation in V3R and V4R is highly suggestive of ongoing RV ischaemia."
- Posterior leads: record V7-V9 when posterior STEMI is suspected; "ST-segment elevation in V7-V9 are highly suggestive of posterior coronary artery occlusion." ST depression in V1-V3, especially with a positive terminal T wave, also points to posterior occlusion.
- Multivessel/left main: "ST depression ≥1 mm in ≥6 surface leads (inferolateral ST depression), coupled with ST-segment elevation in aVR and/or V1" suggests multivessel ischaemia or left main obstruction.
- Bundle branch block/paced: "the presence of LBBB, right bundle branch block (RBBB), or a paced rhythm precludes an accurate assessment" of ST elevation; with high clinical suspicion of ischaemia these patients are managed like patients with clear ST elevation.
- Wellens: "prominent negative T waves [Wellens' sign, related to severe proximal left anterior descending artery stenosis]" are listed among NSTE-ACS ECG abnormalities.
- **de Winter pattern: not present in the text I read** (the section I fetched did not mention it). Treat the de Winter criteria below as secondary-source only.
- Not read: the exact class/level of the "12-lead ECG within 10 min of first medical contact" recommendation (the KR NSTE-ACS protocol carries it as class I, research 10).

### 1.3 Kyrgyz protocols (from research 10; Verified there)

- STEMI revascularisation (MoH KR order 1342, 25.12.2024): only the criterion "Пациенты с острой болью в грудной клетке и сохраняющимся >20 мин подъемом сегмента ST" (acute chest pain and persistent ST elevation >20 min). **No millimetre thresholds and no equivalents list.**
- NSTE-ACS (2022, NCCT): "Депрессия сегмента ST ≥0,05мВ в двух или более смежных отведениях ... предполагает ОКСБЭST" (ST depression >=0.05 mV in two or more contiguous leads suggests NSTE-ACS). Isolated T inversion is "not associated with an adverse prognosis". 12-lead ECG within 10 min of first medical contact.
- Consequence: the KR text contains one measurable number, **0.05 mV ST depression in two contiguous leads**. That is half of the 1 mm elevation threshold and is below what our digitiser can resolve reliably (section 4).

### 1.4 Measurability table (digitised 10 s, 12 leads, 3x4 page + rhythm strip)

Assumes the digitiser delivers 12 leads at 500 Hz with correct lead identity, a verified 10 mm/mV gain and correct time base. "Hard" = needs a capability we do not have today.

| Pattern | Official criterion | Measurable from our trace? | Comment |
|---|---|---|---|
| STE, V2-V3 | Sex/age thresholds 1.5/2/2.5 mm, J point, 2 contiguous leads | Yes, if sex and age are known and J point and baseline are found | Sex/age must be entered in the app. Mimic risk (early repolarisation, LVH) is highest here. |
| STE, other leads | >=1 mm, J point, 2 contiguous leads | Yes, same conditions | Inferior and lateral groups. |
| Reciprocal ST depression | Not a criterion (supporting feature) | Yes | Used only to raise confidence (Researcher inference). |
| ST depression V1-V3 (posterior) | >=0.5 mm V1-V3, positive terminal T; confirm V7-V9 >=0.5 mm | V1-V3 depression: yes (noisy at 0.5 mm). V7-V9: **No**, not on a standard page. T-wave polarity: partly | Posterior leads are never printed on standard 12-lead pages. |
| RV infarction | STE in V3R/V4R | **No** (leads absent). Inferior STE with STE in V1 is a hint only (Unverified, textbook) | Matters for drug advice: nitrates are cautioned in RV infarction (Unverified, textbook; protocol text in research 10 lists nitroglycerin for all NSTE-ACS). Cardiologist to review. |
| LBBB / paced, Sgarbossa and Smith-modified | See 1.5 | **Hard**: needs reliable QRS width (our VT case in README showed QRS width is unreliable), QRS polarity per lead, S-wave depth | Safer to detect "wide QRS" and escalate than to apply the score. |
| de Winter | Upsloping ST depression at J 1-3 mm V1-V6, tall symmetric T, aVR elevation 0.5-2 mm (secondary sources) | Partly (J-point depression yes; T symmetry/height weakly) | Rare (1.6-3.4 % of anterior MI per secondary source). Not in v1. |
| Wellens | Deep/biphasic T in V2-V3, ST <1 mm, no Q waves, pain-free | Partly (T depth yes; "pain-free" is a clinical fact; LVH mimics it) | Not in v1. Secondary source only (LITFL). |
| aVR elevation + diffuse depression | >=1 mm depression in >=6 leads + STE aVR and/or V1 | Yes, counts of leads | Meaningful only with haemodynamic compromise (ESC wording). Needs symptom/vitals input. |
| Hyperacute T, loss of R, Q waves | OMI literature | Weak | Not proposed. |

### 1.5 LBBB / paced rhythm: Sgarbossa and Smith-modified Sgarbossa

- Original Sgarbossa (GUSTO-1, NEJM 1996), Partly verified from secondary pages: concordant ST elevation >= 1 mm in a lead with mostly positive QRS (5 points); concordant ST depression >= 1 mm in V1-V3 (3 points); excessively discordant ST elevation >= 5 mm in a lead with mostly negative QRS (2 points); score >= 3 is positive. Specific but not sensitive (a secondary page cites sensitivity 36 % for score >=3 in the original report; a pooled analysis by Tabas et al. 2008 is cited as 20 % sensitivity and 98 % specificity: Partly verified).
- Smith-modified (Ann Emerg Med 2012), Partly verified: the 5 mm rule is replaced by excessively discordant ST elevation as an **ST-elevation to S-wave ratio** (cut-off -0.25, i.e. discordant STE >= 25 % of the preceding S-wave depth, with at least 1 mm discordant deviation); positive if any criterion is met. Reported performance in the derivation (33 STEMI-equivalent ECGs vs 129 controls) was about 91 % sensitivity and 90 % specificity versus about 52 % for the original (Partly verified); later validation 80 % sensitivity / 99 % specificity (secondary calculator page, Unverified). Secondary sources disagree on exact wording, so read the original before coding.
- ESC 2023 (Verified above): LBBB/paced precludes accurate assessment; treat as STEMI when clinical suspicion is high.
- Measurable? Concordance needs per-lead QRS polarity and a J-point shift of 1 mm on a wide QRS with a sloped ST; ST/S ratio needs the S-wave nadir. All are feasible in principle on a clean trace, but the wide-QRS detection and ST/S in digitised photos are untested. **Proposal: do not implement Sgarbossa in v1; implement "wide QRS present" as an escalation only (section 5).**

### 1.6 OMI versus STEMI paradigm, briefly

- Blinded reading with predefined OMI ECG findings versus STEMI criteria in 808 patients with suspected ACS: STEMI criteria sensitivity 41 % / specificity 94 %; OMI findings 86 % / 91 % (second interpreter on a 250-patient subset: 36 %/91 % vs 80 %/92 %). Verified: [PMC8065286](https://pmc.ncbi.nlm.nih.gov/articles/PMC8065286/) (study text; STEMI criteria "defined according to the fourth universal definition of MI", measured in millimetres from QRS onset to the J point).
- Pooled STEMI-criteria sensitivity for acute coronary occlusion of 43.6 % (3 studies) in a 2024 JACC: Advances review (Partly verified, via research 01).
- The OMI proposal is advocated by Meyers, Weingart and Smith (first on a blog, 2018) and reviewed in a 2021 paper in the Anatolian Journal of Cardiology ([AJC-89304](https://anatoljcardiol.com/article/AJC-89304/pdf), Partly verified). OMI findings are chiefly **T-wave and subtle ST morphology** (hyperacute T waves, de Winter, reciprocal changes), which are exactly the features that digitisation degrades. Evidence is largely single-group and the guidelines still use STEMI/NSTE-ACS (ESC 2023).
- Researcher inference: a transparent STEMI rule gives a floor of about 40 % sensitivity for occlusion; the rest must come from a learned model or from the clinician, and the app must say so.

---

## 2. "Contiguous leads" and lead groups

- Guideline wording: "two or more contiguous leads" (UDMI and ESC 2023, Verified). The 2018 text I read did not itself define the groups.
- Standard grouping used in research 01 (textbook, Unverified): inferior II, III, aVF; lateral I, aVL, V5, V6; anterior/septal V1-V4. Territory shorthand: septal V1-V2, anterior V3-V4, lateral V5-V6 (+ I, aVL), inferior II, III, aVF.
- The 2009 AHA/ACCF/HRS Part VI statement (Wagner et al., Circulation 2009; [PMID 19281933](https://pubmed.ncbi.nlm.nih.gov/19281933/)) covers ST thresholds and conduction disturbances. I could not open its full text (HTTP 403), so its lead-contiguity definition and J-point/baseline text are **Unverified**.
- **Proposed contiguity graph (Researcher inference, PENDING_REVIEW):**
  - Chest chain: V1 - V2 - V3 - V4 - V5 - V6 (adjacent pairs are contiguous; the UDMI example V1+V2 confirms adjacent chest leads count, each against its own threshold).
  - Limb chain (Cabrera order): aVL - I - (-aVR) - II - aVF - III. Adjacent pairs are contiguous. aVR is **excluded** from the STE pair rule (it has its own rule).
  - Inferior set {II, III, aVF}: any two. Lateral set {I, aVL} plus {V5, V6}: any two within the chain.
  - Cross-chain contiguity (for example V4 with V5, or aVL with V2/V3 for high lateral/anterolateral) is allowed only along the chest chain; limb-with-chest pairs are not counted in v1 (conservative; cardiologist to decide).
  - Two leads with different thresholds (for example V2 2 mm, V1 1 mm) each need to meet their own threshold (UDMI example).

---

## 3. How automated algorithms measure ST, and their accuracy and pitfalls

### 3.1 Measurement conventions

- **Reference point:** the J point (end of QRS / start of ST). UDMI and the Glasgow program documentation use the J point; the vendor document says measuring later than the J point can overestimate ST elevation (Stryker/Glasgow overview, a manufacturer document, Partly verified: [PDF](https://Stryker.com/content/dam/stryker/ems/resources/clinical-information/glasgow_program_clinical_overview.pdf)).
- **Baseline:** conventionally the PR segment (or TP segment) of the same median beat; the isoelectric reference is subtracted. I could not verify the exact baseline rule for 12SL, DXL or Glasgow (the Glasgow baseline approach was "Not found"). Treat as Unverified.
- **J+60 / J+80 ms:** common in exercise-ECG practice (Unverified here). A Leiden study measuring amplitudes every 10 ms from J-20 to J+80 ms reported the best STEMI-detection accuracy (93.6 %) for the most liberal algorithm at **J+10 ms**, concluding that detection close to the J point is optimal (Partly verified, search summary of [Leiden thesis](https://scholarlypublications.universiteitleiden.nl/access/item%3A3003615/download)). So a J-point measure is consistent with both the guideline and the evidence; a later point (J+40/J+60) is a useful robustness check, not the primary measure.
- Algorithms work on a **median beat** per lead (noise averaged over beats) after baseline-wander removal; our pipeline has a 2.5 s window per lead in a 3x4 layout (about 2-4 beats at 60-100 bpm), so the averaging benefit is smaller than in a 10 s simultaneous recording (Researcher inference).

### 3.2 Published accuracy for STEMI statements (all Partly verified: search summaries, primary text not read; vendors and studies differ in population, so numbers are not comparable across rows)

| Program / study | Sensitivity | Specificity | Source |
|---|---|---|---|
| Glasgow program, 44,611 prehospital ECGs, Los Angeles (LIFEPAK 15) | 92.8 % | 98.7 % | Stryker clinical overview (manufacturer document) |
| Glasgow vs LIFEPAK 12 programs, 1,000 consecutive prehospital ECGs, Denmark | 78 % (both) | 94 % vs 91 % | [Glasgow eprints](https://eprints.gla.ac.uk/49323) |
| GE Marquette 12SL, prehospital (paramedic, real time) | 69.2 % | 98.9 % | Cambridge CJEM article ([link](https://www.cambridge.org/core/journals/canadian-journal-of-emergency-medicine/article/computerized-interpretation-of-the-prehospital-electrocardiogram-predictive-value-for-st-segment-elevation-myocardial-infarction-and-impact-on-onscene-time/3343435B5954B6CB87AA383F30525B50)) |
| Philips DXL "acute MI/ischaemia" statement vs confirmed STEMI | 62.9 % | 95.6 % | [PMC8664995](https://pmc.ncbi.nlm.nih.gov/articles/PMC8664995/) (via research 01) |
| Prehospital computer-assisted STEMI interpretation, meta-analysis | 85.4 % | 95.4 % | [Circ Rep 2022](https://doi.org/10.1253/circrep.cr-22-0002) (via research 01) |

Take-away (Researcher inference): mature, tuned algorithms working on native digital signals reach roughly 60-90 % sensitivity and 90-99 % specificity for STEMI. A rule on photo-derived signals will not do better than that, and probably worse.

### 3.3 Known pitfalls

- **False positives** (cath-lab activation without culprit: 14 % of 1,345 suspected-STEMI patients in a single registry, JAMA 2007 [PMID 18165668](https://pubmed.ncbi.nlm.nih.gov/18165668/), Partly verified; another vendor page says 25-40 %, Unverified). Common ECG mimics (listed by a secondary page, Unverified): early repolarisation, LVH with strain, LBBB or paced rhythm, pericarditis/myocarditis, hyperkalaemia, Brugada pattern, tachyarrhythmia, artefact. The Glasgow overview itself says most false positives were artefact and non-ischaemic ST elevation (Partly verified).
- **False negatives:** posterior MI (no posterior leads), isolated right-sided/RV involvement, LBBB/paced, OMI without ST elevation (de Winter, hyperacute T), small-amplitude changes. See 1.6.
- **Baseline wander** on a paper tracing and **curl/perspective** on a photo distort ST level directly; they are the main digitisation risk (section 4).
- **Sex/age dependence** in V2-V3 and the "new" criterion require a prior ECG that the app does not have.

---

## 4. Digitisation impact on ST measurement

### 4.1 Accuracy needed

- 1 mm = 0.1 mV at the standard 10 mm/mV gain (UDMI, Verified). The criterion margin is therefore 0.1 mV for most leads, 0.15 mV for women in V2-V3, and 0.05 mV for the KR depression criterion and the posterior criterion (0.5 mm).
- Time axis: 25 mm/s gives 40 ms per mm. Mislocating the J point by 40 ms (one small box) on a rising or falling ST can already change the reading by about 1 mm.
- Gain: pages are printed at 5, 10 or 20 mm/mV. A misread gain scales every ST value by 2x. A calibration pulse (typically 1 mV, 10 mm) must be detected, otherwise the ST rule must abstain (Researcher inference).

### 4.2 Our measured digitiser error (from `ml/digitise/README.md`, 2026-11-04)

- Synthetic clean ECG-Image-Kit pages from PTB-XL: SNR **median 12.5 dB, 10th percentile 5.3 dB**, minimum -0.4 dB (48 leads). Real web images: up to extraction failures. PhysioNet 2024 Challenge phone photos: about **-1 dB** (figure supplied by the project lead; not re-measured here).
- The SNR is defined against the signal power, so it includes time misalignment and amplitude scaling, not only noise.

### 4.3 What that implies in mV (Researcher inference)

Noise RMS ratio = 10^(-SNR/20) of the signal RMS. Assuming a typical 12-lead ECG signal RMS of about 0.2 mV (assumption; leads vary roughly 0.1-0.4 mV):

| SNR | Noise / signal RMS | Approx. error RMS (signal RMS 0.2 mV) | In mm at 10 mm/mV |
|---|---|---|---|
| 12.5 dB (median, clean synthetic) | 0.24 | 0.05 mV | 0.5 mm |
| 5.3 dB (10th percentile, clean synthetic) | 0.54 | 0.11 mV | 1.1 mm |
| -0.4 dB (worst clean lead) | 1.05 | 0.21 mV | 2.1 mm |
| -1 dB (phone photos, Challenge) | 1.12 | 0.22 mV | 2.2 mm |

- Even the median clean case has an error equal to half the 1 mm criterion; the worst cases exceed 2 mm, i.e. the full threshold twice over. Median-beat averaging (several beats) can reduce uncorrelated noise (about 1/sqrt(N) if independent) but not systematic errors (baseline offset drift, curl, gain error, line-thickness bias). Pixel scale also limits resolution: on a 2200 px wide page (about 250-280 mm), 1 mm is about 8 px, so 0.5 mm is 4 px and trace line widths of 2-4 px matter; at the 1200 px native web size 1 mm is about 4 px (arithmetic from the README image sizes; page width assumption).
- Absolute DC offset does not matter (ST is measured relative to the same beat's PR/TP segment), so the key error is the **local** error between the PR baseline and the J point, which for a smooth line is smaller than the global SNR suggests. This is not yet measured.

### 4.4 Design consequences (Researcher inference, PENDING_REVIEW)

1. **Estimate the measurement uncertainty per lead from the data** instead of assuming it:
   - beat-to-beat scatter (MAD of the ST value across beats);
   - Einthoven check within a time column: I + III = II sample by sample, and aVR + aVL + aVF = 0 (the 3x4 layout prints simultaneous leads per column), with the residual giving an error bound for limb leads;
   - lead II is printed twice (column segment and rhythm strip): compare the ST values from both copies.
2. **Require agreement across both leads of the contiguous pair, across beats (at least 3 beats, or at least 2 beats if only 2.5 s is available, agreeing in sign and size), and across two time offsets (J point and J+40 ms, both above threshold).**
3. **A confidence margin:** the "RED" test uses the measured value at or above the guideline threshold *and* an uncertainty u of at most 0.5 mm; "AMBER" is allowed down to a defined fraction of the threshold when u is larger. If u is above 1.0 mm for a lead, that lead is "unmeasurable" and counts as missing.
4. **Evaluate the whole chain** on PTB-XL records rendered to pages and photographed (ground truth available), recording false-negative and false-positive rates for the ST rule on true signals and on digitised signals (`docs/eval/PROTOCOL.md`). PTB-XL has no STEMI/OMI labels (research 01), so use PTB-XL infarction statements only as a proxy and say so.

---

## 5. Proposed rule spec (pseudocode-level; thresholds are drafts)

Principles: the ST check can only **raise** urgency (to AMBER/RED) or **abstain**; it never lowers a rhythm-based colour. Output wording is "ECG pattern suggestive of ST elevation, possible acute ischaemia, refer", never a diagnosis and never "normal" (spec v2 C-31, hazard H-01). "AMBER" corresponds to `Urgency.YELLOW` in `ml/ecg_rules`.

### 5.1 Preconditions (all must hold; otherwise the ST check abstains)

| Check | Rule | Source / status |
|---|---|---|
| Lead identity | 12 leads identified; if fewer than 8 usable leads, abstain | Hazard H-04/H-09; spec C-30. 8 leads = research 01 "≥8-12 properly identified leads". PENDING_REVIEW |
| Gain/time base | Calibration pulse or printed scale detected; gain and speed known; else abstain | Researcher inference |
| Beat count per lead | At least 2 beats with detected QRS and a measurable PR/TP baseline (preferably 3) | Researcher inference |
| Measurement uncertainty | Per-lead u <= 1.0 mm (hard limit); u <= 0.5 mm for RED | Section 4; PENDING_REVIEW |
| Rhythm | If the rhythm rules flag ventricular tachycardia or VF-like trace: ST rule not evaluated (already RED) | Existing rules |
| Wide QRS | If QRS >= 120 ms in most leads: do not apply the standard STEMI thresholds (see 5.4) | UDMI/ESC: criteria exclude LBBB; `thresholds.py` WIDE_QRS_MS = 120 (CITED there) |
| Paced rhythm | Pacing spikes present: treat as wide QRS | ESC 2023, Verified |

### 5.2 Per-lead ST measurement

```
for each lead L and each beat b:
    baseline(L,b) = median of PR segment (fallback: TP)      # AHA convention; Unverified
    J(L,b)        = J point (end of QRS)                     # UDMI, Verified
    ST_J(L,b)     = signal(J) - baseline                     # primary, mm via gain
    ST_40(L,b)    = signal(J + 40 ms) - baseline             # robustness check
ST(L)  = median over beats of ST_J ;  u(L) = max(MAD over beats, Einthoven/dup-lead residual)
```

(J+40 ms is a Researcher inference; J+60 and J+80 are used in other settings and may be substituted after cardiologist review.)

### 5.3 Rule E1: ST elevation in two contiguous leads (RED)

| Leads | Draft thresholds (mm) | Source |
|---|---|---|
| V2, V3, men <40 y | >= 2.5 | UDMI 2018 and ESC 2023 (ESC verbatim, Verified) |
| V2, V3, men >= 40 y | >= 2.0 | same |
| V2, V3, women | >= 1.5 | same |
| V2, V3, sex or age unknown | AMBER at >= 1.5, RED at >= 2.0 | Researcher inference, PENDING_REVIEW |
| All other leads (I, II, III, aVL, aVF, V1, V4, V5, V6) | >= 1.0 | UDMI and ESC (Verified) |
| aVR | not used in E1 | see E4 |

```
RED if there exist two contiguous leads (section 2) L1, L2 with
     ST(L1) >= T(L1) and ST(L2) >= T(L2)                                # criteria met
     and ST_40 on both leads also >= T - 0.5 mm                         # not a J-point artefact
     and the pattern holds in >= 2 of 3 beats (or all beats if only 2)  # reproducible
     and u(L1) <= 0.5 mm and u(L2) <= 0.5 mm                            # accurate enough
AMBER if the same holds with ST >= 0.7 * T (borderline), or criteria are met but 0.5 < u <= 1.0 mm
```

The 0.7 factor and the u limits are Researcher inference, PENDING_REVIEW. Rationale: the borderline band corresponds to roughly the median digitiser error; escalating there costs false alarms but not missed events, and the flag is advisory.

Mimic handling (all Researcher inference, PENDING_REVIEW):
- If ST elevation is confined to V1-V3 (or V2-V4) and a QRS voltage criterion for LVH is met (for example Sokolow-Lyon SV1 + RV5/V6 > 35 mm, Unverified textbook), cap at AMBER with the wording "may be LVH".
- If elevation is diffuse (>= 6 leads, concave, with PR depression), cap at AMBER with "pattern also seen in pericarditis/early repolarisation". PR depression and ST concavity are measurable only roughly; v1 may use lead count alone.
- Reciprocal ST depression of >= 1 mm in the opposite territory (for example aVL for inferior STE) raises AMBER to RED. Supporting evidence for reciprocal changes is not verified here: Unverified.

### 5.4 Rule E2: ST depression (AMBER, escalating with symptoms)

| Pattern | Draft | Source |
|---|---|---|
| Horizontal/downsloping ST depression in two contiguous leads | AMBER if >= 1.0 mm (official figures: 0.5 mm UDMI; 0.05 mV KR NSTE-ACS) | UDMI Table 2 (Partly verified), KR NSTE-ACS (Verified). The 1.0 mm raises the figure to the digitiser's error floor: Researcher inference, PENDING_REVIEW |
| Posterior pattern: ST depression in >= 2 of V1-V3 with upright terminal T wave | AMBER if >= 1.0 mm; RED if symptoms suggest ACS | UDMI (0.5 mm V1-V3, Verified); ESC (V1-V3 with positive terminal T, Verified); V7-V9 not available; the 1.0 mm is Researcher inference |
| ST depression >= 1 mm in >= 6 leads **and** STE in aVR and/or V1 | AMBER; RED if symptoms or haemodynamic compromise reported | UDMI/ESC 2023 (Verified: "suggestive of multivessel disease or left main disease", "haemodynamic compromise") |

Isolated T-wave inversion is **not** a trigger (KR NSTE-ACS: not associated with adverse prognosis; Verified). Downsloping/horizontal depression in a lead with LVH strain or digoxin effect is a known mimic (Unverified); AMBER wording stays non-diagnostic.

### 5.5 Rule E3: wide QRS / LBBB / paced (escalate, do not interpret)

```
if QRS >= 120 ms in >= 8 leads (or pacing spikes):
    mark "ST analysis not valid (wide QRS)"
    AMBER by default    # LBBB cannot be called normal; today's LBBB case came out GREEN
    RED if the user answers yes to ACS-like symptoms   # ESC 2023: manage like STEMI with high clinical suspicion
    optional later: concordant STE >= 1 mm (5 pts), V1-V3 concordant STD >= 1 mm (3 pts), ST/S <= -0.25 (Smith)   # only after QRS-polarity and S-wave measurement are validated
```

Cost: every chronic LBBB (common) becomes AMBER; the cardiologist must decide whether that alarm load is acceptable. The cost of not doing it is a GREEN LBBB, which the README showed on 00180 (CLBBB). PENDING_REVIEW. Wide-QRS detection from the digitised trace is itself unreliable (README: VT QRS width unreliable); use agreement across leads and treat a failed measure as "unknown", not "narrow".

### 5.6 Rule E4: aVR

```
aVR STE > 1 mm alone: no flag (UDMI: may accompany anterior or inferior STEMI; also normal in mislabelled leads)
aVR STE with widespread depression: see E2 row 3
```

### 5.7 Patterns not implemented in v1 (listed with the reason)

- Right-ventricular and posterior V7-V9: leads not on the page; use inferior-STE and V1-STE as hints only; text advice "consider right-sided/posterior leads" (ESC 2023, Verified) for the cardiologist.
- de Winter, Wellens, hyperacute T: partly measurable; secondary-source criteria only; high LVH mimic rate for Wellens. Research for v2 with a labelled test set.
- Sgarbossa/Smith: after QRS polarity and S-wave measurement are validated.

### 5.8 Output logic

```
final = max(rhythm_urgency, ST_urgency)                 # never greener
if ST preconditions fail:  ST_urgency = none and add note "ST analysis not performed"
```
Open decision for the cardiologist (PENDING_REVIEW): when the ST check abstains but the rhythm is clean, either (a) keep GREEN with a mandatory banner "ST segment not assessed; does not exclude heart attack", or (b) show GREY. (b) is safer and complies with "may never make a result greener", but may produce many GREY results on phone photos.

### 5.9 Items that must be marked PENDING_REVIEW

All numeric thresholds are cited to a guideline, except these, which are **draft values chosen here** and need review: AMBER fraction 0.7, u limits (0.5/1.0 mm), 1.0 mm for ST depression, J+40 ms, unknown-sex V2-V3 rule, beat-count and reproducibility rule, the 8-lead minimum, the LVH/diffuse cap logic, the wide-QRS AMBER default, the aVR/diffuse-depression escalation and the reciprocal-change upgrade. Also for the cardiologist: the nitrate advice in the pre-hospital list versus RV infarction; the "ST not assessed" colour; whether limb-chest contiguity pairs should count; and the KR protocol's 0.05 mV depression figure versus the digitiser error floor.

---

## 6. Pretrained open 12-lead ECG classifiers (inference only)

Policy: ADR 0001 requires permissive code **and weights** (Apache-2.0, BSD, MIT) for the product path; CC BY-NC and no-licence items are evaluation-only; weights trained on non-commercial or restricted data need an ADR. No training or fine-tuning by us (so released heads must already contain MI-related outputs).

Important shared caveats (Researcher inference): (1) none of these was tested on **photo-derived** signals; (2) a 3x4 page gives 2.5 s per lead plus a rhythm strip, so the 10 s 12-lead input these models expect is only partly real (the README writes a 10 s record; how the other 7.5 s per lead is filled should be checked before feeding a classifier); (3) a recent benchmark found 2.5 s crops with test-time averaging beat full 10 s input for models that accept variable length ([Al-Masud et al. 2025](https://arxiv.org/html/2509.25095v1)), which fits our case.

| Model | Code licence | Weights licence | Input | Size | MI / ischaemia output and reported performance | Links | ADR 0001 verdict |
|---|---|---|---|---|---|---|---|
| **ECGFounder** (Li, Hong et al., NEJM AI 2025) | MIT (GitHub API, Verified) | MIT on the Hugging Face card (Verified). Weights trained on HEEDB (10.77 M Harvard-Emory ECGs) with labels from Marquette 12SL output; HEEDB terms for derived models not checked: **Unverified** | 12 leads x 5000 samples (10 s at 500 Hz), z-score; filters inconsistent in the paper (0.5-50 Hz vs 1-30 Hz) | 33.8 M (benchmark paper, Net1D); 76.3 M reported in paper Table S11 for a model variant (discrepancy) | 150 classes incl. anterior/inferior/lateral/septal/posterior infarct and "ACUTE MI / STEMI" (Table S4). Internal AUC: anterior infarct 0.908, inferior 0.998, lateral 0.998. **External PTB-XL AUC: anterior 0.635, anterolateral 0.945, inferior 0.851, lateral 0.916, septal 0.947**. No AUROC reported for the acute MI/STEMI label. PTB-XL superdiagnostic macro-AUROC 0.935 after fine-tuning (benchmark) | [GitHub](https://github.com/PKUDigitalHealth/ECGFounder), [HF](https://huggingface.co/PKUDigitalHealth/ECGFounder), [arXiv 2410.04133](https://arxiv.org/abs/2410.04133) | Permissive on paper; needs an ADR on training-data terms. Whether the released checkpoint contains the 150-class head: Unverified (card says "pre-training checkpoint"). |
| **ECG-FM** (wav2vec 2.0-style, MIMIC-IV-ECG + PhysioNet 2021 pretraining) | MIT (Verified on repo page) | MIT on the HF card (Verified) | Input spec not on the pages I read (uses `fairseq_signals`); Unverified | 90.9 M (repo), 93.9 M (benchmark) | Paper reports AF AUROC 0.996 and LVEF<=40 % 0.929; **MI AUROC not found**; PTB-XL superdiagnostic macro 0.916 (benchmark). Fine-tuned label list in `label_def.csv`: not read | [GitHub](https://github.com/bowang-lab/ECG-FM), [HF](https://huggingface.co/wanglab/ecg-fm), [arXiv 2408.05178](https://arxiv.org/abs/2408.05178) | Permissive on paper. Pretraining data licences (MIMIC-IV-ECG, PhysioNet 2021 sets) not checked: Unverified. Needs the fairseq dependency stack. |
| **HuBERT-ECG** (Coppola et al.) | Repo lists CC BY-NC 4.0; GitHub API shows no SPDX licence | **CC BY-NC 4.0** (HF card, Verified) | Not stated on pages read (paper) | 93.1 M base (HF), 97.2 M (benchmark); small/large exist | No MI result found on the pages read; PTB-XL superdiagnostic 0.908 (benchmark) | [HF](https://huggingface.co/Edoardo-BS/hubert-ecg-base), [GitHub](https://github.com/Edoar-do/HuBERT-ECG) | **Evaluation only** (non-commercial). |
| **Ribeiro et al.** (Nat Commun 2020, CODE/Telehealth) | MIT (GitHub API, Verified) | Zenodo [10.5281/zenodo.3625017](https://doi.org/10.5281/zenodo.3625017); **weights licence not stated** (Unverified) | 4096 samples x 12 leads at 400 Hz (about 10 s), order DI, DII, DIII, AVR, AVL, AVF, V1-V6, scale 1e-4 V (multiply volts by 1000); Keras/TensorFlow 2.2 | Not stated on page (ResNet-style 1D) | **No MI class.** Six outputs: 1st-degree AV block, RBBB, LBBB, sinus bradycardia, AF, sinus tachycardia | [GitHub](https://github.com/antonior92/automatic-ecg-diagnosis) | Possibly useful as an independent **LBBB/RBBB gate** for rule E3, not for MI; weights licence must be confirmed from Zenodo first. |
| **Strodthoff et al. PTB-XL benchmark** (resnet1d_wang, xresnet1d101, inception1d, ...) | **GPL-3.0** (GitHub API, Verified) | Trained models in a zip hosted by Fraunhofer; licence not stated (Unverified) | PTB-XL records (100/500 Hz, 10 s, 12 leads; which rate used for released models: Unverified) | Not stated | PTB-XL superdiagnostic macro-AUC 0.930 (resnet1d_wang), 0.928 (xresnet1d101), 0.921 (inception1d) (README leaderboard, Verified); MI-superclass AUC not extracted (Unverified) | [GitHub](https://github.com/helme/ecg_ptbxl_benchmarking), [arXiv 2004.13701](https://arxiv.org/abs/2004.13701) | **Not permissive (GPL-3.0)**; evaluation only. |
| **ST-MEM** (ICLR 2024) | "All rights reserved" notice, no open licence | Google Drive links, no licence | Not stated | ViT-B, about 90.3 M (benchmark) | PTB-XL superdiagnostic 0.901 (benchmark) | [GitHub](https://github.com/bakqui/ST-MEM) | **Not usable** (no licence). |
| **ECG-CPC** (Al-Masud et al. 2025) | Repo has no licence (API: null) | Not stated | 240 Hz (HEEDB minimum), variable length, 2.5 s crops used | 3.8 M | PTB-XL superdiagnostic 0.934; posterior MI AUROC 0.987 (benchmark); other MI labels in non-PTB-XL tables not read | [GitHub](https://github.com/AI4HealthUOL/ecg-fm-benchmarking), [arXiv 2509.25095](https://arxiv.org/abs/2509.25095) | **Not usable until the authors add a licence**. Attractive on size (on-device). Also pretrained on HEEDB (same caveat as ECGFounder). |
| MERL (4.6 M), ECGFM-KED (9.7 M), ECG-JEPA (87.2 M) | Not checked | Not checked | - | as listed in the benchmark | PTB-XL superdiagnostic 0.930 / 0.905 / 0.921 (benchmark) | [benchmark](https://arxiv.org/html/2509.25095v1) | Licences Unverified. |
| OMI-specific models: ECG-SMART-NET (ResNet-18, AUC 0.953, IEEE TBME 2025), Gustafsson et al. medRxiv 2025 (540,372 emergency ECGs with cath outcomes, C-statistic >0.95, internal validation) | Unknown | Unknown | - | - | Only abstracts seen; weights not found | [arXiv 2405.09567](https://arxiv.org/abs/2405.09567), [medRxiv](https://www.medrxiv.org/content/10.1101/2025.09.11.25335407v1.full) | No open weights found. The commercial OMI model (PMcardio) is proprietary (research 01). |

All performance numbers above come from papers or benchmark tables on **clean digital signals**; the benchmark table values were read through a page-summary tool (Partly verified).

### Recommendation (Researcher inference)

1. **ECGFounder** is the only candidate that lists MI/STEMI classes and has MIT code and weights on its pages. Before use: (a) ADR on HEEDB/Marquette-label terms; (b) confirm the checkpoint has the 150-class head; (c) test on rendered PTB-XL pages and photos, where the external PTB-XL anterior-infarct AUC of 0.635 is a warning sign.
2. **ECG-FM** (MIT) as a second candidate; MI output not confirmed.
3. **Ribeiro et al.** only as an LBBB/RBBB/AF cross-check for the wide-QRS gate (E3), after the weights licence is confirmed.
4. HuBERT-ECG, the Strodthoff models (GPL-3.0), ST-MEM and ECG-CPC: evaluation-only or blocked by licence as above. Ask the ECG-CPC authors for a licence.
5. A learned MI score, if used, should also be **escalate-only** and should abstain on low-quality digitisation, like the rule.

---

## 7. Sources

Verified (page text read this session):
- Thygesen K, et al. Fourth universal definition of myocardial infarction (2018). Eur Heart J 2019;40:237-269. https://academic.oup.com/eurheartj/article/40/3/237/5079081
- Byrne RA, et al. 2023 ESC Guidelines for the management of acute coronary syndromes. Eur Heart J 2023;44:3720-3826. https://academic.oup.com/eurheartj/article/44/38/3720/7243210
- Meyers HP, et al. Comparison of the ST-elevation myocardial infarction (STEMI) vs. NSTEMI and occlusion MI (OMI) vs. NOMI paradigms of acute MI. https://pmc.ncbi.nlm.nih.gov/articles/PMC8065286/
- ECG-FM, ECGFounder, HuBERT-ECG, Ribeiro, ST-MEM, PTB-XL benchmark repositories and model cards (links in section 6), including the GitHub API licence fields read on 2026-11-04.
- Al-Masud et al. Benchmarking ECG foundational models. https://arxiv.org/html/2509.25095v1
- ECGFounder paper, v4 HTML. https://arxiv.org/html/2410.04133v4
- KR protocols via research 10 (MedElement copies).

Partly verified (search summaries or secondary pages; primary text not read): Sgarbossa 1996 and Smith 2012 (secondary summaries), Wellens (LITFL), de Winter (WikEM/Wikipedia/radiology pages), the Glasgow/12SL/DXL accuracy figures, the Leiden J-point study, the JAMA 2007 false-positive cath-lab study, OMI review articles, UDMI Table 2 depression wording.

Unverified: AHA/ACCF/HRS 2009 Part VI full text (HTTP 403), PR/TP baseline convention of each vendor program, J+60/J+80 conventions, RV-infarct nitrate caution, Sokolow-Lyon threshold, reciprocal-change value, HEEDB and MIMIC-IV-ECG licence terms for derived weights, ECG-FM input specification, Ribeiro weights licence, class/level of the ESC 10-minute ECG recommendation.
