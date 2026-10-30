import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

/// Glassmorphism hero card: brand gradient backdrop with a frosted overlay
/// and decorative blurred orbs.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.gutter),
    this.gradient = AppColors.primaryGradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Decorative orbs behind the frosted layer.
            Positioned(top: -40, right: -30, child: _orb(140, AppColors.cyan)),
            Positioned(bottom: -50, left: -20, child: _orb(120, Colors.white)),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                padding: padding,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: Colors.white),
                  child: IconTheme.merge(
                    data: const IconThemeData(color: Colors.white),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.35),
        ),
      );
}
