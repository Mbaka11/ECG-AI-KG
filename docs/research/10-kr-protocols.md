# Research 10 — Kyrgyz Republic MoH protocols: first-contact content (AF, NSTE-ACS, STEMI)

Date accessed for all sources: 2026-11-04. Status: draft for the developer; **nothing here is clinical guidance for the app until a cardiologist reviews it** (AGENTS.md: clinical content must cite an official protocol or a cardiologist review).

Labels: **Verified** = I read the text of the cited page myself (downloaded HTML, searched and read the passage). **Not found** = searched and absent from the document. **Unverified** = not read.

Method: the three MedElement pages were downloaded and converted to text; passages below were located by keyword search and read in context. Quotes are verbatim (Russian), translations are mine. The nccim.kg PDF of the 2022 protocol could not be reached from this machine (DNS error), so the NSTE-ACS content comes from the MedElement copy of the same 2022 NCCT text.

## Summary

- All three protocols are **hospital/physician-oriented**. None contains a feldsher- or FAP-specific checklist (the words "ФАП" and "фельдшер" do not appear in any as an actor, except the definition of "first medical contact" in the STEMI protocol). The intended users are named as emergency-ambulance doctors, family doctors, cardiology/therapy departments.
- **Only the NSTE-ACS protocol has an explicit "Догоспитальный этап" (pre-hospital stage) list with drugs and doses.** This is the most directly usable first-contact content.
- **STEMI (order 1342/2024)** gives time targets, the thrombolysis rule and the aspirin dose, but no pre-hospital drug list, no thrombolytic doses and no thrombolysis contraindication list in the text (the document is mostly about PCI). No ST-elevation millimetre thresholds are given; the criterion is only "persistent ST elevation".
- **AF (order 626/2024)** gives ECG criteria, urgent-cardioversion rule for unstable patients, emergency-hospitalisation criteria and drug doses for pharmacological cardioversion; first-contact actions for a feldsher are not given.
- **No Kyrgyz MoH protocol was found for AV block or VT/VF** (see section 5).
- Caveat: the AF protocol's reference section is headed "Клинические протоколы ... Министерства здравоохранения Республики Узбекистан 2024", which suggests the text was adapted from a neighbouring-country source. The approval line still names the Kyrgyz order. Cardiologist should know this.

## 1. Atrial fibrillation — order No. 626 of 11.06.2024

Source: [MedElement, "Фибрилляция предсердий: диагностика и лечение" (КП КР 2024)](https://diseases.medelement.com/disease/%D1%84%D0%B8%D0%B1%D1%80%D0%B8%D0%BB%D0%BB%D1%8F%D1%86%D0%B8%D1%8F-%D0%BF%D1%80%D0%B5%D0%B4%D1%81%D0%B5%D1%80%D0%B4%D0%B8%D0%B9-%D0%B4%D0%B8%D0%B0%D0%B3%D0%BD%D0%BE%D1%81%D1%82%D0%B8%D0%BA%D0%B0-%D0%B8-%D0%BB%D0%B5%D1%87%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BF-%D0%BA%D1%8B%D1%80%D0%B3%D1%8B%D0%B7%D1%81%D1%82%D0%B0%D0%BD-2024/18064). Verified (whole text searched).

**Approval / users (Verified):**
> «Утверждено Приказом Министерства здравоохранения Кыргызской Республики №626 от 11.06.2024 года.» — "Approved by order of the MoH KR No. 626 of 11.06.2024." Next review planned 2029.
> «Пользователи КР: Семейные врачи, врачи первичного уровня здравоохранения, терапевты, кардиологи...» — "Users: family doctors, primary-level doctors, therapists, cardiologists..." (feldshers not named).

**ECG criteria (Verified):**
> «1) абсолютную нерегулярность сердечных сокращений (интервалов R R); 2) отсутствие предсердных зубцов Р, вместо которых определяются "f" волны мерцания; 3) интервал между двумя соседними волнами "f" обычно меняется и меньше 200 мсек (больше 300 в мин.).»
> — "1) absolute irregularity of the heartbeat (R-R intervals); 2) no atrial P waves, replaced by fibrillation 'f' waves; 3) the interval between adjacent f waves usually varies and is under 200 ms (over 300/min)."
> «Для постановки диагноза необходима регистрация эпизода аритмии, продолжительностью более 30 секунд.» — "To make the diagnosis an arrhythmia episode longer than 30 seconds must be recorded."

