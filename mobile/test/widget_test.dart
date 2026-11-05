import 'package:ecg_ai_kg/app.dart';
import 'package:ecg_ai_kg/data/demo_cases.dart';
import 'package:ecg_ai_kg/models/ecg_case.dart';
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
}
