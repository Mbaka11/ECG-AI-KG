# 13 - Where each step should run: on the phone, on a server, or hybrid

Date of research: 2026-11-04. Method: web search plus page reads, and a few local calculations.
Status labels: **Verified** (source page read), **Partly verified** (search snippet or secondary
source only), **Unverified** (not found or not checked), **Researcher inference** (reasoning, no
direct source). Items marked "(computed)" were calculated locally for this note with a simple
multiply-accumulate (MAC) counter. The counter gives 31.0 M parameters for a standard 64-channel
U-Net, the same figure Qualcomm publishes for its U-Net, which is a sanity check on the method.
"(project measurement)" marks numbers the project measured on 2026-11-04. They were not
re-checked for this note.

Related: [ADR 0006 inference location](../adr/0006-inference-location.md),
[ADR 0004 digitiser](../adr/0004-digitiser-approach.md),
[ADR 0001 licences](../adr/0001-permissive-licence-policy.md),
[ADR 0007 stack](../adr/0007-app-and-backend-stack.md),
[04 digitisation](04-digitisation.md), [02 Kyrgyz context](02-kyrgyz-context.md),
[07 regulatory](07-regulatory-ethics.md), [08 tooling](08-dev-tooling-and-agent-skills.md),
[data management plan](../privacy/DATA_MANAGEMENT_PLAN.md), spec v2 C-42 (time targets).

## Executive summary

- **The current 12-lead digitiser cannot run on a typical Kyrgyz phone without training a new
  model.** It has 113.5 M parameters, 454 MB in fp32 (project measurement). A rough count
  gives about 300 GMAC or more per 1024x1280 patch and roughly 0.8-1 GB of fp32 working memory
  (computed, lower bound). Budget Android phones have 3-8 GB RAM, and most use MediaTek Helio or
  Unisoc chips. LiteRT's NPU support does not cover those chips. INT8 quantisation needs no
  training, but it only cuts the weights to about 160 MB. CPU time would still be in the range of
  tens of seconds to minutes (Researcher inference, to be measured).
- **Connectivity is good on paper but not guaranteed at a FAP.** 4G reaches 2,219 of 2,236
  settlements (99.2 %), and 13 settlements had no mobile signal at all in Q1 2026. The national
  mobile median is about 52 Mbps down and 15 Mbps up, and data costs about USD 0.05-0.15 per GB.
  An upload of about 1 MB per case costs a fraction of a cent and takes a few seconds even at
  1-5 Mbps. Settlement coverage does not mean coverage inside the building or reliable service in
  a valley, so offline use remains a hard requirement (spec, ADR 0006).
- **The offline rhythm check is only as good as the signal it gets.** The rule-based rhythm
  layer (NeuroKit2-style) is tiny. But it needs a signal, and without the network the phone has
  no 12-lead digitiser. The offline path therefore needs its own small signal source. The proposal
  is classic computer vision (no neural network, no training) on the long rhythm strip or on the
  3 channels of a thermal strip. Whether that works on photos is untested.
- **Recommendation: hybrid, in stages.**
  (1) POC: run the digitiser on a laptop or server and use the phone for capture only.
  (2) Pilot or product: the phone works offline for capture, quality gate and rhythm-strip
  red flags, and it shows grey ("full analysis pending") rather than green. When a signal is
  available it uploads the photo, with consent, for the full 12-lead digitiser and classifier on a
  server hosted in Kyrgyzstan or at the MoH.
  (3) Long term: a small on-device digitiser, but only if someone trains it, or if a
  permissively licensed small model appears.
- **Options that need training:** distillation into a 1-5 M parameter student, pruning
  (practically needs fine-tuning) and training our own small U-Net (ADR 0004 Stage 2).
  **Options that need no training:** post-training INT8 quantisation (needs only unlabelled
  calibration images), ONNX/LiteRT/ExecuTorch export, turning off test-time augmentation and
  similar inference settings, server hosting, classic-CV rhythm extraction, and the rule layer.
- **This is a proposed change to ADR 0006.** ADR 0006 says "on-device first" for the whole path.
  Given that we will not train models ourselves, the evidence supports on-device first only for
  capture, the quality gate, rhythm rules and the classifier. The 12-lead digitiser should be
  server-side until an on-device model passes the C-42 benchmark. The lead should decide whether
  to amend the ADR.
- **The digitiser's accuracy matters more than where it runs.** The Challenge winner scored
  about -1 dB SNR on phone photos ([04](04-digitisation.md)). A server does make it easier to swap
  in a better digitiser later without shipping a new app. The deciding experiments are listed in
  section 7: CPU-only timing, INT8 export, phone benchmarks, upload test and the rhythm-strip
  prototype.

## 1. Constraints

### 1.1 Connectivity in Kyrgyzstan

