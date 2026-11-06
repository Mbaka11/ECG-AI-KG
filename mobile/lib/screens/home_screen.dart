import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
        titleSpacing: Tokens.s4,
        title: Row(children: [
          const AppMark(size: 34),
          const SizedBox(width: Tokens.s3),
          Expanded(
            child: Text(settings.facility,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleMedium),
          ),
        ]),
        actions: const [Padding(padding: EdgeInsets.only(right: Tokens.s3), child: ConnectivityChip())],
      ),
      body: ListView(
        padding: Tokens.pagePadding,
        children: [
          const SizedBox(height: Tokens.s2),
          Text(l.homeGreeting, style: t.headlineSmall),
          const SizedBox(height: Tokens.s4),
          _NewEcgCard(onTap: () {
            ref.read(draftProvider.notifier).reset();
            context.push('/new/guide');
          }),
          const SizedBox(height: Tokens.s3),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              _SecondaryAction(
                icon: Icons.photo_library_outlined,
                label: l.fromGallery,
                onTap: () async {
                  ref.read(draftProvider.notifier).reset();
                  final img = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 3000);
                  if (img == null) return;
                  ref.read(draftProvider.notifier).setPhoto(await img.readAsBytes());
                  if (context.mounted) context.push('/new/check');
                },
              ),
              const Divider(indent: 72),
              _SecondaryAction(
                icon: Icons.menu_book_outlined,
                label: l.howToPhoto,
                onTap: () => context.push('/new/guide'),
              ),
            ]),
          ),
          if (pending > 0 && !settings.online)
            NoticeBox(text: l.pendingSync(pending), icon: Icons.cloud_upload_outlined, tone: Tokens.inkMuted),
          SectionTitle(
            l.recentCases,
            trailing: cases.isEmpty
                ? null
                : TextButton(onPressed: () => context.go('/history'), child: Text(l.seeAll)),
          ),
          if (cases.isEmpty)
            Card(child: EmptyState(icon: Icons.monitor_heart_outlined, text: l.noCases))
          else
            for (final c in cases.take(3)) ...[
              CaseTile(c: c),
              const SizedBox(height: Tokens.s2),
            ],
        ],
      ),
    );
  }
}

/// The one primary action on Home.
class _NewEcgCard extends StatelessWidget {
  const _NewEcgCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final radius = BorderRadius.circular(Tokens.radiusLarge);
    return Semantics(
      button: true,
      child: Material(
        color: Tokens.brand,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(children: [
            // A faint heartbeat line across the card, decoration only.
            const Positioned.fill(child: CustomPaint(painter: _BeatLinePainter())),
            Padding(
              padding: const EdgeInsets.fromLTRB(Tokens.s5 - 4, Tokens.s5 - 4, Tokens.s5 - 4, Tokens.s5 - 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(Tokens.radius)),
                    child: const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward, color: Tokens.brand),
                  ),
                ]),
                const SizedBox(height: Tokens.s5 + 4),
                Text(l.newEcg,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.15)),
                const SizedBox(height: Tokens.s1),
                Text(l.newEcgSub,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, height: 1.35)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BeatLinePainter extends CustomPainter {
  const _BeatLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.40;
    final unit = size.height * 0.22;
    final p = Path()..moveTo(size.width * 0.30, y);
    for (var x = size.width * 0.30; x < size.width + 60; x += unit * 3.2) {
      p
        ..lineTo(x + unit * 0.9, y)
        ..lineTo(x + unit * 1.1, y - unit * 1.1)
        ..lineTo(x + unit * 1.35, y + unit * 0.55)
        ..lineTo(x + unit * 1.5, y)
        ..quadraticBezierTo(x + unit * 2.0, y - unit * 0.4, x + unit * 2.4, y)
        ..lineTo(x + unit * 3.2, y);
    }
    canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Tokens.s4, vertical: Tokens.s2),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Tokens.brandSoft, shape: BoxShape.circle),
                child: Icon(icon, color: Tokens.brand, size: 22),
              ),
              const SizedBox(width: Tokens.s4),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Tokens.ink))),
              const Icon(Icons.chevron_right, color: Tokens.inkMuted),
            ]),
          ),
        ),
      );
}