App implication: a 10 s strip cannot meet the 30 s rule, so the wording must stay "suspected AF" (consistent with research 01).

**Urgent action for unstable patients (Verified):**
> «У пациентов с пароксизмом ФП и нестабильной гемодинамикой или острой ишемией миокарда ... начало антикоагулянтной терапии не должно задерживать проведения экстренной кардиоверсии. В этом случае целесообразно внутривенно ввести парентеральные антикоагулянты (НФГ или НМГ)...»
> — "In a patient with AF paroxysm and unstable haemodynamics or acute myocardial ischaemia ... starting anticoagulation must not delay urgent cardioversion; it is reasonable to give parenteral anticoagulants (UFH or LMWH) intravenously."
> Flutter: «В случаях, когда ТП сопровождается выраженными нарушениями гемодинамики (артериальная гипотензия, острая коронарная или сердечная недостаточность), методом выбора для прекращения аритмии является неотложная электрическая кардиоверсия.» — "When flutter causes marked haemodynamic compromise (hypotension, acute coronary or heart failure), urgent electrical cardioversion is the method of choice."
> Electrical cardioversion must be QRS-synchronised; biphasic energy "обычно не более 150-200 Дж" (usually up to 150-200 J); performed under brief anaesthesia (this is a hospital/ambulance-doctor procedure).

**Referral / hospitalisation criteria (Verified), section "Показания для экстренной госпитализации":**
> «Фибрилляция предсердия с нарушением гемодинамики (пресинкопальные или синкопальные состояния, гипотония, признаки ишемии миокарда) вне зависимости от давности пароксизма и формы ФП и/или ФП с частым желудочковым ответом (>180 в минуту).»
> — "AF with haemodynamic compromise (presyncope/syncope, hypotension, signs of myocardial ischaemia) regardless of paroxysm duration and AF form, and/or AF with rapid ventricular response (>180/min)."
> «Пароксизм ФП сроком до 48 часов при неэффективной попытке медикаментозной кардиоверсии или противопоказаниях к медикаментозной кардиоверсии.» — "AF paroxysm up to 48 h with failed or contraindicated pharmacological cardioversion."
> «...восстановление ритма или ритм-урежающая терапия может проводиться бригадой СМП на догоспитальном этапе.» — "Rhythm restoration or rate control may be done by the ambulance team at the pre-hospital stage" (indications: unstable haemodynamics; rapid ventricular rate with prior guideline-conform anticoagulation; paroxysm up to 48 h).

**First-time AF, outpatient (Verified):**
> «Пациента с впервые выявленной фибрилляцией предсердий или подозрением на нее целесообразно направить на консультацию к врачу-кардиологу или специалисту по лечению ФП...» — "A patient with new or suspected AF should be referred to a cardiologist or AF specialist."

**Drugs and doses (Verified; hospital/ambulance-doctor level, Table 22 "для недавно развившегося приступа ФП"):**

| Drug | Dose in the protocol |
|---|---|
| Amiodarone | 5 mg/kg IV over 1 h, then 50 mg/h |
| Procainamide | 500–1000 mg IV once, slowly (20–30 mg/min) |
| Propafenone | 2 mg/kg IV over 10 min, or 450–600 mg orally |
| Flecainide | 2 mg/kg IV over 10 min, or 200–300 mg orally |

Rate control: first-line beta-blockers and verapamil/diltiazem; digoxin; amiodarone for unstable patients or markedly reduced EF in emergency care (class IIb). Initial resting-rate target <110/min. Verapamil, diltiazem and digoxin IV are contraindicated in AF with WPW («противопоказаны при пароксизмах ФП у больных синдромом ВПУ»). No rate-control doses were found in the text I searched (Not found).

**Anticoagulation (Verified):** CHA2DS2-VASc is the basis of stratification; OAC recommended for men with score ≥2 and women ≥3 («Пероральные антикоагулянты рекомендованы больным мужского пола с суммой баллов по CHA2 DS2 -VASc ≥2»). Substituting antiplatelets for anticoagulants is stated as unacceptable. Decision is out of feldsher scope.

**Gaps:** no feldsher/FAP checklist; no pre-hospital ECG-transmission or transport-time rule; no doses for rate control.

