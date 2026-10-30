# 03 — ECG datasets (signals and images) for training and evaluating ECG-AI KG

Date accessed for all sources: 2026-10-29. Status tags: **[V]** Verified (primary page read), **[P]** Partly verified (secondary source, search snippet, or only part read), **[U]** Unverified (from memory or not checked — confirm before relying on it).

## Summary

- **No public dataset contains real smartphone photos of paper ECGs with clinical labels at scale.** The usable image resources are *synthetic or re-photographed* renderings of signals: PhysioNet Challenge 2024 images (rendered from PTB-XL with ECG-Image-Kit), ECG-Image-Database (977 PTB-XL and 1000 Emory records, printed and photographed with 4 phones), and PM-ECG-ID (100 PTB-XL waveforms, 6,000 image entries). Our photo-to-signal front end must therefore be trained and tested mainly on synthetic data plus a small self-collected real photo set. [V/P]
- **The best open backbone for the classification stage is PTB-XL** (CC BY 4.0, 21,799 records, 18,869 patients, 10 s, 500 Hz, labelled by cardiologists). It covers MI, ST/T change, conduction disturbance and some rhythms, but it has **no explicit STEMI/OMI label** and few VT/VF/AV-block-III cases. [V]
- **Big 12-lead sets add rhythm coverage and diversity.** The PhysioNet/CinC 2021 collection (>100,000 recordings from 4 countries; >88,000 public) and Chapman-Shaoxing/Ningbo (45,152 patients, CC BY 4.0) cover AF, flutter, bundle-branch blocks and AV blocks with SNOMED-CT labels. CODE-15% adds 345,779 ECGs (Brazil, CC BY 4.0, weak/automatic labels). [V/P]
- **MIT-BIH is a rhythm and beat benchmark, not a 12-lead diagnostic set.** It has 48 two-channel half-hour recordings from 47 subjects, 360 Hz, from 1975–79, so a model that does well on it says little about a clinic photo. Use inter-patient splits such as de Chazal. [V for the facts; U for de Chazal details, see section 2]
- **Licensing is mostly benign for an Apache-2.0 repo, if we ship no data in git.** PTB-XL, Chapman/Ningbo, CinC 2021 and CODE-15% are CC BY 4.0, which allows commercial use with attribution. MIT-BIH is ODC-By. MIMIC-IV-ECG is ODbL (share-alike on derivative *databases*). Icentia11k is CC BY-NC-SA (non-commercial) and needs a conflict check. HEEDB is credentialed under a BDSP licence. [V/P]
- **Acute-MI-specific data is the biggest gap.** The recent ACS-ECG set (19,955 ECGs with angiographic labels, 2026) is the only open set I found with occlusion-type labels. Its licence is reported inconsistently (CC BY 4.0 vs CC0) and I did not read the primary page. [P]
- **No Kyrgyz or Kazakh ECG dataset was found.** The only Russian open set found is LUDB (200 records, Nizhny Novgorod) plus INCART (St Petersburg, 75 records). Population shift to Central Asia cannot be measured with public data. [P]

## 1. Signal datasets: overview table

