import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/analytics_summary.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/shimmer_loading.dart';

/// AI performance report: growth score, summary, strengths, weaknesses and recommendations.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  bool _exporting = false;

  /// Placeholder: a real implementation would build a PDF (e.g. with `package:pdf`).
  Future<void> _export() async {
    setState(() => _exporting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _exporting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export coming soon — your report is ready to share!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(insightsProvider);
    final summary = ref.watch(overviewProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights Report'),
        actions: [
          IconButton(
            tooltip: 'Regenerate',
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => ref.invalidate(insightsProvider),
          ),
        ],
      ),
      body: report.when(
        loading: () => const ShimmerDashboard(),
        error: (e, _) => Center(child: Text('Could not generate report: $e')),
        data: (r) => ListView(
          padding: const EdgeInsets.fromLTRB(AppConstants.gutter, 8, AppConstants.gutter, 32),
          children: [
            if (summary != null) _ScoreCard(summary: summary, headline: r.headline),
            const SizedBox(height: AppConstants.gap),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(LucideIcons.bot, color: AppColors.violet, size: 20),
                    const SizedBox(width: 8),
                    Text('AI summary', style: context.text.titleMedium),
                  ]),
                  const SizedBox(height: 10),
                  Text(r.summary, style: context.text.bodyMedium?.copyWith(height: 1.55)),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppConstants.gap),
            _InsightList(
              title: 'Strengths',
              icon: LucideIcons.thumbsUp,
              color: AppColors.success,
              items: r.strengths,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppConstants.gap),
            _InsightList(
              title: 'Weaknesses',
              icon: LucideIcons.alertTriangle,
              color: AppColors.warning,
              items: r.weaknesses,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppConstants.gap),
            _InsightList(
              title: 'Recommendations',
              icon: LucideIcons.target,
              color: AppColors.violet,
              items: r.recommendations,
              numbered: true,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Export report (PDF)',
              icon: LucideIcons.download,
              loading: _exporting,
              onPressed: _export,
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass hero card with an animated circular growth-score gauge.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.summary, required this.headline});

  final AnalyticsSummary summary;
  final String headline;

  @override
  Widget build(BuildContext context) {
    final score = summary.growthScore;
    return GlassCard(
      child: LayoutBuilder(builder: (context, c) {
        final gauge = min(140.0, c.maxWidth * 0.4);
        return Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => SizedBox(
                width: gauge,
                height: gauge,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: v,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(v * 100).round()}',
                              style: TextStyle(fontSize: gauge * 0.28, fontWeight: FontWeight.w800, height: 1)),
                          Text('/ 100', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Growth score',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(headline, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3)),
                  const SizedBox(height: 8),
                  Text('Based on the last 30 days',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _InsightList extends StatelessWidget {
  const _InsightList({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    this.numbered = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: context.text.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          for (final (i, item) in items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: numbered
                        ? Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color))
                        : Icon(LucideIcons.check, size: 12, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: context.text.bodyMedium?.copyWith(height: 1.45))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
