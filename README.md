# ECG-AI KG

**AI-assisted interpretation of paper ECGs from a smartphone photo, for remote primary care
facilities in Kyrgyzstan.**

A feldsher or general practitioner records an ECG, takes a photo of the paper strip, and the
app digitises the signal, flags suspected life-threatening patterns (acute coronary
syndrome, atrial fibrillation, ventricular tachycardia, complete AV block, …) with an
urgency level and short next-step guidance — online or offline, in Kyrgyz and Russian.

> ⚠️ **Research project — not a medical device.** Nothing in this repository is validated
> for clinical use. Results are decision support only; the final decision always rests
> with a physician.

## Status

**Phase 0 — repository setup and translation** (done) → next: **Phase 1 — research**.
See the [project plan](docs/PLAN.md).

## Documents

| Document | Link |
|---|---|
| Project plan | [docs/PLAN.md](docs/PLAN.md) |
| Open questions for the author | [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) |
| Specification — English | [md](docs/spec/en/ECG-AI_KG_TS_EN.md) · [pdf](docs/spec/en/ECG-AI_KG_TS_EN.pdf) · [docx](docs/spec/en/ECG-AI_KG_TS_EN.docx) |
| Specification — French | [md](docs/spec/fr/ECG-AI_KG_TS_FR.md) · [pdf](docs/spec/fr/ECG-AI_KG_TS_FR.pdf) · [docx](docs/spec/fr/ECG-AI_KG_TS_FR.docx) |
| Specification — Russian original | [pdf](docs/spec/original/ECG-AI_KG_TS_RU_original.pdf) · [docx](docs/spec/original/ECG-AI_KG_TS_RU_original.docx) |
| Translation notes and abbreviations | [docs/spec/TRANSLATION_NOTES.md](docs/spec/TRANSLATION_NOTES.md) |

## Repository layout

```
.
├── docs/                   Project documentation
│   ├── PLAN.md             Project plan (phases, tasks, exit criteria)
│   ├── OPEN_QUESTIONS.md   Questions for the author (EN + RU)
│   └── spec/               Original specification and its translations
│       ├── original/       Russian original (.docx, .pdf)
│       ├── en/             English translation (.md, .pdf, .docx)
│       └── fr/             French translation (.md, .pdf, .docx)
├── tools/
│   └── spec-translation/   Script that rebuilds the translated documents
├── temp/                   Local scratch space (git-ignored, except its README)
├── AGENTS.md               Working conventions for contributors and coding agents
└── README.md
```

Code folders (`ml/`, `backend/`, `mobile/`, `admin/`) will be added when their phase
starts — see the plan.

## Planned stack (from the specification, to be confirmed in Phase 1–2)

Flutter mobile app · FastAPI backend · OpenCV + segmentation model for digitisation ·
CNN + BiLSTM classifier trained on MIT-BIH and PTB-XL · TensorFlow Lite for offline use ·
React + PostgreSQL admin panel.

## Contributing

- The repository is in **English**. The app UI will be in Kyrgyz and Russian.
- **Never commit patient data, real ECG photos, credentials or large datasets/model
  weights.** Public datasets are downloaded by scripts.
- See [AGENTS.md](AGENTS.md) for conventions.

## Licence

Not chosen yet (see [open questions](docs/OPEN_QUESTIONS.md)). Until a licence is added,
all rights are reserved by the authors.
