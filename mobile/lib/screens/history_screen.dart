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
        padding: Tokens.pagePadding,
        children: [
          Row(children: [
            const Icon(Icons.phone_android, size: 18, color: Tokens.inkMuted),
            const SizedBox(width: Tokens.s2),
            Expanded(
                child: Text(l.historyHint, style: const TextStyle(fontSize: 14, color: Tokens.inkMuted))),
          ]),
          const SizedBox(height: Tokens.s4),
          if (cases.isEmpty)
            Card(child: EmptyState(icon: Icons.monitor_heart_outlined, text: l.noCases)),
          for (final c in cases) ...[CaseTile(c: c), const SizedBox(height: Tokens.s2)],
        ],
      ),
    );
  }
}

/// One case in a list: urgency colour + icon + word, headline, date, patient, sync state.
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/case/${c.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Tokens.s3, Tokens.s3, Tokens.s2, Tokens.s3),
          child: Row(children: [
            UrgencyChip(urgency: c.urgency),
            const SizedBox(width: Tokens.s3),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                UrgencyTag(urgency: c.urgency),
                const SizedBox(height: 2),
                Text(c.headline.of(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: Tokens.s1),
                Text([when, if (who.isNotEmpty) who].join(' · '),
                    style: const TextStyle(fontSize: 13, color: Tokens.inkMuted)),
              ]),
            ),
            Tooltip(
              message: syncText,
              child: Padding(
                padding: const EdgeInsets.all(Tokens.s2),
                child: Icon(syncIcon, size: 20, color: Tokens.inkMuted, semanticLabel: syncText),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
