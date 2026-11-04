# Cardiologist review package (draft v0.1)

Status: **draft, prepared before the POC exists** · 2026-11-04 · English is the reference
version. Russian copy: [REVIEW_PACKAGE_RU.md](REVIEW_PACKAGE_RU.md).
Related: [OPEN_QUESTIONS](../OPEN_QUESTIONS.md) (C1-C7), [INTENDED_USE](../safety/INTENDED_USE.md),
[HAZARD_LIST](../safety/HAZARD_LIST.md), [research 01](../research/01-clinical-domain.md),
[research 10](../research/10-kr-protocols.md), [spec v2](../spec/v2/ECG-AI_KG_TS_v2.md).

This package collects, in one place, every piece of clinical content that currently exists in the
repository and in the UI prototype. **Nothing in it is new clinical content.** Where the repo has no
source, the item is marked **GAP**. Nothing here is clinical guidance until it is approved.

## 1. Purpose and what we ask

ECG-AI KG is an offline decision-support app for feldshers and nurses: it reads a photo of a paper
ECG and shows a quality verdict, heart rate, cautious findings, an urgency colour and next-step
text. It is not a diagnosis tool (see INTENDED_USE).

We ask the cardiologist, once the POC can be shown (open question C1), to go through every item
below and record one decision per item:

| Decision | Meaning |
|---|---|
| **Approve** | The item may be used as written. |
| **Change** | Use it with the change written in the Comment column. |
| **Reject** | Remove it. Add the reason in the Comment column. |

Notes for the reviewer:

- Every item has an ID (R-01 ...). The Decision and Comment columns are empty on purpose.
- "Source" shows where the content came from. Sources marked "Partly verified" or "Unverified" in the
  research notes were not read in full by the developer. Please treat them with extra care.
- Unreviewed content is displayed in the app with the tag "pending cardiologist review".
- Where the only source is textbook knowledge or a non-Kyrgyz guideline (ERC / ESC), this is stated.
- The KR protocols read for this project are physician-oriented and give no feldsher checklist
  (research 10). What a feldsher may do at first contact is open (C7, item R-88).
- Priority: if time is short, review the red / never-green rules (section 3) and the red and grey
  action steps (section 4) first. Under-triage is worse than over-triage (spec v2 C-43).

## 2. Urgency mapping: finding to level (open question C1)

Levels: red = possible emergency; yellow (shown as "amber" in the app) = refer or check soon;
green = no urgent finding on this strip (not "ECG normal"); grey = cannot interpret.
The thresholds are a first draft by the developer (research 01 s3).

