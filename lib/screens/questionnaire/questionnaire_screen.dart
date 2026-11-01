import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/post.dart';
import '../../models/questionnaire_answers.dart';
import '../../providers/questionnaire_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/number_stepper.dart';
import '../../widgets/platform_style.dart';

/// Six-step guided questionnaire that personalises AI suggestions.
class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final _pages = PageController();
  late final _location = TextEditingController(text: ref.read(questionnaireProvider).location);
  int _step = 0;
  bool _saving = false;

  static const _titles = [
    ('What is your niche?', 'Pick the topic you create content about.'),
    ('Who is your target audience?', 'Helps the AI match tone and references.'),
    ('What is your main goal?', 'We\'ll prioritise suggestions that move this metric.'),
    ('How often do you post?', 'Posts per week across all platforms.'),
    ('Which content types do you create?', 'Select all that apply.'),
    ('Average performance per post', 'A rough estimate is fine.'),
  ];

  /// Current answers. `build` watches the provider, so reading here is safe in callbacks too.
  QuestionnaireAnswers get _a => ref.read(questionnaireProvider);
  void _set(QuestionnaireAnswers a) => ref.read(questionnaireProvider.notifier).update(a);

  @override
  void dispose() {
    _pages.dispose();
    _location.dispose();
    super.dispose();
  }

  /// Whether the current step has a valid answer.
  bool get _canContinue => switch (_step) {
        0 => _a.niche != null,
        1 => _a.ageRange != null,
        2 => _a.goal != null,
        4 => _a.contentTypes.isNotEmpty,
        _ => true,
      };

  void _go(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    _pages.animateToPage(step, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    _set(_a.copyWith(location: _location.text.trim()));
    await ref.read(questionnaireProvider.notifier).complete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved! AI suggestions are now personalised ✨')),
    );
    context.canPop() ? context.pop() : context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(questionnaireProvider); // rebuild when answers change
    final last = _step == _titles.length - 1;
    final progress = (_step + 1) / _titles.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(_step == 0 ? LucideIcons.x : LucideIcons.arrowLeft),
          onPressed: () => _step == 0 ? (context.canPop() ? context.pop() : context.go(Routes.home)) : _go(_step - 1),
        ),
        title: Text('Step ${_step + 1} of ${_titles.length}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Gradient progress bar.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.gutter),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(height: 8, color: context.colors.onSurfaceVariant.withValues(alpha: 0.12)),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      widthFactor: progress,
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _page(0, _nicheStep()),
                  _page(1, _audienceStep()),
                  _page(2, _goalStep()),
                  _page(3, _frequencyStep()),
                  _page(4, _contentTypeStep()),
                  _page(5, _performanceStep()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.gutter),
              child: GradientButton(
                label: last ? 'Finish' : 'Continue',
                icon: last ? LucideIcons.checkCircle2 : LucideIcons.arrowRight,
                loading: _saving,
                onPressed: _canContinue ? (last ? _finish : () => _go(_step + 1)) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Common page scaffold: title, subtitle and the step's body.
  Widget _page(int i, Widget body) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.gutter),
      children: [
        const SizedBox(height: 8),
        Text(_titles[i].$1, style: context.text.headlineSmall),
        const SizedBox(height: 6),
        Text(_titles[i].$2, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
        const SizedBox(height: 28),
        body.animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
      ],
    );
  }

  // --- Steps ---

  Widget _nicheStep() {
    const icons = {
      'Fitness': LucideIcons.dumbbell,
      'Tech': LucideIcons.cpu,
      'Food': LucideIcons.utensils,
      'Travel': LucideIcons.plane,
      'Fashion': LucideIcons.shirt,
      'Education': LucideIcons.graduationCap,
      'Other': LucideIcons.moreHorizontal,
    };
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final n in AppConstants.niches)
          _SelectChip(
            label: n,
            icon: icons[n],
            selected: _a.niche == n,
            onTap: () => _set(_a.copyWith(niche: n)),
          ),
      ],
    );
  }

  Widget _audienceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Age range', style: context.text.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final r in AppConstants.ageRanges)
              _SelectChip(label: r, selected: _a.ageRange == r, onTap: () => _set(_a.copyWith(ageRange: r))),
          ],
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _location,
          label: 'Main location',
          hint: 'e.g. United States, Sri Lanka, Worldwide',
          icon: LucideIcons.mapPin,
          onChanged: (v) => _set(_a.copyWith(location: v)),
        ),
      ],
    );
  }

  Widget _goalStep() {
    const icons = [LucideIcons.users, LucideIcons.heart, LucideIcons.shoppingBag, LucideIcons.megaphone];
    return Column(
      children: [
        for (final (i, g) in AppConstants.goals.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionCard(
              icon: icons[i],
              label: g,
              selected: _a.goal == g,
              onTap: () => _set(_a.copyWith(goal: g)),
            ),
          ),
      ],
    );
  }

  Widget _frequencyStep() {
    final n = _a.postsPerWeek;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (r) => AppColors.primaryGradient.createShader(r),
            child: Text('$n', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          Text(n == 1 ? 'post per week' : 'posts per week', style: context.text.bodyLarge),
          const SizedBox(height: 16),
          Slider(
            value: n.toDouble(),
            min: 1,
            max: 21,
            divisions: 20,
            label: '$n',
            onChanged: (v) => _set(_a.copyWith(postsPerWeek: v.round())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('1', style: context.text.bodySmall), Text('21+', style: context.text.bodySmall)],
          ),
        ],
      ),
    );
  }

  Widget _contentTypeStep() {
    return Column(
      children: [
        for (final t in PostType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionCard(
              icon: t.icon,
              label: t.label,
              multi: true,
              selected: _a.contentTypes.contains(t),
              onTap: () {
                final set = {..._a.contentTypes};
                set.contains(t) ? set.remove(t) : set.add(t);
                _set(_a.copyWith(contentTypes: set));
              },
            ),
          ),
      ],
    );
  }

  Widget _performanceStep() {
    return Column(
      children: [
        NumberStepper(
          label: 'Average likes per post',
          icon: LucideIcons.heart,
          value: _a.avgLikes,
          step: 10,
          onChanged: (v) => _set(_a.copyWith(avgLikes: v)),
        ),
        const SizedBox(height: 20),
        NumberStepper(
          label: 'Average comments per post',
          icon: LucideIcons.messageCircle,
          value: _a.avgComments,
          onChanged: (v) => _set(_a.copyWith(avgComments: v)),
        ),
      ],
    );
  }
}

/// Pill-shaped selectable chip with an optional icon.
class _SelectChip extends StatelessWidget {
  const _SelectChip({required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: selected ? AppColors.primaryGradient : null,
        color: selected ? null : context.colors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: selected ? Colors.transparent : context.colors.onSurfaceVariant.withValues(alpha: 0.25)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: selected ? Colors.white : AppColors.violet),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : context.colors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width option card with a radio/checkbox indicator.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multi = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      border: Border.all(color: selected ? AppColors.violet : Colors.transparent, width: 1.5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: selected ? 0.18 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.violet, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: context.text.titleMedium)),
          Icon(
            multi
                ? (selected ? LucideIcons.checkSquare : LucideIcons.square)
                : (selected ? LucideIcons.checkCircle2 : LucideIcons.circle),
            color: selected ? AppColors.violet : context.colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
