import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/content_idea.dart';
import 'core_providers.dart';
import 'questionnaire_provider.dart';
import 'user_provider.dart';

/// State of the AI Studio: results per tab plus what is currently loading.
class AiStudioState {
  const AiStudioState({
    this.results = const {},
    this.loading = const {},
    this.regenerating = const {},
    this.saved = const [],
    this.error,
  });

  final Map<IdeaType, List<ContentIdea>> results;

  /// Tabs whose whole result set is being generated.
  final Set<IdeaType> loading;

  /// Ids of single cards being regenerated.
  final Set<String> regenerating;

  /// Ideas the user bookmarked, persisted locally.
  final List<ContentIdea> saved;
  final String? error;

  AiStudioState copyWith({
    Map<IdeaType, List<ContentIdea>>? results,
    Set<IdeaType>? loading,
    Set<String>? regenerating,
    List<ContentIdea>? saved,
    String? error,
  }) =>
      AiStudioState(
        results: results ?? this.results,
        loading: loading ?? this.loading,
        regenerating: regenerating ?? this.regenerating,
        saved: saved ?? this.saved,
        error: error,
      );
}

class AiStudioNotifier extends Notifier<AiStudioState> {
  @override
  AiStudioState build() {
    final saved =
        ref.read(storageProvider).getJsonList(AppConstants.kSavedIdeas).map(ContentIdea.fromJson).toList();
    return AiStudioState(saved: saved);
  }

  /// Questionnaire niche, falling back to the profile niche.
  String? get _niche => ref.read(questionnaireProvider).niche ?? ref.read(userProvider)?.niche;

  /// Calls the AI to generate a full result set for one tab.
  Future<void> generate(IdeaType type, String topic, Tone tone) async {
    state = state.copyWith(loading: {...state.loading, type});
    try {
      final ideas = await ref
          .read(apiServiceProvider)
          .generateContent(type: type, topic: topic, tone: tone, niche: _niche);
      state = state.copyWith(
        results: {...state.results, type: ideas},
        loading: {...state.loading}..remove(type),
      );
    } catch (e) {
      state = state.copyWith(loading: {...state.loading}..remove(type), error: e.toString());
    }
  }

  /// Replaces one result card with a freshly generated alternative.
  Future<void> regenerateOne(ContentIdea idea, String topic, Tone tone) async {
    state = state.copyWith(regenerating: {...state.regenerating, idea.id});
    try {
      final fresh = await ref
          .read(apiServiceProvider)
          .generateContent(type: idea.type, topic: topic, tone: tone, niche: _niche);
      final list = state.results[idea.type] ?? [];
      final index = list.indexWhere((i) => i.id == idea.id);
      if (index < 0 || fresh.isEmpty) return;
      // Calendar slots keep their weekday; other types take the first new idea.
      final replacement = idea.weekday == null
          ? fresh.first
          : fresh.firstWhere((f) => f.weekday == idea.weekday, orElse: () => fresh.first);
      final updated = [...list]..[index] = replacement;
      state = state.copyWith(results: {...state.results, idea.type: updated});
    } finally {
      state = state.copyWith(regenerating: {...state.regenerating}..remove(idea.id));
    }
  }

  bool isSaved(ContentIdea idea) => state.saved.any((s) => s.id == idea.id);

  /// Toggles an idea in the saved list.
  void toggleSave(ContentIdea idea) {
    final saved = isSaved(idea)
        ? state.saved.where((s) => s.id != idea.id).toList()
        : [idea, ...state.saved];
    state = state.copyWith(saved: saved);
    ref.read(storageProvider).setJsonList(AppConstants.kSavedIdeas, saved.map((s) => s.toJson()).toList());
  }
}

final aiStudioProvider = NotifierProvider<AiStudioNotifier, AiStudioState>(AiStudioNotifier.new);
