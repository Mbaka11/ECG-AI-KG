import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/ecg_case.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'history_screen.dart' show CaseTile;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final settings = ref.watch(settingsProvider);
    final cases = ref.watch(casesProvider);
    final pending = cases.where((c) => c.sync != SyncState.synced).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.facility, style: t.titleMedium),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: ConnectivityChip())],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(l.homeGreeting, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _NewEcgCard(onTap: () {
            ref.read(draftProvider.notifier).reset();
            context.push('/new/guide');
          }),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _SmallAction(
                icon: Icons.photo_library_outlined,
                label: l.fromGallery,
                onTap: () {
                  ref.read(draftProvider.notifier).reset();
                  context.push('/new/check');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallAction(
                icon: Icons.menu_book_outlined,
                label: l.howToPhoto,
                onTap: () => context.push('/new/guide'),
              ),
            ),
          ]),
          if (pending > 0 && !settings.online) ...[
            const SizedBox(height: 12),
            NoticeBox(text: l.pendingSync(pending), icon: Icons.cloud_upload_outlined),
          ],
          SectionTitle(l.recentCases, icon: Icons.history),
          for (final c in cases.take(3)) ...[
            CaseTile(c: c),
            const SizedBox(height: 8),
          ],
          TextButton(onPressed: () => context.go('/history'), child: Text(l.seeAll)),
        ],
      ),
    );
  }
}

class _NewEcgCard extends StatelessWidget {
  const _NewEcgCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Tokens.brand,
      borderRadius: BorderRadius.circular(Tokens.radius + 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radius + 4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.newEcg,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(l.newEcgSub,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15)),
              ]),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ]),
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(Tokens.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(children: [
              Icon(icon, color: Tokens.brand),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
      );
}