| ID | Finding | Default level | Escalate to red if | Downgrade / notes | Min. leads | Rationale and source | Decision | Comment |
|---|---|---|---|---|---|---|---|---|
| R-01 | STEMI or STEMI equivalent (ST elevation criteria, posterior MI, diffuse ST depression with aVR elevation); app wording "possible acute ischaemia / occlusion - refer" | Red | always | Time-critical. Refer / transport for reperfusion per KR protocol. Never shown as "normal". | 12 (at least 2 contiguous) | Time targets and reperfusion rule: KR STEMI protocol, MoH order No. 1342, 25.12.2024 (research 10 s3, Verified). ST thresholds: ESC 2023 (research 01 s2.1, Partly verified, read via secondary mirrors); the KR text gives no mm thresholds. STEMI criteria miss about half of occlusions (research 01). | | |
| R-02 | ST depression or T inversion without ST elevation | Yellow | ongoing chest pain; haemodynamic instability; ST depression pattern in 6 or more leads with ST elevation in aVR | Needs troponin; "not ruled out". | 12 | KR NSTE-ACS protocol 2022: ST depression 0.05 mV or more in 2 or more contiguous leads (research 10 s2, Verified via MedElement copy); isolated T inversion not linked to poor prognosis; the 6-lead + aVR/V1 pattern is a KR very-high-risk criterion (invasive strategy within 2 h). | | |
| R-03 | Ventricular tachycardia (sustained); regular wide-complex tachycardia treated as VT | Red | always | 12 leads help to tell VT from SVT with aberrancy; a safe rule is "regular wide-complex tachycardia = treat as VT". | 1 to 12 | ERC 2021 ALS and reviews (research 01 s2.4, Partly verified). **No KR protocol found** (research 10 s5). | | |
| R-04 | VF, asystole, chaotic rhythm | Red | always (cardiac arrest) | Outside the normal use case: a patient in arrest will rarely be photographed. | 1 | Textbook (Unverified); ERC 2021. **No KR protocol found.** | | |
| R-05 | Complete (third-degree) AV block | Red | always | Needs pacing in hospital. | 1 | ESC 2021 pacing guideline, ERC 2021 (research 01 s2.5, Partly verified). **No KR protocol found.** | | |
| R-06 | AF or flutter, rapid (above 110-120/min) or symptomatic | Yellow | syncope, shock, acute heart failure, chest pain, wide QRS | Output is "suspected AF" only. | 1 | Draft (Unverified). KR AF protocol, order No. 626, 11.06.2024: emergency hospitalisation for AF with haemodynamic compromise or ventricular rate above 180/min (research 10 s1, Verified). Note the gap between 110-120 (draft) and 180 (KR hospitalisation criterion). | | |
| R-07 | AF or flutter, rate-controlled, asymptomatic: new finding / known | Yellow (new) / Green (known) | any red flag | Anticoagulation decision is outside the feldsher's scope. | 1 | Draft (Unverified). KR AF protocol: new or suspected AF is referred to a cardiologist (research 10 s1). | | |
| R-08 | Sinus tachycardia | Yellow (above 130, or symptoms) / Green | shock, chest pain | Treat the cause. | 1 | Draft cut-offs, textbook (Unverified); ERC tachycardia algorithm (research 01 s2.6). | | |
| R-09 | Sinus bradycardia | Green (asymptomatic) / Yellow | syncope, systolic BP below 90, rate below 40 | Check drugs. | 1 | Draft cut-offs, textbook (Unverified). | | |
| R-10 | LBBB | Yellow | any ACS-like symptoms: treat as possible occlusion MI (red) | Old versus new is unknown without a prior ECG. | 12 | ESC 2023 supplement, secondary mirror (research 01 s2.7, Partly verified). | | |
| R-11 | RBBB | Green | ACS-like symptoms: yellow or red | | 12 | Draft; textbook (Unverified). | | |
| R-12 | Low quality, not interpretable, or unsupported layout | Grey: "No result. Repeat the photo, record a 12-lead ECG, or send to an expert." | not applicable | Never green, never "normal". | not applicable | Project safety rule (spec v2 C-33; INTENDED_USE D4). | | |
| R-13 | Findings that exist in the product plan but have **no row in the draft table**: atrial flutter 2:1 versus SVT; paced rhythm; other arrhythmias (PVCs, SVT, pauses) | **GAP** | | | | Not in research 01 s3. Please say which should be in or out of the MVP (see also C2, R-83). | | |
| R-14 | Heart-rate cut-offs used by the rules (110-120, 130, 180, 40) | Draft values | | | | See R-06, R-08, R-09. Research 01 open question 5: final thresholds belong to the cardiologist. | | |

Not covered by the mapping and not planned for the MVP: QT / QTc (research 01 s1.4); anticoagulation
advice; any diagnosis wording.

## 3. Never-green and symptom-escalation rules

Source for all rows: spec v2 section 5 (C-33, C-30, C-43), INTENDED_USE s4, research 01 s3 and
implications 2 and 4.

