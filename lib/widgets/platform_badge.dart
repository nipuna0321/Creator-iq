import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class PlatformBadge extends StatelessWidget {
  final String platform;
  final bool isSelected;
  final VoidCallback? onTap;

  const PlatformBadge({
    super.key,
    required this.platform,
    this.isSelected = false,
    this.onTap,
  });

  Color get platformColor {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return AppTheme.instagram;
      case 'youtube':
        return AppTheme.youtube;
      case 'tiktok':
        return AppTheme.tiktok;
      case 'linkedin':
        return AppTheme.linkedin;
      default:
        return AppTheme.primary;
    }
  }

  IconData get platformIcon {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'tiktok':
        return Icons.music_note_outlined;
      case 'linkedin':
        return Icons.business_center_outlined;
      default:
        return Icons.public;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = platformColor;

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected ? color : AppTheme.borderLight,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                platformIcon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                platform,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Static badge representation
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(platformIcon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            platform,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

