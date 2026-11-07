# 15 - Photo ECG datasets and what Open-ECG-Digitizer was trained on

Date accessed for all sources: 2026-11-07. No dataset, weights or third-party code was downloaded or run. Pages were read through a fetch tool that summarises them, so figures are copied from that extraction; spot-check anything that drives a decision. Status tags: **Verified** (read on a primary page or paper), **Partly verified** (secondary source, search snippet or summarised text), **Unverified**. Builds on [03-datasets.md](03-datasets.md), [04-digitisation.md](04-digitisation.md) and [09-dataset-followup.md](09-dataset-followup.md).

## Summary

- **Open-ECG-Digitizer was trained on synthetic images only** (8,658 images, rendered from CODE-15% signals with a modified ECG-Image-Kit, public on Hugging Face, Apache-2.0). No real phone photos were used for training. Training code (`src/train.py`) is released. Verified.
- **Its phone-photo evaluation set (Ahus, 1,596 images of 266 ECGs, iPhone and OnePlus) is NOT public** ("upon reasonable request"). The only public photo test material it used is the Emory/PhysioNet Challenge 2024 hidden set, which is also not freely downloadable. Verified.
- **Public data with real photos AND a true signal is small:** PM-ECG-ID (100 PTB-XL waveforms, GPL-3.0-or-later) and ECG-Image-Database (phone photos of printouts, signal included, licence not found). The Pakistan Mendeley set has real-looking images with diagnosis labels but no signal and an unclear capture method.
- Recommendation: public sets for **evaluation only**; fine-tune on our own 100-300 photos plus synthetic images (section 4).

## 1. Open-ECG-Digitizer