| ID | Rule | Source | Decision | Comment |
|---|---|---|---|---|
| R-20 | Urgency of a result is the **highest** urgency among all findings. | Spec v2 s5 rule 1 | | |
| R-21 | Low image quality, missing leads, uncertain digitisation, or confidence below the threshold gives **grey, or at least yellow, never green**. | Spec v2 s5 rule 2; hazard H-05 | | |
| R-22 | With fewer than 12 identified leads, claims are **limited to rhythm** and the screen says so. Ischaemia and bundle-branch findings are not shown; "no ischaemia" is never shown for a short strip. | Spec v2 C-30; hazard H-09 | | |
| R-23 | Green is worded "No urgent pattern" (not "normal"), and always carries the fixed footer "A green result does not exclude disease". | Spec v2 s5; INTENDED_USE D2 | | |
| R-24 | Colour is never the only cue: each level also has an icon and a word. | Spec v2 s5 rule 4 | | |
| R-25 | Under-triage is worse than over-triage; thresholds for red classes favour sensitivity. | Spec v2 C-43; research 01 implication 5 | | |
| R-26 | **Symptom escalation:** if the user reports symptoms, the result screen says "Symptoms reported: {list}. The patient may need urgent care whatever the ECG shows - act per protocol." This text is currently shown as a banner. Whether symptoms also raise the colour level (for example green to yellow, yellow to red) is **not implemented in the prototype**; the draft table in R-02, R-06 to R-11 lists the intended escalations. | App string `symptomsOverride`; research 01 s3 | | |
| R-27 | Without clinical context, "red" must be assigned conservatively. | Research 01 s3 (assumption) | | |
| R-28 | Findings that cannot be assessed (for example, ischaemia on a 3-lead strip) are stated, not silently omitted. | INTENDED_USE D5 | | |

## 4. Action-step texts currently in the app (per scenario)

Source: the UI prototype (`mobile/lib/data/demo_cases.dart`, branch feat/app-skeleton). These are
canned demo texts, short paraphrases of the protocols, **with no drug doses** (hazard H-07). The
Russian text is what a user sees in the Russian UI. The Kyrgyz UI currently shows Russian
placeholders. The "Cited source" column is the source tag shown in the app next to the step. Each step
is currently tagged "pending cardiologist review".

"Reviewer's check" lists what the developer could and could not match with the cited source.

### 4.1 Red scenario: possible acute ischaemia (ST elevation pattern in II, III, aVF)

Headline (R-30): "Possible acute ischaemia (heart attack pattern)" / "Возможная острая ишемия (признаки инфаркта)". Finding: "ST elevation pattern" in leads II, III, aVF; "Sinus rhythm, 74/min".

| ID | Step text (EN / RU) | Cited source in the app | Reviewer's check | Decision | Comment |
|---|---|---|---|---|---|
| R-30 | Headline and findings wording (above) | Project wording rule (research 01 implication 7) | "Possible ... pattern", not "diagnosis". | | |
| R-31 | "Arrange urgent transfer to a hospital with a cardiology unit now. Every minute counts." / "Срочно организуйте перевод в стационар с кардиологическим отделением. Важна каждая минута." | KR MoH STEMI protocol, order 1342 (2024) | The protocol sets transfer to a PCI-capable centre and a 30-min target for transfer from a non-PCI centre. It is not a feldsher instruction. "Cardiology unit" may differ from "PCI centre": please confirm the destination wording. | | |
| R-32 | "Send this ECG to an expert now." / "Отправьте эту ЭКГ эксперту прямо сейчас." | Project design (ADR 0003) | Not a clinical protocol item. Needs a working route to an expert (C4, C5). | | |
| R-33 | "Keep the patient at rest. Check pulse, blood pressure, breathing and SpO2." / "Обеспечьте покой. Контролируйте пульс, АД, дыхание и SpO2." | KR NSTE-ACS protocol (2022), pre-hospital stage | The protocol item 1 lists history, examination, ECG, BP, respiratory rate and saturation. "Keep at rest" is **not** in the passage the developer read. Please confirm or remove. | | |
| R-34 | "Give medicines only as your protocol and training allow." / "Назначайте препараты только согласно протоколу и вашим полномочиям." | KR NSTE-ACS protocol (2022), pre-hospital stage | Deliberately contains no drug names or doses. The NSTE-ACS pre-hospital list (nitrate, aspirin 165-325 mg, clopidogrel, morphine, heparin, beta-blocker) is **not** shown in the app because it is unknown whether a feldsher may give them (C7, R-88). | | |
| R-35 | Notice (ischaemia): "An ECG alone cannot exclude acute coronary syndrome; troponin and clinical assessment are needed." / "Одна ЭКГ не исключает острый коронарный синдром; нужны тропонин и клиническая оценка." | INTENDED_USE D7; research 01 s2.1 | See D7 (R-67). | | |

