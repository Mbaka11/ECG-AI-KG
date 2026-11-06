# Kyrgyz UI translation: review package

**Status:** draft, 2026-11-04. **Not for field use.**

## 1. Purpose

The Kyrgyz (`ky`) UI strings and the Kyrgyz demo clinical texts were **machine-drafted** by an
AI assistant. Nobody who speaks Kyrgyz natively has checked them yet. Before any use with real
patients, they must be reviewed by a **native Kyrgyz speaker with a medical background**
(a physician, or a feldsher trainer who teaches in Kyrgyz). A cardiologist must also check the
clinical texts in every language, as for Russian (OPEN_QUESTIONS C1, C7).

The draft is there so that the reviewer can correct a working text instead of translating
from scratch, and so that we can check the layout with real Kyrgyz word lengths.

Where the draft lives:

| What | File |
|---|---|
| UI strings (124 keys, one table: English, Russian, Kyrgyz) | [`mobile/tool/gen_arb.py`](../../mobile/tool/gen_arb.py) |
| Generated Kyrgyz ARB (do not edit by hand) | [`mobile/lib/l10n/app_ky.arb`](../../mobile/lib/l10n/app_ky.arb) |
| Demo findings and action steps (3rd `LocalText` argument) | [`mobile/lib/data/demo_cases.dart`](../../mobile/lib/data/demo_cases.dart) |

The app shows that the translation is a draft. When Kyrgyz is selected, a notice appears on the
welcome screen and in Settings (`kyDraftNote`): *"Кыргызча котормо — долбоор. Аны медицина
адиси али текшере элек. Күмөн болсо, орусча текстти караңыз."* ("The Kyrgyz translation is a
draft. A medical reviewer has not checked it yet. If in doubt, check the Russian text.") The
ARB file carries `@@x-status: DRAFT ...`. Remove both only after the review in section 5 is
signed off.

## 2. Style rules used

- Plain, short sentences for rural health workers. Polite imperative (*-ңыз/-ңүз*:
  *тартыңыз*, *жөнөтүңүз*). Kyrgyz Cyrillic with ө, ү, ң.
