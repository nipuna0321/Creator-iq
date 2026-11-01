import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/post.dart';
import '../../providers/posts_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/number_stepper.dart';
import '../../widgets/platform_style.dart';
import '../../widgets/post_tile.dart';
import '../../widgets/section_header.dart';

/// Manual post entry form plus history of manual entries (edit / delete).
class AddDataScreen extends ConsumerStatefulWidget {
  const AddDataScreen({super.key});

  @override
  ConsumerState<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends ConsumerState<AddDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _caption = TextEditingController();

  // --- Form state ---
  String? _editingId;
  SocialPlatform _platform = SocialPlatform.instagram;
  PostType _type = PostType.image;
  DateTime _date = DateTime.now();
  String? _imagePath;
  int _likes = 0, _comments = 0, _shares = 0, _views = 0, _saves = 0, _gained = 0;
  late int _followers = _defaultFollowers(_platform);
  bool _saving = false;

  @override
  void dispose() {
    _scroll.dispose();
    _caption.dispose();
    super.dispose();
  }

  /// Prefill follower count from the connected account, else 10K.
  int _defaultFollowers(SocialPlatform p) {
    final account = ref.read(userProvider)?.accountFor(p);
    return (account != null && account.followers > 0) ? account.followers : 10000;
  }

  void _reset() {
    _formKey.currentState?.reset();
    _caption.clear();
    setState(() {
      _editingId = null;
      _platform = SocialPlatform.instagram;
      _type = PostType.image;
      _date = DateTime.now();
      _imagePath = null;
      _likes = _comments = _shares = _views = _saves = _gained = 0;
      _followers = _defaultFollowers(_platform);
    });
  }

