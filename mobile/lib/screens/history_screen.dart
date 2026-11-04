import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/ecg_case.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cases = ref.watch(casesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.history)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          NoticeBox(text: l.historyHint, icon: Icons.phone_android),
          const SizedBox(height: 16),
          for (final c in cases) ...[CaseTile(c: c), const SizedBox(height: 8)],
        ],
      ),
    );
  }
}

class CaseTile extends ConsumerWidget {
  const CaseTile({super.key, required this.c});
  final EcgCase c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = langOf(ref);
    final when = DateFormat('d MMM, HH:mm', lang).format(c.createdAt);
    final who = [
      if (c.sex != null) c.sex == 'f' ? l.sexF : l.sexM,
      if (c.age != null) l.ageYears(c.age!),
    ].join(', ');
    final (syncIcon, syncText) = switch (c.sync) {
      SyncState.synced => (Icons.cloud_done_outlined, l.syncSynced),
      SyncState.pending => (Icons.cloud_upload_outlined, l.syncPending),
      SyncState.localOnly => (Icons.phone_android, l.syncLocal),
    };
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radius),
        onTap: () => context.push('/case/${c.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            UrgencyChip(urgency: c.urgency),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.headline.of(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text([when, if (who.isNotEmpty) who].join(' · '),
                    style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.6))),
              ]),
            ),
            Tooltip(message: syncText, child: Icon(syncIcon, size: 20, color: Colors.black54)),
          ]),
        ),
      ),
    );
  }
}
