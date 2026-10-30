# Working Conventions

- **Language:** everything in the repo is written in English (code, comments, docs, commit
  messages). Translated copies of the specification live in `docs/spec/<lang>/`.
- **Source of truth:** `docs/spec/original/` is the author's document and is never edited.
  Changes to requirements go into a new spec version (`docs/spec/v2/`, Phase 2) with the
  reason for each change.
- **Plan:** `docs/PLAN.md` drives the work. Tick tasks there when done; record answers in
  `docs/OPEN_QUESTIONS.md`.
- **Research notes:** `docs/research/NN-topic.md`, with links to every source. Mark
  unverified claims clearly.
- **Scratch files:** put temporary context, notes, downloads and experiments in `temp/`.
  Its contents are git-ignored; move anything worth keeping into `docs/` or code folders.
- **Data safety:** no patient data, real ECG photos, secrets or datasets/model weights in
  git. Datasets are downloaded into `data/` (git-ignored) by scripts.
- **Clinical safety:** the system is decision support, not a diagnosis. Clinical content
  (urgency rules, action steps) must cite an official protocol or a cardiologist review.
- **Commits:** small, descriptive, conventional style (`docs: ...`, `feat(ml): ...`).
