// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navHome => 'Главная';

  @override
  String get history => 'История';

  @override
  String get settings => 'Настройки';

  @override
  String get welcomeTitle => 'Помощь в чтении ЭКГ';

  @override
  String get welcomeBody =>
      'Сфотографируйте бумажную ЭКГ. Приложение покажет, насколько это может быть срочно, и что делать дальше. Работает без интернета.';

  @override
  String get chooseLanguage => 'Язык';

  @override
  String get researchTitle => 'Исследовательский прототип';

  @override
  String get disclaimerFirstLaunch =>
      'Исследовательский прототип. Помощь в принятии решений для обученного медработника. Не является диагнозом. Не заменяет клиническое решение или кардиолога.';

  @override
  String get iUnderstand => 'Я понимаю';

  @override
  String get start => 'Начать';

  @override
  String get homeGreeting => 'Что нужно сделать?';

  @override
  String get newEcg => 'Новая ЭКГ';

  @override
  String get newEcgSub => 'Сфотографируйте ленту';

  @override
  String get fromGallery => 'Из галереи';

  @override
  String get howToPhoto => 'Как фотографировать';

  @override
  String get recentCases => 'Последние';

  @override
  String get seeAll => 'Показать все';

  @override
  String get noCases => 'Случаев пока нет. Здесь появятся ваши ЭКГ.';

  @override
  String get online => 'В сети';

  @override
  String get offline => 'Без сети';

  @override
  String get offlineHint =>
      'Приложение работает и без интернета. Случаи отправятся, когда появится связь.';

  @override
  String get historyHint => 'Случаи хранятся на этом телефоне (последние 50).';

  @override
  String get syncSynced => 'Отправлено';

  @override
  String get syncPending => 'Ждёт интернета';

  @override
  String get syncLocal => 'Только на телефоне';

  @override
  String get sexF => 'Женщина';

  @override
  String get sexM => 'Мужчина';

  @override
  String get guideTitle => 'Перед фотографией';

  @override
  String get tipFlat => 'Лента ровная';

  @override
  String get tipFlatSub => 'Расправьте сгибы. Положите на стол.';

  @override
  String get tipLight => 'Хороший свет, без тени';

  @override
  String get tipLightSub => 'Лучше дневной свет. Без бликов от вспышки.';

  @override
  String get tipWhole => 'Вся лента в кадре';

  @override
  String get tipWholeSub => 'Вместе с краями и напечатанным текстом.';

  @override
  String get tipAbove => 'Телефон прямо над лентой';

  @override
  String get tipAboveSub => 'Держите телефон параллельно бумаге.';

  @override
  String get openCamera => 'Открыть камеру';

  @override
  String get cameraHint => 'Поместите ленту в рамку';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get sampleSt => 'Демо: ST';

  @override
  String get sampleAf => 'Демо: ФП';

  @override
  String get sampleSinus => 'Демо: синусовый';

  @override
  String get samplePoor => 'Демо: плохое фото';

  @override
  String get checkTitle => 'Проверьте фото';

  @override
  String get overlayLegend =>
      'Синяя линия — то, что приложение прочитало с бумаги';

  @override
  String get qualityGood => 'Качество фото хорошее.';

  @override
  String get qualityPoor => 'Фото плохо читается. Пожалуйста, переснимите.';

  @override
  String get detected => 'Определено';

  @override
  String get paperSpeed => 'Скорость ленты';

  @override
  String get gain => 'Усиление';

  @override
  String get leadsFound => 'Найдено отведений';

  @override
  String get layout => 'Формат';

  @override
  String get notFound => 'не найдено';

  @override
  String get correctValues => 'Значения неверны? Исправить';

  @override
  String get retake => 'Переснять';

  @override
  String get usePhoto => 'Продолжить';

  @override
  String get patientTitle => 'О пациенте';

  @override
  String get patientSub => 'Необязательно, но так советы будут точнее.';

  @override
  String get symptomsQ => 'Симптомы сейчас';

  @override
  String get symChestPain => 'Боль в груди';

  @override
  String get symBreathless => 'Одышка';

  @override
  String get symFainting => 'Обморок';

  @override
  String get symPalpitations => 'Сердцебиение';

  @override
  String get symWeakness => 'Слабость, головокружение';

  @override
  String get sex => 'Пол';

  @override
  String get age => 'Возраст';

  @override
  String get ageUnder40 => 'До 40';

  @override
  String get age40to64 => '40–64';

  @override
  String get age65plus => '65+';

  @override
  String get noNameNote =>
      'Имя и номер не нужны. Не фотографируйте имя пациента.';

  @override
  String get analyse => 'Анализировать';

  @override
  String get analysing => 'Анализ…';

  @override
  String get onDevice => 'На телефоне, интернет не нужен';

  @override
  String get procPhoto => 'Выравнивание фото';

  @override
  String get procTrace => 'Чтение кривой';

  @override
  String get procRhythm => 'Проверка ритма и признаков';

  @override
  String get procReport => 'Подготовка рекомендаций';

  @override
  String get result => 'Результат';

  @override
  String get done => 'Готово';

  @override
  String get savePdf => 'Сохранить PDF';

  @override
  String get pdfReady => 'PDF готов: можно отправить или сохранить.';

  @override
  String get pdfFailed => 'Не удалось создать PDF. Попробуйте ещё раз.';

  @override
  String get usePhoneCamera => 'Камера телефона';

  @override
  String get photoDemoNote =>
      'Демо: это фото пока не анализируется. Результат строится по выбранному ниже образцу.';

  @override
  String get demoSample => 'Демо-образец';

  @override
  String get urgencyRed => 'Срочно — действуйте сейчас';

  @override
  String get urgencyAmber => 'Нужна консультация врача';

  @override
  String get urgencyGreen => 'Без неотложных признаков';

  @override
  String get urgencyGrey => 'Нет результата';

  @override
  String get whatToDo => 'Что делать';

  @override
  String get findings => 'Что нашло приложение';

  @override
  String get suspected => 'подозрение';

  @override
  String get ecgTrace => 'ЭКГ (отведение II)';

  @override
  String get highlightLegend => 'Выделено: где найден признак';

  @override
  String get technical => 'Проверьте значения';

  @override
  String get imageQuality => 'Качество фото';

  @override
  String get caseId => 'Случай';

  @override
  String get sendToExpert => 'Отправить эксперту';

  @override
  String get sendShort => 'Отправить';

  @override
  String get send => 'Отправить';

  @override
  String get cancel => 'Отмена';

  @override
  String get forwardConsent =>
      'Фото ЭКГ, результат, возраст и пол будут отправлены в экспертный центр. Имя не отправляется. Пациент согласен.';

  @override
  String get forwardSent => 'Отправлено в экспертный центр.';

  @override
  String get forwardQueued =>
      'Нет интернета. Отправится автоматически при появлении связи.';

  @override
  String get disclaimerResult =>
      'Не диагноз. Зелёный результат не исключает болезнь. Если пациенту плохо — действуйте по протоколу и вызовите помощь.';

  @override
  String get noticeRhythmOnly =>
      'Оценён только ритм. Признаки инфаркта и блокады ножек пучка Гиса по этой ленте оценить нельзя.';

  @override
  String get noticeAf =>
      'Подозрение на фибрилляцию предсердий. Для подтверждения нужна ЭКГ длительностью более 30 с и врач.';

  @override
  String get noticeAcs =>
      'Одна ЭКГ не исключает острый коронарный синдром; нужны тропонин и клиническая оценка.';

  @override
  String get pendingReview => 'ожидает проверки кардиолога';

  @override
  String get language => 'Язык';

  @override
  String get kyDraftNote =>
      'Перевод на кыргызский — черновик. Медицинский специалист его ещё не проверил. Если сомневаетесь, сверьтесь с русским текстом.';

  @override
  String get account => 'Учётная запись';

  @override
  String get dataAndPrivacy => 'Данные и конфиденциальность';

  @override
  String get about => 'О приложении';

  @override
  String get showIntro => 'Показать вступление снова';

  @override
  String get whatWeStore => 'Что хранится';

  @override
  String get dataText =>
      'На телефоне: фото ЭКГ, результат, возрастная группа, пол и симптомы последних 50 случаев. Без имён и номеров документов. Случай покидает телефон только когда вы отправляете его эксперту. На сервере фото удаляются через 30 дней.';

  @override
  String get limitations => 'Ограничения';

  @override
  String get limitationsText =>
      'Ещё не проверено на кыргызских ЭКГ. Может пропустить неотложное состояние. Качество фото влияет на результат. По короткой ленте оценивается только ритм.';

  @override
  String bpm(int n) {
    return '$n/мин';
  }

  @override
  String ageYears(int n) {
    return '$n лет';
  }

  @override
  String pendingSync(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n случаев ждут интернета',
      few: '$n случая ждут интернета',
      one: '$n случай ждёт интернета',
    );
    return '$_temp0';
  }

  @override
  String stepOf(int a, int b) {
    return 'Шаг $a из $b';
  }

  @override
  String symptomsOverride(String list) {
    return 'Есть симптомы: $list. Пациенту может быть нужна срочная помощь независимо от ЭКГ — действуйте по протоколу.';
  }

  @override
  String versions(String app, String model, String date) {
    return 'Приложение $app · Модель $model · Тексты протоколов $date';
  }
}
