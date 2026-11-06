import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../data/demo_cases.dart';
import '../l10n/app_localizations.dart';
import '../models/ecg_case.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/ecg_trace.dart';

DemoRhythm rhythmFor(Scenario s) => switch (s) {
      Scenario.red => DemoRhythm.stElevation,
      Scenario.amber => DemoRhythm.af,
      Scenario.green => DemoRhythm.sinus,
      Scenario.grey => DemoRhythm.noisy,
    };

enum _Tip { flat, light, whole, above }

/// Step 1 — short visual checklist before taking the photo.
class CaptureGuideScreen extends StatelessWidget {
  const CaptureGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tips = [
      (_Tip.flat, l.tipFlat, l.tipFlatSub),
      (_Tip.light, l.tipLight, l.tipLightSub),
      (_Tip.whole, l.tipWhole, l.tipWholeSub),
      (_Tip.above, l.tipAbove, l.tipAboveSub),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.stepOf(1, 4)), bottom: const StepProgress(step: 1)),
      body: ListView(
        padding: Tokens.pagePadding,
        children: [
          Text(l.guideTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Tokens.s4),
          for (final (tip, title, sub) in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: Tokens.s3),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Tokens.s3),
                  child: Row(children: [
                    _TipPicture(tip),
                    const SizedBox(width: Tokens.s4),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, height: 1.3)),
                        const SizedBox(height: 2),
                        Text(sub, style: const TextStyle(fontSize: 15, height: 1.35, color: Tokens.inkMuted)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(Tokens.s4, Tokens.s2, Tokens.s4, Tokens.s4),
        child: FilledButton.icon(
          icon: const Icon(Icons.photo_camera_outlined),
          onPressed: () => context.push('/new/camera'),
          label: Text(l.openCamera),
        ),
      ),
    );
  }
}

/// Small drawn picture for each photo tip (no image assets, no copyrighted art).
class _TipPicture extends StatelessWidget {
  const _TipPicture(this.tip);
  final _Tip tip;

  static const _w = 92.0, _h = 76.0;

  Widget _strip({double width = 64, double angle = 0}) => Transform.rotate(
        angle: angle,
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 3, offset: const Offset(0, 1.5)),
          ]),
          child: EcgPaper(
              rhythm: DemoRhythm.sinus, seconds: 2.4, pxPerMm: width / 60, heightMm: 16, traceColor: Tokens.ink),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final Widget scene = switch (tip) {
      // A strip lying flat on a table.
      _Tip.flat => Container(
          color: const Color(0xFFEFE6D8),
          alignment: Alignment.center,
          child: _strip(width: 68),
        ),
      // Daylight from above, no shadow on the strip.
      _Tip.light => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFFFF1C2), Color(0xFFFFFBEF)],
            ),
          ),
          child: Stack(children: [
            const Positioned(top: 4, right: 6, child: Icon(Icons.wb_sunny, color: Color(0xFFE0A100), size: 24)),
            Positioned(left: 10, bottom: 12, child: _strip(width: 64)),
          ]),
        ),
      // The whole strip inside the camera frame corners.
      _Tip.whole => Container(
          color: Tokens.brandSoft,
          child: CustomPaint(
            foregroundPainter: _CornersPainter(color: Tokens.brand, inset: 7, len: 12, width: 3),
            child: Center(child: _strip(width: 62)),
          ),
        ),
      // Side view: phone held parallel above the paper.
      _Tip.above => Container(
          color: Tokens.brandSoft,
          child: CustomPaint(painter: _AbovePainter()),
        ),
    };
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Tokens.radiusSmall + 2),
        child: SizedBox(width: _w, height: _h, child: scene),
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  _CornersPainter({required this.color, required this.inset, required this.len, required this.width});
  final Color color;
  final double inset, len, width;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final r = Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset);
    for (final (c, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(c, c + Offset(dx * len, 0), p);
      canvas.drawLine(c, c + Offset(0, dy * len), p);
    }
  }

  @override
  bool shouldRepaint(covariant _CornersPainter old) => old.color != color;
}

