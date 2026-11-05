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

/// Full-width urgency banner: colour + icon + word, the headline and the heart rate.
/// The word is in sentence case (long Cyrillic words in capitals are hard to read).
/// Grey ("no result") has a dashed outline and no colour fill.
class UrgencyBanner extends StatelessWidget {
  const UrgencyBanner({super.key, required this.urgency, required this.headline, this.heartRate});
  final Urgency urgency;
  final String headline;
  final int? heartRate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = Tokens.urgency(urgency);
    final word = urgencyLabel(l, urgency);
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(Tokens.s4 + 2, Tokens.s4, Tokens.s4 + 2, Tokens.s4 + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: s.border != null ? Colors.white : s.fg.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(s.icon, color: s.fg, size: 26),
            ),
            const SizedBox(width: Tokens.s3),
            Expanded(
              child: Text(word,
                  style: TextStyle(
                      color: s.fg, fontWeight: FontWeight.w800, fontSize: 17, height: 1.25)),
            ),
          ]),
          const SizedBox(height: Tokens.s3),
          Text(headline,
              style: TextStyle(color: s.fg, fontSize: 23, fontWeight: FontWeight.w700, height: 1.25)),
          if (heartRate != null) ...[
            const SizedBox(height: Tokens.s3),
            Divider(color: s.fg.withValues(alpha: 0.25), height: 1),
            const SizedBox(height: Tokens.s3),
            Row(children: [
              Icon(Icons.favorite, size: 22, color: s.fg),
              const SizedBox(width: Tokens.s2),
              Text(l.bpm(heartRate!),
                  style: TextStyle(
                      color: s.fg,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ]),
          ],
        ],
      ),
    );
    final box = Container(
      width: double.infinity,
      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(Tokens.radiusLarge)),
      child: content,
    );
    return Semantics(
      container: true,
      label: '$word. $headline${heartRate != null ? '. ${l.bpm(heartRate!)}' : ''}',
      child: ExcludeSemantics(
        child: s.border != null
            ? CustomPaint(
                foregroundPainter: DashedBorderPainter(color: s.border!, radius: Tokens.radiusLarge),
                child: box,
              )
            : box,
      ),
    );
  }
}

/// Dashed rounded-rectangle outline (used for the grey "no result" state).
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({required this.color, required this.radius, this.width = 2.5});
  final Color color;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    const dash = 9.0, gapLen = 6.0;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += dash + gapLen) {
        canvas.drawPath(m.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter old) => old.color != color || old.radius != radius;
}

/// Compact urgency marker for lists (colour + icon; pair it with [UrgencyTag] for the word).
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

/// The urgency word in the level's text colour, for list rows.
class UrgencyTag extends StatelessWidget {
  const UrgencyTag({super.key, required this.urgency});
  final Urgency urgency;

  @override
  Widget build(BuildContext context) {
    final s = Tokens.urgency(urgency);
    return Text(urgencyLabel(AppLocalizations.of(context), urgency),
        style: TextStyle(color: s.onSoft, fontSize: 13, fontWeight: FontWeight.w700, height: 1.3));
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.icon, this.trailing});
  final String text;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Tokens.s5, bottom: Tokens.s2 + 2),
        child: Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Tokens.brand),
            const SizedBox(width: Tokens.s2),
          ],
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          ?trailing,
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
      avatar: Icon(online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
          size: 18, color: Tokens.inkMuted),
      label: Text(online ? l.online : l.offline),
      tooltip: l.offlineHint,
      shape: const StadiumBorder(),
      side: const BorderSide(color: Tokens.outline),
      backgroundColor: Tokens.card,
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
      decoration: const BoxDecoration(
        color: Color(0xFFEDF0F4),
        border: Border(top: BorderSide(color: Tokens.outline)),
      ),
      padding: const EdgeInsets.fromLTRB(Tokens.s4, Tokens.s2 + 2, Tokens.s4, Tokens.s2 + 2),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 18, color: Tokens.ink),
        const SizedBox(width: Tokens.s2),
        Expanded(
            child: Text(l.disclaimerResult,
                style: const TextStyle(fontSize: 13, height: 1.35, color: Tokens.ink))),
      ]),
    );
  }
}

