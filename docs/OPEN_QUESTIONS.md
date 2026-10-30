# Open Questions

The project idea and the specification come from the author; a cardiologist in the author's
family can advise us. We only ask them what we cannot find ourselves, and we contact
the cardiologist **once we have a proof of concept (POC) to show**, not before.

Status legend: ⬜ open · 🟡 partly answered · ✅ answered

## A. To ask the author now

Short list, can be sent as is (Russian version below). Updated after Phase 1 research
([synthesis](research/00-synthesis.md)): A1 is now the most important question.

A1. ⬜ **Which ECG machine is used** at the FAPs/CFMs you know (brand/model, or a photo of the
   machine), how many channels it prints (1, 3, 6 or 12), and the paper width? Could the
   cardiologist share **5–10 photos of real paper ECGs**, fully anonymised (no name or ID
   visible), ideally with her reading of each? *(Public tenders suggest 3-channel thermal
   machines with ~48–80 mm paper, but no brand was found — this decides what the POC must read.)*
A2. ⬜ What does the source **"МСС КР, 2022–2026"** refer to (full name or link)?
A3. ⬜ Can you send the **links to the sources** in the document? Several could not be found
   or do not match: "234.5 per 100,000" (EHJ 2024), hypertension "34–37 %" (NCCIM), the IHD
   rank "3rd among women / 5th among men", the WHO/World Bank "untapped lever" quote, and
   IJMEDRI 2024 "~19,000".
A4. ⬜ Do you know whether the MoH's **"Digital FAP" kits (SberMedAI)** or the **NCCIM tele-ECG**
   programme have actually reached FAPs? *(Only if known — it helps us position the app as
   complementary.)*

## B. Research first — ask only if we find nothing

B1. 🟡 **ECG machines** — partly answered: tenders show 3- and 6-channel portable thermal
   machines (~48–80 mm paper, 25/50 mm/s, 5/10/20 mm/mV); no brand confirmed; no evidence
   of digital export. → remaining part moved to A1. ([02](research/02-kyrgyz-context.md))
B2. ✅ **Phones and coverage** — Android majority (70–84 %, Xiaomi/Samsung lead); 4G covers
   ~99 % of the population, 22 settlements have no mobile coverage. Offline-first stays.
   ([02](research/02-kyrgyz-context.md))
B3. ✅ **MoH KR clinical protocols** — found on MedElement: STEMI (order No. 1342, 2024),
   NSTE-ACS (2022), AF (order No. 626, 2024). No KR protocol found for AV block or VT/VF
   (use ESC/ERC until one is found; ask the cardiologist). ([01](research/01-clinical-domain.md))

## C. For the cardiologist — after the POC

C1. ⬜ Review of the urgency mapping (🔴 / 🟡 / 🟢) and of the action steps for each target
   pathology.
C2. ⬜ Which pathologies matter most in practice for feldshers, and which mistakes would be
   most dangerous?
C3. ⬜ Is it possible to collect anonymised Kyrgyz ECGs with a cardiologist's reading for a
   proper validation, and under which consent / ethics framework?
C4. ⬜ Could she introduce the project to NCCIM or KSMA later on?
C5. ⬜ Which drugs and equipment FAPs actually have (aspirin, heparin, thrombolytics,
    atropine, defibrillator) and the real referral/transport route per oblast — this
    shapes the action steps.
C6. ⬜ Which ethics committee would review a retrospective study on anonymised ECGs, and a
    later pilot?

## D. Answered

| Topic | Answer |
|---|---|
| Team | The maintainer builds everything; the author and the cardiologist answer questions. |
| Nature of the project | Personal project first, scaling later. No fixed or bureaucratic timeline (the 12-month roadmap in the spec is indicative only). |
| Deliverables | Everything is in scope: research, ML, app, admin panel, documentation, paper. |
| Languages | Everything in English, except the app UI: Russian, Kyrgyz and English. |
| Cardiologist | Available, but contacted only once a POC exists. |
| Admin panel | Can be part of the MVP. |
| Hosting | Cloud hosting is fine; the maintainer will fund it. |
| Tech stack | The spec's stack is a suggestion; final choices are made in Phase 2 (ADRs). |
| Repository | Public, open source under Apache-2.0. |

---

## Версия на русском (для отправки — раздел A)

1. **Какой аппарат ЭКГ используется** в знакомых вам ФАП/ЦСМ (марка/модель или фото
   аппарата), сколько каналов он печатает (1, 3, 6 или 12) и какой ширины бумага? Может ли
   твоя мама поделиться **5–10 фотографиями настоящих бумажных ЭКГ**, полностью
   обезличенными (без имени и данных пациента), желательно с её расшифровкой к каждой?
   Это главный вопрос: от него зависит, что прототип должен уметь читать.
2. Что означает источник **«МСС КР, 2022–2026»** (полное название или ссылка)?
3. Можешь прислать **ссылки на источники** из документа? Некоторые мы не нашли или они не
   совпадают: «234,5 на 100 тыс.» (EHJ 2024), АГ «34–37 %» (НЦКиТ), место по смертности от
   ИБС «3-е среди женщин / 5-е среди мужчин», цитата ВОЗ/Всемирного банка про
   «незадействованный рычаг» и IJMEDRI 2024 «~19 000».
4. Знаешь ли ты, дошли ли до ФАП **«Цифровые ФАП» (СберМедИИ)** или **телеЭКГ НЦКиТ**?
   (Только если знаешь — это поможет позиционировать приложение как дополнение к ним.)
