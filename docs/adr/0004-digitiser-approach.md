# ADR 0004 — Digitiser approach: staged, permissive-only

Status: proposed (2026-11-04; revisable after the Phase 3 bake-off) · Phase 2

## Context
[ADR 0001](0001-permissive-licence-policy.md) forbids share-alike and copyleft code and
weights in the product path, so Open-ECG-Digitizer (CC BY-SA 4.0; best open photo results:
12.19 dB OnePlus and 10.47 dB iPhone on its own data, only about 1-2 dB on Emory photos) is a
baseline only. Photo digitisation is the weakest step: the PhysioNet 2024 winner (SignalSavants,
`felixkrones/ECG-Digitiser`, BSD-2 badge) scored 12.15 dB on scans but about -1 dB on phone
photos. The open study found that a diverse training set mattered more than the choice of
segmentation network ([research 04](../research/04-digitisation.md) s1-2). Two options remain:
(A) train our own U-Net-type segmenter on synthetic ECG-Image-Kit images (BSD-3, partly
verified licence); (B) reuse the BSD-2 PhysioNet 2024 entries. Real FAP machines are probably
3- or 6-channel thermal printers ([synthesis](../research/00-synthesis.md), spec v2 C-30).
Image-dataset licences: PM-ECG-ID is GPL-3.0-or-later and the ECG-Image-Database licence is
unresolved, so both are evaluation-only ([research 09](../research/09-dataset-followup.md) s2).

## Decision
Stage the work and decide on measured SNR on the own-photo set of the
[evaluation protocol](../eval/PROTOCOL.md), not on preference.

1. **Stage 1 (Phase 3, baseline).** Run the BSD-2 SignalSavants pipeline (Hough rotation,
   nnU-Net, vectorisation) as the permissive reference. First check the licence of the bundled
   nnU-Net and of every pretrained weight file (unverified: research 04 only says to check
   nnU-Net's own licence). Run Open-ECG-Digitizer in `temp/` purely to measure the gap; it is
   never shipped.
2. **Stage 2 (Phase 3, own model).** Train our own small U-Net-type segmenter (trace, grid,
   text, background) on ECG-Image-Kit renderings of PTB-XL/CinC signals. Add local paper
   styles (grid colour, layout, Cyrillic lead labels, thermal-strip look) once sample strips
   exist (open question A1), plus photo augmentation (perspective, shadows, folds, stains).
   Ship this model if its SNR is at least that of Stage 1 on the own-photo set; otherwise
   fine-tune from, or wrap, the BSD-2 entry. Train and test on disjoint signals.
3. **Pipeline around the segmenter** (OpenCV/numpy, permissive): page quadrilateral and
   perspective rectification, segmentation, grid period by autocorrelation, layout and lead
   identification by template matching, mask-to-1D vectorisation with NaN for ambiguous
   parts, signal quality gate. No Ultralytics YOLO; if a detector is needed use an Apache-2.0
   one (research 04 s3).
4. **3- and 6-channel strips are first-class.** The layout stage has templates for 3x4, 6x2,
   12x1 and 3/6-channel strips. Lead names may be absent on thermal strips: fall back to
   channel order plus user confirmation, and restrict claims to rhythm findings when fewer
   than 12 leads are identified (C-30, H-04, H-09).
5. **Calibration detection.** Read mm per pixel from the grid; confirm speed (25/50 mm/s) and
   gain (5/10/20 mm/mV) from the printed calibration pulse or printed text. If they cannot be
   confirmed, show the assumed values and lower the claim; never silently assume 25 mm/s and
   10 mm/mV (C-34, H-03).
6. **Quality gate.** Capture-time checks (blur, glare, page coverage) and post-segmentation
   checks (grid found, leads recovered, plausible rate) return "retake" or "cannot
   interpret", never a colour (H-02, H-05). Where the segmenter runs is set by
   [ADR 0006](0006-inference-location.md).
7. A direct-image classifier (MobileNet-sized) is kept as a comparison and possible
   low-quality fallback only (research 04 s4).

## Consequences
More work than adopting Open-ECG-Digitizer, but a clean licence and a clean handover.
Synthetic-only training risks domain shift to real Kyrgyz paper; mitigate with consented real
strips kept out of git. Expect weak ST fidelity on photos, so morphology claims depend on the
protocol's digitiser rule. Mobile runtime of the segmenter is unknown (research 04: not found);
measure in Phase 3. Revisit under ADR 0001's clause if quality on real photos is clearly
blocked by the permissive rule.
