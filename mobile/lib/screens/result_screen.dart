import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../l10n/app_localizations.dart';
import '../models/ecg_case.dart';
import '../services/pdf_report.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/ecg_trace.dart';
import 'patient_screen.dart' show symptomLabel;

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.caseId, this.fresh = false});
  final String caseId;
  final bool fresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = langOf(ref);
    final cases = ref.watch(casesProvider);
    final c = cases.firstWhere((e) => e.id == caseId, orElse: () => cases.first);
    final s = Tokens.urgency(c.urgency);
    final t = Theme.of(context).textTheme;
    final serious = c.symptoms.intersection({Symptom.chestPain, Symptom.breathless, Symptom.fainting});

    return Scaffold(
      appBar: AppBar(
        title: Text(l.result),
        leading: IconButton(
          icon: Icon(fresh ? Icons.close : Icons.arrow_back),
          tooltip: fresh ? l.done : null,
          onPressed: () => fresh ? context.go('/home') : context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: l.savePdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportPdf(context, c, l, lang),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          UrgencyBanner(urgency: c.urgency, headline: c.headline.of(lang), heartRate: c.heartRate),

          // Symptoms override reassurance: an unwell patient is never "fine" because of the ECG.
          if (serious.isNotEmpty && c.urgency != Urgency.red)
            NoticeBox(
              text: l.symptomsOverride(serious.map((x) => symptomLabel(l, x)).join(', ')),
              icon: Icons.priority_high,
              tone: Tokens.urgency(Urgency.red).bg,
            ),

          SectionTitle(l.whatToDo, icon: Icons.checklist),
          Card(
            child: Column(children: [
              for (var i = 0; i < c.steps.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 64),
                _StepRow(n: i + 1, step: c.steps[i], lang: lang, color: s.bg, fg: s.fg),
              ],
            ]),
          ),
          if (c.urgency == Urgency.red)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: s.bg, foregroundColor: s.fg),
                onPressed: () => _forward(context, ref, c, l),
                icon: const Icon(Icons.send_outlined),
                label: Text(l.sendToExpert),
              ),
            ),

          SectionTitle(l.findings, icon: Icons.search),
          Card(
            child: Column(children: [
              for (final f in c.findings)
                ListTile(
                  leading: Icon(f.suspected ? Icons.help_outline : Icons.circle_outlined, size: 20),
                  title: Text(f.title.of(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: f.detail != null ? Text(f.detail!.of(lang)) : null,
                  trailing: f.suspected
                      ? Chip(label: Text(l.suspected), visualDensity: VisualDensity.compact)
                      : null,
                ),
            ]),
          ),
          for (final n in c.extraNotices) NoticeBox(text: _notice(l, n)),

          SectionTitle(l.ecgTrace, icon: Icons.show_chart),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: EcgPaper(
                  rhythm: c.rhythm,
                  seconds: 10,
                  pxPerMm: 3.2,
                  heightMm: 32,
                  highlights: c.highlights,
                  leadLabel: 'II',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                      border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.highlightLegend, style: const TextStyle(fontSize: 13))),
                  const Icon(Icons.swipe, size: 18, color: Colors.black45),
                ]),
              ),
            ]),
          ),

          SectionTitle(l.technical, icon: Icons.tune),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 14, height: 1.6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${l.paperSpeed}: ${c.tech.speedMmS ?? '—'} mm/s · ${l.gain}: ${c.tech.gainMmMv ?? '—'} mm/mV'),
                  Text('${l.leadsFound}: ${c.tech.leadsFound} · ${l.layout}: ${c.tech.layout}'),
                  Text('${l.imageQuality}: ${(c.tech.quality * 100).round()} / 100'),
                  const Divider(),
                  Text(l.versions('0.1.0-demo', 'none (demo)', '2026-11-04'),
                      style: t.bodySmall),
                  Text('${l.caseId}: ${c.id}', style: t.bodySmall),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _forward(context, ref, c, l),
                icon: const Icon(Icons.send_outlined),
                label: Text(l.sendShort),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.go('/home'),
                child: Text(l.done),
              ),
            ),
          ]),
        ],
      ),
      bottomNavigationBar: const SafeArea(child: DisclaimerBar()),
    );
  }

  String _notice(AppLocalizations l, Notice n) => switch (n) {
        Notice.rhythmOnly => l.noticeRhythmOnly,
        Notice.afConfirm => l.noticeAf,
        Notice.acsNotExcluded => l.noticeAcs,
      };

  void _forward(BuildContext context, WidgetRef ref, EcgCase c, AppLocalizations l) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.sendToExpert, style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l.forwardConsent),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.send_outlined),
            onPressed: () {
              ref.read(casesProvider.notifier).markForwarded(c.id);
              Navigator.pop(ctx);
              _snack(context, ref.read(settingsProvider).online ? l.forwardSent : l.forwardQueued);
            },
            label: Text(l.send),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
        ]),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, EcgCase c, AppLocalizations l, String lang) async {
    try {
      final bytes = await buildCasePdf(c, l, lang);
      await Printing.sharePdf(bytes: bytes, filename: 'ecg-ai-kg-${c.id}.pdf');
      if (context.mounted) _snack(context, l.pdfReady);
    } catch (_) {
      if (context.mounted) _snack(context, l.pdfFailed);
    }
  }

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.n, required this.step, required this.lang, required this.color, required this.fg});
  final int n;
  final ActionStep step;
  final String lang;
  final Color color;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Text('$n', style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(step.text.of(lang), style: const TextStyle(fontSize: 17, height: 1.35)),
            const SizedBox(height: 4),
            Text(
              '${step.source}${step.reviewed ? '' : ' · ${l.pendingReview}'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ]),
        ),
      ]),
    );
  }
}
