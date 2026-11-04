# Data management plan

Status: **draft v0.1** · 2026-11-04 · Phase 2 deliverable. Not legal advice; the legal points
are from [research 07](../research/07-regulatory-ethics.md) and need a lawyer's check before
any pilot. Related: [ADR 0006](../adr/0006-inference-location.md),
[ADR 0007](../adr/0007-app-and-backend-stack.md), hazard H-11 and H-12 in the
[hazard list](../safety/HAZARD_LIST.md), spec v2 changes C-51 to C-54.

## 1. Principles

- **On-device first, minimal data.** Triage needs no patient name or ID; none is collected by
  default (research 07).
- **Research and POC phases use no patient data in git.** Datasets stay in git-ignored
  `data/`; own-photo test sets are printed from public-dataset signals ([AGENTS.md](../../AGENTS.md)).
- **Legal basis (KR).** The Digital Code No. 178 of 31.07.2025 (in force 2026-02-08) replaced
  Law No. 58. Health data is a special category; processing is allowed for diagnosis and care by a
  person bound by medical secrecy, and for research on **anonymised** data (Art. 80). Transfers
  abroad follow Art. 89 (adequacy list, consent or other conditions) (research 07, verified
  from a legal-text mirror, not the official portal).
- **Data localisation is open.** No statutory storage-in-KR rule was found for private apps
  (conflicting law-firm notes); a government deployment may still require national hosting.
  Hosting is undecided (ADR 0007).

## 2. What is collected

| Data | Purpose | Identifying? | Where | Notes |
|---|---|---|---|---|
| ECG photo | Input to the digitiser | Can be: paper may carry a name or ID, and metadata (EXIF, location) | Device; server only if synced with consent | Spec: kept on the server at most 30 days without the facility's explicit consent (C-53) |
| Digitised signal (per lead) | Classifier input, review, PDF | Low alone, but ECGs can be biometric (unverified) | Device; server if synced | Kept longer than the photo; for de-identified research only after de-identification |
| Age, sex | Model context, statistics | Quasi-identifier | Device; server if synced | Age band in exports |
| Symptoms (2-4 yes/no questions) | Urgency context | No | Device; server if synced | Question set pending cardiologist review |
| Results | Findings, urgency, versions | No | Device; server if synced | Include model, rules and protocol-text versions and image-quality score |
| Facility and user (role) | Access control, audit | Yes (staff) | Server | Staff accounts only |
| Audit and error logs | Security, safety review | Must not contain patient data | Server | See section 8 |
| Free-text patient name or ID | Not collected by default | Yes | Optional, off by default | Open question: do facilities need a local case reference? |

## 3. Where data lives

| Place | Content | Protection |
|---|---|---|
| Phone | Last 50 cases (spec FR-4) in the local Drift database; photos in app-private storage, not the gallery | Android app sandbox; device-level encryption; encrypted database (SQLCipher or equivalent: unverified, to evaluate); app lock; excluded from cloud backup (H-11) |
| Backend | Synced cases, users, facilities, audit log, model manifest | TLS in transit, encryption at rest, RBAC, 2FA for admins, backups with the same retention |
| Admin panel | Reads the backend; shows aggregate and de-identified data | Same as backend |
| Research store | Public datasets in `data/` (git-ignored), model weights outside git | Licences in the [SOUP table](../safety/SOUP_LICENCES.md) |

Hosting location (KR, on-premises at the MoH, or abroad) is **open** (ADR 0007). Until decided,
no real personal data goes to any server and any pilot runs in on-device mode. A cloud
service counts as a cross-border transfer under the old law (research 07); the Digital Code
analogue was not read.

## 4. Retention

| Data | Retention | Basis |
|---|---|---|
| Photo on server | At most 30 days, unless the facility consents explicitly | Spec (C-53) |
| Photo on device | Deleted after a successful sync or after 30 days, whichever is first; the user can delete at any time | Proposed (open: should offline phones keep photos longer for the 50-case history?) |
| Digitised signal and result, device | Last 50 cases (FR-4), then oldest removed | Spec |
| Digitised signal and result, server | Proposed 12 months for audit and safety review, then deleted or de-identified | Open: no source found; ask the author, MoH and the ethics committee |
| Audit log | Proposed 12 months | Open |
| De-identified research export | Per ethics approval | Open (C6) |

## 5. De-identification

- Strip EXIF and location from every photo on capture; never store the original gallery file.
- Offer a crop or mask step for name and ID text on paper before upload (proposed).
- Exports for epidemiology (FR-6) contain age band, sex, region, findings, urgency, model
  version and no photo; small cells are suppressed (proposed threshold: open).