/// Tinted notice with an icon. [tone] colours the icon and border; the text stays dark.
class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key, required this.text, this.icon = Icons.info_outline, this.tone, this.strong = false});
  final String text;
  final IconData icon;
  final Color? tone;

  /// Mandatory or safety notices: stronger border and semibold text.
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = tone ?? Tokens.brand;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Tokens.s3),
      padding: const EdgeInsets.all(Tokens.s3 + 2),
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.withValues(alpha: 0.07), Tokens.card),
        borderRadius: BorderRadius.circular(Tokens.radiusSmall + 2),
        border: Border.all(color: c.withValues(alpha: strong ? 0.6 : 0.25), width: strong ? 1.5 : 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: c, size: 22),
        const SizedBox(width: Tokens.s3),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Tokens.ink,
                    fontWeight: strong ? FontWeight.w600 : FontWeight.w400))),
      ]),
    );
  }
}

/// Friendly empty state: an icon in a soft circle and one sentence.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Tokens.s5, horizontal: Tokens.s4),
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: Tokens.brandSoft, shape: BoxShape.circle),
            child: Icon(icon, color: Tokens.brand, size: 30),
          ),
          const SizedBox(height: Tokens.s3),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Tokens.inkMuted)),
        ]),
      );
}

/// App mark: one heartbeat on the brand square. Drawn in code, so no image asset.
/// tool/gen_icons.py draws the same shape for the launcher and web icons.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _AppMarkPainter()),
      );
}

/// The heartbeat polyline of the app mark, in unit coordinates (0..1).
const appMarkBeat = [
  (0.14, 0.56), (0.31, 0.56), (0.36, 0.48), (0.41, 0.56), (0.45, 0.56), (0.50, 0.22),
  (0.56, 0.76), (0.60, 0.56), (0.66, 0.56), (0.72, 0.44), (0.78, 0.56), (0.86, 0.56),
];

class _AppMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final r = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w * 0.28));
    canvas.drawRRect(r, Paint()..color = Tokens.brand);
    final p = Path()..moveTo(appMarkBeat.first.$1 * w, appMarkBeat.first.$2 * w);
    for (final (x, y) in appMarkBeat.skip(1)) {
      p.lineTo(x * w, y * w);
    }
    canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.075
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "ECG-AI KG" wordmark next to the app mark.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.markSize = 44, this.fontSize = 22});
  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'ECG-AI KG',
        child: ExcludeSemantics(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AppMark(size: markSize),
            SizedBox(width: markSize * 0.27),
            Text.rich(
              const TextSpan(children: [
                TextSpan(text: 'ECG-AI '),
                TextSpan(text: 'KG', style: TextStyle(color: Tokens.brand)),
              ]),
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: Tokens.ink),
            ),
          ]),
        ),
      );
}

/// Segmented progress for the four capture steps, shown under the app bar.
class StepProgress extends StatelessWidget implements PreferredSizeWidget {
  const StepProgress({super.key, required this.step, this.total = 4, this.dark = false});
  final int step;
  final int total;
  final bool dark;

  @override
  Size get preferredSize => const Size.fromHeight(12);

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Tokens.s4, 0, Tokens.s4, Tokens.s2),
          child: Row(children: [
            for (var i = 1; i <= total; i++) ...[
              if (i > 1) const SizedBox(width: Tokens.s1 + 2),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= step
                        ? (dark ? Colors.white : Tokens.brand)
                        : (dark ? Colors.white24 : Tokens.outline),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ]),
        ),
      );
}

/// Two buttons side by side; stacked (primary on top) when the screen is narrow or the
/// system font is large, so Russian/Kyrgyz labels never break inside a word.
class ActionPair extends StatelessWidget {
  const ActionPair({super.key, required this.secondary, required this.primary});
  final Widget secondary;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final narrow = mq.size.width / mq.textScaler.scale(1) < 370;
    if (narrow) {
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        primary,
        const SizedBox(height: Tokens.s2),
        secondary,
      ]);
    }
    return Row(children: [
      Expanded(child: secondary),
      const SizedBox(width: Tokens.s3),
      Expanded(child: primary),
    ]);
  }
}

String langOf(WidgetRef ref) => ref.watch(settingsProvider).lang;
