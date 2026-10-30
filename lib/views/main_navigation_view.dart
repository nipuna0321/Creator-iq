import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../repositories/post_repository.dart';
import '../repositories/content_plan_repository.dart';
import '../services/analytics_service.dart';
import '../services/sample_data_service.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../viewmodels/import_viewmodel.dart';
import '../viewmodels/content_planner_viewmodel.dart';
import 'dashboard/dashboard_view.dart';
import 'data_import/import_view.dart';
import 'analytics/analytics_view.dart';
import 'content_planner/content_planner_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  // Repositories & Services
  late final PostRepository _postRepository;
  late final ContentPlanRepository _planRepository;
  late final AnalyticsService _analyticsService;

  // ViewModels
  late final DashboardViewModel _dashboardViewModel;
  late final AnalyticsViewModel _analyticsViewModel;
  late final ImportViewModel _importViewModel;
  late final ContentPlannerViewModel _plannerViewModel;

  @override
  void initState() {
    super.initState();

    // Initialize with rich sample data so the frontend is 100% functional out of the box
    _postRepository = InMemoryPostRepository(SampleDataService.getInitialPosts());
    _planRepository = InMemoryContentPlanRepository(SampleDataService.getInitialPlans());
    _analyticsService = AnalyticsService();

    _dashboardViewModel = DashboardViewModel(
      postRepository: _postRepository,
      analyticsService: _analyticsService,
    );

    _analyticsViewModel = AnalyticsViewModel(
      postRepository: _postRepository,
      analyticsService: _analyticsService,
    );

    _importViewModel = ImportViewModel(
      postRepository: _postRepository,
    );

    _plannerViewModel = ContentPlannerViewModel(
      planRepository: _planRepository,
    );
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });

    // Automatically synchronize dashboards when switching tabs
    if (index == 0) {
      _dashboardViewModel.refresh();
    } else if (index == 2) {
      _analyticsViewModel.loadAnalytics();
    } else if (index == 3) {
      _plannerViewModel.loadPlans();
    }
  }

  void _onImportCompleted() {
    _dashboardViewModel.refresh();
    _analyticsViewModel.loadAnalytics();
    setState(() {
      _currentIndex = 0; // Jump back to dashboard to view newly imported analytics
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardView(
            viewModel: _dashboardViewModel,
            onNavigateTab: _onTabSelected,
          ),
          ImportView(
            viewModel: _importViewModel,
            onImportSuccess: _onImportCompleted,
          ),
          AnalyticsView(
            viewModel: _analyticsViewModel,
          ),
          ContentPlannerView(
            viewModel: _plannerViewModel,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          border: const Border(
            top: BorderSide(color: AppTheme.borderLight, width: 1.0),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: AppTheme.surfaceWhite,
          elevation: 0,
          indicatorColor: AppTheme.primaryLight,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.file_upload_outlined),
              selectedIcon: Icon(Icons.file_upload_rounded, color: AppTheme.primary),
              label: 'Import',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded, color: AppTheme.primary),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
              label: 'Planner',
            ),
          ],
        ),
      ),
    );
  }
}

