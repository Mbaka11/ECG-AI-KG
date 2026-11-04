import '../widgets/ecg_trace.dart';

/// Text in several languages. Clinical content is data, not UI strings: it will
/// come from a versioned, reviewed content table (hazards H-07, H-08).
/// Kyrgyz falls back to Russian until a native translator reviews it.
class LocalText {
  const LocalText(this.en, this.ru, [this.ky]);
  final String en;
  final String ru;
  final String? ky;

  String of(String lang) => switch (lang) {
        'ru' => ru,
        'ky' => ky ?? ru,
        _ => en,
      };
}

enum Urgency { red, amber, green, grey }

/// Demo scenario a case was built from (prototype only; no model runs).
enum Scenario { red, amber, green, grey }

enum SyncState { synced, pending, localOnly }

class Finding {
  const Finding(this.title, {this.detail, this.suspected = true});
  final LocalText title;
  final LocalText? detail;
  final bool suspected;
}

class ActionStep {
  const ActionStep(this.text, this.source, {this.reviewed = false});
  final LocalText text;

  /// Protocol name, order number and date (disclaimer D10).
  final String source;

  /// False until a cardiologist has reviewed the text.
  final bool reviewed;
}

class TechDetails {
  const TechDetails({
    required this.speedMmS,
    required this.gainMmMv,
    required this.leadsFound,
    required this.layout,
    required this.quality,
  });
  final int? speedMmS;
  final int? gainMmMv;
  final int leadsFound;
  final String layout;

  /// Image quality 0..1.
  final double quality;
}

class EcgCase {
  const EcgCase({
    required this.id,
    required this.createdAt,
    required this.scenario,
    required this.urgency,
    required this.headline,
    required this.findings,
    required this.steps,
    required this.tech,
    required this.rhythm,
    this.heartRate,
    this.highlights = const [],
    this.age,
    this.sex,
    this.symptoms = const {},
    this.sync = SyncState.pending,
    this.extraNotices = const [],
  });

  final String id;
  final DateTime createdAt;
  final Scenario scenario;
  final Urgency urgency;
  final LocalText headline;
  final List<Finding> findings;
  final List<ActionStep> steps;
  final TechDetails tech;
  final DemoRhythm rhythm;
  final int? heartRate;
  final List<(double, double)> highlights;
  final int? age;
  final String? sex;
  final Set<Symptom> symptoms;
  final SyncState sync;

  /// Mandatory notices (D5, D6, D7) shown on the result screen.
  final List<Notice> extraNotices;

  EcgCase copyWith({
    String? id,
    DateTime? createdAt,
    int? age,
    String? sex,
    Set<Symptom>? symptoms,
    SyncState? sync,
  }) =>
      EcgCase(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        scenario: scenario,
        urgency: urgency,
        headline: headline,
        findings: findings,
        steps: steps,
        tech: tech,
        rhythm: rhythm,
        heartRate: heartRate,
        highlights: highlights,
        age: age ?? this.age,
        sex: sex ?? this.sex,
        symptoms: symptoms ?? this.symptoms,
        sync: sync ?? this.sync,
        extraNotices: extraNotices,
      );
}

enum Symptom { chestPain, breathless, fainting, palpitations, weakness }

/// Mandatory notices from docs/safety/INTENDED_USE.md section 7.
enum Notice { rhythmOnly, afConfirm, acsNotExcluded }