| Dataset | Content | Labels relevant to us | Population | Licence / access | Fit | Status |
|---|---|---|---|---|---|---|
| **MIT-BIH Arrhythmia** | 48 ~30-min 2-channel ambulatory recordings, 47 subjects, 360 Hz, 11-bit; ~110,000 beat annotations | Beat and rhythm labels (AF, flutter, VT, AV block, etc. appear, but in few subjects) | Boston, 1975–79; 25 men (32–89), 22 women (23–89); records 201 and 202 are the same subject | ODC-By 1.0; open ([page](https://physionet.org/content/mitdb/1.0.0/), [licence](https://physionet.org/content/mitdb/view-license/1.0.0/)) | Beat/rhythm detector sanity check only | V |
| **PTB-XL v1.0.3** | 21,799 ECGs, 18,869 patients, 12 leads, 10 s, 500 Hz (100 Hz copy). 71 SCP-ECG statements, up to 2 cardiologists. Superclasses: NORM 9,514; MI 5,469; STTC 5,235; CD 4,898; HYP 2,649 | MI (with sub-types), ST/T, LBBB/RBBB (within CD), AF/flutter/tachy/brady rhythm statements. No STEMI label. | Germany (PTB Berlin); 52% male, age 0–95 | CC BY 4.0; open ([page](https://physionet.org/content/ptb-xl/1.0.3/), [licence](https://physionet.org/content/ptb-xl/view-license/1.0.3/)) | **Core train/val set**; includes recommended 10-fold split (folds 9, 10 are the quality-checked evaluation folds) | V |
| **PTB-XL+ v1.0.1** | Features from 12SL, Uni-G and ECGdeli; median beats; automatic 12SL diagnostic statements (SNOMED-mapped). Uni-G statements not included (usage restrictions) | Machine labels, used by Challenge 2024 to refine acute/old MI | Same as PTB-XL | Licence not read on the page (derivative of PTB-XL); open | Feature baselines, explainability, label refinement | V (content), U (licence) |
| **PTB Diagnostic** | ~549 records, 290 subjects, 15 leads, 1 kHz — numbers from memory | MI, cardiomyopathy, BBB, dysrhythmia, healthy | Germany | Open (licence not read) | Superseded by PTB-XL; many records per patient, leakage risk | U |
| **CinC 2020/2021** | 2021: >100,000 recordings from CPSC, CPSC-Extra, INCART, PTB, PTB-XL, G12EC (Georgia, USA), Chapman-Shaoxing, Ningbo and UMich sources; >88,000 public as training data; hidden validation 6,630 and hidden test 36,266 | SNOMED-CT labels (AF, flutter, VT in a few, 1st/3rd degree AV block, LBBB/RBBB, STEMI-like ST changes, brady/tachy) | China, Germany, USA, Russia (INCART) | CC BY 4.0; open ([page](https://physionet.org/content/challenge-2021/1.0.3/), [licence](https://physionet.org/content/challenge-2021/view-license/1.0.3/)) | **Best multi-source rhythm/conduction pool**; leave-one-source-out generalisation tests | V (sources, counts, licence); U (per-class counts, check the label table) |
| **Chapman-Shaoxing + Ningbo** | 45,152 patients, 12 leads, 10 s, 500 Hz, SNOMED-CT. Original figshare release had 10,646 patients | Rhythms (AF, flutter, SVT, brady/tachy…) and some other conditions | Zhejiang, China | CC BY 4.0; open ([page](https://physionet.org/content/ecg-arrhythmia/1.0.0/), [licence](https://physionet.org/content/ecg-arrhythmia/view-license/1.0.0/)) | Rhythm training, AF/flutter especially; Asian population | V |
| **CODE / CODE-15%** | CODE-15%: 345,779 ECGs, 233,770 patients, 12 leads, 400 Hz, HDF5, from the Telehealth Network of Minas Gerais, 2010–2016 | Labels for 1dAVb, RBBB, LBBB, sinus brady, AF, sinus tachy (automatic/text-derived, weaker than manual labels). Full CODE is not public. | Brazil; primary-care telehealth, closest in setting to our target users | CC BY 4.0; open on Zenodo ([record](https://zenodo.org/records/4916206)) | Large pretraining or external test for 6 classes. Weak labels — do not treat as gold. | P (via secondary summaries + Zenodo link; record not read) |
| **SaMi-Trop** | 12-lead ECGs from a Chagas cardiomyopathy cohort (cohort 1,959 patients; open subset smaller), age and mortality annotations | Not a rhythm/diagnosis set | Brazil, Chagas disease | Zenodo, open; licence not read | Low relevance; skip | P ([record](https://zenodo.org/records/4905618)) |
| **MIMIC-IV-ECG** | ~800,000 diagnostic ECGs, ~160,000 patients, 12 leads, 10 s, 500 Hz; ~5% withheld for challenges; machine measurements and cardiologist report text | Free-text reports (NLP needed for labels): STEMI, AF, flutter, AV block, BBB all present at scale | Boston (BIDMC), 2008–2019 | ODbL 1.0 (share-alike on derivative databases); [page](https://physionet.org/content/mimic-iv-ecg/1.0/), [licence](https://physionet.org/content/mimic-iv-ecg/view-license/1.0/). Access tier not confirmed on the page I read (U). | Large external test/pretraining; label extraction from reports is a project in itself | V (content, licence), U (access tier) |
| **INCART** | 75 annotated recordings from 32 Holter records, 30 min, 12 leads, 257 Hz | Beat annotations (arrhythmia patients, incl. ischemia, AF, etc.) | St Petersburg, Russia | PhysioNet open (licence not read) | Tiny; Russian-population data point ([archive page](https://archive.physionet.org/physiobank/database/incartdb/)) | P |
| **Long-Term AF DB** | 84 long-term (~24–25 h) 2-lead recordings, 128 Hz — numbers from memory (the record list shows ~84 IDs) | AF episodes (rhythm labels) | USA (paroxysmal AF patients) | Open (licence not read) | Long AF/non-AF rhythm tests; 2-lead, not 12-lead ([page](https://physionet.org/content/ltafdb/1.0.0/)) | U |
| **CU Ventricular Tachyarrhythmia DB** | 35 eight-minute recordings with sustained VT, flutter, VF | Rhythm labels | USA | Open | VT/VF detector, tiny | V ([page](https://physionet.org/content/cudb/1.0.0/)) |
| **MIT-BIH Malignant Ventricular Ectopy DB** | 22 half-hour recordings with sustained VT, ventricular flutter, VF; rhythm labels only | Rhythm labels | Boston | Open | VT/VF detector, tiny | V ([page](https://physionet.org/content/vfdb/1.0.0/)) |
| **Icentia11k** | 11,000 patients, ~2 billion labelled beats, single lead, 250 Hz, CardioSTAT patch | Beat and rhythm (AF) labels | Canada | PhysioNet shows **CC BY-NC-SA 4.0** on the licence page, but a separate LICENSE.txt snippet showed CC BY-SA 4.0 — conflict, treat as non-commercial ([licence](https://physionet.org/content/icentia11k-continuous-ecg/view-license/1.0/)) | Single-lead pretraining only. Avoid if the product may be commercial or government-licensed. | P |
| **Shandong Provincial Hospital (SPH)** | 25,770 ECGs, 24,666 patients, 12 leads, 500 Hz, 10–60 s; AHA/ACC/HRS statements (44 primary + 15 modifiers) | Counts from Table 3: AV conduction 370; ventricular arrhythmias 1,067; MI 260; ST/T 5,125; sinus 4,643 | Jinan, China, 2019–20 | Hosted via Scientific Data/figshare; I did not read the licence ([article](https://pmc.ncbi.nlm.nih.gov/articles/PMC9174207/)) | Rich AHA-standard labels; useful for AV block and MI | V (content), U (licence) |
| **Harvard-Emory ECG Database (HEEDB) v5** | ~11.6 million 12-lead ECGs (10.6 M MGH, ~1.0 M Emory) | Large-scale labels, hospital data | USA | **Credentialed** via BDSP: CITI training + DUA, "BDSP Credentialed Health Data License 1.5.0" ([page](https://www.bdsp.io/content/heedb/5.0/), [paper](https://www.nature.com/articles/s41597-026-06861-9)) | Not usable for an open-weight public model without checking the DUA; best only as an optional private external test | P |
| **ACS-ECG (2026)** | 19,955 12-lead ECGs, 18,909 patients, 500 Hz, angiographic labels (a Hugging Face repack of 12,569 ECGs from 11,906 patients is licensed CC0 1.0) | **Acute coronary occlusion/ACS labels — the only OMI-type label set found** | Source hospital not checked | Aggregator says CC BY 4.0; the repack says the figshare original is CC0 1.0 — inconsistent ([repack](https://huggingface.co/datasets/Emulated-Inc/sci-omi-from-ecg), [catalogue](https://github.com/aaekay/ecg-datasets)); original not read | Priority external check for the ACS/STEMI model | P |
| **LUDB** | 200 records, 12 leads, 10 s, 500 Hz, manual wave boundaries (P, QRS, T) | Delineation, not diagnosis | Nizhny Novgorod, Russia | ODC-Attribution (per catalogue) ([page](https://physionet.org/content/ludb/1.0.1/)) | Tiny Russian-population delineation set | P |

### 1.1 PTB-XL record counts by version [V]
v1.0.0 and v1.0.1 had 21,837 records. v1.0.2 removed 36 duplicate-waveform records (preferentially from test folds 9–10). v1.0.3 removed two more (21,837 − 36 − 2 = 21,799, matching the current page). The 21,799 figure and release notes come from the [v1.0.3 page](https://physionet.org/content/ptb-xl/1.0.3/). The "two more" detail is truncated on the page I read, so the arithmetic is my inference.

### 1.2 Limits of MIT-BIH [V for facts, U for de Chazal numbers]
- Only 2 channels (usually modified lead II plus V1/V5), ambulatory, 1975–79 equipment, 47 subjects, 25 men and 22 women. [Source](https://physionet.org/content/mitdb/1.0.0/)
- Many classes occur in just a handful of patients. **Intra-patient** (random beat) splits put beats from the same patient in train and test and report inflated accuracy. **Inter-patient** evaluation (the de Chazal et al. 2004 split, which divides the 44 usable records into two disjoint sets of 22, and AAMI EC57 classes N, S, V, F, Q) is the honest protocol. I did not re-read de Chazal's paper this session, so treat the split details as [U] and fetch the paper before coding it.
- It cannot teach photo-based 12-lead interpretation or STEMI detection.

## 2. ECG image datasets

| Dataset | Content | Real photos? | Labels | Licence / access | Status |
|---|---|---|---|---|---|
| **PhysioNet Challenge 2024** (digitisation + classification) | Training images are synthetic, generated from PTB-XL waveforms with ECG-Image-Kit; labels from PTB-XL, with acute/old MI refinement via PTB-XL+ ([challenge site](https://moody-challenge.physionet.org/2024/)) | Mostly synthetic; hidden test sets included real scans/photos (Emory) per the challenge overview — detail U | PTB-XL classes | Derived from PTB-XL: treat as CC BY 4.0 plus the kit's BSD-3-Clause (this is a licence-composition inference, not a quote) | P |
| **ECG-Image-Database** (Reyna et al., arXiv 2409.16612) | Images made from **977 PTB-XL records and 1000 diagnosis-stratified Emory Healthcare records**, with distortions (noise, wrinkles, stains, perspective). Red-grid printouts were photographed with 4 phones (Galaxy S20 FE, iPhone 12, iPhone 13 mini, Galaxy S10+) in an office. | **Yes — physically printed and photographed**, but office conditions | Source-record labels | Licence not found in the text I read | V ([arXiv](https://arxiv.org/html/2409.16612), [PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11469442/)) |
| **PM-ECG-ID (PMcardio)** | 100 PTB-XL waveforms → 6,000 image entries: different phones, bends, crumples, scans, photos of screens, plus augmentations. 33.9 GB | **Yes (mixed with augmentation)** | Ground-truth leads/rhythm arrays for digitisation scoring | Zenodo "Open"; the exact licence did not appear in the extracted page — U ([record](https://zenodo.org/records/13617673)) | V (content), U (licence) |
| **Emory Paper ECG Database** | Used as a benchmark with scans and mobile photos, clean and deteriorated, colour and B&W | Yes | Not checked | Not checked | P ([benchmark listing](https://www.sota2.com/research/dataset/emory-paper-ecg-database)) |
| **ECG Images dataset of Cardiac Patients** (Mendeley, Pakistan) | 12-lead ECG images from the Ch. Pervaiz Elahi Institute of Cardiology, Multan; v2 published 2021-03-19; four categories in the cardiac-only version | Scans/photos of printed ECGs (acquisition details not verified) | Four classes (reported as MI, abnormal heartbeat, history of MI, normal) — class names are from memory, U | CC BY 4.0 ([record](https://data.mendeley.com/datasets/gwbz3fsgp8/2)) | P |
| **Our own PTB-XL renderings** | Render PTB-XL with ECG-Image-Kit (BSD-3-Clause) and augment | Synthetic | PTB-XL labels | CC BY 4.0 for derivatives with attribution | V (licences from [PTB-XL licence](https://physionet.org/content/ptb-xl/view-license/1.0.3/)) |

Open-source digitisers exist that we can benchmark against rather than build from scratch: [Open-ECG-Digitizer](https://github.com/Ahus-AIM/Open-ECG-Digitizer) (handles phone photos with perspective correction). I did not check its licence, so [U].

## 3. Central Asia / Russia

- **Kyrgyzstan / Kazakhstan:** no public ECG dataset found in three searches (including the community catalogues [vlbthambawita/ECGDatasets](https://github.com/vlbthambawita/ECGDatasets) and [aaekay/ecg-datasets](https://github.com/aaekay/ecg-datasets)). Absence of evidence only.
- **Russia:** LUDB (Nizhny Novgorod, 200 records) and INCART (St Petersburg, 75 records) are on PhysioNet; both are small. Russian-language papers exist about ECG synthesis, but I found no further open datasets.
- **Concern (researcher inference):** the training populations are German, Chinese, Brazilian and US hospital patients, recorded on hospital machines. Rural Kyrgyz FAP ECGs (older portable devices, different paper formats, different disease mix, e.g. higher hypertensive and rheumatic burden) may differ. Calibrate and test locally after the proof of concept.

## 4. Implications for ECG-AI KG

1. **Split the problem.** (a) Image → signal (digitisation); (b) signal → classes. Train and test each independently. Use PTB-XL waveforms for (b), so (b) is not blocked by image data.
2. **Image pipeline data.** Generate synthetic training images from PTB-XL and CinC data with ECG-Image-Kit. Evaluate on ECG-Image-Database and PM-ECG-ID real photos (digitisation SNR vs ground truth). Collect a small private set of real photos of Kyrgyz paper ECGs after the POC, with consent and with no patient data in git.
3. **Classification data.** Start with PTB-XL (official folds). Add Chapman/Ningbo and CinC 2021 sources for rhythm and conduction classes. Use leave-one-source-out evaluation and report per-class results with confidence intervals.
4. **STEMI/ACS.** PTB-XL's MI label is not "STEMI". Plan to use ACS-ECG (after reading its primary licence page) and/or MIMIC-IV-ECG report text as an external check, and make the cardiologist review the definitions (STEMI criteria, OMI, equivalent patterns) at the POC stage.
5. **VT/VF, AV block III.** Public 12-lead data has few examples. Use CU/MIT-BIH VFDB for a *rate/morphology rule-based safety net*, and treat model output for these as low-confidence. Prefer rule-based detection (ventricular rate, QRS width, regularity) plus "refer urgently" defaults.
6. **Do not use MIT-BIH as the headline benchmark.** Use it only for R-peak and beat-detector checks, with an inter-patient split.
7. **Licensing for a public Apache-2.0 repo with government use.**
   - Do not commit data or weights trained on data in a way that violates a share-alike licence; keep datasets in git-ignored `data/` and download via scripts (already in AGENTS.md).
   - CC BY 4.0 sets (PTB-XL, Chapman/Ningbo, CinC 2021, CODE-15%) allow commercial and government use with attribution. Keep a `DATA_LICENSES.md` with the attributions.
   - Avoid **non-commercial** sets (Icentia11k) for any model weights that the ministry might deploy.
   - ODbL (MIMIC-IV-ECG) share-alike applies to derivative databases, not obviously to model weights; this is a legal question [U] — ask a lawyer or avoid training on it, using it only for evaluation.
   - Credentialed data (HEEDB, and any other DUA data) usually forbids redistribution; keep weights trained on it private unless the DUA allows otherwise.

## 5. Recommended dataset strategy

| Stage | Data | Notes |
|---|---|---|
| **Train (classifier)** | PTB-XL folds 1–8; Chapman/Ningbo; CinC 2021 open sources; optionally CODE-15% (weak labels) | CC BY sets only for released weights |
| **Validation** | PTB-XL fold 9; held-out patients of other sources | Split by patient, never by record |
| **Internal test** | PTB-XL fold 10 (quality-checked) | Report once |
| **External test** | SPH (Shandong), ACS-ECG, MIMIC-IV-ECG (evaluation only), CODE-15% subset | Measures population shift; check licences first |
| **Train (digitiser)** | Synthetic images from PTB-XL via ECG-Image-Kit with heavy augmentation (shadows, perspective, folds) | |
| **Test (digitiser)** | ECG-Image-Database, PM-ECG-ID, Emory paper ECG (if accessible) | Metric: SNR vs ground truth, then end-to-end class accuracy on photo vs original signal |
| **Local test (after POC)** | Kyrgyz paper ECGs photographed with local phones, cardiologist-labelled | The only real answer to population shift |

## Open questions

| Question | Who / how |
|---|---|
| Exact licences of PTB-XL+, PM-ECG-ID, ECG-Image-Database, SPH, ACS-ECG, INCART, LTAFDB, PTB | Research follow-up (read the licence pages) |
| Per-class counts (AF, flutter, VT, AV block III, LBBB/RBBB, STEMI-type) in CinC 2021 and PTB-XL (SCP statement counts) | Research follow-up: compute from downloaded metadata |
| Does ODbL on MIMIC-IV-ECG propagate to trained weights? | Lawyer, or avoid training on it |
| de Chazal split definition and AAMI mapping details | Research follow-up: read the paper |
| Does the ministry or hospital hold digitised or paper ECG archives in Kyrgyzstan, and would they share them? | **Author** (access to MoH contacts) |
| STEMI/OMI definitions and acceptable label mapping from PTB-XL/ACS-ECG | **Cardiologist**, after the POC |
| Which ECG devices and paper formats are used in FAPs/CFMs? | **Author** |

## Sources (accessed 2026-10-29)

- PTB-XL v1.0.3 — https://physionet.org/content/ptb-xl/1.0.3/ and licence https://physionet.org/content/ptb-xl/view-license/1.0.3/ (read)
- PTB-XL+ v1.0.1 — https://physionet.org/content/ptb-xl-plus/1.0.1/ (read)
- MIT-BIH Arrhythmia Database — https://physionet.org/content/mitdb/1.0.0/ and https://physionet.org/content/mitdb/view-license/1.0.0/ (read)
- MIMIC-IV-ECG — https://physionet.org/content/mimic-iv-ecg/1.0/ and https://physionet.org/content/mimic-iv-ecg/view-license/1.0/ (read)
- PhysioNet/CinC Challenge 2021 — https://physionet.org/content/challenge-2021/1.0.3/ and licence https://physionet.org/content/challenge-2021/view-license/1.0.3/ (read)
- Chapman-Shaoxing/Ningbo — https://physionet.org/content/ecg-arrhythmia/1.0.0/ and licence https://physionet.org/content/ecg-arrhythmia/view-license/1.0.0/ (read)
- Shandong Provincial Hospital database — https://pmc.ncbi.nlm.nih.gov/articles/PMC9174207/ (read)
- ECG-Image-Database — https://arxiv.org/html/2409.16612 ; https://pmc.ncbi.nlm.nih.gov/articles/PMC11469442/ (read)
- PM-ECG-ID — https://zenodo.org/records/13617673 (read)
- PhysioNet Challenge 2024 — https://moody-challenge.physionet.org/2024/ ; https://doi.org/10.22489/cinc.2024.011 (search snippets only)
- CODE-15% — https://zenodo.org/records/4916206 (search result only)
- SaMi-Trop — https://zenodo.org/records/4905618 (search result only)
- Icentia11k — https://physionet.org/content/icentia11k-continuous-ecg/ (search snippets only)
- HEEDB — https://www.bdsp.io/content/heedb/5.0/ ; https://www.nature.com/articles/s41597-026-06861-9 (search summaries only)
- CU DB — https://physionet.org/content/cudb/1.0.0/ ; MIT-BIH Malignant Ventricular Ectopy — https://physionet.org/content/vfdb/1.0.0/ (search snippets)
- Long-Term AF DB — https://physionet.org/content/ltafdb/1.0.0/ (page fetched, but the extract was only citations; facts from memory)
- PTB Diagnostic — https://physionet.org/content/ptbdb/1.0.0/ (fetched, extract only citations; facts from memory)
- INCART — https://archive.physionet.org/physiobank/database/incartdb/ (search snippet)
- LUDB — https://physionet.org/content/ludb/1.0.1/ (search snippet)
- ACS-ECG — https://huggingface.co/datasets/Emulated-Inc/sci-omi-from-ecg ; https://github.com/aaekay/ecg-datasets (secondary)
- Mendeley ECG images (Pakistan) — https://data.mendeley.com/datasets/gwbz3fsgp8/2 (search summary)
- Community catalogues — https://github.com/vlbthambawita/ECGDatasets ; https://github.com/aaekay/ecg-datasets (discovery only)
- Open-ECG-Digitizer — https://github.com/Ahus-AIM/Open-ECG-Digitizer (search snippet)
- Rejected/deprioritised: sota2.com benchmark listing (used only for Emory paper ECG existence), aggregator "ecgbench" pages (secondary).
