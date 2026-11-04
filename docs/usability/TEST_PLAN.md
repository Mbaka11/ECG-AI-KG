# Formative usability test plan (IEC 62366-lite, draft v0.1)

Status: **draft** · Phase 2 · 2026-11-04. Addresses hazard **H-06** (over-trust / automation
bias) and the usability parts of H-02, H-13 and H-16 in [HAZARD_LIST](../safety/HAZARD_LIST.md).
Related: [INTENDED_USE](../safety/INTENDED_USE.md), [REVIEW_PACKAGE](../clinical/REVIEW_PACKAGE.md),
[research 11](../research/11-ux-market.md), [PLAN](../PLAN.md) (4.6). Not a full IEC 62366-1
usability file: this is a small formative study to find problems early.

## 1. Goals

1. Find use errors and confusing screens in capture, retake, result reading, forwarding and
   history, before the app is validated or piloted.
2. Check that a user understands each urgency level (red, yellow/amber, green, grey) and what
   to do next, in Russian and (once translated) Kyrgyz.
3. Look for **automation bias**: does the user follow the colour even when the patient
   scenario says otherwise (especially green with symptoms, grey with an unwell patient)?
4. Check that the disclaimers and the trace overlay are noticed and used.
5. Feed concrete findings into the hazard list and the requirements (section 12).

This is formative: no pass/fail claim about the product, no statistical comparison.

## 2. Participants and recruitment

| Item | Plan |
|---|---|
| Number | 3 to 5 (enough to find most major problems in a formative round) |
| Who | Feldshers or nurses who record or look at ECGs at a FAP, CFM or similar first-contact site; ideally a mix of ages and phone experience |
| Exclusion | Developers; anyone who cannot attend without affecting patient care |
| Recruitment | Through the cardiologist, **after the POC exists** and she agrees (OPEN_QUESTIONS C1, C4). No recruitment from patient lists. Participation is voluntary and unpaid or per local rules |
| Languages | Russian first. Kyrgyz round only after a native medical translation exists (the Kyrgyz UI currently shows Russian placeholders) |
| Record per participant | Code (P1...), role, years of experience, ECG machines used, phone model and OS, preferred language. No names |

## 3. Setting and materials

- Quiet room at a clinic or training room, or the developer's office. The test can be run
  offline: the app works without internet.
- A mid-range Android phone with the app build under test, in airplane mode (confirms offline use).
- **Printed synthetic ECGs only. No patient data and no real ECG photos.** Sources: synthetic
  generators (for example ECG-Image-Kit, BSD-3) or CC-licensed public traces, printed on paper
  that looks like the local strips (width and layout as far as known from OPEN_QUESTIONS A1).
  Material set (each with a card describing the patient scenario):
  1. Clear 12-lead print with an ST-elevation pattern (expected red).
  2. 3-channel strip with irregular rhythm (expected amber / yellow; rhythm only).
  3. Clear sinus rhythm, patient scenario card says "chest pain for 30 minutes" (expected green
     plus symptom banner; tests automation bias).
  4. Poor-quality print: glare, fold, cut-off trace (expected grey).
  5. Sinus rhythm with a scenario card of an unwell patient on a grey result (acts per protocol).
- Scenario cards are fictional (age group, sex, short symptom story) and carry no identifiers.
- Two observers: a moderator and a note-taker. A stopwatch or a screen-record of the **phone
  screen only** (see section 10).
- Printed copies of the consent form and SUS questionnaire (Russian appendix A).

## 4. Tasks

Each task starts from the home screen. The moderator reads the task in neutral words and does not
help unless the participant is stuck for 2 minutes (then a recorded assist is counted as a failure).

