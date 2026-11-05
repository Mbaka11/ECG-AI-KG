import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/ecg_case.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';

String urgencyLabel(AppLocalizations l, Urgency u) => switch (u) {
      Urgency.red => l.urgencyRed,
      Urgency.amber => l.urgencyAmber,
      Urgency.green => l.urgencyGreen,
      Urgency.grey => l.urgencyGrey,
    };

/// Full-width urgency banner: colour + icon + word (+ headline).
class UrgencyBanner extends StatelessWidget {
  const UrgencyBanner({super.key, required this.urgency, required this.headline, this.heartRate});
  final Urgency urgency;
  final String headline;
  final int? heartRate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = Tokens.urgency(urgency);
    return Semantics(
      container: true,
      label: '${urgencyLabel(l, urgency)}. $headline',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: s.bg,
          borderRadius: BorderRadius.circular(Tokens.radius),
          border: s.border != null ? Border.all(color: s.border!, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(s.icon, color: s.fg, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(urgencyLabel(l, urgency).toUpperCase(),
                    style: TextStyle(
                        color: s.fg, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.8)),
              ),
              if (heartRate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: s.fg.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.favorite, size: 16, color: s.fg),
                    const SizedBox(width: 4),
                    Text(l.bpm(heartRate!),
                        style: TextStyle(color: s.fg, fontWeight: FontWeight.w700)),
                  ]),
                ),
            ]),
            const SizedBox(height: 10),
            Text(headline,
                style: TextStyle(color: s.fg, fontSize: 22, fontWeight: FontWeight.w700, height: 1.25)),
          ],
        ),
      ),
    );
  }
}

/// Compact urgency marker for lists.
class UrgencyChip extends StatelessWidget {
  const UrgencyChip({super.key, required this.urgency});
  final Urgency urgency;

  @override
  Widget build(BuildContext context) {
    final s = Tokens.urgency(urgency);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(12),
        border: s.border != null ? Border.all(color: s.border!, width: 2) : null,
      ),
      child: Icon(s.icon, color: s.fg, size: 24),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(text, style: Theme.of(context).textTheme.titleMedium),
        ]),
      );
}

/// Shows whether the phone is online; the app works the same offline.
class ConnectivityChip extends ConsumerWidget {
  const ConnectivityChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final online = ref.watch(settingsProvider).online;
    return ActionChip(
      onPressed: () => ref.read(settingsProvider.notifier).toggleOnline(),
      avatar: Icon(online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined, size: 18),
      label: Text(online ? l.online : l.offline),
      tooltip: l.offlineHint,
    );
  }
}

/// Fixed disclaimer (D2) shown on every result.
class DisclaimerBar extends StatelessWidget {
  const DisclaimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: const Color(0xFFEFF1F5),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(l.disclaimerResult, style: const TextStyle(fontSize: 13, height: 1.35))),
      ]),
    );
  }
}

class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key, required this.text, this.icon = Icons.info_outline, this.tone});
  final String text;
  final IconData icon;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = tone ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(Tokens.radiusSmall),
        border: Border(left: BorderSide(color: c, width: 4)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: c, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4))),
      ]),
    );
  }
}

String langOf(WidgetRef ref) => ref.watch(settingsProvider).lang;
