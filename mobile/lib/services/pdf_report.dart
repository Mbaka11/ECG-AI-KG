import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_localizations.dart';
import '../models/ecg_case.dart';
import '../widgets/ecg_trace.dart';

/// Builds a one-page A4 PDF of a result, to send for consultation (FR-4).
/// Same content and disclaimers as the result screen; no patient name or ID.
Future<Uint8List> buildCasePdf(EcgCase c, AppLocalizations l, String lang) async {
  final font = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans.ttf'));
  final theme = pw.ThemeData.withFont(base: font, bold: font);
  final u = _urgencyColors(c.urgency);
  final when = DateFormat('d MMM yyyy, HH:mm', lang).format(c.createdAt);
  final who = [
    if (c.sex != null) c.sex == 'f' ? l.sexF : l.sexM,
    if (c.age != null) l.ageYears(c.age!),
  ].join(', ');

  final doc = pw.Document(title: 'ECG-AI KG ${c.id}', author: 'ECG-AI KG prototype');
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('ECG-AI KG', style: const pw.TextStyle(fontSize: 16)),
            pw.Text('${l.caseId} ${c.id} · $when${who.isEmpty ? '' : ' · $who'}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ]),
          pw.SizedBox(height: 12),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: u.$1,
              borderRadius: pw.BorderRadius.circular(8),
              border: c.urgency == Urgency.grey ? pw.Border.all(color: PdfColors.grey700, width: 2) : null,
            ),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(
                '${_urgencyWord(l, c.urgency).toUpperCase()}${c.heartRate != null ? '   ·   ${l.bpm(c.heartRate!)}' : ''}',
                style: pw.TextStyle(fontSize: 10, color: u.$2, letterSpacing: 0.8),
              ),
              pw.SizedBox(height: 4),
              pw.Text(c.headline.of(lang), style: pw.TextStyle(fontSize: 18, color: u.$2)),
            ]),
          ),
          if (c.symptoms.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('${l.symptomsQ}: ${c.symptoms.map((s) => _symptom(l, s)).join(', ')}',
                style: const pw.TextStyle(fontSize: 10)),
          ],
          _h(l.whatToDo),
          for (var i = 0; i < c.steps.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.SizedBox(width: 18, child: pw.Text('${i + 1}.', style: const pw.TextStyle(fontSize: 11))),
                pw.Expanded(
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(c.steps[i].text.of(lang), style: const pw.TextStyle(fontSize: 11)),
                    pw.Text(
                      '${c.steps[i].source}${c.steps[i].reviewed ? '' : ' · ${l.pendingReview}'}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                  ]),
                ),
              ]),
            ),
          _h(l.findings),
          for (final f in c.findings)
            pw.Bullet(
              text: '${f.title.of(lang)}${f.detail != null ? ' — ${f.detail!.of(lang)}' : ''}'
                  '${f.suspected ? ' (${l.suspected})' : ''}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          for (final n in c.extraNotices)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text('• ${_notice(l, n)}', style: const pw.TextStyle(fontSize: 9.5)),
            ),
          _h(l.ecgTrace),
          _trace(c),
          pw.SizedBox(height: 6),
          pw.Text(
            '${l.paperSpeed}: ${c.tech.speedMmS ?? '—'} mm/s · ${l.gain}: ${c.tech.gainMmMv ?? '—'} mm/mV · '
            '${l.leadsFound}: ${c.tech.leadsFound} · ${l.layout}: ${c.tech.layout} · '
            '${l.imageQuality}: ${(c.tech.quality * 100).round()}/100',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey400),
          pw.Text(l.disclaimerResult, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 2),
          pw.Text(l.disclaimerFirstLaunch, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.Text(l.versions('0.1.0-demo', 'none (demo)', '2026-11-04'),
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ],
      ),
    ),
  );
  return doc.save();
}

pw.Widget _h(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(t, style: const pw.TextStyle(fontSize: 13)),
    );

/// 10 s of lead II on a 25 mm/s, 10 mm/mV grid, drawn as vectors.
pw.Widget _trace(EcgCase c) {
  const seconds = 10.0, mmW = 250.0, mmH = 30.0;
  final samples = synthEcg(c.rhythm, seconds: seconds);
  return pw.LayoutBuilder(builder: (ctx, box) {
    final w = box!.maxWidth;
    final k = w / mmW; // points per mm
    final h = mmH * k;
    return pw.SizedBox(
      width: w,
      height: h,
      child: pw.CustomPaint(
        size: PdfPoint(w, h),
        painter: (canvas, size) {
          canvas.setFillColor(PdfColor.fromHex('#FFF6F5'));
          canvas.drawRect(0, 0, w, h);
          canvas.fillPath();
          for (final (a, b) in c.highlights) {
            canvas.setFillColor(PdfColor.fromHex('#E9E1F6'));
            canvas.drawRect(a * 25 * k, 0, (b - a) * 25 * k, h);
            canvas.fillPath();
          }
          for (var mm = 0; mm <= mmW; mm++) {
            canvas
              ..setStrokeColor(PdfColor.fromHex(mm % 5 == 0 ? '#E59894' : '#F5C6C4'))
              ..setLineWidth(mm % 5 == 0 ? 0.5 : 0.2)
              ..drawLine(mm * k, 0, mm * k, h)
              ..strokePath();
          }
          for (var mm = 0; mm <= mmH; mm++) {
            canvas
              ..setStrokeColor(PdfColor.fromHex(mm % 5 == 0 ? '#E59894' : '#F5C6C4'))
              ..setLineWidth(mm % 5 == 0 ? 0.5 : 0.2)
              ..drawLine(0, mm * k, w, mm * k)
              ..strokePath();
          }
          // PDF y axis points up: baseline at 40 % of the height.
          final base = h * 0.4;
          canvas
            ..setStrokeColor(PdfColors.black)
            ..setLineWidth(0.6);
          for (var i = 0; i < samples.length; i++) {
            final x = i / 250 * 25 * k;
            final y = (base + samples[i] * 10 * k).clamp(0.5, h - 0.5);
            i == 0 ? canvas.moveTo(x, y) : canvas.lineTo(x, y);
          }
          canvas.strokePath();
        },
      ),
    );
  });
}

(PdfColor, PdfColor) _urgencyColors(Urgency u) => switch (u) {
      Urgency.red => (PdfColor.fromHex('#B3261E'), PdfColors.white),
      Urgency.amber => (PdfColor.fromHex('#FFC107'), PdfColor.fromHex('#1F1F1F')),
      Urgency.green => (PdfColor.fromHex('#1B6E3C'), PdfColors.white),
      Urgency.grey => (PdfColor.fromHex('#ECEEF1'), PdfColor.fromHex('#3C4043')),
    };

String _urgencyWord(AppLocalizations l, Urgency u) => switch (u) {
      Urgency.red => l.urgencyRed,
      Urgency.amber => l.urgencyAmber,
      Urgency.green => l.urgencyGreen,
      Urgency.grey => l.urgencyGrey,
    };

String _notice(AppLocalizations l, Notice n) => switch (n) {
      Notice.rhythmOnly => l.noticeRhythmOnly,
      Notice.afConfirm => l.noticeAf,
      Notice.acsNotExcluded => l.noticeAcs,
    };

String _symptom(AppLocalizations l, Symptom s) => switch (s) {
      Symptom.chestPain => l.symChestPain,
      Symptom.breathless => l.symBreathless,
      Symptom.fainting => l.symFainting,
      Symptom.palpitations => l.symPalpitations,
      Symptom.weakness => l.symWeakness,
    };
