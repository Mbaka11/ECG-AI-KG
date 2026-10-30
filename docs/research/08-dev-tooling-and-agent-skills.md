# 08 — Development tooling and AI-agent skills

Scope: tools that help one developer (using the "pi" agent, which reads `SKILL.md` Agent Skills and MCP servers) build ECG-AI KG: Flutter app, FastAPI backend, admin panel, and the Python ECG/ML pipeline.
Date of research: 2026-10-29. Package/skill ecosystems move fast, so **re-check versions before pinning**.

Verification labels: **Verified** = I read the source page (or a tool-fetched copy of it); **Partly verified** = seen only in a search-result snippet or a secondary aggregator; **Unverified** = from memory or inference.

## Summary

- **Official Flutter tooling exists and is first-party.** The Dart SDK ships an MCP server (`dart mcp-server`), and the Flutter team publishes `flutter/agent-plugins` (skills + MCP config + rules; BSD-3-Clause, ~3.1k stars at fetch time). Install both for Phase 4 (Verified/Partly verified).
- **Kyrgyz (`ky`) is in `GlobalMaterialLocalizations`.** The API doc lists `ky - Kirghiz Kyrgyz`, so Material widgets (date pickers, dialogs, back buttons) can be localised to Kyrgyz out of the box. Your own app strings still need ARB files (Verified).
- **Avoid `isar` and original `hive` for new work** (stale). `drift` is actively maintained and is the sensible default for offline storage; `hive_ce` is an option for simple key-value data (Partly verified, from a search-engine summary of pub.dev version pages).
- **On-device ML:** `tflite_flutter` is still labelled "work-in-progress" on its own page; `flutter_litert` (Apache-2.0, API-compatible with `tflite_flutter`) looks like the better-maintained option. Treat as a candidate to benchmark in the POC, not a settled choice (Verified for the tflite_flutter notice; Partly verified for flutter_litert's claims).
- **Document capture:** `google_mlkit_document_scanner` is **Android-only (beta)**. `cunning_document_scanner` covers Android and iOS (ML Kit on Android, Apple Vision on iOS) and falls back to a manual crop on devices without Google Play Services (Verified from pub.dev READMEs). Both give perspective-corrected crops, which fits the "photo of paper ECG" step but not ECG-specific grid/lead detection.
- **Skills worth adding now are research-oriented:** `K-Dense-AI/scientific-agent-skills` (MIT; includes `neurokit2`, `literature-review`, `pytorch-lightning`), `openags/paper-search-mcp`, `anthropics/skills` (`skill-creator`, `frontend-design`, `pdf`/`docx`) and, later, Hugging Face skills. Everything third-party can execute code or inject prompts: **pin to a commit and read before installing**.
- **ECG Python stack is mature and permissively licensed:** `wfdb` (MIT), `neurokit2` (MIT), `ecg-image-kit` (BSD-3), `torch_ecg` (MIT), `ecglib` (Apache-2.0). Check dataset licences separately (see other research notes).
- **Admin panel:** for one developer, **SQLAdmin** (BSD-3, FastAPI/Starlette) is the cheapest start; React-admin/Refine only if MoH needs dashboards beyond CRUD. A small EU VPS costs on the order of €6–20/month (Partly verified).

## A. Agent skills and MCP servers

| Item | What it is / source | Licence, activity (as seen) | Use in THIS project | Verdict |
|---|---|---|---|---|
| **Dart & Flutter MCP server** (`dart mcp-server`) | Built into the Dart SDK: analyzer errors, symbol lookup, tests, formatting, pub.dev search, running-app introspection. Docs: <https://docs.flutter.dev/ai/get-started>, <https://pub.dev/packages/dart_mcp_server> | Part of Dart SDK (BSD-style; exact licence not checked). Official. | Core for Phase 4 Flutter work: lets the agent run analyzer/tests instead of guessing. | **Install in Phase 4** (config is one JSON block: `command: dart, args: [mcp-server]`). Partly verified (search summary of docs). |
| **flutter/agent-plugins** (also reachable as `flutter/skills`) | Official Flutter team skills, MCP config and rules. Skills seen in README: `flutter-add-integration-test`, `flutter-add-widget-test`, `flutter-apply-architecture-best-practices`, `flutter-build-responsive-layout`, `flutter-fix-layout-issues`, `flutter-implement-json-serialization`, `flutter-setup-declarative-routing`, `flutter-setup-localization`, `flutter-use-http-package`, plus `dart-*` skills. <https://github.com/flutter/agent-plugins> | BSD-3-Clause; ~3,088 stars; created 2026-02-25; an open issue (#202) proposes migrating to Apache-2.0. A `flutter/skills` repo showed ~2.6k stars and the same content, so the two may be mirrors/rename — I could not confirm which is canonical. | `flutter-setup-localization` (ru/ky/en), widget/integration test skills, architecture skill. | **Install in Phase 4**, pin a commit. Verified (repo structure, licence); canonical-repo question unresolved. |
| **zakariaf/Flutter-Skills** | Community, ~40 Flutter skills (`skills/<name>/SKILL.md`). <https://github.com/zakariaf/Flutter-Skills> | Licence/activity not checked. | Possibly fills gaps (offline storage, Riverpod). | **Skip for now**; review later. Partly verified. |
| **Anthropic `anthropics/skills`** | Official example skills. Folder listing read: `frontend-design`, `skill-creator`, `webapp-testing`, `mcp-builder`, `doc-coauthoring`, `docx`, `pdf`, `pptx`, `xlsx`, `theme-factory`, `canvas-design`, etc. <https://github.com/anthropics/skills> | Many skills Apache-2.0; **`docx/pdf/pptx/xlsx` are "source-available, not open source"**; README says skills are demonstration/educational. | `skill-creator` (to write own project skills, e.g. an "ECG safety review" skill); `frontend-design` (admin panel / web mockups, *web-oriented*, not Flutter); `pdf`/`docx` for MoH documents and spec work; `webapp-testing` for admin panel. | **Install now:** `skill-creator`. **Later (Phase 4/6):** `frontend-design`, `pdf`, `docx`, `webapp-testing`. Verified. |
| **obra/superpowers** | Software-development methodology as skills (brainstorming, TDD, subagent-driven development, writing skills). <https://github.com/obra/superpowers> | MIT; ~308k stars, last push 2026-10-23, v7.0.1 released ~2026-10-21 (Partly verified: aggregator and GitHub snippets). Very high star count and fast growth — popularity is not a security audit. | Process discipline (plan → test → review) for a solo dev. May be heavy/opinionated for docs-heavy Phases 1–2. | **Later (Phase 3/4)**, try on a branch. |
| **K-Dense `scientific-agent-skills`** (formerly `claude-scientific-skills`) | Large collection of research/science skills. README claims; skills incl. `neurokit2` (ECG/biosignals), `literature-review`, `scientific-writing`, `citation-management`, `pytorch-lightning`, `database-lookup`, `pyhealth`. <https://github.com/K-Dense-AI/scientific-agent-skills> | MIT; README badge "Version 2.72.0"; star counts seen: 17–19k (varies by aggregator). Repo ~460 MB. **No explicit `wfdb` or PhysioNet skill found** (not found in the extracted content; could not read the full tree). README says healthcare/biosignal skills are research-only, not for diagnosis or deployment. | Literature review (Phase 1–2), neurokit2 usage hints (Phase 3), paper writing. | **Install selectively now** (copy only `literature-review`, `neurokit2`, `scientific-writing`, `citation-management`, optionally `pytorch-lightning`; do not vendor 460 MB). Partly verified. |
| **openags/paper-search-mcp** | MCP server + CLI + `SKILL.md` for searching/downloading papers from 20+ sources (arXiv, PubMed, bioRxiv, Semantic Scholar, Crossref…). <https://github.com/openags/paper-search-mcp> | Licence not read. README mentions optional Sci-Hub support — **do not enable it** (legal/ethical risk, and the repo is public). | Phase 1 literature sweeps; ECG digitisation/classification papers. | **Install now**, pin commit, use open-access sources only. Partly verified. |
| **huggingface/skills** | Skills for HF Hub, datasets, model training, evals, experiment tracking (`hf-cli`, `huggingface-llm-trainer`, `huggingface-datasets`, …). <https://github.com/huggingface/skills> | Apache-2.0; ~11.2k stars; created 2025-11-24. | Model hosting/versioning and training jobs in Phase 3; our models are small CNNs, not LLMs, so only some skills apply. | **Later (Phase 3)**: `hf-cli`, `huggingface-datasets`. Partly verified. |
| **datalayer/jupyter-mcp-server** | MCP for live Jupyter notebooks. <https://github.com/datalayer/jupyter-mcp-server> | Licence not checked. | Notebook-driven ECG experiments in Phase 3. | **Later (Phase 3)**, optional. Partly verified. |
| **Figma MCP server** | Official, hosted at `mcp.figma.com`; reads designs, default output React+Tailwind (other frameworks via prompt). <https://developers.figma.com/docs/figma-mcp-server/> | Figma product (plan/seat limits not checked). | Only if you design screens in Figma; output is web-biased, so Flutter code needs manual adaptation. | **Skip** unless a designer joins. Partly verified. |
| **Maestro + Maestro MCP** | Mobile E2E testing with YAML flows; Flutter supported via the semantics tree; `maestro mcp`. <https://github.com/mobile-dev-inc/maestro>, <https://docs.maestro.dev/get-started/supported-platform/flutter> | Apache-2.0. Repo says physical iOS devices are not yet supported. | Black-box UI tests incl. language switching, offline mode. Complements `flutter_test`/`integration_test`. | **Later (Phase 4/5)**. Partly verified (search summary). |
| **Playwright MCP** (`@playwright/mcp`) | Official Microsoft browser-automation MCP. <https://github.com/microsoft/playwright-mcp> | Apache-2.0. | Test the MoH admin panel only. | **Later (Phase 4, admin panel)**. Partly verified. |
| Flutter UI design / accessibility skills (generic) | I did not find a trustworthy, specific Flutter-UI or accessibility skill. | — | Use `flutter-build-responsive-layout`, Flutter's accessibility docs, and WCAG checklists by hand. | **Not found** — do not install unknown ones. |

### Security of third-party skills and MCP servers

- Skills are instructions plus optional scripts; MCP servers are programs. Both can run code or steer the agent. Published studies: skill files enable "trivially simple" prompt injection ([arXiv 2510.26328](https://arxiv.org/html/2510.26328)); the Skill-Inject benchmark measures agent vulnerability to malicious skill files ([arXiv 2602.20156](https://arxiv.org/abs/2602.20156)); Snyk's ToxicSkills audit reports security flaws in 36% of 3,984 skills scanned on ClawHub/skills.sh as of 5 Feb 2026, including 1,467 malicious payloads ([Snyk](https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub/)). I read only the search snippets of these, so treat the numbers as **Partly verified**.
- Practice: (1) vendor skills into your own repo at a **specific commit SHA**, never "latest"; (2) read every `SKILL.md` and any `scripts/`; (3) optionally scan with a tool such as [SkillInquisitor](https://github.com/peterkarman1/SkillInquisitor) (not evaluated); (4) run MCP servers with least privilege and no access to `data/` or secrets; (5) never give an agent real patient data or ECG photos (project rule).

## B. Flutter app stack

| Concern | Candidate | Status / notes | Licence | Recommendation |
|---|---|---|---|---|
| Document capture (Android) | `google_mlkit_document_scanner` ^0.6.1 | Beta, **Android only**, API 21+; runs via Google Play services, on-device, ~300 KB app-size impact, needs ≥1.7 GB RAM ([ML Kit doc](https://developers.google.com/ml-kit/vision/doc-scanner/android), [pub.dev](https://pub.dev/packages/google_mlkit_document_scanner)). Depends on Play Services — a risk on cheap/unlicensed devices. | MIT (README badge) | Try first for Android POC. |
| Document capture (cross-platform) | `cunning_document_scanner` | Android API 24+, iOS 13+; ML Kit (Android) / Vision (iOS); manual-crop fallback when no Play Services; project continues after the creator's passing ([pub.dev](https://pub.dev/packages/cunning_document_scanner)). Licence not read. | Unverified | Good fallback; check licence and last release date before adopting. |
| Own edge detection | OpenCV via FFI (e.g. `opencv_dart`) | Not researched; would give grid/lead-aware rectification beyond a generic document scanner. | Unverified | Consider in Phase 3 if document scanners crop badly on ECG grids. |
| On-device inference | `flutter_litert` ^3.9.4 | `tflite_flutter`-compatible `Interpreter` API, bundles native runtimes, adds `CompiledModel` (GPU/NPU); README badge Apache-2.0 ([pub.dev](https://pub.dev/packages/flutter_litert)). Single-maintainer community package. | Apache-2.0 | **Preferred candidate**; benchmark in POC. |
| | `tflite_flutter` 0.12.x | Page says "work-in-progress", last note dated April 2023 ([pub.dev](https://pub.dev/packages/tflite_flutter)). | Apache-2.0 | Avoid for new code. |
| | `onnxruntime_v2` 1.23.2+2 | Community fork of ONNX Runtime plugin; published ~9 months before search date ([licence page](https://pub.dev/packages/onnxruntime_v2/license)). | MIT | Alternative if models are exported to ONNX; weigh maintenance. |
| Camera | `camera` (flutter.dev) | Not researched here. If ML Kit/Cunning scanner handles capture, a custom camera is optional. | Unverified (BSD-3 expected) | Add only if a custom guided-capture overlay is needed. |
| Offline storage | `drift` | Actively maintained (2.35.x published days before search) ([pub.dev](https://pub.dev/packages/drift/versions)); SQL, migrations, reactive queries. | MIT (expected; not read) | **Recommended.** |
| | `isar` 3.1.0+1 | Effectively abandoned; v4 prereleases ~3 years old; fork `isar_community` exists ([GitHub](https://github.com/isar-community/isar-community)). | — | **Avoid.** |
| | `hive` 2.2.3 | ~4 years old; fork `hive_ce` 2.22.0 active ([pub.dev](https://pub.dev/packages/hive_ce)). | — | Avoid `hive`; `hive_ce` OK for settings only. |
| i18n | `flutter_localizations` + `intl` + ARB | `ky` supported in Material/Widgets/Cupertino delegates ([API doc](https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html)); `ru`, `en` also present. | BSD-3 (Flutter) | **Use**. Kyrgyz medical wording needs a human reviewer (cardiologist/translator), not machine translation. |
| ECG charting | `fl_chart` | Popular line-chart lib ([pub.dev](https://pub.dev/packages/fl_chart)); not designed for dense 500 Hz × 10 s traces with mm-grid. | MIT (expected; not read) | OK for small plots. |
| | Syncfusion Flutter Charts | Free only under the Community License: <US$1M revenue, ≤5 developers, ≤10 employees (and ≤US$3M outside capital) ([Syncfusion](https://www.syncfusion.com/products/communitylicense)). Eligibility could change if the project is scaled or monetised. | Commercial / Community | **Avoid** (licence risk for a MoH deployment). |
| | **Custom `CustomPainter`** | Best control: ECG paper grid (1 mm = 40 ms / 0.1 mV at 25 mm/s, 10 mm/mV), calipers, overlay of detected QRS. | — | **Recommended** for the main ECG view. |
| PDF export | `pdf` + `printing` | `printing` 5.15.1 published ~40 days before search, Apache-2.0 ([licence](https://pub.dev/packages/printing/license)). | Apache-2.0 | **Use.** Check that Cyrillic/Kyrgyz glyphs (ң, ө, ү) render by embedding a font. |
| State management | `riverpod` | Flutter Favorite per README badge ([pub.dev](https://pub.dev/packages/riverpod)); bloc is an equal alternative. | MIT | Riverpod; pick one and note it in an ADR. |
| Auth | Not researched | If sync to a backend: JWT/OAuth2 via FastAPI + `flutter_secure_storage`; app must work with no login offline. | Unverified | Decide in Phase 2. |

## C. Backend and admin panel

- **FastAPI + PostgreSQL** is the obvious default for Python ML serving (Unverified in this note; standard practice). Note: if inference runs on-device, the backend mainly handles model distribution, anonymised stats/feedback, and the admin panel.
- **SQLAdmin** ([GitHub](https://github.com/smithyhq/sqladmin), PyPI v0.32.0, BSD-3-Clause, Python ≥3.10; Verified from PyPI snippet): CRUD admin on SQLAlchemy models, mounts inside FastAPI, uses Tabler UI. Fastest path to a MoH-viewable panel. A React rewrite (`spa-sqladmin`) exists but is a small third-party project.
- **React-admin / Refine / Next.js:** more flexible dashboards and role management, but a second codebase (TypeScript) for a solo developer. Not researched in detail — **Unverified**; decide in Phase 2 after the admin requirements are clear.
- **Hosting (approximate, Partly verified):** Hetzner's page lists cost-optimised cloud servers from about €5.99/month and regular-performance from €6.49/month, excluding VAT ([Hetzner](https://www.hetzner.com/cloud/)); a 4 GB CPX22 was listed at €19.99/month by a third-party aggregator ([servermarket](https://servermarket.dev/providers/hetzner/cpx22-cloud-124)). Prices change; confirm on the vendor page. **Data-residency/legal questions for Kyrgyzstan (hosting abroad, health-data law) are not covered here** — ask the author/MoH contact.

## D. ECG-specific Python tooling

| Tool | What it gives us | Licence / activity | Use |
|---|---|---|---|
| [`wfdb`](https://pypi.org/project/wfdb/) 4.3.1 | Read/write PhysioNet records and annotations | MIT (Verified, PyPI/GitHub) | Loading PTB-XL etc. |
| [`neurokit2`](https://pypi.org/project/neurokit2/) 0.2.13 | ECG cleaning, R-peak, delineation, HRV | MIT (Verified, PyPI) | Rule-based features for rate/rhythm sanity checks, baselines. |
| [`ecg-image-kit`](https://github.com/alphanumericslab/ecg-image-kit) | Synthesise ECG *images* (with distortions) from signals; digitisation tools | BSD-3-Clause; 166 stars, created 2024-01 (Partly verified: aggregator) | **Key for us:** generate photo-like paper-ECG training/test data and build a digitiser benchmark. |
| [`torch_ecg`](https://github.com/DeepPSP/torch_ecg) | PyTorch ECG models, preprocessing, training utilities | MIT; 272 stars (Partly verified) | Training baselines. |
| [`ecglib`](https://pypi.org/project/ecglib/) 1.1.1 | Pretrained ECG models and tools (ISPRAS) | Apache-2.0 (Partly verified) | Check model weights' own licence/data provenance. |
| [`openecg`](https://github.com/vitaldb/openecg) | P/QRS/T segmentation, int8 TFLite model (~1.5 MB) | Licence not read; claims beat NeuroKit2 (author's own claim) | Interesting for on-device delineation; **Unverified** quality. |

Pretrained-model licences and training-data terms (e.g. whether weights trained on restricted datasets can ship in a public app) were not checked — see other research notes / follow up in Phase 2.

## Implications for ECG-AI KG

1. **Phase 1 (now):** add research skills/MCP (list below), keep them pinned and vendored. Use `paper-search-mcp` open-access sources only.
2. **Phase 3 (POC):** Python stack = `wfdb` + `neurokit2` + `torch_ecg`/PyTorch; use `ecg-image-kit` to create synthetic photographed ECGs for the digitiser; evaluate `flutter_litert` and a document scanner on 2–3 real mid/low-end Android phones early (Play Services dependency and RAM ≥1.7 GB are real constraints for rural devices).
3. **Phase 4 (MVP):** Flutter + Riverpod + Drift + `flutter_localizations` (ru/ky/en) + `CustomPainter` ECG view + `pdf`/`printing`; install `dart mcp-server` and `flutter/agent-plugins` then. Avoid `isar`, `hive`, Syncfusion.
4. **Admin:** start with SQLAdmin behind FastAPI; revisit if MoH requirements outgrow CRUD.
5. **Safety:** K-Dense's own README disclaims clinical use; the project's decision-support framing and the rule "clinical content cites a protocol or cardiologist review" still apply — no skill replaces that.
6. **Record decisions** (state mgmt, storage, inference runtime) as short ADRs in Phase 2.

## Open questions

| Question | Who |
|---|---|
| Canonical repo for official Flutter skills (`flutter/agent-plugins` vs `flutter/skills`) and install command with pi | Developer (test in pi) |
| Do `cunning_document_scanner`, `drift`, `fl_chart`, `camera` licences/last-release dates meet our bar? (not read) | Developer, quick pub.dev check |
| Does K-Dense contain a wfdb/PhysioNet skill? (not found, tree not fully read) | Developer (clone at pinned commit) |
| Actual field devices of feldshers (Android version, RAM, Play Services?) | Author |
| Hosting location / health-data law in Kyrgyzstan | Author / MoH contact |
| Admin panel requirements (roles, dashboards, reporting) | Author |
| Kyrgyz clinical wording review | Cardiologist or medical translator after POC |

## Sources (all accessed 2026-10-29)

- Flutter AI getting started — <https://docs.flutter.dev/ai/get-started> (search summary only)
- dart_mcp_server — <https://pub.dev/packages/dart_mcp_server> (search summary only)
- flutter/agent-plugins — <https://github.com/flutter/agent-plugins> (read); flutter/skills — <https://github.com/flutter/skills/> (read, README titled "Flutter Agent Plugins"); issue #202 — <https://github.com/flutter/agent-plugins/issues/202>
- zakariaf/Flutter-Skills — <https://github.com/zakariaf/Flutter-Skills> (snippet only)
- anthropics/skills — <https://github.com/anthropics/skills> (README and folder list read)
- obra/superpowers — <https://github.com/obra/superpowers> (snippets)
- K-Dense-AI/scientific-agent-skills — <https://github.com/K-Dense-AI/scientific-agent-skills/> (partial read)
- openags/paper-search-mcp — <https://github.com/openags/paper-search-mcp> (snippets)
- huggingface/skills — <https://github.com/huggingface/skills/> (snippets)
- datalayer/jupyter-mcp-server — <https://github.com/datalayer/jupyter-mcp-server/>; Figma MCP — <https://developers.figma.com/docs/figma-mcp-server/>
- Maestro — <https://github.com/mobile-dev-inc/maestro>; Playwright MCP — <https://github.com/microsoft/playwright-mcp>
- GlobalMaterialLocalizations — <https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html> (read; `ky` listed)
- pub.dev pages read: flutter_litert, tflite_flutter, google_mlkit_document_scanner, cunning_document_scanner, fl_chart, riverpod; search snippets: drift, isar, hive, hive_ce, printing, onnxruntime_v2
- ML Kit Document Scanner — <https://developers.google.com/ml-kit/vision/doc-scanner/android>
- Syncfusion Community License — <https://www.syncfusion.com/products/communitylicense>
- SQLAdmin — <https://github.com/smithyhq/sqladmin>, <https://pypi.org/project/sqladmin/>
- Hetzner — <https://www.hetzner.com/cloud/>; <https://servermarket.dev/providers/hetzner/cpx22-cloud-124>
- ECG tools — <https://pypi.org/project/wfdb/>, <https://pypi.org/project/neurokit2/>, <https://github.com/alphanumericslab/ecg-image-kit>, <https://github.com/DeepPSP/torch_ecg>, <https://pypi.org/project/ecglib/>, <https://github.com/vitaldb/openecg>
- Skill security — <https://arxiv.org/html/2510.26328>, <https://arxiv.org/abs/2602.20156>, <https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub/>, <https://github.com/peterkarman1/SkillInquisitor>

---

## Final deliverables

### (1) Add NOW to `D:/Projects/pi-tools-and-skills` (pin each to a commit SHA, read before enabling)

| Source | Why |
|---|---|
| <https://github.com/anthropics/skills/tree/main/skills/skill-creator> | Author project-specific skills (e.g. clinical-source checker, research-note template). Apache-2.0 per repo README (verify per-folder LICENSE). |
| <https://github.com/K-Dense-AI/scientific-agent-skills> — only `literature-review`, `scientific-writing`, `citation-management`, `neurokit2` (optionally `pytorch-lightning`) | Phase 1–3 research/writing and ECG signal hints; MIT. Do not vendor the whole 460 MB repo. |
| <https://github.com/openags/paper-search-mcp> (its `claude-code/SKILL.md` + CLI/MCP) | Multi-source paper search (arXiv, PubMed…); disable Sci-Hub. |
| **Prepare for Phase 4, add later:** <https://github.com/flutter/agent-plugins> and `dart mcp-server` (<https://docs.flutter.dev/ai/get-started>) | Official Flutter skills + MCP; BSD-3. |
| **Later:** <https://github.com/huggingface/skills> (`hf-cli`, `huggingface-datasets`), <https://github.com/anthropics/skills/tree/main/skills/frontend-design> (admin UI), <https://github.com/mobile-dev-inc/maestro>, <https://github.com/microsoft/playwright-mcp> | Phase 3–4 needs. |

### (2) Recommended Flutter package stack

| Layer | Package | Maintenance status (as seen 2026-10) | Licence |
|---|---|---|---|
| State | `riverpod` | Flutter Favorite badge; active | MIT |
| Local DB | `drift` | Very active (release days before search) | MIT (expected; verify) |
| Settings | `shared_preferences` or `hive_ce` | `hive_ce` active; `shared_preferences` not checked | Verify |
| i18n | `flutter_localizations`, `intl` (ARB, ru/ky/en) | First-party; `ky` supported | BSD-3 |
| Capture | `google_mlkit_document_scanner` (Android) / `cunning_document_scanner` (Android+iOS) | Beta / maintained by community | MIT / verify |
| Inference | `flutter_litert` (fallback `onnxruntime_v2`) | Community, active; benchmark first | Apache-2.0 / MIT |
| ECG plot | `CustomPainter` (+ `fl_chart` for small charts) | n/a / popular | — / MIT (verify) |
| PDF | `pdf`, `printing` | Active (`printing` 5.15.1) | Apache-2.0 |
| Avoid | `isar`, `hive`, `tflite_flutter` (new code), Syncfusion charts | Stale / WIP / licence limits | — |
