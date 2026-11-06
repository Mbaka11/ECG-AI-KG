import 'package:ecg_ai_kg/app.dart';
import 'package:ecg_ai_kg/data/demo_cases.dart';
import 'package:ecg_ai_kg/models/ecg_case.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome needs acknowledgement before start', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1800));
    await tester.pumpWidget(const ProviderScope(child: EcgApp()));
    await tester.pumpAndSettle();
    expect(find.text('Начать'), findsOneWidget);
    final start = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Начать'));
    expect(start.onPressed, isNull);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();
    expect(find.text('Новая ЭКГ'), findsOneWidget);
  });

  test('low-quality demo case is never green', () {
    final c = demoCase(Scenario.grey);
    expect(c.urgency, isNot(Urgency.green));
    expect(c.tech.quality, lessThan(0.6));
  });

  test('every action step has a source and is pending review', () {
    for (final s in Scenario.values) {
      for (final step in demoCase(s).steps) {
        expect(step.source, isNotEmpty);
        expect(step.reviewed, isFalse);
      }
    }
  });

  test('demo clinical texts have Kyrgyz and never say "normal"', () {
    // The UI never says "normal" (Kyrgyz: нормалдуу, кадимки).
    final banned = RegExp(r'normal|норм|кадимки', caseSensitive: false);
    for (final s in Scenario.values) {
      final c = demoCase(s);
      final texts = <LocalText>[
        c.headline,
        for (final f in c.findings) ...[f.title, if (f.detail != null) f.detail!],
        for (final st in c.steps) st.text,
      ];
      for (final t in texts) {
        expect(t.ky, isNotNull, reason: t.en);
        for (final v in [t.en, t.ru, t.ky!]) {
          expect(banned.hasMatch(v), isFalse, reason: v);
        }
      }
    }
  });

  test('ARB files share keys and the Kyrgyz file is marked as a draft', () {
    Map<String, dynamic> load(String l) =>
        jsonDecode(File('lib/l10n/app_$l.arb').readAsStringSync()) as Map<String, dynamic>;
    Set<String> keys(Map<String, dynamic> m) => m.keys.where((k) => !k.startsWith('@')).toSet();
    final en = load('en'), ru = load('ru'), ky = load('ky');
    expect(keys(ky), keys(en));
    expect(keys(ru), keys(en));
    expect(ky['@@x-status'], contains('DRAFT'));
    final banned = RegExp(r'норм|кадимки', caseSensitive: false);
    // Strings that are the same in both languages (codes, numbers, loanwords).
    const sameAsRussian = {'layout', 'sampleSt', 'sampleAf', 'age40to64', 'age65plus'};
    for (final k in keys(ky)) {
      expect(banned.hasMatch(ky[k] as String), isFalse, reason: k);
      if (!sameAsRussian.contains(k)) {
        expect(ky[k], isNot(ru[k]), reason: 'Kyrgyz still holds Russian text: $k');
      }
    }
  });
}

