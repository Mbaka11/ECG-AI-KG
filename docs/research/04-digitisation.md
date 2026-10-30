# 04 - Digitising paper ECGs from photos, and classifying from images

Date accessed for all sources: 2026-10-29. Verification labels: **Verified** (source page read in this session), **Partly verified** (only search-result snippet or secondary summary seen), **Unverified** (not found or not checked).

## Summary

- **Photo digitisation is still unsolved at high fidelity.** In the PhysioNet/Moody Challenge 2024, the winner scored an SNR of 12.15 dB on the clean leaderboard scans. On mobile-phone photos of clean, stained and deteriorated paper, the same entry scored about -1 dB. Several top teams also scored near or below 0 dB on photos. (Verified, official score tables.)
- **The best open-source photo-capable digitiser is Open-ECG-Digitizer (Ahus, Norway).** It reports mean SNR of 19.65 dB on scans, 12.19 dB on OnePlus photos and 10.47 dB on iPhone photos. Its Emory-database results on photos are only about 1-2 dB. Its code and weights are licensed **CC BY-SA 4.0**, which is unusual for software and brings share-alike obligations. (Verified.)
- **The spec's "<7 seconds, robust to folds/stains" claim comes from a company paper, not Nature.** It is Powerful Medical/PMcardio, J Electrocardiol 2025, which is closed-source. It reports SNR above 12.5 dB, a 6.62% per-lead failure rate and under 7 s per image. The "Nature" paper that most likely matches the spec is Stenhede et al. in npj Digital Medicine (Open-ECG-Digitizer). (Verified, with one inference about which paper the spec meant.)
- **Yolov11 + OpenCV is a real but minority choice.** Winners and the best open tools use U-Net-family semantic segmentation (nnU-Net, residual U-Net) plus classical geometry (Hough, autocorrelation grid detection). YOLO appears mainly for detecting regions or leads (e.g. ECGLight, TimeBeater's YOLOv10). Ultralytics YOLO is AGPL-3.0 and its own licence page says commercial, proprietary or embedded use needs an Enterprise licence. Permissive alternatives exist. (Verified.)
- **Classifying directly from images works, but the evidence is thin for a rural-offline POC.** Examples are ECG-GPT (Yale), Sangha et al. (Yale, Nat Commun 2022), PMcardio and PULSE. General multimodal LLMs (GPT-4o, Gemini) are unreliable: one 928-image MI study found 36% sensitivity for ChatGPT. They also need the internet. (Verified for the MI study and the Moody classification table; Partly verified for the rest.)
- **Moody 2024 classification was easier than digitisation.** Winner AIMED scored macro-F 0.817 on scans and 0.64-0.71 on phone photos. These are Challenge-specific labels, not our six target classes. (Verified.)
- **Recommended POC:** a modular pipeline, not one end-to-end model. Stages: on-device capture guidance and document detection, then server-side or on-device U-Net segmentation and grid calibration, then 1D signal quality gating, then a 1D classifier trained on PTB-XL with image-domain augmentation. Compare against a direct image classifier as a baseline. Use a permissive detector (or none) instead of Ultralytics. Never output a red/yellow/green result when digitisation quality is low.

## 1. PhysioNet/Moody Challenge 2024

**Task.** Teams build open-source algorithms to (a) turn ECG images into time series and/or (b) classify from the extracted signals or from the image itself. The digitisation metric is SNR between the reference and digitised signal, after shifting by up to ±0.5 s and ±1 mV to maximise cross-correlation. Classification is scored by macro F-measure. ([Challenge description paper](https://moody-challenge.physionet.org/2024/papers/cinc_paper.pdf), [Results page](https://moody-challenge.physionet.org/2024/results/)) Verified.

**Data.** The hidden test set is built on PTB-XL. The "leaderboard" score uses colour and black-and-white scans. The other columns cover scans and phone photos of clean, stained and deteriorated paper, plus photos of monitors. ([Results page](https://moody-challenge.physionet.org/2024/results/)) Verified.

**Official digitisation scores (SNR dB, hidden data; selected from [official_scores_digitization.tsv](https://moody-challenge.physionet.org/2024/results/official_scores_digitization.tsv)). Verified.**

| Rank | Team | Leaderboard (scans) | Colour scan, clean | Phone photo, clean | Phone photo, stained | Phone photo, deteriorated |
|---|---|---|---|---|---|---|
| 1 | SignalSavants (Oxford) | 12.15 | 4.93 | -1.07 | -0.72 | -1.30 |
| 2 | BAPORLab | 5.49 | 6.22 | -0.26 | -1.12 | 0.81 |
| 3 | wavie_ABI | 5.47 | n/a | n/a | n/a | n/a |
| 4 | Ahus AI Lab | 3.05 | 3.32 | 0.14 | -0.35 | 0.79 |

Only a few teams beat the "all zeros" baseline (about -0.06 to -0.38 dB depending on category). The leaderboard score is much higher than the score after the organisers retrained on the full test set and evaluated on photo variants. Photos were clearly the hard case. The 16 official teams are all in the table; the later npj paper says there were 17 methods in total.

**Official classification (macro F-measure; [official_scores_classification.tsv](https://moody-challenge.physionet.org/2024/results/official_scores_classification.tsv)). Verified.**

| Rank | Team | Leaderboard | Clean phone photo | Stained photo | Deteriorated photo |
|---|---|---|---|---|---|
| 1 | AIMED | 0.817 | 0.644 | 0.636 | 0.711 |
| 2 | Inventec AIC | 0.742 | 0.697 | 0.694 | 0.739 |
| 3 | BAPORLab | 0.730 | 0.609 | 0.634 | 0.644 |
| 4 | CeZIS | 0.645 | 0.648 | 0.659 | 0.700 |

Inventec's classifier lost the least on photos. Note the Challenge labels are PTB-XL-derived diagnostic classes, not our target list.

**Winning digitiser method (SignalSavants / Krones et al.).** Synthetic printouts generated from PTB-XL with ECG-Image-Kit, Hough transform for rotation, nnU-Net segmentation of traces, then vectorisation of the mask. Reported SNR was 17.02 dB in 10-fold CV on PTB-XL images and 12.15 on the hidden leaderboard. The repo `felixkrones/ECG-Digitiser` contains training scripts and pretrained models and carries a BSD-2-Clause badge. It also bundles nnU-Net, so check nnU-Net's own licence before shipping. ([arXiv 2410.14185](https://arxiv.org/abs/2410.14185), [repo](https://github.com/felixkrones/ECG-Digitiser)) Method and licence badge: Verified (repo README read); CV numbers: Partly verified (search summary).

**Code availability caveat.** The npj paper says that, at the time of its writing, none of the three Challenge entries that beat the baseline showed robust photo results, and their code was not available ([Stenhede et al.](https://www.nature.com/articles/s41746-025-02327-1)). The SignalSavants repo does now exist, so that statement is partly stale for that team. Verified.

## 2. Open-source and published digitisers

| Tool / paper | Approach | Photo robustness | Runtime | Licence | Status |
|---|---|---|---|---|---|
| **Open-ECG-Digitizer** (Ahus-AIM; Stenhede et al., npj Digit Med, published online 2025-10-22, issue 2026) | Residual U-Net segments trace/grid/text/background; perspective correction (handles ~45° rotation per README); cropper; autocorrelation grid-size finder; second U-Net reads lead names and matches layout templates; signal extractor sets overlapping parts to NaN. Optional dewarping is "experimental, not formally evaluated". | Ahus data: 19.65 dB scans, 12.19 dB OnePlus, 10.47 dB iPhone. Emory database (25 mm/s): 7.34 dB scans, 1.05-2.03 dB on photos and deteriorated paper. Authors call it the first with positive SNR in all categories. | Not stated for the new tool. They cite 4.86 s mean (3.88-6.33 s) for the PMcardio method. README says tested on Linux with CUDA. | **CC BY-SA 4.0** (LICENSE file read). Mandatory citation requested. Training dataset on Hugging Face. | Verified |
| **felixkrones/ECG-Digitiser** (Moody 2024 winner) | Hough rotation + nnU-Net + vectorisation. | About -1 dB on phone photos in the Challenge. | Not found. | BSD-2-Clause badge (bundled nnU-Net has its own LICENSE). | Verified (repo); runtime not found |
| **ECGtizer** (UMMISCO; Lence et al., Biomed Signal Process Control 2025, [arXiv 2412.12139](https://arxiv.org/abs/2412.12139)) | Classical: variance-peak track splitting, binarise, three trace-extraction modes (lazy/full/fragmented), calibration from the reference pulse, optional PyTorch autoencoder to complete missing leads, HL7 aECG XML output. Works on PDF/scans. | The paper stresses clean generated ECGs; real scans with marks/folds remain a stated challenge. No perspective-correction or photo module found in the README/structure read. | Not found. | Unlicense per search summary of the repo; LICENSE file exists but its text was not read. | Partly verified |
| **PMcardio / Powerful Medical** (Demolder et al., J Electrocardiol 2025;90:153900) | Grid normalisation + distortion correction, then deep-learning lead extraction. Evaluated on the public PM-ECG-ID (6000 images from 100 ECGs, printed and photographed). | PCC >0.91, SNR >12.5 dB, RMSE <0.10 mV, per-lead failure rate 6.62% (severe blur/degradation). | **<7 s** (this is the spec's figure). | Closed source; commercial product (self-described Class IIb device). | Verified (vendor page); journal text not read |
| **Heart 2024 smartphone app** (Hsieh? authors not captured; [Heart 110:1074](https://heart.bmj.com/content/110/17/1074)) | Object-detection + segmentation models in sequence: waveform identification, gridline removal, signal extraction. | 94.0% of 5743 photographed waveforms correctly cropped/labelled; 88.0% of 5752 got successful signal extraction; AF algorithm 91.3% sens / 94.2% spec on the demo. Only 444 photographed ECGs. | Not found. | Not found. | Partly verified (abstract snippet) |
| **ECG-Image-Kit** (Emory/Georgia Tech; Shivashankara et al., Physiol Meas 2024) | Synthetic ECG image generator with wrinkles, stains, handwriting, perspective, plus lead-box labels. Used for Challenge training. | n/a (generator) | n/a | BSD-3-Clause per repository metadata snippet. | Partly verified |
| **ECGLight** (SCAI-Lab) | Sequential YOLOv11 detection, Hough-based scale calibration, K-Means grid, MI/OMI screening. | Not assessed here. | Not found. | Not read. Using Ultralytics implies AGPL-3.0 obligations. | Partly verified (README snippet) |
| **PaperECG, ECGminer, Wu et al. 2022 (Sci Rep)** | Semi-automatic (PaperECG) or earlier DL. | The npj authors could not digitise any of their images with the Wu et al. API. ECGtizer's paper claims to beat PaperECG and ECGminer on clean synthetic images. | n/a | Not checked. | Partly verified |

**Where the spec's "Nature, 2025" and "<7 seconds" come from.** The <7 s figure is from the PMcardio paper above. The most plausible "Nature" paper is Stenhede et al. (npj Digital Medicine, Nature portfolio). This is a researcher inference, since the spec gives no URL. The spec's wording ("robust to folds, stains, perspective distortion") overstates the evidence. The Challenge and the npj paper both show large drops on real photos.

**Common technical pattern.** Perspective correction, then semantic segmentation (U-Net), then grid-scale estimation (autocorrelation or Hough), then layout identification, then mask-to-1D conversion. The npj authors report that "a diverse training set was more important than the choice of segmentation network". Verified (npj text). Implication: synthetic-data realism matters more than architecture.

## 3. Is YOLOv11 + OpenCV a good choice?

- **Prevalence.** A search for YOLO-based ECG digitisation returned mostly Challenge papers using YOLO as a region detector (YOLOv10 for ECG area detection in ECGFusion, YOLOv11 in ECGLight), with binarisation done by other networks ([ECGFusion](https://cinc.org/archives/2024/pdf/CinC2024-167.pdf), [ECGLight](https://github.com/SCAI-Lab/ECGLight)). The two top Challenge digitisers and the best open tool use U-Net-family segmentation. Verified for those papers; the claim "YOLO is a minority choice" is a researcher interpretation from a small sample, not a systematic survey.
- **Task fit.** A thin 1-pixel-wide trace is a poor fit for instance-segmentation masks produced at the low resolution of YOLO's prototype masks. Semantic U-Nets at near-full resolution suit it better. (Researcher inference.)
- **Licence.** Ultralytics' own page lists as Enterprise-licence triggers: "any commercial product or service", "proprietary / closed-source software", "SaaS ... behind the scenes", "embedded deployments", and "custom-trained or fine-tuned YOLO models in a proprietary or commercial setting". AGPL-3.0 is free if the whole project is released under AGPL. ([Ultralytics licence page](https://www.ultralytics.com/license)) Verified. The project is public, so AGPL could be acceptable, but it would constrain later MoH/commercial reuse. (Inference; legal advice not sought.)
- **Permissive alternatives (licence text seen in search results, not individually fetched; Partly verified):** [MMDetection / RTMDet](https://github.com/open-mmlab/mmdetection/blob/main/LICENSE) (Apache-2.0; an open issue questions the licence of RTMDet in the separate MMYOLO repo, so use MMDetection), [YOLOX (MegEngine fork)](https://github.com/MegEngine/YOLOX/blob/main/LICENSE) (Apache-2.0), [D-FINE](https://github.com/Peterande/D-FINE/blob/master/LICENSE) (Apache-2.0). For segmentation, nnU-Net and the Ahus U-Net are U-Net variants; check each repo's licence. I did not verify the licences of RT-DETR forks, SAM variants or the licence of nnU-Net itself.

## 4. Classifying directly from images

| Work | What it does | Key evidence | Notes |
|---|---|---|---|
| **Sangha et al., Nat Commun 2022** (Yale) | Multilabel diagnosis from ECG images and signals | Abstract and authorship seen; numbers not captured | Yale group later published HCM-from-images and HF-risk-from-ECG-photos. Partly verified. ([paper](https://www.nature.com/articles/s41467-022-29153-3)) |
| **ECG-GPT** (Yale/Mount Sinai; Eur Heart J Digit Health 2026) | Format-independent vision encoder-decoder producing free-text interpretation | 2.9M ECGs, seven settings; for AF, ST changes, sinus bradycardia and PACs AUROCs ranged 0.80-0.95 (preprint snippet); blocks 0.88-0.96 | Developed on ~3M ECGs. Not tested on rural phone photos in what I saw. Partly verified. ([journal](https://academic.oup.com/ehjdh/article/7/3/ztag031/8489956)) |
| **PMcardio AMSTELHEART-1** (Cardiovasc Digit Health J 2023) | Smartphone app reading 12-lead ECG images, 290 Dutch GP patients | Major ECG abnormalities: sens 86%, spec 92%; AF: sens 97%, spec 99% | Photo-based, closed-source, commercial. Verified (abstract). ([PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC10282008/)) |
| **PULSE** (Liu et al., npj Digit Med, Mar 2026) | Open 7B multimodal LLM for ECG images | Beats GPT-4o by 21-36% on several benchmarks; 64.0% vs 43.5% (GPT-4o) vs 84.4% (cardiologists) on a 30-question MMMU ECG sample; "modest" drop on printed-ECG photos | Open weights and data, but 7B parameters is far too big for an offline feldsher phone. Partly verified (summary). ([paper](https://www.nature.com/articles/s41746-026-02551-3)) |
| **GPT-4V / GPT-4o / Gemini** | General multimodal LLMs | MI study, 928 images: ChatGPT accuracy 65.95%, sensitivity 36.4%, specificity 76.2%, AUC 0.573; dedicated ECG Buddy: accuracy 96.98% ([JMIR AI 2025](https://doi.org/10.2196/75910)). JMIR 2024 study found counting-type questions poor (1 of 7 correct) ([JMIR 2024](https://www.jmir.org/2024/1/e54607/PDF)). | Verified for the MI figures (preprint abstract snippet); Partly verified for the rest. Not offline, and no consistent safety record. |

**Digitise-then-classify vs direct image classification.**

| | Digitise then classify | Direct image classification |
|---|---|---|
| Pros | Gives a signal for measuring HR, QRS, QTc and for highlighting (spec FR-2, FR-3). Allows training on large public signal datasets (PTB-XL). Failures are visible (quality gate). Models are small and run on-device. | Skips the hard digitisation step. Robust to layouts if trained on photos. Higher reported accuracy in some commercial settings. |
| Cons | Errors compound: photo SNR is about 1-10 dB. The npj authors say AI performance and reliability improve with digital time series. | Needs large labelled image datasets, with matching photo variability, that we do not have. Hard to explain or highlight. Harder to detect silent failure. |
| Fit for POC | Better for decision support with visible evidence. | Useful as a second opinion or fallback baseline. |

The Moody 2024 classification table shows that image-based or signal-based classification was usable on photos (macro-F 0.64-0.74 for the top entries) even where digitisation SNR was near 0 dB. Researcher inference: a direct image branch could be a safety net when digitisation quality is low.

## 5. Image quality assessment, retake guidance, document detection

- **Document detection and perspective correction on-device.** Google's [ML Kit Document Scanner](https://developers.google.com/ml-kit/vision/doc-scanner) offers a scanning UI with crop, shadow and stain removal, and runs through Google Play Services. Third-party notes say it works offline ([Scandroid FAQ](https://scandroid.app/questions-and-answers/)). Limitations seen: Android only; the UI flow uses an external camera activity, so you cannot feed your own frames (a [feature request](https://github.com/googlesamples/mlkit/issues/788)), and it needs Google Play Services (not checked for offline first-run requirements). For Flutter on both platforms, OpenCV (contour/Hough and homography) is the portable option. Verified for ML Kit features; offline claim Partly verified.
- **Signal quality assessment.** Mature signal-quality-index work exists from the 2011 PhysioNet/CinC challenge on mobile-phone ECG quality ([CinC 2011 paper](https://cinc.org/archives/2011/pdf/0281.pdf)), but it targets signals, not photos. Open-ECG-Digitizer leaves unreadable leads as NaN rather than guessing. This is a useful design pattern. Verified.
- **Photo-specific quality gating.** I found no validated, open, ECG-photo-specific retake model. A 2026 arXiv paper proposes "VLM-in-the-Loop" quality assurance for digitisation, claiming existing methods "collapse on real-world images" ([arXiv 2604.00396](https://arxiv.org/html/2604.00396)); abstract only, not evaluated. Partly verified.
- **Practical retake checks (researcher suggestion, no source):** blur (variance of Laplacian), glare/saturation, grid visible and resolvable (grid period in pixels from autocorrelation), detected page quadrilateral covering most of the frame, skew angle, lead labels found, and a plausibility check on the output (physiological HR, no flat lines).

## Implications for ECG-AI KG

1. **Fix the spec's rationale.** Replace "SOTA ... YOLOv11" and "Nature 2025, <7 s" with accurate citations: Stenhede et al. (npj Digit Med) and Demolder et al. (J Electrocardiol, closed source). Record that photo-based SNR is only 1-12 dB in the best open tool. Put this in the v2 spec change log.
2. **POC digitiser: start from Open-ECG-Digitizer or the SignalSavants repo, not from scratch.** Run both on a small set of real photos from Kyrgyz ECG machines. **Licence decision needed:** CC BY-SA 4.0 requires derivatives to stay share-alike. That fits a public repo but could conflict with a closed MoH build. BSD-2 (Krones) is easier.
3. **Own the training data.** Generate synthetic Kyrgyz-style images with ECG-Image-Kit (add the local paper grid colour, layout, printed text and Cyrillic lead labels if present), plus real phone augmentations. Collect real strips only with consent and keep them out of git (project rule).
4. **Avoid Ultralytics unless AGPL is accepted.** If you need a detector (strip or lead boxes), use an Apache-2.0 option (RTMDet via MMDetection, D-FINE, YOLOX), or skip detection and use U-Net plus geometry.
5. **Quality gate with a "cannot read" state.** Never show red/yellow/green on low-quality input. Show a retake prompt, or an "unreadable, treat clinically" message. This is also a clinical-safety requirement in AGENTS.md.
6. **Add a direct-image baseline.** Train a small image classifier (e.g. MobileNet-sized) on synthetic photos of PTB-XL and compare with the digitise-then-classify route on the same held-out photos.
7. **Do not use general LLMs for classification.** If an LLM is used at all, restrict it to wording the action-step text from a template, with clinical content taken from official protocols.
8. **Evaluate with the Moody metric.** Report SNR on photo categories and the macro-F of the end-to-end pipeline, so results are comparable with the 2024 leaderboard.

## Recommended POC pipeline

1. Capture (Flutter camera, live overlay): detect page quadrilateral (OpenCV), check blur, glare, and size; auto-capture when good.
2. Perspective rectification (homography); rotate to upright.
3. Semantic segmentation (U-Net, ONNX/TFLite on-device if latency is acceptable; otherwise a local server) into trace, grid, text, background.
4. Grid-scale estimation (autocorrelation) giving mm per pixel; confirm 25 mm/s and 10 mm/mV from the printed calibration pulse or text; flag if not standard.
5. Layout and lead identification (template matching); lead-wise vectorisation of the trace mask; NaN for ambiguous parts.
6. Signal QC (HR plausibility, missing-lead fraction, SNR proxy). Fail gracefully.
7. 1D classifier (PTB-XL, augmented with simulated digitisation noise) for the six target groups.
8. Rule-based urgency layer and action-step templates sourced from official protocols; always show the digitised trace with the raw photo so the feldsher can check.

## Main risks

- Real-photo digitisation quality is low (SNR 1-12 dB); subtle ST-segment changes (STEMI/ACS) are most likely to be damaged.
- Thermal-paper degradation, handwriting, 25 mm/s vs 50 mm/s speeds, and local layouts are not represented in public data.
- Licence traps: CC BY-SA 4.0 (Open-ECG-Digitizer), AGPL-3.0 (Ultralytics), BSD-2 repos that bundle other licences, PTB-XL and PhysioNet data-use terms.
- Domain shift from PTB-XL (European adult ECGs) to Kyrgyz patients and devices.
- Pretrained classifiers on MIT-BIH (48 recordings) are not suitable for ACS or 12-lead tasks. Use PTB-XL plus larger sets.
- Regulatory and clinical-safety exposure if urgency colours are over-trusted.

## Open questions

| Question | Who to ask |
|---|---|
| Which ECG machines and paper formats (speed, grid colour, lead layout, thermal vs plain paper) are used in Kyrgyz FAPs/CFMs? Can the author supply sample strips? | Author |
| Is AGPL-3.0 or CC BY-SA acceptable for the app and the MoH build, or must the stack be permissive? | Author (then MoH legal) |
| Which patterns need ST-level fidelity for the "red" category, and what error rate is acceptable? | Cardiologist, after the POC |
| Open-ECG-Digitizer runtime on CPU/mobile; ECGtizer runtime and photo performance | Not found; test in the POC |
| Heart 2024 paper authors and licence; ECGLight licence; nnU-Net licence; Ecgtizer LICENSE text | Not found / not read; check repos directly |
| Numbers for Sangha 2022 and full ECG-GPT results | Not captured (publisher blocked fetch); read the papers directly |
| Any other 2025-2026 smartphone-photo digitisation results beyond those listed | Search coverage was limited to a handful of queries |

## Sources

- Kept: [Moody 2024 results page](https://moody-challenge.physionet.org/2024/results/), [official digitisation scores](https://moody-challenge.physionet.org/2024/results/official_scores_digitization.tsv), [official classification scores](https://moody-challenge.physionet.org/2024/results/official_scores_classification.tsv), [Challenge description paper](https://moody-challenge.physionet.org/2024/papers/cinc_paper.pdf) - Challenge facts and scores (read: tables and results page; paper via snippet).
- Kept: [Stenhede et al., npj Digit Med](https://www.nature.com/articles/s41746-025-02327-1) - the best open photo-capable digitiser, with results (read).
- Kept: [Ahus-AIM/Open-ECG-Digitizer](https://github.com/Ahus-AIM/Open-ECG-Digitizer) and its [LICENSE (CC BY-SA 4.0)](https://raw.githubusercontent.com/Ahus-AIM/Open-ECG-Digitizer/main/LICENSE) (read).
- Kept: [felixkrones/ECG-Digitiser](https://github.com/felixkrones/ECG-Digitiser) and [arXiv 2410.14185](https://arxiv.org/abs/2410.14185) - Challenge winner (repo README read; arXiv by snippet).
- Kept: [UMMISCO/ecgtizer](https://github.com/UMMISCO/ecgtizer) and [arXiv 2412.12139](https://arxiv.org/abs/2412.12139) - spec-named tool (repo read; paper by snippet).
- Kept: [Powerful Medical research page](https://www.powerfulmedical.com/research/high-precision-ecg-digitization-using-artificial-intelligence/) and [PubMed 40010101](https://pubmed.ncbi.nlm.nih.gov/40010101/) - source of "<7 s" (vendor page read).
- Kept: [Heart 2024](https://heart.bmj.com/content/110/17/1074) (snippet); [ECG-Image-Kit](https://github.com/alphanumericslab/ecg-image-kit) (snippet); [ECGLight](https://github.com/SCAI-Lab/ECGLight) (snippet); [ECGFusion](https://cinc.org/archives/2024/pdf/CinC2024-167.pdf) (snippet).
- Kept: [Ultralytics licence page](https://www.ultralytics.com/license) (read); [MMDetection](https://github.com/open-mmlab/mmdetection/blob/main/LICENSE), [YOLOX](https://github.com/MegEngine/YOLOX/blob/main/LICENSE), [D-FINE](https://github.com/Peterande/D-FINE/blob/master/LICENSE) (snippets).
- Kept: [AMSTELHEART-1](https://pmc.ncbi.nlm.nih.gov/articles/PMC10282008/), [Sangha 2022](https://www.nature.com/articles/s41467-022-29153-3), [ECG-GPT](https://academic.oup.com/ehjdh/article/7/3/ztag031/8489956), [PULSE](https://www.nature.com/articles/s41746-026-02551-3), [JMIR AI 2025 MI study](https://doi.org/10.2196/75910), [JMIR 2024 GPT-4V](https://www.jmir.org/2024/1/e54607) - image classification evidence (mostly snippets; some publisher pages blocked).
- Kept: [ML Kit Document Scanner](https://developers.google.com/ml-kit/vision/doc-scanner), [CinC 2011 mobile ECG quality](https://cinc.org/archives/2011/pdf/0281.pdf), [VLM-in-the-Loop](https://arxiv.org/html/2604.00396).
- Rejected/deprioritised: Roboflow/Ultralytics reseller pages (marketing); GitHub issue #19390 on AGPL for on-device use (user question, not authoritative); small conference abstracts on GPT-4 ECG accuracy (low-sample, redundant).