Repo: [Ahus-AIM/Open-ECG-Digitizer](https://github.com/Ahus-AIM/Open-ECG-Digitizer) (pinned commit 97a15087 in this project). Paper: [arXiv 2510.19590](https://arxiv.org/abs/2510.19590), [npj Digital Medicine 2026](https://doi.org/10.1038/s41746-025-02327-1), full text via [PMC12891466](https://pmc.ncbi.nlm.nih.gov/articles/PMC12891466/).

| Question | Finding | Status |
|---|---|---|
| Training images | Synthetic. Signals from CODE-15%, rendered with a modified ECG-Image-Kit (random line widths, colours, text overlays, perspective transforms, real photo backgrounds). Layout 3x4 plus lead II rhythm strip. 8,658 images with segmentation labels and ground-truth signals | Verified (PMC full text); the 8,658 figure also in arXiv search snippet |
| Real or phone photos in training | No evidence of any. README is silent; paper says synthetic only | Verified (paper), Partly verified (README silent) |
| Training data public? | Yes: [Open-ECG-Digitizer-Development-Dataset](https://huggingface.co/datasets/Ahus-AIM/Open-ECG-Digitizer-Development-Dataset), about 75 GB, **Apache-2.0**, "generated using this fork of ECG-Image-Kit". The card does not list sample counts or label format | Verified |
| Evaluation sets | (a) **Ahus**: 1,596 images of 266 ECGs/266 patients (thermal paper, 50 mm/s), each ECG printed on two sheets, captured with flatbed scanner, iPhone and OnePlus, paired with raw time series. (b) **Emory**: 35,595 images (colour/B&W scans, mobile photos, stained/degraded), the hidden test set of the PhysioNet Challenge 2024; zero-shot | Verified (PMC full text) |
| Reported SNR | Ahus: 19.65 dB scans, 12.19 dB OnePlus photos, 10.47 dB iPhone photos. Emory best 7.34 dB (colour scans). Model fails to digitise about 0.21% of samples (set to NaN) | Verified (SNR, PMC); 0.21% Partly verified (snippet) |
| Is the photo evaluation set public? | **Ahus: no**, "available upon reasonable request". The text also says release together with the ECG-Image-Database is planned, no date. The Results section says "open source", which contradicts the availability statement; treat the statement as authoritative. No licence stated | Verified (text), conflict noted |
| Training code | Yes. `src/train.py`, run `python3 -m src.train` after editing `src/config/unet.yml` (`data_path` for TRAIN/VAL/TEST); on-the-fly transforms in `src/transform/vision.py` can be changed to mimic own data. Weights in `weights/` via git-lfs | Verified ([README](https://github.com/Ahus-AIM/Open-ECG-Digitizer/blob/97a15087/README.md)) |
| Licence of code and weights | CC BY-SA 4.0 per [04-digitisation.md](04-digitisation.md); the README text fetched here showed no licence section, so re-check the LICENSE file at the pinned commit | Partly verified |

Takeaway: the model never saw a real photo during training and still reaches 10-12 dB on phone photos, so the synthetic-plus-augmentation route works, and our own print-and-photograph set would be a genuine extension (see Demolder et al., cited by the paper as printing and photographing ECGs, [Partly verified, via search summary]).

## 2. Public datasets with photos or camera images

| Dataset | Size | What is real / labelled | Licence | Commercial or derived use | Patient-data risk |
|---|---|---|---|---|---|
| **PhysioNet Challenge 2024** ([site](https://moody-challenge.physionet.org/2024/)) | Training images are generated from PTB-XL signals; hidden validation/test sets have "actual scans or photographs of paper ECGs" | Training: images plus signal and 11 classes (NORM, Acute MI, Old MI, STTC, CD, HYP, PAC, PVC, AFIB/AFL, TACHY, BRADY; PTB-XL labels, MI split with PTB-XL+ 12SL). Test: no signal, no labels, headers partial; scored once via submission, not downloadable. Augmentation by ECG-Image-Kit: shift, rotate, creases, fonts | Website CC BY 4.0; data terms not read | Test set unavailable, so only the generated training data is usable | Training: none (PTB-XL). Test: hidden |
| **ECG-Image-Database** (Reyna et al., [arXiv 2409.16612](https://arxiv.org/html/2409.16612v1)) | 35,595 images from 1,977 records (977 PTB-XL + 1,000 Emory) in the preprint; the journal version is larger (37,191 images, 2,243 records) per [03](03-datasets.md) | Printed (LaserJet 600 dpi) then scanned, or photographed with Galaxy S20 FE, iPhone 11/12/13 Mini, S10+, S22 Ultra, some screen photos; soaked/stained (water, coffee, soy sauce) and mouldy copies. Ground-truth time series for every image; Emory labels regenerated with GE 12SL. No per-variant counts given in the preprint | **No dataset licence found** (the arXiv notice covers the paper only); hosted on Kaggle per [09](09-dataset-followup.md) | Unresolved, treat as evaluation only | Emory data under Emory IRB STUDY-00007353; images are rendered, but real-patient waveforms. Low-moderate |
| **PM-ECG-ID** ([Zenodo 13617673](https://zenodo.org/records/13617673)) | 100 PTB-XL waveforms expanded to 6,000 image entries, 33.9 GB | Real phone photos of printouts, scans and photos of screens, plus digital augmentation (contrast, perspective, blur, JPEG...) and simulated bends/crumples. `leads.npz` and `rhythms.npz` hold the true signal; `metadata.csv` maps to the PTB-XL ID. No diagnosis label of its own | **GPL-3.0-or-later** | Open question whether GPL reaches trained weights; keep evaluation only | None beyond PTB-XL (public, de-identified) |
| **ECG Images dataset of Cardiac Patients** (Pakistan; [Mendeley gwbz3fsgp8](https://data.mendeley.com/datasets/gwbz3fsgp8/2), [Data in Brief article, PMC7820911](https://pmc.ncbi.nlm.nih.gov/articles/PMC7820911/)) | 1,937 patient records (v1 includes COVID-19: 250; Normal 859; MI 77; history of MI 203; abnormal heartbeat 548); v2 title drops COVID-19, per-version counts not confirmed | 12-lead images from EDAN SERIES-3 devices (Multan, Lahore); one diagnosis class per image assigned by hospital unit and reviewed by clinicians. **No signal files.** The pages do not say whether images are scans or camera photos, so it may not be photo data at all | CC BY 4.0 (v2 Mendeley page; article CC BY) | CC BY allows reuse with attribution, but labels are coarse and consent is not described | Article says images were anonymised, protocol approved by a Medical Superintendent order; consent not described. Moderate |
| **PTB-XL-Image-17K** ([arXiv 2602.07446](https://arxiv.org/abs/2602.07446)) | 17,271 images | Synthetic renderings, not photos. Pixel masks, signals, lead boxes | Not stated on the page read | Unknown | None |
| **GenECG** ([PubMed 40451261](https://pubmed.ncbi.nlm.nih.gov/40451261/), BMJ Health Care Inform. 2025) | Not stated | Synthetic images from PTB-XL with imperfection effects; photos of paper not confirmed | Not stated | Unknown | None |

Status: Challenge 2024 page, PM-ECG-ID, ECG-Image-Database capture details and Pakistan article read directly = Verified. ECG-Image-Database licence = Unverified (not found). Journal-version size, PTB-XL-Image-17K licence and GenECG details = Partly verified/Unverified (snippets only). Neither Mendeley page states how the Pakistan images were captured; do not assume phone photos.

Not found: any public dataset of genuine clinical phone photos with the true signal, other than the above. Searches for "photographed ECG" datasets returned only these sets. Unverified that none others exist (Kaggle and Figshare were not searched exhaustively).

## 3. Licence and clinical-safety notes

- GPL-3.0 (PM-ECG-ID) and the unknown ECG-Image-Database licence are reasons to keep both out of any training pipeline whose weights we ship. Keeping them in `data/` for scoring only is safe.
- CC BY-SA 4.0 on Open-ECG-Digitizer weights would pass share-alike to fine-tuned derivatives; see [04-digitisation.md](04-digitisation.md). Training on the Apache-2.0 synthetic set does not change that.
- Pakistan set labels are hospital-unit labels, not cardiologist-verified diagnoses; use only for image-type robustness, never for clinical claims.

## 4. Recommendation

**(a) Evaluation only**
1. **PM-ECG-ID**: best fit; real phone photos with true signal and PTB-XL IDs, so SNR can be computed. Exclude our own PTB-XL training IDs from fine-tuning to avoid leakage.
2. **ECG-Image-Database** (phone-photo and degraded subsets): if the Kaggle terms allow, use as an external digitisation benchmark, matching how Open-ECG-Digitizer reports on Emory. Check the licence field in a browser first.
3. **Pakistan Mendeley set**: robustness smoke test (does the digitiser return plausible leads on real device printouts?) and a rough diagnosis-class sanity check; no ground-truth signal.
4. **LITFL images**: evaluation only, as already decided.
5. **Open-ECG-Digitizer Ahus set**: ask the corresponding author (Stenhede) for access only if a comparison with the published 10-12 dB phone numbers is needed.

**(b) Fine-tuning**
1. **Synthetic**: the Apache-2.0 Open-ECG-Digitizer development set and our own ECG-Image-Kit renders from PTB-XL are the safe bulk training data.
2. **Our own 100-300 printed-and-photographed PTB-XL pages**: the best real-photo fine-tuning source (we own it, true signal known). Split by PTB-XL record (not by photo): about 70% train, 30% test, so the test set is never in fine-tuning. Vary phone, light, bends and angle. Because this is a few hundred images, prefer light fine-tuning of the segmentation U-Net via `src/train.py` with changed transforms, and freeze most layers; this is a plan, not a tested result.
3. Do **not** fine-tune on PM-ECG-ID, ECG-Image-Database or LITFL until licences are settled.
4. Keep every real photo (ours or public) in `data/` or `temp/`, never in git.

## Open points

| Open point | Next step |
|---|---|
| ECG-Image-Database dataset licence and Kaggle terms | Read the Kaggle licence field in a browser |
| How the Pakistan images were captured, per-version counts | Download metadata only after approval, or read the Data in Brief article's methods in full |
| Open-ECG-Digitizer LICENSE file at the pinned commit | Read the file in the repo |
| Whether GPL-3.0 on PM-ECG-ID reaches trained weights | Lawyer, or stay evaluation-only |

## Sources

- Open-ECG-Digitizer repo: https://github.com/Ahus-AIM/Open-ECG-Digitizer ; README at pinned commit: https://github.com/Ahus-AIM/Open-ECG-Digitizer/blob/97a15087/README.md
- Paper: https://arxiv.org/abs/2510.19590 ; https://doi.org/10.1038/s41746-025-02327-1 ; https://pmc.ncbi.nlm.nih.gov/articles/PMC12891466/
- Training set card: https://huggingface.co/datasets/Ahus-AIM/Open-ECG-Digitizer-Development-Dataset
- PhysioNet Challenge 2024: https://moody-challenge.physionet.org/2024/
- ECG-Image-Database: https://arxiv.org/html/2409.16612v1
- PM-ECG-ID: https://zenodo.org/records/13617673
- Pakistan set: https://data.mendeley.com/datasets/gwbz3fsgp8/2 ; https://pmc.ncbi.nlm.nih.gov/articles/PMC7820911/
- PTB-XL-Image-17K: https://arxiv.org/abs/2602.07446
- GenECG: https://pubmed.ncbi.nlm.nih.gov/40451261/
