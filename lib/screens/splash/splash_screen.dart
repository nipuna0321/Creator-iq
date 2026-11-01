import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/core_providers.dart';
import '../../providers/user_provider.dart';

/// Animated logo on the brand gradient; then routes to onboarding, login or home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), _next);
  }

  void _next() {
    if (!mounted) return;
    final onboarded = ref.read(storageProvider).getBool(AppConstants.kOnboarded);
    final user = ref.read(userProvider);
    if (!onboarded) {
      context.go(Routes.onboarding);
    } else if (user == null) {
      context.go(Routes.login);
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft pulsing glow behind the logo.
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.8, end: 1.15, duration: 1400.ms, curve: Curves.easeInOut),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (r) => AppColors.primaryGradient.createShader(r),
                    child: const Icon(LucideIcons.sparkles, size: 48, color: Colors.white),
                  ),
                )
                    .animate()
                    .scaleXY(begin: 0.4, end: 1, duration: 700.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms)
                    .then(delay: 200.ms)
                    .rotate(begin: 0, end: 0.02, duration: 300.ms)
                    .then()
                    .rotate(begin: 0.02, end: 0, duration: 300.ms),
                const SizedBox(height: 24),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Smarter content. Faster growth.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
                ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
              ],
            ),
            Positioned(
              bottom: 60,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              ).animate().fadeIn(delay: 1000.ms),
            ),
          ],
        ),
      ),
    );
  }
}