Protocol anchors available for the red path, not shown in the app (for your decision whether to add them):

| ID | Content | Source | Decision | Comment |
|---|---|---|---|---|
| R-36 | Time targets: first medical contact to ECG and diagnosis at most 10 min; diagnosis to primary PCI at most 120 min, otherwise thrombolysis; thrombolysis started within 10 min of the decision; transfer from a non-PCI centre within 30 min of diagnosis; transport ideally within one hour. | KR STEMI protocol, order 1342/2024 (research 10 s3, Verified via MedElement copy) | | |
| R-37 | Aspirin, loading dose 150-300 mg orally (chewed), for all STEMI patients (the NSTE-ACS pre-hospital list says 165-325 mg: the two ranges differ inside the KR texts). Not shown in the app. | KR STEMI protocol; KR NSTE-ACS protocol (research 10 s2, s3, s6) | | |

### 4.2 Amber (yellow) scenario: suspected atrial fibrillation, 3-channel strip

Headline (R-40): "Suspected atrial fibrillation" / "Подозрение на фибрилляцию предсердий". Finding: "Irregular rhythm, no clear P waves; ventricular rate about 108/min". Notices shown: AF confirmation notice (D6) and rhythm-only notice (D5).

| ID | Step text (EN / RU) | Cited source in the app | Reviewer's check | Decision | Comment |
|---|---|---|---|---|---|
| R-40 | Headline and findings wording (above) | KR AF protocol, order 626 (2024) | The KR protocol needs an episode of more than 30 s; a strip is about 10 s, so only "suspected". | | |
| R-41 | "Check for danger signs: fainting, low blood pressure, chest pain, rate over 180/min. If present, treat as an emergency." / "Проверьте признаки опасности: обморок, низкое АД, боль в груди, ЧСС более 180/мин. При их наличии - действуйте как при неотложном состоянии." | KR MoH AF protocol, order 626 (2024) | Matches the emergency-hospitalisation criteria (presyncope / syncope, hypotension, signs of ischaemia, rate above 180/min). "Chest pain" stands for "signs of myocardial ischaemia". | | |
| R-42 | "If no danger signs: refer to a doctor or cardiologist to confirm the diagnosis." / "Если признаков опасности нет - направьте к врачу или кардиологу для подтверждения диагноза." | KR MoH AF protocol, order 626 (2024) | Matches: new or suspected AF is referred to a cardiologist or AF specialist. | | |
| R-43 | "If the machine allows, record a longer strip (more than 30 seconds)." / "Если аппарат позволяет, запишите более длинную ленту (более 30 секунд)." | KR MoH AF protocol, order 626 (2024) | Matches the 30-s rule. Whether the FAP machines can print longer strips is unknown (A1). | | |
| R-44 | "Send the ECG to an expert." / "Отправьте ЭКГ эксперту." | Project design (ADR 0003) | Not a clinical protocol item. | | |
| R-45 | Notice (AF): "Suspected atrial fibrillation. Confirmation needs an ECG of more than 30 s and a clinician." / "Подозрение на фибрилляцию предсердий. Для подтверждения нужна ЭКГ длительностью более 30 с и врач." | INTENDED_USE D6; research 10 s1 | See D6. | | |
| R-46 | Notice (rhythm only): "Only rhythm was assessed. Heart attack signs and bundle branch blocks cannot be assessed from this strip." / "Оценён только ритм. Признаки инфаркта и блокады ножек пучка Гиса по этой ленте оценить нельзя." | INTENDED_USE D5; spec v2 C-30 | See D5. | | |

