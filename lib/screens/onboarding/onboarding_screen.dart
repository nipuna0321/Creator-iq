import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/core_providers.dart';
import '../../widgets/gradient_button.dart';

/// Three intro slides with Skip / Next and a page indicator.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    (
      LucideIcons.trendingUp,
      'Track your growth',
      'See followers, likes, comments and engagement across every platform in one beautiful dashboard.',
      [AppColors.violet, AppColors.pink],
    ),
    (
      LucideIcons.users,
      'Understand your audience',
      'Discover when your audience is active, which content they love, and what makes them engage.',
      [AppColors.pink, AppColors.cyan],
    ),
    (
      LucideIcons.sparkles,
      'Create smarter content',
      'Generate post ideas, captions, hashtags and weekly plans with AI tuned to your niche.',
      [AppColors.cyan, AppColors.violet],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(storageProvider).setBool(AppConstants.kOnboarded, true);
    if (mounted) context.go(Routes.login);
  }

  void _next() {
    if (_page == _slides.length - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: last ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: last ? null : _finish,
                  child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _Slide(data: _slides[i]),
              ),
            ),
            // Page indicator dots.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.primaryGradient : null,
                    color: active ? null : context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.gutter),
              child: GradientButton(
                label: last ? 'Get Started' : 'Next',
                icon: last ? LucideIcons.rocket : LucideIcons.arrowRight,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.data});

  final (IconData, String, String, List<Color>) data;

  @override
  Widget build(BuildContext context) {
    final (icon, title, body, colors) = data;
    final size = MediaQuery.sizeOf(context);
    final art = (size.width * 0.62).clamp(180.0, 300.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration: gradient blob with floating icon tiles.
          SizedBox(
            width: art,
            height: art,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: art,
                  height: art,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: colors.map((c) => c.withValues(alpha: 0.15)).toList()),
                  ),
                ),
                Container(
                  width: art * 0.55,
                  height: art * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: colors.first.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 14))],
                  ),
                  child: Icon(icon, color: Colors.white, size: art * 0.24),
                ).animate().scaleXY(begin: 0.7, end: 1, duration: 500.ms, curve: Curves.easeOutBack),
                Positioned(top: art * 0.08, right: art * 0.06, child: _chip(context, LucideIcons.heart, AppColors.pink)),
                Positioned(bottom: art * 0.1, left: art * 0.02, child: _chip(context, LucideIcons.barChart3, AppColors.cyan)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center, style: context.text.headlineMedium)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: context.text.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant, height: 1.5),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.softShadow,
      ),
      child: Icon(icon, color: color, size: 22),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -5, end: 5, duration: 1600.ms, curve: Curves.easeInOut);
  }
}