class _AbovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Table and paper.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.80, w, h * 0.20), Paint()..color = const Color(0xFFEFE6D8));
    canvas.drawRect(Rect.fromLTWH(w * 0.14, h * 0.76, w * 0.72, h * 0.05), Paint()..color = const Color(0xFFF2B8B5));
    // Phone, parallel to the paper.
    final phone = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.16, w * 0.64, h * 0.11), const Radius.circular(4));
    canvas.drawRRect(phone, Paint()..color = Tokens.ink);
    canvas.drawCircle(Offset(w * 0.5, h * 0.27 + 1), 2.2, Paint()..color = Tokens.ink);
    // Dashed view lines down to the paper.
    final dash = Paint()
      ..color = Tokens.brand
      ..strokeWidth = 2;
    for (final x in [w * 0.30, w * 0.70]) {
      for (var y = h * 0.34; y < h * 0.72; y += 7) {
        canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 4, h * 0.72)), dash);
      }
    }
    // Arrow in the middle.
    final a = Paint()
      ..color = Tokens.brand
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.36), Offset(w * 0.5, h * 0.66), a);
    canvas.drawLine(Offset(w * 0.5, h * 0.67), Offset(w * 0.5 - 6, h * 0.59), a);
    canvas.drawLine(Offset(w * 0.5, h * 0.67), Offset(w * 0.5 + 6, h * 0.59), a);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Step 2 — simulated camera with a framing guide (no real camera in the prototype).
class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  static const _bg = Color(0xFF111316);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scenario = ref.watch(draftProvider).scenario;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            fontFamily: 'NotoSans', fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
        title: Text(l.stepOf(2, 4)),
        bottom: const StepProgress(step: 2, dark: true),
      ),
      body: Column(children: [
        // Demo-only sample chooser.
        const SampleChips(padding: EdgeInsets.symmetric(horizontal: Tokens.s3)),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final frameW = c.maxWidth - 2 * Tokens.s5;
            final frameH = math.min(c.maxHeight * 0.6, frameW * 34 / 150 + 56);
            return Stack(alignment: Alignment.center, children: [
              // "Live" view: a slightly rotated, shaded paper strip.
              Transform.rotate(
                angle: -0.035,
                child: _PhotoLike(rhythm: rhythmFor(scenario), width: frameW - 12),
              ),
              // Frame outline and corner marks.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _FramePainter(Size(frameW, frameH))),
                ),
              ),
              Positioned(
                top: Tokens.s4,
                left: Tokens.s4,
                right: Tokens.s4,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Tokens.s4, vertical: Tokens.s2 + 2),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.crop_free, color: Colors.white, size: 20),
                      const SizedBox(width: Tokens.s2),
                      Flexible(
                        child: Text(l.cameraHint,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                ),
              ),
            ]);
          }),
        ),
        SafeArea(
          minimum: const EdgeInsets.only(bottom: Tokens.s5),
          child: Column(children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: Colors.white54),
                shape: const StadiumBorder(),
              ),
              onPressed: () async {
                final img = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 3000);
                if (img == null) return;
                ref.read(draftProvider.notifier).setPhoto(await img.readAsBytes());
                if (context.mounted) context.push('/new/check');
              },
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l.usePhoneCamera),
            ),
            const SizedBox(height: Tokens.s4),
            Semantics(
              button: true,
              label: l.takePhoto,
              child: GestureDetector(
                onTap: () => context.push('/new/check'),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.frame);
  final Size frame;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCenter(center: size.center(Offset.zero), width: frame.width, height: frame.height);
    final hole = RRect.fromRectAndRadius(r, const Radius.circular(14));
    canvas.drawRRect(
        hole,
        Paint()
          ..color = Colors.white38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    canvas.save();
    canvas.translate(r.left, r.top);
    _CornersPainter(color: Colors.white, inset: 0, len: 28, width: 5).paint(canvas, Size(r.width, r.height));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) => old.frame != frame;
}

/// Demo-only: picks which canned scenario the "analysis" returns.
class SampleChips extends ConsumerWidget {
  const SampleChips({super.key, this.padding = EdgeInsets.zero});
  final EdgeInsets padding;

  static String name(AppLocalizations l, Scenario s) => switch (s) {
        Scenario.red => l.sampleSt,
        Scenario.amber => l.sampleAf,
        Scenario.green => l.sampleSinus,
        Scenario.grey => l.samplePoor,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scenario = ref.watch(draftProvider).scenario;
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: [
          for (final s in Scenario.values)
            Padding(
              padding: const EdgeInsets.only(right: Tokens.s2),
              child: ChoiceChip(
                label: Text(name(l, s)),
                selected: s == scenario,
                onSelected: (_) => ref.read(draftProvider.notifier).setScenario(s),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoLike extends StatelessWidget {
  const _PhotoLike({required this.rhythm, required this.width, this.overlay = false});
  final DemoRhythm rhythm;
  final double width;
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    const seconds = 6.0;
    final pxPerMm = width / (seconds * 25);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(children: [
        EcgPaper(rhythm: rhythm, seconds: seconds, pxPerMm: pxPerMm, heightMm: 34, leadLabel: 'II'),
        // Uneven light, like a phone photo.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.transparent,
                  Colors.black.withValues(alpha: rhythm == DemoRhythm.noisy ? 0.38 : 0.12),
                ],
              ),
            ),
          ),
        ),
        if (overlay)
          EcgPaper(
            rhythm: rhythm,
            seconds: seconds,
            pxPerMm: pxPerMm,
            heightMm: 34,
            showPaper: false,
            traceColor: Tokens.brand.withValues(alpha: 0.85),
          ),
      ]),
    );
  }
}

