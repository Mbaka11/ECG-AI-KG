# Working Conventions

- **Language:** everything in the repo is written in English (code, comments, docs, commit
  messages). The app UI is in Russian, Kyrgyz and English. Translated copies of the
  specification live in `docs/spec/<lang>/`.
- **Questions:** research before asking. Only ask the author what cannot be found online;
  contact the cardiologist only once a POC exists (see `docs/OPEN_QUESTIONS.md`).
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
- **Agent skills:** project skills are in `.agents/skills/` (vendored, pinned) and
  `.pi/settings.json` (pinned git packages). Review and pin any new third-party skill to a
  commit; never let a skill send patient data or ECG photos to an online service.
- **Commits:** small, descriptive, conventional style (`docs: ...`, `feat(ml): ...`).
