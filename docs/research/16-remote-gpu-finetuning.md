# Research 16 - Fine-tuning the ECG digitiser on a remote GPU VM

Date accessed for all sources: 2026-11-07. Status: draft for the developer. No third-party code was run, no weights downloaded, no cloud resource created. Nothing here is legal advice or clinical guidance.

Labels: **Verified** = read on the cited page in this session. **Partly verified** = from a search-result summary or an aggregator page. **Unverified** = memory or a source that could not be opened. **Inference** = my own reasoning or estimate.

## Summary

1. **Workflow is short.** Convert the images and masks to an nnU-Net v2 dataset, reuse the pretrained model's plans, run `nnUNetv2_train ... -pretrained_weights <checkpoint_final.pth>`. For 100-300 images one fold ("all", or fold 0) is enough. (Verified command; details section 1.)
2. **A 24 GB GPU is the practical minimum, an A100 40 GB the comfortable choice.** A T4 16 GB probably cannot hold a 59.2 M-parameter model at patch 1024x1280 (Inference, unmeasured). Estimated 5-14 h and roughly 10-20 USD per 100-epoch run (Inference; prices Partly verified).
3. **Cheapest sensible path:** Lambda A10 24 GB 1.29 USD/h or A100 40 GB 1.99 USD/h (Verified, price list effective 2026-11-16). AWS g5.xlarge (A10G) 1.006 USD/h on demand (Partly verified).
4. **Data rule:** upload only public or synthetic data and own photos of printed synthetic pages. Never patient data, real patient ECG photos or LITFL images (checklist, section 3).
5. **Licences:** ECG-Digitiser repo is BSD-2-Clause and nnU-Net is Apache-2.0 (both Verified). Open-ECG-Digitizer weights and code are CC BY-SA 4.0, so a fine-tuned copy must be shared under the same licence (section 4).
6. **Biggest scientific risk is leakage**, not compute. Split by patient (PTB-XL `strat_fold` already does), and keep the real-photo test set physically separate (section 5).

---

## 1. nnU-Net v2 fine-tuning from a pretrained checkpoint

### 1.1 What the official docs say (Verified)

