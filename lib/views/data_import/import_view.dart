import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/social_post.dart';
import '../../viewmodels/import_viewmodel.dart';
import '../../widgets/modern_button.dart';
import '../../widgets/platform_badge.dart';

class ImportView extends StatefulWidget {
  final ImportViewModel viewModel;
  final VoidCallback onImportSuccess;

  const ImportView({
    super.key,
    required this.viewModel,
    required this.onImportSuccess,
  });

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _rawCsvController = TextEditingController();

  // Manual entry controllers
  final _captionController = TextEditingController();
  final _viewsController = TextEditingController();
  final _reachController = TextEditingController();
  final _likesController = TextEditingController();
  final _commentsController = TextEditingController();
  final _sharesController = TextEditingController();
  String _manualPlatform = 'Instagram';
  String _manualContentType = 'Reel';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rawCsvController.dispose();
    _captionController.dispose();
    _viewsController.dispose();
    _reachController.dispose();
    _likesController.dispose();
    _commentsController.dispose();
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Screen Header
                  const Text(
                    'Import Post Data',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Upload CSV exports or manually add your social metrics.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Tab switcher (CSV Upload vs Manual Entry)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      tabs: const [
                        Tab(text: 'CSV Import'),
                        Tab(text: 'Manual Entry'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status / Feedback message
                  if (vm.statusMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: vm.isSuccess ? AppTheme.successLight : AppTheme.errorLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(
                          color: vm.isSuccess
                              ? AppTheme.success.withOpacity(0.3)
                              : AppTheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            vm.isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                            color: vm.isSuccess ? AppTheme.success : AppTheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              vm.statusMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: vm.isSuccess ? AppTheme.success : AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tab View Content
                  SizedBox(
                    height: 520,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCsvTab(vm),
                        _buildManualTab(vm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCsvTab(ImportViewModel vm) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag-and-drop Card Simulation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.35),
                width: 1.8,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 36,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Select or Load Social CSV Export',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Supports YouTube Studio, Instagram Insights, and TikTok CSV formats',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),

                // Load Sample Data Quick Action
                ModernButton(
                  text: 'Load Sample Creator CSV',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: vm.isProcessing,
                  onPressed: () => vm.loadSampleCsv(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Validation Report Display
          if (vm.report != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                border: Border.all(
                  color: vm.report!.isValid ? AppTheme.success : AppTheme.warning,
                  width: 1.4,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            vm.report!.isValid ? Icons.verified_rounded : Icons.info_outline,
                            color: vm.report!.isValid ? AppTheme.success : AppTheme.warning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vm.report!.isValid ? 'Data Validated' : 'Validation Notice',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: vm.report!.isValid ? AppTheme.success : AppTheme.warning,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceMuted,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${vm.report!.validRowsCount} of ${vm.report!.totalRowsParsed} rows valid',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.surfaceMuted),
                  const SizedBox(height: 12),

                  // Issues list if any
                  if (vm.report!.issues.isNotEmpty) ...[
                    ...vm.report!.issues.map((issue) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• Row ${issue.rowNumber}: ${issue.reason}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.error),
                          ),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Confirmation Action
                  Row(
                    children: [
                      Expanded(
                        child: ModernButton(
                          text: 'Confirm & Save (${vm.report!.validRowsCount})',
                          icon: Icons.check,
                          onPressed: () async {
                            final success = await vm.commitImport();
                            if (success && mounted) {
                              widget.onImportSuccess();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: vm.clearReport,
                        icon: const Icon(Icons.delete_outline, color: AppTheme.textMuted),
                        tooltip: 'Clear',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildManualTab(ImportViewModel vm) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: AppTheme.borderLight, width: 1.2),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Post Metrics Manually',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Platform Picker
            const Text('Platform', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Instagram', 'YouTube', 'TikTok'].map((plat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PlatformBadge(
                      platform: plat,
                      isSelected: _manualPlatform == plat,
                      onTap: () => setState(() => _manualPlatform = plat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Content Type Picker
            const Text('Content Format', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Reel', 'Video', 'Short', 'Carousel'].map((type) {
                final isSelected = _manualContentType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _manualContentType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Caption Field
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Post Caption or Title',
                hintText: 'e.g. 3 Quick lighting secrets...',
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metric inputs in 2x2 grid
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(_viewsController, 'Views', Icons.visibility_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(_reachController, 'Reach', Icons.campaign_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(_likesController, 'Likes', Icons.favorite_border),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(_commentsController, 'Comments', Icons.chat_bubble_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(_sharesController, 'Shares', Icons.share_outlined),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ModernButton(
              text: 'Save Post',
              icon: Icons.add_circle_outline,
              isLoading: vm.isProcessing,
              onPressed: () async {
                final caption = _captionController.text.trim();
                if (caption.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a post caption')),
                  );
                  return;
                }

                final post = SocialPost(
                  id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                  platform: _manualPlatform,
                  contentType: _manualContentType,
                  caption: caption,
                  publishedAt: DateTime.now(),
                  views: int.tryParse(_viewsController.text) ?? 1000,
                  reach: int.tryParse(_reachController.text) ?? 800,
                  likes: int.tryParse(_likesController.text) ?? 95,
                  comments: int.tryParse(_commentsController.text) ?? 12,
                  shares: int.tryParse(_sharesController.text) ?? 18,
                );

                final success = await vm.addManualPost(post);
                if (success && mounted) {
                  _captionController.clear();
                  _viewsController.clear();
                  _reachController.clear();
                  _likesController.clear();
                  _commentsController.clear();
                  _sharesController.clear();
                  widget.onImportSuccess();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
      ),
    );
  }
}

