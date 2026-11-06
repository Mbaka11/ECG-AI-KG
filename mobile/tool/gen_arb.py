"""Generate app_en.arb, app_ru.arb, app_ky.arb from one table (keeps key parity).

Each entry is (English, Russian, Kyrgyz). The Kyrgyz column is a machine draft. It must be
reviewed by a native Kyrgyz speaker with a medical background before any field use; see
docs/translation/KY_REVIEW.md for the glossary and the review procedure.

Usage: python tool/gen_arb.py lib/l10n
"""
import json, sys, pathlib

out = pathlib.Path(sys.argv[1])

S = {
 "navHome": ("Home", "Главная", "Башкы бет"),
 "history": ("History", "История", "Тарых"),
 "settings": ("Settings", "Настройки", "Жөндөөлөр"),
 "welcomeTitle": ("ECG reading help", "Помощь в чтении ЭКГ", "ЭКГны окууга жардам"),
 "welcomeBody": ("Take a photo of a paper ECG. The app shows how urgent it may be and what to do next. It works without internet.",
                 "Сфотографируйте бумажную ЭКГ. Приложение покажет, насколько это может быть срочно, и что делать дальше. Работает без интернета.",
                 "Кагаз ЭКГны сүрөткө тартыңыз. Колдонмо абал канчалык шашылыш болушу мүмкүн экенин жана мындан ары эмне кылуу керегин көрсөтөт. Интернетсиз иштейт."),
 "chooseLanguage": ("Language", "Язык", "Тил"),
 "researchTitle": ("Research prototype", "Исследовательский прототип", "Изилдөө прототиби"),
 "disclaimerFirstLaunch": ("Research prototype. Decision support for a trained health worker. Not a diagnosis. Does not replace clinical judgement or a cardiologist.",
                           "Исследовательский прототип. Помощь в принятии решений для обученного медработника. Не является диагнозом. Не заменяет клиническое решение или кардиолога.",
                           "Изилдөө прототиби. Даярдыгы бар медицина кызматкерине чечим кабыл алууга жардам берет. Диагноз эмес. Клиникалык чечимди же кардиологду алмаштырбайт."),
 "iUnderstand": ("I understand", "Я понимаю", "Түшүндүм"),
 "start": ("Start", "Начать", "Баштоо"),
 "homeGreeting": ("What do you need?", "Что нужно сделать?", "Эмне кылуу керек?"),
 "newEcg": ("New ECG", "Новая ЭКГ", "Жаңы ЭКГ"),
 "newEcgSub": ("Take a photo of the strip", "Сфотографируйте ленту", "Лентаны сүрөткө тартыңыз"),
 "fromGallery": ("From gallery", "Из галереи", "Галереядан"),
 "howToPhoto": ("How to take a photo", "Как фотографировать", "Кантип сүрөткө тартуу керек"),
 "recentCases": ("Recent", "Последние", "Акыркылар"),
 "seeAll": ("See all", "Показать все", "Баарын көрүү"),
 "noCases": ("No cases yet. Your ECGs will appear here.", "Случаев пока нет. Здесь появятся ваши ЭКГ.",
             "Азырынча учурлар жок. Сиздин ЭКГлар ушул жерде пайда болот."),
 "online": ("Online", "В сети", "Интернет бар"),
 "offline": ("Offline", "Без сети", "Интернет жок"),
 "offlineHint": ("The app works the same without internet. Cases are sent when the phone is online.",
                 "Приложение работает и без интернета. Случаи отправятся, когда появится связь.",
                 "Колдонмо интернетсиз да ошондой эле иштейт. Байланыш пайда болгондо учурлар жөнөтүлөт."),
 "historyHint": ("Cases are kept on this phone (last 50).", "Случаи хранятся на этом телефоне (последние 50).",
                 "Учурлар ушул телефондо сакталат (акыркы 50)."),
 "syncSynced": ("Sent", "Отправлено", "Жөнөтүлдү"),
 "syncPending": ("Waiting for internet", "Ждёт интернета", "Интернетти күтүүдө"),
 "syncLocal": ("Only on this phone", "Только на телефоне", "Ушул телефондо гана"),
 "sexF": ("Woman", "Женщина", "Аял"),
 "sexM": ("Man", "Мужчина", "Эркек"),
 "guideTitle": ("Before the photo", "Перед фотографией", "Сүрөткө тартуудан мурун"),
 "tipFlat": ("Paper flat", "Лента ровная", "Лента түз жатсын"),
 "tipFlatSub": ("Smooth out folds. Put it on a table.", "Расправьте сгибы. Положите на стол.",
                "Бүктөлгөн жерлерин жазыңыз. Үстөлгө коюңуз."),
 "tipLight": ("Good light, no shadow", "Хороший свет, без тени", "Жарык жакшы, көлөкө жок"),
 "tipLightSub": ("Daylight is best. Avoid flash glare.", "Лучше дневной свет. Без бликов от вспышки.",
                 "Күндүзгү жарык эң жакшы. Вспышканын жалтырагы болбосун."),
 "tipWhole": ("Whole strip in the frame", "Вся лента в кадре", "Лента толугу менен кадрда"),
 "tipWholeSub": ("Include the edges and the printed text.", "Вместе с краями и напечатанным текстом.",
                 "Четтери жана басылган тексти менен кошо."),
 "tipAbove": ("Phone straight above", "Телефон прямо над лентой", "Телефон лентанын так үстүндө"),
 "tipAboveSub": ("Hold the phone parallel to the paper.", "Держите телефон параллельно бумаге.",
                 "Телефонду кагазга параллель кармаңыз."),
 "openCamera": ("Open camera", "Открыть камеру", "Камераны ачуу"),
 "cameraHint": ("Fit the strip inside the frame", "Поместите ленту в рамку", "Лентаны алкактын ичине жайгаштырыңыз"),
 "takePhoto": ("Take photo", "Сделать фото", "Сүрөткө тартуу"),
 "sampleSt": ("Demo: ST", "Демо: ST", "Демо: ST"),
 "sampleAf": ("Demo: AF", "Демо: ФП", "Демо: ФП"),
 "sampleSinus": ("Demo: sinus", "Демо: синусовый", "Демо: синус"),
 "samplePoor": ("Demo: poor photo", "Демо: плохое фото", "Демо: начар сүрөт"),
 "checkTitle": ("Check the photo", "Проверьте фото", "Сүрөттү текшериңиз"),
 "overlayLegend": ("Blue line: what the app read from the paper", "Синяя линия — то, что приложение прочитало с бумаги",
                   "Көк сызык — колдонмо кагаздан окуган сызык"),
 "qualityGood": ("Photo quality is good.", "Качество фото хорошее.", "Сүрөттүн сапаты жакшы."),
 "qualityPoor": ("The photo is hard to read. Please retake it.", "Фото плохо читается. Пожалуйста, переснимите.",
                 "Сүрөт начар окулат. Сураныч, кайра тартыңыз."),
 "detected": ("Detected", "Определено", "Аныкталды"),
 "paperSpeed": ("Paper speed", "Скорость ленты", "Лентанын ылдамдыгы"),
 "gain": ("Gain", "Усиление", "Күчөтүү"),
 "leadsFound": ("Leads found", "Найдено отведений", "Табылган отведениелер"),
 "layout": ("Layout", "Формат", "Формат"),
 "notFound": ("not found", "не найдено", "табылган жок"),
 "correctValues": ("Values wrong? Correct them", "Значения неверны? Исправить", "Маанилер туура эмеспи? Оңдоо"),
 "retake": ("Retake", "Переснять", "Кайра тартуу"),
 "usePhoto": ("Continue", "Продолжить", "Улантуу"),
 "patientTitle": ("About the patient", "О пациенте", "Бейтап жөнүндө"),
 "patientSub": ("Optional, but it makes the advice safer.", "Необязательно, но так советы будут точнее.",
                "Милдеттүү эмес, бирок кеңештер так болот."),
 "symptomsQ": ("Symptoms now", "Симптомы сейчас", "Азыркы симптомдор"),
 "symChestPain": ("Chest pain", "Боль в груди", "Көкүрөктөгү оору"),
 "symBreathless": ("Short of breath", "Одышка", "Ентигүү"),
 "symFainting": ("Fainting", "Обморок", "Эсинен тануу"),
 "symPalpitations": ("Palpitations", "Сердцебиение", "Жүрөктүн катуу кагышы"),
 "symWeakness": ("Weakness, dizziness", "Слабость, головокружение", "Алсыздык, баш айлануу"),
 "sex": ("Sex", "Пол", "Жынысы"),
 "age": ("Age", "Возраст", "Жашы"),
 "ageUnder40": ("Under 40", "До 40", "40ка чейин"),
 "age40to64": ("40–64", "40–64", "40–64"),
 "age65plus": ("65+", "65+", "65+"),
 "noNameNote": ("No name or ID is needed. Do not photograph the patient's name.",
                "Имя и номер не нужны. Не фотографируйте имя пациента.",
                "Аты-жөнү жана номери керек эмес. Бейтаптын атын сүрөткө тартпаңыз."),
 "analyse": ("Analyse", "Анализировать", "Талдоо"),
 "analysing": ("Analysing…", "Анализ…", "Талдоо…"),
 "onDevice": ("On this phone, no internet needed", "На телефоне, интернет не нужен", "Телефондо, интернет керек эмес"),
 "procPhoto": ("Straightening the photo", "Выравнивание фото", "Сүрөт түздөлүүдө"),
 "procTrace": ("Reading the trace", "Чтение кривой", "ЭКГ сызыгы окулууда"),
 "procRhythm": ("Checking rhythm and patterns", "Проверка ритма и признаков", "Ритм жана белгилер текшерилүүдө"),
 "procReport": ("Preparing advice", "Подготовка рекомендаций", "Кеңештер даярдалууда"),
 "result": ("Result", "Результат", "Жыйынтык"),
 "done": ("Done", "Готово", "Даяр"),
 "savePdf": ("Save PDF", "Сохранить PDF", "PDF сактоо"),
 "pdfReady": ("PDF ready to share or save.", "PDF готов: можно отправить или сохранить.",
              "PDF даяр: жөнөтсөңүз же сактасаңыз болот."),
 "pdfFailed": ("Could not create the PDF. Try again.", "Не удалось создать PDF. Попробуйте ещё раз.",
               "PDF түзүлгөн жок. Кайра аракет кылыңыз."),
 "usePhoneCamera": ("Use phone camera", "Камера телефона", "Телефондун камерасы"),
 "photoDemoNote": ("Demo: this photo is not analysed yet. The result uses the sample strip chosen below.",
                   "Демо: это фото пока не анализируется. Результат строится по выбранному ниже образцу.",
                   "Демо: бул сүрөт азырынча талданбайт. Жыйынтык төмөндө тандалган үлгү боюнча чыгат."),
 "demoSample": ("Demo sample", "Демо-образец", "Демо үлгү"),
 # Urgency words: one meaning each, never "normal" (see docs/translation/KY_REVIEW.md).
 "urgencyRed": ("Urgent — act now", "Срочно — действуйте сейчас", "Шашылыш — азыр аракет кылыңыз"),
 "urgencyAmber": ("Needs a doctor's review", "Нужна консультация врача", "Дарыгер кароосу керек"),
 "urgencyGreen": ("No urgent pattern", "Без неотложных признаков", "Шашылыш белги табылган жок"),
 "urgencyGrey": ("No result", "Нет результата", "Жыйынтык жок"),
 "whatToDo": ("What to do", "Что делать", "Эмне кылуу керек"),
 "findings": ("What the app found", "Что нашло приложение", "Колдонмо эмнени тапты"),
 "suspected": ("suspected", "подозрение", "шек бар"),
 "ecgTrace": ("ECG (lead II)", "ЭКГ (отведение II)", "ЭКГ (II отведение)"),
 "highlightLegend": ("Highlighted: where the pattern was found", "Выделено: где найден признак",
                     "Белгиленген жер: белги ушул жерден табылды"),
 "technical": ("Check these values", "Проверьте значения", "Бул маанилерди текшериңиз"),
 "imageQuality": ("Image quality", "Качество фото", "Сүрөттүн сапаты"),
 "caseId": ("Case", "Случай", "Учур"),
 "sendToExpert": ("Send to an expert", "Отправить эксперту", "Экспертке жөнөтүү"),
 "sendShort": ("Send", "Отправить", "Жөнөтүү"),
 "send": ("Send", "Отправить", "Жөнөтүү"),
 "cancel": ("Cancel", "Отмена", "Жокко чыгаруу"),
 "forwardConsent": ("The ECG photo, the result, age and sex will be sent to the expert centre. No name is sent. The patient has agreed.",
                    "Фото ЭКГ, результат, возраст и пол будут отправлены в экспертный центр. Имя не отправляется. Пациент согласен.",
                    "ЭКГ сүрөтү, жыйынтык, жашы жана жынысы эксперттик борборго жөнөтүлөт. Аты-жөнү жөнөтүлбөйт. Бейтап макул."),
 "forwardSent": ("Sent to the expert centre.", "Отправлено в экспертный центр.", "Эксперттик борборго жөнөтүлдү."),
 "forwardQueued": ("No internet. It will be sent automatically when online.", "Нет интернета. Отправится автоматически при появлении связи.",
                   "Интернет жок. Байланыш пайда болгондо өзү жөнөтүлөт."),
 "disclaimerResult": ("Not a diagnosis. A green result does not exclude disease. If the patient is unwell, act per protocol and call for help.",
                      "Не диагноз. Зелёный результат не исключает болезнь. Если пациенту плохо — действуйте по протоколу и вызовите помощь.",
                      "Диагноз эмес. Жашыл жыйынтык ооруну жокко чыгарбайт. Бейтаптын абалы начар болсо, протокол боюнча аракет кылып, жардам чакырыңыз."),
 "noticeRhythmOnly": ("Only rhythm was assessed. Heart attack signs and bundle branch blocks cannot be assessed from this strip.",
                      "Оценён только ритм. Признаки инфаркта и блокады ножек пучка Гиса по этой ленте оценить нельзя.",
                      "Ритм гана бааланды. Инфаркттын белгилерин жана Гис тутамынын буттарынын блокадасын бул лента боюнча баалоого болбойт."),
 "noticeAf": ("Suspected atrial fibrillation. Confirmation needs an ECG of more than 30 s and a clinician.",
              "Подозрение на фибрилляцию предсердий. Для подтверждения нужна ЭКГ длительностью более 30 с и врач.",
              "Фибрилляция предсердий (дүлөйчөлөрдүн фибрилляциясы) болушу мүмкүн. Тастыктоо үчүн 30 секунддан узун ЭКГ жана дарыгер керек."),
 "noticeAcs": ("An ECG alone cannot exclude acute coronary syndrome; troponin and clinical assessment are needed.",
               "Одна ЭКГ не исключает острый коронарный синдром; нужны тропонин и клиническая оценка.",
               "Бир гана ЭКГ курч коронардык синдромду жокко чыгара албайт; тропонин жана клиникалык баалоо керек."),
 "pendingReview": ("pending cardiologist review", "ожидает проверки кардиолога", "кардиолог али текшере элек"),
 "language": ("Language", "Язык", "Тил"),
 "kyDraftNote": ("Kyrgyz translation is a draft. A medical reviewer has not checked it yet. If in doubt, check the Russian text.",
                 "Перевод на кыргызский — черновик. Медицинский специалист его ещё не проверил. Если сомневаетесь, сверьтесь с русским текстом.",
                 "Кыргызча котормо — долбоор. Аны медицина адиси али текшере элек. Күмөн болсо, орусча текстти караңыз."),
 "account": ("Account", "Учётная запись", "Каттоо эсеби"),
 "dataAndPrivacy": ("Data and privacy", "Данные и конфиденциальность", "Маалымат жана купуялык"),
 "about": ("About the app", "О приложении", "Колдонмо жөнүндө"),
 "showIntro": ("Show the introduction again", "Показать вступление снова", "Киришүүнү кайра көрсөтүү"),
 "whatWeStore": ("What is stored", "Что хранится", "Эмне сакталат"),
 "dataText": ("On this phone: the ECG photo, the result, age group, sex and symptoms for the last 50 cases. No names or ID numbers. A case leaves the phone only when you send it to an expert. On the server, photos are deleted after 30 days.",
              "На телефоне: фото ЭКГ, результат, возрастная группа, пол и симптомы последних 50 случаев. Без имён и номеров документов. Случай покидает телефон только когда вы отправляете его эксперту. На сервере фото удаляются через 30 дней.",
              "Ушул телефондо: акыркы 50 учурдун ЭКГ сүрөтү, жыйынтыгы, жаш тобу, жынысы жана симптомдору. Аты-жөнү жана документ номерлери сакталбайт. Учур телефондон сиз экспертке жөнөткөндө гана чыгат. Серверде сүрөттөр 30 күндөн кийин өчүрүлөт."),
 "limitations": ("Limitations", "Ограничения", "Чектөөлөр"),
 "limitationsText": ("Not yet tested on Kyrgyz ECG paper. May miss emergencies. Photo quality affects the result. Short strips allow only rhythm assessment.",
                     "Ещё не проверено на кыргызских ЭКГ. Может пропустить неотложное состояние. Качество фото влияет на результат. По короткой ленте оценивается только ритм.",
                     "Кыргызстандагы ЭКГ кагаздарында али текшерилген эмес. Шашылыш абалды байкабай калышы мүмкүн. Сүрөттүн сапаты жыйынтыкка таасир этет. Кыска лента боюнча ритм гана бааланат."),
}