| ID | Task | Expected path | Success criterion |
|---|---|---|---|
| T1 | Capture: record the printed ECG with the app (card 1) | New ECG, read the guide, take the photo, check the photo | Photo accepted with the whole strip in frame, no help |
| T2 | Retake: the app says the photo is poor (card 4); fix it | Read the quality message, retake with flat paper and light | A usable photo within 2 retakes, or participant correctly decides to record a new ECG |
| T3 | Check the detected values: say what speed, gain and leads the app found and whether they match the paper | Open "Check these values" and compare with the printed text | Participant finds the values and spots a deliberately wrong value (if the build allows editing) |
| T4 | Read the result for each urgency (cards 1, 2, 3 and 4): say how urgent it is and what you would do | Read the level, the headline and the steps | Correct level named; correct next action stated; participant mentions the limits notice when asked "what can this not tell you?" |
| T5 | Symptoms: enter the symptoms from the scenario card | Tick symptoms, read the banner | Symptoms entered; participant says the patient may need urgent care whatever the ECG shows |
| T6 | Forward: send the case to an expert; then do it with no network | Send to an expert, read the consent, send | Consent read (not just tapped); participant knows whether it was sent or queued |
| T7 | Find history: find the case from "yesterday" and say whether it was sent | History list, open the case | Correct case opened within 60 s |
| T8 | Unwell-patient override: card 5 (grey result, unwell patient) | Act per protocol, do not wait for the app | Participant says they would treat or call for help now, not only retake |
| T9 | Language: switch the app language and find the disclaimer | Settings, About | Language changed; disclaimer found |

## 5. Success criteria (formative)

These are targets that trigger action, not claims.

| Metric | Target | Action if missed |
|---|---|---|
| Task success without help (T1-T9) | At least 80 % of tasks; **no failure on T4 (red and grey) and T8** | Redesign the screen; add a hazard or raise severity |
| Critical use error (see section 7) | Zero | Any critical error is a finding that blocks the pilot until fixed and retested |
| Understanding of urgency levels (T4) | All participants name the level and a correct next step for red, amber and grey | Change wording, icon or colour; retest |
| Green handled safely (T4, T5) | Every participant says green does not exclude disease, and acts on symptoms | Strengthen the green text; review H-05 and H-06 |
| SUS score | At least 68 (average); read with caution for n=3 to 5 | Review the lowest-scoring items |
| Time (see section 7) | Photo to result within a few minutes; no fixed target before a baseline exists | Record as baseline |

## 6. Think-aloud protocol

1. Moderator explains: "We are testing the app, not you. There are no wrong answers. Please
   say aloud what you are looking at, thinking and trying to do."
2. Practice with a neutral example (for example "describe how you would unlock the phone").
3. During tasks, prompt only with "What are you thinking?" or "What do you expect to happen?"
   after 10 seconds of silence. Do not explain the interface, and do not say what a colour means.
4. After each task: "How sure are you about the result?" (1 to 5) and "What would you do next
   with the patient?".
5. After all tasks: a short interview: what was clear or unclear; would you use it at your
   post; what would make you stop trusting it; what is missing; Russian wording problems.
6. Note-taker records exact quotes, hesitation, taps on wrong controls and screens that were not
   read.

## 7. Metrics

| Metric | How measured |
|---|---|
| Task success | Per task: success, success with assist, failure (note-taker, with reason) |
| Errors | Count and description of use errors; classify **critical** (could cause wrong urgency, wrong action or missed escalation), **major**, **minor** |
| Time on task | Stopwatch from the task prompt to the stated completion; T1 to T4 reported separately |
| SUS | 10-item System Usability Scale, translated into Russian, scored 0-100 per participant |
| Confidence | 1-5 rating after each result task, compared with correctness |
| Disclaimer / overlay use | Observed: did the participant read the footer, the notice, the technical values, the overlay (yes / no / only when prompted) |
| Qualitative | Quotes and the post-test interview |

Critical-error examples: calling a green result "healthy"; not retaking after a grey result and
treating it as normal; ignoring reported symptoms because the colour is green; forwarding a
case without reading the consent; entering a patient name or ID.

## 8. What to observe for automation bias

Note, for each result task:

1. Does the participant decide before or after looking at the paper ECG and the trace overlay?
2. Do they compare the app's heart rate, speed and gain with the printed ECG, or accept them?
3. On card 3 (green with chest pain): do they follow the green colour or the scenario?
4. On card 5 (grey with an unwell patient): do they wait for a better photo or act on the patient?
5. Do they read the footer, the notice and the symptom banner, or only the colour?
6. Do they say "the app says" instead of "the ECG shows"? Do they change their own opinion to
   agree with the app (ask: "What was your impression of the paper before the app?")?
