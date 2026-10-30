import '../models/content_plan.dart';

abstract interface class ContentPlanRepository {
  Future<List<ContentPlan>> getAllPlans();
  Future<void> savePlan(ContentPlan plan);
  Future<void> updatePlanStatus(String id, ContentPlanStatus status);
  Future<void> deletePlan(String id);
}

class InMemoryContentPlanRepository implements ContentPlanRepository {
  final List<ContentPlan> _plans = [];

  InMemoryContentPlanRepository([List<ContentPlan>? initialPlans]) {
    if (initialPlans != null) {
      _plans.addAll(initialPlans);
    }
  }

  @override
  Future<List<ContentPlan>> getAllPlans() async {
    return List.unmodifiable(_plans);
  }

  @override
  Future<void> savePlan(ContentPlan plan) async {
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index >= 0) {
      _plans[index] = plan;
    } else {
      _plans.insert(0, plan);
    }
  }

  @override
  Future<void> updatePlanStatus(String id, ContentPlanStatus status) async {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _plans[index] = _plans[index].copyWith(status: status);
    }
  }

  @override
  Future<void> deletePlan(String id) async {
    _plans.removeWhere((p) => p.id == id);
  }
}

