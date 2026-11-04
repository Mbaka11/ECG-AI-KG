# ADR 0006 — Inference location: on-device first, server optional

Status: proposed (2026-11-04; revisable after on-device benchmarks) · Phase 2

## Context
FAPs may have no signal: 4G covers about 99 % of people but not every building or valley
([research 02](../research/02-kyrgyz-context.md)). Android is the target (ADR 0002). Small 1D
CNNs run in tens of ms on phones, so classification is not the bottleneck; the digitiser
segmenter is heavier and its mobile runtime is unknown
([research 05](../research/05-classification.md) s6, [04](../research/04-digitisation.md)).
Privacy law favours minimal data leaving the phone, and a cloud service can count as a
cross-border transfer ([research 07](../research/07-regulatory-ethics.md)). `tflite_flutter` is
labelled work-in-progress; `flutter_litert` (Apache-2.0, single maintainer) is the preferred
candidate to benchmark; ONNX Runtime plugins are less maintained
([research 08](../research/08-dev-tooling-and-agent-skills.md)). Offline model drift is
hazard H-12.

## Decision
- **On-device first.** The full path (capture checks, digitiser, quality gate, classifier,
  rules, report templates) runs on the phone with no network. Export models to LiteRT (int8,
  calibrated on photo-like signals) and ONNX; wrap the runtime behind a Dart interface so the
  plugin can change, with a thin Kotlin platform channel over the official LiteRT/ONNX library
  as fallback if the plugin is unmaintained.
- **Server optional.** If the segmenter is too slow or large for low-end phones (decided by a
  Phase 3 benchmark on 2-3 real mid-range Android devices; targets in C-42: under 20 s
  offline, under 10 s server), an online "heavy path" may be offered with consent. It must
  give the same output format and the same safety rules. The server is also used for model
  distribution, forwarding a case to an expert, and anonymised statistics.
- **Offline-first sync.** Cases are stored locally (last 50, Drift). A queue uploads only what
  consent allows, when online, with retry and idempotent requests; sync is never needed to see
  a result. What is synced is set in the
  [data management plan](../privacy/DATA_MANAGEMENT_PLAN.md).
- **Model versioning and update channel.** Each model and protocol-text bundle has a
  semantic version, a hash, a model-card and licence reference, and the evaluation run that
  approved it. The app checks a manifest from the backend when online (signing scheme not yet
  designed; unverified), downloads in the background, verifies the hash, switches atomically
  and can roll back. Every result records the model, rules and protocol-text versions. A
  minimum supported version lets us retire a withdrawn model, and the app warns when the
  bundle is older than a set age (H-12). Whether the pilot can use the Play Store or needs
  sideloaded APKs is unknown (open).

## Consequences
No per-inference server cost and less personal data in transit. Model size and latency budgets
constrain design. Two inference paths (device, server) need parity tests. Update logistics and
rollback add backend work (ADR 0007).