7. After a red result, do they act appropriately and still call for help, or wait?
8. Confidence compared with correctness (high confidence on a wrong decision is a finding).
9. Signs of fatigue or time pressure shortcuts (skipping the photo check).

Optional second pass if time permits: show the same card with a deliberately wrong app result in
a test build and note whether the participant notices. Use this only with a clearly labelled
test build and tell participants afterwards that it was a test.

## 9. Consent and data handling

- Written (or recorded verbal) informed consent on a one-page form (appendix A): purpose, voluntary,
  can stop at any time without consequences, what is recorded, who sees it, retention.
- The participant is not the subject of a performance review. Results are reported without names
  or workplace.
- **No patients are involved. No recordings of patients. No patient data, real ECG photos or
  identifiers on any test device or in notes.**
- Notes are coded (P1...). The consent form with names is stored separately from the notes and
  deleted at the end of the study (or per the local ethics rule).
- Audio recording is optional and needs separate consent. If used, store it only in the
  git-ignored `temp/` folder or an encrypted drive, never in git, and delete after transcription
  (target: within 30 days). Screen-record the phone screen only, with no face video.
- Check with the cardiologist whether an ethics opinion is needed for a usability study with
  health workers (OPEN_QUESTIONS C6). Do not start before that is answered.
- Only anonymised, aggregated findings go into `docs/usability/`.

## 10. Procedure and schedule (about 60 minutes per participant)

| Min | Step |
|---|---|
| 0-5 | Welcome, consent, background questions |
| 5-10 | Think-aloud practice |
| 10-45 | Tasks T1-T9 (cards in a fixed order; counterbalance cards 1-4 across participants) |
| 45-55 | Interview and SUS |
| 55-60 | Thank and close; no feedback on correctness before all participants are done |

Pilot the plan once with a colleague first. If the app is not ready for a full flow, test with
the clickable prototype (demo scenarios) and say so in the report.

## 11. Analysis and reporting

1. Fill one table per participant: task, result, time, errors (with class), quotes.
2. List findings with severity: critical, major, minor. Link each to the screen and the hazard ID.
3. Compute task success rates, mean/median time and the SUS score; give individual values (n is small).
4. Short report: findings, proposed fixes, retest list. Store it as `docs/usability/REPORT_YYYY-MM.md`
   (aggregated, anonymised).
5. Repeat after fixes with at least 3 participants, including a new one, before the pilot.

## 12. How findings feed the hazard list

| Finding type | Update |
|---|---|
| Critical use error | New hazard or higher severity/residual risk in HAZARD_LIST (usually H-05, H-06, H-13); add a mitigation with a test |
| Participant over-trusts green or ignores the overlay | H-06: strengthen wording and UI; add training material; set a pilot measurement (DECIDE-AI) |
| Poor-photo handling failure | H-02: adjust the guided capture and the quality-gate messages |
| Misread wording or language problem | H-13: fix the string; send to the translator or the cardiologist |
| Slow or crashing flow | H-16: performance requirement |
| New hazards (patient mix-up in forwarding, small screen, daylight glare) | Add to the "not yet in the table" list in HAZARD_LIST |
| Wording that the cardiologist should decide | Add to the [REVIEW_PACKAGE](../clinical/REVIEW_PACKAGE.md) as a new R-item |

The hazard list is re-reviewed after each round (HAZARD_LIST notes).

## Appendix A. Russian participant-facing materials

### A.1 Информация для участника и согласие

**Исследование удобства использования приложения для чтения ЭКГ**

Мы разрабатываем приложение, которое помогает фельдшерам и медсёстрам прочитать бумажную
ЭКГ по фотографии. Мы хотим понять, удобно ли им пользоваться. **Проверяем приложение, а не вас.**
Ошибок и неправильных ответов здесь нет.

- Участие добровольное. Вы можете остановиться в любой момент или не отвечать на вопрос, без
  каких-либо последствий для вас и вашей работы.
- Встреча займёт около часа. Вы выполните несколько заданий на телефоне с напечатанными
  учебными (искусственными) ЭКГ и расскажете вслух, что думаете.
