import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/content_plan.dart';
import '../../viewmodels/content_planner_viewmodel.dart';
import '../../widgets/modern_button.dart';
import '../../widgets/platform_badge.dart';

class ContentPlannerView extends StatelessWidget {
  final ContentPlannerViewModel viewModel;

  const ContentPlannerView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;

        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        final plans = vm.filteredPlans;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Create Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Content Planner',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Data-backed weekly production schedule',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _showAddPlanModal(context, vm),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.elevatedShadow,
                          ),
                          child: const Icon(Icons.add, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusFilterChip(
                          label: 'All Items',
                          isSelected: vm.filterStatus == null,
                          onTap: () => vm.setFilterStatus(null),
                        ),
                        ...ContentPlanStatus.values.map((status) {
                          return _buildStatusFilterChip(
                            label: status.label,
                            isSelected: vm.filterStatus == status,
                            onTap: () => vm.setFilterStatus(status),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Plans List
                  if (plans.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 40, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No plans found for this filter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add a new post schedule backed by your analytics evidence.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ModernButton(
                            text: 'Plan a New Post',
                            icon: Icons.add,
                            onPressed: () => _showAddPlanModal(context, vm),
                          ),
                        ],
                      ),
                    )
                  else
                    ...plans.map((plan) => _buildPlanCard(context, vm, plan)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.borderLight,
              width: 1.2,
            ),
            boxShadow: isSelected ? AppTheme.elevatedShadow : AppTheme.cardShadow,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, ContentPlannerViewModel vm, ContentPlan plan) {
    Color statusColor;
    Color statusBg;
    switch (plan.status) {
      case ContentPlanStatus.planned:
        statusColor = AppTheme.textSecondary;
        statusBg = AppTheme.surfaceMuted;
        break;
      case ContentPlanStatus.inProduction:
        statusColor = AppTheme.warning;
        statusBg = AppTheme.warningLight;
        break;
      case ContentPlanStatus.readyToPublish:
        statusColor = AppTheme.primary;
        statusBg = AppTheme.primaryLight;
        break;
      case ContentPlanStatus.published:
        statusColor = AppTheme.success;
        statusBg = AppTheme.successLight;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Platform, format, status menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PlatformBadge(platform: plan.platform),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plan.contentType,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                // Status Popup Menu
                PopupMenuButton<ContentPlanStatus>(
                  onSelected: (newStatus) => vm.updatePlanStatus(plan.id, newStatus),
                  itemBuilder: (context) => ContentPlanStatus.values.map((s) {
                    return PopupMenuItem(
                      value: s,
                      child: Text(s.label),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          plan.status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 14, color: statusColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Plan Topic
            Text(
              plan.topic,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Scheduled Date & Target
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  Formatters.shortDate(plan.scheduledDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (plan.targetMetric != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.flag_outlined, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    plan.targetMetric!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Evidence / Rationale card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 15, color: AppTheme.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Why: ${plan.rationale}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (plan.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${plan.notes}',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textMuted,
                ),
              ),
            ],

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textMuted),
                onPressed: () => vm.deletePlan(plan.id),
                tooltip: 'Delete Plan',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlanModal(BuildContext context, ContentPlannerViewModel vm) {
    final topicCtrl = TextEditingController();
    final rationaleCtrl = TextEditingController(text: 'Reels generated higher median reach in recent tests.');
    final targetCtrl = TextEditingController(text: 'Target: 8K+ Reach');
    String selectedPlatform = 'Instagram';
    String selectedFormat = 'Reel';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add to Content Schedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Plan a data-backed post with an explicit rationale.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),

                // Platform selection
                const Text('Platform', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: ['Instagram', 'YouTube', 'TikTok'].map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PlatformBadge(
                        platform: p,
                        isSelected: selectedPlatform == p,
                        onTap: () => setModalState(() => selectedPlatform = p),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Format selection
                const Text('Format', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Reel', 'Video', 'Short', 'Carousel'].map((f) {
                    final isSel = selectedFormat == f;
                    return ChoiceChip(
                      label: Text(f),
                      selected: isSel,
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setModalState(() => selectedFormat = f),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Topic title
                TextField(
                  controller: topicCtrl,
                  decoration: InputDecoration(
                    labelText: 'Content Idea / Hook',
                    hintText: 'e.g. 5 Editing shortcuts that save 2 hours',
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Target metric
                TextField(
                  controller: targetCtrl,
                  decoration: InputDecoration(
                    labelText: 'Target Performance Goal',
                    hintText: 'Target: 10K Reach',
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Rationale
                TextField(
                  controller: rationaleCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Data Rationale (Why this content?)',
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ModernButton(
                  text: 'Add to Schedule',
                  icon: Icons.check,
                  onPressed: () {
                    final topic = topicCtrl.text.trim();
                    if (topic.isEmpty) return;

                    final newPlan = ContentPlan(
                      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
                      topic: topic,
                      platform: selectedPlatform,
                      contentType: selectedFormat,
                      scheduledDate: DateTime.now().add(const Duration(days: 2)),
                      rationale: rationaleCtrl.text.trim(),
                      targetMetric: targetCtrl.text.trim(),
                    );

                    vm.addPlan(newPlan);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

