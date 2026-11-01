import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'gradient_button.dart';

/// Friendly placeholder for empty lists: a layered icon "illustration",
/// a title, a message and an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration: concentric gradient rings around the icon.
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _ring(140, 0.06),
                _ring(104, 0.12),
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                Positioned(top: 18, right: 22, child: _dot(10, AppColors.cyan)),
                Positioned(bottom: 22, left: 16, child: _dot(8, AppColors.pink)),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -4, end: 4, duration: 1800.ms, curve: Curves.easeInOut),
          const SizedBox(height: 20),
          Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            GradientButton(label: actionLabel!, onPressed: onAction, expanded: false, height: 48),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _ring(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.violet.withValues(alpha: alpha),
        ),
      );

  Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
