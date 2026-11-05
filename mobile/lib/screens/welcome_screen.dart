import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/ecg_trace.dart';
import 'settings_screen.dart' show LanguagePicker;

/// First launch: language + research disclaimer (D1) with acknowledgement.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: Tokens.brand, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Text('ECG-AI KG', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(Tokens.radius),
              child: const SizedBox(
                height: 110,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  child: EcgPaper(rhythm: DemoRhythm.sinus, seconds: 5, pxPerMm: 3.4, heightMm: 32),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l.welcomeTitle, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(l.welcomeBody, style: t.bodyLarge),
            const SizedBox(height: 24),
            Text(l.chooseLanguage, style: t.titleMedium),
            const SizedBox(height: 8),
            const LanguagePicker(),
            if (ref.watch(settingsProvider).lang == 'ky')
              NoticeBox(text: l.kyDraftNote, icon: Icons.translate),
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFFFFF8E6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.science_outlined),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l.researchTitle, style: t.titleMedium)),
                  ]),
                  const SizedBox(height: 8),
                  Text(l.disclaimerFirstLaunch, style: t.bodyMedium),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _agree,
              onChanged: (v) => setState(() => _agree = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(l.iUnderstand),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _agree
                  ? () {
                      ref.read(settingsProvider.notifier).acknowledge();
                      context.go('/home');
                    }
                  : null,
              child: Text(l.start),
            ),
          ],
        ),
      ),
    );
  }
}
