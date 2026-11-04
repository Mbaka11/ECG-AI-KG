# ADR 0007 — App and backend stack

Status: proposed (2026-11-04; hosting open) · Phase 2

## Context
One maintainer builds everything. [Research 08](../research/08-dev-tooling-and-agent-skills.md)
recommends Flutter with Riverpod, Drift, `flutter_localizations` (ru/ky/en), `flutter_litert`,
a document scanner, CustomPainter for the ECG view and `pdf`/`printing`; it says to avoid
`isar`, `hive` and Syncfusion; and for the admin panel FastAPI + SQLAdmin first. `go_router` is
not covered in the notes (unverified: check licence and activity). FastAPI + PostgreSQL is
standard practice but unverified in the notes. The spec asked for React + PostgreSQL for the
admin panel (C-26). Data localisation in KR is unresolved
([research 07](../research/07-regulatory-ethics.md)); the maintainer's earlier answer that cloud
hosting is fine ([OPEN_QUESTIONS](../OPEN_QUESTIONS.md) section D) predates that finding.

## Decision
- **Mobile (Android first, ADR 0002):** Flutter with Riverpod (state), go_router (navigation),
  Drift (offline storage and migrations), `flutter_localizations` + `intl` + ARB for ru, en and
  ky (Kyrgyz medical wording needs a human reviewer, H-13), `flutter_litert` (ADR 0006),
  `google_mlkit_document_scanner` first with `cunning_document_scanner` as fallback (Play
  Services risk on cheap phones), `camera`, `pdf` + `printing` with an embedded font covering
  the Kyrgyz letters, ECG view via CustomPainter. Avoid isar, hive and Syncfusion. Tokens in
  `flutter_secure_storage`; the app works with no login offline. Check licence and release date
  of each package before adoption and record them in the SOUP table.
- **Backend:** Python FastAPI with PostgreSQL (SQLAlchemy). Scope: auth (JWT/OAuth2, RBAC),
  case sync, model and protocol update manifest, forwarding to an expert, anonymised
  statistics, audit log, optional heavy-path inference (ADR 0006).
- **Admin panel:** SQLAdmin (BSD-3) mounted in the FastAPI app for facilities, users, review
  flags and de-identified export. The spec requires 2FA for administrators; SQLAdmin has no
  built-in 2FA (unverified), so implement it in the auth layer. Move to React-admin or Refine
  only if the MoH needs dashboards beyond CRUD.
- **Hosting: not decided (open).** Candidates are a KR-based provider or on-premises at the
  MoH, versus an EU VPS (about EUR 6-20 per month, partly verified in research 08). The
  decision waits for the localisation answer and the MoH's wishes. Until then no real personal
  data is uploaded to any server, and the stack is containerised so it can move. Open
  questions: is in-country storage mandatory for health data; does the MoH require national
  hosting; which providers exist in KR.

## Consequences
One language family on the server, shared with the ML code. Flutter plus Drift gives a solid
offline story. SQLAdmin is quick but limited. Single-maintainer packages are the main
dependency risk.
