# ADR 0001 — Permissive licence policy for the product path

Status: accepted (2026-11-04, default proposed in the Phase 1 synthesis; revisable) · Phase 2

## Context
The project is Apache-2.0 and may be handed to a government partner. Open-ECG-Digitizer is the
best open photo digitiser but is CC BY-SA 4.0 (share-alike). Ultralytics YOLO is AGPL-3.0.
See [research 04](../research/04-digitisation.md) and [07](../research/07-regulatory-ethics.md).

## Decision
Code and model weights in the product path must be permissive (Apache-2.0, BSD, MIT).
No AGPL/GPL, no share-alike, no non-commercial licences. Such components may be used only
for research baselines in `temp/` or evaluation, never shipped. Open-ECG-Digitizer is a
reference/baseline only; we train our own U-Net-type digitiser on permissive data
(ECG-Image-Kit, BSD-3) or reuse the BSD-2 PhysioNet 2024 entries. Datasets: record each
licence; non-commercial data may train research models but weights derived from them need a
case-by-case ADR.

## Consequences
More digitiser work for us; clean handover and no copyleft surprises.
Revisit if digitiser quality on real photos is clearly blocked by this rule.
