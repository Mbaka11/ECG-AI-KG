import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rhythm patterns used to draw demo traces. These are synthetic shapes for the
/// UI prototype only; they are not clinical examples.
enum DemoRhythm { sinus, sinusTachy, sinusBrady, af, stElevation, noisy }

/// Generates a synthetic single-lead ECG (mV) sampled at [fs] Hz.
List<double> synthEcg(DemoRhythm rhythm,
    {double seconds = 10, int fs = 250, int seed = 7}) {
  final rnd = math.Random(seed);
  final n = (seconds * fs).round();
  final out = List<double>.filled(n, 0);

  double g(double t, double c, double w, double a) =>
      a * math.exp(-math.pow(t - c, 2) / (2 * w * w));

  // Beat times.
  final beats = <double>[];
  var t = 0.35;
  while (t < seconds + 1) {
    beats.add(t);
    switch (rhythm) {
      case DemoRhythm.sinusTachy:
        t += 0.48 + rnd.nextDouble() * 0.02;
      case DemoRhythm.sinusBrady:
        t += 1.45 + rnd.nextDouble() * 0.04;
      case DemoRhythm.af:
        t += 0.42 + rnd.nextDouble() * 0.5;
      default:
        t += 0.85 + rnd.nextDouble() * 0.04;
    }
  }

  final hasP = rhythm != DemoRhythm.af;
  final ste = rhythm == DemoRhythm.stElevation;

  for (var i = 0; i < n; i++) {
    final x = i / fs;
    var v = 0.0;
    for (final b in beats) {
      final d = x - b;
      if (d < -0.4 || d > 0.6) continue;
      if (hasP) v += g(d, -0.17, 0.022, 0.13);
      v += g(d, -0.03, 0.008, -0.09); // Q
      v += g(d, 0.0, 0.011, ste ? 0.85 : 1.05); // R
      v += g(d, 0.032, 0.010, ste ? -0.05 : -0.22); // S
      if (ste) {
        // Raised ST segment merging into the T wave (illustrative only).
        final s = 1 / (1 + math.exp(-(d - 0.05) / 0.008));
        final e = 1 / (1 + math.exp((d - 0.30) / 0.03));
        v += 0.28 * s * e;
        v += g(d, 0.24, 0.05, 0.25);
      } else {
        v += g(d, 0.26, 0.048, 0.28); // T
      }
    }
    if (rhythm == DemoRhythm.af) {
      v += 0.045 * math.sin(2 * math.pi * 6.3 * x + 1.7 * math.sin(x)) +
          0.02 * (rnd.nextDouble() - 0.5);
    }
    if (rhythm == DemoRhythm.noisy) {
      v += 0.35 * math.sin(2 * math.pi * 0.3 * x) +
          0.18 * (rnd.nextDouble() - 0.5) +
          0.08 * math.sin(2 * math.pi * 50 * x);
      if (x > 3.2 && x < 4.6) v = 1.4; // clipped / missing part of the trace
    }
    out[i] = v + 0.008 * (rnd.nextDouble() - 0.5);
  }
  return out;
}

/// Standard ECG paper with a trace drawn at 25 mm/s and 10 mm/mV.
class EcgPaper extends StatelessWidget {
  const EcgPaper({
    super.key,
    required this.rhythm,
    this.seconds = 10,
    this.pxPerMm = 4,
    this.heightMm = 30,
    this.highlights = const [],
    this.traceColor,
    this.showPaper = true,
    this.leadLabel,
  });

  final DemoRhythm rhythm;
  final double seconds;
  final double pxPerMm;
  final double heightMm;

  /// Time ranges (seconds) to highlight as "look here".
  final List<(double, double)> highlights;
  final Color? traceColor;
  final bool showPaper;
  final String? leadLabel;

  @override
  Widget build(BuildContext context) {
    final width = seconds * 25 * pxPerMm;
    final height = heightMm * pxPerMm;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EcgPainter(
          samples: synthEcg(rhythm, seconds: seconds),
          pxPerMm: pxPerMm,
          highlights: highlights,
          traceColor: traceColor ?? const Color(0xFF1B1B1F),
          showPaper: showPaper,
          leadLabel: leadLabel,
          highlightColor: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  _EcgPainter({
    required this.samples,
    required this.pxPerMm,
    required this.highlights,
    required this.traceColor,
    required this.showPaper,
    required this.highlightColor,
    this.leadLabel,
  });

  final List<double> samples;
  final double pxPerMm;
  final List<(double, double)> highlights;
  final Color traceColor;
  final bool showPaper;
  final Color highlightColor;
  final String? leadLabel;

  static const fs = 250;

  @override
  void paint(Canvas canvas, Size size) {
    if (showPaper) {
      canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFF6F5));
      final minor = Paint()
        ..color = const Color(0xFFF5C6C4)
        ..strokeWidth = 0.5;
      final major = Paint()
        ..color = const Color(0xFFE59894)
        ..strokeWidth = 1;
      for (var mm = 0; mm * pxPerMm <= size.width; mm++) {
        final x = mm * pxPerMm;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), mm % 5 == 0 ? major : minor);
      }
      for (var mm = 0; mm * pxPerMm <= size.height; mm++) {
        final y = mm * pxPerMm;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), mm % 5 == 0 ? major : minor);
      }
    }

    final pxPerSec = 25 * pxPerMm;
    for (final (a, b) in highlights) {
      final r = Rect.fromLTRB(a * pxPerSec, 0, b * pxPerSec, size.height);
      canvas.drawRect(r, Paint()..color = highlightColor.withValues(alpha: 0.16));
      canvas.drawRect(
          r,
          Paint()
            ..color = highlightColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }

    final baseline = size.height * 0.6;
    final pxPerMv = 10 * pxPerMm;
    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = i / fs * pxPerSec;
      final y = (baseline - samples[i] * pxPerMv).clamp(1.0, size.height - 1);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = traceColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round);

    if (leadLabel != null) {
      final tp = TextPainter(
        text: TextSpan(
            text: leadLabel,
            style: TextStyle(color: traceColor, fontSize: 12, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, const Offset(6, 4));
    }
  }

  @override
  bool shouldRepaint(covariant _EcgPainter old) =>
      old.samples != samples || old.highlights != highlights;
}