Not in the app, **GAP**: no anticoagulation advice (outside the feldsher's scope, CHA2DS2-VASc is in the
KR protocol); no rate-control doses (not found in the KR text); no steps for atrial flutter.

### 4.3 Green scenario: sinus rhythm, no urgent pattern

Headline (R-50): "No urgent pattern found" / "Неотложных изменений не найдено". Finding: "Sinus rhythm, 72/min". Notice shown: ACS notice (D7).

| ID | Step text (EN / RU) | Cited source in the app | Reviewer's check | Decision | Comment |
|---|---|---|---|---|---|
| R-51 | "This does not exclude heart disease. Decide based on the patient's condition." / "Это не исключает заболевание сердца. Решение принимайте по состоянию пациента." | Project safety rule (INTENDED_USE D2) | Safety wording, not from a clinical protocol. | | |
| R-52 | "If symptoms continue or get worse, repeat the ECG and contact a doctor." / "Если симптомы сохраняются или усиливаются, повторите ЭКГ и свяжитесь с врачом." | Project safety rule (INTENDED_USE D2) | Safety wording, not from a clinical protocol. Please confirm that repeating the ECG is the right advice. | | |

### 4.4 Grey scenario: cannot interpret (partial trace, gain not readable)

Headline (R-53): "Cannot interpret this photo" / "Не удалось расшифровать фото". Findings: "Part of the trace is missing"; "Paper gain not readable".

| ID | Step text (EN / RU) | Cited source in the app | Reviewer's check | Decision | Comment |
|---|---|---|---|---|---|
| R-54 | "Retake the photo: paper flat, good light, whole strip in the frame." / "Переснимите: лента ровная, хорошее освещение, вся лента в кадре." | Project safety rule (INTENDED_USE D4) | Technical advice, not clinical. | | |
| R-55 | "If it still fails, record a new ECG or send it to an expert." / "Если не получается - запишите ЭКГ заново или отправьте эксперту." | Project safety rule (INTENDED_USE D4) | | | |
| R-56 | "If the patient is unwell, act per protocol now. Do not wait for the app." / "Если пациенту плохо - действуйте по протоколу сейчас, не ждите приложения." | Project safety rule (INTENDED_USE D4) | | | |

### 4.5 Scenarios planned but with no action text yet (GAP)

| ID | Finding | Status of the content | Decision | Comment |
|---|---|---|---|---|
| R-57 | VT / VF | No KR protocol found. The research draft says: call emergency help, check pulse and consciousness, CPR and defibrillation if pulseless, synchronised cardioversion if unstable (ERC 2021, Unverified for KR). **No action text exists in the app.** | | |
| R-58 | Complete AV block | No KR protocol found. Research draft: monitor, IV access, oxygen if hypoxic, transport with ECG monitoring, atropine per protocol, pacing if available (ESC / ERC; Unverified for KR). **No action text in the app.** | | |
| R-59 | NSTE-ACS / ST depression (yellow, escalating to red) | KR NSTE-ACS 2022 pre-hospital list exists (research 10 s2), but is not in the app for the reason in R-34. **No action text in the app.** | | |
| R-60 | Sinus tachycardia / bradycardia, LBBB, RBBB | No action text. Source: textbook (Unverified). | | |

## 5. Mandatory disclaimers D1-D12

English wording is from INTENDED_USE s7 ("final text pending cardiologist review"). The "In the app"
column shows whether and how the prototype implements it (strings in `mobile/tool/gen_arb.py`).
The Russian and Kyrgyz wording needs a medical translator or your review (research 01 open question 6).
The Kyrgyz UI still shows Russian placeholders.

