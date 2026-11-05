# ml/digitise — photo/scan of a paper ECG → signal → rule-based safety net

Research prototype for **docs/eval/PROTOCOL.md stage S1** (digitisation) and a first end-to-end
check of the chain *image → digitiser → lead II → `ecg_rules` → urgency*. **Inference only**: no
training or fine-tuning. Decision support, not a diagnosis; rule thresholds are pending
cardiologist review.

## What is here (committed)

| File | Purpose |
|---|---|
| `run_digitiser.py` | Runs the PhysioNet 2024 winner (ECG-Digitiser) on a folder of images; writes 12-lead WFDB records (500 Hz, 10 s). Converts JPG→PNG, upscales narrow images, patches one torchvision incompatibility at runtime (no third-party file is edited). |
| `image_to_rules.py` | End to end: images → `run_digitiser.py` (in its own venv) → lead II → `ecg_rules.assess`. `--truth-dir` also runs the rules on the true signal. |
| `imagekit_page.py` | Renders WFDB records as ECG-Image-Kit pages (the style the weights were trained on) for synthetic tests with ground truth. |
| `render_page.py` | A plain matplotlib page renderer. Kept as a **negative result**: the pretrained model mis-segments it badly (see below). |
| `metrics.py`, `eval_synthetic.py` | SNR (dB) and Pearson r per lead, with column placement and a ±50-sample lag search ("project definition", close to but not the official PhysioNet scorer). Tests: `tests/test_digitise_metrics.py`. |

Nothing third-party is committed: the digitiser code, its weights, PTB-XL records, LITFL images and
all outputs live in the git-ignored `data/` folder.

## Setup (Windows, NVIDIA GPU; ~6 GB download)

```bash
cd data/third_party
git clone https://github.com/felixkrones/ECG-Digitiser.git
cd ECG-Digitiser && git checkout e6f62aa776f105e4c7b04f21669da4d4f0df370b && git lfs pull && cd ..

# digitiser venv (torch + the repo's bundled nnU-Net fork); TensorFlow etc. are not needed
uv venv --python 3.11 venv-digitiser
uv pip install --python venv-digitiser/Scripts/python.exe torch torchvision --index-url https://download.pytorch.org/whl/cu126
uv pip install --python venv-digitiser/Scripts/python.exe opencv-python wfdb matplotlib tqdm ./ECG-Digitiser/nnUNet

# optional: image-kit venv for synthetic pages (old numpy/imgaug/pandas pins)
uv venv --python 3.11 venv-imagekit
uv pip install --python venv-imagekit/Scripts/python.exe numpy==1.26.4 imgaug==0.4.0 opencv-python==4.9.0.80 \
    scikit-image==0.23.2 scipy matplotlib wfdb==4.1.2 pandas==2.2.2 pillow pyyaml imageio imutils

# ml venv (rules + glue)
cd ../../ml && uv venv .venv && uv pip install --python .venv/Scripts/python.exe -e ".[dev,digitise]"
```

Run: `ml/.venv/Scripts/python.exe -m digitise.image_to_rules IMG_DIR [--truth-dir WFDB_DIR] [--work OUT_DIR]`
(from `ml/`). About 15–30 s per image on an RTX 3060 Ti, most of it nnU-Net start-up and
test-time augmentation.

Pinned commit `e6f62aa776f105e4c7b04f21669da4d4f0df370b`; model `models/M3` (`fold_all`).
The `.pth` weights are Python pickles; accepted for **local evaluation only** from the pinned
upstream commit. Before any product use, re-export them to a non-pickle format (ADR 0001).

## Licences (product-path policy: ADR 0001, `docs/safety/SOUP_LICENCES.md`)

| Component | Licence | Use here |
|---|---|---|
| ECG-Digitiser code + weights | BSD-2-Clause | local inference |
| nnU-Net v2 (bundled fork) | Apache-2.0 | local inference |
| ECG-Image-Kit generator (bundled) | BSD-3-Clause | synthetic pages |
| PTB-XL 1.0.3 records | CC BY 4.0 | ground truth for synthetic pages |
| LITFL ECG images | CC BY-NC-SA 4.0 | **evaluation only**, never committed, shipped or trained on (`docs/research/12-litfl-ecg-library.md`) |

