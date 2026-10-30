import 'package:flutter/foundation.dart';
import '../models/social_post.dart';
import '../models/creator_profile.dart';
import '../repositories/post_repository.dart';
import '../services/analytics_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final PostRepository _postRepository;
  final AnalyticsService _analyticsService;

  DashboardViewModel({
    required PostRepository postRepository,
    required AnalyticsService analyticsService,
  })  : _postRepository = postRepository,
        _analyticsService = analyticsService {
    loadDashboard();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CreatorProfile _profile = CreatorProfile.defaultCreator;
  CreatorProfile get profile => _profile;

  AnalyticsSummary _summary = AnalyticsSummary.empty;
  AnalyticsSummary get summary => _summary;

  List<SocialPost> _allPosts = [];
  List<SocialPost> get allPosts => _allPosts;

  String _selectedPlatform = 'All';
  String get selectedPlatform => _selectedPlatform;

  final List<String> availablePlatforms = ['All', 'Instagram', 'YouTube', 'TikTok'];

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPosts = await _postRepository.getAllPosts();
      _summary = _analyticsService.calculateSummary(
        _allPosts,
        platformFilter: _selectedPlatform,
      );
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPlatformFilter(String platform) {
    if (_selectedPlatform == platform) return;
    _selectedPlatform = platform;
    _summary = _analyticsService.calculateSummary(
      _allPosts,
      platformFilter: _selectedPlatform,
    );
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}