| ID | D | Where shown | Required content (English) | In the app (prototype) | Decision | Comment |
|---|---|---|---|---|---|---|
| R-61 | D1 | First launch, with acknowledgement; also "About" | "Research prototype. Decision support for a trained health worker. Not a diagnosis. Does not replace clinical judgement or a cardiologist." | Implemented. RU: "Исследовательский прототип. Помощь в принятии решений для обученного медработника. Не является диагнозом. Не заменяет клиническое решение или кардиолога." | | |
| R-62 | D2 | Every result screen, fixed footer | "Not a diagnosis. A green result does not exclude disease. If the patient is unwell, act per protocol and call for help." | Implemented. RU: "Не диагноз. Зелёный результат не исключает болезнь. Если пациенту плохо - действуйте по протоколу и вызовите помощь." | | |
| R-63 | D3 | Red result | "Possible emergency. Act per protocol and call for help now." plus the step list with sources | Partly: red headline and steps shown; the exact D3 sentence is not a separate string. The level label is "Urgent - act now" / "Срочно - действуйте сейчас". | | |
| R-64 | D4 | Grey "cannot interpret" | "No result. Repeat the photo, record a 12-lead ECG, or send to an expert." Never shown as green or "normal". | Partly: level label "No result" / "Нет результата" and the grey steps (R-54 to R-56). | | |
| R-65 | D5 | Strips with fewer than 12 identified leads | "Only rhythm was assessed. Heart attack signs and bundle branch blocks cannot be assessed from this strip." | Implemented (R-46). | | |
| R-66 | D6 | AF finding | "Suspected atrial fibrillation. Confirmation needs an ECG of more than 30 s and a clinician." | Implemented (R-45). | | |
| R-67 | D7 | Any ischaemia-related finding or its absence | "ECG alone cannot exclude acute coronary syndrome; troponin and clinical assessment are needed." | Implemented (R-35); also shown on the green scenario. | | |
| R-68 | D8 | Every result | Detected speed, gain, leads found and image quality score, so the user can check them; digitised trace overlaid on the photo. | Implemented as the "Check these values" block and the overlay legend. | | |
| R-69 | D9 | Every result | App version, model version and protocol-text version with date. | Implemented as "App {app} - Model {model} - Protocol texts {date}". | | |
| R-70 | D10 | Protocol-derived steps | Source name and date next to each step, or "pending cardiologist review". | Source name shown; **date not shown**; tag "pending cardiologist review" shown. | | |
| R-71 | D11 | About / data screen | What is stored, where, for how long; no identifiers by default; consent text if a case is forwarded. | Implemented: "On this phone: the ECG photo, the result, age group, sex and symptoms for the last 50 cases. No names or ID numbers. A case leaves the phone only when you send it to an expert. On the server, photos are deleted after 30 days." Forward consent: "The ECG photo, the result, age and sex will be sent to the expert centre. No name is sent. The patient has agreed." | | |
| R-72 | D12 | Pilot builds only | Study-use notice stating whether output is hidden or shown per the approved protocol, and the ethics approval reference. | Not in the prototype (pilot is a later phase; needs an ethics opinion, C6). | | |
| R-73 | - | About / Limitations screen | Not in D1-D12 but shown in the app: "Not yet tested on Kyrgyz ECG paper. May miss emergencies. Photo quality affects the result. Short strips allow only rhythm assessment." | Implemented. RU: "Ещё не проверено на кыргызских ЭКГ. Может пропустить неотложное состояние. Качество фото влияет на результат. По короткой ленте оценивается только ритм." | | |

## 6. Symptom questions

The draft in research 01 s3 assumes 2-4 yes/no questions: chest pain, syncope, shortness of breath,
and systolic BP below 90 if measured. INTENDED_USE s3 repeats this and marks the exact set pending
review. The UI prototype currently offers five tick boxes under "Symptoms now" (optional, with age
group and sex), which differs from the draft.

