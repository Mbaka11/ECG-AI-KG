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
          const SizedBox(width: Tokens.s1),
        ],
      ),
      body: ListView(
        padding: Tokens.pagePadding,
        children: [
          UrgencyBanner(urgency: c.urgency, headline: c.headline.of(lang), heartRate: c.heartRate),

          // Symptoms override reassurance: an unwell patient is never "fine" because of the ECG.
          if (serious.isNotEmpty && c.urgency != Urgency.red)
            NoticeBox(
              text: l.symptomsOverride(serious.map((x) => symptomLabel(l, x)).join(', ')),
              icon: Icons.priority_high,
              tone: Tokens.urgency(Urgency.red).bg,
              strong: true,
            ),

          SectionTitle(l.whatToDo, icon: Icons.checklist),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Tokens.s2),
              child: Column(children: [
                for (var i = 0; i < c.steps.length; i++)
                  _StepRow(
                    n: i + 1,
                    step: c.steps[i],
                    lang: lang,
                    style: s,
                    last: i == c.steps.length - 1,
                  ),
              ]),
            ),
          ),
          if (c.urgency == Urgency.red)
            Padding(
              padding: const EdgeInsets.only(top: Tokens.s3),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: s.bg, foregroundColor: s.fg),
                onPressed: () => _forward(context, ref, c, l),
                icon: const Icon(Icons.send_outlined),
                label: Text(l.sendToExpert),
              ),
            ),

          // Findings sit next to the trace they were read from, so the user can check them.
          SectionTitle(l.findings, icon: Icons.search),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Tokens.s4, Tokens.s3, Tokens.s4, Tokens.s2),
                child: Row(children: [
                  const Icon(Icons.show_chart, size: 18, color: Tokens.inkMuted),
                  const SizedBox(width: Tokens.s2),
                  Expanded(
                      child: Text(l.ecgTrace,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Tokens.inkMuted))),
                  const Icon(Icons.swipe, size: 18, color: Tokens.inkMuted),
                ]),
              ),
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
              if (c.highlights.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(Tokens.s4, Tokens.s3 - 2, Tokens.s4, Tokens.s3),
                  child: Row(children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Tokens.highlight.withValues(alpha: 0.16),
                        border: Border.all(color: Tokens.highlight, width: 1.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: Tokens.s2),
                    Expanded(child: Text(l.highlightLegend, style: const TextStyle(fontSize: 13, color: Tokens.inkMuted))),
                  ]),
                )
              else
                const SizedBox(height: Tokens.s2),
            ]),
          ),
          for (final f in c.findings) ...[
            const SizedBox(height: Tokens.s2),
            _FindingCard(finding: f, lang: lang),
          ],
          for (final n in c.extraNotices) NoticeBox(text: _notice(l, n), icon: Icons.report_outlined, strong: true),

          SectionTitle(l.technical, icon: Icons.tune),
          Card(
            child: Column(children: [
              _kv(l.paperSpeed, '${c.tech.speedMmS ?? '—'} mm/s'),
              const Divider(),
              _kv(l.gain, '${c.tech.gainMmMv ?? '—'} mm/mV'),
              const Divider(),
              _kv(l.leadsFound, '${c.tech.leadsFound} · ${c.tech.layout}'),
              const Divider(),
              _kv(l.imageQuality, '${(c.tech.quality * 100).round()} / 100'),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Tokens.s1, Tokens.s2, Tokens.s1, 0),
            child: Text('${l.versions('0.1.0-demo', 'none (demo)', '2026-11-04')}\n${l.caseId}: ${c.id}',
                style: t.bodySmall),
          ),
          const SizedBox(height: Tokens.s5),
          ActionPair(
            secondary: OutlinedButton.icon(
              onPressed: () => _forward(context, ref, c, l),
              icon: const Icon(Icons.send_outlined),
              label: Text(l.sendShort),
            ),
            primary: FilledButton(
              onPressed: () => context.go('/home'),
              child: Text(l.done),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SafeArea(child: DisclaimerBar()),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Tokens.s4, vertical: Tokens.s3 - 1),
        child: Row(children: [
          Expanded(child: Text(k, style: const TextStyle(fontSize: 15, color: Tokens.inkMuted))),
          const SizedBox(width: Tokens.s2),
          Text(v, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      );

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
        padding: const EdgeInsets.fromLTRB(Tokens.s5 - 4, 0, Tokens.s5 - 4, Tokens.s5),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.sendToExpert, style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: Tokens.s2),
          Text(l.forwardConsent, style: Theme.of(ctx).textTheme.bodyLarge),
          const SizedBox(height: Tokens.s4),
          FilledButton.icon(
            icon: const Icon(Icons.send_outlined),
            onPressed: () {
              ref.read(casesProvider.notifier).markForwarded(c.id);
              Navigator.pop(ctx);
              _snack(context, ref.read(settingsProvider).online ? l.forwardSent : l.forwardQueued);
            },
            label: Text(l.send),
          ),
          const SizedBox(height: Tokens.s2),
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

/// One numbered action step, with a line joining it to the next step.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.n, required this.step, required this.lang, required this.style, required this.last});
  final int n;
  final ActionStep step;
  final String lang;
  final UrgencyStyle style;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 64,
          child: Column(children: [
            const SizedBox(height: Tokens.s3),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.bg,
                shape: BoxShape.circle,
                border: style.border != null ? Border.all(color: style.border!, width: 2) : null,
              ),
              child: Text('$n', style: TextStyle(color: style.fg, fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            if (!last)
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.only(top: Tokens.s1),
                  color: Tokens.outline,
                ),
              ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, Tokens.s3 + 2, Tokens.s4, Tokens.s3),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step.text.of(lang), style: const TextStyle(fontSize: 17, height: 1.35, color: Tokens.ink)),
              const SizedBox(height: Tokens.s1 + 2),
              Text(
                '${step.source}${step.reviewed ? '' : ' · ${l.pendingReview}'}',
                style: const TextStyle(fontSize: 12.5, height: 1.3, color: Tokens.inkMuted),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// A finding as its own card. "Suspected" is a label, not a button.
class _FindingCard extends StatelessWidget {
  const _FindingCard({required this.finding, required this.lang});
  final Finding finding;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = finding;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s4 - 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: f.suspected ? const Color(0xFFFFF4D6) : Tokens.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(f.suspected ? Icons.help_outline : Icons.circle_outlined,
                size: 20, color: f.suspected ? Tokens.caution : Tokens.brand),
          ),
          const SizedBox(width: Tokens.s3),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (f.suspected) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Tokens.s2, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Tokens.caution.withValues(alpha: 0.6)),
                  ),
                  child: Text(l.suspected,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Tokens.caution)),
                ),
                const SizedBox(height: Tokens.s1 + 2),
              ],
              Text(f.title.of(lang), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3)),
              if (f.detail != null) ...[
                const SizedBox(height: 2),
                Text(f.detail!.of(lang), style: const TextStyle(fontSize: 15, color: Tokens.inkMuted)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}