| Fact | Value | Source | Status |
|---|---|---|---|
| Settlements with no mobile signal (end of Q1 2026) | 13 of 2,236: Issyk-Kul 7, Jalal-Abad 3, Osh 2, Naryn 1. Chui and Talas fully covered. 4G in 2,219 settlements (99.2 %); Batken 255 of 256 with 4G | [Economist.kg, 2026-08-13, citing data.gov.kg](https://economist.kg/society/2026/08/13/mobilnaya-svyaz-v-naselennyh-punktah-kr/) | Verified (article read) |
| Earlier figures | 99.2 % of population in 4G coverage; 2,210 of 2,227 settlements (2025). ITU: 4G 99.4 %, 2G/3G 99.6 % of population (2024) | [Economist.kg 2025-11-06](https://economist.kg/society/2025/11/06/kyrghyzstan-udierzhivaiet-lidierstvo-po-okhvatu-mobilnoi-sviaziu-v-tsientralnoi-azii/); [ITU DataHub](https://datahub.itu.int/data/?e=KGZ) via [02](02-kyrgyz-context.md) | Partly verified |
| Mobile speed (national) | Ookla median download 52.09 Mbps (end of 2025, +21.6 % in a year) | [DataReportal Digital 2026 Kyrgyzstan](https://datareportal.com/reports/digital-2026-kyrgyzstan) | Verified |
| Upload and latency (national) | 51.63 Mbps down, 14.77 Mbps up, 20 ms (Speedtest Global Index, Nov 2025; the article does not say median or mean) | [Economist.kg 2025-12-30](https://economist.kg/novosti/2025/12/30/mobilnyi-intierniet-v-kyrghyzstanie-uskoriaietsia-chto-pokazal-noiabrskii-rieitingh-speedtest/) | Verified (article read) |
| Broadband share of connections | 96.1 % of mobile connections are 3G/4G/5G (GSMA Intelligence, end of 2025); rural population 61.3 % | [DataReportal 2026](https://datareportal.com/reports/digital-2026-kyrgyzstan) | Verified |
| Time on 4G | 88.8 % 4G availability (Q4 2022) | [GSMA](https://www.gsma.com/get-involved/gsma-membership/gsma_resources/central-asia-embarks-on-5g-while-4g-is-still-lacking) | Partly verified (old) |
| Rural or FAP-level speed | Not published | [02](02-kyrgyz-context.md) | Not found |
| Data price | USD 0.15/GB average prepaid, cheapest USD 0.10 (Cable.co.uk via 24.kg, Dec 2021). A 2026 league table snippet gives USD 0.05/GB | [24.kg 2021](https://24.kg/english/216491_Kyrgyzstan_takes_2nd_place_in_worldwide_mobile_data_pricing_ranking/); [broadband.co.uk league](https://www.broadband.co.uk/mobile-data-price-league) (snippet; page returned 403) | Verified (2021); Partly verified (2026) |
| International transit | A presidential decree gave state-owned ElCat a temporary monopoly on international Internet traffic from 2025-08-15 to 2026-08-14. Its status after that date was not checked | [24.kg 2025-07-29](https://24.kg/english/337806_Kyrgyzstan_introduces_temporary_state_monopoly_on_international_Internet_traffic) | Verified (article); later status Unverified |
| Health-facility IT | Many medical facilities lack a computer and Internet. The MoH planned 200 "Digital FAP" kits, which include an electrocardiograph and link to Sanarip Clinic (announced Jan 2025; delivery not confirmed) | [Kaktus](https://kaktus.media/doc/375519_elektronnoe_zdravoohranenie_v_kyrgyzstane._kak_eto_sviazano_so_zdorovem_kajdogo.html) (snippet); [Economist.kg 2025-01-28](https://economist.kg/all/2025/01/28/kyrghyzstan-vniedrit-tsifrovyie-fapy-dlia-uluchshieniia-miedobsluzhivaniia-v-otdaliennykh-rieghionakh/) | Partly verified; Verified |

What this means (Researcher inference):
- National averages are dominated by urban users. A settlement counted as "covered" can still
  have no signal inside a FAP building or in a side valley. Uploads must be queued and retried,
  and no result may depend on the network.
- Data cost is not a barrier. One case at 1 MB is about USD 0.0001 at USD 0.10/GB (computed).
- Users abroad and servers abroad reach each other through international transit, which until
  August 2026 was run by a single state gateway. A server inside Kyrgyzstan avoids that dependency.
  We have no evidence that the gateway caused outages.
- If the Digital FAP kits export a digital ECG signal, the photo digitiser can be skipped for
  those devices (open question Q3).

### 1.2 Phones

| Fact | Value | Source | Status |
|---|---|---|---|
| Vendors (StatCounter, mobile, Oct 2026) | Xiaomi 37.2 %, Apple 20.8 %, Samsung 19.0 %, Tecno 5.3 %, Realme 3.3 %, Infinix 3.1 % | [StatCounter vendor](https://gs.statcounter.com/vendor-market-share/mobile/kyrgyzstan) | Verified (page read) |
| Android versions (mobile+tablet, Oct 2026) | 16: 35.1 %, 15: 20.3 %, 14: 14.9 %, 13: 13.4 %, 12: 5.7 %, 11: 4.1 %. About 84 % are on Android 13 or newer (computed) | [StatCounter Android versions](https://gs.statcounter.com/android-version-market-share/mobile-tablet/kyrgyzstan) | Verified |
| RAM / chipset in Kyrgyzstan | No local data found. Typical budget models sold in the region: Redmi A3 (3 GB), Redmi 14C (4-8 GB, Helio G-series), Tecno Spark 8C (3 GB, Unisoc T606) | [Smartprix](https://www.smartprix.com/mobiles/xiaomi_redmi_a3_vs_tecno_spark_20c-cpd1uw0v3lqr_pd19pfkrnz9.php), [Beebom](https://gadgets.beebom.com/compare/tecno-spark-8c-vs-redmi-14c-5g) (snippets) | Partly verified |
| Spec | Offline-first. Targets: offline run under 20 s on an average Android phone; server processing under 10 s over 3G (C-42) | [spec v2](../spec/v2/ECG-AI_KG_TS_v2.md) | Verified (repo) |

StatCounter measures web traffic, not unit sales. A feldsher's phone may be older and cheaper than
the average browsing device (Researcher inference). The benchmark should therefore include a
3-4 GB MediaTek or Unisoc phone, not only a Snapdragon.

### 1.3 Hardware acceleration on budget phones

- **NNAPI is deprecated** since Android 15. Google points developers to LiteRT (in Play
  Services) and the GPU delegate instead ([NNAPI migration guide](https://developer.android.com/ndk/guides/neuralnetworks/migration-guide)). Partly verified (official page, seen as snippet).
- **LiteRT NPU support** through `CompiledModel` covers Qualcomm and MediaTek NeuroPilot. The
  MediaTek page lists Dimensity 9300/9400/9500, which are flagship chips
  ([LiteRT NPU](https://developers.google.com/edge/litert/next/npu), [MediaTek blog](https://developers.googleblog.com/en/mediatek-npu-and-litert-powering-the-next-generation-of-on-device-ai/)). Partly verified.
  Researcher inference: on Helio G and Unisoc phones the realistic targets are the CPU (XNNPACK)
  or the GPU (OpenCL/OpenGL), not an NPU.

## 2. The current pipeline, step by step

| Step | Compute | Network needed? | Where it can run today |
|---|---|---|---|
| Capture, page detection, blur/glare checks | Classic CV (OpenCV), ms per frame | No | Phone (Verified as standard practice in [04](04-digitisation.md) s5) |
| Hough rotation | Classic CV | No | Phone or server |
| nnU-Net segmentation (113.5 M params, 454 MB fp32, patch 1024x1280, 13 classes) | ~300 GMAC per patch or more (computed lower bound, see note); 15-30 s per image on an RTX 3060 Ti (project measurement) | - | Server or laptop. On a phone only after training a smaller model (section 3) |
| Vectorisation (mask to signal) | Classic numpy/Python | No | Server. On a phone only after porting from Python to Dart/Kotlin (or using Chaquopy) |
| Rhythm safety net (NeuroKit2 rules) | Tiny | No | Anywhere. NeuroKit2 is Python, so the phone needs a port or an embedded Python runtime. [Chaquopy](https://github.com/chaquo/chaquopy) is MIT on GitHub (Partly verified). |
| 12-lead classifier (future, 1D CNN, a few MB) | Tens of ms on phones ([05](05-classification.md)) | No | Phone |

Note on the compute estimate (computed): a 9-stage 2D U-Net with features 32-64-128-256-512x5,
two 3x3 convolutions per stage and 2x2 transposed convolutions comes to about 300 GMAC per
1024x1280 patch and about 59 M parameters. The measured 113.5 M parameters means the real network
has more weights, mostly in the low-resolution stages. Those stages add few MACs, so 300 GMAC is a
lower bound. One 32-channel fp32 feature map at full patch size is 168 MB. Counting the skip
connections, peak working memory is probably 0.8-1 GB in fp32 (computed, rough).

Parameter count (project measurement, resolved): the checkpoint's state dict has 448 tensors
totalling 160.7 M values, but 144 of them (`decoder.encoder.*`) are the encoder again, because
the nnU-Net decoder keeps a reference to the encoder. Without those duplicates the network has
**113.5 M parameters = 454 MB in fp32**, which matches the 475 MB checkpoint file (the rest is
optimizer state and metadata, saved with shared storage).

The 15-30 s GPU time is long for one forward pass. It probably includes sliding-window tiles,
test-time mirroring and possibly a fold ensemble, plus vectorisation (Researcher inference). nnU-Net
can turn mirroring off and use a larger tile step, at some cost in accuracy
([example predictor settings](https://huggingface.co/AI4MIRO/nnUNet_Brain_EPTN/blob/70986d2d210dc039e8325c25d1c5150386e6dc42/predict_nnunet.py),
Partly verified). These are settings, not training.

## 3. On-device options for the digitiser

### 3.1 Compression

| Technique | Needs training? | Effect | Evidence | Status |
|---|---|---|---|---|
| Post-training INT8 quantisation (static, per-channel weights) | **No.** Needs about 100-1,000 unlabelled calibration images (synthetic ECG-Image-Kit photos are fine) | Weights about 4x smaller (113.5 M params gives about 114 MB, computed). Faster on CPUs and NPUs with int8 support | ONNX Runtime: quantisation cuts 32-bit weights by about 4x ([ORT mobile tutorial](https://onnxruntime.ai/docs/tutorials/mobile)). An ExecuTorch segmentation example shrinks from 12.9 MB to 3.5 MB with 100 calibration images ([Arm course](https://learn.arm.com/courses/executorch-on-arm/android-semantic-segmentation/quantize-and-validate-the-int8-model/quantize-lr-aspp-to-int8/)) | Verified (Arm page); Partly verified (ORT) |
| INT8 effect on thin structures | - | No direct study found. A road-scene U-Net's thinnest class (lane marks) dropped only 88.30 to 87.99 IoU with per-tensor INT8 | [arXiv 2507.16556](https://arxiv.org/pdf/2507.16556) (snippet) | Partly verified. Must be measured as SNR on our set |
| Dynamic-range / weight-only int8 | **No** | Smaller file, smaller speed gain | Recipes `dynamic_wi8_afp32`, `weight_only_wi8_afp32` in ai-edge-quantizer ([LiteRT CLI codelab](https://codelabs.developers.google.com/codelabs/litert-cli/101)) | Partly verified |
| Pruning (structured / channel) | **Yes, in practice.** Pruning without fine-tuning usually loses accuracy (Researcher inference, general ML practice) | Smaller and faster if structured | - | Unverified for this task |
| Knowledge distillation into a small U-Net or MobileNet-UNet | **Yes.** The student is trained on teacher outputs over many synthetic images, on a GPU | A 3D nnU-Net teacher (102 M) distilled to a 1/4-width student (6.4 M, -94 %) kept 98.7 % of Dice (80.58 vs 81.65) and cut CPU time from 82.7 s to 27.2 s | [arXiv 2601.09191](https://arxiv.org/html/2601.09191v1) (read) | Verified (brain MRI, not ECG) |
| Lower input resolution | No training if the model tolerates it, but nnU-Net expects its training spacing | Compute falls with pixel count. Thin traces may break | - | Researcher inference. Risky without retraining |

Size of a small student (computed with the same counter, 6 stages, at 1024x1280): base width 8
(8-128 channels) gives 1.3 M parameters and about 18 GMAC. Base width 16 (16-256) gives 5.2 M
parameters and about 72 GMAC. Depthwise-separable (MobileNet-style) blocks would cut MACs further
(Researcher inference).

### 3.2 Export paths and Flutter packages

| Path | Notes | Status |
|---|---|---|
| PyTorch -> ONNX -> ONNX Runtime Mobile | nnU-Net v2 has an ONNX export PR ([#1826](https://github.com/MIC-DKFZ/nnUNet/pull/1826)); its merge status was not checked. Export needs a fixed patch-size dummy input ([discussion #1144](https://github.com/MIC-DKFZ/nnUNet/discussions/1144)). The ORT Android package supports the XNNPACK and NNAPI execution providers ([XNNPACK EP](https://onnxruntime.ai/docs/execution-providers/Xnnpack-ExecutionProvider.html)) | Partly verified |
| PyTorch -> LiteRT (`litert-torch`, formerly ai-edge-torch) | `litert_torch.convert(model.eval(), sample_inputs).export("x.tflite")`; quantise with ai-edge-quantizer ([repo](https://github.com/google-ai-edge/litert-torch), [Google guide](https://ai.google.dev/edge/litert/models/convert_pytorch)) | Partly verified |
| PyTorch -> ExecuTorch | Native PyTorch path; XNNPACK on CPU, Vulkan GPU experimental | Partly verified |
| Classic-CV parts (Hough, vectorisation, rhythm rules) | Must be rewritten in Dart/Kotlin with OpenCV, or embedded with Chaquopy | Researcher inference |

| Flutter package | Version / age (on 2026-11-04) | Licence | Notes | Status |
|---|---|---|---|---|
| [`flutter_litert`](https://pub.dev/packages/flutter_litert) | 3.9.4, about 3 weeks old, verified publisher | Apache-2.0 | Fork of `tflite_flutter`. XNNPACK CPU, GPU delegate on Android, `CompiledModel` for GPU/NPU (float32 only, known accuracy issues, so validate the model first). 31 likes | Verified |
| [`flutter_onnxruntime`](https://pub.dev/packages/flutter_onnxruntime) | 1.9.0, about a month old, verified publisher | MIT | ORT 1.28 on Android. Execution-provider configuration supported. Handles the Play Store 16 KB page-size requirement from 1.5.1 | Verified |
| [`executorch_flutter`](https://pub.dev/packages/executorch_flutter) | 0.8.0, about 6 weeks old, 12 likes | MIT | XNNPACK default; Vulkan experimental with known PowerVR bugs; needs Flutter 3.38+ | Verified |
| [`onnxruntime`](https://pub.dev/packages/onnxruntime) | 1.4.1, about 2 years old, unverified uploader | MIT | Stale; avoid | Verified |
| [`tflite_flutter`](https://pub.dev/packages/tflite_flutter) | 0.12.1, 12 months old | Apache-2.0 | Labelled work-in-progress; avoid for new code | Verified |

This matches [08](08-dev-tooling-and-agent-skills.md) and ADR 0006: `flutter_litert` first and
`flutter_onnxruntime` as fallback. Both are now actively published, and `flutter_onnxruntime`
looks better maintained than the `onnxruntime_v2` package listed in 08.

### 3.3 Realistic latency and memory on phones

No published benchmark was found for a 1-5 M parameter segmentation U-Net at about 1024 px on a
mid-range Android CPU. The nearest anchors:

| Anchor | Numbers | Source | Status |
|---|---|---|---|
| Qualcomm U-Net (31.0 M params, 640x1280, about 600 GMAC computed), INT8 w8a8, NPU | Snapdragon 8 Gen 3: 25 ms; 8 Gen 1: 48 ms; **7 Gen 4: 71 ms**; low-tier Dragonwing Q-6690: about 1.0-1.05 s. Peak memory up to 180-330 MB. Float on 8 Gen 1: about 240 ms. INT8 file 29.8 MB. Model licence GPL-3.0 | [HF qualcomm/Unet-Segmentation](https://huggingface.co/qualcomm/Unet-Segmentation) | Verified (NPU only; no CPU numbers) |
| Older TFLite CPU benchmarks | U-Net at 224x224: 415 ms on Snapdragon 845, 1.93 s on Snapdragon 430. DeepLabV3 at 513x513: 845 ms / 5.2 s | [mobile_semantic_segmentation](https://github.com/SpirinEgor/mobile_semantic_segmentation) | Verified (old, undated) |
| Desktop CPU, Open-ECG-Digitizer full pipeline | 16.78 s mean on CPU vs 5.88 s on GPU (Intel i9-14900KF / RTX 5090 class) | [arXiv 2510.19590](https://arxiv.org/html/2510.19590v1) | Verified (times); hardware from a summary, Partly verified |
| ECGLight, CPU only | "<30 s per ECG", hardware not stated | [arXiv 2607.07683](https://arxiv.org/abs/2607.07683) | Verified (abstract) |
| Distilled 3D nnU-Net student on a server CPU | 27 s vs 83 s for the teacher (3D volume, Xeon Silver 4116) | [arXiv 2601.09191](https://arxiv.org/html/2601.09191v1) | Verified |

Estimates (Researcher inference, to be replaced by experiment E3):
- Scaling the 224x224 U-Net CPU times by the 26x larger pixel count of a 1024x1280 patch gives
  about 11 s (Snapdragon 845) to 50 s (Snapdragon 430) per patch for a model of that size.
- Assuming 5-50 GMAC/s effective on a budget-to-mid phone CPU with XNNPACK (unverified
  assumption): the student at 18 GMAC takes about 0.4-4 s, the student at 72 GMAC about 1.5-15 s,
  and the current teacher (300+ GMAC per patch, several patches) takes minutes at the low end.
  The teacher also needs about 160 MB of int8 weights and several hundred MB of activations.
- Teacher-sized compute is not impossible on a phone with a supported NPU: the 600 GMAC Qualcomm
  U-Net runs in 71 ms on a Snapdragon 7 Gen 4. But few phones at FAPs are likely to have such a
  chip (section 1.2).
- Memory on 3-4 GB phones: Android may kill an app in the background that holds about 1 GB
  (Unverified). A 1-5 M parameter int8 student, using about 50-200 MB at runtime, would be safe.

### 3.4 Smaller or lighter digitisers in the literature

| Tool | Size / runtime | Licence | Usable under ADR 0001? | Status |
|---|---|---|---|---|
| Open-ECG-Digitizer (Ahus) | Residual U-Net, widths 32-320, 8 blocks, plus a lighter text U-Net; parameter count not found. 16.78 s CPU / 5.88 s GPU on a desktop. No mobile or ONNX notes | CC BY-SA 4.0 ([04](04-digitisation.md)) | Baseline only | Verified (times), Partly verified (widths) |
| ECGLight (SCAI-Lab, 2026) | Four YOLOv11 detectors plus small classifiers; CPU <30 s; Streamlit app, no phone app | Non-commercial academic licence ("commercial use strictly prohibited"); Ultralytics YOLO is AGPL ([repo](https://github.com/SCAI-Lab/ECGLight)) | No | Verified |
| ECGtizer | Classical binarisation and splitting plus a small PyTorch autoencoder for lead completion. Inputs PDF/PNG/JPG; no perspective correction | Unlicense ([repo](https://github.com/UMMISCO/ecgtizer)) | Yes, but not built for photos | Verified |
| ECGMiner (CMPB 2024) | Classical: layout recognition, grid removal, signal extraction | Article CC BY-NC-ND; code licence not found ([UVa repository](https://uvadoc.uva.es/handle/10324/72927)) | Unknown | Partly verified |
| Smartphone app (Heart 2024) | Detection plus segmentation models; runtime and licence not found | Not found ([04](04-digitisation.md)) | Unknown | Partly verified |
| PMcardio | Under 7 s; closed and commercial. Whether it runs on the phone was not found | Closed | No | Partly verified |

No permissively licensed, mobile-sized and photo-validated ECG digitiser was found. Researcher
inference: the only no-training route to an on-device signal is classic CV. It is most promising
on simple inputs: the long rhythm strip, or the 3 long channels of a portable thermal printer,
which are the common case at FAPs ([00](00-synthesis.md), spec C-30). The steps would be colour or
grey thresholding to remove the grid, column-wise trace tracking, grid-period scaling, and R-peak
detection, giving heart rate and RR irregularity only. That is enough for the rhythm red flags
(very slow or very fast rate, irregular rhythm) but not for ST analysis.

## 4. Server and hybrid options

### 4.1 What a hybrid looks like

1. **On the phone, always offline:** guided capture, page detection, blur/glare checks, EXIF
   strip, crop or mask of name text ([DMP](../privacy/DATA_MANAGEMENT_PLAN.md) s5). Then
   classic-CV rhythm-strip extraction, rhythm rules and the quality gate. Output: red if a
   dangerous rhythm is clearly found, otherwise **grey "full analysis pending / treat clinically"**.
   Never green offline. That follows the never-green rule, because a negative rhythm check
   does not exclude ACS (Researcher inference, consistent with ADR 0004 point 6).
2. **Queue:** the case is stored locally (Drift). The upload runs when a signal appears, only with
   consent, with retry and idempotent requests (ADR 0006).
3. **On the server:** full 12-lead digitiser plus quality gate plus classifier plus rules, using the
   same output format and rule versions as the phone. The result is pushed back to the phone, and
   the case can be forwarded to a cardiologist.
4. **Parity:** both paths log model and rules versions. Parity tests on a fixed set are already
   required by ADR 0006.

Clinical-safety note (Researcher inference): a delayed 12-lead result must not delay referral.
The offline screen should say what to do now, using protocol text, and that the full result will
follow. This needs cardiologist review before a pilot (AGENTS.md).

### 4.2 Image size, bandwidth and latency

| Item | Value | Status |
|---|---|---|
| Raw phone photo (12 MP JPEG) | About 2.5-5 MB | Unverified (typical, not sourced) |
| Upload after on-phone rectify plus resize (long side about 2,000-2,500 px, JPEG q85) | About 0.3-1 MB | Researcher inference; measure in E4 |
| Upload time for 1 MB | 8 s at 1 Mbps, 1.6 s at 5 Mbps, 0.5 s at 14.77 Mbps (national average upload) | Computed |
| Upload time for 4 MB (unresized) | 32 s at 1 Mbps, 6.4 s at 5 Mbps | Computed |
| Data cost per case (1 MB) | About USD 0.0001-0.00015 | Computed from section 1.1 |
| Server compute now | 15-30 s per image on an RTX 3060 Ti | Project measurement. Above the C-42 target of 10 s; tune inference settings (section 2) |
| Network round trip | About 20 ms national average; to an EU server, add international transit (not measured) | Partly verified / Unverified |

### 4.3 Hosting

| Option | Facts | Data protection | Cost | Status |
|---|---|---|---|---|
| Kyrgyzstan data centre | DataTime, Bishkek, Tier III, more than 500 kW, opened Oct 2024 ([RackCorp](https://www.rackcorp.com/network/datacenters/kyrgyzstan/datatime/)); DataDome, "first commercial DC" ([DCD](https://www.datacenterdynamics.com/en/news/datadome-launches-kyrgyzstans-first-commercial-data-center-in-bishkek/)); ProHost colocation; VPS resellers (e.g. [THE.Hosting](https://the.hosting/en/vps-vds-kyrgyzstan-bishkek)). **No GPU cloud found in KR** ([getdeploying](https://getdeploying.com/datacenters-in-kyrgyzstan)) | No cross-border transfer. Simplest under Digital Code Art. 89 ([07](07-regulatory-ethics.md)) | Colocation or VPS prices not found. A GPU means bringing our own server | Partly verified |
| MoH on-premises | Possible requirement for a government deployment ([07](07-regulatory-ethics.md)); MoH runs e-health servers ([24.kg](https://24.kg/obschestvo/288782_shveytsariya_peredala_kompyuteryi_gruppam_semeynyih_vrachey_kyirgyizstana/), snippet) | Best fit for state systems | Unknown | Partly verified |
| EU cloud | CPU VPS about EUR 6-20/month ([08](08-dev-tooling-and-agent-skills.md)); Hetzner GPU GEX44 EUR 184/month at launch, now replaced by GEX45 at about EUR 214/month ([Hetzner](https://www.hetzner.com/news/new-gpu-server); [wz-it comparison](https://wz-it.com/en/blog/hetzner-gpu-server-comparison/)) | Cross-border transfer. Needs an adequacy-list country or consent (Art. 89). Unlawful cross-border transfer fine: 65,000 soms for a legal entity; registration in the personal data register is required ([Economist.kg](https://economist.kg/exclusive/2025/09/10/komu-i-zachiem-rieghistrirovatsia-v-rieiestrie-piersonalnykh-dannykh-kr-i-chiem-ghrozit-otkaz-obzor-economist-kg.md)) | Low | Verified (Hetzner launch price); Partly verified (GEX45) |
| Laptop at the project (POC only) | The existing RTX 3060 Ti machine | No real patient data (DMP s3: none until hosting is decided) | Zero extra | Verified (repo policy) |

Load estimate (computed): 100 FAPs x 5 ECGs per day = 500 images per day. At 30 s each that is
about 4.2 GPU-hours per day, which one GPU handles easily. On CPU only, at an assumed 2-5 minutes
per image (unmeasured), it is 17-42 core-hours per day, which a few CPU cores can handle if results
may arrive asynchronously.

## 5. Comparison

| Option | Runs where | Works offline | Needs training? | Latency (est.) | Phone RAM/storage | Privacy | Cost | Verdict |
|---|---|---|---|---|---|---|---|---|
| A. Current teacher on phone (fp32 or INT8 PTQ) | Phone | Yes | No (PTQ only) | Minutes on budget CPUs; seconds only on rare NPUs (inference) | About 160-640 MB weights plus 0.3-1 GB activations | Best | None per case | Not viable for target phones; benchmark once to confirm |
| B. Small student (1-5 M) on phone | Phone | Yes | **Yes** (distillation or own training) | About 0.4-15 s (inference) | 2-20 MB | Best | GPU training time | Best long-term option, but conflicts with "no training" |
| C. Classic CV only on phone (rhythm strip) | Phone | Yes | No (engineering only) | Under 1 s (inference) | Negligible | Best | Developer time | Do it as the offline safety net; rhythm only |
| D. Server only | Server | **No** | No | Upload 1-8 s plus 15-30 s compute now | Thin client | Photo leaves the phone | Server | Violates offline requirement; not alone |
| E. **Hybrid (C on phone + current digitiser on server)** | Both | Partly (rhythm offline, 12-lead when online) | No | Instant rhythm; 12-lead when connected | Small | Photo uploaded with consent; host in KR/MoH | Server plus maintenance | **Recommended now** |
| F. Hybrid now, B later | Both | Fully, once B ships | Later, yes | Same as E, then B | Small | Same as E, then best | Training later | **Recommended path** |

## 6. Recommendation and staged path

1. **POC (now):** keep the digitiser on the laptop or server. Measure CPU-only and tuned-GPU
   times (E1, E2). Build the phone capture flow, the quality gate and the upload queue against a
   local server, with test data only.
2. **Pilot or product v1 (hybrid, no training):** the phone runs capture, the quality gate,
   classic-CV rhythm extraction, rhythm rules and grey/red output offline. When online, and with
   consent, the server runs the full digitiser and classifier and returns the 12-lead result.
   Host in Kyrgyzstan or at the MoH (ADR 0007 is still open). Never green without the full
   analysis. Run the classifier on the phone once a signal comes back, or on the server, whichever
   is simpler; it is small either way.
3. **Long term (on-device 12-lead):** only when a small digitiser exists that meets the C-42
   target (under 20 s) and matches the server's SNR on the own-photo set. That needs training
   (ADR 0004 Stage 2, or distillation from the BSD-2 teacher, which is allowed under the
   licences), done by someone else or later. INT8 PTQ alone is worth one test (E3) but is
   unlikely to be enough for budget phones.
4. **ADR 0006:** propose an amendment from "on-device first" to "hybrid by default for the 12-lead
   digitiser; on-device for capture, quality, rhythm and classifier". Re-evaluate after E3.

## 7. Experiments that decide it

| # | Experiment | Needs training? | Decides |
|---|---|---|---|
| E1 | Run the current pipeline **CPU only** on the laptop (mirroring off, tile step 0.5 vs 0.9, single fold) on 20 synthetic photos: time per image, peak RAM, SNR change | No | Whether a cheap CPU server (EUR 6-20/month) is enough, or a GPU is needed |
| E2 | Count real parameters and MACs (e.g. `fvcore`/`ptflops`); export to ONNX (PR #1826 route) and to LiteRT; INT8 static PTQ with 200 calibration images; compare SNR fp32 vs int8 | No | Whether INT8 keeps trace fidelity (parameter count already resolved: 113.5 M, section 2) |
| E3 | Benchmark the exported fp32/int8 model with `benchmark_model` (LiteRT) and `onnxruntime_perf_test` on 2-3 real phones: a 3-4 GB Helio/Unisoc, a mid Snapdragon 6/7, and an Android 11-12 phone | No | Whether option A is viable on any target tier (expected: no) |
| E4 | Upload test: rectify plus resize plus JPEG on the phone; measure size and SNR loss vs the original; time the uploads from a rural site or with a 3G network profile | No | Image budget and server path end-to-end time vs C-42 (under 10 s) |
| E5 | Classic-CV rhythm-strip prototype: HR and RR irregularity on printed synthetic strips and phone photos vs reference signals | No | Whether the offline red-flag path is reliable enough to ship |
| E6 | Distil a 1.3 M and a 5 M student (section 3.1) from the teacher on synthetic images; compare SNR and phone time | **Yes** | Whether long-term on-device 12-lead digitisation is realistic |

Decision rule (proposed): if E3 shows that any int8 model runs in under 20 s and under about
500 MB RAM on the budget phone with no SNR loss in E2, revisit full on-device. Otherwise ship
hybrid (option E) and plan E6.

## 8. Open questions

| # | Question | Who / how |
|---|---|---|
| Q1 | MACs and test-time settings (folds, mirroring, tile step) of the shipped model (parameter count resolved: 113.5 M) | Measure (E2) |
| Q2 | Which phones do feldshers actually carry (RAM, chipset, Android version)? Are work phones provided? | Author, then a short field survey |
| Q3 | Do the MoH "Digital FAP" kits' electrocardiographs export a digital signal (and in which format)? If so, the photo path is not needed for them | Author, MoH |
| Q4 | Is signal available inside typical FAP buildings, and with what upload speed? | Field test (E4) |
| Q5 | Must health data be hosted in KR or at the MoH (DMP P1)? Is Germany or the EU on the Art. 89 adequacy list? | Lawyer; DPA site |
| Q6 | Is a delayed (store-and-forward) 12-lead result clinically acceptable if the offline screen gives rhythm red flags and protocol-based next steps? | Cardiologist, after the POC |
| Q7 | GPU hosting or colocation prices in Bishkek (DataTime, DataDome) | Ask the providers |
| Q8 | Status of the international-traffic monopoly after 2026-08-14 and its effect on reaching servers abroad | Desk check |
| Q9 | Who would train a small on-device digitiser (E6), if anyone? | Author |
| Q10 | Chaquopy current licence and commercial terms, if Python is embedded for NeuroKit2 rules | Read the official site |

## Sources

- Connectivity: [Economist.kg 2026-08-13](https://economist.kg/society/2026/08/13/mobilnaya-svyaz-v-naselennyh-punktah-kr/) (read); [Economist.kg 2025-11-06](https://economist.kg/society/2025/11/06/kyrghyzstan-udierzhivaiet-lidierstvo-po-okhvatu-mobilnoi-sviaziu-v-tsientralnoi-azii/) (snippet); [DataReportal 2026](https://datareportal.com/reports/digital-2026-kyrgyzstan) (read); [Economist.kg Speedtest Nov 2025](https://economist.kg/novosti/2025/12/30/mobilnyi-intierniet-v-kyrghyzstanie-uskoriaietsia-chto-pokazal-noiabrskii-rieitingh-speedtest/) (read); [GSMA 2023](https://www.gsma.com/get-involved/gsma-membership/gsma_resources/central-asia-embarks-on-5g-while-4g-is-still-lacking) (snippet); [ITU DataHub](https://datahub.itu.int/data/?e=KGZ) (via 02); [24.kg data price 2021](https://24.kg/english/216491_Kyrgyzstan_takes_2nd_place_in_worldwide_mobile_data_pricing_ranking/) (read); [broadband.co.uk league](https://www.broadband.co.uk/mobile-data-price-league) (snippet; 403); [24.kg ElCat decree](https://24.kg/english/337806_Kyrgyzstan_introduces_temporary_state_monopoly_on_international_Internet_traffic) (read).
- Health IT: [Economist.kg Digital FAPs](https://economist.kg/all/2025/01/28/kyrghyzstan-vniedrit-tsifrovyie-fapy-dlia-uluchshieniia-miedobsluzhivaniia-v-otdaliennykh-rieghionakh/) (read); [Kaktus e-health](https://kaktus.media/doc/375519_elektronnoe_zdravoohranenie_v_kyrgyzstane._kak_eto_sviazano_so_zdorovem_kajdogo.html) (snippet); [24.kg computers](https://24.kg/obschestvo/288782_shveytsariya_peredala_kompyuteryi_gruppam_semeynyih_vrachey_kyirgyizstana/) (snippet).
- Phones: [StatCounter vendor](https://gs.statcounter.com/vendor-market-share/mobile/kyrgyzstan), [StatCounter Android versions](https://gs.statcounter.com/android-version-market-share/mobile-tablet/kyrgyzstan) (read); [Smartprix](https://www.smartprix.com/mobiles/xiaomi_redmi_a3_vs_tecno_spark_20c-cpd1uw0v3lqr_pd19pfkrnz9.php), [Beebom](https://gadgets.beebom.com/compare/tecno-spark-8c-vs-redmi-14c-5g) (snippets).
- Android acceleration: [NNAPI migration guide](https://developer.android.com/ndk/guides/neuralnetworks/migration-guide) (snippet, official); [LiteRT NPU](https://developers.google.com/edge/litert/next/npu), [MediaTek NPU and LiteRT](https://developers.googleblog.com/en/mediatek-npu-and-litert-powering-the-next-generation-of-on-device-ai/) (snippets).
- Export and runtimes: [litert-torch](https://github.com/google-ai-edge/litert-torch), [LiteRT PyTorch guide](https://ai.google.dev/edge/litert/models/convert_pytorch), [LiteRT CLI codelab](https://codelabs.developers.google.com/codelabs/litert-cli/101) (snippets); [ORT mobile tutorial](https://onnxruntime.ai/docs/tutorials/mobile), [ORT XNNPACK EP](https://onnxruntime.ai/docs/execution-providers/Xnnpack-ExecutionProvider.html) (snippets); [nnU-Net PR #1826](https://github.com/MIC-DKFZ/nnUNet/pull/1826), [discussion #1144](https://github.com/MIC-DKFZ/nnUNet/discussions/1144) (snippets); [Arm ExecuTorch INT8 course](https://learn.arm.com/courses/executorch-on-arm/android-semantic-segmentation/quantize-and-validate-the-int8-model/quantize-lr-aspp-to-int8/) (read).
- Flutter packages (read): [flutter_litert](https://pub.dev/packages/flutter_litert), [flutter_onnxruntime](https://pub.dev/packages/flutter_onnxruntime), [executorch_flutter](https://pub.dev/packages/executorch_flutter), [onnxruntime](https://pub.dev/packages/onnxruntime), [tflite_flutter](https://pub.dev/packages/tflite_flutter); [Chaquopy](https://github.com/chaquo/chaquopy) (snippet).
- Benchmarks and compression: [Qualcomm U-Net card](https://huggingface.co/qualcomm/Unet-Segmentation) (read); [mobile_semantic_segmentation](https://github.com/SpirinEgor/mobile_semantic_segmentation) (read); [KD for nnU-Net, arXiv 2601.09191](https://arxiv.org/html/2601.09191v1) (read); [INT8 road-scene U-Net, arXiv 2507.16556](https://arxiv.org/pdf/2507.16556) (snippet); [nnU-Net predictor settings example](https://huggingface.co/AI4MIRO/nnUNet_Brain_EPTN/blob/70986d2d210dc039e8325c25d1c5150386e6dc42/predict_nnunet.py) (snippet).
- Digitisers: [Open-ECG-Digitizer paper, arXiv 2510.19590](https://arxiv.org/html/2510.19590v1) (read, partial); [Open-ECG-Digitizer repo](https://github.com/Ahus-AIM/Open-ECG-Digitizer) (read); [felixkrones/ECG-Digitiser](https://github.com/felixkrones/ECG-Digitiser) (read: BSD-2, weights via Git LFS, no runtime figures, nnU-Net fork); [ECGLight paper](https://arxiv.org/abs/2607.07683), [ECGLight repo](https://github.com/SCAI-Lab/ECGLight) (read); [ECGtizer](https://github.com/UMMISCO/ecgtizer) (read); [ECGMiner](https://uvadoc.uva.es/handle/10324/72927) (snippet).
- Hosting and law: [RackCorp DataTime](https://www.rackcorp.com/network/datacenters/kyrgyzstan/datatime/), [DCD DataDome](https://www.datacenterdynamics.com/en/news/datadome-launches-kyrgyzstans-first-commercial-data-center-in-bishkek/), [getdeploying KR](https://getdeploying.com/datacenters-in-kyrgyzstan), [THE.Hosting](https://the.hosting/en/vps-vds-kyrgyzstan-bishkek) (snippets); [Hetzner GEX44](https://www.hetzner.com/news/new-gpu-server), [wz-it comparison](https://wz-it.com/en/blog/hetzner-gpu-server-comparison/) (snippets); [Economist.kg personal-data register and fines](https://economist.kg/exclusive/2025/09/10/komu-i-zachiem-rieghistrirovatsia-v-rieiestrie-piersonalnykh-dannykh-kr-i-chiem-ghrozit-otkaz-obzor-economist-kg.md) (read); Digital Code Art. 89 via [07](07-regulatory-ethics.md).
- Rejected or deprioritised: eSIM reseller price pages (tourist prices); SpeedOf.Me (small sample); low-quality VPS SEO pages; Start.io device lists (undated); AI-Benchmark archive (no 1024 px segmentation numbers found).
