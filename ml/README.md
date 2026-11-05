# ml/ - rule-based rhythm safety net

Transparent, rule-based checks on a **single ECG lead** (mV + sampling rate), as described in
[ADR 0005](../docs/adr/0005-classifier-approach.md). No neural network, no training, no
datasets. In the final system the urgency is the highest of the network and these rules.

## What it does (`ecg_rules/`)
- R-peak detection (NeuroKit2), heart rate, RR irregularity (CV, RMSSD/mean), crude QRS width.
- Rules, each returning a `RuleResult` (finding, evidence, thresholds used, source):
  tachycardia / bradycardia, "irregular rhythm - possible AF", "very fast broad-complex
  rhythm - possible VT" (only if QRS width could be estimated), "very slow regular rate -
  possible high-grade AV block", and a signal-quality gate (flatline, clipping, HF noise,
  too short, too few beats, implausible rate, low sampling rate).
- `assess(signal, fs)` aggregates: highest urgency wins (red > yellow > green); a failed
  quality gate gives **grey ("cannot interpret")** and never green.
- All numbers live in `ecg_rules/thresholds.py`. Each is either cited from
  `docs/research/01-clinical-domain.md` or marked `PENDING_REVIEW`.

## Run the tests
```
cd ml
python -m venv .venv
.venv/Scripts/python -m pip install -e ".[dev]"     # Linux/macOS: .venv/bin/python
.venv/Scripts/python -m pytest
```

## Limits
- Tested on **synthetic** NeuroKit2 signals only. **Not validated** on real or photo-derived
  ECGs, not a diagnosis, and not clinical guidance (AGENTS.md clinical-safety rule).
- Thresholds not cited are developer drafts pending cardiologist review (C1).
- The QRS-width estimator is crude and uncalibrated (synthetic QRS is narrower than real);
  the VT screen may under-fire or mis-fire on real data. The AV-block screen cannot see P
  waves; "sinus" is never claimed. The AF screen uses RR irregularity only.
- Quality failure returns grey even if a rule would have fired (the data is untrusted).

## Next steps
1. Add a script that downloads PTB-XL into `data/` (git-ignored); no data in git.
2. Evaluate each rule per [docs/eval/PROTOCOL.md](../docs/eval/PROTOCOL.md) (patient-wise
   folds, sensitivity/specificity with CIs, abstention rate; "limited evidence" classes
   reported as such); use VFDB/CUDB for VT/VF rule tests.
3. Calibrate the QRS estimator against annotated durations; tune thresholds on validation
   folds only; cardiologist review of all `PENDING_REVIEW` values.
