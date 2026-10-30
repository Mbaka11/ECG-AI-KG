# 05 – ECG classification: state of the art and on-device deployment

Research date: 2026-10-29. Scope: signal-level classification, foundation models, interval measurement, robustness, mobile inference, uncertainty.

**Method and limits.** Evidence labels: **Verified** = I read the primary page or a tool-returned excerpt of it. **Partly verified** = seen only in a search-result excerpt or a secondary summary. **Unverified** = from general knowledge, not checked. Several primary pages (PMC, Nature) could not be fetched (JavaScript-rendered), so many numbers rest on search excerpts. I did **not** re-read `docs/spec/en/ECG-AI_KG_TS_EN.md` or `docs/PLAN.md` in this run. The "98–99.4 %" claim is taken from the task brief. Check the exact wording against the spec before quoting it.

## Summary

- A "98–99.4 % accuracy on MIT-BIH" figure is **not interpretable** for unseen patients. It usually comes from random beat-level (intra-patient) splits, and accuracy is dominated by normal beats. Partly verified.
- The honest baseline is inter-patient evaluation (de Chazal 2004 DS1/DS2). There the 2004 benchmark reached only ~76 % sensitivity / 38.5 % PPV for supraventricular beats and ~78 % / 82 % for ventricular beats. Modern deep models are better, but I found no verified modern inter-patient table in this pass.
- MIT-BIH is the wrong dataset for this product. It is 2-lead Holter beat classification (48 recordings, 1970s). Our task is 12-lead (or 3×4 segment) rhythm and diagnostic classification from a paper strip. The right public datasets are PTB-XL, the PhysioNet/CinC 2020/2021 collections and the 2024 ECG-image data.
- On PTB-XL, a plain ResNet/Inception 1D CNN already gives macro-AUROC ≈0.93 (superdiagnostic) and ≈0.96 (rhythm). Verified from the abstract-level summary. Big foundation models give modest gains in independent benchmarks.
- STEMI-criteria-based detection misses many occlusion MIs. ML OMI models improve on it (Al-Zaiti 2023 AUROC 0.91 internal test), but real-world unselected-ED sensitivity is still modest (Queen of Hearts: 52 % sens / 99 % spec). The ACS/STEMI class is the hardest and most safety-relevant one.
- Permissive foundation-model weights exist: ECGFounder (MIT) and ECG-FM (MIT). HuBERT-ECG is CC BY-NC, and ECG-JEPA weight licence is unclear. Read the licence of each checkpoint, and of the training data, before shipping.
- TensorFlow Lite is now **LiteRT**. Small 1D CNNs fit in 1–5 MB int8 and run in tens of ms on phones, so on-device inference is not the bottleneck. **Photo digitisation** is the real risk.
- Uncertainty, selective prediction and an "I can't read this" path are mandatory for a triage tool. Evidence exists for MC-dropout/ensembles on ECG, but no off-the-shelf recipe.

## 1. Reality check on "98–99.4 % on MIT-BIH with CNN+BiLSTM"

