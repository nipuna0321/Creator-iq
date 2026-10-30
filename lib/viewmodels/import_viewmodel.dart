import 'package:flutter/foundation.dart';
import '../models/social_post.dart';
import '../repositories/post_repository.dart';
import '../services/sample_data_service.dart';

class ImportViewModel extends ChangeNotifier {
  final PostRepository _postRepository;

  ImportViewModel({required PostRepository postRepository})
      : _postRepository = postRepository;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  ValidationReport? _report;
  ValidationReport? get report => _report;

  /// Loads sample CSV data directly for testing
  Future<void> loadSampleCsv() async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600)); // Smooth UX transition

    _report = SampleDataService.parseAndValidateCsv(SampleDataService.sampleCsvRaw);
    _isProcessing = false;
    notifyListeners();
  }

  /// Parses custom raw CSV string entered or loaded by user
  Future<void> parseCsvString(String rawCsv) async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    _report = SampleDataService.parseAndValidateCsv(rawCsv);
    _isProcessing = false;
    notifyListeners();
  }

  /// Commits verified rows to the repository
  Future<bool> commitImport() async {
    if (_report == null || _report!.validPosts.isEmpty) {
      _statusMessage = 'No valid records to import.';
      _isSuccess = false;
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      await _postRepository.savePosts(_report!.validPosts);
      _statusMessage = 'Successfully imported ${_report!.validPosts.length} posts into database!';
      _isSuccess = true;
      _report = null;
      return true;
    } catch (e) {
      _statusMessage = 'Import failed: $e';
      _isSuccess = false;
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Manually creates and saves a post from the in-app form
  Future<bool> addManualPost(SocialPost post) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await _postRepository.addPost(post);
      _statusMessage = 'Post added successfully!';
      _isSuccess = true;
      return true;
    } catch (e) {
      _statusMessage = 'Failed to add post: $e';
      _isSuccess = false;
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearReport() {
    _report = null;
    _statusMessage = null;
    notifyListeners();
  }
}

