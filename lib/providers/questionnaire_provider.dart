import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/questionnaire_answers.dart';
import 'core_providers.dart';
import 'user_provider.dart';

/// Answers from the guided setup questionnaire, persisted locally.
class QuestionnaireNotifier extends Notifier<QuestionnaireAnswers> {
  @override
  QuestionnaireAnswers build() {
    final json = ref.read(storageProvider).getJson(AppConstants.kQuestionnaire);
    return json == null ? const QuestionnaireAnswers() : QuestionnaireAnswers.fromJson(json);
  }

  /// Updates the in-progress answers without saving.
  void update(QuestionnaireAnswers answers) => state = answers;

  /// Marks the questionnaire complete, saves it and copies the niche to the profile.
  Future<void> complete() async {
    state = state.copyWith(completed: true);
    await ref.read(storageProvider).setJson(AppConstants.kQuestionnaire, state.toJson());
    if (state.niche != null) {
      await ref.read(userProvider.notifier).updateProfile(niche: state.niche);
    }
  }
}

final questionnaireProvider =
    NotifierProvider<QuestionnaireNotifier, QuestionnaireAnswers>(QuestionnaireNotifier.new);
