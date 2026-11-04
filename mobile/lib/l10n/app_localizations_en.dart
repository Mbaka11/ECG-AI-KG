// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get welcomeTitle => 'ECG reading help';

  @override
  String get welcomeBody =>
      'Take a photo of a paper ECG. The app shows how urgent it may be and what to do next. It works without internet.';

  @override
  String get chooseLanguage => 'Language';

  @override
  String get researchTitle => 'Research prototype';

  @override
  String get disclaimerFirstLaunch =>
      'Research prototype. Decision support for a trained health worker. Not a diagnosis. Does not replace clinical judgement or a cardiologist.';

  @override
  String get iUnderstand => 'I understand';

  @override
  String get start => 'Start';

  @override
  String get homeGreeting => 'What do you need?';

  @override
  String get newEcg => 'New ECG';

  @override
  String get newEcgSub => 'Take a photo of the strip';

  @override
  String get fromGallery => 'From gallery';

  @override
  String get howToPhoto => 'How to take a photo';

  @override
  String get recentCases => 'Recent';

  @override
  String get seeAll => 'See all';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get offlineHint =>
      'The app works the same without internet. Cases are sent when the phone is online.';

  @override
  String get historyHint => 'Cases are kept on this phone (last 50).';

  @override
  String get syncSynced => 'Sent';

  @override
  String get syncPending => 'Waiting for internet';

  @override
  String get syncLocal => 'Only on this phone';

  @override
  String get sexF => 'Woman';

  @override
  String get sexM => 'Man';

  @override
  String get guideTitle => 'Before the photo';

  @override
  String get tipFlat => 'Paper flat';

  @override
  String get tipFlatSub => 'Smooth out folds. Put it on a table.';

  @override
  String get tipLight => 'Good light, no shadow';

  @override
  String get tipLightSub => 'Daylight is best. Avoid flash glare.';

  @override
  String get tipWhole => 'Whole strip in the frame';

  @override
  String get tipWholeSub => 'Include the edges and the printed text.';

  @override
  String get tipAbove => 'Phone straight above';

  @override
  String get tipAboveSub => 'Hold the phone parallel to the paper.';

  @override
  String get openCamera => 'Open camera';

  @override
  String get cameraHint => 'Fit the strip inside the frame';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get sampleSt => 'Demo: ST';

  @override
  String get sampleAf => 'Demo: AF';

  @override
  String get sampleSinus => 'Demo: sinus';

  @override
  String get samplePoor => 'Demo: poor photo';

  @override
  String get checkTitle => 'Check the photo';

  @override
  String get overlayLegend => 'Blue line: what the app read from the paper';

  @override
  String get qualityGood => 'Photo quality is good.';

  @override
  String get qualityPoor => 'The photo is hard to read. Please retake it.';

  @override
  String get detected => 'Detected';

  @override
  String get paperSpeed => 'Paper speed';

  @override
  String get gain => 'Gain';

  @override
  String get leadsFound => 'Leads found';

  @override
  String get layout => 'Layout';

  @override
  String get notFound => 'not found';

  @override
  String get correctValues => 'Values wrong? Correct them';

  @override
  String get retake => 'Retake';

  @override
  String get usePhoto => 'Continue';

  @override
  String get patientTitle => 'About the patient';

  @override
  String get patientSub => 'Optional, but it makes the advice safer.';

  @override
  String get symptomsQ => 'Symptoms now';

  @override
  String get symChestPain => 'Chest pain';

  @override
  String get symBreathless => 'Short of breath';

  @override
  String get symFainting => 'Fainting';

  @override
  String get symPalpitations => 'Palpitations';

  @override
  String get symWeakness => 'Weakness, dizziness';

  @override
  String get sex => 'Sex';

  @override
  String get age => 'Age';

  @override
  String get ageUnder40 => 'Under 40';

  @override
  String get age40to64 => '40–64';

  @override
  String get age65plus => '65+';

  @override
  String get noNameNote =>
      'No name or ID is needed. Do not photograph the patient\'s name.';

  @override
  String get analyse => 'Analyse';

  @override
  String get analysing => 'Analysing…';

  @override
  String get onDevice => 'On this phone, no internet needed';

  @override
  String get procPhoto => 'Straightening the photo';

  @override
  String get procTrace => 'Reading the trace';

  @override
  String get procRhythm => 'Checking rhythm and patterns';

  @override
  String get procReport => 'Preparing advice';

  @override
  String get result => 'Result';

  @override
  String get done => 'Done';

  @override
  String get savePdf => 'Save PDF';

  @override
  String get pdfReady => 'PDF ready to share or save.';

  @override
  String get pdfFailed => 'Could not create the PDF. Try again.';

  @override
  String get usePhoneCamera => 'Use phone camera';

  @override
  String get photoDemoNote =>
      'Demo: this photo is not analysed yet. The result uses the sample strip chosen below.';

  @override
  String get demoSample => 'Demo sample';

  @override
  String get urgencyRed => 'Urgent — act now';

  @override
  String get urgencyAmber => 'Needs a doctor\'s review';

  @override
  String get urgencyGreen => 'No urgent pattern';

  @override
  String get urgencyGrey => 'No result';

  @override
  String get whatToDo => 'What to do';

  @override
  String get findings => 'What the app found';

  @override
  String get suspected => 'suspected';

  @override
  String get ecgTrace => 'ECG (lead II)';

  @override
  String get highlightLegend => 'Highlighted: where the pattern was found';

  @override
  String get technical => 'Check these values';

  @override
  String get imageQuality => 'Image quality';

  @override
  String get caseId => 'Case';

  @override
  String get sendToExpert => 'Send to an expert';

  @override
  String get sendShort => 'Send';

  @override
  String get send => 'Send';

  @override
  String get cancel => 'Cancel';

  @override
  String get forwardConsent =>
      'The ECG photo, the result, age and sex will be sent to the expert centre. No name is sent. The patient has agreed.';

  @override
  String get forwardSent => 'Sent to the expert centre.';

  @override
  String get forwardQueued =>
      'No internet. It will be sent automatically when online.';

  @override
  String get disclaimerResult =>
      'Not a diagnosis. A green result does not exclude disease. If the patient is unwell, act per protocol and call for help.';

  @override
  String get noticeRhythmOnly =>
      'Only rhythm was assessed. Heart attack signs and bundle branch blocks cannot be assessed from this strip.';

  @override
  String get noticeAf =>
      'Suspected atrial fibrillation. Confirmation needs an ECG of more than 30 s and a clinician.';

  @override
  String get noticeAcs =>
      'An ECG alone cannot exclude acute coronary syndrome; troponin and clinical assessment are needed.';

  @override
  String get pendingReview => 'pending cardiologist review';

  @override
  String get language => 'Language';

  @override
  String get kyDraftNote =>
      'Kyrgyz translation is not ready yet; Russian text is shown.';

  @override
  String get account => 'Account';

  @override
  String get dataAndPrivacy => 'Data and privacy';

  @override
  String get about => 'About the app';

  @override
  String get showIntro => 'Show the introduction again';

  @override
  String get whatWeStore => 'What is stored';

  @override
  String get dataText =>
      'On this phone: the ECG photo, the result, age group, sex and symptoms for the last 50 cases. No names or ID numbers. A case leaves the phone only when you send it to an expert. On the server, photos are deleted after 30 days.';

  @override
  String get limitations => 'Limitations';

  @override
  String get limitationsText =>
      'Not yet tested on Kyrgyz ECG paper. May miss emergencies. Photo quality affects the result. Short strips allow only rhythm assessment.';

  @override
  String bpm(int n) {
    return '$n/min';
  }

  @override
  String ageYears(int n) {
    return '$n y';
  }

  @override
  String pendingSync(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cases are waiting for internet',
      one: '1 case is waiting for internet',
    );
    return '$_temp0';
  }

  @override
  String stepOf(int a, int b) {
    return 'Step $a of $b';
  }

  @override
  String symptomsOverride(String list) {
    return 'Symptoms reported: $list. The patient may need urgent care whatever the ECG shows — act per protocol.';
  }

  @override
  String versions(String app, String model, String date) {
    return 'App $app · Model $model · Protocol texts $date';
  }
}
