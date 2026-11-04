# 09 — Dataset follow-up: per-class counts and image-dataset licences

Date accessed for all sources: 2026-11-04. Follows up the open questions in [03-datasets.md](03-datasets.md). Status tags: **[V]** verified on a primary page/paper, **[P]** partly verified (secondary, truncated or machine-extracted text), **[U]** unverified.

Method note: no dataset was downloaded. Pages were read through a fetch tool that summarises the page, so numbers are copied from that extraction, not from my own reading of raw HTML. Spot-check anything that will drive a design decision.

## Summary

- **PTB-XL has very few examples of the urgent classes.** AFIB 1,514, AFLT 73, 3AVB 16, 2AVB 14, no VT/VF and no STEMI label (only 28 records of "non-specific ST elevation"). MI is large (5,469 records in the superclass) but is not "STEMI". [V/P]
- **CinC 2021 adds a lot for AF/flutter but little for VT/VF/complete heart block/STEMI.** Training-set totals in the official label tables: AF 5,255; flutter 8,374 (7,615 of them from Ningbo); VT 12; VF 97; complete heart block 127; ST elevation 628; "acute myocardial infarction" 55; MI 6,144. [P]
- **Licences (corrected):** PM-ECG-ID is **GPL-3.0-or-later** (Zenodo). ACS-ECG is **CC0 1.0** on the figshare record, which resolves the earlier CC BY vs CC0 conflict. ECG-Image-Database: **no dataset licence found**. [V/P/U, see section 2]

## 1. Per-class record counts

### 1.1 PTB-XL