## Results (2026-11-04)

### A. Synthetic ECG-Image-Kit pages from PTB-XL (fold 10, human-validated labels)

Clean, upright, 200 dpi pages; no wrinkles, handwriting or photo artefacts, so this is a
**best case**.

| Record | Label | Leads | SNR median (min) | r median | Rules on image | Rules on true signal |
|---|---|---|---|---|---|---|
| 00009 | NORM | 12/12 | 15.9 dB (7.9) | 0.986 | GREEN 61/min | GREEN 61/min |
| 00180 | CLBBB | 12/12 | 13.1 dB (−0.4) | 0.976 | GREEN 93/min | GREEN 93/min |
| 00210 | IMI | 12/12 | 13.5 dB (5.5) | 0.978 | GREEN 75/min | GREEN 75/min |
| 07221 | AFIB | 12/12 | 10.7 dB (6.2) | 0.956 | YELLOW 77/min (possible AF) | YELLOW 78/min |

Overall: 48 leads, SNR median 12.5 dB, 10th percentile 5.3 dB. Lead II rhythm strip: 23.2, −0.4,
10.7 and 11.9 dB. In the −0.4 dB case the R-peaks were still right, so heart rate and the rule
result matched. **The rules gave the same urgency from the image as from the true signal in 4/4.**

With the plain matplotlib renderer (`render_page.py`) the same records failed badly: leads were
missing, columns were swapped and amplitudes saturated. The weights are tied to the ECG-Image-Kit
look (calibration pulse, lead-separator ticks, label placement), so real-world layouts need their
own check.

### B. Real LITFL web images (12 selected 3×4 tracings; labels from LITFL page titles)

Native images are about 1200×600 px. **At native size the segmentation found no leads**;
upscaling to 2200 px wide (now the default) fixed that.

| Image | LITFL label | Result | Correct triage? |
|---|---|---|---|
| litfl_0648 | normal sinus rhythm | GREEN 74/min | yes |
| litfl_0060 | AF | YELLOW, possible AF | yes |
| litfl_0058 | AF | GREY (quality) | safe fallback |
| litfl_0062 | AF, slow response | GREY (quality) | safe fallback |
| litfl_0059 | AF | **GREEN 63/min** | **no: missed AF** |
| litfl_0061 | AF | no signal extracted → app must show GREY | safe fallback |
| litfl_0720 | monomorphic VT | **YELLOW** 123/min (tachycardia + possible AF) | **no: under-triaged, VT should be RED** |
| litfl_0504 | proximal LAD occlusion (OMI) | no signal extracted → GREY | safe fallback; rules cannot see ST changes anyway |
| litfl_0622, 0624 | RBBB | GREY (quality) | safe fallback |
| litfl_0623 | RBBB | GREEN 81/min | expected (rhythm-only rules; RBBB is morphology) |
| litfl_0626 | incomplete RBBB, 2-year-old | GREEN, tachycardia 113/min | expected (paediatric, out of intended use) |

## What this means

1. **The chain works end to end** on synthetic pages and on real web images, fully offline, with
   no training.
2. **Two under-triage errors on 12 real images** (missed AF; VT shown amber instead of red). These
   are hazard H-05-type failures. Before any field use, the digitised lead II needs a
   plausibility gate (e.g. agreement between rhythm strip and short-lead R-R, amplitude and
   coverage checks) that falls back to GREY. The VT case also shows that QRS width from a digitised
   strip is unreliable, so `fast_wide_vt` should not depend on it alone.
3. **The rules only cover rhythm.** Inferior MI, LBBB, OMI and RBBB give GREEN when the rhythm is
   fine. Ischaemia detection needs the network path (ADR 0005); until it exists, the app must not
   present GREEN as "no ischaemia" (spec v2 wording rules: never "normal").
4. **Image size matters.** The pretrained weights expect ~200 dpi pages. The app's capture guide
   must ask for the full page filling the frame; phone photos are larger than these web images, but
   perspective, shadows and curl are untested here.
5. Next: run the same chain on phone photos of printed PTB-XL pages (ground truth known), and on
   the author's machine format once A1 in `docs/OPEN_QUESTIONS.md` is answered.