- Research use needs **anonymisation** (Digital Code Art. 80); the procedure is set by DPA
  Order No. 4 of 14.01.2025, whose text was not read (research 07). ECG waveforms may be
  re-identifying (unverified), so a signal-level release needs the ethics committee's view.
- Training on logged cases only with consent and de-identification (C-54); never in git.

## 6. Access roles

| Role | Can | Cannot |
|---|---|---|
| Feldsher / GP | Create and view own facility's cases on device and server; delete own cases; forward a case | See other facilities; export |
| Cardiologist reviewer (proposed) | View cases forwarded or flagged for review | Edit clinical rules |
| Facility admin (proposed, open) | Manage facility users | View other facilities |
| MoH administrator | Aggregate and de-identified dashboards, exports, user and facility management | Open photos or raw cases by default |
| Maintainer / developer | Operate infrastructure; production data access only by break-glass with a log entry | Use production data for development |

Spec roles: feldsher, GP, MoH administrator; 2FA for administrators (FR-5). Further roles are
proposals. Least privilege and audit of every admin access.

## 7. Consent

- **First launch:** the research-prototype notice and an explanation of what is stored, where
  and for how long (D1, D11 in the [intended use](../safety/INTENDED_USE.md)).
- **Patient:** a case sent to a server or forwarded names each recipient and any cross-border
  step (research 07). Whether verbal or written patient consent is needed in a FAP setting
  is open; written informed consent is mandatory for a clinical investigation (Law 216, partly
  verified).
- **Facility:** explicit consent to keep photos beyond 30 days or to use data for fine-tuning.
- **Withdrawal:** the user can withdraw and trigger deletion (section 10).
- A pilot needs a positive ethics-committee opinion first; the committee and its waiver route
  for anonymised retrospective data are unknown (C6).

## 8. Logging

- Audit log (server): who, which role, action, case ID (random, not patient-derived), time,
  app and model versions. Logs never contain photos, signals, names or free text.
- Client errors: crash reports without case content; any third-party crash service must be
  checked and must not receive patient data (AGENTS.md).
- Safety log: cases flagged by a cardiologist, with a link to the model version (H-12).
- Logs are protected like other data and kept for the audit period in section 4.

## 9. Export

- Patient or facility export of a case as PDF with the digitised trace and the disclaimers
  (D-items in the intended use). The PDF contains the data the user typed and nothing hidden.
- MoH export: de-identified, aggregated (section 5). Raw case export only by a break-glass
  procedure with approval (open).
- Data portability format for a facility (CSV/JSON) is proposed, not required by the spec.

## 10. Deletion

- Users delete cases on the device; deletion is synced to the server and applied to backups
  within one backup cycle (proposed: 35 days; open).
- Automatic purge jobs enforce section 4; they are monitored.
- A deletion request from a patient goes through the facility; the process and the
  Digital Code data-subject rights are not yet reviewed (open).
- De-identified data that has left the system cannot be recalled; say so in the consent text.

## 11. Incident handling

1. Detect (monitoring, user report), contain (revoke tokens, disable sync, rotate keys).
2. Assess what data and how many people; record in an incident log.
3. Notify the facility, the MoH partner and, if required, the data-protection regulator. The
   notification duty and its deadline under the Digital Code were not read (open).
4. Fix, document the cause, and update the hazard list (H-11).
5. A safety incident (wrong or missed result) follows the same path with the cardiologist,
   plus a model or rule rollback (ADR 0006).

## 12. Open questions

| # | Question | Who |
|---|---|---|
| P1 | Is in-country storage of health data mandatory; does the MoH require national hosting? | Lawyer; MoH via the author |
| P2 | Server retention periods for results and logs | Author, MoH, ethics committee |
| P3 | Patient consent form and who obtains it in a FAP | Ethics committee; cardiologist |
| P4 | Breach-notification duty and deadline under Digital Code No. 178 | Lawyer; DPA site |
| P5 | Adequacy list of states (Art. 89) published? | DPA site |
| P6 | Do facilities need a local case reference or patient ID? | Author; cardiologist |
| P7 | Encrypted on-device database choice and key handling | Developer, Phase 4 |
| P8 | Can ECG waveforms be re-identifying; what anonymisation does DPA Order No. 4 require? | Lawyer |
| P9 | Who is the data controller (maintainer, MoH, facility) and who is the manufacturer? | Lawyer before handover |