/// Step 3 — quality verdict, detected layout/scale, retake or continue.
class QualityCheckScreen extends ConsumerWidget {
  const QualityCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final draft = ref.watch(draftProvider);
    final scenario = draft.scenario;
    final photo = draft.photo;
    final c = demoCase(scenario);
    final good = c.tech.quality >= 0.6;
    final t = c.tech;
    return Scaffold(
      appBar: AppBar(title: Text(l.stepOf(3, 4)), bottom: const StepProgress(step: 3)),
      body: ListView(
        padding: Tokens.pagePadding,
        children: [
          Text(l.checkTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Tokens.s4),
          _QualityVerdict(good: good, text: good ? l.qualityGood : l.qualityPoor),
          const SizedBox(height: Tokens.s3),
          if (photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(Tokens.radius),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: Image.memory(photo, fit: BoxFit.contain, width: double.infinity),
              ),
            ),
            NoticeBox(text: l.photoDemoNote, icon: Icons.science_outlined, tone: Tokens.caution),
            SectionTitle(l.demoSample, icon: Icons.science_outlined),
            const SampleChips(),
            const SizedBox(height: Tokens.s3),
          ],
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s3),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                LayoutBuilder(
                  builder: (context, box) => Transform.rotate(
                    angle: -0.02,
                    child: _PhotoLike(rhythm: rhythmFor(scenario), width: box.maxWidth, overlay: true),
                  ),
                ),
                const SizedBox(height: Tokens.s3),
                Row(children: [
                  Container(
                    width: 20,
                    height: 4,
                    decoration: BoxDecoration(color: Tokens.brand, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: Tokens.s2),
                  Expanded(child: Text(l.overlayLegend, style: const TextStyle(fontSize: 14, color: Tokens.inkMuted))),
                ]),
              ]),
            ),
          ),
          SectionTitle(l.detected, icon: Icons.tune),
          Card(
            child: Column(children: [
              _kv(l.paperSpeed, t.speedMmS != null ? '${t.speedMmS} mm/s' : l.notFound),
              const Divider(),
              _kv(l.gain, t.gainMmMv != null ? '${t.gainMmMv} mm/mV' : l.notFound, warn: t.gainMmMv == null),
              const Divider(),
              _kv(l.leadsFound, '${t.leadsFound}'),
              const Divider(),
              _kv(l.layout, t.layout),
            ]),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l.correctValues),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(Tokens.s4, Tokens.s2, Tokens.s4, Tokens.s4),
        // When the photo is poor, Retake is the primary action and comes first.
        child: () {
          final retake = (good ? OutlinedButton.icon : FilledButton.icon)(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.replay),
            label: Text(l.retake),
          );
          final cont = (good ? FilledButton.icon : OutlinedButton.icon)(
            onPressed: () => context.push('/new/patient'),
            icon: const Icon(Icons.arrow_forward),
            label: Text(l.usePhoto),
          );
          return good ? ActionPair(secondary: retake, primary: cont) : ActionPair(secondary: cont, primary: retake);
        }(),
      ),
    );
  }

  Widget _kv(String k, String v, {bool warn = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Tokens.s4, vertical: Tokens.s3),
        child: Row(children: [
          Expanded(child: Text(k, style: const TextStyle(fontSize: 15, color: Tokens.inkMuted))),
          if (warn) ...[
            const Icon(Icons.warning_amber_rounded, size: 18, color: Tokens.caution),
            const SizedBox(width: Tokens.s1),
          ],
          Text(v,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: warn ? Tokens.caution : Tokens.ink)),
        ]),
      );
}

/// The photo-quality decision, shown first on the check screen.
/// Uses its own tones, not the urgency palette: photo quality is not a result.
class _QualityVerdict extends StatelessWidget {
  const _QualityVerdict({required this.good, required this.text});
  final bool good;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = good ? const Color(0xFF1B6E3C) : Tokens.caution;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Tokens.s4),
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.withValues(alpha: 0.08), Tokens.card),
        borderRadius: BorderRadius.circular(Tokens.radius),
        border: Border.all(color: c.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(children: [
        Icon(good ? Icons.check_circle : Icons.warning_rounded, color: c, size: 32),
        const SizedBox(width: Tokens.s3),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: Tokens.ink)),
        ),
      ]),
    );
  }
}