The v1.0.3 page gives only the superclass counts (NORM 9,514; MI 5,469; STTC 5,235; CD 4,898; HYP 2,649; sum exceeds records because of multi-label). [V] ([PTB-XL v1.0.3](https://physionet.org/content/ptb-xl/1.0.3/)). It lists no per-statement counts. [V]

Per-statement counts come from the dataset paper's tables 6-8 ([Wagner et al. 2020, Sci Data, PMC7248071](https://pmc.ncbi.nlm.nih.gov/articles/PMC7248071/), read via [Europe PMC full text](https://www.ebi.ac.uk/europepmc/webservices/rest/PMC7248071/fullTextXML)). Caveat: these describe the **initial release (21,837 records)**; v1.0.3 has 21,799 (36 duplicates removed in v1.0.2, plus 2 more, see 03-datasets.md section 1.1), so counts may differ by a small amount. [P] The CinC 2021 table below shows the same PTB-XL values for AF (1,514), flutter-adjacent, CRBBB (542), LBBB (536), 1AVB (797), which supports consistency. [P]

For exact v1.0.3 counts, compute from `ptbxl_database.csv` / `scp_statements.csv` after download (both described on the [v1.0.3 page](https://physionet.org/content/ptb-xl/1.0.3/)). [U for exact v1.0.3 numbers]

| Class of interest | SCP statement(s) | Records (paper, 21,837 release) |
|---|---|---|
| Atrial fibrillation | AFIB | 1,514 |
| Atrial flutter | AFLT | 73 |
| Supraventricular tachycardia | SVTAC 27; PSVT 24 | 27 + 24 |
| Sinus tachycardia | STACH | 826 |
| Sinus bradycardia | SBRAD | 637 |
| Other rhythms (context) | SR 16,782; SARRH 772; PACE 296; SVARR 157; BIGU 82; TRIGU 20 | as listed |
| LBBB | CLBBB 536; ILBBB 77 | 536 / 77 |
| RBBB | CRBBB 542; IRBBB 1,118 | 542 / 1,118 |
| AV block | 1st degree (AVB) 797; 2AVB 14; 3AVB 16 | 797 / 14 / 16 |
| Other conduction | LAFB 1,626; IVCD 789; LPFB 177; WPW 80 | as listed |
| MI (superclass) | 5,469 (v1.0.3 page) | 5,469 |
| MI by location | IMI 2,685; ASMI 2,363; ILMI 479; AMI 354; ALMI 290; LMI 201; IPLMI 51; IPMI 33; PMI 17 | as listed |
| Subendocardial injury | INJAS 215; INJAL 148; INJIN 18; INJLA 17; INJIL 15 | as listed |
| ST elevation | STE_ ("non-specific ST elevation", form statement) | 28 |
| VT / VF | none among the 71 statements (rhythm list has 12, none ventricular tachyarrhythmia) | 0 |
| STEMI | no statement | n/a |

Notes: [P]
- The paper's tables show the "first degree AV block" statement as `AVB`, not `1AVB`.
- Multi-label: counts overlap; do not sum them.
- Per-record label depth (rhythm: 771 records with 0 rhythm statements, 20,923 with 1, 142 with 2) is in Table I of the [benchmark paper (Strodthoff et al.)](https://ar5iv.labs.arxiv.org/html/2004.13701). [P]
- MI statements here are cardiologist-labelled MI patterns (age not distinguished); they are **not** a STEMI/NSTEMI/OMI split. Treat as [inference].

### 1.2 PhysioNet/CinC Challenge 2021

The challenge page ([v1.0.3](https://physionet.org/content/challenge-2021/1.0.3/)) gives only per-source recording totals and points to the official label mapping tables. Per-class counts below are from the official evaluation repository tables [dx_mapping_scored.csv](https://raw.githubusercontent.com/physionetchallenges/evaluation-2021/main/dx_mapping_scored.csv) and [dx_mapping_unscored.csv](https://raw.githubusercontent.com/physionetchallenges/evaluation-2021/main/dx_mapping_unscored.csv). [P: machine-extracted CSV text, not independently recomputed from the data. These are counts of the *public training* recordings. A record can carry several labels.]

Source columns: CPSC, CPSC_Extra (CPSC-E), StPetersburg/INCART (StP), PTB, PTB-XL, Georgia (Geo), Chapman-Shaoxing (Chap), Ningbo (Nb).

| Class (SNOMED CT) | CPSC | CPSC-E | StP | PTB | PTB-XL | Geo | Chap | Nb | **Total** | Table |
|---|---|---|---|---|---|---|---|---|---|---|
| Atrial fibrillation (164889003) | 1,221 | 153 | 2 | 15 | 1,514 | 570 | 1,780 | 0 | **5,255** | scored |
| Atrial flutter (164890007) | 0 | 54 | 0 | 1 | 73 | 186 | 445 | 7,615 | **8,374** | scored |
| AF and flutter combined label (195080001) | 0 | 39 | 0 | 0 | 0 | 2 | 0 | 0 | 41 | unscored |
| Ventricular tachycardia (164895002) | 0 | 1 | 1 | 10 | 0 | 0 | 0 | 0 | **12** | unscored |
| Ventricular fibrillation (164896001) | 0 | 10 | 0 | 25 | 0 | 3 | 0 | 59 | **97** | unscored |
| Complete heart block (27885002; = AV block III) | 0 | 27 | 0 | 0 | 16 | 8 | 1 | 75 | **127** | unscored |
| 2nd degree AV block (195042002) | 0 | 21 | 0 | 0 | 14 | 23 | 8 | 58 | 124 | unscored |
| 1st degree AV block (270492004) | 722 | 106 | 0 | 0 | 797 | 769 | 247 | 893 | 3,534 | scored |
| ST elevation (164931005) | 220 | 66 | 4 | 0 | 28 | 134 | 176 | 0 | **628** | unscored |
| Acute myocardial infarction (57054005) | 0 | 0 | 6 | 0 | 0 | 0 | 0 | 49 | **55** | unscored |
| Myocardial infarction (164865005) | 0 | 376 | 9 | 368 | 5,261 | 7 | 40 | 83 | 6,144 | unscored |
| Left bundle branch block (164909002 + 733534002 scored as one) | 236 | 38 | 0 | 0 | 536 | 231 | 205 | 35 (+213 CLBBB code) | 1,281 + 213 | scored |
| Complete RBBB (713427006) / RBBB (59118001), scored as one | 1,857 (RBBB) | 113 / 1 | 0 / 2 | 0 | 542 (CRBBB) | 28 / 542 | 0 / 454 | 1,096 / 195 | 1,779 + 3,051 | scored |
| Sinus bradycardia (426177001) | 0 | 45 | 0 | 0 | 637 | 1,677 | 3,889 | 12,670 | 18,918 | scored |
| Sinus tachycardia (427084000) | 0 | 303 | 11 | 1 | 826 | 1,261 | 1,568 | 5,687 | 9,657 | scored |
| Bradycardia, unspecified (426627000) | 0 | 271 | 11 | 0 | 0 | 6 | 0 | 7 | 295 | scored |

Reading the table: [inference]
- **AF**: plentiful (5k+) with several independent sources, so leave-one-source-out testing is feasible. Ningbo has no AF label, so do not treat Ningbo as AF-negative for that class.
- **Flutter**: 91% of the 8,374 comes from Ningbo, so flutter is effectively a single-source label; expect source confounding.
- **VT**: 12 records overall (10 from the PTB set, 1 CPSC-Extra, 1 St Petersburg); not trainable as a 12-lead class. **VF**: 97, mostly Ningbo (59) and PTB (25); treat with caution (label semantics in some sources unclear). Both are unscored classes in the Challenge.
- **AV block III**: 127 "complete heart block" records (75 Ningbo). Small but not negligible; `3AVB` in PTB-XL is only 16.
- **STEMI**: no STEMI code exists in these tables. The nearest are "ST elevation" (628, a finding, not a diagnosis) and "acute myocardial infarction" (55). Do not map either to STEMI without cardiologist input.
- Ventricular tachyarrhythmia and STEMI therefore need other sources (ACS-ECG, MIMIC-IV-ECG report text, rule-based detectors), as already concluded in 03-datasets.md section 4.

Gap: the Challenge hidden validation/test sets have different distributions and are not counted here; the Google Sheet of label mappings linked on the [challenge page](https://physionet.org/content/challenge-2021/1.0.3/) was not read. [U]

## 2. Licences and redistribution terms

### 2.1 PM-ECG-ID (PMcardio) [V]

- Zenodo record: [10.5281/zenodo.13617673](https://zenodo.org/records/13617673), v1, published 2024-08-30, access "Open", single file `pmcardio_ecg_image_database.zip` (33,863,935,685 bytes). Creators from Powerful Medical (Iring, Kresnakova, Hojcka, Boza, Rafajdus, Vavrik).
- **Licence: GNU General Public License v3.0 or later** (`gpl-3.0-or-later`), per the record page and the Zenodo API ([API record](https://zenodo.org/api/records/13617673)). The record has no separate rights field.
- Terms (GPL-3.0 summary as shown on the Zenodo page): strong copyleft; complete source must be made available for licensed works and modifications; copyright/licence notices preserved; contributors grant patent rights. Commercial use is not prohibited by the GPL itself, but copyleft attaches to distributed copies and modified versions. Full text: https://www.gnu.org/licenses/gpl-3.0.html [text itself not read]
- Practical flags [inference, not legal advice]:
  1. The GPL is an unusual licence for a *data* set. Whether GPL copyleft reaches **model weights** trained on it, or only the data/derived images, is untested; ask a lawyer before using it for training. The safe use is **evaluation only**, with no redistribution in git (matches AGENTS.md: datasets stay in git-ignored `data/`).
  2. The images are derived from 100 PTB-XL waveforms (CC BY 4.0). The two licences are layered on the same content; the dataset authors' GPL grant over PTB-XL-derived material is questionable but not our problem if we only evaluate. [U]
  3. Apache-2.0 repo code can call it, but do not copy dataset files or derived images into the repo.

### 2.2 ACS-ECG (Du et al., 2026) [V for licence; P for the rest]

- Primary record: figshare dataset [10.6084/m9.figshare.29925314.v1](https://doi.org/10.6084/m9.figshare.29925314.v1), posted 2026-07-09. Companion article: *Scientific Data*, [10.1038/s41597-026-07278-0](https://doi.org/10.1038/s41597-026-07278-0) (article page not readable by my tool; the paper's own data-availability text is **not read** [U]).
- **Licence: CC0 (public domain dedication, `creativecommons.org/publicdomain/zero/1.0/`)** per the figshare API ([API record](https://api.figshare.com/v2/articles/29925314)). This agrees with the Hugging Face repack ([Emulated-Inc/sci-omi-from-ecg](https://huggingface.co/datasets/Emulated-Inc/sci-omi-from-ecg), CC0 1.0). The "CC BY 4.0" in the earlier aggregator listing (03-datasets.md) is therefore probably wrong. [P: the article's licence statement was not read]
- Content (API description): 19,955 ten-second 12-lead ECGs at 500 Hz from 18,909 patients, all with digital subtraction angiography; labels STEMI, NSTEMI, unstable angina, OMI, infarct location; two physician benchmarks; open-source baseline OMI model released. Files: CSV.zip (0.3 MB), ECG_median_data.zip (140 MB), ECG_row_data.zip (1.28 GB). [P]
- Per-class counts (STEMI, NSTEMI, OMI): **not found** in what I could read [U]. The HF repack lists labels OMI, STEMI, CTO and `minutes_to_angiography` for a 12,569-ECG / 11,906-patient subset (patients with md5(id) mod 10 >= 3). [P]
- Terms in practice: CC0 allows copying, modification, redistribution and commercial use with no conditions or attribution. Cite the paper anyway as good practice. Hospital/country and ethics/consent statement not seen [U], so confirm there is no use restriction in the article before training or publishing weights. Patient-data rule in AGENTS.md still applies (keep the data out of git).

### 2.3 ECG-Image-Database (Reyna et al.) [partly verified; licence NOT found]

- Preprint [arXiv 2409.16612](https://arxiv.org/html/2409.16612): says the data are open access but names **no dataset licence** and no host. [V]
- Journal version: *Physiological Measurement*, [10.1088/1361-6579/ae85b2](https://iopscience.iop.org/article/10.1088/1361-6579/ae85b2) (also [PMC13402943](https://pmc.ncbi.nlm.nih.gov/articles/PMC13402943/), [PubMed 42504433](https://pubmed.ncbi.nlm.nih.gov/42504433/)). Read through [Europe PMC](https://www.ebi.ac.uk/europepmc/webservices/rest/PMC13402943/fullTextXML) and the IOP page. [P: long pages, parts unread]
  - Data availability statement: hosted on **Kaggle** at https://www.kaggle.com/datasets/physionet/ecg-image-database/ , "Data will be available from 01 August 2026". There is no PhysioNet page: the PhysioNet URL I tried returned 404. [V]
  - The article itself is CC BY 4.0; that covers the paper only. **No licence for the dataset was stated** in the parts I read. The Kaggle page text I received did not show its licence field. [U]
  - Larger than the preprint: 37,191 images from 2,243 records across three countries: PTB-XL + Emory 35,595 images, Akershus University Hospital (Norway) 1,596 images from 266 patients (identifiers manually redacted). The earlier "977 PTB-XL + 1,000 Emory" figure is the preprint. [P]
  - PTB-XL part: acknowledgments thank Dr Tobias Schaeffter "for permitting the redistribution of the PTB-XL records used for this study under the CC BY 4.0 license". [P]
  - Emory part: from the Harvard-Emory ECG Database; Emory IRB approval with consent waiver; released data described as de-identified, "for research and benchmarking". No separate data-use terms seen. Note: the parent HEEDB is *credentialed* (03-datasets.md), so redistribution rights for the Emory subset need explicit confirmation. [P/U]
  - Ahus (Norway) part: approved by the Norwegian Directorate of Health; no licence text seen. [P]
- Companion generator: ECG-Image-Kit is open source (BSD-3-Clause per 03-datasets.md; licence file not re-read). [U]
- **Conclusion:** commercial/redistribution terms are **unknown**. Until the Kaggle licence field is read, treat as research/evaluation-only, do not redistribute, and do not train released weights on the Emory/Ahus parts. The PTB-XL-derived images are CC BY 4.0 per the acknowledgment, but that permission statement is not itself a licence file. [inference]

## 3. Impact on the plan

1. PTB-XL alone cannot train AV block III (16), 2AVB (14), flutter (73) or VT/VF/STEMI. Pool CinC 2021 sources for AF, flutter, AV block; keep VT/VF/AV-III as rule-based plus "refer urgently" paths (consistent with 03-datasets.md section 4).
2. Update 03-datasets.md: ACS-ECG licence is CC0 (figshare); PM-ECG-ID is GPL-3.0-or-later; ECG-Image-Database host is Kaggle (from 2026-08-01), licence unresolved. (Not edited here, per task scope.)
3. Use PM-ECG-ID and ECG-Image-Database for **evaluation only** until licence/legal questions are settled.

## Open items

| Item | Action |
|---|---|
| Exact PTB-XL v1.0.3 per-statement counts | Compute from `ptbxl_database.csv` after download (script, not committed data) |
| Recompute CinC 2021 counts from `.hea` files and check the Google Sheet mapping | Script after download; the CSV extraction above is machine-read |
| ACS-ECG class counts, hospital, data-availability/ethics text | Read the Sci Data article in a browser |
| ECG-Image-Database licence | Open the Kaggle page in a browser (licence field and "Data Card") |
| Does GPL-3.0 on PM-ECG-ID reach trained weights? | Lawyer, or evaluation-only |

## Sources (accessed 2026-11-04)

- PTB-XL v1.0.3 — https://physionet.org/content/ptb-xl/1.0.3/ (read)
- PTB-XL paper tables 6-8 — https://pmc.ncbi.nlm.nih.gov/articles/PMC7248071/ via https://www.ebi.ac.uk/europepmc/webservices/rest/PMC7248071/fullTextXML (read, machine-extracted)
- PTB-XL benchmark paper Table I — https://ar5iv.labs.arxiv.org/html/2004.13701 (read)
- CinC 2021 page — https://physionet.org/content/challenge-2021/1.0.3/ (read)
- CinC 2021 label tables — https://raw.githubusercontent.com/physionetchallenges/evaluation-2021/main/dx_mapping_scored.csv ; https://raw.githubusercontent.com/physionetchallenges/evaluation-2021/main/dx_mapping_unscored.csv (read, machine-extracted)
- PM-ECG-ID — https://zenodo.org/records/13617673 ; https://zenodo.org/api/records/13617673 (read)
- ACS-ECG — https://api.figshare.com/v2/articles/29925314 ; https://doi.org/10.6084/m9.figshare.29925314.v1 (redirect; figshare web page returned 403) ; https://huggingface.co/datasets/Emulated-Inc/sci-omi-from-ecg ; https://doi.org/10.1038/s41597-026-07278-0 (not readable)
- ECG-Image-Database — https://arxiv.org/html/2409.16612 ; https://iopscience.iop.org/article/10.1088/1361-6579/ae85b2 ; https://pmc.ncbi.nlm.nih.gov/articles/PMC13402943/ (via Europe PMC) ; https://www.kaggle.com/datasets/physionet/ecg-image-database/ (licence not visible)