- Where clinical Kyrgyz usually keeps the Russian or Latin term, the draft keeps it (ЭКГ,
  ишемия, инфаркт, синдром, тропонин, протокол, кардиолог, отведение, ЧСС, SpO₂). Feldshers
  in Kyrgyzstan mostly trained with Russian clinical vocabulary
  ([research 02, section 6](../research/02-kyrgyz-context.md#6-languages)).
- **The word "normal" is never used** (нормалдуу, кадимки, норма). Green means "no urgent sign
  was found", never "everything is fine". A unit test enforces this
  (`mobile/test/widget_test.dart`).
- Each urgency level has exactly one Kyrgyz label, and no label is reused elsewhere with a
  different meaning (see section 3.1).
- "Not found" is translated as *табылган жок* ("was not found"), not *жок* ("there is none").
  This keeps the meaning that the app may have missed something.

## 3. Glossary

Confidence: **H** = standard everyday Kyrgyz, low risk. **M** = likely right, but other forms
are common. **L** = unsure, the reviewer must decide.

### 3.1 Urgency labels (most important)

| Level | English | Russian | Kyrgyz draft | Meaning to keep | Alternatives | Conf. |
|---|---|---|---|---|---|---|
| Red | Urgent — act now | Срочно — действуйте сейчас | **Шашылыш — азыр аракет кылыңыз** | urgent, act now | Тез арада — азыр аракет кылыңыз; Өтө шашылыш | M |
| Amber | Needs a doctor's review | Нужна консультация врача | **Дарыгер кароосу керек** | needs attention soon, not an emergency | Дарыгердин кеңеши керек; Жакын арада дарыгерге көрсөтүү керек | M |
| Green | No urgent pattern | Без неотложных признаков | **Шашылыш белги табылган жок** | no urgent sign *was found* (not "healthy") | Шашылыш белгилер табылган жок | M |
| Grey | No result | Нет результата | **Жыйынтык жок** | the app cannot interpret this photo | Жыйынтык чыккан жок | H |

Check that *шашылыш* reads as clinical urgency ("неотложно"), not as "hurry up". *Тез жардам*
(ambulance) was avoided on purpose, so that red is not read as "call an ambulance" when the
protocol says "transfer".

### 3.2 Clinical terms

| English | Russian | Kyrgyz draft | Alternatives | Conf. | Note |
|---|---|---|---|---|---|
| ECG | ЭКГ | ЭКГ (ЭКГны, ЭКГ сүрөтү) | электрокардиограмма | H | Kept as is. |
| patient | пациент | бейтап | оорулуу | H | |
| doctor / clinician | врач | дарыгер | врач | H | |
| health worker | медработник | медицина кызматкери | медициналык кызматкер | H | |
| hospital with a cardiology unit | стационар с кардиологическим отделением | кардиология бөлүмү бар оорукана | | H | |
| expert / expert centre | эксперт / экспертный центр | эксперт / эксперттик борбор | адис / адистер борбору | M | *адис* is more native; *эксперт* matches the Russian UI. |
| symptoms | симптомы | симптомдор | белгилер | M | *Белги* is kept for ECG "signs/patterns", so that symptoms and ECG signs stay distinct. |
| sign / pattern (on the ECG) | признак | белги | | M | |
| chest pain | боль в груди | көкүрөктөгү оору | көкүрөк оорусу | H | |
| short of breath | одышка | ентигүү | дем кысылуу | M | |
| fainting | обморок | эсинен тануу | эс-учун жоготуу | M | |
| palpitations | сердцебиение | жүрөктүн катуу кагышы | жүрөк кагуу; жүрөктүн тез согушу | L | Needs a term that a patient would also use. |
| weakness, dizziness | слабость, головокружение | алсыздык, баш айлануу | | H | |
| blood pressure | АД | кан басымы | артериялык кан басымы (АКБ) | H | |
| pulse | пульс | пульс | тамыр кагышы | M | Kept as *пульс*, common in practice. |
| breathing rate | частота дыхания | дем алуу жыштыгы | | M | |
| heart rate | ЧСС | ЧСС | жүрөктүн кагуу жыштыгы | L | Russian abbreviation kept. A Kyrgyz abbreviation was not confirmed. |
| heart attack | инфаркт | инфаркт | жүрөк приступу | M | *инфаркт* is used in Kyrgyz media ([24.kg](https://24.kg/kyrgyzcha/159994_onokot_oorularyi_bar_beytaptar_uchun_oorukanalarda_orundar_jetishtuu/)). |
| acute ischaemia | острая ишемия | курч ишемия | | M | |
| acute coronary syndrome | острый коронарный синдром | курч коронардык синдром | | M | |
| atrial fibrillation | фибрилляция предсердий | фибрилляция предсердий (дүлөйчөлөрдүн фибрилляциясы) | дүлөйчөлөрдүн фибрилляциясы; жыбырма аритмия | L | Russian term kept first. *Дүлөйчө* = atrium in [ky Wikipedia "Жүрөк"](https://ky.wikipedia.org/wiki/Жүрөк). A 2024 Kyrgyz paper title uses "дүлөйчөлүк фибрилляция" (Vestnik MUK No. 2 (54), 2024, search snippet only). |
| atria / ventricles | предсердия / желудочки | дүлөйчөлөр / карынчалар | | M | From ky Wikipedia. |
| sinus rhythm | синусовый ритм | синус ритми | синустук ритм | M | |
| irregular rhythm | нерегулярный ритм | ритм бир калыпта эмес | ритм туура эмес | M | |
| P wave | зубец P | P тиши (P тиштери) | P зубеци | L | Kyrgyz textbook term not confirmed. |
| ST elevation | подъём сегмента ST | ST сегментинин көтөрүлүшү | | M | |
| lead (ECG) | отведение | отведение (II отведение, отведениелер) | тармак | L | Kept in Russian. A native Kyrgyz term was not found. |
| bundle branch block | блокада ножек пучка Гиса | Гис тутамынын буттарынын блокадасы | | L | Literal calque. Check against the KRSU dictionary. |
| troponin | тропонин | тропонин | | H | |
| paper speed / gain | скорость ленты / усиление | лентанын ылдамдыгы / күчөтүү | | M | |
| strip (ECG paper) | лента | лента | тасма | M | *лента* is what users see on the machine. |
| suspected | подозрение | шек бар | шектүү; болушу мүмкүн | M | A tag next to a finding. Headlines use *болушу мүмкүн* ("may be"). |
| diagnosis | диагноз | диагноз | | H | |
| protocol | протокол | протокол | | H | |
| case | случай | учур | окуя | M | |
| per minute | /мин | /мүн | /мин | M | |

### 3.3 UI terms

| English | Kyrgyz draft | Note |
|---|---|---|
| Home / History / Settings | Башкы бет / Тарых / Жөндөөлөр | Android Kyrgyz conventions. |
| Send / Cancel / Done / Continue | Жөнөтүү / Жокко чыгаруу / Даяр / Улантуу | |
| Online / Offline chip | Интернет бар / Интернет жок | Plainer than "онлайн / офлайн". |
| Draft (translation) | долбоор | |
| Account | Каттоо эсеби | |

## 4. Strings we are least sure about

| Key / place | Kyrgyz draft | Concern |
|---|---|---|
| `urgencyAmber` | Дарыгер кароосу керек | Does it say "soon" strongly enough, without sounding like an emergency? |
| `urgencyGreen` | Шашылыш белги табылган жок | Must not read as "healthy" or "normal". |
| `noticeAf`, amber headline | Фибрилляция предсердий (дүлөйчөлөрдүн фибрилляциясы) болушу мүмкүн | Mixed Russian and Kyrgyz. Which form do feldshers recognise? |
| `noticeRhythmOnly` | … Гис тутамынын буттарынын блокадасын … | Literal calque of the Russian anatomical term. |
| `symPalpitations` | Жүрөктүн катуу кагышы | "Strong beating" vs "fast beating" vs "feeling the heartbeat". |
| `leadsFound`, `ecgTrace`, demo detail "II, III, aVF отведениелеринде" | отведение(лер) | A Russian word with Kyrgyz suffixes. Acceptable? |
| demo amber finding | Ритм бир калыпта эмес, P тиштери так көрүнбөйт | The term for "P wave". |
| demo amber detail and step 1 | ЧСС … 180/мүн ашык | Russian abbreviation kept. Is "180/мүн ашык" natural? |
| demo red step 4 | Дарыларды протоколго жана ыйгарым укугуңузга ылайык гана бериңиз | Is *ыйгарым укук* ("authority, scope of practice") clear to a feldsher? |
| `disclaimerFirstLaunch` | … чечим кабыл алууга жардам берет … | Legal-safety text. Check that it clearly says "not a diagnosis". |
| `stepOf` | {b} кадамдын {a}-кадамы | Alternatives: "Кадам {a} / {b}", "{a}-кадам ({b} кадамдан)". |
| `patientSub` | Милдеттүү эмес, бирок кеңештер так болот | Follows the Russian ("more precise"). The English says "safer". |
| `pendingSync` (plural) | {n} учур интернетти күтүүдө | Kyrgyz has no plural agreement after a number. Check the wording. |

Known gap outside the translation: the demo values for `layout` (`3-channel strip`, `unknown`)
come from data and are shown in English in every language.

## 5. Review procedure

1. **Reviewer.** A native Kyrgyz speaker with a medical background, ideally one who trains
   feldshers or works at a FAP or CFM. Record the name, role and date in the sign-off table
   below.
2. **Material.** This file, the table in `mobile/tool/gen_arb.py` (English / Russian / Kyrgyz,
   side by side), the Kyrgyz texts in `mobile/lib/data/demo_cases.dart`, and the screenshots
   (`node shots.mjs <dir> ky` on the web build, as described in `mobile/README.md`).
3. **Order of review.**
   1. The urgency labels (section 3.1) and every safety notice (`disclaimer*`, `notice*`,
      `symptomsOverride`, `kyDraftNote`, `limitationsText`).
   2. The clinical glossary (section 3.2): pick one term per concept and keep it everywhere.
   3. The strings in section 4.
   4. All remaining strings, read on the screens, not only in the table.
4. **What to check.** The meaning matches the Russian (the Russian is the clinical reference).
   Nothing reads as "normal" or as a diagnosis. Wording is short and polite. Placeholders
   (`{n}`, `{list}`, `{a}`, `{b}`, `{app}`, `{model}`, `{date}`) and the plural syntax are
   unchanged.
5. **Apply the changes.** Edit only the third column in `tool/gen_arb.py` and the third
   `LocalText` argument in `demo_cases.dart`. Then run `python tool/gen_arb.py lib/l10n`,
   `flutter gen-l10n`, `flutter analyze` and `flutter test`. Take new Kyrgyz screenshots and
   fix any overflow by shortening the wording.
6. **Clinical sign-off.** Any change to the meaning of a clinical text goes to the
   cardiologist review (OPEN_QUESTIONS C1/C7) in all three languages.
7. **Release.** Only after steps 1 to 6: change `KY_STATUS` in `gen_arb.py` and the
   `kyDraftNote` text to say "reviewed on <date>", update the glossary confidence to
   "reviewed", and note the review in `docs/PLAN.md`.

| Reviewer | Role | Date | Scope | Result |
|---|---|---|---|---|
| | | | | |

## 6. Sources

- Project research on languages and terminology resources:
  [research 02, section 6](../research/02-kyrgyz-context.md#6-languages). It lists the State
  Language Commission's 2024 Russian-Kyrgyz dictionary of medical terms and the KRSU
  Russian-Kyrgyz medical dictionary (2022). Neither was consulted for this draft. The
  reviewer should use them.
- Kyrgyz Wikipedia, "Жүрөк" (heart): дүлөйчө (atrium), карынча (ventricle).
  <https://ky.wikipedia.org/wiki/Жүрөк>. Read on 2026-11-04.
- 24.kg (Kyrgyz edition), 2020: *инфаркт*, *тез жардам*, *оорукана*, *Улуттук кардиология
  борбору* used in news text.
  <https://24.kg/kyrgyzcha/159994_onokot_oorularyi_bar_beytaptar_uchun_oorukanalarda_orundar_jetishtuu/>
- Vestnik MUK No. 2 (54), 2024, a Kyrgyz-language paper on atrial fibrillation in rheumatic
  heart disease ("дүлөйчөлүк фибрилляция"). Seen as a search-result title only; the PDF
  link returned 404. **Unverified.**
- All other choices are the drafter's judgement and are **unverified**. Online searches for
  Kyrgyz MoH protocols in Kyrgyz (AF, STEMI) found no usable text.
