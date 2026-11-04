import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_cases.dart';
import '../models/ecg_case.dart';
import 'case_store.dart';

class Settings {
  const Settings({
    this.lang = 'ru',
    this.acknowledged = false,
    this.facility = 'FAP Kara-Suu (demo)',
    this.userName = 'Feldsher (demo)',
    this.online = false,
  });
  final String lang;
  final bool acknowledged;
  final String facility;
  final String userName;

  /// Demo toggle to show the offline state in the UI.
  final bool online;

  Settings copyWith({String? lang, bool? acknowledged, bool? online}) => Settings(
        lang: lang ?? this.lang,
        acknowledged: acknowledged ?? this.acknowledged,
        facility: facility,
        userName: userName,
        online: online ?? this.online,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() {
    // Demo links can preselect a language: ?lang=en|ru|ky
    final q = Uri.base.queryParameters['lang'];
    return Settings(lang: const {'en', 'ru', 'ky'}.contains(q) ? q! : 'ru');
  }

  void setLang(String lang) => state = state.copyWith(lang: lang);
  void acknowledge() => state = state.copyWith(acknowledged: true);
  void toggleOnline() => state = state.copyWith(online: !state.online);
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

/// The case being captured.
class Draft {
  const Draft({this.scenario = Scenario.red, this.age, this.sex, this.symptoms = const {}, this.photo});
  final Scenario scenario;
  final int? age;
  final String? sex;
  final Set<Symptom> symptoms;

  /// Photo picked from the camera or gallery. Kept in memory only; the
  /// prototype does not analyse it (results come from [scenario]).
  final Uint8List? photo;

  Draft copyWith({Scenario? scenario, int? age, String? sex, Set<Symptom>? symptoms, bool clearSex = false}) =>
      Draft(
        scenario: scenario ?? this.scenario,
        age: age ?? this.age,
        sex: clearSex ? null : (sex ?? this.sex),
        symptoms: symptoms ?? this.symptoms,
        photo: photo,
      );
}

class DraftNotifier extends Notifier<Draft> {
  @override
  Draft build() => const Draft();

  void reset() => state = Draft(scenario: state.scenario);
  void setScenario(Scenario s) => state = state.copyWith(scenario: s);
  void setAge(int? a) =>
      state = Draft(scenario: state.scenario, age: a, sex: state.sex, symptoms: state.symptoms, photo: state.photo);
  void setPhoto(Uint8List? p) =>
      state = Draft(scenario: state.scenario, age: state.age, sex: state.sex, symptoms: state.symptoms, photo: p);
  void setSex(String? s) => state = state.copyWith(sex: s, clearSex: s == null);
  void toggleSymptom(Symptom s) {
    final next = {...state.symptoms};
    next.contains(s) ? next.remove(s) : next.add(s);
    state = state.copyWith(symptoms: next);
  }
}

final draftProvider = NotifierProvider<DraftNotifier, Draft>(DraftNotifier.new);

class CasesNotifier extends Notifier<List<EcgCase>> {
  final _store = CaseStore();

  @override
  List<EcgCase> build() {
    _restore();
    return seedHistory();
  }

  Future<void> _restore() async {
    final saved = await _store.load();
    if (saved != null && saved.isNotEmpty) state = saved;
  }

  void _set(List<EcgCase> next) {
    state = next.take(CaseStore.maxCases).toList();
    _store.save(state);
  }

  EcgCase addFromDraft(Draft d) {
    final c = demoCase(d.scenario).copyWith(age: d.age, sex: d.sex, symptoms: d.symptoms);
    _set([c, ...state]);
    return c;
  }

  void markForwarded(String id) {
    _set([
      for (final c in state) c.id == id ? c.copyWith(sync: SyncState.synced) : c,
    ]);
  }
}

final casesProvider = NotifierProvider<CasesNotifier, List<EcgCase>>(CasesNotifier.new);