PARAM = {
 "bpm": (("{n}/min", "{n}/мин", "{n}/мүн"), {"n": {"type": "int"}}),
 "ageYears": (("{n} y", "{n} лет", "{n} жаш"), {"n": {"type": "int"}}),
 # Kyrgyz nouns do not change after a number, so both plural forms read the same.
 "pendingSync": (("{n, plural, =1{1 case is waiting for internet} other{{n} cases are waiting for internet}}",
                  "{n, plural, one{{n} случай ждёт интернета} few{{n} случая ждут интернета} other{{n} случаев ждут интернета}}",
                  "{n, plural, =1{1 учур интернетти күтүүдө} other{{n} учур интернетти күтүүдө}}"), {"n": {"type": "int"}}),
 "stepOf": (("Step {a} of {b}", "Шаг {a} из {b}", "{b} кадамдын {a}-кадамы"), {"a": {"type": "int"}, "b": {"type": "int"}}),
 "symptomsOverride": (("Symptoms reported: {list}. The patient may need urgent care whatever the ECG shows — act per protocol.",
                       "Есть симптомы: {list}. Пациенту может быть нужна срочная помощь независимо от ЭКГ — действуйте по протоколу.",
                       "Симптомдор бар: {list}. ЭКГ эмнени көрсөтсө да, бейтапка шашылыш жардам керек болушу мүмкүн — протокол боюнча аракет кылыңыз."),
                      {"list": {"type": "String"}}),
 "versions": (("App {app} · Model {model} · Protocol texts {date}", "Приложение {app} · Модель {model} · Тексты протоколов {date}",
               "Колдонмо {app} · Модель {model} · Протокол тексттери {date}"),
              {"app": {"type": "String"}, "model": {"type": "String"}, "date": {"type": "String"}}),
}

KY_STATUS = ("DRAFT: machine-drafted Kyrgyz. Must be reviewed by a native Kyrgyz speaker with a medical "
             "background before any field use. See docs/translation/KY_REVIEW.md.")

def build(idx, locale, note=None):
    d = {"@@locale": locale}
    if note:
        d["@@x-status"] = note
    for k, v in S.items():
        d[k] = v[idx]
    for k, (vals, ph) in PARAM.items():
        d[k] = vals[idx]
        if idx == 0:
            d["@" + k] = {"placeholders": ph}
    return d

for k, v in S.items():
    assert len(v) == 3 and all(v), k
for k, (vals, _) in PARAM.items():
    assert len(vals) == 3 and all(vals), k

out.mkdir(parents=True, exist_ok=True)
for name, d in [("app_en.arb", build(0, "en")), ("app_ru.arb", build(1, "ru")),
                ("app_ky.arb", build(2, "ky", KY_STATUS))]:
    (out / name).write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("ok", len(S) + len(PARAM), "keys")
