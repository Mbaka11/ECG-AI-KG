import '../models/ecg_case.dart';
import '../widgets/ecg_trace.dart';

/// Demo scenarios for the UI prototype. No model runs; results are canned.
///
/// Clinical texts: short paraphrases of the KR MoH protocols summarised in
/// docs/research/10-kr-protocols.md. No drug doses are shown (hazard H-07).
/// Every step is "pending cardiologist review" until OPEN_QUESTIONS C1/C7 are answered.

const _stemi = 'KR MoH STEMI protocol, order 1342 (2024)';
const _nsteacs = 'KR NSTE-ACS protocol (2022), pre-hospital stage';
const _af = 'KR MoH AF protocol, order 626 (2024)';
const _adr3 = 'Project design (ADR 0003)';
const _safety = 'Project safety rule (INTENDED_USE D2/D4)';

EcgCase demoCase(Scenario s, {DateTime? at, String? id}) {
  final when = at ?? DateTime.now();
  final cid = id ?? 'C-${when.millisecondsSinceEpoch % 100000}';
  switch (s) {
    case Scenario.red:
      return EcgCase(
        id: cid,
        createdAt: when,
        scenario: s,
        urgency: Urgency.red,
        rhythm: DemoRhythm.stElevation,
        heartRate: 74,
        highlights: const [(2.1, 2.7), (4.6, 5.2), (7.2, 7.8)],
        headline: const LocalText(
          'Possible acute ischaemia (heart attack pattern)',
          'Возможная острая ишемия (признаки инфаркта)',
        ),
        findings: const [
          Finding(
            LocalText('ST elevation pattern', 'Подъём сегмента ST'),
            detail: LocalText('Seen in leads II, III, aVF', 'В отведениях II, III, aVF'),
          ),
          Finding(LocalText('Sinus rhythm, 74/min', 'Синусовый ритм, 74/мин'), suspected: false),
        ],
        steps: const [
          ActionStep(
              LocalText('Arrange urgent transfer to a hospital with a cardiology unit now. Every minute counts.',
                  'Срочно организуйте перевод в стационар с кардиологическим отделением. Важна каждая минута.'),
              _stemi),
          ActionStep(
              LocalText('Send this ECG to an expert now.', 'Отправьте эту ЭКГ эксперту прямо сейчас.'), _adr3),
          ActionStep(
              LocalText('Check pulse, blood pressure, breathing rate and SpO₂.',
                  'Контролируйте пульс, АД, частоту дыхания и SpO₂.'),
              _nsteacs),
          ActionStep(
              LocalText('Give medicines only as your protocol and training allow.',
                  'Назначайте препараты только согласно протоколу и вашим полномочиям.'),
              _nsteacs),
        ],
        tech: const TechDetails(speedMmS: 25, gainMmMv: 10, leadsFound: 12, layout: '3×4 + II', quality: 0.86),
        extraNotices: const [Notice.acsNotExcluded],
      );
    case Scenario.amber:
      return EcgCase(
        id: cid,
        createdAt: when,
        scenario: s,
        urgency: Urgency.amber,
        rhythm: DemoRhythm.af,
        heartRate: 108,
        highlights: const [(0, 10)],
        headline: const LocalText('Suspected atrial fibrillation', 'Подозрение на фибрилляцию предсердий'),
        findings: const [
          Finding(
            LocalText('Irregular rhythm, no clear P waves', 'Нерегулярный ритм, нет чётких зубцов P'),
            detail: LocalText('Ventricular rate about 108/min', 'ЧСС около 108/мин'),
          ),
        ],
        steps: const [
          ActionStep(
              LocalText(
                  'Check for danger signs: fainting, low blood pressure, chest pain, rate over 180/min. If present, treat as an emergency.',
                  'Проверьте признаки опасности: обморок, низкое АД, боль в груди, ЧСС более 180/мин. При их наличии — действуйте как при неотложном состоянии.'),
              _af),
          ActionStep(
              LocalText('If no danger signs: refer to a doctor or cardiologist to confirm the diagnosis.',
                  'Если признаков опасности нет — направьте к врачу или кардиологу для подтверждения диагноза.'),
              _af),
          ActionStep(
              LocalText('If the machine allows, record a longer strip (more than 30 seconds).',
                  'Если аппарат позволяет, запишите более длинную ленту (более 30 секунд).'),
              _af),
          ActionStep(LocalText('Send the ECG to an expert.', 'Отправьте ЭКГ эксперту.'), _adr3),
        ],
        tech: const TechDetails(speedMmS: 25, gainMmMv: 10, leadsFound: 3, layout: '3-channel strip', quality: 0.78),
        extraNotices: const [Notice.afConfirm, Notice.rhythmOnly],
      );
    case Scenario.green:
      return EcgCase(
        id: cid,
        createdAt: when,
        scenario: s,
        urgency: Urgency.green,
        rhythm: DemoRhythm.sinus,
        heartRate: 72,
        headline: const LocalText('No urgent pattern found', 'Неотложных изменений не найдено'),
        findings: const [
          Finding(LocalText('Sinus rhythm, 72/min', 'Синусовый ритм, 72/мин'), suspected: false),
        ],
        steps: const [
          ActionStep(
              LocalText('This does not exclude heart disease. Decide based on the patient’s condition.',
                  'Это не исключает заболевание сердца. Решение принимайте по состоянию пациента.'),
              _safety),
          ActionStep(
              LocalText('If symptoms continue or get worse, repeat the ECG and contact a doctor.',
                  'Если симптомы сохраняются или усиливаются, повторите ЭКГ и свяжитесь с врачом.'),
              _safety),
        ],
        tech: const TechDetails(speedMmS: 25, gainMmMv: 10, leadsFound: 12, layout: '3×4 + II', quality: 0.91),
        extraNotices: const [Notice.acsNotExcluded],
        sync: SyncState.synced,
      );
    case Scenario.grey:
      return EcgCase(
        id: cid,
        createdAt: when,
        scenario: s,
        urgency: Urgency.grey,
        rhythm: DemoRhythm.noisy,
        highlights: const [(3.2, 4.6)],
        headline: const LocalText('Cannot interpret this photo', 'Не удалось расшифровать фото'),
        findings: const [
          Finding(LocalText('Part of the trace is missing', 'Часть записи не видна'), suspected: false),
          Finding(LocalText('Paper gain not readable', 'Не удалось определить усиление'), suspected: false),
        ],
        steps: const [
          ActionStep(
              LocalText('Retake the photo: paper flat, good light, whole strip in the frame.',
                  'Переснимите: лента ровная, хорошее освещение, вся лента в кадре.'),
              _safety),
          ActionStep(
              LocalText('If it still fails, record a new ECG or send it to an expert.',
                  'Если не получается — запишите ЭКГ заново или отправьте эксперту.'),
              _safety),
          ActionStep(
              LocalText('If the patient is unwell, act per protocol now. Do not wait for the app.',
                  'Если пациенту плохо — действуйте по протоколу сейчас, не ждите приложения.'),
              _safety),
        ],
        tech: const TechDetails(speedMmS: 25, gainMmMv: null, leadsFound: 1, layout: 'unknown', quality: 0.31),
        sync: SyncState.localOnly,
      );
  }
}

/// A few past cases for the history list.
List<EcgCase> seedHistory() {
  final now = DateTime.now();
  return [
    demoCase(Scenario.green, at: now.subtract(const Duration(hours: 3)), id: 'C-10427')
        .copyWith(age: 58, sex: 'f'),
    demoCase(Scenario.amber, at: now.subtract(const Duration(days: 1, hours: 2)), id: 'C-10419')
        .copyWith(age: 71, sex: 'm', symptoms: {Symptom.palpitations}, sync: SyncState.synced),
    demoCase(Scenario.red, at: now.subtract(const Duration(days: 3)), id: 'C-10388')
        .copyWith(age: 63, sex: 'm', symptoms: {Symptom.chestPain}, sync: SyncState.synced),
    demoCase(Scenario.grey, at: now.subtract(const Duration(days: 4)), id: 'C-10371'),
  ];
}
