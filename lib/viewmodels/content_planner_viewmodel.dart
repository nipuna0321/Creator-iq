import 'package:flutter/foundation.dart';
import '../models/content_plan.dart';
import '../repositories/content_plan_repository.dart';

class ContentPlannerViewModel extends ChangeNotifier {
  final ContentPlanRepository _planRepository;

  ContentPlannerViewModel({required ContentPlanRepository planRepository})
      : _planRepository = planRepository {
    loadPlans();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ContentPlan> _plans = [];
  List<ContentPlan> get plans => _plans;

  ContentPlanStatus? _filterStatus;
  ContentPlanStatus? get filterStatus => _filterStatus;

  List<ContentPlan> get filteredPlans {
    if (_filterStatus == null) return _plans;
    return _plans.where((p) => p.status == _filterStatus).toList();
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      _plans = await _planRepository.getAllPlans();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterStatus(ContentPlanStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> updatePlanStatus(String id, ContentPlanStatus newStatus) async {
    await _planRepository.updatePlanStatus(id, newStatus);
    await loadPlans();
  }

  Future<void> addPlan(ContentPlan plan) async {
    await _planRepository.savePlan(plan);
    await loadPlans();
  }

  Future<void> deletePlan(String id) async {
    await _planRepository.deletePlan(id);
    await loadPlans();
  }
}

