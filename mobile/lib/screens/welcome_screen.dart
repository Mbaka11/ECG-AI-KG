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
          padding: const EdgeInsets.fromLTRB(Tokens.s5 - 4, Tokens.s5, Tokens.s5 - 4, Tokens.s5),
          children: [
            const Align(alignment: Alignment.centerLeft, child: Wordmark()),
            const SizedBox(height: Tokens.s5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Tokens.radiusLarge),
                border: Border.all(color: const Color(0xFFF1C9C6)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Tokens.radiusLarge - 1),
                child: const SizedBox(
                  height: 110,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: NeverScrollableScrollPhysics(),
                    child: EcgPaper(rhythm: DemoRhythm.sinus, seconds: 5, pxPerMm: 3.4, heightMm: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Tokens.s5),
            Text(l.welcomeTitle, style: t.headlineSmall),
            const SizedBox(height: Tokens.s2),
            Text(l.welcomeBody, style: t.bodyLarge?.copyWith(color: Tokens.inkMuted)),
            const SizedBox(height: Tokens.s5),
            Text(l.chooseLanguage, style: t.titleMedium),
            const SizedBox(height: Tokens.s2),
            const LanguagePicker(),
            const SizedBox(height: Tokens.s5),
            Container(
              padding: const EdgeInsets.all(Tokens.s4),
              decoration: BoxDecoration(
                color: Tokens.research,
                borderRadius: BorderRadius.circular(Tokens.radius),
                border: Border.all(color: Tokens.caution.withValues(alpha: 0.35)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.science_outlined, color: Tokens.caution),
                  const SizedBox(width: Tokens.s2),
                  Expanded(child: Text(l.researchTitle, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: Tokens.s2),
                Text(l.disclaimerFirstLaunch, style: t.bodyMedium?.copyWith(fontSize: 16)),
              ]),
            ),
            const SizedBox(height: Tokens.s3),
            // The whole row is the tap target for the acknowledgement.
            Material(
              color: _agree ? Tokens.brandSoft : Tokens.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Tokens.radius),
                side: BorderSide(color: _agree ? Tokens.brand : Tokens.control, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: CheckboxListTile(
                value: _agree,
                onChanged: (v) => setState(() => _agree = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: Tokens.s2),
                title: Text(l.iUnderstand, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: Tokens.s4),
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
