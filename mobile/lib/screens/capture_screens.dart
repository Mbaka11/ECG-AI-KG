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

/// Step 1 — short visual checklist before taking the photo.
class CaptureGuideScreen extends StatelessWidget {
  const CaptureGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tips = [
      (Icons.straighten, l.tipFlat, l.tipFlatSub),
      (Icons.wb_sunny_outlined, l.tipLight, l.tipLightSub),
      (Icons.crop_free, l.tipWhole, l.tipWholeSub),
      (Icons.screen_rotation_alt_outlined, l.tipAbove, l.tipAboveSub),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.stepOf(1, 4))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(l.guideTitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          for (final (icon, title, sub) in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Tokens.brand.withValues(alpha: 0.1),
                    child: Icon(icon, color: Tokens.brand),
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                  subtitle: Text(sub),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          icon: const Icon(Icons.photo_camera_outlined),
          onPressed: () => context.push('/new/camera'),
          label: Text(l.openCamera),
        ),
      ),
    );
  }
}

/// Step 2 — simulated camera with a framing guide (no real camera in the prototype).
class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scenario = ref.watch(draftProvider).scenario;
    return Scaffold(
      backgroundColor: const Color(0xFF111316),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111316),
        foregroundColor: Colors.white,
        title: Text(l.stepOf(2, 4)),
      ),
      body: Column(children: [
        // Demo-only sample chooser.
        const SampleChips(padding: EdgeInsets.symmetric(horizontal: 12)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (context, c) {
              return Stack(alignment: Alignment.center, children: [
                // "Live" view: a slightly rotated, shaded paper strip.
                Transform.rotate(
                  angle: -0.035,
                  child: _PhotoLike(rhythm: rhythmFor(scenario), width: c.maxWidth * 0.95),
                ),
                // Framing guide.
                IgnorePointer(
                  child: Container(
                    width: c.maxWidth * 0.92,
                    height: math.min(c.maxHeight * 0.6, c.maxWidth * 0.95 * 34 / 150 + 48),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(l.cameraHint,
                        style: const TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
              ]);
            }),
          ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () async {
            final img = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 3000);
            if (img == null) return;
            ref.read(draftProvider.notifier).setPhoto(await img.readAsBytes());
            if (context.mounted) context.push('/new/check');
          },
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(l.usePhoneCamera),
        ),
        const SizedBox(height: 8),
        SafeArea(
          minimum: const EdgeInsets.only(bottom: 24),
          child: Semantics(
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
        ),
      ]),
    );
  }

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
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: [
          for (final s in Scenario.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
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
      appBar: AppBar(title: Text(l.stepOf(3, 4))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(l.checkTitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(Tokens.radiusSmall),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: Image.memory(photo, fit: BoxFit.contain, width: double.infinity),
              ),
            ),
            NoticeBox(text: l.photoDemoNote, icon: Icons.science_outlined),
            SectionTitle(l.demoSample, icon: Icons.science_outlined),
            const SampleChips(),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(
            builder: (context, box) => Transform.rotate(
              angle: -0.02,
              child: _PhotoLike(rhythm: rhythmFor(scenario), width: box.maxWidth, overlay: true),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Container(width: 18, height: 3, color: Tokens.brand),
            const SizedBox(width: 8),
            Expanded(child: Text(l.overlayLegend, style: const TextStyle(fontSize: 13))),
          ]),
          const SizedBox(height: 12),
          NoticeBox(
            text: good ? l.qualityGood : l.qualityPoor,
            icon: good ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            tone: good ? Tokens.urgency(Urgency.green).bg : const Color(0xFF8A5A00),
          ),
          SectionTitle(l.detected, icon: Icons.tune),
          Card(
            child: Column(children: [
              _kv(l.paperSpeed, t.speedMmS != null ? '${t.speedMmS} mm/s' : l.notFound),
              const Divider(height: 1),
              _kv(l.gain, t.gainMmMv != null ? '${t.gainMmMv} mm/mV' : l.notFound, warn: t.gainMmMv == null),
              const Divider(height: 1),
              _kv(l.leadsFound, '${t.leadsFound}'),
              const Divider(height: 1),
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
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(children: [
          Expanded(
            child: (good ? OutlinedButton.icon : FilledButton.icon)(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.replay),
              label: Text(l.retake),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: (good ? FilledButton.icon : OutlinedButton.icon)(
              onPressed: () => context.push('/new/patient'),
              icon: const Icon(Icons.arrow_forward),
              label: Text(l.usePhoto),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _kv(String k, String v, {bool warn = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(child: Text(k, style: const TextStyle(fontSize: 15))),
          if (warn) const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFF8A5A00)),
          const SizedBox(width: 4),
          Text(v, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
      );
}