## 2. NSTE-ACS — 2022 (NCCT named after M. Mirrakhimov)

Source: [MedElement, "Острый коронарный синдром без элевации сегмента ST на ЭКГ" (КП КР 2022)](https://diseases.medelement.com/disease/%D0%BE%D1%81%D1%82%D1%80%D1%8B%D0%B9-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D1%8B%D0%B9-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC-%D0%B1%D0%B5%D0%B7-%D1%8D%D0%BB%D0%B5%D0%B2%D0%B0%D1%86%D0%B8%D0%B8-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BD%D0%B0-%D1%8D%D0%BA%D0%B3-%D0%BA%D0%BF-%D0%BA%D0%B8%D1%80%D0%B3%D0%B8%D0%B7%D0%B8%D1%8F-2023/17749) (the URL slug says 2023 but the page version is "Клинические протоколы КР 2022"). The original PDF is at [nccim.kg](https://nccim.kg/wp-content/uploads/2023/06/%D0%9F%D1%80%D0%BE%D1%82%D0%BE%D0%BA%D0%BE%D0%BB-%D0%9E%D0%9A%D0%A1%D0%91%D0%9F%D0%A1%D0%A2-2022.pdf) (not reachable from here; not read). Verified for the MedElement text. No MoH order number appears in the text I read (Not found); the text says it was developed after the 2020 ESC NSTE-ACS guideline.

**Users (Verified):** «Врачи службы скорой медицинской помощи, семейные врачи, врачи ургентных и плановых кардиологических и терапевтических отделений стационаров, организаторы здравоохранения.»

**ECG criteria (Verified):**
> «Депрессия сегмента ST ≥0,05мВ в двух или более смежных отведениях с соответствующей клинической картиной предполагает ОКСБЭST и указывает на плохой прогноз» — "ST depression ≥0.05 mV in two or more contiguous leads with a matching clinical picture suggests NSTE-ACS and indicates a poor prognosis."
> «Изолированная инверсия зубца Т на ЭКГ не связана с неблагоприятным прогнозом.» — "Isolated T-wave inversion is not associated with an adverse prognosis."
> «На ЭКГ могут быть следующие изменения: преходящая элевация сегмента ST, стойкая или преходящая депрессия сегмента ST, инверсия зубца Т, сглаженность зубцов Т или псевдонормализация зубцов Т, кроме того, изменения на ЭКГ могут отсутствовать.» — "ECG may show transient ST elevation, persistent or transient ST depression, T inversion, flat or pseudo-normalised T, or no change."
> «Выполнить ЭКГ в 12 отведениях в течение 10 мин после первого медицинского контакта и немедленно провести ее интерпретацию опытным специалистом» (class I) — "Record a 12-lead ECG within 10 min of first medical contact and have an experienced person interpret it immediately."
> STE vs NSTE split: STE-ACS = «острой болью в грудной клетке и сохраняющимся >20 мин подъемом сегмента ST» (chest pain with ST elevation persisting >20 min).

**Pre-hospital stage (Verified; this is the key first-contact passage), «Догоспитальный этап»:**
> «1. Опрос, физикальный осмотр, регистрация ЭКГ, АД, ЧД, сатурации кислорода в крови. 2. Сублингвально применяют НТГ или изосорбид в таблетированной форме либо в виде аэрозоля (лучше). 3. Аспирин в дозе от 165-325 мг, клопидогрель внутрь 300 мг. 4. При сохраняющихся ангинозных болях вводят морфин 2-4 мг. 5. Инфузия НТГ или изосорбида динитрата. 6. Гепарин в виде болюса в дозе 60 ЕД/кг массы тела, максимальная доза 5000 ЕД. 7. Бетаблокаторы.»
> — "1. History, examination, ECG, BP, respiratory rate, oxygen saturation. 2. Sublingual nitroglycerin or isosorbide, tablets or spray (spray preferred). 3. Aspirin 165–325 mg, clopidogrel 300 mg orally. 4. If chest pain persists, morphine 2–4 mg. 5. Infusion of nitroglycerin or isosorbide dinitrate. 6. Heparin bolus 60 U/kg, maximum 5000 U. 7. Beta-blockers."

Note: the same document later says aspirin "150-300 мг" chewed (hospital list and antiplatelet section), so the dose range differs slightly inside the document (165–325 vs 150–300 mg). Flag for the cardiologist. No oxygen recommendation and no contraindication list were found in the pre-hospital list (Not found). Doses for non-feldsher use; whether a feldsher may give heparin/morphine is not stated.

**Referral / admission (Verified):**
> «ОКСБЭST является заболеванием, требующим неотложной диагностики и лечения, такие пациенты нуждаются в срочной госпитализации в палаты интенсивной терапии, реанимации. Обследование и лечение таких больных начинается с первого контакта с медиками на дому или в общественных местах по приезду кареты скорой медицинской помощи, в поликлиниках семейными врачами и т.д.»
> — "NSTE-ACS needs urgent diagnosis and treatment; patients need urgent admission to intensive care/resuscitation units. Assessment and treatment begin at first contact with medical staff at home, in public places on arrival of the ambulance, at polyclinics by family doctors, etc."
> By risk: very high and high risk go to intensive care; moderate risk to resuscitation/therapy or planned wards; low risk to planned wards.

**Urgent invasive strategy criteria (Verified):**
> «Неотложная инвазивная стратегия (<2 ч) рекомендована пациентам, по крайней мере, с одним из следующих критериев очень высокого риска: Нестабильная гемодинамика или кардиогенный шок; Рецидивирующие или продолжающиеся ангинозные боли, невосприимчивые к лечению; Жизнеугрожающие аритмии или остановка сердца; "Механические" осложнения ИМ; Острая сердечная недостаточность...; Стойкая депрессия сегмента ST >1 мм в ≥6 отведениях в совокупности с подъемом ST в aVR и/или V1.»
> Early invasive (<24 h): NSTEMI diagnosis, dynamic ST/T changes, transient ST elevation, GRACE >140.

App implication: the "ST depression ≥6 leads + STE in aVR/V1" pattern is an explicit KR very-high-risk criterion (<2 h), which supports mapping it to red. Troponin (hs-cTn) within 60 min is also required, which a feldsher with a photo-based app cannot provide.

## 3. STEMI — Annex 7 to MoH KR order No. 1342 of 25.12.2024

Source: [MedElement, "Реваскуляризация миокарда при ОКС с подъемом сегмента ST" (КП КР 2024)](https://diseases.medelement.com/disease/%D1%80%D0%B5%D0%B2%D0%B0%D1%81%D0%BA%D1%83%D0%BB%D1%8F%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D0%BC%D0%B8%D0%BE%D0%BA%D0%B0%D1%80%D0%B4%D0%B0-%D0%BF%D1%80%D0%B8-%D0%BE%D1%81%D1%82%D1%80%D0%BE%D0%BC-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D0%BE%D0%BC-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC%D0%B5-%D1%81-%D0%BF%D0%BE%D0%B4%D1%8A%D0%B5%D0%BC%D0%BE%D0%BC-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BA%D0%BF-%D0%BA%D1%80-2024/18614). Verified (whole text searched). Title says "revascularisation", so the text is PCI/reperfusion-centred.

**Approval (Verified):** «Приложение 7 к приказу МЗКР №1342 от 25.12.2024 г.»
**Users (Verified):** «врачам службы скорой медицинской помощи, семейным врачам, врачам ургентных и плановых кардиологических и терапевтических отделений стационаров, рентгенхирургам, интервенционным кардиологам...»

**First medical contact definition (Verified):**
> «Первичный медицинский контакт (ПМК) - время первичного контакта на догоспитальном этапе или в стационаре с медицинским работником (врач, фельдшер, медсестра), которые могут зарегистрировать ЭКГ и расшифровать ее.»
> — "First medical contact = first contact, pre-hospital or in hospital, with a health worker (doctor, feldsher, nurse) who can record and interpret the ECG." So the clock starts at a feldsher's ECG.

**ECG criterion:** only «Пациенты с острой болью в грудной клетке и сохраняющимся >20 мин подъемом сегмента ST» ("persistent ST elevation >20 min with acute chest pain"); also "ST elevation or its equivalents" is mentioned for immediate invasive management. **No millimetre thresholds, no list of equivalents** (Not found). Use ESC 2023 thresholds from research 01 until a cardiologist decides.

**Time targets table (Verified), «Целевые временные интервалы реперфузионной стратегии»:**

| Interval | Target |
|---|---|
| First medical contact to ECG and diagnosis | max 10 min |
| Diagnosis to primary PCI (wire in the artery); if not met, consider thrombolysis | max 120 min |
| Optimal diagnosis to PCI | 90 min |
| Diagnosis to wire, patient brought directly to a PCI centre | max 60 min |
| Diagnosis to wire, patient transferred to a PCI centre | max 90 min |
| Diagnosis in a non-invasive centre to transfer to a PCI centre | max 30 min |
| Diagnosis to start of thrombolytic infusion (if PCI not feasible in time) | max 10 min |
| Thrombolysis to efficacy assessment | 60–90 min |
| Thrombolysis to angiography if successful | 2–24 h |

**Thrombolysis rule and transport (Verified):**
> «ТЛТ проводится в первые 12ч от начала ИМ при невозможности выполнить пЧКВ в течение 120 мин от постановки диагноза ИМпST.» (class I, A) — "Thrombolysis within the first 12 h from MI onset when primary PCI cannot be done within 120 min of STEMI diagnosis."
> «Если выбрана стратегия реперфузии с помощью ТЛТ, ее следует проводить незамедлительно, лучше на догоспитальном этапе.» (I, A) — "If thrombolysis is chosen, give it immediately, preferably pre-hospital."
> «Предпочтительными являются фибрин-специфические тромболитики (альтеплаза, тенектеплаза, проурокиназа, стафилокиназа)» (I, A).
> «Пациентов рекомендуется переводить в центры с возможностью проведения ЧКВ для первичного ЧКВ в обход отделений неотложной помощи и кардиореанимации, и направлять непосредственно в рентген-операционную.» — "Transfer to PCI-capable centres, bypassing emergency and ICU, directly to the cath lab."
> Transport: «Приоритетом должна быть госпитализация в ЧКВ-центр. Вместе с тем продолжительная транспортировка сопряжена с неоправданно высоким риском. Нужно стремиться, чтобы это время не превышало один час.» — "Priority is a PCI centre, but long transport carries unjustifiably high risk; aim for transport not exceeding one hour."
> Ambulance diagnosis: «это время должно не превышать 10 мин. Если принимается решение о догоспитальной ТЛТ, она должна быть начата немедленно в течение 10 минут.»
> Remote areas: the text notes ambulance arrival time «В отделенных населенных пунктах ... может быть значительно больше по объективным причинам» ("in remote places may be much longer").

**Drugs (Verified, partial):**
> Aspirin «Дозировка: Пероральная нагрузочная доза — 150—300 мг (или 150 мг внутривенно), поддерживающая доза — 75—100 мг в сутки»; tablet preferably chewed; recommended for all STEMI patients regardless of reperfusion strategy.
> Ticagrelor loading 180 mg then 90 mg twice daily is in the P2Y12 section; clopidogrel/prasugrel also described. Enoxaparin is "the only LMWH recommended for STEMI"; fondaparinux not recommended in STEMI. UFH with thrombolysis: «не имеет доказательств эффективности» for major events (still a long-standing companion).
> Intracranial haemorrhage risk with thrombolysis ~0.9–1.0%; risk factors old age, low weight, female sex, cerebrovascular disease, hypertension on admission.

**Not found in this document:** pre-hospital drug checklist (nitrates, morphine, oxygen), thrombolytic doses, thrombolysis contraindication list, feldsher-specific steps, ECG-transmission/telemedicine procedure, list of STEMI equivalents. These need the cardiologist, or another KR document (for example a pre-hospital/emergency-care order), if one exists.

## 4. Comparison for app design (draft, for cardiologist review)

| Topic | KR protocol statement | App relevance |
|---|---|---|
| Time clock | FMC to ECG/diagnosis ≤10 min (STEMI, NSTE-ACS) | App result should appear fast and show "time from first contact" |
| STEMI reperfusion choice | PCI ≤120 min from diagnosis, else thrombolysis ≤10 min after decision; transfer decision ≤30 min | Action text: "refer/transfer to PCI centre now" |
| NSTE-ACS very high risk | <2 h invasive: instability, refractory pain, arrhythmia, acute HF, ST depression in ≥6 leads + STE aVR/V1 | Supports red for that pattern |
| AF unstable | Urgent cardioversion; hospitalise if presyncope/syncope/hypotension/ischaemia or rate >180 | Supports "red if unstable or >180" in research 01 draft |
| AF stable/new | Refer to cardiologist; anticoagulation by CHA2DS2-VASc | Yellow/green plus referral |

## 5. AV block and VT/VF — no Kyrgyz protocol found

- Searches (2026-11-04, Russian) for a KR MoH clinical protocol on atrioventricular block, ventricular tachycardia/VF/sudden cardiac death, and bradyarrhythmia/supraventricular tachycardia/emergency care returned **no Kyrgyz document**. Results were Belarus ([bradyarrhythmia protocol](https://minzdrav.gov.by/upload/dadvfiles/CProtokol/%D0%9A%D0%9F1_%D0%B1%D1%80%D0%B0%D0%B4%D0%B8%D0%B0%D1%80%D0%B8%D1%82%D0%BC%D0%B8%D0%B8,%20%D0%BD%D0%B0%D1%80%D1%83%D1%88%D0%B5%D0%BD%D0%B8%D1%8F%20%D0%BF%D1%80%D0%BE%D0%B2%D0%BE%D0%B4%D0%B8%D0%BC%D0%BE%D1%81%D1%82%D0%B8.pdf), [VF/VT protocol KP5](https://minzdrav.gov.by/upload/dadvfiles/CProtokol/%D0%9A%D0%9F5_%D1%84%D0%B8%D0%B1%D1%80%D0%B8%D0%BB%D0%BB%D1%8F%D1%86%D0%B8%D1%8F%20%D0%B6%D0%B5%D0%BB%D1%83%D0%B4%D0%BE%D1%87%D0%BA%D0%BE%D0%B2%D1%8B%D1%85%20%D0%B8%20%D0%B6%D0%B5%D0%BB%D1%83%D0%B4%D0%BE%D1%87%D0%BA%D0%BE%D0%B2%D0%B0%D1%8F%20%D1%82%D0%B0%D1%85%D0%B8%D0%BA%D0%B0%D1%80%D0%B4%D0%B8%D1%8F.pdf)) and Russia (Russian Society of Cardiology VT/SCD recommendations, 2025 edition). These are other countries and only usable as reference, not as KR authority.
- The MedElement pages for the three KR protocols link to no related KR rhythm/conduction protocol, and MedElement's own search is script-driven so I could not query it directly (limitation: absence is not proven).
- Not checked (unreachable or not indexed by the search tool): the MoH KR site, the legal database cbd.minjust.gov.kg, cez.med.kg order list, nccim.kg. Absence is therefore "not found by web search", not "does not exist". The prior note in research 01 reached the same conclusion.
- Consequence: for complete AV block and VT/VF the app's action steps must cite ERC 2021 / ESC 2021 (as already planned in research 01) and be flagged "pending cardiologist review", or the author must provide a local ambulance/emergency-care order.
- Indirect KR hint: the AF protocol's text on WPW and flutter mentions urgent electrical cardioversion for unstable patients, and the NSTE-ACS protocol lists "жизнеугрожающие аритмии или остановка сердца" as a very-high-risk criterion; neither gives arrhythmia-specific steps.

## 6. Gaps and follow-ups

1. No feldsher-level (FAP) checklist exists in any of the three protocols. Whether a feldsher may give heparin, morphine, thrombolytics or perform cardioversion is not stated. Ask the author/cardiologist and look for a separate MoH order on pre-hospital emergency care (open question 3 in research 01 remains open).
2. STEMI protocol: ST thresholds, equivalents, thrombolytic doses and contraindications are absent from the MedElement text. If the official order PDF contains more (for example an annex or flowchart image, "Рисунок 5" is only referenced), it was not available to me.
3. NSTE-ACS: official PDF at nccim.kg not read; MoH order number not found; aspirin dose inconsistency (165–325 mg pre-hospital vs 150–300 mg elsewhere).
4. AF: reference list names Uzbekistan MoH 2024; check provenance with the author. Rate-control doses not found.
5. Both MedElement pages are a secondary host. Compare with the MoH-published originals before quoting in the app or in a publication.
6. Russian text is authoritative for the app; Kyrgyz-language terminology is not covered here (research 01 open question 6).

## Sources (accessed 2026-11-04)

- KR AF protocol, order 626/2024 (MedElement): https://diseases.medelement.com/disease/%D1%84%D0%B8%D0%B1%D1%80%D0%B8%D0%BB%D0%BB%D1%8F%D1%86%D0%B8%D1%8F-%D0%BF%D1%80%D0%B5%D0%B4%D1%81%D0%B5%D1%80%D0%B4%D0%B8%D0%B9-%D0%B4%D0%B8%D0%B0%D0%B3%D0%BD%D0%BE%D1%81%D1%82%D0%B8%D0%BA%D0%B0-%D0%B8-%D0%BB%D0%B5%D1%87%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BF-%D0%BA%D1%8B%D1%80%D0%B3%D1%8B%D0%B7%D1%81%D1%82%D0%B0%D0%BD-2024/18064
- KR NSTE-ACS protocol 2022 (MedElement): https://diseases.medelement.com/disease/%D0%BE%D1%81%D1%82%D1%80%D1%8B%D0%B9-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D1%8B%D0%B9-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC-%D0%B1%D0%B5%D0%B7-%D1%8D%D0%BB%D0%B5%D0%B2%D0%B0%D1%86%D0%B8%D0%B8-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BD%D0%B0-%D1%8D%D0%BA%D0%B3-%D0%BA%D0%BF-%D0%BA%D0%B8%D1%80%D0%B3%D0%B8%D0%B7%D0%B8%D1%8F-2023/17749
- KR NSTE-ACS protocol 2022 (original PDF, not read): https://nccim.kg/wp-content/uploads/2023/06/%D0%9F%D1%80%D0%BE%D1%82%D0%BE%D0%BA%D0%BE%D0%BB-%D0%9E%D0%9A%D0%A1%D0%91%D0%9F%D0%A1%D0%A2-2022.pdf
- KR STEMI revascularisation protocol, order 1342/2024 (MedElement): https://diseases.medelement.com/disease/%D1%80%D0%B5%D0%B2%D0%B0%D1%81%D0%BA%D1%83%D0%BB%D1%8F%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D0%BC%D0%B8%D0%BE%D0%BA%D0%B0%D1%80%D0%B4%D0%B0-%D0%BF%D1%80%D0%B8-%D0%BE%D1%81%D1%82%D1%80%D0%BE%D0%BC-%D0%BA%D0%BE%D1%80%D0%BE%D0%BD%D0%B0%D1%80%D0%BD%D0%BE%D0%BC-%D1%81%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC%D0%B5-%D1%81-%D0%BF%D0%BE%D0%B4%D1%8A%D0%B5%D0%BC%D0%BE%D0%BC-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0-st-%D0%BA%D0%BF-%D0%BA%D1%80-2024/18614
- Reference-only (other countries, not KR authority): Belarus bradyarrhythmia protocol https://minzdrav.gov.by/upload/dadvfiles/CProtokol/%D0%9A%D0%9F1_%D0%B1%D1%80%D0%B0%D0%B4%D0%B8%D0%B0%D1%80%D0%B8%D1%82%D0%BC%D0%B8%D0%B8,%20%D0%BD%D0%B0%D1%80%D1%83%D1%88%D0%B5%D0%BD%D0%B8%D1%8F%20%D0%BF%D1%80%D0%BE%D0%B2%D0%BE%D0%B4%D0%B8%D0%BC%D0%BE%D1%81%D1%82%D0%B8.pdf ; Belarus VF/VT protocol KP5 https://minzdrav.gov.by/upload/dadvfiles/CProtokol/%D0%9A%D0%9F5_%D1%84%D0%B8%D0%B1%D1%80%D0%B8%D0%BB%D0%BB%D1%8F%D1%86%D0%B8%D1%8F%20%D0%B6%D0%B5%D0%BB%D1%83%D0%B4%D0%BE%D1%87%D0%BA%D0%BE%D0%B2%D1%8B%D1%85%20%D0%B8%20%D0%B6%D0%B5%D0%BB%D1%83%D0%B4%D0%BE%D1%87%D0%BA%D0%BE%D0%B2%D0%B0%D1%8F%20%D1%82%D0%B0%D1%85%D0%B8%D0%BA%D0%B0%D1%80%D0%B4%D0%B8%D1%8F.pdf (seen as search results only, not read).
- Context: research 01 (`docs/research/01-clinical-domain.md`).
