import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/ecg_case.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

String symptomLabel(AppLocalizations l, Symptom s) => switch (s) {
      Symptom.chestPain => l.symChestPain,
      Symptom.breathless => l.symBreathless,
      Symptom.fainting => l.symFainting,
      Symptom.palpitations => l.symPalpitations,
      Symptom.weakness => l.symWeakness,
    };

IconData symptomIcon(Symptom s) => switch (s) {
      Symptom.chestPain => Icons.favorite_border,
      Symptom.breathless => Icons.air,
      Symptom.fainting => Icons.airline_seat_flat_outlined,
      Symptom.palpitations => Icons.monitor_heart_outlined,
      Symptom.weakness => Icons.battery_alert_outlined,
    };

/// Step 4 — optional patient info. No name or ID is collected (privacy, D11).
class PatientScreen extends ConsumerWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(draftProvider);
    final n = ref.read(draftProvider.notifier);
    final ages = [(l.ageUnder40, 35), (l.age40to64, 55), (l.age65plus, 72)];
    return Scaffold(
      appBar: AppBar(title: Text(l.stepOf(4, 4))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(l.patientTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(l.patientSub),
          SectionTitle(l.symptomsQ, icon: Icons.sick_outlined),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in Symptom.values)
              FilterChip(
                avatar: Icon(symptomIcon(s), size: 20),
                label: Text(symptomLabel(l, s)),
                selected: d.symptoms.contains(s),
                onSelected: (_) => n.toggleSymptom(s),
              ),
          ]),
          SectionTitle(l.sex, icon: Icons.person_outline),
          SegmentedButton<String>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 'f', label: Text(l.sexF)),
              ButtonSegment(value: 'm', label: Text(l.sexM)),
            ],
            selected: {if (d.sex != null) d.sex!},
            onSelectionChanged: (v) => n.setSex(v.isEmpty ? null : v.first),
          ),
          SectionTitle(l.age, icon: Icons.cake_outlined),
          SegmentedButton<int>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            segments: [for (final (label, v) in ages) ButtonSegment(value: v, label: Text(label))],
            selected: {if (d.age != null) d.age!},
            onSelectionChanged: (v) => n.setAge(v.isEmpty ? null : v.first),
          ),
          const SizedBox(height: 16),
          NoticeBox(text: l.noNameNote, icon: Icons.lock_outline),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: () => context.push('/new/processing'),
          label: Text(l.analyse),
        ),
      ),
    );
  }
}

/// Processing — runs on the phone; shows the steps so the wait is understandable.
class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (_step < 3) {
        setState(() => _step++);
      } else {
        t.cancel();
        final c = ref.read(casesProvider.notifier).addFromDraft(ref.read(draftProvider));
        context.go('/case/${c.id}?fresh=1');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [l.procPhoto, l.procTrace, l.procRhythm, l.procReport];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 56, height: 56, child: CircularProgressIndicator(strokeWidth: 5)),
              const SizedBox(height: 24),
              Text(l.analysing,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(l.onDevice),
              const SizedBox(height: 24),
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Icon(
                      i < _step ? Icons.check_circle : (i == _step ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                      color: i <= _step ? Tokens.brand : Colors.black26,
                    ),
                    const SizedBox(width: 12),
                    Text(steps[i],
                        style: TextStyle(
                            fontSize: 17,
                            color: i <= _step ? Tokens.ink : Colors.black45,
                            fontWeight: i == _step ? FontWeight.w600 : FontWeight.w400)),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