| ID | Question / field in the prototype (EN / RU) | Link in the draft | Decision | Comment |
|---|---|---|---|---|
| R-75 | Chest pain / Боль в груди | In the draft | | |
| R-76 | Short of breath / Одышка | In the draft | | |
| R-77 | Fainting / Обморок | In the draft (syncope) | | |
| R-78 | Palpitations / Сердцебиение | **Not** in the draft list; added in the prototype | | |
| R-79 | Weakness, dizziness / Слабость, головокружение | **Not** in the draft list; added in the prototype | | |
| R-80 | Low blood pressure (systolic below 90), if measured | In the draft; **not in the prototype** | | |
| R-81 | Age group (under 40 / 40-64 / 65+) and sex (needed by ESC 2023 V2-V3 thresholds) | Spec v2 s4.1: "age and sex"; prototype uses age groups | | |

Also for your decision: which symptoms escalate which level (R-26), and which symptom combinations
should always give red (**GAP**: none defined in the repo).

## 7. Open questions C1-C7

Reproduced from OPEN_QUESTIONS.md section C. Please answer in the Comment column or in conversation;
answers are then recorded in OPEN_QUESTIONS.md.

| ID | Q | Question | What it decides | Decision | Comment |
|---|---|---|---|---|---|
| R-82 | C1 | Review of the urgency mapping (red / yellow / green) and of the action steps for each target pathology. | Sections 2 to 4 of this package | | |
| R-83 | C2 | Which pathologies matter most in practice for feldshers, and which mistakes would be most dangerous? | MVP target list; R-13; hazard severities | | |
| R-84 | C3 | Is it possible to collect anonymised Kyrgyz ECGs with a cardiologist's reading for proper validation, and under which consent / ethics framework? | Validation plan (hazards H-14) | | |
| R-85 | C4 | Could you introduce the project to NCCIM or KSMA later on? | "Send to an expert" destination (R-32) | | |
| R-86 | C5 | Which drugs and equipment FAPs actually have (aspirin, heparin, thrombolytics, atropine, defibrillator), and the real referral / transport route per oblast? | Action steps; transfer wording (R-31) | | |
| R-87 | C6 | Which ethics committee would review a retrospective study on anonymised ECGs, and a later pilot? | D12; pilot plan | | |
| R-88 | C7 | What is a feldsher allowed to do at first contact (aspirin, nitrates, heparin, morphine, thrombolysis, cardioversion)? The KR protocols do not say. | Every action step (R-31 to R-34, R-41) | | |

## 8. Further points for the cardiologist (from the research notes)

| ID | Point | Source | Decision | Comment |
|---|---|---|---|---|
| R-90 | The AF protocol (order No. 626) has a reference list headed "Uzbekistan MoH 2024". Is it the version in force? | Research 10 summary; OPEN_QUESTIONS A5 | | |
| R-91 | Aspirin dose differs inside the NSTE-ACS text (165-325 mg versus 150-300 mg). | Research 10 s2, s6 | | |
| R-92 | The KR texts were read from a secondary host (MedElement), not the official PDFs. Please say whether they are current. | Research 10 s6 | | |
| R-93 | No KR protocol was found for AV block, VT/VF, SVT or pre-hospital emergency care by feldshers. Is there one? Otherwise ERC / ESC will be cited and flagged. | Research 10 s5; research 01 open question 3 | | |
| R-94 | Russian and Kyrgyz medical wording of all texts above. | Research 01 open question 6; hazard H-13 | | |
| R-95 | Sign-off on severity ratings and residual risk in the hazard list (H-01 to H-17). | HAZARD_LIST header | | |

## 9. Gaps summary

1. No feldsher-level checklist in any KR protocol (C7).
2. No KR protocol for VT/VF or AV block; no action text for them in the app.
3. No ST-elevation thresholds or STEMI-equivalent list in the KR STEMI text; ESC 2023 used.
4. Draft cut-offs (110-120, 130, 180, 40/min) are not sourced beyond textbook and the KR AF 180/min criterion.
5. Symptom list in the app differs from the draft; no symptom-to-level escalation is implemented yet.
6. D10 date is not shown; D12 does not exist yet.
7. Clinical texts in Kyrgyz do not exist yet (Russian placeholders).
8. Review of the red-path steps depends on C5 and C7.

## 10. Review log

| Date | Reviewer | Items reviewed | Outcome |
|---|---|---|---|
| | | | |
