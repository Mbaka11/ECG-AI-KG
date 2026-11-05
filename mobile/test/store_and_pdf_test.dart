import 'package:ecg_ai_kg/data/demo_cases.dart';
import 'package:ecg_ai_kg/l10n/app_localizations.dart';
import 'package:ecg_ai_kg/models/ecg_case.dart';
import 'package:ecg_ai_kg/services/pdf_report.dart';
import 'package:ecg_ai_kg/state/case_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('case store round-trips metadata and never stores photos', () async {
    SharedPreferences.setMockInitialValues({});
    final store = CaseStore();
    final c = demoCase(Scenario.amber, id: 'C-1')
        .copyWith(age: 72, sex: 'm', symptoms: {Symptom.palpitations}, sync: SyncState.pending);
    await store.save([c]);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cases.v1')!;
    expect(raw.contains('photo'), isFalse);

    final back = (await store.load())!;
    expect(back.single.id, 'C-1');
    expect(back.single.urgency, Urgency.amber);
    expect(back.single.symptoms, {Symptom.palpitations});
    expect(back.single.age, 72);
  });

  test('case store falls back to null on corrupt data', () async {
    SharedPreferences.setMockInitialValues({'cases.v1': 'not json'});
    expect(await CaseStore().load(), isNull);
  });

  test('PDF builds for every scenario in Russian', () async {
    await initializeDateFormatting('ru');
    final l = lookupAppLocalizations(const Locale('ru'));
    for (final s in Scenario.values) {
      final bytes = await buildCasePdf(demoCase(s), l, 'ru');
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(5000));
    }
  });
}
