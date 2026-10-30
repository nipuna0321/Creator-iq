import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/post.dart';

/// Icon and brand colour for each social platform.
extension PlatformStyle on SocialPlatform {
  IconData get icon => switch (this) {
        SocialPlatform.instagram => LucideIcons.instagram,
        SocialPlatform.tiktok => LucideIcons.music2,
        SocialPlatform.youtube => LucideIcons.youtube,
        SocialPlatform.facebook => LucideIcons.facebook,
        SocialPlatform.x => LucideIcons.twitter,
      };

  Color get color => switch (this) {
        SocialPlatform.instagram => const Color(0xFFE1306C),
        SocialPlatform.tiktok => const Color(0xFF111111),
        SocialPlatform.youtube => const Color(0xFFFF0000),
        SocialPlatform.facebook => const Color(0xFF1877F2),
        SocialPlatform.x => const Color(0xFF14171A),
      };
}

/// Icon for each content type.
extension PostTypeStyle on PostType {
  IconData get icon => switch (this) {
        PostType.image => LucideIcons.image,
        PostType.video => LucideIcons.video,
        PostType.reel => LucideIcons.clapperboard,
        PostType.story => LucideIcons.circleDot,
      };
}

/// Rounded square badge with the platform's icon.
class PlatformBadge extends StatelessWidget {
  const PlatformBadge({super.key, required this.platform, this.size = 40});

  final SocialPlatform platform;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Near-black brand colours need a lighter tint in dark mode to stay visible.
    final c = isDark && (platform == SocialPlatform.tiktok || platform == SocialPlatform.x)
        ? Colors.white
        : platform.color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(platform.icon, color: c, size: size * 0.5),
    );
  }
}
