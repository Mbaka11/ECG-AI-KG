# 07 — Regulation, ethics, privacy and licensing

Researched 2026-10-29. Legend: **Verified** = primary or authoritative page read in this run; **Partly verified** = seen only in a search snippet, or only a secondary source; **Unverified** = background knowledge, not checked in this run.
Not legal advice. A Kyrgyz lawyer or the regulator must confirm every point marked below before any pilot or deployment.
Note: the spec and `docs/PLAN.md` were not re-read for this note. The project context came from the task brief.

## Summary

- **A CDSS that interprets an ECG with AI is almost certainly "software as a medical device" (SaMD) in the EAEU and KR.** The EAEU criteria for software as a medical device include "interpretation of data in automatic mode, including with AI, that affects clinical decisions". Processing patient clinical data (an ECG is named explicitly) is the key criterion. Partly verified (Russian academic article from 2023; the Decision text itself was not readable).
- **KR has a dedicated medical-device law**: Law No. 216 of 29.12.2023 "On the circulation of medical devices" and Cabinet Resolution No. 513 of 27.08.2024 (registration). The regulator is the Department of Drugs and Medical Devices (dlsmi.kg). Verified.
- **Since 2026-01-01, EAEU registration should follow EAEU rules only**, and national certificates are valid only in the issuing country. Verified for the schedule (2023 article); the current state in KR was not confirmed.
- **A clinical investigation of a device needs a positive ethics-committee opinion plus a permit from the regulator**, with written informed consent and participant insurance. Verified from the e-licence register and a search summary of Law 216. Partly verified for software-only studies and retrospective studies on anonymised data. No explicit rule found.
- **Personal data law changed.** The 2008 Law No. 58 was replaced by the **Digital Code No. 178 (31.07.2025)**, in force from 2026-02-08. Verified for the date (ICNL guide). Health data is a special category, but processing is allowed for medical purposes by a person bound by medical secrecy, and for research if the data is anonymised (Art. 80). Verified.
- **Data localisation in KR is disputed.** One law-firm note says in-country storage is mandatory. Another says there is no localisation requirement. The Digital Code text I read (Art. 89) governs cross-border transfer only. See "Contradictions" in the data section. Treat as open.
- **Licensing is the sharpest engineering risk.** Ultralytics YOLO is AGPL-3.0, and Ultralytics' own page says any commercial, SaaS or closed use needs an Enterprise licence. Handing it over to the government makes this a real issue. Prefer a permissive detector or no YOLO at all. Verified.
- **The EU AI Act is not applicable to KR, but the timeline matters as a good-practice benchmark.** High-risk obligations for AI in medical devices were moved to 2028-08-02 by the AI Omnibus (Reg. 2026/1744). Partly verified (law-firm brief and EU timeline snippet).
- **FDA's January 2026 CDS guidance keeps analysis of signals and images as a device, and says time-critical decision support is not "non-device CDS".** Our app (ECG image, urgency in minutes) would be a device there too. Verified (FDA FAQ snippet; full guidance not read).

## 1. Medical-device status in KR and the EAEU