Source: [nnU-Net `pretraining_and_finetuning.md`](https://github.com/MIC-DKFZ/nnUNet/blob/master/documentation/pretraining_and_finetuning.md).

- Fine-tune command: `nnUNetv2_train FINETUNING_DATASET CONFIG FOLD -pretrained_weights PATH_TO_CHECKPOINT`.
- "When loading pretrained weights, all layers except the segmentation layers will be used." So the encoder and decoder weights load; the last 1x1 output layer is re-initialised.
- Plan transfer: `nnUNetv2_move_plans_between_datasets -s SRC -t TGT -sp SRC_PLANS -tp TGT_PLANS`. Doc quote: "EVERYTHING is transferred between the datasets" (batch size, patch size, normalisation). The doc's own flow plans on the fine-tuning set and moves those plans to the pretraining set. We have the reverse situation (checkpoint already exists), so we must make our new dataset use the **checkpoint's** plans.
- There are no fine-tuning-specific trainers; the doc recommends plain `nnUNetTrainer`, and custom trainers may add LR warm-up, head-only tuning or shorter training.

### 1.2 What the ECG-Digitiser repo documents (Verified)

Source: [felixkrones/ECG-Digitiser README](https://github.com/felixkrones/ECG-Digitiser) (the URL `physionet-challenge-2024` returns 404; the correct repo is `ECG-Digitiser`).

- Dataset folder `Dataset500_Signals`, synthetic printouts rendered with ecg-image-kit from PTB-XL, splits from `ptbxl_database.csv`.
- Example commands: `nnUNetv2_plan_and_preprocess -d 500 --clean -c 2d --verify_dataset_integrity`, `nnUNetv2_train 500 2d 0 -device cuda --c`.
- Weights are in `models/` via Git LFS (`models/M3` used in the example). Licence BSD-2-Clause.
- Not stated in the README: epochs, trainer name, GPU. The figures (59.2 M parameters measured by us, corrected from an earlier 113.5 M), patch 1024x1280, 13 classes, 1000 epochs and 66,600 images come from the task brief and were not re-checked here (Unverified in this note; research 04 covers the paper).

### 1.3 Minimum workflow for 100-300 images (Inference built on 1.1 and 1.2)

1. Environment on the VM: Python venv, PyTorch with CUDA, `pip install nnunetv2` (pin the same version the repo uses; check its requirements first). Set `nnUNet_raw`, `nnUNet_preprocessed`, `nnUNet_results`.
2. Build `Dataset501_PhotoFT/` with `imagesTr/`, `labelsTr/`, `dataset.json`. Copy the **exact** `channel_names`, `labels` (13 classes, same integer ids) and `file_ending` from the pretrained model's `dataset.json`. A class-id mismatch silently corrupts the output head.
3. Labels for photos: the cheapest source is to render the synthetic page (known trace mask from ecg-image-kit), print it, photograph it, then **warp the mask** to the photo (homography from page corners). Hand-labelling 13 classes at 1024x1280 is expensive. Warping accuracy limits label quality (Inference).
4. `nnUNetv2_plan_and_preprocess -d 501 --verify_dataset_integrity -c 2d`, then replace the generated plans with the checkpoint's plans (`nnUNetv2_extract_fingerprint` + `nnUNetv2_move_plans_between_datasets`, or copy `nnUNetPlans.json` from the pretrained results folder and re-run `nnUNetv2_preprocess -plans_name ...`). Goal: identical architecture, patch size and normalisation, otherwise the checkpoint will not load or will mismatch.
5. Train: `nnUNetv2_train 501 2d FOLD -pretrained_weights /path/checkpoint_final.pth -device cuda`. Use a shorter trainer (nnU-Net ships variants named like `nnUNetTrainer_100epochs`; Unverified, check `nnunetv2/training/nnUNetTrainer/variants/training_length/` in the installed package) and a lower LR (custom trainer, e.g. `initial_lr = 1e-3`; default 1e-2 is aimed at training from scratch; Inference).
6. Folds: with 100-300 images, 5-fold CV multiplies cost by 5. Use one fixed patient-level split (section 5) for model selection, then, if wanted, a final run on "all". nnU-Net's own fold split is random per image; supply `splits_final.json` by hand to keep it patient- and page-disjoint.
7. Download only `checkpoint_final.pth` plus plans/dataset JSON, then delete the VM and disk.

---

## 2. GPU memory, time and cost

### 2.1 Memory (Inference; not measured)

- nnU-Net's own hardware page could not be opened (404), so no official VRAM figure was verified.
- Rough arithmetic: 59.2 M parameters in fp32 = 0.23 GB; with AdamW/SGD state and gradients about 1.5-2 GB. Activations dominate: a PlainConvUNet at 1024x1280 with 32-base features and several stages is likely 10-20 GB per sample at fp16/AMP. Therefore:
  - **T4 16 GB:** likely out of memory or forced to batch 1 plus a smaller patch (which breaks plan compatibility). Not recommended.
  - **L4 / A10 / A10G 24 GB:** probably fits batch 1-2 with AMP. Slow.
  - **A100 40 GB:** comfortable. Treat as the default.
- Confirm on day one with a 2-epoch smoke test and `nvidia-smi`; the numbers above are a guess.

### 2.2 Time (Inference)

nnU-Net default is 250 iterations per epoch. 100 epochs = 25,000 iterations regardless of image count (300 images just means each is seen about 80 times with strong augmentation). Assumed 0.5-1 s/iter on A100, 1.2-2 s/iter on A10G/L4, so about **3.5-7 h (A100)** and **8-14 h (A10G/L4)**. 50 epochs halves these. CPU data loading (augmentation of 1024x1280 images) can bottleneck; choose a VM with 8+ vCPUs and a fast local disk. g5.xlarge has only 4 vCPUs (Partly verified), so g5.2xlarge may be needed (Inference).

### 2.3 Prices (USD per hour, checked 2026-11-07)

| Provider / instance | GPU | On demand | Spot / cheaper | Source and status |
|---|---|---|---|---|
| AWS g4dn.xlarge, us-east-1 | T4 16 GB | 0.526 | about 0.20-0.27 | [DoiT](https://www.doit.com/compute/spot/us-east-1/g4dn.xlarge), [DevZero](https://www.devzero.io/instances/aws/g4dn.xlarge). Partly verified (aggregators; AWS's own page lists no prices) |
| AWS g5.xlarge, us-east-1 | A10G 24 GB | 1.006 | about 0.49-0.65 | [DoiT](https://www.doit.com/compute/spot/us-east-1/g5.xlarge), [DevZero](https://www.devzero.io/instances/aws/g5.xlarge). Partly verified; other aggregators show conflicting figures (0.43, 0.18), I discarded them |
| GCP T4 (GPU only, us-central1) | T4 16 GB | 0.35 + VM | not found | [Google GPU pricing](https://cloud.google.com/products/compute/gpus-pricing) via search summary. Partly verified |
| GCP g2-standard-4 | L4 24 GB | about 0.71 incl. vCPU/RAM | about 0.42 GPU only (3rd party, dated 2026-08-18) | [Google accelerator-optimized pricing](https://cloud.google.com/products/compute/pricing/accelerator-optimized?hl=en), [computeprices](https://computeprices.com/providers/google/gpus/l4). Partly verified |
| Lambda | A10 24 GB | 1.29 | n/a | [Lambda pricing](https://lambda.com/pricing). **Verified**, but the page says these prices take effect 2026-11-16 |
| Lambda | A100 40 GB | 1.99 | n/a | same page. Verified (same caveat) |
| RunPod | L4 24 GB | about 0.39-0.49 | n/a | [RunPod pricing](https://runpod.io/pricing) via search summary; pages disagree. Partly verified |
| RunPod | A100 PCIe | about 1.19 (Community) to 1.64 (Secure, 80 GB) | n/a | same. Partly verified; no clean 40 GB figure found |

Not found: A100 40 GB on AWS (p4d is 8 GPUs, much larger) and GCP a2-highgpu-1g; Vast.ai prices were not checked (peer-hosted machines; see the data-protection note below). Add storage (100-200 GB SSD about 10-20 USD/month, Unverified) and egress (small).

### 2.4 Budget (Inference = hours x price)

- One 100-epoch run on Lambda A100 40 GB: about 5 h x 1.99 = **about 10 USD** (range 7-14).
- One run on AWS g5.xlarge on demand: about 11 h x 1.006 = **about 11 USD**; on spot about 6 USD but interruptions need `--c` (continue) resume, which nnU-Net supports (Verified in the repo README example, flag `--c`).
- A full experiment (smoke test, 3 hyper-parameter variants, 1 final run) is therefore about 40-80 USD. No budget is committed; the author must approve any spend.

---

## 3. Data-protection checklist for a cloud VM

Consistent with AGENTS.md: no patient data, real ECG photos, secrets or datasets/weights in git. Items below are my recommendations (Inference), not provider documentation, unless noted.

**May be uploaded:**
- PTB-XL (CC BY 4.0, Verified at [PhysioNet](https://physionet.org/content/ptb-xl/1.0.3/); records are pseudonymised) and synthetic images rendered from it.
- Own photos of printed synthetic pages (no person, no name, no hospital stamp).
- The released pretrained checkpoint and plans.

**Must never be uploaded:** patient data of any kind; photos of real patient ECGs (including from Kyrgyz clinics, pending ethics approval); LITFL images (copyright, see research 12); API keys, SSH private keys, cloud credentials in the dataset folder; the git history of this repo (copy only what is needed).

**Procedure:**
1. **Review the upload folder manually** before `scp/rsync`: open every photo, check EXIF (GPS, device owner) and strip it (`exiftool -all=`). Keep a manifest (file, source, licence).
2. **Region:** pick a region of the cloud provider that fits the team's data-residency wishes (EU is the safest default for a CH/EU-linked project; the repo has no stated requirement, Unverified). With public/synthetic data only, residency is not a legal blocker.
3. **Encryption:** enable encrypted volumes (AWS EBS and GCP persistent disks encrypt at rest by default in current offerings, Unverified here; verify in the console). Use SSH key login only, no password, no public ports other than 22 restricted to your IP. Transfer over SSH.
4. **Secrets:** use a fresh, least-privilege cloud account or project; no personal credentials on the VM; no `git push` from the VM with a personal token (pull artefacts back by `scp` instead).
5. **Marketplace hosts (Vast.ai-style):** machines belong to third parties, so treat as untrusted; use only for fully public data. Prefer AWS/GCP/Lambda/RunPod Secure Cloud for anything beyond that (Inference).
6. **Spend control:** set a budget alert and an auto-stop timer before starting; spot/preemptible with checkpoint resume.
7. **Teardown:** copy out `checkpoint_final.pth`, plans, logs; `shutdown`, then **terminate** the instance, delete the attached volume, snapshots and any static IP, and check the billing console the next day. Stopping alone still bills for disks.
8. **Record** in `temp/` the run log (date, commit of the training code, data manifest hash). Weights go to `data/` or a model store, never git.

---

## 4. Licence consequences

| Item | Licence | Status | Consequence for a fine-tune |
|---|---|---|---|
| felixkrones/ECG-Digitiser code and `models/` | BSD-2-Clause | Verified ([README](https://github.com/felixkrones/ECG-Digitiser)); the README does not separately say that the weights have the same licence | Keep the copyright notice and licence text in source and binary redistributions; no share-alike. Fine-tuned weights are most likely a derivative that may be kept closed, but ask the authors if weights are to be shipped (Inference). |
| nnU-Net v2 | Apache-2.0 | Verified ([LICENSE](https://github.com/MIC-DKFZ/nnUNet/blob/master/LICENSE)) | Keep notices; patent grant; state changes. Compatible with BSD-2. |
| PTB-XL | CC BY 4.0 | Verified (PhysioNet) | Attribute (Wagner et al., 2020). Synthetic images derived from it carry the attribution duty. |
| Open-ECG-Digitizer code and weights | CC BY-SA 4.0 | Verified in research 04 (LICENSE read); the README fetched today does not state a licence for `weights/` | Fine-tuned weights are an "adapted material": must be released under CC BY-SA 4.0 (or a compatible licence) with attribution, a note of changes and the requested citation (npj Digit Med 2026, doi 10.1038/s41746-025-02327-1, Verified in README). This binds only if we distribute the adapted weights or code; running them privately is not distribution. A closed MoH build would conflict (research 04). Whether model weights count as "adapted material" is untested law (Unverified). |
| Own photos of printed synthetic pages | ours, derived from PTB-XL | Inference | Publish under CC BY 4.0 with PTB-XL attribution if released. |

Recommendation: if licence flexibility matters, fine-tune the BSD-2 + Apache-2 stack (ECG-Digitiser) and use Open-ECG-Digitizer only as a benchmark or as a public, share-alike component. Seek legal advice before any distribution of Open-ECG-Digitizer derivatives.

---

## 5. Risks and how to split

**Overfitting with 300 photos (Inference).**
- 300 photos are tiny next to 66,600 pretraining images; the model can memorise the paper, lighting and phone of a few sessions. Mitigations: freeze nothing but use low LR and short training; keep strong augmentation (nnU-Net default); mix 1:1 with synthetic PTB-XL pages so the model does not forget; vary printer paper, phones, lighting, folds, shadows, angles; stop on validation SNR, not training loss.
- Photos of the same printed page are not independent: 10 photos of one page count as roughly 1 sample for generalisation.
- Catastrophic forgetting of the 13 classes: monitor per-class Dice on a held-out synthetic set as well.
- Mask warping errors (section 1.3) put a ceiling on label quality; check 20 masks by eye.

**Test leakage (PTB-XL; Verified rules).**
- PTB-XL has several records per patient. The `strat_fold` column keeps all of one patient's records in one fold; the authors recommend folds 1-8 train, 9 validation, 10 test ([PhysioNet](https://physionet.org/content/ptb-xl/1.0.3/)). Folds 9-10 also have better label quality.
- nnU-Net's internal random 5-fold split ignores patients and pages. Always provide your own `splits_final.json`.

**Proposed split (Inference).**
1. **Test (never touched during tuning):** PTB-XL fold 10 records, printed and photographed in a **separate session** with a different phone/paper/lighting from training; plus a small set of different-layout pages. Report SNR per lead, not only Dice.
2. **Validation:** fold 9 records, photographed separately; used for early stopping and LR choice.
3. **Train:** records from folds 1-8; each record's synthetic render and all its photos go to the same side. Split by **record id and patient id**, never by photo.
4. Generate every augmentation or re-render of a page **after** the split, not before.
5. Do not reuse the pretrained model's training records in your test set: the winners trained on PTB-XL, so check the repo's split file (Unverified which folds were used) and prefer test records the base model never saw, otherwise reported gains are inflated. Real held-out photos from clinics (after ethics approval) remain the only honest final test.
6. Report results as decision-support quality of digitisation only; any downstream clinical claim needs the cardiologist review (AGENTS.md).

## Sources not opened / gaps

- nnU-Net `hardware_requirements.md` (404 at the guessed path), the AWS EC2 pricing page (not fetched; used aggregators), Vast.ai and GCP spot GPU prices.
- Real training speed and VRAM: need the 2-epoch smoke test on the chosen VM.
- Whether the ECG-Digitiser released weights were trained on PTB-XL folds that overlap with our test fold.
