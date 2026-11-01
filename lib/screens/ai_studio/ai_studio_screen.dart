import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/content_idea.dart';
import '../../providers/ai_studio_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/shimmer_loading.dart';
import 'idea_card.dart';
import 'weekly_calendar.dart';

/// AI content generator with tabs for ideas, captions, hashtags and a weekly calendar.
class AiStudioScreen extends ConsumerStatefulWidget {
  const AiStudioScreen({super.key});

  @override
  ConsumerState<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends ConsumerState<AiStudioScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: IdeaType.values.length, vsync: this);
  final _topic = TextEditingController();
  Tone _tone = Tone.casual;

  @override
  void dispose() {
    _tabs.dispose();
    _topic.dispose();
    super.dispose();
  }

  void _generate(IdeaType type) {
    FocusScope.of(context).unfocus();
    ref.read(aiStudioProvider.notifier).generate(type, _topic.text, _tone);
  }

  void _copy(ContentIdea idea) {
    Clipboard.setData(ClipboardData(text: idea.copyText));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void _showSaved() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Consumer(builder: (ctx, ref, _) {
        final saved = ref.watch(aiStudioProvider).saved;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          builder: (ctx, scroll) => saved.isEmpty
              ? const SingleChildScrollView(
                  child: EmptyState(
                    icon: LucideIcons.bookmark,
                    title: 'Nothing saved yet',
                    message: 'Tap the bookmark on any result to keep it here.',
                  ),
                )
              : ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(AppConstants.gutter, 0, AppConstants.gutter, 32),
                  children: [
                    Text('Saved ideas', style: ctx.text.titleLarge),
                    const SizedBox(height: 12),
                    for (final idea in saved)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IdeaCard(
                          idea: idea,
                          saved: true,
                          onCopy: () => _copy(idea),
                          onSave: () => ref.read(aiStudioProvider.notifier).toggleSave(idea),
                        ),
                      ),
                  ],
                ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedCount = ref.watch(aiStudioProvider.select((s) => s.saved.length));
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (r) => AppColors.primaryGradient.createShader(r),
              child: const Icon(LucideIcons.sparkles, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('AI Studio'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saved ideas',
            onPressed: _showSaved,
            icon: Badge(
              isLabelVisible: savedCount > 0,
              label: Text('$savedCount'),
              backgroundColor: AppColors.pink,
              child: const Icon(LucideIcons.bookmark),
            ),
          ),
          IconButton(
            tooltip: 'Ask AI',
            onPressed: () => context.push(Routes.chat),
            icon: const Icon(LucideIcons.bot),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.violet,
          indicatorColor: AppColors.violet,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [for (final t in IdeaType.values) Tab(text: t.label)],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: TabBarView(
          controller: _tabs,
          children: [for (final t in IdeaType.values) _tab(t)],
        ),
      ),
    );
  }

  Widget _tab(IdeaType type) {
    final state = ref.watch(aiStudioProvider);
    final loading = state.loading.contains(type);
    final results = state.results[type] ?? [];
    final notifier = ref.read(aiStudioProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppConstants.gutter, AppConstants.gap, AppConstants.gutter, 32),
      children: [
        _PromptCard(
          controller: _topic,
          tone: _tone,
          onTone: (t) => setState(() => _tone = t),
          loading: loading,
          buttonLabel: type == IdeaType.calendar ? 'Generate my week' : 'Generate ${type.label.toLowerCase()}',
          onGenerate: () => _generate(type),
        ),
        const SizedBox(height: 20),
        if (loading)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.sparkles, color: AppColors.violet, size: 18)
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: 1200.ms),
                  const SizedBox(width: 8),
                  Text('AI is crafting your content…', style: context.text.bodyMedium),
                ],
              ),
              const SizedBox(height: 16),
              const ShimmerList(count: 3, itemHeight: 120),
            ],
          )
        else if (results.isEmpty)
          EmptyState(
            icon: type == IdeaType.calendar ? LucideIcons.calendarDays : LucideIcons.wand2,
            title: 'Ready when you are',
            message: type == IdeaType.calendar
                ? 'Generate a full week of post suggestions tailored to your niche.'
                : 'Describe your post and pick a tone, then hit generate.',
          )
        else if (type == IdeaType.calendar)
          WeeklyCalendar(
            items: results,
            regenerating: state.regenerating,
            isSaved: notifier.isSaved,
            onCopy: _copy,
            onSave: notifier.toggleSave,
            onRegenerate: (i) => notifier.regenerateOne(i, _topic.text, _tone),
          )
        else
          for (final (i, idea) in results.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IdeaCard(
                idea: idea,
                saved: notifier.isSaved(idea),
                regenerating: state.regenerating.contains(idea.id),
                onCopy: () => _copy(idea),
                onSave: () => notifier.toggleSave(idea),
                onRegenerate: () => notifier.regenerateOne(idea, _topic.text, _tone),
              ).animate().fadeIn(delay: (80 * i).ms, duration: 300.ms).slideY(begin: 0.1, end: 0),
            ),
      ],
    );
  }
}

/// Topic input, tone selector and Generate button.
class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.controller,
    required this.tone,
    required this.onTone,
    required this.loading,
    required this.buttonLabel,
    required this.onGenerate,
  });

  final TextEditingController controller;
  final Tone tone;
  final ValueChanged<Tone> onTone;
  final bool loading;
  final String buttonLabel;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.gap),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.2)),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What\'s your post about?', style: context.text.titleMedium),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 2,
            minLines: 1,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onGenerate(),
            decoration: const InputDecoration(
              hintText: 'e.g. morning workout routine for beginners',
              prefixIcon: Icon(LucideIcons.edit3, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          Text('Tone', style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in Tone.values)
                ChoiceChip(
                  label: Text('${t.emoji} ${t.label}'),
                  selected: tone == t,
                  onSelected: (_) => onTone(t),
                  labelStyle: TextStyle(
                    fontWeight: tone == t ? FontWeight.w700 : FontWeight.w500,
                    color: tone == t ? AppColors.violet : context.colors.onSurface,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: buttonLabel,
            icon: LucideIcons.sparkles,
            loading: loading,
            height: 52,
            onPressed: onGenerate,
          ),
        ],
      ),
    );
  }
}
