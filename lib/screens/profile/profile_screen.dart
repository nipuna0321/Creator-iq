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
import '../../models/user.dart';
import '../../providers/questionnaire_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/platform_style.dart';
import '../../widgets/section_header.dart';

/// Profile header, connected accounts and app settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final dark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final notifications = ref.watch(notificationsProvider);
    final language = ref.watch(languageProvider);
    final questionnaireDone = ref.watch(questionnaireProvider.select((a) => a.completed));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppConstants.gutter, 8, AppConstants.gutter, 40),
        children: [
          if (user != null) _Header(user: user).animate().fadeIn(duration: 300.ms),
          SectionHeader(
            title: 'Connected accounts',
            actionLabel: 'Manage',
            onAction: () => context.push(Routes.connect),
            padding: const EdgeInsets.only(top: 24, bottom: 8),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                if (user == null || user.connectedAccounts.isEmpty)
                  ListTile(
                    leading: const Icon(LucideIcons.link2),
                    title: const Text('No accounts connected'),
                    subtitle: const Text('Tap to connect your platforms'),
                    onTap: () => context.push(Routes.connect),
                  )
                else
                  for (final a in user.connectedAccounts)
                    ListTile(
                      leading: PlatformBadge(platform: a.platform, size: 38),
                      title: Text(a.platform.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(a.handle),
                      trailing: Text('${Fmt.compact(a.followers)} followers', style: context.text.bodySmall),
                    ),
              ],
            ),
          ),
          const SectionHeader(title: 'Settings', padding: EdgeInsets.only(top: 24, bottom: 8)),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _SwitchTile(
                  icon: dark ? LucideIcons.moon : LucideIcons.sun,
                  title: 'Dark mode',
                  value: dark,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setDark(v),
                ),
                _SwitchTile(
                  icon: LucideIcons.bell,
                  title: 'Notifications',
                  value: notifications,
                  onChanged: (v) => ref.read(notificationsProvider.notifier).set(v),
                ),
                _Tile(
                  icon: LucideIcons.globe,
                  title: 'Language',
                  trailing: Text(language, style: context.text.bodySmall),
                  onTap: () => _pickLanguage(context, ref, language),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Account', padding: EdgeInsets.only(top: 24, bottom: 8)),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _Tile(
                  icon: LucideIcons.userCog,
                  title: 'Edit profile',
                  onTap: user == null ? null : () => _editProfile(context, ref, user),
                ),
                _Tile(
                  icon: LucideIcons.link2,
                  title: 'Manage connected platforms',
                  onTap: () => context.push(Routes.connect),
                ),
                _Tile(
                  icon: LucideIcons.listChecks,
                  title: 'Content preferences',
                  trailing: questionnaireDone
                      ? const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 18)
                      : Text('Set up', style: context.text.bodySmall?.copyWith(color: AppColors.pink)),
                  onTap: () => context.push(Routes.questionnaire),
                ),
                _Tile(
                  icon: LucideIcons.fileText,
                  title: 'Insights report',
                  onTap: () => context.push(Routes.insights),
                ),
                _Tile(
                  icon: LucideIcons.helpCircle,
                  title: 'Help & support',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support: hello@createiq.app')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context, ref),
            icon: const Icon(LucideIcons.logOut, color: AppColors.danger, size: 18),
            label: const Text('Log out', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('${AppConstants.appName} v1.0.0', style: context.text.bodySmall)),
        ],
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref, String current) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (v) => Navigator.pop(ctx, v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final lang in AppConstants.languages)
                RadioListTile<String>(value: lang, title: Text(lang), activeColor: AppColors.violet),
            ],
          ),
        ),
      ),
    );
    if (picked != null) ref.read(languageProvider.notifier).set(picked);
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref, User user) async {
    final name = TextEditingController(text: user.name);
    final bio = TextEditingController(text: user.bio);
    var niche = AppConstants.niches.contains(user.niche) ? user.niche : 'Other';
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit profile', style: ctx.text.titleLarge),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: name,
                    label: 'Name',
                    icon: LucideIcons.user,
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(controller: bio, label: 'Bio', maxLines: 3, hint: 'Tell people what you create'),
                  const SizedBox(height: 16),
                  Text('Niche', style: ctx.text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final n in AppConstants.niches)
                        ChoiceChip(
                          label: Text(n),
                          selected: niche == n,
                          onSelected: (_) => setSheet(() => niche = n),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Save changes',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      ref.read(userProvider.notifier).updateProfile(
                            name: name.text.trim(),
                            bio: bio.text.trim(),
                            niche: niche,
                          );
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    name.dispose();
    bio.dispose();
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in any time. Your manual entries stay on this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(userProvider.notifier).logout();
    if (context.mounted) context.go(Routes.login);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppConstants.gutter),
      child: Row(
        children: [
          Avatar(initials: user.initials, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: context.text.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(user.email, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Tag(text: user.niche, color: AppColors.violet),
                    _Tag(text: '${Fmt.compact(user.totalFollowers)} followers', color: AppColors.cyan),
                  ],
                ),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(user.bio, style: context.text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.trailing, this.onTap});

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?trailing,
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronRight, size: 18, color: context.colors.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({required this.icon, required this.title, required this.value, required this.onChanged});

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
    );
  }
}
