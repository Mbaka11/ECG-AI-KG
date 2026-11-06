import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider).lang;
    final langs = [('ru', 'Русский'), ('ky', 'Кыргызча'), ('en', 'English')];
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [for (final (code, name) in langs) ButtonSegment(value: code, label: Text(name))],
      selected: {lang},
      onSelectionChanged: (v) => ref.read(settingsProvider.notifier).setLang(v.first),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: Tokens.pagePadding,
        children: [
          SectionTitle(l.language, icon: Icons.translate),
          const LanguagePicker(),
          if (s.lang == 'ky') NoticeBox(text: l.kyDraftNote, icon: Icons.translate),
          SectionTitle(l.account, icon: Icons.badge_outlined),
          Card(
            child: Column(children: [
              ListTile(leading: const Icon(Icons.person_outline), title: Text(s.userName)),
              const Divider(),
              ListTile(leading: const Icon(Icons.local_hospital_outlined), title: Text(s.facility)),
            ]),
          ),
          SectionTitle(l.dataAndPrivacy, icon: Icons.lock_outline),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l.about),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: Text(l.showIntro),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/welcome'),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// About + data (D1, D9, D11).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: ListView(
        padding: Tokens.pagePadding,
        children: [
          const SizedBox(height: Tokens.s2),
          const Wordmark(markSize: 52, fontSize: 24),
          const SizedBox(height: Tokens.s2),
          Text(l.versions('0.1.0-demo', 'none (demo)', '2026-11-04'), style: t.bodySmall),
          const SizedBox(height: Tokens.s1),
          NoticeBox(text: l.disclaimerFirstLaunch, icon: Icons.science_outlined, tone: Tokens.caution, strong: true),
          SectionTitle(l.whatWeStore, icon: Icons.storage_outlined),
          Text(l.dataText, style: t.bodyLarge),
          SectionTitle(l.limitations, icon: Icons.report_outlined),
          Text(l.limitationsText, style: t.bodyLarge),
        ],
      ),
    );
  }
}
