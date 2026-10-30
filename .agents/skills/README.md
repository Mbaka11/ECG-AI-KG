# Project agent skills (vendored)

Skills in this folder are loaded automatically by pi (and other agents that read
`.agents/skills/`) when working in this repository. They are **third-party,
unchanged copies**, pinned to a reviewed commit. Do not edit them in place; update by
re-copying a newer reviewed commit and recording it here.

| Skill | Use in this project | Source | Licence |
|---|---|---|---|
| `literature-review` | Systematic searches (PubMed, arXiv, Semantic Scholar…), screening, citation checks for `docs/research/` and the paper | K-Dense-AI/scientific-agent-skills | MIT |
| `citation-management` | DOI → BibTeX, metadata extraction, citation validation | same | MIT |
| `scientific-writing` | Research paper drafting with evidence provenance and reporting-guideline checks (TRIPOD+AI etc.) | same | MIT |
| `neurokit2` | ECG signal processing (R-peaks, delineation, HRV) in Phase 3 — research use, not diagnosis | same | MIT |
| `pytorch-lightning` | Training loops for the Phase 3 classifier | same | MIT repo (skill metadata says Apache-2.0) |

- Upstream: https://github.com/K-Dense-AI/scientific-agent-skills
- Commit: `5f2bc0341354fd5590aef76a533ada1e1e5b4e62` (copied 2026-10-29)
- Licence text: [LICENSE-K-Dense.md](LICENSE-K-Dense.md)

Review notes (2026-10-29): the scripts call public scholarly APIs (OpenAlex, Crossref,
PubMed, arXiv, DataCite) and read optional API keys from the environment. The
`literature-review` schematic scripts call OpenRouter only if `OPENROUTER_API_KEY` is set —
do not set it. No script uploads local files. Never run these skills on patient data.

Other skills used by the project (Anthropic `skill-creator`, `frontend-design`,
`webapp-testing`; official Flutter skills) are loaded as pinned git packages from
[`../../.pi/settings.json`](../../.pi/settings.json), not copied.