- Пациентов не будет. Настоящие данные пациентов и настоящие ЭКГ не используются.
- Мы записываем ваши заметки под кодом (П1, П2 ...), без имени и места работы. Экран телефона
  может записываться, лицо - нет. Звук записывается только с вашего отдельного согласия.
- Результаты используются только для улучшения приложения и в обобщённом виде. Согласие с
  вашим именем хранится отдельно от заметок и удаляется по окончании исследования.
- Приложение - исследовательский прототип. Оно не заменяет клиническое решение и не
  предназначено для лечения реальных пациентов.

Согласие: Я прочитал(а) информацию, мне ответили на вопросы, я согласен(на) участвовать.

Подпись ______________ Дата ______________

Отдельно (по желанию): я согласен(на) на аудиозапись  [ ] да  [ ] нет

### A.2 Вводный сценарий для ведущего

«Здравствуйте! Спасибо, что пришли. Мы проверяем приложение, а не вас. Если что-то непонятно -
это недостаток приложения, а не ваш. Пожалуйста, говорите вслух всё, что вы видите, думаете и
собираетесь сделать. Я не буду подсказывать, потому что хочу увидеть, как вы действуете сами.
Если захотите остановиться - скажите. Все ЭКГ на столе - учебные, настоящих пациентов нет.
Представьте, что вы на своём рабочем месте в ФАП, и к вам пришёл пациент, описание которого
написано на карточке.»

### A.3 Задания (читает ведущий)

- З1. «Сфотографируйте эту ЭКГ с помощью приложения.» (карточка 1)
- З2. «Приложение говорит, что фото плохое. Исправьте это.» (карточка 4)
- З3. «Скажите, какую скорость ленты, усиление и отведения нашло приложение. Совпадает ли это с бумагой?»
- З4. «Посмотрите на результат. Насколько это срочно и что вы будете делать?» (карточки 1, 2, 3, 4)
- З5. «Введите симптомы пациента из карточки.»
- З6. «Отправьте этот случай эксперту. Теперь то же самое без интернета.»
- З7. «Найдите в истории случай со вчерашнего дня. Он отправлен?»
- З8. «Результат серый, а пациенту плохо. Что вы делаете?» (карточка 5)
- З9. «Смените язык приложения и найдите предупреждение о том, что это не диагноз.»

Вопросы после каждого задания: «О чём вы думаете?» · «Что вы ожидали увидеть?» ·
«Насколько вы уверены в результате, от 1 до 5?» · «Что вы будете делать с пациентом дальше?»

### A.4 Заключительные вопросы

1. Что было понятно, а что - нет?
2. Какие слова или картинки на экране сбили вас с толку?
3. Что вы думаете о цветах и о том, что означает каждый?
4. Стали бы вы пользоваться таким приложением на своём рабочем месте? Почему?
5. Что могло бы заставить вас перестать доверять приложению?
6. Чего не хватает в приложении?
7. Что бы вы изменили в русском тексте?

### A.5 Шкала удобства использования (SUS)

Оцените каждое утверждение: 1 - совсем не согласен(на), 5 - полностью согласен(на).

1. Я хотел(а) бы пользоваться этим приложением часто.
2. Приложение показалось мне излишне сложным.
3. Приложением было легко пользоваться.
4. Мне понадобилась бы помощь технического специалиста, чтобы пользоваться приложением.
5. Функции приложения хорошо согласуются друг с другом.
6. В приложении было слишком много несоответствий и противоречий.
7. Думаю, большинство коллег быстро научатся пользоваться этим приложением.
8. Пользоваться приложением было очень неудобно.
9. Я чувствовал(а) себя уверенно, пользуясь приложением.
10. Мне нужно было многому научиться, прежде чем я смог (смогла) пользоваться приложением.

Подсчёт (для исследователя): для нечётных пунктов - ответ минус 1; для чётных - 5 минус ответ;
сумма умножается на 2,5 (получается от 0 до 100).

### A.6 Заключение

«Спасибо! Вы очень помогли. Ответы на задания мы не оцениваем и не сообщаем никому по именам.
Если у вас появятся вопросы или мысли позже, свяжитесь с нами.»
