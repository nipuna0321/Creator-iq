import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/post.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/platform_style.dart';

/// Lets the user link social accounts (mock OAuth) or choose manual entry.
///
/// Used both after sign-up and from Profile → Manage connected platforms.
class ConnectAccountsScreen extends ConsumerStatefulWidget {
  const ConnectAccountsScreen({super.key});

  @override
  ConsumerState<ConnectAccountsScreen> createState() => _ConnectAccountsScreenState();
}

class _ConnectAccountsScreenState extends ConsumerState<ConnectAccountsScreen> {
  /// Platforms currently going through the connect flow.
  final Set<SocialPlatform> _connecting = {};

  Future<void> _toggle(SocialPlatform p, bool connected) async {
    final notifier = ref.read(userProvider.notifier);
    if (connected) {
      notifier.disconnect(p);
      return;
    }
    setState(() => _connecting.add(p));
    try {
      await notifier.connect(p);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.label} connected')));
      }
    } finally {
      if (mounted) setState(() => _connecting.remove(p));
    }
  }

  /// When opened from Profile we pop back; during onboarding we go Home.
  void _done() => context.canPop() ? context.pop() : context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final connectedCount = user?.connectedAccounts.length ?? 0;
    final fromProfile = context.canPop();

    return Scaffold(
      appBar: AppBar(title: Text(fromProfile ? 'Connected platforms' : '')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppConstants.gutter, 0, AppConstants.gutter, AppConstants.gutter),
          children: [
            if (!fromProfile) ...[
              Text('Connect your accounts', style: context.text.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Link your social profiles so CreateIQ can analyze your performance automatically.',
                style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
            ],
            for (final (i, p) in SocialPlatform.values.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlatformCard(
                  platform: p,
                  connected: user?.accountFor(p).connected ?? false,
                  followers: user?.accountFor(p).followers ?? 0,
                  handle: user?.accountFor(p).handle ?? '',
                  loading: _connecting.contains(p),
                  onPressed: () => _toggle(p, user?.accountFor(p).connected ?? false),
                ).animate().fadeIn(delay: (80 * i).ms).slideX(begin: 0.08, end: 0),
              ),
            const SizedBox(height: 12),
            GradientButton(
              label: connectedCount == 0 ? 'Continue' : 'Continue with $connectedCount connected',
              icon: LucideIcons.arrowRight,
              onPressed: _done,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // Manual path: fill in the guided questions, then land on Add Data.
                if (!fromProfile) context.go(Routes.addData);
                context.push(Routes.questionnaire);
              },
              icon: const Icon(LucideIcons.edit3, size: 18),
              label: const Text('Enter data manually instead', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.shieldCheck, size: 14, color: context.colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('Read-only access. We never post on your behalf.', style: context.text.bodySmall),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.platform,
    required this.connected,
    required this.followers,
    required this.handle,
    required this.loading,
    required this.onPressed,
  });

  final SocialPlatform platform;
  final bool connected;
  final int followers;
  final String handle;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: connected ? Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 1.5) : null,
      child: Row(
        children: [
          PlatformBadge(platform: platform, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platform.label, style: context.text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  connected ? '$handle · ${Fmt.compact(followers)} followers' : 'Not connected',
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            child: connected
                ? OutlinedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(LucideIcons.check, size: 16, color: AppColors.success),
                    label: const Text('Connected', style: TextStyle(color: AppColors.success)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.success.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                : FilledButton(
                    onPressed: loading ? null : onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.violet,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Connect'),
                  ),
          ),
        ],
      ),
    );
  }
}
