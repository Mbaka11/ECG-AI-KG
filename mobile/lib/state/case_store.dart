import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_cases.dart';
import '../models/ecg_case.dart';

/// Keeps the last [maxCases] cases on the phone between launches.
///
/// Prototype store: only case metadata is saved (scenario, time, age band, sex,
/// symptoms, sync state), never photos or names. The real app moves to Drift
/// (SQLite) per ADR 0007 with the retention rules of the data management plan.
class CaseStore {
  static const maxCases = 50;
  static const _key = 'cases.v1';

  Future<List<EcgCase>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return [for (final m in list) _fromJson(m)];
    } catch (_) {
      return null; // corrupt or unavailable storage: fall back to the demo seed
    }
  }

  Future<void> save(List<EcgCase> cases) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode([for (final c in cases.take(maxCases)) _toJson(c)]));
    } catch (_) {
      // Storage is a convenience in the prototype; the UI keeps working without it.
    }
  }

  Map<String, dynamic> _toJson(EcgCase c) => {
        'id': c.id,
        'at': c.createdAt.toIso8601String(),
        'scenario': c.scenario.name,
        'age': c.age,
        'sex': c.sex,
        'symptoms': [for (final s in c.symptoms) s.name],
        'sync': c.sync.name,
      };

  EcgCase _fromJson(Map<String, dynamic> m) => demoCase(
        Scenario.values.byName(m['scenario'] as String),
        at: DateTime.parse(m['at'] as String),
        id: m['id'] as String,
      ).copyWith(
        age: m['age'] as int?,
        sex: m['sex'] as String?,
        symptoms: {for (final s in (m['symptoms'] as List)) Symptom.values.byName(s as String)},
        sync: SyncState.values.byName(m['sync'] as String),
      );
}