  /// Loads an existing manual post into the form for editing.
  void _edit(Post p) {
    _caption.text = p.caption;
    setState(() {
      _editingId = p.id;
      _platform = p.platform;
      _type = p.type;
      _date = p.date;
      _imagePath = p.imagePath;
      _likes = p.likes;
      _comments = p.comments;
      _shares = p.shares;
      _views = p.views;
      _saves = p.saves;
      _gained = p.followersGained;
      _followers = p.followersAtPost;
    });
    _scroll.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    setState(() {
      _date = DateTime(date.year, date.month, date.day, time?.hour ?? _date.hour, time?.minute ?? _date.minute);
    });
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200);
      if (file != null) setState(() => _imagePath = file.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the gallery')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_likes + _comments + _shares + _saves + _views == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one metric (likes, comments, views…)')),
      );
      return;
    }
    setState(() => _saving = true);
    final wasEditing = _editingId != null;
    final post = Post(
      id: _editingId ?? const Uuid().v4(),
      platform: _platform,
      type: _type,
      date: _date,
      caption: _caption.text.trim(),
      likes: _likes,
      comments: _comments,
      shares: _shares,
      views: _views,
      saves: _saves,
      followersGained: _gained,
      followersAtPost: _followers,
      imagePath: _imagePath,
      isManual: true,
    );
    await ref.read(postsProvider.notifier).upsert(post);
    if (!mounted) return;
    setState(() => _saving = false);
    _reset();
    await _showSuccess(wasEditing);
  }

  Future<void> _showSuccess(bool updated) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radius)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                child: const Icon(LucideIcons.check, color: Colors.white, size: 44),
              )
                  .animate()
                  .scaleXY(begin: 0, end: 1, duration: 500.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 800.ms, color: Colors.white54),
              const SizedBox(height: 20),
              Text(updated ? 'Post updated!' : 'Post saved!', style: ctx.text.titleLarge)
                  .animate()
                  .fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'Your analytics have been updated with this post.',
                textAlign: TextAlign.center,
                style: ctx.text.bodyMedium?.copyWith(color: ctx.colors.onSurfaceVariant),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 24),
              GradientButton(
                label: 'View analytics',
                height: 48,
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(Routes.analytics);
                },
              ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Add another')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(Post p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text('"${p.caption.isEmpty ? p.type.label : p.caption}" will be removed from your analytics.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(postsProvider.notifier).delete(p.id);
    if (_editingId == p.id) _reset();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Entry deleted'),
      action: SnackBarAction(label: 'Undo', onPressed: () => ref.read(postsProvider.notifier).upsert(p)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(manualPostsProvider);
    final editing = _editingId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit Post' : 'Add Data'),
        actions: [
          if (editing) TextButton(onPressed: _reset, child: const Text('Cancel'))
          else
            IconButton(
              tooltip: 'Guided setup',
              icon: const Icon(LucideIcons.listChecks),
              onPressed: () => context.push(Routes.questionnaire),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(AppConstants.gutter, 4, AppConstants.gutter, 40),
          children: [
            Form(
              key: _formKey,
              child: AppCard(
                padding: const EdgeInsets.all(AppConstants.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, 'Platform'),
                    DropdownButtonFormField<SocialPlatform>(
                      // Keyed by value so the field re-initialises when editing/resetting.
                      key: ValueKey(_platform),
                      initialValue: _platform,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      items: [
                        for (final p in SocialPlatform.values)
                          DropdownMenuItem(
                            value: p,
                            child: Row(children: [
                              Icon(p.icon, size: 18),
                              const SizedBox(width: 10),
                              Text(p.label),
                            ]),
                          ),
                      ],
                      onChanged: (p) {
                        if (p == null) return;
                        setState(() {
                          _platform = p;
                          if (!editing) _followers = _defaultFollowers(p);
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    _label(context, 'Post type'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in PostType.values)
                          ChoiceChip(
                            avatar: Icon(t.icon, size: 16, color: _type == t ? AppColors.violet : null),
                            label: Text(t.label),
                            selected: _type == t,
                            onSelected: (_) => setState(() => _type = t),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _label(context, 'Post date'),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      child: InputDecorator(
                        decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.calendar, size: 20)),
                        child: Text('${Fmt.date(_date)} · ${Fmt.time(_date)}'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      controller: _caption,
                      label: 'Caption / description',
                      hint: 'What was this post about?',
                      maxLines: 3,
                      validator: (v) => (v ?? '').length > 2200 ? 'Caption is too long' : null,
                    ),
                    const SizedBox(height: 18),
                    _label(context, 'Image (optional)'),
                    _ImagePickerBox(
                      path: _imagePath,
                      onPick: _pickImage,
                      onClear: () => setState(() => _imagePath = null),
                    ),
                    const SizedBox(height: 22),
                    Text('Performance', style: context.text.titleMedium),
                    const SizedBox(height: 12),
                    _StepperGrid(children: [
                      NumberStepper(label: 'Likes', icon: LucideIcons.heart, value: _likes, step: 10,
                          onChanged: (v) => setState(() => _likes = v)),
                      NumberStepper(label: 'Comments', icon: LucideIcons.messageCircle, value: _comments,
                          onChanged: (v) => setState(() => _comments = v)),
                      NumberStepper(label: 'Shares', icon: LucideIcons.share2, value: _shares,
                          onChanged: (v) => setState(() => _shares = v)),
                      NumberStepper(label: 'Views', icon: LucideIcons.eye, value: _views, step: 100,
                          onChanged: (v) => setState(() => _views = v)),
                      NumberStepper(label: 'Saves', icon: LucideIcons.bookmark, value: _saves,
                          onChanged: (v) => setState(() => _saves = v)),
                      NumberStepper(label: 'Followers gained', icon: LucideIcons.userPlus, value: _gained,
                          onChanged: (v) => setState(() => _gained = v)),
                    ]),
                    const SizedBox(height: 14),
                    NumberStepper(
                      label: 'Account followers (for engagement rate)',
                      icon: LucideIcons.users,
                      value: _followers,
                      step: 100,
                      onChanged: (v) => setState(() => _followers = v),
                    ),
                    const SizedBox(height: 10),
                    _EngagementPreview(
                      interactions: _likes + _comments + _shares + _saves,
                      followers: _followers,
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      label: editing ? 'Update post' : 'Save post',
                      icon: editing ? LucideIcons.save : LucideIcons.checkCircle2,
                      loading: _saving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
            SectionHeader(
              title: 'Your entries',
              padding: const EdgeInsets.only(top: 28, bottom: 8),
              actionLabel: history.isEmpty ? null : '${history.length} total',
            ),
            if (history.isEmpty)
              const EmptyState(
                icon: LucideIcons.inbox,
                title: 'No manual entries yet',
                message: 'Posts you add here show up in your analytics instantly.',
              )
            else
              for (final p in history)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PostTile(
                    post: p,
                    onTap: () => _edit(p),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.moreVertical, size: 20),
                      onSelected: (v) => v == 'edit' ? _edit(p) : _delete(p),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(LucideIcons.edit3), title: Text('Edit'))),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(LucideIcons.trash2, color: AppColors.danger),
                            title: Text('Delete', style: TextStyle(color: AppColors.danger)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 250.ms),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
      );
}

/// Lays out steppers two per row (one per row on very small phones).
class _StepperGrid extends StatelessWidget {
  const _StepperGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth < 300 ? 1 : 2;
      const spacing = 12.0;
      final w = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: 14,
        children: [for (final child in children) SizedBox(width: w, child: child)],
      );
    });
  }
}

/// Live engagement-rate preview using the app's formula.
class _EngagementPreview extends StatelessWidget {
  const _EngagementPreview({required this.interactions, required this.followers});

  final int interactions;
  final int followers;

  @override
  Widget build(BuildContext context) {
    final rate = followers == 0 ? 0.0 : interactions / followers * 100;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.trendingUp, color: AppColors.violet, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Engagement rate', style: context.text.bodyMedium)),
          Text(Fmt.percent(rate, digits: 2),
              style: context.text.titleMedium?.copyWith(color: AppColors.violet, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// Dashed-style upload box that shows the picked image preview.
class _ImagePickerBox extends StatelessWidget {
  const _ImagePickerBox({required this.path, required this.onPick, required this.onClear});

  final String? path;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.radiusSmall);
    if (path != null) {
      // On web, image_picker returns a blob URL instead of a file path.
      final image = kIsWeb
          ? Image.network(path!, height: 180, width: double.infinity, fit: BoxFit.cover)
          : Image.file(File(path!), height: 180, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(height: 180, child: Center(child: Text('Image unavailable'))));
      return Stack(
        children: [
          ClipRRect(borderRadius: radius, child: image),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: onClear,
              icon: const Icon(LucideIcons.x, size: 18, color: Colors.white),
            ),
          ),
        ],
      );
    }
    return InkWell(
      onTap: onPick,
      borderRadius: radius,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.violet.withValues(alpha: 0.35), width: 1.5),
          color: AppColors.violet.withValues(alpha: 0.04),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.imagePlus, color: AppColors.violet, size: 28),
            const SizedBox(height: 8),
            Text('Tap to upload a preview', style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}
