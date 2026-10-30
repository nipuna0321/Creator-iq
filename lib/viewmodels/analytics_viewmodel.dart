import 'package:flutter/foundation.dart';
import '../models/social_post.dart';
import '../repositories/post_repository.dart';
import '../services/analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final PostRepository _postRepository;
  final AnalyticsService _analyticsService;

  AnalyticsViewModel({
    required PostRepository postRepository,
    required AnalyticsService analyticsService,
  })  : _postRepository = postRepository,
        _analyticsService = analyticsService {
    loadAnalytics();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedPlatform = 'All';
  String get selectedPlatform => _selectedPlatform;

  String _selectedMetric = 'Engagement';
  String get selectedMetric => _selectedMetric;

  final List<String> metrics = ['Engagement', 'Reach', 'Interactions'];
  final List<String> platforms = ['All', 'Instagram', 'YouTube', 'TikTok'];

  AnalyticsSummary _summary = AnalyticsSummary.empty;
  AnalyticsSummary get summary => _summary;

  List<SocialPost> _filteredPosts = [];
  List<SocialPost> get filteredPosts => _filteredPosts;

  Future<void> loadAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final posts = await _postRepository.getAllPosts();
      _summary = _analyticsService.calculateSummary(
        posts,
        platformFilter: _selectedPlatform,
      );

      _filteredPosts = _selectedPlatform == 'All'
          ? posts
          : posts.where((p) => p.platform.toLowerCase() == _selectedPlatform.toLowerCase()).toList();
    } catch (e) {
      _errorMessage = 'Error loading analytics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPlatform(String platform) {
    if (_selectedPlatform == platform) return;
    _selectedPlatform = platform;
    loadAnalytics();
  }

  void setMetric(String metric) {
    if (_selectedMetric == metric) return;
    _selectedMetric = metric;
    notifyListeners();
  }
}