**Facts**
- MIT-BIH: 48 half-hour two-lead recordings from 47 subjects, ~110,000 annotated beats, collected 1975–79. 25 recordings were deliberately chosen for rare arrhythmias, so it does not reflect population prevalence. Records 201 and 202 are the same subject. Verified (excerpt of [PhysioNet MIT-BIH](https://www.physionet.org/content/mitdb/1.0.0/mitdbdir/)).
- **AAMI EC57 classes:** N (normal/bundle-branch/escape), S (supraventricular ectopic, SVEB), V (ventricular ectopic, VEB), F (fusion), Q (paced/unknown). These are *beat* classes, not rhythm or diagnosis classes. Partly verified ([de Chazal 2004](https://pubmed.ncbi.nlm.nih.gov/15248536/)).
- **Intra-patient split:** beats from one record appear in both train and test. The network learns patient-specific morphology, which is leakage for new-patient use. **Inter-patient split (de Chazal):** 44 non-paced records divided into two disjoint sets of 22 (DS1 for training, DS2 for testing). Verified (PubMed abstract excerpt).
- de Chazal's independent-test results: SVEB sensitivity 75.9 %, PPV 38.5 %, FPR 4.7 %. VEB sensitivity 77.7 %, PPV 81.9 %, FPR 1.2 %. Partly verified ([PubMed](https://pubmed.ncbi.nlm.nih.gov/15248536/)).
- A 2026 systematic review of 122 ECG arrhythmia studies found 68 following AAMI guidance but only 37 using an inter-patient split. So "AAMI-compliant" does not mean "fair". Partly verified ([Res. Biomed. Eng. review](https://link.springer.com/article/10.1007/s42600-026-00485-z)).

**Why accuracy is misleading:** N beats are the large majority. A model that finds every N beat and misses most S beats still scores >90 %. For safety work report per-class sensitivity, specificity/PPV, F1 and confusion matrices, with per-patient confidence intervals. For prevalence-shifted deployment, report PPV at the expected prevalence.

**Realistic expectation (researcher inference).** Intra-patient 98–99 % is plausible and uninformative. Inter-patient results for S and V classes sit in a much lower band than the headline. I could not verify a specific modern inter-patient figure, so the doc should not promise one. Treat any number we publish as something we measure ourselves with patient-wise splits.

**Relevance:** beat-level MIT-BIH classification does not match the app's output classes. Use it at most as a pre-training or sanity-check dataset for beat/arrhythmia detection (e.g. VT/VF with the MIT-BIH Malignant Ventricular Ectopy and CU databases, unverified availability here).

## 2. 12-lead / multi-label benchmarks

| Source | Data and task | Headline result | Status |
|---|---|---|---|
| [Strodthoff et al. 2020, PTB-XL benchmark](https://arxiv.org/abs/2004.13701) | PTB-XL, 100 Hz, recommended patient-aware folds, 7 architectures | Macro-AUROC (best single model): all 71 statements 0.925; diagnostic 0.937; sub-diagnostic 0.930; superdiagnostic 0.930; form 0.899; rhythm 0.957. ResNet/Inception 1D CNNs strongest. | Partly verified (search summary of the arXiv abstract/results) |
| [Ribeiro et al. 2020, Nat Commun](https://www.nature.com/articles/s41467-020-15432-4) | CODE (Brazil, ~2 M ECGs), 6 abnormalities, 12-lead ResNet | Compared with cardiology and emergency residents and students. F1 > 80 % and specificity > 99 % are claimed in the paper (from memory). | Page found, numbers **Unverified** |
| [Hannun et al. 2019, Nat Med](https://pubmed.ncbi.nlm.nih.gov/30617320/) | Single-lead ambulatory patch ECG, 12 rhythm classes, 34-layer CNN | Cardiologist-level AUC/F1 on rhythm classes including AF, AV block, VT. | Partly verified (abstract excerpts); single-lead *patch* data, not paper photo |
| [PhysioNet/CinC 2021](https://moody-challenge.physionet.org/2021/results/) | 131,155 recordings, 2/3/4/6/12-lead subsets | ISIBrno-AIMT ranked first in every lead-count category (ensemble of residual CNNs with attention). | Verified (results table excerpt) |

**MI / STEMI / OMI specifically**
- STEMI criteria are insensitive for occlusion MI. In one 808-patient study, STEMI criteria had sensitivity 41 % and specificity 94 % for OMI, versus 86 % / 91 % for expert OMI-ECG reading. Partly verified ([PMC8065286](https://ncbi.nlm.nih.gov/pmc/articles/PMC8065286/)).
- Al-Zaiti et al. 2023 (Nat Med): random-forest OMI model on ECG features, hold-out AUROC 0.91 (95 % CI 0.87–0.96), outperforming clinicians and a commercial FDA-cleared "acute MI" algorithm. Label = angiographic culprit occlusion (TIMI 0–1, plus severe stenosis with high troponin). Partly verified ([Nat Med](https://www.nature.com/articles/s41591-023-02396-3), [PMC10353937](https://pmc.ncbi.nlm.nih.gov/articles/PMC10353937/)). The model uses 12-lead digital ECG features in a US ED cohort.
- Queen of Hearts (Powerful Medical / PMcardio): in 24,513 chest-pain presentations in five Swedish EDs, 52 % sensitivity / 99 % specificity for OMI, versus 26 % / 98 % for classic STEMI criteria. The source is a vendor page that summarises a study, so treat it as **Partly verified**. ([source](https://www.powerfulmedical.com/research/validation-of-an-artificial-intelligence-ecg-model-for-detection-of-acute-coronary-occlusion-myocardial-infarction-in-unselected-emergency-department-chest-pain-patients/)).
- **Key lesson:** the ground truth for ACS needs angiography/troponin, not only cardiologist ECG labels. PTB-XL's MI labels are ECG-based statements. Models trained on them learn "ECG looks like MI", which is what a feldsher can also read. It is not equal to "occluded artery now".

## 3. ECG foundation models (2023–2026)

| Model | Weights | Licence | Notes | Status |
|---|---|---|---|---|
| [ECGFounder](https://huggingface.co/PKUDigitalHealth/ECGFounder) (PKU; [NEJM AI](https://ai.nejm.org/doi/full/10.1056/AIx2500913)) | Yes (Hugging Face) | MIT (repo) | Trained on >10 M ECGs, ~150 diagnostic labels, 12-lead and single-lead variants. Published per-class AUROC/sens/spec tables. | Partly verified |
| [ECG-FM](https://huggingface.co/wanglab/ecg-fm/blame/main/README.md) ([JAMIA Open](https://academic.oup.com/jamiaopen/article/8/5/ooaf122/8287827)) | Yes | MIT | Fine-tuned AF AUROC 0.996, LVEF≤40 % 0.929 (paper). Loading needs the GitHub code (fairseq-signals). | Partly verified |
| [HuBERT-ECG](https://github.com/Edoar-do/HuBERT-ECG) | Yes | **CC BY-NC 4.0** | No commercial use. | Partly verified |
| [ECG-JEPA](https://github.com/sehunfromdaegu/ecg_jepa) | Yes (Drive links) | Code MIT; **weights licence not stated** | Ask authors before use. | Partly verified |
| MERL, ST-MEM, ECG-Chat, ECG-Byte | Not checked | Not checked | Not researched in this pass. | **Unverified** |

**Independent benchmark.** [Al-Masud, Lopez Alcaraz, Strodthoff (ICLR 2026): "Benchmarking ECG FMs: A Reality Check"](https://arxiv.org/abs/2509.25095) evaluated eight FMs on 26 tasks over 12 public datasets. The reported takeaway is that results are mixed: some FMs beat a supervised S4 baseline on some tasks, and ECG-FM ranked fourth overall. Partly verified (excerpts only). My inference: for a few coarse classes, a supervised CNN trained on public data is a strong baseline, and FMs help most with little labelled data or to extract embeddings.

**Practical issues (inference).** Almost all FMs expect clean 12-lead digital signals at 250–500 Hz and 10 s. Our digitised photo signal gives low-quality 2.5 s segments per lead. Transformer FMs of tens to hundreds of millions of parameters are heavy for offline phones. A distillation path (FM teacher, small CNN student) is more realistic than shipping the FM. Fine-tuning cost: not found. Typical fine-tuning on one GPU for PTB-XL-sized data is hours, not days (Unverified).

## 4. Heart rate and interval measurement

- **NeuroKit2** (`ecg_peaks`, `ecg_delineate` with DWT/CWT/peak methods): good for R-peak detection and HR. Delineation is weaker. In a 2026 multi-dataset benchmark on one database, mean absolute error (ms) for NeuroKit2 DWT was PR 45.3, QRS 17.0, QT 91.5; ECGdeli was PR 47.0, QRS 18.0, QT 33.6. Partly verified ([arXiv 2610.07885](https://arxiv.org/html/2610.07885), a recent preprint, not peer-reviewed as far as I know).
- A [2024 IEEE Access comparison](https://doi.org/10.1109/access.2024.3487013) of delineation algorithms on smartwatch data exists (not read in detail).
- **wfdb** (reading/annotation, includes `xqrs` and `gqrs` detectors), **BioSPPy**, **ecg-kit** (MATLAB) and **ECGdeli** (MATLAB): not benchmarked by me; Unverified.
- **Implication:** heart rate from R-peaks is reliable if the digitised trace is clean. QT/QTc and P-wave presence are error-prone. Use QT only as a soft feature with wide tolerance, and compute QTc by Bazett/Fridericia in the app as informational only.

## 5. Robustness: digitisation noise, missing leads, population shift

- **PhysioNet/CinC 2024** addressed exactly our setting: digitising phone photos/scans of paper ECGs and classifying them. Hidden test: 35,595 real paper images from 1,977 PTB-XL and Emory records, with stains, shadows, skew and photographed screens. Metrics: reconstruction SNR and macro-F1. The top classifier (AIMED, ConvNeXt-style direct image classifier) reached hidden macro-F1 0.817. Partly verified ([challenge paper](https://moody-challenge.physionet.org/2024/papers/cinc_paper.pdf), [AIMED paper](https://www.cinc.org/archives/2024/pdf/CinC2024-398.pdf), [results](https://moody-challenge.physionet.org/2024/results/)). Note: macro-F1 of 0.817 is over the challenge's coarse label set, not our classes.
- **ECG-Image-Kit** generates synthetic paper images from PTB-XL with wrinkles, shadows, rotation and handwriting. Synthetic-only training is not enough; validate on real photos. Partly verified (same challenge paper).
- **Reduced leads.** The 2021 challenge evaluated 2-, 3-, 4-, 6- and 12-lead subsets and ISIBrno-AIMT led in all of them. The detailed per-subset score loss is not read yet. Reconstruction of 12 leads from 3 leads works at signal level, but one [repo summary](https://github.com/ZJUXiaoyu/CaLiNet/blob/main/README.md) notes diagnostic F1 retention of only 62–87 % for some deep methods despite high signal correlation (Partly verified, GitHub README, not peer-reviewed).
- **3×4 layout with 2.5 s segments** is a distribution shift from 10 s continuous leads: rhythm leads (II long strip) are often absent, and leads do not overlap in time. Train on the same layout by cutting PTB-XL signals into 4×2.5 s blocks. This is an inference and needs ablation.
- **Population shift:** CODE (Brazil), PTB-XL (Germany), Emory/Georgia/Chapman (CinC) are not Central Asian. No Kyrgyz dataset found (see the dataset note in other research docs if present). Expect calibration drift. Plan local validation.

## 6. On-device inference

- **LiteRT** is the new name of TensorFlow Lite (Sept 2024); the old packages still work, but new features go only to LiteRT. Verified ([Google blog](https://developers.googleblog.com/tensorflow-lite-is-now-litert/), [migration page](https://developers.google.com/edge/litert/migration)).
- Examples: an open-source ECG repo reports a ~4 MB PyTorch model → 1.5 MB TFLite int8, ~44 ms per 10 s window for fp32 (hardware not clear from the excerpt; vendor/GitHub claim). Partly verified ([vitaldb/openecg](https://github.com/vitaldb/openecg)). A PTB-XL TFLite model on Raspberry Pi is also published ([arXiv 2209.00989](https://arxiv.org/abs/2209.00989)). I found no mid-range-Android benchmark; measure ourselves.
- **Flutter packages.** `tflite_flutter` (Apache-2.0, binds to the TFLite C API, Android/iOS delegates NNAPI/GPU/Metal/CoreML). The pub.dev README says it is a TensorFlow-managed fork and "work-in-progress", last README update April 2023. Verified ([pub.dev](https://pub.dev/packages/tflite_flutter)). **Not checked:** current version, Android 15 16 KB page-size support, LiteRT migration. A `flutter_onnxruntime` package exists on pub.dev, but I did not read its maturity or licence details. Unverified ([pub.dev](https://pub.dev/packages/flutter_onnxruntime)). ExecuTorch and ONNX Runtime Mobile were not researched (Unverified).
- **Inference-path risk (inference):** tiny 1D CNNs are trivial for any runtime. The dependency-maintenance risk is in the Flutter plugin. Mitigation: keep model in ONNX/TFLite both, wrap behind a Dart interface, or use a thin Kotlin/Swift platform channel with the official LiteRT/ONNX Runtime library.
- **Quantisation:** use post-training int8 with a calibration set of *photo-like* signals, and compare the sensitivity of dynamic-range vs full-int8 per class. Check that quantisation does not move calibration.

## 7. Uncertainty, calibration, OOD

- [Uncertainty estimation for deep 12-lead ECG analysis (EHJ Digital Health 2021)](https://academic.oup.com/ehjdh/article/2/3/401/6272223) compared six methods on 526,656 ECGs, on ranking, calibration and OOD robustness, and showed that rejecting high-uncertainty ECGs improves performance. Partly verified.
- [Multi-label UQ for ECG (Information Fusion 2023)](https://doi.org/10.1016/j.inffus.2023.101978) and [PLOS ONE OOD ECG](https://journals.plos.org/plosone/article/file?id=10.1371%2Fjournal.pone.0317900&type=printable) exist. MC-dropout flagged erroneous computer ECG reads in a Heart Rhythm abstract ([link](https://www.heartrhythmjournal.com/article/S1547-5271(21)01465-X/fulltext)). All Partly verified.
- **Cheap recipe for POC (inference):** (a) temperature scaling on a patient-wise validation set; (b) a small deep ensemble (3–5 seeds) or MC-dropout; (c) an *input-quality gate* (digitisation confidence, number of leads recovered, SNR, grid detection) that returns "retake the photo" before classification; (d) an "uncertain/abstain → treat as yellow, seek help" rule; (e) Mahalanobis or energy-score OOD on embeddings.

## Implications for ECG-AI KG

1. **Rewrite the spec claim.** Replace "98–99.4 % accuracy on MIT-BIH" by target metrics measured by us: per-class sensitivity and specificity with 95 % CIs on patient-wise splits and on *real photos*. Record the reason in the v2 spec.
2. **Stop using MIT-BIH as the main dataset.** Use PTB-XL (patient-wise official folds) as primary. Add CinC 2020/2021 (Chapman, Georgia, CPSC, etc.) as external test. Use the CinC 2024 image data and ECG-Image-Kit for the photo pipeline.
3. **Two-stage architecture.** (i) photo → digitised signal plus quality score; (ii) a small 1D CNN/ResNet on the signal (XResNet1D / Inception1D class, 1–5 MB int8). Keep rule-based HR/rhythm-regularity features as an independent cross-check for AF, brady/tachy and AV block (high urgency, transparent).
4. **Class design.** Rhythm classes (AF/flutter, VT, sinus tachy/brady, AV block) are well supported by data (PTB-XL rhythm macro-AUROC ≈0.96). LBBB/RBBB are conduction classes in PTB-XL/CinC. VF is rare in public 12-lead sets. ACS/STEMI is the weakest and most dangerous. Present STEMI as "ST-elevation pattern suspected, urgent" with a conservative threshold, and say plainly that it misses OMI without ST elevation. This wording needs cardiologist review.
5. **Do not ship a foundation model in v1.** Use ECGFounder or ECG-FM (MIT) only as a teacher or for linear-probe experiments. Avoid HuBERT-ECG for any commercial or MoH deployment. Check the data licences of the training sets too (not researched).
6. **Safety design:** the app outputs red/yellow/green with an asymmetric cost. Optimise sensitivity for red classes at an agreed specificity floor, and fall back to yellow on low quality or high uncertainty. Never output green on a poor-quality photo.
7. **Mobile stack:** export to both TFLite (LiteRT) and ONNX. Benchmark on 2–3 real mid-range Android phones. Isolate the runtime behind a Dart interface. Check `tflite_flutter` current maintenance before committing.
8. **Intervals:** use R-peak HR and RR-regularity as primary; show QT/QTc only as informational.

## Recommended POC modelling approach

| Item | Recommendation |
|---|---|
| Data | PTB-XL (train/val/test by official strat. folds 1–8/9/10); external test on CinC Chapman/Georgia/CPSC subsets; photo robustness on CinC 2024 data and ECG-Image-Kit renderings printed/photographed by us. |
| Input | Signals resampled to 100–250 Hz; leads arranged as 3×4 layout with 2.5 s segments + optional rhythm strip; random lead dropout during training; baseline-wander/noise/gridline/scale augmentation matching digitiser errors. |
| Models | (a) XResNet1D-18/Inception1D baseline from the Strodthoff benchmark code; (b) same on digitised signals (end-to-end degraded); (c) optional distilled student from ECGFounder; compare with a direct-image ConvNeXt-tiny classifier as in CinC 2024. |
| Labels | Map PTB-XL/CinC SNOMED codes to the app's 8–10 classes; keep "other abnormal" and "normal" so the model can abstain. |
| Metrics | Per-class sensitivity, specificity, PPV at the operating point; AUROC and AUPRC; F1; macro averages; calibration (ECE, Brier); abstention rate vs accuracy curve; report by image condition (clean, phone photo, shadow, skew). 95 % CIs by patient-level bootstrap. |
| Protocol | Patient-wise splits only (PTB-XL ids are patient-aware in the official folds); no normalisation or threshold tuning on test; threshold chosen on validation; external-database test; final test once. |
| Targets | Set only after measuring baselines; agree red-class sensitivity target with cardiologist after the POC. |

## Open questions

| Question | Who |
|---|---|
| Exact wording and context of the "98–99.4 %" claim in the spec; is MIT-BIH meant for beats or rhythms? | Author |
| Which sensitivity/specificity trade-off is acceptable for red/yellow classes; is "STEMI-equivalent/OMI" in scope? | Cardiologist (after POC) |
| Typical paper ECG formats in Kyrgyz FAPs (3×4, 6×2, rhythm strip? speed 25 mm/s, gain 10 mm/mV?) | Author, then cardiologist |
| Verified modern inter-patient MIT-BIH numbers, CinC 2021 per-lead-count scores, Ribeiro F1/specificity values | Further desk research |
| ExecuTorch, ONNX Runtime Mobile, and Flutter ONNX plugin maturity; mid-range Android latency | Desk research and own benchmark |
| Licences of training data for ECGFounder/ECG-FM checkpoints; ECG-JEPA weight licence | Desk research / ask authors |
| MERL, ST-MEM, ECG-Chat, ECG-Byte details | Desk research (low priority) |
| Any Kyrgyz or Central Asian ECG dataset for local validation | Author / MoH (cannot be found online in this pass) |

## Sources (accessed 2026-10-29)

- de Chazal et al. 2004 – https://pubmed.ncbi.nlm.nih.gov/15248536/
- PhysioNet MIT-BIH Arrhythmia Database – https://www.physionet.org/content/mitdb/1.0.0/mitdbdir/
- Systematic review of ECG arrhythmia classification (2026) – https://link.springer.com/article/10.1007/s42600-026-00485-z
- Strodthoff et al., PTB-XL benchmark – https://arxiv.org/abs/2004.13701
- Ribeiro et al. 2020 – https://www.nature.com/articles/s41467-020-15432-4
- Hannun et al. 2019 – https://pubmed.ncbi.nlm.nih.gov/30617320/
- PhysioNet/CinC 2021 results – https://moody-challenge.physionet.org/2021/results/
- PhysioNet/CinC 2024 paper, results – https://moody-challenge.physionet.org/2024/papers/cinc_paper.pdf ; https://moody-challenge.physionet.org/2024/results/ ; https://www.cinc.org/archives/2024/pdf/CinC2024-398.pdf
- Al-Zaiti et al. 2023 – https://www.nature.com/articles/s41591-023-02396-3 ; https://pmc.ncbi.nlm.nih.gov/articles/PMC10353937/
- OMI ECG vs STEMI criteria – https://ncbi.nlm.nih.gov/pmc/articles/PMC8065286/
- Queen of Hearts / Powerful Medical (vendor page) – https://www.powerfulmedical.com/research/validation-of-an-artificial-intelligence-ecg-model-for-detection-of-acute-coronary-occlusion-myocardial-infarction-in-unselected-emergency-department-chest-pain-patients/
- ECGFounder – https://huggingface.co/PKUDigitalHealth/ECGFounder ; https://ai.nejm.org/doi/full/10.1056/AIx2500913
- ECG-FM – https://huggingface.co/wanglab/ecg-fm/blame/main/README.md ; https://academic.oup.com/jamiaopen/article/8/5/ooaf122/8287827
- HuBERT-ECG – https://github.com/Edoar-do/HuBERT-ECG
- ECG-JEPA – https://github.com/sehunfromdaegu/ecg_jepa
- Benchmarking ECG FMs – https://arxiv.org/abs/2509.25095
- ECG delineation benchmark (preprint) – https://arxiv.org/html/2610.07885 ; smartwatch comparison https://doi.org/10.1109/access.2024.3487013
- LiteRT – https://developers.googleblog.com/tensorflow-lite-is-now-litert/ ; https://developers.google.com/edge/litert/migration
- vitaldb/openecg – https://github.com/vitaldb/openecg ; ECG TFLite on Raspberry Pi – https://arxiv.org/abs/2209.00989
- tflite_flutter – https://pub.dev/packages/tflite_flutter ; flutter_onnxruntime – https://pub.dev/packages/flutter_onnxruntime
- Uncertainty in ECG DL – https://academic.oup.com/ehjdh/article/2/3/401/6272223 ; https://doi.org/10.1016/j.inffus.2023.101978 ; https://journals.plos.org/plosone/article/file?id=10.1371%2Fjournal.pone.0317900&type=printable ; https://www.heartrhythmjournal.com/article/S1547-5271(21)01465-X/fulltext
- CaLiNet README (reduced-lead reconstruction, not peer-reviewed) – https://github.com/ZJUXiaoyu/CaLiNet/blob/main/README.md