| Topic | Finding | Status |
|---|---|---|
| KR law | Law No. 216 of 29.12.2023 "On the circulation of medical devices"; devices exempt from registration are listed in its Art. 16. [dlsmi.kg](https://dlsmi.kg/ru/register_mi/) | Verified |
| Registration order | Cabinet Resolution No. 513 of 27.08.2024. Procedures run in the online system "Electronic database of medicines and medical devices" (ЭБД ЛС и МИ). [dlsmi.kg](https://dlsmi.kg/ru/register_mi/) | Verified |
| Registration principle | A device must already be in circulation in the manufacturer's country or elsewhere, and must pass an expert assessment of safety, quality and efficacy by risk class. [dlsmi.kg](https://dlsmi.kg/ru/register_mi/) | Verified. Implication (inference): a first-ever product from a KR developer needs a route for a "home-country" registration. Not found how this works for a local manufacturer. |
| EAEU route | Registration under Council of EEC Decision No. 46 of 12.02.2016. [dlsmi.kg/register_eaes](https://dlsmi.kg/ru/register_eaes/) | Verified (page header) |
| Transition | Per a 2023 article: 2025 is the last year for national-rule registration; from 2026-01-01 only EAEU rules; national certificates then valid only in the issuing state. [Mediasphera 2023](https://www.mediasphera.ru/issues/meditsinskie-tekhnologii-otsenka-i-vybor/2023/2/1221906782023021032) | Partly verified. Article is from 2023 and was written from the Russian viewpoint. KR's current practice unconfirmed. |
| Is software a device? | EAEU criteria (as summarised in the article): software works independently of hardware, is not a part of another device, is meant for use in providing care, and its output is an automatic (incl. AI) interpretation of data affecting clinical decisions. Input includes ECG diagrams. [Mediasphera 2023](https://www.mediasphera.ru/issues/meditsinskie-tekhnologii-otsenka-i-vybor/2023/2/1221906782023021032) | Partly verified |
| Classification | Rules: EEC Board Decision No. 173 of 22.12.2015, amended on 23.05.2023 to align software with IMDRF. [EEC news](https://eec.eaeunion.org/news/aktualizirovany-pravila-klassifikatsii-meditsinskikh-izdeliy-v-zavisimosti-ot-potentsialnogo-riska-p/) Software classes are set by the type of information supplied and the severity of the situation (snippet only). | Class of this app **not determined**. Inference: urgency triage for life-threatening arrhythmia and ACS would plausibly land in a high class (2b or 3), but this is unverified. |
| Quality system | For software of class 2b: certified ISO 13485 (GOST ISO 13485) QMS required before registration (without design controls). For class 3: QMS including design and development. Class 1 and 2a: optional. [Mediasphera 2023](https://www.mediasphera.ru/issues/meditsinskie-tekhnologii-otsenka-i-vybor/2023/2/1221906782023021032) | Partly verified |
| Clinical trials | Run under EAEU rules (Council Decision No. 29 of 12.02.2016), per Resolution 513. Application needs the technical file, protocol, investigator's brochure, adverse-event data, insurance and a **positive ethics-committee opinion**. [elicense.gov.kg](https://elicense.gov.kg/license/id/2341), [committee opinion](https://elicense.gov.kg/license/id/2343) | Partly verified (search summary, not the permit pages read in full) |

**Research vs commercial.** (Inference, not found stated in a source.) A retrospective algorithm study that does not put a tool in front of clinicians is not "use of a medical device" and mainly needs ethics review and data-protection compliance. A prospective pilot where a feldsher sees the output is a clinical investigation of an unregistered device. It needs the ethics opinion and the regulator's permit under KR/EAEU rules. It might be framed as "clinical evaluation in silent mode" (output hidden from the clinician) to reduce risk, but whether KR accepts this framing is **Unverified**. Routine use in FAPs/CFMs (family medicine centres) requires registration.

## 2. Research ethics in KR

- Law 216 requires voluntary written informed consent, participant life/health insurance paid by the sponsor, right to withdraw, and bans research on certain vulnerable groups. Partly verified (search summary of the law; the PDF was not read).
- Ethics committees review the protocol, consent form, device safety data and the investigator's qualification. Partly verified ([elicense.gov.kg](https://elicense.gov.kg/license/id/2343)).
- **Not found:** a named list of accredited committees (MoH, KSMA, NCCIM, etc.), their fees and timelines, or a waiver route for retrospective anonymised data. Ask the author (who knows local institutions); confirm with the cardiologist's hospital's committee.
- The Digital Code allows processing health data "for scientific or other research purposes, provided the records are anonymised" (Art. 80(2)(11)). Verified. DPA Order No. 4 of 14.01.2025 sets the procedure for anonymisation for research. Partly verified (title seen in the ICNL guide; text not read).

## 3. Personal data in KR

| Point | Finding | Status |
|---|---|---|
| Statute | Digital Code of the KR No. 178 of 31.07.2025 replaces Law No. 58 "On personal information" from 2026-02-08; it removes the duty to register as a personal-data holder. [ICNL, Aug 2025](https://www.icnl.org/wp-content/uploads/KG-Personal-Data-Guidance-Note_August-2025_eng.pdf) | Verified |
| Regulator | State Agency for Personal Data Protection under the Cabinet (DPA), [dpa.gov.kg](https://dpa.gov.kg/) | Verified |
| Health data | Special category; processing normally prohibited, with exceptions including medical diagnosis and care by a person bound by medical secrecy, and research on anonymised data. [Art. 80](https://aqlex.ai/doc/230029914/st-80) (a legal-text mirror, not the official portal) | Verified |
| Cross-border | Regulator publishes a list of states with adequate protection; transfer there cannot be restricted. Elsewhere only with consent, treaty, vital interest, contract clauses set by the regulator, etc. Owner must check the list before the transfer. [Art. 89](https://aqlex.ai/doc/230029914/st-89) | Verified (mirror text, edition 31.07.2025) |
| Cloud counts as transfer | ICNL says using Google Drive or similar is a cross-border transfer, under the old law (Art. 25). Fines under the old Offences Code Art. 413-3 were 65,000 KGS for a legal entity (first violation). | Verified for old law. Digital Code analogue not read. |
| Security | Old Resolution No. 760 (2017) defined four protection levels (blue to red); health data pushes toward higher levels. | Partly verified; status under Digital Code unknown |
| Automated decisions | The Code defines "automatic decision" (made without human involvement). Not analysed. | Unverified relevance. Our tool keeps a clinician in the loop. |

**Contradiction on localisation:**
- [Vetrov & Partners](https://vetrovpartners.com/tpost/kg-pn-005-practical-points-on-data-protection-and-localisa) (Russian firm, written by a "contributing analyst", unusual publication date, no statute cited) says operators must store Kyrgyz residents' data on servers in KR.
- [WCR Consulting, 2026](https://wcr-consulting.com/blog/2026/05/10/kyrgyzstan-personal-data/) (search snippet only) says there is no localisation requirement under Law 58 and the transfer is allowed under conditions.
- The cross-border article of the new Code (Art. 89), which I read, regulates transfers but contains no storage-in-KR rule. There may be sector rules for state information systems or for MoH systems that I did not find.
- **Conclusion:** no statutory localisation obligation was found for private apps. Do not treat this as settled. A government deployment may still require national hosting by procurement or MoH policy. Design for **hosting in KR or on-premises at the MoH, with cloud as a non-personal-data convenience only**.

## 4. International good-practice frameworks

All items below are **Unverified** in this run unless a link is given. They are standard references. Check the versions before citing them in docs.

| Framework | Use for this project |
|---|---|
| IEC 62304 (software life cycle) | Lightweight software development plan, requirements, risk-linked tests, SOUP list. Safety class likely B or C because a wrong "green" can delay care. |
| ISO 14971 (risk management) | Hazard log. Key hazards: false "green" in STEMI/VT; bad photo not rejected; wrong lead mapping; automation bias. |
| IEC 62366-1 (usability) | Formative tests with feldshers in Russian and Kyrgyz; error-tolerant UI. |
| ISO 13485 | Required by EAEU for classes 2b/3 (see above, partly verified). Plan for it only at commercial stage. |
| WHO guidance on ethics and governance of AI for health (2021), [WHO](https://www.who.int/publications/i/item/9789240029200/) | Six principles: autonomy, well-being/safety, transparency, accountability, inclusiveness/equity, sustainability. Useful for the MoH conversation. Verified that it exists. Principles listed from background knowledge. |
| WHO guidance on large multi-modal models (Jan 2024), [WHO news](https://www.who.int/news/item/18-01-2024-who-releases-ai-ethics-and-governance-guidance-for-large-multi-modal-models) | Only relevant if an LLM/VLM is used to read the photo or write action steps. Verified that it exists. |
| EU AI Act | Medical-device AI is high-risk via Art. 6(1). Per a law-firm brief citing Regulation (EU) 2026/1744 (AI Omnibus), the date moved from 2027-08-02 to 2028-08-02. [QLE](https://www.qle.be/the-qle-regulatory-brief/ai-acts-digital-omnibus-is-now-law-ai-medical-devices-get-until-2-august-2028-but-notified-bodies-face-a-28-january-2028-deadline), [EU timeline](https://ai-act-service-desk.ec.europa.eu/en/ai-act/timeline/timeline-implementation-eu-ai-act). Partly verified. Not legally applicable in KR. |
| FDA CDS guidance (29.01.2026) | Software that analyses a signal or image stays a device. FAQ Q3: time-critical decision support is not "non-device CDS". [FDA guidance page](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/clinical-decision-support-software), [FAQ](https://www.fda.gov/medical-devices/software-medical-device-samd/clinical-decision-support-software-frequently-asked-questions-faqs). Partly verified (snippets). Lesson: do not rely on a "just CDS" argument. |
| TRIPOD+AI (2024) | Reporting for the model development/validation paper. |
| STARD-AI / CONSORT-AI / SPIRIT-AI / DECIDE-AI | CONSORT-AI/SPIRIT-AI for trial protocols and reports; DECIDE-AI for early live clinical evaluation, which matches the pilot. |

## 5. Open-source licensing

| Component | Licence | Compatibility for an Apache-2.0 public repo handed to a government | Status |
|---|---|---|---|
| Ultralytics YOLO (code and weights) | AGPL-3.0, or paid Enterprise. Ultralytics' page lists "any commercial product or service", "SaaS platforms, APIs", "using custom-trained or fine-tuned YOLO models in a proprietary or commercial setting" and "internal business tools" as needing Enterprise. AGPL use requires publishing the **entire** solution incl. training scripts. [Ultralytics licence](https://www.ultralytics.com/license); [community Q&A](https://community.ultralytics.com/t/yolov11-agpl-license-for-on-premises-use/1529) | **Not compatible** with a permissive licence for the combined work. Fine for research only if the whole thing is AGPL. Avoid in the shipped product. Alternatives (inference): classical OpenCV pipeline, or a permissively licensed detector. Check each licence before use. | Verified |
| OpenCV | Apache-2.0 (since 4.5.0) | Compatible | Unverified |
| Flutter / Dart | BSD-3-Clause | Compatible | Unverified |
| PTB-XL | CC BY 4.0. [PhysioNet licence](https://www.physionet.org/content/ptb-xl/view-license/1.0.3/) | Needs attribution; derivatives and trained weights are allowed | Verified |
| MIMIC-IV-ECG and other credentialed data | PhysioNet Credentialed Health Data License 1.5.0: data must not be shared with third parties, **including via APIs and online LLM services**. [licence](https://www.physionet.org/about/licenses/physionet-credentialed-health-data-license-150/); [PhysioNet LLM notice](https://physionet.org/news/post/llm-responsible-use/) | **Never** put the data in the repo. Weights trained on it: the licence text should be read for derivative-model terms before release. | Partly verified (headline seen, full text not read for model rules) |
| Other PhysioNet sets (ODC-By etc.) | Open licences with attribution | Usually fine; check each dataset page | Unverified |
| Foundation-model weights | Many have non-commercial or research-only terms | Check per model; record in a licence table | Unverified |
| Fonts | SIL OFL fonts (e.g. Noto) are safe to bundle. Kyrgyz Cyrillic glyphs (ҢӨҮ) must be covered. | Compatible | Unverified |

**Safe in a public repo:** own code (Apache-2.0), documentation, synthetic ECGs, scripts that download datasets, model cards, and a dependency licence table. **Not safe:** patient data, real ECG photos, credentialed-dataset files, weights with restrictive licences, AGPL code mixed in. For a handover, ship a software bill of materials (SBOM) with licences.

## 6. Safety, liability and "not a diagnosis" framing

- No KR-specific rule on disclaimers was found. Disclaimers do not change a product's regulatory status. Under FDA and EAEU logic, the **intended purpose** and the real function decide (partly verified above).
- Practical framing (inference from common practice): "supports a trained health worker; does not replace clinical judgement or an ECG reading by a cardiologist; any red result means: act per protocol and call for help; green does not exclude disease". Show it on first launch and in every result, in all three languages.
- Liability for a faulty "green" falls on the developer or on the institution that deploys it. The ethics process requires insurance for participants (verified for investigations). Get legal advice before the MoH handover on who is the manufacturer and who is responsible.
- Clinical content (urgency rules, action steps) must cite an official protocol or a cardiologist review (project rule in `AGENTS.md`).

## Implications for ECG-AI KG

1. **Build now as if it will be registered**: intended-use statement, hazard log (ISO 14971-lite), requirement-to-test traceability, SOUP/licence table. It costs little and is required later.
2. **Drop Ultralytics from the product path.** Use it only in throwaway experiments in `temp/`, or replace it. Write the choice in an ADR.
3. **Keep the repo public and clean**: no real ECG photos or credentialed data, synthetic or CC-BY test data only; add a `LICENSES` table covering datasets and weights.
4. **Prefer on-device inference** (offline is already a requirement). This minimises data leaving the phone and the cross-border transfer exposure. Store nothing identifiable by default; no patient name or ID needed for triage.
5. **Admin panel for MoH**: aggregate and anonymised statistics only; if records are synced, host in KR or at the MoH, with a consent text naming each recipient and any cross-border step.
6. **Clinical evaluation plan**: retrospective on public datasets first (report with TRIPOD+AI); then a silent-mode prospective pilot at one site with ethics approval; only then an assisted-mode pilot (DECIDE-AI).
7. **Position as decision support in all text**, but plan for device registration for any real deployment.
8. **Don't use online LLM APIs on credentialed data.** Same for any real patient data.

## Open questions

| Question | Who to ask |
|---|---|
| Which accredited ethics committee, what documents, how long, any waiver for anonymised retrospective data? | Author first (local knowledge), then cardiologist's institution |
| Does a research pilot of unregistered AI software need the regulator's permit if output is hidden (silent mode)? | DLS/MoH directly (written query); author for contact |
| Expected EAEU risk class of the app (2b or 3?) and how a KR developer registers a first-of-kind product | DLS; regulatory consultant |
| Is there any in-KR storage obligation for health data under the Digital Code or MoH acts? | KR lawyer / DPA (WhatsApp channel in the ICNL guide) |
| Has the DPA published the "adequate countries" list and consent form under the Digital Code? | DPA site |
| Who owns the product and takes liability on government handover? | Author, MoH |
| Do the full texts of Law 216 (Art. 16 exemptions) and Resolution 513 contain a software-specific path? | Read the originals (not done) |

## Sources (accessed 2026-10-29)

- DLS KR, medical devices page: https://dlsmi.kg/ru/register_mi/
- DLS KR, EAEU registration page: https://dlsmi.kg/ru/register_eaes/
- Cabinet Resolution No. 513 (listing): https://www.gov.kg/index.php/ru/npa/s/4583
- Mediasphera 2023, software as medical device under EAEU rules: https://www.mediasphera.ru/issues/meditsinskie-tekhnologii-otsenka-i-vybor/2023/2/1221906782023021032
- EEC news on Decision 173 amendment (2023): https://eec.eaeunion.org/news/aktualizirovany-pravila-klassifikatsii-meditsinskikh-izdeliy-v-zavisimosti-ot-potentsialnogo-riska-p/
- Decision 173 (not readable; ConsultantPlus needs login): https://www.consultant.ru/document/cons_doc_LAW_191465/
- e-licence KR, clinical-trial permit: https://elicense.gov.kg/license/id/2341 ; ethics opinion: https://elicense.gov.kg/license/id/2343 (search summaries only)
- Law 216 (via cbd.minjust.gov.kg, summary only): https://cbd.minjust.gov.kg/4-5241/edition/40637/ru
- ICNL, KR personal data guidance, Aug 2025: https://www.icnl.org/wp-content/uploads/KG-Personal-Data-Guidance-Note_August-2025_eng.pdf
- Digital Code Art. 80: https://aqlex.ai/doc/230029914/st-80 ; Art. 89: https://aqlex.ai/doc/230029914/st-89
- DPA KR: https://dpa.gov.kg/
- Vetrov & Partners (weak source, disputed): https://vetrovpartners.com/tpost/kg-pn-005-practical-points-on-data-protection-and-localisa
- WCR Consulting 2026 (snippet only): https://wcr-consulting.com/blog/2026/05/10/kyrgyzstan-personal-data/
- Ultralytics licence: https://www.ultralytics.com/license
- PhysioNet credentialed licence 1.5.0: https://www.physionet.org/about/licenses/physionet-credentialed-health-data-license-150/ ; LLM notice: https://physionet.org/news/post/llm-responsible-use/ ; PTB-XL licence: https://www.physionet.org/content/ptb-xl/view-license/1.0.3/
- WHO AI ethics 2021: https://www.who.int/publications/i/item/9789240029200/ ; LMM 2024: https://www.who.int/news/item/18-01-2024-who-releases-ai-ethics-and-governance-guidance-for-large-multi-modal-models
- EU AI Act timeline: https://ai-act-service-desk.ec.europa.eu/en/ai-act/timeline/timeline-implementation-eu-ai-act ; QLE brief: https://www.qle.be/the-qle-regulatory-brief/ai-acts-digital-omnibus-is-now-law-ai-medical-devices-get-until-2-august-2028-but-notified-bodies-face-a-28-january-2028-deadline
- FDA CDS guidance: https://www.fda.gov/regulatory-information/search-fda-guidance-documents/clinical-decision-support-software ; FAQ: https://www.fda.gov/medical-devices/software-medical-device-samd/clinical-decision-support-software-frequently-asked-questions-faqs

## Checklist per phase

**POC (now)**
- [ ] Only public/synthetic data; no patient data in git
- [ ] Licence table started; no AGPL or non-commercial code or weights in the main path
- [ ] One-paragraph intended-use statement and "not a diagnosis" text
- [ ] Credentialed datasets used only locally, never via online LLM APIs
- [ ] Start the hazard log

**MVP**
- [ ] Requirements, traceability to tests, SOUP list (IEC 62304-lite)
- [ ] Usability tests with 3 to 5 feldshers in RU/KY (IEC 62366-lite)
- [ ] Clinical content reviewed by the cardiologist against an official protocol
- [ ] Retrospective validation report (TRIPOD+AI), with subgroup and image-quality failure analysis
- [ ] Privacy by design: on-device, minimal data, consent text, no identifiers by default
- [ ] Written query to DLS and DPA about the open questions above

**Pilot**
- [ ] Ethics committee opinion; regulator permit if required; written informed consent; insurance
- [ ] Silent-mode phase first, then assisted mode (DECIDE-AI reporting)
- [ ] Hosting decision (KR or on-premises); cross-border consent wording
- [ ] Incident and adverse-event reporting process; kill switch / version pinning
- [ ] Legal clarity on manufacturer and liability

**Deployment**
- [ ] Device registration (EAEU/KR route) with risk class confirmed; ISO 13485 QMS if class 2b/3
- [ ] Post-market surveillance, model change control, training of users
- [ ] Handover pack: code, SBOM, licences, documentation, risk file, maintenance plan
- [ ] Annual review against the Digital Code and DPA rules
