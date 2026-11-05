import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ky'),
    Locale('ru'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'ECG reading help'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of a paper ECG. The app shows how urgent it may be and what to do next. It works without internet.'**
  String get welcomeBody;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get chooseLanguage;

  /// No description provided for @researchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research prototype'**
  String get researchTitle;

  /// No description provided for @disclaimerFirstLaunch.
  ///
  /// In en, this message translates to:
  /// **'Research prototype. Decision support for a trained health worker. Not a diagnosis. Does not replace clinical judgement or a cardiologist.'**
  String get disclaimerFirstLaunch;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get iUnderstand;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'What do you need?'**
  String get homeGreeting;

  /// No description provided for @newEcg.
  ///
  /// In en, this message translates to:
  /// **'New ECG'**
  String get newEcg;

  /// No description provided for @newEcgSub.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the strip'**
  String get newEcgSub;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get fromGallery;

  /// No description provided for @howToPhoto.
  ///
  /// In en, this message translates to:
  /// **'How to take a photo'**
  String get howToPhoto;

  /// No description provided for @recentCases.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentCases;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noCases.
  ///
  /// In en, this message translates to:
  /// **'No cases yet. Your ECGs will appear here.'**
  String get noCases;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @offlineHint.
  ///
  /// In en, this message translates to:
  /// **'The app works the same without internet. Cases are sent when the phone is online.'**
  String get offlineHint;

  /// No description provided for @historyHint.
  ///
  /// In en, this message translates to:
  /// **'Cases are kept on this phone (last 50).'**
  String get historyHint;

  /// No description provided for @syncSynced.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get syncSynced;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for internet'**
  String get syncPending;

  /// No description provided for @syncLocal.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone'**
  String get syncLocal;

  /// No description provided for @sexF.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get sexF;

  /// No description provided for @sexM.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get sexM;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Before the photo'**
  String get guideTitle;

  /// No description provided for @tipFlat.
  ///
  /// In en, this message translates to:
  /// **'Paper flat'**
  String get tipFlat;

  /// No description provided for @tipFlatSub.
  ///
  /// In en, this message translates to:
  /// **'Smooth out folds. Put it on a table.'**
  String get tipFlatSub;

  /// No description provided for @tipLight.
  ///
  /// In en, this message translates to:
  /// **'Good light, no shadow'**
  String get tipLight;

  /// No description provided for @tipLightSub.
  ///
  /// In en, this message translates to:
  /// **'Daylight is best. Avoid flash glare.'**
  String get tipLightSub;

  /// No description provided for @tipWhole.
  ///
  /// In en, this message translates to:
  /// **'Whole strip in the frame'**
  String get tipWhole;

  /// No description provided for @tipWholeSub.
  ///
  /// In en, this message translates to:
  /// **'Include the edges and the printed text.'**
  String get tipWholeSub;

  /// No description provided for @tipAbove.
  ///
  /// In en, this message translates to:
  /// **'Phone straight above'**
  String get tipAbove;

  /// No description provided for @tipAboveSub.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone parallel to the paper.'**
  String get tipAboveSub;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get openCamera;

  /// No description provided for @cameraHint.
  ///
  /// In en, this message translates to:
  /// **'Fit the strip inside the frame'**
  String get cameraHint;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @sampleSt.
  ///
  /// In en, this message translates to:
  /// **'Demo: ST'**
  String get sampleSt;

  /// No description provided for @sampleAf.
  ///
  /// In en, this message translates to:
  /// **'Demo: AF'**
  String get sampleAf;

  /// No description provided for @sampleSinus.
  ///
  /// In en, this message translates to:
  /// **'Demo: sinus'**
  String get sampleSinus;

  /// No description provided for @samplePoor.
  ///
  /// In en, this message translates to:
  /// **'Demo: poor photo'**
  String get samplePoor;

  /// No description provided for @checkTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the photo'**
  String get checkTitle;

  /// No description provided for @overlayLegend.
  ///
  /// In en, this message translates to:
  /// **'Blue line: what the app read from the paper'**
  String get overlayLegend;

  /// No description provided for @qualityGood.
  ///
  /// In en, this message translates to:
  /// **'Photo quality is good.'**
  String get qualityGood;

  /// No description provided for @qualityPoor.
  ///
  /// In en, this message translates to:
  /// **'The photo is hard to read. Please retake it.'**
  String get qualityPoor;

  /// No description provided for @detected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get detected;

  /// No description provided for @paperSpeed.
  ///
  /// In en, this message translates to:
  /// **'Paper speed'**
  String get paperSpeed;

  /// No description provided for @gain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get gain;

  /// No description provided for @leadsFound.
  ///
  /// In en, this message translates to:
  /// **'Leads found'**
  String get leadsFound;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'not found'**
  String get notFound;

  /// No description provided for @correctValues.
  ///
  /// In en, this message translates to:
  /// **'Values wrong? Correct them'**
  String get correctValues;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get usePhoto;

  /// No description provided for @patientTitle.
  ///
  /// In en, this message translates to:
  /// **'About the patient'**
  String get patientTitle;

  /// No description provided for @patientSub.
  ///
  /// In en, this message translates to:
  /// **'Optional, but it makes the advice safer.'**
  String get patientSub;

  /// No description provided for @symptomsQ.
  ///
  /// In en, this message translates to:
  /// **'Symptoms now'**
  String get symptomsQ;

  /// No description provided for @symChestPain.
  ///
  /// In en, this message translates to:
  /// **'Chest pain'**
  String get symChestPain;

  /// No description provided for @symBreathless.
  ///
  /// In en, this message translates to:
  /// **'Short of breath'**
  String get symBreathless;

  /// No description provided for @symFainting.
  ///
  /// In en, this message translates to:
  /// **'Fainting'**
  String get symFainting;

  /// No description provided for @symPalpitations.
  ///
  /// In en, this message translates to:
  /// **'Palpitations'**
  String get symPalpitations;

  /// No description provided for @symWeakness.
  ///
  /// In en, this message translates to:
  /// **'Weakness, dizziness'**
  String get symWeakness;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @ageUnder40.
  ///
  /// In en, this message translates to:
  /// **'Under 40'**
  String get ageUnder40;

  /// No description provided for @age40to64.
  ///
  /// In en, this message translates to:
  /// **'40–64'**
  String get age40to64;

  /// No description provided for @age65plus.
  ///
  /// In en, this message translates to:
  /// **'65+'**
  String get age65plus;

  /// No description provided for @noNameNote.
  ///
  /// In en, this message translates to:
  /// **'No name or ID is needed. Do not photograph the patient\'s name.'**
  String get noNameNote;

  /// No description provided for @analyse.
  ///
  /// In en, this message translates to:
  /// **'Analyse'**
  String get analyse;

  /// No description provided for @analysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing…'**
  String get analysing;

  /// No description provided for @onDevice.
  ///
  /// In en, this message translates to:
  /// **'On this phone, no internet needed'**
  String get onDevice;

  /// No description provided for @procPhoto.
  ///
  /// In en, this message translates to:
  /// **'Straightening the photo'**
  String get procPhoto;

  /// No description provided for @procTrace.
  ///
  /// In en, this message translates to:
  /// **'Reading the trace'**
  String get procTrace;

  /// No description provided for @procRhythm.
  ///
  /// In en, this message translates to:
  /// **'Checking rhythm and patterns'**
  String get procRhythm;

  /// No description provided for @procReport.
  ///
  /// In en, this message translates to:
  /// **'Preparing advice'**
  String get procReport;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @savePdf.
  ///
  /// In en, this message translates to:
  /// **'Save PDF'**
  String get savePdf;

  /// No description provided for @pdfReady.
  ///
  /// In en, this message translates to:
  /// **'PDF ready to share or save.'**
  String get pdfReady;

  /// No description provided for @pdfFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the PDF. Try again.'**
  String get pdfFailed;

  /// No description provided for @usePhoneCamera.
  ///
  /// In en, this message translates to:
  /// **'Use phone camera'**
  String get usePhoneCamera;

  /// No description provided for @photoDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo: this photo is not analysed yet. The result uses the sample strip chosen below.'**
  String get photoDemoNote;

  /// No description provided for @demoSample.
  ///
  /// In en, this message translates to:
  /// **'Demo sample'**
  String get demoSample;

  /// No description provided for @urgencyRed.
  ///
  /// In en, this message translates to:
  /// **'Urgent — act now'**
  String get urgencyRed;

  /// No description provided for @urgencyAmber.
  ///
  /// In en, this message translates to:
  /// **'Needs a doctor\'s review'**
  String get urgencyAmber;

  /// No description provided for @urgencyGreen.
  ///
  /// In en, this message translates to:
  /// **'No urgent pattern'**
  String get urgencyGreen;

  /// No description provided for @urgencyGrey.
  ///
  /// In en, this message translates to:
  /// **'No result'**
  String get urgencyGrey;

  /// No description provided for @whatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get whatToDo;

  /// No description provided for @findings.
  ///
  /// In en, this message translates to:
  /// **'What the app found'**
  String get findings;

  /// No description provided for @suspected.
  ///
  /// In en, this message translates to:
  /// **'suspected'**
  String get suspected;

  /// No description provided for @ecgTrace.
  ///
  /// In en, this message translates to:
  /// **'ECG (lead II)'**
  String get ecgTrace;

  /// No description provided for @highlightLegend.
  ///
  /// In en, this message translates to:
  /// **'Highlighted: where the pattern was found'**
  String get highlightLegend;

  /// No description provided for @technical.
  ///
  /// In en, this message translates to:
  /// **'Check these values'**
  String get technical;

  /// No description provided for @imageQuality.
  ///
  /// In en, this message translates to:
  /// **'Image quality'**
  String get imageQuality;

  /// No description provided for @caseId.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get caseId;

  /// No description provided for @sendToExpert.
  ///
  /// In en, this message translates to:
  /// **'Send to an expert'**
  String get sendToExpert;

  /// No description provided for @sendShort.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendShort;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @forwardConsent.
  ///
  /// In en, this message translates to:
  /// **'The ECG photo, the result, age and sex will be sent to the expert centre. No name is sent. The patient has agreed.'**
  String get forwardConsent;

  /// No description provided for @forwardSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to the expert centre.'**
  String get forwardSent;

  /// No description provided for @forwardQueued.
  ///
  /// In en, this message translates to:
  /// **'No internet. It will be sent automatically when online.'**
  String get forwardQueued;

  /// No description provided for @disclaimerResult.
  ///
  /// In en, this message translates to:
  /// **'Not a diagnosis. A green result does not exclude disease. If the patient is unwell, act per protocol and call for help.'**
  String get disclaimerResult;

  /// No description provided for @noticeRhythmOnly.
  ///
  /// In en, this message translates to:
  /// **'Only rhythm was assessed. Heart attack signs and bundle branch blocks cannot be assessed from this strip.'**
  String get noticeRhythmOnly;

  /// No description provided for @noticeAf.
  ///
  /// In en, this message translates to:
  /// **'Suspected atrial fibrillation. Confirmation needs an ECG of more than 30 s and a clinician.'**
  String get noticeAf;

  /// No description provided for @noticeAcs.
  ///
  /// In en, this message translates to:
  /// **'An ECG alone cannot exclude acute coronary syndrome; troponin and clinical assessment are needed.'**
  String get noticeAcs;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'pending cardiologist review'**
  String get pendingReview;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @kyDraftNote.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyz translation is not ready yet; Russian text is shown.'**
  String get kyDraftNote;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data and privacy'**
  String get dataAndPrivacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get about;

  /// No description provided for @showIntro.
  ///
  /// In en, this message translates to:
  /// **'Show the introduction again'**
  String get showIntro;

  /// No description provided for @whatWeStore.
  ///
  /// In en, this message translates to:
  /// **'What is stored'**
  String get whatWeStore;

  /// No description provided for @dataText.
  ///
  /// In en, this message translates to:
  /// **'On this phone: the ECG photo, the result, age group, sex and symptoms for the last 50 cases. No names or ID numbers. A case leaves the phone only when you send it to an expert. On the server, photos are deleted after 30 days.'**
  String get dataText;

  /// No description provided for @limitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get limitations;

  /// No description provided for @limitationsText.
  ///
  /// In en, this message translates to:
  /// **'Not yet tested on Kyrgyz ECG paper. May miss emergencies. Photo quality affects the result. Short strips allow only rhythm assessment.'**
  String get limitationsText;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'{n}/min'**
  String bpm(int n);

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{n} y'**
  String ageYears(int n);

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 case is waiting for internet} other{{n} cases are waiting for internet}}'**
  String pendingSync(int n);

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {a} of {b}'**
  String stepOf(int a, int b);

  /// No description provided for @symptomsOverride.
  ///
  /// In en, this message translates to:
  /// **'Symptoms reported: {list}. The patient may need urgent care whatever the ECG shows — act per protocol.'**
  String symptomsOverride(String list);

  /// No description provided for @versions.
  ///
  /// In en, this message translates to:
  /// **'App {app} · Model {model} · Protocol texts {date}'**
  String versions(String app, String model, String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ky', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ky':
      return AppLocalizationsKy();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
